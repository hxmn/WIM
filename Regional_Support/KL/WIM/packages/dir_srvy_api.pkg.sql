-- PPDM schema
grant update on  ppdm.tlm_well_dir_srvy_station to wim;
grant update on  ppdm.tlm_well_dir_srvy to wim;


-- WIM
drop synonym dir_srvy_api;

/*
    Script: dir_srvy_api

    Purpose:   
        Reassign items in the TLM_WELL_DIR_SRVY_* tables to a new TLM Well ID.

    Dependencies
        ppdm.tlm_well_dir_srvy table
        ppdm.tlm_well_dir_srvy_station table

    History:
        0.1 15-Jan-11   S.Makarov   Initial version
        0.2 16-Jan-12   V.Rajpoot   Added Detail logs (counts) to the TLM_Process_Log
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change
*/
create or replace package dir_srvy_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end dir_srvy_api;
/

-- ppdm user
-- grant update on ppdm.tlm_well_dir_srvy_station to wim;
-- grant update on ppdm.tlm_well_dir_srvy to wim;

create or replace package body dir_srvy_api
is
    procedure tlm_id_change(pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
    is
        v_detail varchar2(2000);
    begin
        update ppdm.tlm_well_dir_srvy_station
        set uwi = pnew_tlm_id
        where uwi = pold_tlm_id;
        
        v_detail :=  ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_DIR_SRVY_STATION records moved';
        
        update ppdm.tlm_well_dir_srvy
        set uwi = pnew_tlm_id
        WHERE uwi = pold_tlm_id;
    
        v_detail := v_detail || ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_DIR_SRVY records moved.';
  
        ppdm_admin.tlm_process_logger.info('WIM.DIR_SRVY_API: Well records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id || v_detail);
    end tlm_id_change;
end dir_srvy_api;
/