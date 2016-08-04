-- WIM schema
drop synonym seismic_api;


/*
    Script: seismic_api

    Purpose:   
        Implement changes required when moving all attachements on well pold_tlm_id
		to well pnew_tlm_id, typically in preparation for deleting pold_tlm_id.

		Forwards the request to GEOLOGIC_API.TLM_ID_CHANGE@SEISMIC_DATA_MGMT.

    Dependencies
        wim.seismic_data_mgmt           db link
		geologic_api@seismic_data_mgmt  package at target of above db link
        
    History:
        1.0    2015-08-27  RPeters    Initial version
		1.1    2015-10-14  RPeters    Update counts in DATA_ACCESS_COAT_CHECK.WELL_INVENTORY
		1.2    2015-10-30  RPeters    Comment out 1.1 (done by trigger in seismic DB)
		1.3	   2016-06-06  Kxedward	  	
*/
create or replace package seismic_api
is
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end seismic_api;
/

create or replace package body seismic_api 
is
	procedure tlm_id_change (
        pold_tlm_id	in	varchar2,
        pnew_tlm_id in  varchar2
    )
	is
		v_detail varchar2(2000);
    begin
		geologic_api.tlm_id_change@seismic_data_mgmt(pold_tlm_id, pnew_tlm_id);
		v_detail := chr(10) || 'Successfully updated seismic database.';
  
		ppdm_admin.tlm_process_logger.info('WIM.SEISMIC_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id || v_detail);
    end tlm_id_change; 
end s_api;
/

