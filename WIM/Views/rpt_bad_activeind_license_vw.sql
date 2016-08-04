/**********************************************************************************************************************
 Queries to identify active well node-version/license/status records where the associated well version record is active.
 This is a data-quality issue.
 Via DataFinder, a user would be mislead into believing the license is valid, when in-fact is should be inactivated.

 Usage:
 This view will be used by the WIM Housekeeping procedure to identify affected records and correct the active-indicator.

 Run this script in the WIM schema.

 History
  20160321  cdong   QC1783 script creation

 **********************************************************************************************************************/

--revoke select on wim.rpt_bad_activeind_license_vw    from wim_ro ;
--drop view rpt_bad_activeind_license_vw ;

create or replace force view wim.rpt_bad_activeind_license_vw
as
select wl.uwi
       , w.well_name
       , w.ipl_uwi_local
       , w.country
       , w.province_state
       , wl.source
       , wl.license_num
       --, wl.expiry_date
       --, wl.active_ind, wv.active_ind, wl.row_changed_by, wl.row_changed_date, wl.row_created_by, wl.row_created_date
  from ppdm.well_license wl
       inner join ppdm.well_version wv 
                    on wl.uwi = wv.uwi 
                       and wl.source = wv.source 
                       and wl.active_ind <> wv.active_ind
       left join ppdm.well w on wl.uwi = w.uwi
 where wv.active_ind = 'N'
 order by w.country, w.province_state, wl.uwi
;


grant select on wim.rpt_bad_activeind_license_vw  to wim_ro ;

--select * from rpt_bad_activeind_license_vw ;
