/**********************************************************************************************************************
 Queries to identify active well node-version/license/status records where the associated well version record is active.
 This is a data-quality issue.

 Usage:
 This view will be used by the WIM Housekeeping procedure to identify affected records and correct the active-indicator.

 Run this script in the WIM schema.

 History
  20160321  cdong   QC1783 script creation

 **********************************************************************************************************************/

--revoke select on wim.rpt_bad_activeind_status_vw    from wim_ro ;
--drop view rpt_bad_activeind_status_vw ;

create or replace force view wim.rpt_bad_activeind_status_vw
as
select ws.uwi
       , w.well_name
       , w.ipl_uwi_local
       , w.country
       , w.province_state
       , ws.source
       , ws.status
       , ws.status_type
  from ppdm.well_status ws
       inner join ppdm.well_version wv 
                    on ws.uwi = wv.uwi 
                       and ws.source = wv.source 
                       and ws.active_ind <> wv.active_ind
       left join ppdm.well w on ws.uwi = w.uwi
 where wv.active_ind = 'N'
 order by w.country, w.province_state, ws.uwi
;


grant select on wim.rpt_bad_activeind_status_vw    to wim_ro ;

--select * from wim.rpt_bad_activeind_status_vw ; 
