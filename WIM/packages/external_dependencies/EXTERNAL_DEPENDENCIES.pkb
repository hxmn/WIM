CREATE OR REPLACE PACKAGE BODY WIM.external_dependencies
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Invoke the appropriate API's (packages) to move dependent/associated well-data
  from one well to another. Basically, update the well-id in the associated records.

  Procedure does NOT COMMIT the change to allow caller to apply as part of wider transaction.

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   Typically, this is invoked by WIM.WIM_WELL_ACTION.WELL_MOVE, when the last active well version is moved
     pfrom_tlm_id - tlm_id of the well_version to be moved
     pfrom_source - source of the well_version to be moved
     pto_tlm_id   - tlm_id of the receiving well
     puserapi     - the user issuing the move request

 HISTORY:
   0.1    xx-xxx-xxx  -unknown- Initial version
          2015-11-05  kxedward  QC555/QC1480 - update External Dependencies and related move API's


 --------------------------------------------------------------------------------------------------------------------*/

  type array_api is varray(11) of varchar2(50);
  v_api array_api := array_api(
      'datman_api',
      'dir_srvy_api',
      'geochem_api',
      'pden_vol_api',
      'strat_api',
      'well_area_api',
      'well_completions_api',
      'well_core_api',
      'well_test_api',
      'seismic_api',
      'oilware_api'
    );

  /*----------------------------------------------------------------------------------------------
      Procedure:  move_well_data
      Detail:     This Procedure dynamically calls external APIs to move data to the new TLM_ID.
                  Catches and logs error to process_log
                  Rethows original exceptions to be handled by the caller
  -----------------------------------------------------------------------------------------------*/
  procedure well_move (
    pfrom_tlm_id    in  ppdm.well_version.uwi%type,
    pfrom_source    in  ppdm.well_version.source%type,
    pto_tlm_id      in  ppdm.well_version.uwi%type,
    puser           in  ppdm.well_version.row_created_by%type default user
  ) 
  is
    v_sql   varchar2(2000);
    v_msg   varchar2(2000);
  begin
    for i in v_api.first .. v_api.last
    loop
        v_msg := v_api(i) || ' data can not be moved from uwi:' || pfrom_tlm_id || ' to uwi: ' || pto_tlm_id;
        v_sql := 'begin wim.' || v_api(i) || '.tlm_id_change(:pfrom_tlm_id , :pto_tlm_id ); end;';
        execute immediate v_sql using pfrom_tlm_id, pto_tlm_id;
    end loop;
  exception
    when others then
         ppdm_admin.tlm_process_logger.error(' EXTERNAL_DEPENDENCIES: ' || v_msg);
         raise;
  end well_move;

end external_dependencies;
/