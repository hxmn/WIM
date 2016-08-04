/**************************************************************************************************
 Data quality checks of Directional Survey data
 Dir srvys with duplicate/repeated measured depths.

 See TIS Task 1666, QC1727,  and WIM Housekeeping wiki page for background
 http://explweb1.na.tlm.com/wiki/WIM_Housekeeping#Fixes_and_Checks

 Run in the WIM schema

 History
  20151116 cdong    QC1727  views used in WIM Housekeeping procedure

 **************************************************************************************************/

----drop view wim.rpt_dirsrvy_dupe_md_vw

create or replace force view wim.rpt_dirsrvy_dupe_md_vw
as
select uwi, survey_id, station_md
       , listagg(depth_obs_no, ', ') within group (order by uwi, survey_id, station_md, depth_obs_no) as stations
       , well_name, country, row_created_by, row_created_date
  from (
            select dss.uwi, dss.survey_id, dss.depth_obs_no, dss.station_md, dss.row_created_by, dss.row_created_date
                   , w.well_name, w.country, w.province_state
              from ppdm.tlm_well_dir_srvy_station dss
                   inner join (----return list of dir srvy station_md that is duplicated
                                select uwi, survey_id, station_md
                                  from ppdm.tlm_well_dir_srvy_station
                                 ----date afterwhich GeoWiz was enhanced to allow more than two decimal places
                                 ----  by default, 2 decimal places could lead to dupes due to rounding after unit conversion (ft to meters)
                                 where row_created_date > to_date('2015-08-26', 'yyyy-mm-dd')
                                 group by uwi, survey_id, station_md
                                 having count(1) > 1
                              ) t  on dss.uwi = t.uwi and dss.survey_id = t.survey_id and dss.station_md = t.station_md
                   left join ppdm.well w on dss.uwi = w.uwi
       )
 group by uwi, survey_id, station_md, well_name, country, row_created_by, row_created_date
 order by uwi, survey_id, station_md
;

--select on tlm_well_dir_srvy with grant option required to grant select on new view to roles
grant select on wim.rpt_dirsrvy_dupe_md_vw  to ppdm_ro;
grant select on wim.rpt_dirsrvy_dupe_md_vw  to wim_ro;



/* ..... testing ..............

select *
  from wim.rpt_dirsrvy_dupe_md_vw
;

*/
