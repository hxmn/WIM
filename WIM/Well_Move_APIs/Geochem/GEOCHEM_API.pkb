CREATE OR REPLACE PACKAGE BODY WIM.geochem_api
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Move dependent/associated well-data from one well to another. Basically, update the well-id in the associated records.
  Reassign items in the SAMPLE_COMPONENT  tables to a new TLM Well ID.
  Used when wells are merged or split to ensure SAMPLE_COMPONENT data is linked to the correct TLM IDs.

  Procedure does NOT COMMIT the change to allow caller to apply as part of wider transaction.

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   Typically, this is invoked by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE, when the last active well version is moved
   @param  pold_tlm_id - the original/old id of the well-version to be moved
   @param  pnew_tlm_id - the target/new id of well-version to be moved

 HISTORY:
  0.1    30-May-11   V.Rajpoot Initial version
  0.2    2015-11-05  kxedward  QC555/QC1480 - update External Dependencies and related move API's


 --------------------------------------------------------------------------------------------------------------------*/

  procedure tlm_id_change (
    pold_tlm_id   in  varchar2,
    pnew_tlm_id   in  varchar2
  )
  is
    v_detail varchar2(2000);

    begin
      update gpdr.sample_component
         set uwi = pnew_tlm_id
       where uwi = pold_tlm_id
             and component_type = 'WELL';

      v_detail :=  ', ' || chr(10) ||  SQL%ROWCOUNT || ' GPDR.SAMPLE_COMPONENT records moved.';

      ppdm_admin.tlm_process_logger.info('WIM.GEOCHEM_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: ' || pnew_tlm_id || v_detail);

    end tlm_id_change;

end geochem_api;
/