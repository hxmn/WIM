/**********************************************************************************************************************
 View of the number of ppdm.well_node_version records created for NAD27-generation.
 A FME job runs daily to generate NAD27 location records for Canada and US wells.

 The view is limited to the week preceding the current day.
 The counts for past days may be less than the wnv records actually created. The FME process may delete existing NAD27
   records before generating an updated location. So, it is possible that a wnv record created in the past was replaced,
   thereby skewing the count of records.
   This is okay, as the past counts are not important--they are purely informational.

 History
  20160719 cdong  QC1856  view creation

 **********************************************************************************************************************/


--drop view  wim.rpt_nad27_gen_wnv_count_vw;

create or replace view  wim.rpt_nad27_gen_wnv_count_vw
as
select d.thedate as create_date, coalesce(c.wn_count, 0) cnt
  from (select distinct trunc(row_created_on) as thedate
          from ppdm_admin.tlm_process_log
         where row_created_on > sysdate-8
       ) d
       left join
       (select trunc(row_created_date) as cr_date, count(*) as wn_count
          from ppdm.well_node_version
         where geog_coord_system_id = '4267'
              and row_created_by = 'WIM_NAD27'
              and row_created_date > trunc(sysdate-8)
         group by trunc(row_created_date)
       ) c  on d.thedate = c.cr_date
 order by d.thedate
;


grant select on  wim.rpt_nad27_gen_wnv_count_vw  to ppdm_ro;
grant select on  wim.rpt_nad27_gen_wnv_count_vw  to wim_ro;

/
