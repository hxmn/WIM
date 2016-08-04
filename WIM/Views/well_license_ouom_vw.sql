/**********************************************************************************************************************
 Well License with distance converted to meters

 History
  20160315 cdong  Documenting code in PETPROD, to ensure a create-script exists in source-control system Vault
                  I do not know when this view was first created, nor what this view is used for.

 **********************************************************************************************************************/

drop view well_license_ouom_vw;


create or replace force view well_license_ouom_vw
as
  select wl.uwi,
         wl.license_id,
         wl.source,
         wl.active_ind,
         wl.agent,
         wl.application_id,
         wl.authorized_strat_unit_id,
         wl.bidding_round_num,
         wl.contractor,
         wim.wim_util.uom_conversion ('M',
                                      nvl (wl.direction_to_loc_ouom, 'M'),
                                      wl.direction_to_loc)                     as direction_to_loc,
         wl.direction_to_loc_ouom,
         wl.distance_ref_point,
         wim.wim_util.uom_conversion ('M',
                                      nvl (wl.distance_to_loc_ouom, 'M'),
                                      wl.distance_to_loc)                      as distance_to_loc,
         wl.distance_to_loc_ouom,
         wl.drill_rig_num,
         wl.rig_name,
         wl.drill_slot_no,
         wl.drill_tool,
         wl.effective_date,
         wl.exception_granted,
         wl.exception_requested,
         wl.expired_ind,
         wl.expiry_date,
         wl.fees_paid_ind,
         wl.licensee,
         wl.licensee_contact_id,
         wl.license_date,
         wl.license_num,
         wl.no_of_wells,
         wl.offshore_completion_type,
         wl.permit_reference_num,
         wl.permit_reissue_date,
         wl.permit_type,
         wl.platform_name,
         wl.ppdm_guid,
         wim.wim_util.uom_conversion ('M',
                                      nvl (wl.projected_depth_ouom, 'M'),
                                      wl.projected_depth)                      as projected_depth,
         wl.projected_depth_ouom,
         wl.projected_strat_unit_id,
         wim.wim_util.uom_conversion ('M',
                                      nvl (wl.projected_tvd_ouom, 'M'),
                                      wl.projected_tvd)                        as projected_tvd,
         wl.projected_tvd_ouom,
         wl.proposed_spud_date,
         wl.purpose,
         wl.rate_schedule_id,
         wl.regulation,
         wl.regulatory_agency,
         wl.regulatory_contact_id,
         wl.remark,
         wl.rig_code,
         wim.wim_util.uom_conversion ('M',
                                      nvl (wl.rig_substr_height_ouom, 'M'),
                                      wl.rig_substr_height)                    as rig_substr_height,
         wl.rig_substr_height_ouom,
         wl.rig_type,
         rt.long_name                                                          as rig_type_name,
         wl.section_of_regulation,
         wl.strat_name_set_id,
         wl.surveyor,
         wl.target_objective_fluid,
         wl.ipl_projected_strat_age,
         wl.ipl_alt_source,
         wl.ipl_xaction_code,
         wl.row_changed_by,
         wl.row_changed_date,
         wl.row_created_by,
         wl.row_created_date,
         wl.ipl_well_objective,
         wl.row_quality,
         ba.ba_name                                                             as licensee_name
    from well_license wl, business_associate ba, ppdm.r_rig_type rt
   where wl.licensee = ba.business_associate(+)
         and wl.rig_type = rt.rig_type(+)
;


---- Grants
grant select on well_license_ouom_vw to wim_ro;


---- Synonyms
create or replace synonym dm_appl.well_license_ouom_vw          for well_license_ouom_vw;
create or replace synonym geoframe_appl.well_license_ouom_vw    for well_license_ouom_vw;
create or replace synonym geowiz_appl.well_license_ouom_vw      for well_license_ouom_vw;
create or replace synonym iwim_appl.well_license_ouom_vw        for well_license_ouom_vw;
create or replace synonym spatial_appl.well_license_ouom_vw     for well_license_ouom_vw;
