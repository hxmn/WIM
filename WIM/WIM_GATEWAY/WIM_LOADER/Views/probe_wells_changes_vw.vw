
  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."PROBE_WELLS_CHANGES_VW" ("WELL_NUM") AS 
  (SELECT DISTINCT ihs.well_num
               FROM (SELECT   w.well_num,
                              MAX
                                 (GREATEST (NVL (w.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (w.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (base.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (base.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (surface.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (surface.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                )
                                           )
                                 ) ihs_date
                         FROM well_versionprbstg_mv w,
                              (SELECT *
                                 FROM well_node_versionprbstg_mv
                                WHERE node_position = 'B') base,
                              (SELECT *
                                 FROM well_node_versionprbstg_mv
                                WHERE node_position = 'S') surface
                        WHERE w.uwi = surface.ipl_uwi(+) AND w.uwi = base.ipl_uwi(+)
                              AND w.active_ind = 'Y'
                              and w.country not in (select country from ppdm_admin.r_country_ap)
                     --and w.base_nodE_id = '0000280131'
                     GROUP BY well_num) ihs
                    LEFT JOIN
                    (SELECT   wv.well_num,
                              MAX
                                 (GREATEST (NVL (wv.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (wv.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (nv_b.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (nv_b.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (nv_s.row_changed_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                ),
                                            NVL (nv_s.row_created_date,
                                                 TO_DATE ('0001-01-01',
                                                          'yyyy-mm-dd'
                                                         )
                                                )
                                           )
                                 ) tlm_date
                         FROM well_version wv,
                              (SELECT *
                                 FROM well_node_version
                                WHERE node_position = 'B'
                                      AND SOURCE = '500PRB') nv_b,
                              (SELECT *
                                 FROM well_node_version
                                WHERE node_position = 'S'
                                      AND SOURCE = '500PRB') nv_s
                        WHERE wv.SOURCE = '500PRB'
                          AND wv.active_ind = 'Y'
                          AND wv.uwi = nv_b.ipl_uwi(+)
                          AND wv.uwi = nv_s.ipl_uwi(+)
                          and wv.country not in (select country from ppdm_admin.r_country_ap)
                     GROUP BY well_num) ppdm ON ihs.well_num = ppdm.well_num
              WHERE ppdm.well_num IS NULL OR (ihs_date > tlm_date)
    UNION
    SELECT well_num
      FROM (SELECT well_num, abandonment_date, active_ind, assigned_field,
                   casing_flange_elev, casing_flange_elev_ouom,
                   completion_date, confid_strat_name_set_id,
                   confid_strat_unit_id, confidential_date,
                   confidential_depth, confidential_depth_ouom,
                   confidential_type, country, county, current_class,
                   current_status, current_status_date, deepest_depth,
                   deepest_depth_ouom, depth_datum, depth_datum_elev,
                   depth_datum_elev_ouom, derrick_floor_elev,
                   derrick_floor_elev_ouom, difference_lat_msl, discovery_ind,
                   district, drill_td, drill_td_ouom, effective_date,
                   elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
                   final_td, final_td_ouom, geographic_region,
                   geologic_province, ground_elev, ground_elev_ouom,
                   ground_elev_type, initial_class, ipl_alt_source, ipl_area,
                   ipl_basin, ipl_block, ipl_conc, ipl_confidential_strat_age,
                   ipl_last_update, ipl_licensee, ipl_lot, ipl_offshore_ind,
                   ipl_oninject_date, ipl_onprod_date, ipl_orstatus,
                   ipl_pidstatus, ipl_plugback_tvd, ipl_pool, ipl_prstatus,
                   ipl_td_tvd, ipl_tract, ipl_twp, ipl_water_tvd,
                   ipl_whipstock_tvd, ipl_xaction_code, kb_elev, kb_elev_ouom,
                   lease_name, lease_num, legal_survey_type, location_type,
                   log_td, log_td_ouom, max_tvd, max_tvd_ouom, net_pay,
                   net_pay_ouom, oldest_strat_age, oldest_strat_name_set_age,
                   oldest_strat_name_set_id, oldest_strat_unit_id, OPERATOR,
                   parent_relationship_type, parent_uwi, platform_id,
                   platform_sf_type, plot_name, plot_symbol, plugback_depth,
                   plugback_depth_ouom, ppdm_guid, profile_type,
                   province_state, regulatory_agency, remark,
                   rig_on_site_date, rig_release_date, rotary_table_elev,
                   source_document, spud_date, status_type,
                   subsea_elev_ref_type, tax_credit_code, td_strat_age,
                   td_strat_name_set_age, td_strat_name_set_id,
                   td_strat_unit_id, water_acoustic_vel,
                   water_acoustic_vel_ouom, water_depth, water_depth_datum,
                   water_depth_ouom, well_event_num, well_government_id,
                   well_intersect_md, well_name, well_numeric_id,
                   whipstock_depth, whipstock_depth_ouom, surface_latitude,
                   surface_longitude, bottom_hole_latitude,
                   bottom_hole_longitude, row_changed_date, row_created_date
              FROM well_versionprbstg_mv wv
              where wv.country not in (select country from ppdm_admin.r_country_ap)
            MINUS
            SELECT well_num, abandonment_date, active_ind, assigned_field,
                   casing_flange_elev, casing_flange_elev_ouom,
                   completion_date, confid_strat_name_set_id,
                   confid_strat_unit_id, confidential_date,
                   confidential_depth, confidential_depth_ouom,
                   confidential_type, country, county, current_class,
                   current_status, current_status_date, deepest_depth,
                   deepest_depth_ouom, depth_datum, depth_datum_elev,
                   depth_datum_elev_ouom, derrick_floor_elev,
                   derrick_floor_elev_ouom, difference_lat_msl, discovery_ind,
                   district, drill_td, drill_td_ouom, effective_date,
                   elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
                   final_td, final_td_ouom, geographic_region,
                   geologic_province, ground_elev, ground_elev_ouom,
                   ground_elev_type, initial_class, ipl_alt_source, ipl_area,
                   ipl_basin, ipl_block, ipl_conc, ipl_confidential_strat_age,
                   ipl_last_update, ipl_licensee, ipl_lot, ipl_offshore_ind,
                   ipl_oninject_date, ipl_onprod_date, ipl_orstatus,
                   ipl_pidstatus, ipl_plugback_tvd, ipl_pool, ipl_prstatus,
                   ipl_td_tvd, ipl_tract, ipl_twp, ipl_water_tvd,
                   ipl_whipstock_tvd, ipl_xaction_code, kb_elev, kb_elev_ouom,
                   lease_name, lease_num, legal_survey_type, location_type,
                   log_td, log_td_ouom, max_tvd, max_tvd_ouom, net_pay,
                   net_pay_ouom, oldest_strat_age, oldest_strat_name_set_age,
                   oldest_strat_name_set_id, oldest_strat_unit_id, OPERATOR,
                   parent_relationship_type, parent_uwi, platform_id,
                   platform_sf_type, plot_name, plot_symbol, plugback_depth,
                   plugback_depth_ouom, ppdm_guid, profile_type,
                   province_state, regulatory_agency, remark,
                   rig_on_site_date, rig_release_date, rotary_table_elev,
                   source_document, spud_date, status_type,
                   subsea_elev_ref_type, tax_credit_code, td_strat_age,
                   td_strat_name_set_age, td_strat_name_set_id,
                   td_strat_unit_id, water_acoustic_vel,
                   water_acoustic_vel_ouom, water_depth, water_depth_datum,
                   water_depth_ouom, well_event_num, well_government_id,
                   well_intersect_md, well_name, well_numeric_id,
                   whipstock_depth, wv.whipstock_depth_ouom, surface_latitude,
                   surface_longitude, bottom_hole_latitude,
                   bottom_hole_longitude, row_changed_date, row_created_date
              FROM ppdm.well_version wv
             WHERE SOURCE = '500PRB' AND active_ind = 'Y'
             and wv.country not in (select country from ppdm_admin.r_country_ap)
             ));
