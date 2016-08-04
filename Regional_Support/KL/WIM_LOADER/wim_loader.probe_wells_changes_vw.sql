
  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."PROBE_WELLS_CHANGES_VW" ("WELL_NUM") AS 
  (
    select distinct ihs.well_num
    from (
        select w.well_num, max(greatest(
              nvl(w.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
              , nvl (w.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
              , nvl (base.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
              , nvl (base.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
              , nvl (surface.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
              , nvl (surface.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )) as ihs_date
        from probe_wells_stg w, 
        (
            SELECT *
            FROM probe_well_node_stg
            WHERE node_position = 'B'
        ) base,
        (
              SELECT *
              FROM probe_well_node_stg
              WHERE node_position = 'S'
        ) surface
        where w.uwi = surface.ipl_uwi(+) AND w.uwi = base.ipl_uwi(+) AND w.active_ind = 'Y'
        group by w.well_num
    ) ihs
    left join (
        select wv.well_num, max(greatest(
            nvl (wv.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
            , nvl (wv.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
            , nvl (nv_b.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
            , nvl (nv_b.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
            , nvl (nv_s.row_changed_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
            , nvl (nv_s.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )) as tlm_date
        from well_version wv,
        (
            select *
            from well_node_version
            where node_position = 'B'
                and source = '500PRB'
        ) nv_b,
        (
          select *
            from well_node_version
            where node_position = 'S'
                and source = '500PRB'
        ) nv_s
        where wv.source = '500PRB'
            and wv.active_ind = 'Y'
            and wv.uwi = nv_b.ipl_uwi(+)
            and wv.uwi = nv_s.ipl_uwi(+)
        group by wv.well_num
    ) ppdm on ihs.well_num = ppdm.well_num
    where ppdm.well_num is null or (ihs_date > tlm_date)
    union
    select well_num
    from (
        select well_num, abandonment_date, active_ind, assigned_field,
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
            oldest_strat_name_set_id, oldest_strat_unit_id, operator,
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
    from probe_wells_stg wv
    minus
        select well_num, abandonment_date, active_ind, assigned_field,
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
            oldest_strat_name_set_id, oldest_strat_unit_id, operator,
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
    from ppdm.well_version wv
    where source = '500PRB'
        and active_ind = 'Y'
    )
);
