/*******************************************************************************************
  WELL_COMPLETION  (View)

  20150817  cdong   include IHS US data (tis task 1164)
 
 *******************************************************************************************/

--drop view PPDM.WELL_COMPLETION;


create or replace force view ppdm.well_completion
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
   top_strat_age,
   base_strat_age,
   province_state,
   x_perf_shots,
   x_perf_status,
   tlm_perforation_per_uom
)
as
   select twc.uwi,
          twc.source,
          twc.completion_obs_no,
          twc.active_ind,
          twc.base_depth,
          twc.base_depth_ouom,
          twc.base_strat_unit_id,
          twc.completion_date,
          twc.completion_method,
          twc.completion_strat_unit_id,
          twc.completion_type,
          twc.effective_date,
          twc.expiry_date,
          twc.ppdm_guid,
          twc.remark,
          twc.strat_name_set_id,
          twc.top_depth,
          twc.top_depth_ouom,
          twc.top_strat_unit_id,
          twc.row_changed_by,
          twc.row_changed_date,
          twc.row_created_by,
          twc.row_created_date,
          twc.row_quality,
          --  Extensions - Initially all NULL, but once we start to load the data may need to join this to other tables
          null as top_strat_age,
          null as base_strat_age,
          null as province_state,
          null as x_perf_shots,
          null as x_perf_status,
          null as tlm_perforation_per_uom
     from ppdm.tlm_well_completion twc
   union all
   select iwc.uwi,
          iwc.source,
          iwc.completion_obs_no,
          iwc.active_ind,
          iwc.base_depth,
          iwc.base_depth_ouom,
          iwc.base_strat_unit_id,
          iwc.completion_date,
          iwc.completion_method,
          iwc.completion_strat_unit_id,
          iwc.completion_type,
          iwc.effective_date,
          iwc.expiry_date,
          iwc.ppdm_guid,
          iwc.remark,
          iwc.strat_name_set_id,
          iwc.top_depth,
          iwc.top_depth_ouom,
          iwc.top_strat_unit_id,
          iwc.row_changed_by,
          iwc.row_changed_date,
          iwc.row_created_by,
          iwc.row_created_date,
          iwc.row_quality,
          --  IHS Extentions
          iwc.top_strat_age,
          iwc.base_strat_age,
          iwc.province_state,
          iwc.x_perf_shots,
          iwc.x_perf_status,
          --  Extension for DataFinder - Assuming IHS data defaults to Metres
          'M' as tlm_perforation_per_uom
     from ihs_cdn_well_completion iwc
   union all
   select iwu.uwi,
          iwu.source,
          iwu.completion_obs_no,
          iwu.active_ind,
          iwu.base_depth,
          iwu.base_depth_ouom,
          iwu.base_strat_unit_id,
          iwu.completion_date,
          iwu.completion_method,
          iwu.completion_strat_unit_id,
          iwu.completion_type,
          iwu.effective_date,
          iwu.expiry_date,
          iwu.ppdm_guid,
          iwu.remark,
          iwu.strat_name_set_id,
          iwu.top_depth,
          iwu.top_depth_ouom,
          iwu.top_strat_unit_id,
          iwu.row_changed_by,
          iwu.row_changed_date,
          iwu.row_created_by,
          iwu.row_created_date,
          iwu.row_quality,
          --  IHS Extentions
          iwu.top_strat_age,
          iwu.base_strat_age,
          iwu.province_state,
          iwu.x_perf_shots,
          iwu.x_perf_status,
          --  Extension for DataFinder - Assuming IHS data defaults to Metres
          'M' as tlm_perforation_per_uom
     from ihs_us_well_completion iwu
;


grant select on ppdm.well_completion to ppdm_ro;


--create or replace synonym data_finder.well_completion for ppdm.well_completion;
--create or replace synonym ppdm.wco for ppdm.well_completion;
