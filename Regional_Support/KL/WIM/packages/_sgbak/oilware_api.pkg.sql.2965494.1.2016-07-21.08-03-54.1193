-- PPDM schema
grant select on ppdm.well_log to wim;

-- EZ_TOOLS schema
grant select on ez_load_id to wim;
grant execute on ezmanagementpkg to wim;

-- WIM schema
drop synonym oilware_api;

/*
    Script: oilware_api

    Purpose:   
        Reassign logs in the well log tables to a new TLM Well ID.

    Dependencies
        ppdm.well_log table
        ez_tools.ez_load_id sequence
        ez_tools.ezmanagementpkg package

    History:
        0.1 10-Jan-12   V.Rajpoot   Initial version
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change
*/
create or replace package oilware_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end oilware_api;
/

create or replace package body oilware_api
is
    procedure tlm_id_change(pold_tlm_id in varchar2, pnew_tlm_id in varchar2)
    is
        cursor get_welllogs
        is
            select well_log_id
            from ppdm.well_log
            where uwi = pold_tlm_id
        ; 
            
        v_gwl       get_welllogs%rowtype;
        v_ezid      integer;
        p_commit    varchar2(20) := 'YES';
        v_detail    varchar2(2000);
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