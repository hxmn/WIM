-- PPDM schema
grant update on ppdm.tlm_strat_well_section to wim;

-- WIM schema
drop synonym strat_api;


/*
    Script: strat_api

    Purpose:   
        Reassign items in the TLM_STRAT_*  tables to a new TLM Well ID.

    Dependencies
        ppdm.tlm_strat_well_section table

    History:
        0.1 10-Jan-12   V.Rajpoot   Initial version
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change
*/
create or replace package strat_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end strat_api;
/

create or replace package body strat_api
is
    procedure tlm_id_change(pold_tlm_id in varchar2, pnew_tlm_id in varchar2)
    is
        v_detail    varchar2(2000);
    begin
        update ppdm.tlm_strat_well_section
        set uwi = pnew_tlm_id
        where uwi = pold_tlm_id;
       
        v_detail := ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_STRAT_WELL_SECTION records moved.';
        
        ppdm_admin.tlm_process_logger.info('WIM.STRAT_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id ||  v_detail);
   end tlm_id_change;
end strat_api;
/