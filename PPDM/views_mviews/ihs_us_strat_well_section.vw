/***************************************************************************************************
 ihs_us_strat_well_section  (view)

 20150812   Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_strat_well_section;


create or replace force view ppdm.ihs_us_strat_well_section
(
   uwi,
   strat_name_set_id,
   strat_unit_id,
   interp_id,
   active_ind,
   application_name,
   area_id,
   area_type,
   certified_ind,
   conformity_relationship,
   dominant_lithology,
   effective_date,
   expiry_date,
   interpreter,
   ordinal_seq_no,
   overturned_ind,
   pick_date,
   pick_depth,
   pick_depth_ouom,
   pick_location,
   pick_qualifier,
   pick_qualif_reason,
   pick_quality,
   pick_tvd,
   pick_version_type,
   ppdm_guid,
   preferred_pick_ind,
   remark,
   repeat_strat_occur_no,
   repeat_strat_type,
   source,
   source_document,
   strat_interpret_method,
   tvd_method,
   version_obs_no,
   x_base_strat_unit_id,
   x_base_depth,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state,
   x_strat_unit_id_num
)
as
   select /*+ use_nl(sws wv) */
          wv.uwi,
          sws.strat_name_set_id,
          sws.strat_unit_id,
          sws.interp_id,
          sws.active_ind,
          sws.application_name,
          sws.area_id,
          sws.area_type,
          sws.certified_ind,
          sws.conformity_relationship,
          sws.dominant_lithology,
          sws.effective_date,
          sws.expiry_date,
          sws.interpreter,
          sws.ordinal_seq_no,
          sws.overturned_ind,
          sws.pick_date,
          sws.pick_depth,
          sws.pick_depth_ouom,
          sws.pick_location,
          sws.pick_qualifier,
          sws.pick_qualif_reason,
          sws.pick_quality,
          sws.pick_tvd,
          sws.pick_version_type,
          sws.ppdm_guid,
          sws.preferred_pick_ind,
          sws.remark,
          sws.repeat_strat_occur_no,
          sws.repeat_strat_type,
          wv.source,
          sws.source_document,
          sws.strat_interpret_method,
          sws.tvd_method,
          sws.version_obs_no,
          sws.x_base_strat_unit_id,
          sws.x_base_depth,
          sws.row_changed_by,
          sws.row_changed_date,
          sws.row_created_by,
          sws.row_created_date,
          sws.row_quality,
          sws.province_state,
          sws.x_strat_unit_id_num
     from strat_well_section@c_talisman_us_ihsdataq sws, ppdm.well_version wv
    where     wv.well_num = sws.uwi
          and wv.source = '450PID'
          and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_strat_well_section to ppdm_ro;
