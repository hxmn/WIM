-- PPDM schema
grant select, update, insert, delete on ppdm.rm_info_item_content to wim;
grant select, update, insert, delete on ppdm.rm_data_store to wim;

-- WIM schema
drop synonym datman_api;



/*
    Script: datman_api

    Purpose:   
        Reassign items in the RM_* tables to a new TLM Well ID.

    Dependencies
        ppdm.rm_info_item_content table
        pppdm.rm_data_store table

    History:
        0.1 15-Jan-11   S.Makarov   Initial version
        0.2 16-Jan-12   V.Rajpoot   Added Detail logs (counts) to the TLM_Process_Log
        1.0 25-Mar-13   V.Rajpoot   Moved package from SDP Schema to WIM schema.
									Renamed from Inquest_API to DATMAN_API 
		2.0 09-Sep-15   K. Edward   Remove tlm_id_can_change function
*/
create or replace package datman_api
as
    /*
        @name   tlm_id_change
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @param  pold_tlm_id - the id of the well_version that is to be moved
        @logs               - logs to process log
    */
    procedure tlm_id_change (pold_tlm_id in varchar2, pnew_tlm_id in varchar2);
end datman_api;
/

create or replace package body datman_api 
is
	procedure tlm_id_change (
        pold_tlm_id	in	varchar2,
        pnew_tlm_id in  varchar2
    )
	is
		v_detail varchar2(2000);
    begin
		--  Note: Ignore the Oilware items (OWI-DBLOAD)
		update ppdm.rm_info_item_content
        set rm_info_item_content.uwi = pnew_tlm_id
		where rm_info_item_content.uwi = pold_tlm_id
			and (
				rm_info_item_content.source != 'OWI-DBLOAD'
				or rm_info_item_content.source is null
			);
 
		v_detail :=  ', ' || chr(10) ||  SQL%ROWCOUNT || ' RM_INFO_ITEM_CONTENT records moved.';
  
		update ppdm.rm_data_store 
        set rm_data_store.name = pnew_tlm_id,
			rm_data_store.long_location = pnew_tlm_id
		where rm_data_store.name = pold_tlm_id;
       
        v_detail := v_detail || ', ' || chr(10) ||  SQL%ROWCOUNT || ' RM_DATA_STORE records moved.';
    
		ppdm_admin.tlm_process_logger.info('WIM.DATMAN_API: Records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id || v_detail);
    end tlm_id_change; 
end datman_api;