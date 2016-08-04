-- PPDM schema
grant select, insert, update, delete on ppdm.well_area to wim;

-- WIM schema
drop synonym well_area_api;

/*
    Script: well_area_api

    Purpose:   
        Reassign items in the WELL_AREA table to a new TLM Well ID.

    Dependencies
        ppdm.well_area

    History:
        0.1 10-Jan-12   V.Rajpoot   Initial version
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change
*/
create or replace package well_area_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end well_area_api;
/

create or replace package body well_area_api
is
    procedure tlm_id_change(pold_tlm_id in varchar2, pnew_tlm_id in varchar2)
    is
        v_detail    varchar2(2000);
    begin
        update ppdm.well_area
        set uwi = pnew_tlm_id
        where uwi = pold_tlm_id;
       
        v_detail := ', ' || chr(10) || SQL%ROWCOUNT || ' WELL_AREA records moved.';
        
        ppdm_admin.tlm_process_logger.info('WIM.WELL_AREA_API: Well records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id ||  v_detail);
   end tlm_id_change;
end well_area_api;
/