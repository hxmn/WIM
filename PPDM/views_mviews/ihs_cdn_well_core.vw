/***************************************************************************************************
 ihs_cdn_well_core  (view)

 20150813 copied from ihs_well_core, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_core;


create or replace force view ppdm.ihs_cdn_well_core
(
   uwi,
   source,
   core_id,
   active_ind,
   analysis_report,
   base_depth,
   base_depth_ouom,
   contractor,
   core_barrel_size,
   core_barrel_size_ouom,
   core_diameter,
   core_diameter_ouom,
   core_handling_type,
   core_oriented_ind,
   core_show_type,
   core_type,
   coring_fluid,
   digit_avail_ind,
   effective_date,
   expiry_date,
   gamma_correlation_ind,
   operation_seq_no,
   ppdm_guid,
   primary_core_strat_unit_id,
   recovered_amount,
   recovered_amount_ouom,
   recovered_amount_uom,
   recovery_date,
   remark,
   reported_core_num,
   run_num,
   shot_recovered_count,
   sidewall_ind,
   strat_name_set_id,
   top_depth,
   top_depth_ouom,
   total_shot_count,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   x_top_strat_unit_id,
   x_base_strat_unit_id,
   province_state,
   top_strat_age,
   base_strat_age,
   primary_strat_age
)
as
   select /*+ use_nl(wc wv) */
          wv.uwi,
          wv.source,
          wc.core_id,
          wc.active_ind,
          wc.analysis_report,
          wc.base_depth,
          wc.base_depth_ouom,
          wc.contractor,
          wc.core_barrel_size,
          wc.core_barrel_size_ouom,
          wc.core_diameter,
          wc.core_diameter_ouom,
          wc.core_handling_type,
          wc.core_oriented_ind,
          wc.core_show_type,
          wc.core_type,
          wc.coring_fluid,
          wc.digit_avail_ind,
          wc.effective_date,
          wc.expiry_date,
          wc.gamma_correlation_ind,
          wc.operation_seq_no,
          wc.ppdm_guid,
          wc.primary_core_strat_unit_id,
          wc.recovered_amount,
          wc.recovered_amount_ouom,
          wc.recovered_amount_uom,
          wc.recovery_date,
          wc.remark,
          wc.reported_core_num,
          wc.run_num,
          wc.shot_recovered_count,
          wc.sidewall_ind,
          wc.strat_name_set_id,
          wc.top_depth,
          wc.top_depth_ouom,
          wc.total_shot_count,
          wc.row_changed_by,
          wc.row_changed_date,
          wc.row_created_by,
          wc.row_created_date,
          wc.row_quality,
          wc.x_top_strat_unit_id,
          wc.x_base_strat_unit_id,
          wc.province_state,
          wc.top_strat_age,
          wc.base_strat_age,
          wc.primary_strat_age
     from well_core@c_talisman_ihsdata wc, ppdm.well_version wv
    where     wv.ipl_uwi_local = wc.uwi
          and wv.source = '300IPL'
          and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_core to ppdm_ro;

