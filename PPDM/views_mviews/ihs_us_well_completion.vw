/***************************************************************************************************
 ihs_us_well_completion  (view)

 20150812   cdong       add IHS-US data to combo views, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_completion;


create or replace force view ppdm.ihs_us_well_completion
(
  uwi,
  source,
  completion_obs_no,
  active_ind,
  base_depth,
  base_depth_ouom,
  base_strat_unit_id,
  completion_date,
  completion_method,
  completion_strat_unit_id,
  completion_type,
  effective_date,
  expiry_date,
  ppdm_guid,
  remark,
  strat_name_set_id,
  top_depth,
  top_depth_ouom,
  top_strat_unit_id,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  x_perf_status,
  x_perf_shots,
  province_state,
  top_strat_age,
  base_strat_age
)
as
  select /*+ use_nl(wc wv) */
         wv.uwi,
         wv.source,
         wc.completion_obs_no,
         wc.active_ind,
         wc.base_depth * .3048 as base_depth,
         'FT' as base_depth_ouom,
         wc.base_strat_unit_id,
         wc.completion_date,
         wc.completion_method,
         wc.completion_strat_unit_id,
         wc.completion_type,
         wc.effective_date,
         wc.expiry_date,
         wc.ppdm_guid,
         wc.remark,
         wc.strat_name_set_id,
         wc.top_depth * .3048 as top_depth,
         'FT' as top_depth_ouom,
         wc.top_strat_unit_id,
         wc.row_changed_by,
         wc.row_changed_date,
         wc.row_created_by,
         wc.row_created_date,
         wc.row_quality,
         wc.x_perf_status,
         wc.x_perf_shots,
         wc.province_state,
         wc.top_strat_age,
         wc.base_strat_age
    from well_completion@c_talisman_us_ihsdataq wc, ppdm.well_version wv
   where     wv.well_num = wc.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_completion to ppdm_ro;
