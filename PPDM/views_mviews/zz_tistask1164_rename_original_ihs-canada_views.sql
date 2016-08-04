/*******************************************************************************
 TIS Task 1164  Add IHS US data to combo views
 
 Run this script AFTER
  - create new IHS Canada views
  - create new IHS US views
  - update existing combo view to include new IHS US view
 
 This script will rename the original IHS (canada) views, instead of dropping them.
 This is "safer" in the short term.  Once everything is tested, then can drop views.

 20150817 cdong   script creation

 *******************************************************************************/

rename  ihs_pden_vol_by_month       to  ihs_x_pden_vol_by_month ;

rename  ihs_well_completion         to  ihs_x_well_completion ;

rename  ihs_well_core               to  ihs_x_well_core ;
rename  ihs_well_core_sample_anal   to  ihs_x_well_core_sample_anal ;
rename  ihs_well_core_sample_desc   to  ihs_x_well_core_sample_desc ;

rename  ihs_strat_name_set          to  ihs_x_strat_name_set ;
rename  ihs_strat_unit              to  ihs_x_strat_unit ; 
rename  ihs_strat_well_section      to  ihs_x_strat_well_section ;

rename  ihs_r_test_subtype          to  ihs_x_r_test_subtype ;
rename  ihs_r_well_test_type        to  ihs_x_r_well_test_type ;
rename  ihs_well_test               to  ihs_x_well_test ;
rename  ihs_well_test_analysis      to  ihs_x_well_test_analysis ;
rename  ihs_well_test_blow_desc     to  ihs_x_well_test_blow_desc ;
rename  ihs_well_test_contaminant   to  ihs_x_well_test_contaminant ;
rename  ihs_well_test_cushion       to  ihs_x_well_test_cushion ;
rename  ihs_well_test_equipment     to  ihs_x_well_test_equipment ;
rename  ihs_well_test_flow          to  ihs_x_well_test_flow ;
rename  ihs_well_test_flow_meas     to  ihs_x_well_test_flow_meas ;
rename  ihs_well_test_mud           to  ihs_x_well_test_mud ;
rename  ihs_well_test_period        to  ihs_x_well_test_period ;
rename  ihs_well_test_press_meas    to  ihs_x_well_test_press_meas ;
rename  ihs_well_test_pressure      to  ihs_x_well_test_pressure ;
rename  ihs_well_test_quality       to  ihs_x_well_test_quality ;
rename  ihs_well_test_recorder      to  ihs_x_well_test_recorder ;
rename  ihs_well_test_recovery      to  ihs_x_well_test_recovery ;
rename  ihs_well_test_remark        to  ihs_x_well_test_remark ;
rename  ihs_well_test_slope         to  ihs_x_well_test_slope ;
