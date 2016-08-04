
-- GPDR schema
grant select, insert, update, delete on gpdr.sample_component to wim;
grant select on gpdr.seq_sample_sample_id to wim;


-- WIM schema
drop synonym geochem_api;


/*
    Script: geochem_api

    Purpose:   
        Reassign items in the SAMPLE_COMPONENT tables to a new TLM Well ID

    Dependencies
        gpdr.sample_component
        
    History:
        0.1 15-Jan-11   S.Makarov   Initial version
        1.0 09-Sep-15   K. Edward   Remove tlm_id_can_change function
									Moved to WIM schema
*/
create or replace package geochem_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end geochem_api;
/

create or replace package body geochem_api 
is
	procedure tlm_id_change (
        pold_tlm_id	in	varchar2,
        pnew_tlm_id in  varchar2
    )
	is
		v_detail varchar2(2000);
    begin
		update gpdr.sample_component
        set uwi = pnew_tlm_id
		where uwi = pold_tlm_id
			and component_type = 'WELL';
		
		v_detail :=  ', ' || chr(10) ||  SQL%ROWCOUNT || ' GPDR.SAMPLE_COMPONENT records moved.';
  
		ppdm_admin.tlm_process_logger.info('WIM.GEOCHEM_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id || v_detail);
    end tlm_id_change; 
end geochem_api;
/

