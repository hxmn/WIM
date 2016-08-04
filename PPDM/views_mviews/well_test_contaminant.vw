/*******************************************************************************************
  WELL_TEST_CONTAMINANT  (View)
   
  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_contaminant;


create or replace force view ppdm.well_test_contaminant
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   recovery_obs_no,
   contaminant_seq_no,
   active_ind,
   contaminant_type,
   effective_date,
   expiry_date,
   ppdm_guid,
   remark,
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
          recovery_obs_no,
          contaminant_seq_no,
          active_ind,
          contaminant_type,
          effective_date,
          expiry_date,
          ppdm_guid,
          remark,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL      as province_state
     from tlm_well_test_contaminant
   union all
   select wc.uwi,
          wc.source,
          wc.test_type,
          wc.run_num,
          wc.test_num,
          wc.recovery_obs_no,
          wc.contaminant_seq_no,
          wc.active_ind,
          wc.contaminant_type,
          wc.effective_date,
          wc.expiry_date,
          wc.ppdm_guid,
          wc.remark,
          wc.row_changed_by,
          wc.row_changed_date,
          wc.row_created_by,
          wc.row_created_date,
          wc.row_quality,
          --IHS extension
          wc.province_state
     from ihs_cdn_well_test_contaminant wc
   union all
   select wc.uwi,
          wc.source,
          wc.test_type,
          wc.run_num,
          wc.test_num,
          wc.recovery_obs_no,
          wc.contaminant_seq_no,
          wc.active_ind,
          wc.contaminant_type,
          wc.effective_date,
          wc.expiry_date,
          wc.ppdm_guid,
          wc.remark,
          wc.row_changed_by,
          wc.row_changed_date,
          wc.row_created_by,
          wc.row_created_date,
          wc.row_quality,
          --IHS extension
          wc.province_state
     from ihs_us_well_test_contaminant wc
;


grant select on ppdm.well_test_contaminant to ppdm_ro;


--create or replace synonym data_finder.well_test_contaminant for ppdm.well_test_contaminant;
--create or replace synonym ppdm.wtc for ppdm.well_test_contaminant;
