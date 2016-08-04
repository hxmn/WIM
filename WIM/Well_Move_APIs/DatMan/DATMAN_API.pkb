CREATE OR REPLACE PACKAGE BODY WIM.datman_api
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Move dependent/associated well-data from one well to another. Basically, update the well-id in the associated records.

  Procedure does NOT COMMIT the change to allow caller to apply as part of wider transaction.

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   Typically, this is invoked by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE, when the last active well version is moved
   @param  pold_tlm_id - the original/old id of the well-version to be moved
   @param  pnew_tlm_id - the target/new id of well-version to be moved

 HISTORY:
   0.1    xx-xxx-xxx  -unknown- Initial version
   0.2    2015-11-05  kxedward  QC555/QC1480 - update External Dependencies and related move API's


 --------------------------------------------------------------------------------------------------------------------*/

  procedure tlm_id_change (
    pold_tlm_id   in  varchar2,
    pnew_tlm_id   in  varchar2
  )
  is
    v_detail varchar2(2000);
    begin
      --  Note: Ignore the Oilware items (OWI-DBLOAD)
      update ppdm.rm_info_item_content
          set rm_info_item_content.uwi = pnew_tlm_id
      where rm_info_item_content.uwi = pold_tlm_id
        and (   rm_info_item_content.source != 'OWI-DBLOAD'
             or rm_info_item_content.source is null
            );

      v_detail :=  ', ' || chr(10) ||  SQL%ROWCOUNT || ' RM_INFO_ITEM_CONTENT records moved.';

      update ppdm.rm_data_store
         set rm_data_store.name = pnew_tlm_id,
             rm_data_store.long_location = pnew_tlm_id
       where rm_data_store.name = pold_tlm_id;

      v_detail := v_detail || ', ' || chr(10) ||  SQL%ROWCOUNT || ' RM_DATA_STORE records moved.';

      ppdm_admin.tlm_process_logger.info('WIM.DATMAN_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: ' || pnew_tlm_id || v_detail);

    end tlm_id_change;

end datman_api;
/