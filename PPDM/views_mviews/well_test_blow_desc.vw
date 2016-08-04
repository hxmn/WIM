/*******************************************************************************************
  WELL_TEST_BLOW_DESC  (View)

  20150818  cdong   include IHS US data (tis task 1164)

 *******************************************************************************************/

--drop view ppdm.well_test_blow_desc;

 
create or replace force view ppdm.well_test_blow_desc
(
   uwi,
   source,
   test_type,
   test_num,
   blow_obs_num,
   blow_description,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state,
   run_num,
   active_ind
)
as
   select uwi,
          source,
          test_type,
          test_num,
          blow_obs_num,
          blow_description,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          province_state,
          run_num,
          active_ind
     from tlm_well_test_blow_desc
   union all
   select uwi,
          source,
          test_type,
          test_num,
          blow_obs_num,
          blow_description,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          province_state,
          run_num,
          active_ind
     from ihs_cdn_well_test_blow_desc
   union all
   select uwi,
          source,
          test_type,
          test_num,
          blow_obs_num,
          blow_description,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          province_state,
          run_num,
          active_ind
     from ihs_us_well_test_blow_desc
;


grant select on ppdm.well_test_blow_desc to ppdm_ro;


--create or replace synonym data_finder.well_test_blow_desc for ppdm.well_test_blow_desc;
--create or replace synonym ppdm.wtbd for ppdm.well_test_blow_desc;
