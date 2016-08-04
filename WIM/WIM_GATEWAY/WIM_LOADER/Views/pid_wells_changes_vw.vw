
  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."PID_WELLS_CHANGES_VW" ("WELL_NUM") AS 
  SELECT well_num
     FROM (SELECT uwi AS well_num, abandonment_date, assigned_field,
                  completion_date, confidential_date, confidential_type,
                  confid_strat_name_set_id, confid_strat_unit_id, country,
                  SUBSTR (county, 3), current_class, current_status, current_status_date,
                  difference_lat_msl, discovery_ind, district, effective_date,
                  elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
                  geographic_region, geologic_province, ground_elev_type,
                  initial_class, lease_name, lease_num, legal_survey_type,
                  location_type,
                  CAST (oldest_strat_age AS VARCHAR (12)) AS oldest_strat_age,
                  oldest_strat_name_set_age, oldest_strat_name_set_id,
                  oldest_strat_unit_id, OPERATOR, parent_relationship_type,
                  parent_uwi, platform_id, platform_sf_type, plot_name,
                  plot_symbol, ppdm_guid, profile_type, province_state,
                  regulatory_agency, remark, rig_on_site_date,
                  rig_release_date, rotary_table_elev, source_document,
                  spud_date, status_type, subsea_elev_ref_type,
                  tax_credit_code, CAST(td_strat_age as VARCHAR(20)), td_strat_name_set_age,
                  td_strat_unit_id, water_acoustic_vel,
                  water_acoustic_vel_ouom, well_event_num, well_government_id,
                  well_intersect_md, well_name, well_numeric_id, SUBSTR (ipl_licensee, 3),
                  case 
                      when ipl_offshore_ind = 'Y' then 'OFFSHORE'
                      when ipl_offshore_ind = 'Y' then 'OFFSHORE'
                      else null
                  end as ipl_offshore_ind,
                  ipl_pidstatus, ipl_orstatus, ipl_prstatus,
                  ipl_onprod_date, ipl_confidential_strat_age, ipl_pool,
                  --ipl_last_update, 
                  ipl_uwi_sort, ipl_uwi_display, ipl_td_tvd,
                  ipl_plugback_tvd, ipl_whipstock_tvd, ipl_water_tvd,
                  ipl_alt_source, ipl_basin, ipl_block, ipl_area, ipl_twp,
                  ipl_tract, ipl_lot, ipl_conc, ipl_uwi_local, depth_datum,
                  ROUND (casing_flange_elev * .3048 / 1,
                         5
                        ) AS casing_flange_elev,
                  casing_flange_elev_ouom,
                  ROUND (confidential_depth * .3048 / 1,
                         5
                        ) AS confidential_depth,
                  confidential_depth_ouom,
                  ROUND (deepest_depth * .3048 / 1, 5) AS deepest_depth,
                  deepest_depth_ouom,
                  
                  --cast(wim_util.uom_conversion ('FT','M',depth_datum_elev) as number(10,5)),
                  ROUND (depth_datum_elev * .3048 / 1, 5) AS depth_datum_elev,
                  depth_datum_elev_ouom,
                  ROUND (derrick_floor_elev * .3048 / 1,
                         5
                        ) AS derrick_floor_elev,
                  derrick_floor_elev_ouom,
                  ROUND (drill_td * .3048 / 1, 5) AS drill_td, drill_td_ouom,
                  ROUND (final_td * .3048 / 1, 5) AS final_td, final_td_ouom,
                  ROUND (ground_elev * .3048 / 1, 5) AS ground_elev,
                  ground_elev_ouom, ROUND (kb_elev * .3048 / 1, 5) AS kb_elev,
                  kb_elev_ouom, ROUND (log_td * .3048 / 1, 5) AS log_td,
                  log_td_ouom, ROUND (max_tvd * .3048 / 1, 5) AS max_tvd,
                  max_tvd_ouom, (net_pay * .3048 / 1) AS net_pay,
                  net_pay_ouom,
                  ROUND (plugback_depth * .3048 / 1, 5) AS plugback_depth,
                  plugback_depth_ouom,
                  ROUND (water_depth * .3048 / 1, 5) AS water_depth,
                  water_depth_ouom,
                  ROUND (whipstock_depth * .3048 / 1, 5) AS whipstock_depth,
                  whipstock_depth_ouom --, row_changed_date, row_created_date
             FROM well_pidstg_mv             --well@c_talisman_us             
            WHERE active_ind = 'Y'
            and well_name is not null
           MINUS
           SELECT well_num, abandonment_date, assigned_field, completion_date,
                  confidential_date, confidential_type,
                  confid_strat_name_set_id, confid_strat_unit_id, country,
                  county, current_class, current_status, current_status_date,
                  difference_lat_msl, discovery_ind, district, effective_date,
                  elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
                  geographic_region, geologic_province, ground_elev_type,
                  initial_class, lease_name, lease_num, legal_survey_type,
                  location_type, oldest_strat_age, oldest_strat_name_set_age,
                  oldest_strat_name_set_id, oldest_strat_unit_id, OPERATOR,
                  parent_relationship_type, parent_uwi, platform_id,
                  platform_sf_type, plot_name, plot_symbol, ppdm_guid,
                  profile_type, province_state, regulatory_agency, remark,
                  rig_on_site_date, rig_release_date, rotary_table_elev,
                  source_document, spud_date, status_type,
                  subsea_elev_ref_type, tax_credit_code, td_strat_age,
                  td_strat_name_set_age, td_strat_unit_id, water_acoustic_vel,
                  water_acoustic_vel_ouom, well_event_num, well_government_id,
                  well_intersect_md, well_name, well_numeric_id, ipl_licensee,
                  ipl_offshore_ind, ipl_pidstatus, ipl_orstatus, ipl_prstatus,
                  ipl_onprod_date, ipl_confidential_strat_age, ipl_pool,
                  --ipl_last_update,
                   ipl_uwi_sort, ipl_uwi_display, ipl_td_tvd,
                  ipl_plugback_tvd, ipl_whipstock_tvd, ipl_water_tvd,
                  ipl_alt_source, ipl_basin, ipl_block, ipl_area, ipl_twp,
                  ipl_tract, ipl_lot, ipl_conc, ipl_uwi_local, depth_datum,
                  casing_flange_elev, casing_flange_elev_ouom,
                  confidential_depth, confidential_depth_ouom, deepest_depth,
                  deepest_depth_ouom, depth_datum_elev, depth_datum_elev_ouom,
                  derrick_floor_elev, derrick_floor_elev_ouom, drill_td,
                  drill_td_ouom, final_td, final_td_ouom, ground_elev,
                  ground_elev_ouom, kb_elev, kb_elev_ouom, log_td,
                  log_td_ouom, max_tvd, max_tvd_ouom, net_pay, net_pay_ouom,
                  plugback_depth, plugback_depth_ouom, water_depth,
                  water_depth_ouom, whipstock_depth, whipstock_depth_ouom
                --  row_changed_date, row_created_date
             FROM well_version
            WHERE SOURCE = '450PID' AND active_ind = 'Y')
   UNION
   SELECT well_num
     FROM (SELECT wnv.uwi AS well_num, wnv.node_obs_no, wnv.acquisition_id,
                  wnv.active_ind, wnv.country, substr(wnv.county,3),
                  ROUND (wnv.easting * .3048 / 1, 5) AS easting,
                  wnv.easting_ouom, wnv.effective_date,
                  ROUND (wnv.elev * .3048 / 1, 5), wnv.elev_ouom,
                  wnv.ew_direction, wnv.expiry_date, wnv.geog_coord_system_id,
                  wnv.latitude, wnv.legal_survey_type, wnv.location_qualifier,
                  wnv.location_quality, wnv.longitude,
                  wnv.map_coord_system_id, ROUND (wnv.md * .3048 / 1, 5),
                  wnv.md_ouom, wnv.monument_id, wnv.monument_sf_type,
                  wnv.node_position, wnv.north_type,
                  ROUND (wnv.northing * .3048 / 1, 5), wnv.northing_ouom,
                  wnv.ns_direction, wnv.polar_azimuth,
                  ROUND (wnv.polar_offset * .3048 / 1, 2),
                  wnv.polar_offset_ouom, wnv.ppdm_guid, wnv.preferred_ind,
                  wnv.province_state, wnv.remark,
                  ROUND (wnv.reported_tvd * .3048 / 1, 5),
                  wnv.reported_tvd_ouom, wnv.version_type,
                  ROUND (x_offset * .3048 / 1, 2), wnv.x_offset_ouom,
                  ROUND (y_offset * .3048 / 1, 2), wnv.y_offset_ouom
             --  wnv.row_changed_by, wnv.row_changed_date,
              -- wnv.row_created_by, wnv.row_created_date
           FROM   well_node_Versionpidstg_mv wnv,
                  well_pidstg_mv w
            WHERE wnv.uwi = w.uwi
              AND wnv.location_qualifier = 'IH' 
              and w.active_ind ='Y' and wnv.active_ind ='Y'
              AND wnv.node_position = 'B' and w.well_name is not null             
           minus
           SELECT wv.well_num, wnv.node_obs_no, wnv.acquisition_id,
                  wnv.active_ind, wnv.country, wnv.county, wnv.easting,
                  wnv.easting_ouom, wnv.effective_date, wnv.elev,
                  wnv.elev_ouom, wnv.ew_direction, wnv.expiry_date,
                  wnv.geog_coord_system_id, wnv.latitude,
                  wnv.legal_survey_type, wnv.location_qualifier,
                  wnv.location_quality, wnv.longitude,
                  wnv.map_coord_system_id, wnv.md, wnv.md_ouom,
                  wnv.monument_id, wnv.monument_sf_type, wnv.node_position,
                  wnv.north_type, wnv.northing, wnv.northing_ouom,
                  wnv.ns_direction, wnv.polar_azimuth, wnv.polar_offset,
                  wnv.polar_offset_ouom, wnv.ppdm_guid, wnv.preferred_ind,
                  wnv.province_state, wnv.remark, wnv.reported_tvd,
                  wnv.reported_tvd_ouom, wnv.version_type, wnv.x_offset,
                  wnv.x_offset_ouom, wnv.y_offset, wnv.y_offset_ouom
             -- wnv.row_changed_by, wnv.row_changed_date,
             -- wnv.row_created_by, wnv.row_created_date
           FROM   ppdm.well_node_version wnv, ppdm.well_version wv
            WHERE wv.uwi = wnv.ipl_uwi
              AND wv.SOURCE = '450PID'
              AND wnv.SOURCE = '450PID'
              AND wnv.node_position = 'B'
              AND wnv.location_qualifier = 'IH'
              AND wnv.active_ind = 'Y'
              AND wv.active_ind = 'Y')
   UNION
   --SURFACE NODE
   SELECT well_num
     FROM (SELECT wnv.uwi AS well_num, wnv.node_obs_no, wnv.acquisition_id,
                  wnv.active_ind, wnv.country, substr(wnv.county,3),
                  ROUND (wnv.easting * .3048 / 1, 5) AS easting,
                  wnv.easting_ouom, wnv.effective_date,
                  ROUND (wnv.elev * .3048 / 1, 5), wnv.elev_ouom,
                  wnv.ew_direction, wnv.expiry_date, wnv.geog_coord_system_id,
                  wnv.latitude, wnv.legal_survey_type, wnv.location_qualifier,
                  wnv.location_quality, wnv.longitude,
                  wnv.map_coord_system_id, ROUND (wnv.md * .3048 / 1, 5),
                  wnv.md_ouom, wnv.monument_id, wnv.monument_sf_type,
                  wnv.node_position, wnv.north_type,
                  ROUND (wnv.northing * .3048 / 1, 5), wnv.northing_ouom,
                  wnv.ns_direction, wnv.polar_azimuth,
                  ROUND (wnv.polar_offset * .3048 / 1, 2),
                  wnv.polar_offset_ouom, wnv.ppdm_guid, wnv.preferred_ind,
                  wnv.province_state, wnv.remark,
                  ROUND (wnv.reported_tvd * .3048 / 1, 5),
                  wnv.reported_tvd_ouom, wnv.version_type,
                  ROUND (x_offset * .3048 / 1, 2), wnv.x_offset_ouom,
                  ROUND (y_offset * .3048 / 1, 2), wnv.y_offset_ouom
             --  wnv.row_changed_by, wnv.row_changed_date,
              -- wnv.row_created_by, wnv.row_created_date
           FROM   well_node_Versionpidstg_mv wnv,
                  well_pidstg_mv w
            WHERE wnv.uwi = w.uwi
              AND wnv.location_qualifier = 'IH' 
              and w.active_ind ='Y' and wnv.active_ind ='Y'
              AND wnv.node_position = 'S' and w.well_name is not null
             
           minus
           SELECT wv.well_num, wnv.node_obs_no, wnv.acquisition_id,
                  wnv.active_ind, wnv.country, wnv.county, wnv.easting,
                  wnv.easting_ouom, wnv.effective_date, wnv.elev,
                  wnv.elev_ouom, wnv.ew_direction, wnv.expiry_date,
                  wnv.geog_coord_system_id, wnv.latitude,
                  wnv.legal_survey_type, wnv.location_qualifier,
                  wnv.location_quality, wnv.longitude,
                  wnv.map_coord_system_id, wnv.md, wnv.md_ouom,
                  wnv.monument_id, wnv.monument_sf_type, wnv.node_position,
                  wnv.north_type, wnv.northing, wnv.northing_ouom,
                  wnv.ns_direction, wnv.polar_azimuth, wnv.polar_offset,
                  wnv.polar_offset_ouom, wnv.ppdm_guid, wnv.preferred_ind,
                  wnv.province_state, wnv.remark, wnv.reported_tvd,
                  wnv.reported_tvd_ouom, wnv.version_type, wnv.x_offset,
                  wnv.x_offset_ouom, wnv.y_offset, wnv.y_offset_ouom
             -- wnv.row_changed_by, wnv.row_changed_date,
             -- wnv.row_created_by, wnv.row_created_date
           FROM   ppdm.well_node_version wnv, ppdm.well_version wv
            WHERE wv.uwi = wnv.ipl_uwi
              AND wv.SOURCE = '450PID'
              AND wnv.SOURCE = '450PID'
              AND wnv.node_position = 'S'
              AND wnv.location_qualifier = 'IH'
              AND wnv.active_ind = 'Y'
              AND wv.active_ind = 'Y'
              
     )
   --STATUSES
   UNION
   SELECT well_num
     FROM (SELECT ws.uwi AS well_num, prefix_zeros(ws.status_id), ws.effective_date,
                  ws.expiry_date, ws.ppdm_guid, ws.remark, ws.status,
                  ws.status_date, ws.status_depth, ws.status_depth_ouom,
                  --ws.ipl_xaction_code,
                   ws.status_type
             FROM well_statuspidstg_mv ws,
                  well_pidstg_mv w
            WHERE ws.active_ind = 'Y' 
              AND ws.active_ind = 'Y'
              AND ws.uwi = w.uwi
              AND w.well_name is not null
           MINUS
           SELECT wv.well_num, status_id, ws.effective_date, ws.expiry_date,
                  ws.ppdm_guid, ws.remark, status, status_date, status_depth,
                  status_depth_ouom, --ws.ipl_xaction_code,
                   ws.status_type
             FROM well_status ws, well_version wv
            WHERE ws.SOURCE = '450PID'
              AND wv.uwi = ws.uwi
              AND wv.SOURCE = '450PID'
              AND ws.active_ind = 'Y'
              AND wv.active_ind ='Y')
 --  LICENSES
   UNION
   SELECT well_num
     FROM (SELECT wl.uwi AS well_num, wl.agent, wl.application_id,
                  wl.authorized_strat_unit_id, wl.bidding_round_num,
                  wl.contractor,
                  ROUND (wl.direction_to_loc * 1609.344 / 1, 2),
                  wl.direction_to_loc_ouom, wl.distance_ref_point,
                  ROUND (wl.distance_to_loc * 1609.344 / 1, 2),
                  wl.distance_to_loc_ouom, wl.drill_rig_num,
                  wl.drill_slot_no, wl.drill_tool, wl.effective_date,
                  wl.exception_granted, wl.exception_requested,
                  wl.expired_ind, wl.expiry_date, wl.fees_paid_ind,
                  --wl.ipl_alt_source, --wl.ipl_projected_strat_age,
                  wl.ipl_well_objective, --wl.ipl_xaction_code,
                  wl.license_date, wl.license_num, wl.licensee,
                  wl.licensee_contact_id, wl.no_of_wells,
                  wl.offshore_completion_type, wl.permit_reference_num,
                  wl.permit_reissue_date, wl.permit_type,
                  wl.platform_name, wl.ppdm_guid,
                  ROUND (wl.projected_depth * .3048 / 1, 5),
                  wl.projected_depth_ouom, wl.projected_strat_unit_id,
                  ROUND (wl.projected_tvd * .3048 / 1, 5),
                  wl.projected_tvd_ouom, wl.proposed_spud_date,
                  wl.purpose, wl.rate_schedule_id, wl.regulation,
                  wl.regulatory_agency, wl.regulatory_contact_id,
                  wl.remark, wl.rig_code,
                  ROUND (wl.rig_substr_height * .3048 / 1, 2),
                  wl.rig_substr_height_ouom, wl.rig_type,
                  wl.row_quality, wl.section_of_regulation,
                  wl.strat_name_set_id, wl.surveyor,
                  wl.target_objective_fluid
             FROM well_licensepidstg_mv wl, well_pidstg_mv w
            WHERE wl.uwi = w.uwi 
              AND wl.license_num IS NOT NULL 
              and w.well_name is not null 
              and wl.active_ind ='Y'
              and w.active_ind ='Y'
              and wl.license_num <> '0'
           MINUS
           SELECT wv.well_num, wl.AGENT, wl.application_id,
                  wl.authorized_strat_unit_id, wl.bidding_round_num,
                  wl.contractor, wl.direction_to_loc,
                  wl.direction_to_loc_ouom, wl.distance_ref_point,
                  wl.distance_to_loc, wl.distance_to_loc_ouom,
                  wl.drill_rig_num, wl.drill_slot_no, wl.drill_tool,
                  wl.effective_date, wl.exception_granted,
                  wl.exception_requested, wl.expired_ind, wl.expiry_date,
                  wl.fees_paid_ind, --wl.ipl_alt_source,
                  --wl.ipl_projected_strat_age,
                   wl.ipl_well_objective,
                  --wl.ipl_xaction_code, 
                  wl.license_date, wl.license_num,
                  wl.licensee, wl.licensee_contact_id, wl.no_of_wells,
                  wl.offshore_completion_type, wl.permit_reference_num,
                  wl.permit_reissue_date, wl.permit_type, wl.platform_name,
                  wl.ppdm_guid, wl.projected_depth, wl.projected_depth_ouom,
                  wl.projected_strat_unit_id, wl.projected_tvd,
                  wl.projected_tvd_ouom, wl.proposed_spud_date, wl.purpose,
                  wl.rate_schedule_id, wl.regulation, wl.regulatory_agency,
                  wl.regulatory_contact_id, wl.remark, wl.rig_code,
                  wl.rig_substr_height, wl.rig_substr_height_ouom,
                  wl.rig_type, wl.row_quality, wl.section_of_regulation,
                  wl.strat_name_set_id, wl.surveyor,
                  wl.target_objective_fluid
             FROM ppdm.well_license wl, well_version wv
            WHERE wl.active_ind = 'Y'
              AND wv.active_ind = 'Y'
              AND wl.uwi = wv.uwi
              AND wl.SOURCE = '450PID'
              AND wv.SOURCE = '450PID')
 ;
