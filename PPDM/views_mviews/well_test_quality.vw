/*******************************************************************************************
  WELL_TEST_QUALITY  (View)

  20150818  cdong   include IHS US data (tis task 1164)

 *******************************************************************************************/

--drop view ppdm.well_test_quality;

 
create or replace force view ppdm.well_test_quality
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   quality_obs_no,
   test_result_code,
   quality_misrun_code,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   province_state,
   active_ind
)
as
   select uwi,
          source,
          test_type,
          run_num,
          test_num,
          quality_obs_no,
          test_result_code,
          quality_misrun_code,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          province_state,
          active_ind
     from tlm_well_test_quality
   union all
   select wtq.uwi,
          wtq.source,
          wtq.test_type,
          wtq.run_num,
          wtq.test_num,
          wtq.quality_obs_no,
          wtq.test_result_code,
          wtq.quality_misrun_code,
          wtq.row_changed_by,
          wtq.row_changed_date,
          wtq.row_created_by,
          wtq.row_created_date,
          wtq.province_state,
          wtq.active_ind
     from ihs_cdn_well_test_quality wtq
   union all
   select wtq.uwi,
          wtq.source,
          wtq.test_type,
          wtq.run_num,
          wtq.test_num,
          wtq.quality_obs_no,
          wtq.test_result_code,
          wtq.quality_misrun_code,
          wtq.row_changed_by,
          wtq.row_changed_date,
          wtq.row_created_by,
          wtq.row_created_date,
          wtq.province_state,
          wtq.active_ind
     from ihs_us_well_test_quality wtq
;


grant select on ppdm.well_test_quality to ppdm_ro;

--create or replace synonym data_finder.well_test_quality for ppdm.well_test_quality;
--create or replace synonym ppdm.wtq for well_test_quality;
