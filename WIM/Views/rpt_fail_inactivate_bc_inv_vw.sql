/**********************************************************************************************************************
 View used to identify the failed well version inactivations for the 15 days.
 The inner join to well_version will limit the result-set to any versions that still haven't been inactivated.
 The inner join to well is used to get the composite country/province-state and name information, in case there are other active versions.
 Use 15 days to allow support/data-steward time to (hopefully) address/resolve the inventory.

 Note: this view is DEPENDENT on the hard-coded error code produced by the gateway/loaders.
    So, if the error message is ever changed, this view may stop working.

 Usage:
 This view will be used by the WIM Housekeeping procedure to track the number of wells with this particular condition.
 Additionaly, a summary of the data may be included in a BIRT report.

 Run this script in the WIM schema.

 History
  20160322  cdong   QC1740 identify wells with failed well-version inactivations

 **********************************************************************************************************************/

--revoke select on rpt_fail_inactivate_bc_inv_vw  from wim_ro ;
--delete view rpt_fail_inactivate_bc_inv_vw ;

create or replace force view wim.rpt_fail_inactivate_bc_inv_vw
as
select distinct wal.tlm_id
       , wal.source
       , w.well_name
       , w.ipl_uwi_local
       , w.country
       , w.province_state
  from wim.wim_audit_log wal
       inner join ppdm.well_version wv
                    on wal.tlm_id = wv.uwi
                       and wal.source = wv.source
                       and wv.active_ind = 'Y'
       inner join ppdm.well w on wal.tlm_id = w.uwi
 where wal.row_created_date > sysdate - 15
       and upper(wal.text) = 'WELL CANNOT BE DELETED/INACTIVATED. THERE IS INVENTORY ASSOCIATED WITH THIS WELL.'
 order by source, tlm_id
;


grant select on wim.rpt_fail_inactivate_bc_inv_vw  to wim_ro ;

--select * from rpt_fail_inactivate_bc_inv_vw ;



/*---- alternate query, to include an inventory count and/or DM document information
  ---- mainly, this would be a query to run during analysis of what is preventing the inactivation
select t.tlm_id, t.source, t.well_name, t.ipl_uwi_local, t.country, t.province_state
       ----count of local inventory
       --, well_inventory.get_inventory_count(t.tlm_id, 'ALL', 'Y') as local_inv_cnt
       ----DM document information
       --, dm.docnumber, dm.docname, dm.last_edit_date, dm.user_id
  from (----using sub-select to reduce the number of times get-inventory-count is called
        select distinct wal.tlm_id, wal.source, w.well_name, w.ipl_uwi_local, w.country, w.province_state
          from wim.wim_audit_log wal
               inner join ppdm.well w on wal.tlm_id = w.uwi
               inner join ppdm.well_version wv on wal.tlm_id = wv.uwi and wv.active_ind = 'Y'
         where wal.row_created_date > sysdate - 7
               and upper(wal.text) like 'WELL CANNOT BE DELETED/INACTIVATED. THERE IS INVENTORY ASSOCIATED WITH THIS WELL.'
         order by source, tlm_id
       ) t
       --left join well_inventory.dm_well_docs_vw dm on t.tlm_id = dm.tlm_well_id
 order by source
          --, local_inv_cnt desc
          , tlm_id
          --, dm.docnumber
;

*/
