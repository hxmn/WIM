-- PPDM schema
grant update on ppdm.tlm_well_completion to wim;

-- WIM schema
drop synonym well_completions_api;

/*
    Script: well_completions_api

    Purpose:   
        Reassign items in the TLM_WELL_COMPLETIONS table to a new TLM Well ID.

    Dependencies
        ppdm.tlm_well_completions

    History:
        0.1 10-Jan-12   V.Rajpoot   Initial version
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change
*/
create or replace package well_completions_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end well_completions_api;
/

  
create or replace package body well_completions_api
is
    procedure tlm_id_change(pold_tlm_id in varchar2, pnew_tlm_id in varchar2)
    is
        v_detail    varchar2(2000);
    begin
        update ppdm.tlm_well_completion
        set uwi = pnew_tlm_id
        where uwi = pold_tlm_id;

        v_detail := ', ' || CHR(10) || SQL%ROWCOUNT || ' TLM_WELL_COMPLETION records moved.';
        
        ppdm_admin.tlm_process_logger.info('WIM.WELL_COMPLETIONS_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: ' || pnew_tlm_id ||  v_detail);
   end tlm_id_change;
end well_completions_api;
/