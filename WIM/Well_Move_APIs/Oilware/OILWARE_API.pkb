CREATE OR REPLACE PACKAGE BODY WIM.oilware_api
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Move dependent/associated well-data from one well to another. Basically, update the well-id in the associated records.
  OILWARE API to enable changes to be made to the Log data other than through the Oilware GUI

  Reassign logs in the PPDM well log tables database to a new TLM Well ID.
  Used when wells are merged or split to ensure log data is linked to the correct TLM IDs.

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
    cursor get_welllogs
    is
        select well_log_id
        from ppdm.well_log
        where uwi = pold_tlm_id
    ;

    v_gwl         get_welllogs%rowtype;
    v_ezid        integer;
    p_commit      varchar2(20) := 'YES';
    v_detail      varchar2(2000);

    begin
      select ez_tools.ez_load_id.nextval into v_ezid from dual;

      for gwl in get_welllogs
      loop
          ez_tools.ezmanagementpkg.movewelllog(v_ezid, pold_tlm_id, pnew_tlm_id, gwl.well_log_id, p_commit);
      end loop;

      v_detail := 'OILWARE records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

      ppdm_admin.tlm_process_logger.info('WIM.OILWARE_API: ' || v_detail);

    end tlm_id_change;

end oilware_api;
/