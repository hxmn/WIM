/*
    Script: wim.external_dependencies
    
    Purpose:
        Incapsulate calls from gateway to external API's that contain data for a composite well.
    
    Exceptions:
        Catches and logs error to process_log
        Rethows original exceptions to be handled by the caller
        
    History:
        0.1     15-JAN-11   S.MAKAROV   initial version
        0.2     03-AUG-11   V.RAJPOOT   added a call to geochem-api,(commented out, because if required table is not in prod)
                                        added a call to well_area_api
        0.3     17-JAN-12   V.RAJPOOT   added to call to pden_vol_api, well_core_api, well_completions_api,strat_api
        0.4     14-AUG-12   V.RAJPOOT   moved all apis from gpdr/ppdm_admin/ez_tools schemas to wim schema.
                                        removed pstatus parameter (out number) from well_move proceudure, it is not being used anywhere.        
        0.5     25-MAR-13   V.RAJPOOT   renamed inquest_api to datman_api 
        1.0     27-AUG-15   K.EDWARDS   removed can move well function
                                        procedure renamed to move_well_data
*/
create or replace package external_dependencies
is
    /*
        pfrom_tlm_id - tlm_id of the well_version to be moved
        pfrom_source - source of the well_version to be moved
        pto_tlm_id   - tlm_id of the receiving well 
        puserapi     - the user issuing the move request
    */
    procedure move_well_data (
        pfrom_tlm_id    in  ppdm.well_version.uwi%type,
        pfrom_source    in  ppdm.well_version.source%type,
        pto_tlm_id      in  ppdm.well_version.uwi%type,
        puser           in  ppdm.well_version.row_created_by%type default user
    );
end;
/

create or replace package body external_dependencies
is
    type array_api is varray(10) of varchar2(50);
    v_api array_api := array_api(
        'datman_api',
        'dir_srvy_api',
        'geochem_api',
        'pden_vol_api',
        'oilware_api',
        'strat_api',
        'well_area_api',
        'well_completions_api',
        'well_core_api',
        'well_test_api'
    );

    /*
        Procedure:  move_well_data
        Detail:     This Procedure dynamically calls external APIs to move data to the new TLM_ID.
                    Catches and logs error to process_log
                    Rethrows original exceptions to be handled by the caller
    */
    procedure move_well_data (
        pfrom_tlm_id    in  ppdm.well_version.uwi%type,
        pfrom_source    in  ppdm.well_version.source%type,
        pto_tlm_id      in  ppdm.well_version.uwi%type,
        puser           in  ppdm.well_version.row_created_by%type default user
    ) is
        v_sql   varchar2(2000);
        v_msg   varchar2(2000);
    begin  
        for i in v_api.first .. v_api.last
        loop
            v_msg := v_api(i) || ' data can not be moved from uwi:' || pfrom_tlm_id || ' to uwi: ' || pto_tlm_id;
            v_sql := 'begin wim.' || v_api(i) || '.tlm_id_change(:pfrom_tlm_id , :pto_tlm_id ); end;';
            execute immediate v_sql using pfrom_tlm_id, pto_tlm_id;
        end loop;
        
        --20150218 cdong AP PDMS  write well move to new tracking table
        insert into wim.tlm_well_move(to_uwi, from_uwi, original_move_date)
        values(pto_tlm_id, pfrom_tlm_id, sysdate);
    exception
        when others then
            ppdm_admin.tlm_process_logger.error('** FAILURE in wim.external_dependencies : ' || sqlerrm);
            rollback;
            raise;
    end move_well_data;
end external_dependencies;
/