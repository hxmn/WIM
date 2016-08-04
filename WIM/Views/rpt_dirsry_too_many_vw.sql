/**************************************************************************************************
 Data quality checks of Directional Survey data
 Wells with "too-many" directional survey headers.

 See TIS Task 1666, QC1727,  and WIM Housekeeping wiki page for background
 http://explweb1.na.tlm.com/wiki/WIM_Housekeeping#Fixes_and_Checks

 Run in the WIM schema

 History
  20151116 cdong    QC1727  views used in WIM Housekeeping procedure

 **************************************************************************************************/

----drop view wim.rpt_dirsrvy_too_many_vw;

----return a list of wells where there are three or more active TLM-proprietary directional surveys (header)
create or replace force view wim.rpt_dirsrvy_too_many_vw
as
select ds.uwi, w.well_name, w.country, count(ds.survey_id) as cnt_srvys
  from ppdm.tlm_well_dir_srvy ds
       inner join ppdm.well w on ds.uwi = w.uwi
 where ds.active_ind = 'Y'
 group by ds.uwi, w.well_name, w.country
 having count(1) >= 3
;

--select on tlm_well_dir_srvy* with grant option required to grant select on new view to roles
grant select on wim.rpt_dirsrvy_too_many_vw to ppdm_ro;
grant select on wim.rpt_dirsrvy_too_many_vw to wim_ro;



/* ..... testing ..............

select *
  from wim.rpt_dirsrvy_too_many_vw
;

*/
