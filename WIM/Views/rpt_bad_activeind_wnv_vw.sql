/**********************************************************************************************************************
 View to identify active well node-version/license/status records where the associated well version record is active.
 This is a data-quality issue.

 Usage:
 This view will be used by the WIM Housekeeping procedure to identify affected records and correct the active-indicator.

 Run this script in the WIM schema.

 History
  20160321  cdong   QC1783 script creation

 **********************************************************************************************************************/

--revoke select on wim.rpt_bad_activeind_wnv_vw    from wim_ro ;
--drop view rpt_bad_activeind_wnv_vw ;

create or replace force view wim.rpt_bad_activeind_wnv_vw
as
select wnv.ipl_uwi as uwi
       , w.well_name
       , w.ipl_uwi_local
       , w.country
       , w.province_state
       , wnv.source
       , wnv.node_id
       , wnv.node_obs_no
  from ppdm.well_node_version wnv
       inner join ppdm.well_version wv 
                    on wnv.ipl_uwi = wv.uwi 
                       and wnv.source = wv.source 
                       and wnv.active_ind <> wv.active_ind
       left join ppdm.well w on wnv.ipl_uwi = w.uwi
 where wv.active_ind = 'N'
 order by w.country, w.province_state, wnv.ipl_uwi

;


grant select on wim.rpt_bad_activeind_wnv_vw    to wim_ro ;

--select * from wim.rpt_bad_activeind_wnv_vw ;
