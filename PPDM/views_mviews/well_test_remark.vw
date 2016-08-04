/*******************************************************************************************
  WELL_TEST_REMARK  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_remark;

 
create or replace force view ppdm.well_test_remark
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   remark_obs_no,
   active_ind,
   effective_date,
   expiry_date,
   ppdm_guid,
   remark,
   remark_type,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state
)
as
   select uwi,
          source,
          test_type,
          run_num,
          test_num,
          remark_obs_no,
          active_ind,
          effective_date,
          expiry_date,
          ppdm_guid,
          remark,
          remark_type,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_remark
   union all
   select wtrmk.uwi,
          wtrmk.source,
          wtrmk.test_type,
          wtrmk.run_num,
          wtrmk.test_num,
          wtrmk.remark_obs_no,
          wtrmk.active_ind,
          wtrmk.effective_date,
          wtrmk.expiry_date,
          wtrmk.ppdm_guid,
          wtrmk.remark,
          wtrmk.remark_type,
          wtrmk.row_changed_by,
          wtrmk.row_changed_date,
          wtrmk.row_created_by,
          wtrmk.row_created_date,
          wtrmk.row_quality,
          --IHS extension
          wtrmk.province_state
     from ihs_cdn_well_test_remark wtrmk
   union all
   select wtrmk.uwi,
          wtrmk.source,
          wtrmk.test_type,
          wtrmk.run_num,
          wtrmk.test_num,
          wtrmk.remark_obs_no,
          wtrmk.active_ind,
          wtrmk.effective_date,
          wtrmk.expiry_date,
          wtrmk.ppdm_guid,
          wtrmk.remark,
          wtrmk.remark_type,
          wtrmk.row_changed_by,
          wtrmk.row_changed_date,
          wtrmk.row_created_by,
          wtrmk.row_created_date,
          wtrmk.row_quality,
          --IHS extension
          wtrmk.province_state
     from ihs_us_well_test_remark wtrmk
;


grant select on ppdm.well_test_remark to ppdm_ro;


--create or replace synonym data_finder.well_test_remark for ppdm.well_test_remark;
--create or replace synonym ppdm.wtrm for ppdm.well_test_remark;
