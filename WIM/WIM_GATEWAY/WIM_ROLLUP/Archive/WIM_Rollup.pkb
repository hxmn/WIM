CREATE OR REPLACE PACKAGE BODY WIM.WIM_Rollup
IS
--
-- ========== ===============================================================
-- 2008.03.06 Doug Henderson, Talisman Energy Ltd.
--            initial creation from old version of well_refresh
-- 2008.03.07 Doug Henderson, Talisman Energy Ltd.
--            refactor and reformat
-- 2008.03.11 Doug Henderson, Talisman Energy Ltd.
--            refactor to make null_row procedure
-- 2008.05.06 Doug Henderson, Talisman Energy Ltd.
--            adjust priority of nodes based on sources and datums
-- 2008.05.13 Doug Henderson, Talisman Energy Ltd.
--            revise node priority. I.E., move 150TLMX above 200TLI
--            overwrite well (bottom_hole|surface)_(lat|long)itude with values from well_node
-- 2008.06.05 Doug Henderson, Talisman Energy Ltd.
--            inactivate the well row when there are no well_version rows
--            inactivate the well_node row when there are no well_node_version rows
-- 2008.06.18 Doug Henderson, Talisman Energy Inc.
--            refactor as package
-- 2008.06.27 Doug Henderson, Talisman Energy Ltd.
--            add NAD83 to geog2epsg function
-- 2008.07.23 Doug Henderson, Talisman Energy Inc.
--            add 850TLML source
--            add merge_node procedure
--            use merge instead of insert and update procedures
--            update ready function
--            ignore node validation errors
-- 2008.07.24 Doug Henderson, Talisman Energy Inc.
--            validate well versions
--            mark orphan well_alias rows as inactive
-- 2008.09.05 Doug Henderson, Talisman Energy Inc.
--            expose geog2epsg function.
-- 2008.10.22 Doug Henderson, Talisman Energy Inc.
--            change dependency chaining in ready().
--            only update well surface/base node ids when they would change.
-- 2008.10.23 Doug Henderson, Talisman Energy Inc.
--            add new source 590TLMR
-- 2008.11.05 Doug Henderson, Talisman Energy Inc.
--            modify well_node columns to more closely match PPDM 3.7 standard
--            rename primary_source to source, ...
-- 2009.01.07 Doug Henderson, Talisman Energy Inc.
--            remove AUTHID CURRENT_USER clause
-- 2009.01.09 Doug Henderson, Talisman Energy Inc.
--            handle case when only override version remains
-- 2009.03.06 Doug Henderson, Talisman Energy Inc.
--            lookup and calculate node ids in well_and_nodes
--            do not call well/node validator - too many messages
-- 2009.03.23 Doug Henderson, Talisman Energy Inc.
--            use NOCOPY for large record parameters
-- 2009.06.16 Doug Henderson, Talisman Energy Inc.
--            correct logic error when inactivating an isolated
--            075TLMO well version
--            Change source priority for node refresh
--            to place 400FNDR nodes after 100TLM and before 450PID nodes
--            Correct a sql logic error when inactivating a well version or well
--            node version row with a null active indicator.
-- 2009.12.21 Floy Baird, TLM
--            Remove 590TLMR - this source deemed obsolete by Well Data Steward
--                No records attached to this source
--            Add restriction of Active_Ind != 'N' to restrict the rollup to ACTIVE records only
--            Add logical rollup pairings such as keeping OUOM together with data
--            Add logical rollup pairings keeping depths and ouom together
--            Add logical rollup pairings keeping status and type together
--            Add logical rollup pairings keeping parent relationship type and parent uwi together
--            Add logical rollup pairings keeping strat name set and strat unit together
--            Add logical rollup pairings keeping row change by and date together
--            Add logical rollup pairings keeping row created date and by together 
-- 2010.03.19  Floy Baird, TLM
--            Add function on row_updated to move the most recent date into composite well to ensure 
--            user knows some attribute has been changed on that date
-- 2010.03.29 Floy Baird, TLM
--            Add Function to Get Active_Ind flag to determine whether the rollup will act only 
--            on 'ACTIVE'('Y') or INACTIVE'('N') Versions
-- 2010.04.19 Floy Baird, TLM
--            Add Changed_by and Changed_Date logic to roll up the most recent date and to pair that with changed_by 
--            to indicate to consumers of the data the most recent currency of change and by who
-- 2010.07.30 Richard Masterman, TLM
--            Added MAX to the Last_Chg_by function in case 2 records have the same timestamp
-- 2010.08.23 Richard Masterman
--             1) Removed 075 caveat which stopped it rolling up the 075 in the source attribute
--             2) Removed references to the test VALIDATOR function as the Gateway will validate now before roll up
--             3) Switched to use common TLM_PROCESS_LOG package
--             4) Removed redundant error_count variables
--             5) Removed COMMIT to allow caller to determine success of overall transaction
--             6) Stopped Nodes rolling up when inactive
--             7) Node roll up assumes IPL_UWI attribute is filled correctly - which it should be from now on 
--             8) Nodes now roll up the EARLIEST create date and the LATEST update date - ignoring precedence
--             9) Same approach to create date/update date applied to WELL rollup for consistency & speed
--             10) Added the update to WELL_VERSION of lat/long information when nodes rolled up
--             11) Remove Well and Well_Node record if no underlying version records exist
--             12) Remove Option to call WELL and NODE rollup separately - now only whole well or source rollups
--             13) Renamed to WIM_Rollup package and renamed procedures to clean up terminology
--             14) Added Version Function
--   2010.10.22 Richard Masterman
--              Changed WARNING for removing last composite well or node to an INFO message as it is a regular
--              and acceptable update.
--   2010.11.04 Richard Masterman
--              Changed the roll ups to NOT retain composite wells/nodes if no ACTIVE versions exist and not
--              to report an INFO message if there was no composite WELL or WELL_NODE to clean up
--   2011.01.17 Richard Masterman
--              Source roll up now COMMITs changes every 1000 wells and logs progress to avoid locking the whole dataset or blowing
--              resource limits
              

    --  External Function
    FUNCTION Version
        RETURN VARCHAR2
    IS

      --  Return package version number
      --  Format: nn.mm.ll (kk)
      --    nn - Major version (Numeric)
      --    mm - Functional change (Numeric)
      --    ll - Bug fix revision (Numeric)
      --    k  - Optional - Test version (letters)  
      
    BEGIN
        RETURN '2.0.10';
    END Version; 

    -- LOCAL Function 
    FUNCTION geog2epsg (geog_coord_system_id IN VARCHAR2)
        RETURN VARCHAR2
    IS
    
    --  Returns Geog Coord system ID from the name
    BEGIN
        RETURN CASE geog_coord_system_id
            WHEN 'WGS84'
                THEN '4326'                              -- new international
            WHEN 'IHS83'
                THEN '4326'                         -- new ihs north american
            WHEN 'NAD83'
                THEN '4326'                             -- new north american
            WHEN 'NAD27'
                THEN '4267'                             -- old north american
            WHEN 'IHS27'
                THEN '4267'                         -- old ihs north american
            ELSE NULL
        END;
    END geog2epsg;
    

    -- LOCAL PROCEDURE - Inserts or updates the new rolled up well record
    PROCEDURE merge_well (a_row IN OUT NOCOPY ppdm.well_version%ROWTYPE)
    IS
    BEGIN
            MERGE INTO PPDM.well dst
                USING (SELECT a_row.uwi uwi,
                              a_row.abandonment_date abandonment_date,
                              a_row.active_ind active_ind,
                              a_row.assigned_field assigned_field,
                              a_row.base_node_id base_node_id,
                              a_row.bottom_hole_latitude bottom_hole_latitude,
                              a_row.bottom_hole_longitude bottom_hole_longitude,
                              a_row.casing_flange_elev casing_flange_elev,
                              a_row.casing_flange_elev_ouom casing_flange_elev_ouom,
                              a_row.completion_date completion_date,
                              a_row.confidential_date confidential_date,
                              a_row.confidential_depth confidential_depth,
                              a_row.confidential_depth_ouom confidential_depth_ouom,
                              a_row.confidential_type confidential_type,
                              a_row.confid_strat_name_set_id confid_strat_name_set_id,
                              a_row.confid_strat_unit_id confid_strat_unit_id,
                              a_row.country country, a_row.county county,
                              a_row.current_class current_class,
                              a_row.current_status current_status,
                              a_row.current_status_date current_status_date,
                              a_row.deepest_depth deepest_depth,
                              a_row.deepest_depth_ouom deepest_depth_ouom,
                              a_row.depth_datum depth_datum,
                              a_row.depth_datum_elev depth_datum_elev,
                              a_row.depth_datum_elev_ouom depth_datum_elev_ouom,
                              a_row.derrick_floor_elev derrick_floor_elev,
                              a_row.derrick_floor_elev_ouom derrick_floor_elev_ouom,
                              a_row.difference_lat_msl difference_lat_msl,
                              a_row.discovery_ind discovery_ind,
                              a_row.district district,
                              a_row.drill_td drill_td,
                              a_row.drill_td_ouom drill_td_ouom,
                              a_row.effective_date effective_date,
                              a_row.elev_ref_datum elev_ref_datum,
                              a_row.expiry_date expiry_date,
                              a_row.faulted_ind faulted_ind,
                              a_row.final_drill_date final_drill_date,
                              a_row.final_td final_td,
                              a_row.final_td_ouom final_td_ouom,
                              a_row.geographic_region geographic_region,
                              a_row.geologic_province geologic_province,
                              a_row.ground_elev ground_elev,
                              a_row.ground_elev_ouom ground_elev_ouom,
                              a_row.ground_elev_type ground_elev_type,
                              a_row.initial_class initial_class,
                              a_row.kb_elev kb_elev,
                              a_row.kb_elev_ouom kb_elev_ouom,
                              a_row.lease_name lease_name,
                              a_row.lease_num lease_num,
                              a_row.legal_survey_type legal_survey_type,
                              a_row.location_type location_type,
                              a_row.log_td log_td,
                              a_row.log_td_ouom log_td_ouom,
                              a_row.max_tvd max_tvd,
                              a_row.max_tvd_ouom max_tvd_ouom,
                              a_row.net_pay net_pay,
                              a_row.net_pay_ouom net_pay_ouom,
                              a_row.oldest_strat_age oldest_strat_age,
                              a_row.oldest_strat_name_set_age oldest_strat_name_set_age,
                              a_row.oldest_strat_name_set_id oldest_strat_name_set_id,
                              a_row.oldest_strat_unit_id oldest_strat_unit_id,
                              a_row.OPERATOR OPERATOR,
                              a_row.parent_relationship_type parent_relationship_type,
                              a_row.parent_uwi parent_uwi,
                              a_row.platform_id platform_id,
                              a_row.platform_sf_type platform_sf_type,
                              a_row.plot_name plot_name,
                              a_row.plot_symbol plot_symbol,
                              a_row.plugback_depth plugback_depth,
                              a_row.plugback_depth_ouom plugback_depth_ouom,
                              a_row.ppdm_guid ppdm_guid,
                              a_row.profile_type profile_type,
                              a_row.province_state province_state,
                              a_row.regulatory_agency regulatory_agency,
                              a_row.remark remark,
                              a_row.rig_on_site_date rig_on_site_date,
                              a_row.rig_release_date rig_release_date,
                              a_row.rotary_table_elev rotary_table_elev,
                              a_row.SOURCE SOURCE,
                              a_row.source_document source_document,
                              a_row.spud_date spud_date,
                              a_row.status_type status_type,
                              a_row.subsea_elev_ref_type subsea_elev_ref_type,
                              a_row.surface_latitude surface_latitude,
                              a_row.surface_longitude surface_longitude,
                              a_row.surface_node_id surface_node_id,
                              a_row.tax_credit_code tax_credit_code,
                              a_row.td_strat_age td_strat_age,
                              a_row.td_strat_name_set_age td_strat_name_set_age,
                              a_row.td_strat_name_set_id td_strat_name_set_id,
                              a_row.td_strat_unit_id td_strat_unit_id,
                              a_row.water_acoustic_vel water_acoustic_vel,
                              a_row.water_acoustic_vel_ouom water_acoustic_vel_ouom,
                              a_row.water_depth water_depth,
                              a_row.water_depth_datum water_depth_datum,
                              a_row.water_depth_ouom water_depth_ouom,
                              a_row.well_event_num well_event_num,
                              a_row.well_government_id well_government_id,
                              a_row.well_intersect_md well_intersect_md,
                              a_row.well_name well_name,
                              a_row.well_num well_num,
                              a_row.well_numeric_id well_numeric_id,
                              a_row.whipstock_depth whipstock_depth,
                              a_row.whipstock_depth_ouom whipstock_depth_ouom,
                              a_row.ipl_licensee ipl_licensee,
                              a_row.ipl_offshore_ind ipl_offshore_ind,
                              a_row.ipl_pidstatus ipl_pidstatus,
                              a_row.ipl_prstatus ipl_prstatus,
                              a_row.ipl_orstatus ipl_orstatus,
                              a_row.ipl_onprod_date ipl_onprod_date,
                              a_row.ipl_oninject_date ipl_oninject_date,
                              a_row.ipl_confidential_strat_age ipl_confidential_strat_age,
                              a_row.ipl_pool ipl_pool,
                              a_row.ipl_last_update ipl_last_update,
                              a_row.ipl_uwi_sort ipl_uwi_sort,
                              a_row.ipl_uwi_display ipl_uwi_display,
                              a_row.ipl_td_tvd ipl_td_tvd,
                              a_row.ipl_plugback_tvd ipl_plugback_tvd,
                              a_row.ipl_whipstock_tvd ipl_whipstock_tvd,
                              a_row.ipl_water_tvd ipl_water_tvd,
                              a_row.ipl_alt_source ipl_alt_source,
                              a_row.ipl_xaction_code ipl_xaction_code,
                              a_row.row_changed_by row_changed_by,
                              a_row.row_changed_date row_changed_date,
                              a_row.row_created_by row_created_by,
                              a_row.row_created_date row_created_date,
                              a_row.ipl_basin ipl_basin,
                              a_row.ipl_block ipl_block,
                              a_row.ipl_area ipl_area, a_row.ipl_twp ipl_twp,
                              a_row.ipl_tract ipl_tract,
                              a_row.ipl_lot ipl_lot, a_row.ipl_conc ipl_conc,
                              a_row.ipl_uwi_local ipl_uwi_local,
                              a_row.row_quality row_quality
                         FROM DUAL) src
                ON (dst.uwi = src.uwi)
                WHEN MATCHED THEN
                    UPDATE
                       SET abandonment_date = src.abandonment_date,
                           active_ind = src.active_ind,
                           assigned_field = src.assigned_field,
                           base_node_id = src.base_node_id,
                           bottom_hole_latitude = src.bottom_hole_latitude,
                           bottom_hole_longitude = src.bottom_hole_longitude,
                           casing_flange_elev = src.casing_flange_elev,
                           casing_flange_elev_ouom = src.casing_flange_elev_ouom,
                           completion_date = src.completion_date,
                           confidential_date = src.confidential_date,
                           confidential_depth = src.confidential_depth,
                           confidential_depth_ouom = src.confidential_depth_ouom,
                           confidential_type = src.confidential_type,
                           confid_strat_name_set_id = src.confid_strat_name_set_id,
                           confid_strat_unit_id = src.confid_strat_unit_id,
                           country = src.country, county = src.county,
                           current_class = src.current_class,
                           current_status = src.current_status,
                           current_status_date = src.current_status_date,
                           deepest_depth = src.deepest_depth,
                           deepest_depth_ouom = src.deepest_depth_ouom,
                           depth_datum = src.depth_datum,
                           depth_datum_elev = src.depth_datum_elev,
                           depth_datum_elev_ouom = src.depth_datum_elev_ouom,
                           derrick_floor_elev = src.derrick_floor_elev,
                           derrick_floor_elev_ouom = src.derrick_floor_elev_ouom,
                           difference_lat_msl = src.difference_lat_msl,
                           discovery_ind = src.discovery_ind,
                           district = src.district, drill_td = src.drill_td,
                           drill_td_ouom = src.drill_td_ouom,
                           effective_date = src.effective_date,
                           elev_ref_datum = src.elev_ref_datum,
                           expiry_date = src.expiry_date,
                           faulted_ind = src.faulted_ind,
                           final_drill_date = src.final_drill_date,
                           final_td = src.final_td,
                           final_td_ouom = src.final_td_ouom,
                           geographic_region = src.geographic_region,
                           geologic_province = src.geologic_province,
                           ground_elev = src.ground_elev,
                           ground_elev_ouom = src.ground_elev_ouom,
                           ground_elev_type = src.ground_elev_type,
                           initial_class = src.initial_class,
                           kb_elev = src.kb_elev,
                           kb_elev_ouom = src.kb_elev_ouom,
                           lease_name = src.lease_name,
                           lease_num = src.lease_num,
                           legal_survey_type = src.legal_survey_type,
                           location_type = src.location_type,
                           log_td = src.log_td,
                           log_td_ouom = src.log_td_ouom,
                           max_tvd = src.max_tvd,
                           max_tvd_ouom = src.max_tvd_ouom,
                           net_pay = src.net_pay,
                           net_pay_ouom = src.net_pay_ouom,
                           oldest_strat_age = src.oldest_strat_age,
                           oldest_strat_name_set_age = src.oldest_strat_name_set_age,
                           oldest_strat_name_set_id = src.oldest_strat_name_set_id,
                           oldest_strat_unit_id = src.oldest_strat_unit_id,
                           OPERATOR = src.OPERATOR,
                           parent_relationship_type = src.parent_relationship_type,
                           parent_uwi = src.parent_uwi,
                           platform_id = src.platform_id,
                           platform_sf_type = src.platform_sf_type,
                           plot_name = src.plot_name,
                           plot_symbol = src.plot_symbol,
                           plugback_depth = src.plugback_depth,
                           plugback_depth_ouom = src.plugback_depth_ouom,
                           ppdm_guid = src.ppdm_guid,
                           primary_source = src.SOURCE,-- note source column name difference
                           profile_type = src.profile_type,
                           province_state = src.province_state,
                           regulatory_agency = src.regulatory_agency,
                           remark = src.remark,
                           rig_on_site_date = src.rig_on_site_date,
                           rig_release_date = src.rig_release_date,
                           rotary_table_elev = src.rotary_table_elev,
                           source_document = src.source_document,
                           spud_date = src.spud_date,
                           status_type = src.status_type,
                           subsea_elev_ref_type = src.subsea_elev_ref_type,
                           surface_latitude = src.surface_latitude,
                           surface_longitude = src.surface_longitude,
                           surface_node_id = src.surface_node_id,
                           tax_credit_code = src.tax_credit_code,
                           td_strat_age = src.td_strat_age,
                           td_strat_name_set_age = src.td_strat_name_set_age,
                           td_strat_name_set_id = src.td_strat_name_set_id,
                           td_strat_unit_id = src.td_strat_unit_id,
                           water_acoustic_vel = src.water_acoustic_vel,
                           water_acoustic_vel_ouom = src.water_acoustic_vel_ouom,
                           water_depth = src.water_depth,
                           water_depth_datum = src.water_depth_datum,
                           water_depth_ouom = src.water_depth_ouom,
                           well_event_num = src.well_event_num,
                           well_government_id = src.well_government_id,
                           well_intersect_md = src.well_intersect_md,
                           well_name = src.well_name,
                           well_num = src.well_num,
                           well_numeric_id = src.well_numeric_id,
                           whipstock_depth = src.whipstock_depth,
                           whipstock_depth_ouom = src.whipstock_depth_ouom,
                           ipl_licensee = src.ipl_licensee,
                           ipl_offshore_ind = src.ipl_offshore_ind,
                           ipl_pidstatus = src.ipl_pidstatus,
                           ipl_prstatus = src.ipl_prstatus,
                           ipl_orstatus = src.ipl_orstatus,
                           ipl_onprod_date = src.ipl_onprod_date,
                           ipl_oninject_date = src.ipl_oninject_date,
                           ipl_confidential_strat_age = src.ipl_confidential_strat_age,
                           ipl_pool = src.ipl_pool,
                           ipl_last_update = src.ipl_last_update,
                           ipl_uwi_sort = src.ipl_uwi_sort,
                           ipl_uwi_display = src.ipl_uwi_display,
                           ipl_td_tvd = src.ipl_td_tvd,
                           ipl_plugback_tvd = src.ipl_plugback_tvd,
                           ipl_whipstock_tvd = src.ipl_whipstock_tvd,
                           ipl_water_tvd = src.ipl_water_tvd,
                           ipl_alt_source = src.ipl_alt_source,
                           ipl_xaction_code = src.ipl_xaction_code,
                           row_changed_by = src.row_changed_by,
                           row_changed_date = src.row_changed_date,
                           row_created_by = src.row_created_by,
                           row_created_date = src.row_created_date,
                           ipl_basin = src.ipl_basin,
                           ipl_block = src.ipl_block,
                           ipl_area = src.ipl_area, ipl_twp = src.ipl_twp,
                           ipl_tract = src.ipl_tract, ipl_lot = src.ipl_lot,
                           ipl_conc = src.ipl_conc,
                           ipl_uwi_local = src.ipl_uwi_local,
                           row_quality = src.row_quality
                WHEN NOT MATCHED THEN
                    INSERT (uwi, abandonment_date, active_ind,
                            assigned_field, base_node_id,
                            bottom_hole_latitude, bottom_hole_longitude,
                            casing_flange_elev, casing_flange_elev_ouom,
                            completion_date, confidential_date,
                            confidential_depth, confidential_depth_ouom,
                            confidential_type, confid_strat_name_set_id,
                            confid_strat_unit_id, country, county,
                            current_class, current_status,
                            current_status_date, deepest_depth,
                            deepest_depth_ouom, depth_datum,
                            depth_datum_elev, depth_datum_elev_ouom,
                            derrick_floor_elev, derrick_floor_elev_ouom,
                            difference_lat_msl, discovery_ind, district,
                            drill_td, drill_td_ouom, effective_date,
                            elev_ref_datum, expiry_date, faulted_ind,
                            final_drill_date, final_td, final_td_ouom,
                            geographic_region, geologic_province,
                            ground_elev, ground_elev_ouom, ground_elev_type,
                            initial_class, kb_elev, kb_elev_ouom, lease_name,
                            lease_num, legal_survey_type, location_type,
                            log_td, log_td_ouom, max_tvd, max_tvd_ouom,
                            net_pay, net_pay_ouom, oldest_strat_age,
                            oldest_strat_name_set_age,
                            oldest_strat_name_set_id, oldest_strat_unit_id,
                            OPERATOR, parent_relationship_type, parent_uwi,
                            platform_id, platform_sf_type, plot_name,
                            plot_symbol, plugback_depth, plugback_depth_ouom,
                            ppdm_guid, primary_source, profile_type,
                            province_state, regulatory_agency, remark,
                            rig_on_site_date, rig_release_date,
                            rotary_table_elev, source_document, spud_date,
                            status_type, subsea_elev_ref_type,
                            surface_latitude, surface_longitude,
                            surface_node_id, tax_credit_code, td_strat_age,
                            td_strat_name_set_age, td_strat_name_set_id,
                            td_strat_unit_id, water_acoustic_vel,
                            water_acoustic_vel_ouom, water_depth,
                            water_depth_datum, water_depth_ouom,
                            well_event_num, well_government_id,
                            well_intersect_md, well_name, well_num,
                            well_numeric_id, whipstock_depth,
                            whipstock_depth_ouom, ipl_licensee,
                            ipl_offshore_ind, ipl_pidstatus, ipl_prstatus,
                            ipl_orstatus, ipl_onprod_date, ipl_oninject_date,
                            ipl_confidential_strat_age, ipl_pool,
                            ipl_last_update, ipl_uwi_sort, ipl_uwi_display,
                            ipl_td_tvd, ipl_plugback_tvd, ipl_whipstock_tvd,
                            ipl_water_tvd, ipl_alt_source, ipl_xaction_code,
                            row_changed_by, row_changed_date, row_created_by,
                            row_created_date, ipl_basin, ipl_block, ipl_area,
                            ipl_twp, ipl_tract, ipl_lot, ipl_conc,
                            ipl_uwi_local, row_quality)
                    VALUES (src.uwi, src.abandonment_date, src.active_ind,
                            src.assigned_field, src.base_node_id,
                            src.bottom_hole_latitude,
                            src.bottom_hole_longitude,
                            src.casing_flange_elev,
                            src.casing_flange_elev_ouom, src.completion_date,
                            src.confidential_date, src.confidential_depth,
                            src.confidential_depth_ouom,
                            src.confidential_type,
                            src.confid_strat_name_set_id,
                            src.confid_strat_unit_id, src.country,
                            src.county, src.current_class,
                            src.current_status, src.current_status_date,
                            src.deepest_depth, src.deepest_depth_ouom,
                            src.depth_datum, src.depth_datum_elev,
                            src.depth_datum_elev_ouom,
                            src.derrick_floor_elev,
                            src.derrick_floor_elev_ouom,
                            src.difference_lat_msl, src.discovery_ind,
                            src.district, src.drill_td, src.drill_td_ouom,
                            src.effective_date, src.elev_ref_datum,
                            src.expiry_date, src.faulted_ind,
                            src.final_drill_date, src.final_td,
                            src.final_td_ouom, src.geographic_region,
                            src.geologic_province, src.ground_elev,
                            src.ground_elev_ouom, src.ground_elev_type,
                            src.initial_class, src.kb_elev, src.kb_elev_ouom,
                            src.lease_name, src.lease_num,
                            src.legal_survey_type, src.location_type,
                            src.log_td, src.log_td_ouom, src.max_tvd,
                            src.max_tvd_ouom, src.net_pay, src.net_pay_ouom,
                            src.oldest_strat_age,
                            src.oldest_strat_name_set_age,
                            src.oldest_strat_name_set_id,
                            src.oldest_strat_unit_id, src.OPERATOR,
                            src.parent_relationship_type, src.parent_uwi,
                            src.platform_id, src.platform_sf_type,
                            src.plot_name, src.plot_symbol,
                            src.plugback_depth, src.plugback_depth_ouom,
                            src.ppdm_guid,
                            src.SOURCE,            -- to primary_source column
                            src.profile_type, src.province_state,
                            src.regulatory_agency, src.remark,
                            src.rig_on_site_date, src.rig_release_date,
                            src.rotary_table_elev, src.source_document,
                            src.spud_date, src.status_type,
                            src.subsea_elev_ref_type, src.surface_latitude,
                            src.surface_longitude, src.surface_node_id,
                            src.tax_credit_code, src.td_strat_age,
                            src.td_strat_name_set_age,
                            src.td_strat_name_set_id, src.td_strat_unit_id,
                            src.water_acoustic_vel,
                            src.water_acoustic_vel_ouom, src.water_depth,
                            src.water_depth_datum, src.water_depth_ouom,
                            src.well_event_num, src.well_government_id,
                            src.well_intersect_md, src.well_name,
                            src.well_num, src.well_numeric_id,
                            src.whipstock_depth, src.whipstock_depth_ouom,
                            src.ipl_licensee, src.ipl_offshore_ind,
                            src.ipl_pidstatus, src.ipl_prstatus,
                            src.ipl_orstatus, src.ipl_onprod_date,
                            src.ipl_oninject_date,
                            src.ipl_confidential_strat_age, src.ipl_pool,
                            src.ipl_last_update, src.ipl_uwi_sort,
                            src.ipl_uwi_display, src.ipl_td_tvd,
                            src.ipl_plugback_tvd, src.ipl_whipstock_tvd,
                            src.ipl_water_tvd, src.ipl_alt_source,
                            src.ipl_xaction_code, src.row_changed_by,
                            src.row_changed_date, src.row_created_by,
                            src.row_created_date, src.ipl_basin,
                            src.ipl_block, src.ipl_area, src.ipl_twp,
                            src.ipl_tract, src.ipl_lot, src.ipl_conc,
                            src.ipl_uwi_local, src.row_quality);
    EXCEPTION
            WHEN OTHERS
            THEN
                ppdm.tlm_process_logger.sqlerror
                          ('WIM_Rollup.Merge_Well: Exception during roll up of well '
                            || a_row.uwi || '(' || a_row.source || ')');
                RAISE;
    END merge_well;

    -- LOCAL PROCEDURE
    PROCEDURE null_well_row (a_row IN OUT NOCOPY ppdm.well_version%ROWTYPE)
    IS

    --  Sets the new composite well record to NULL ready to roll up into

     BEGIN
            -- initialize all the new row columns
            a_row.uwi := NULL;
            a_row.abandonment_date := NULL;
            a_row.active_ind := NULL;
            a_row.assigned_field := NULL;
            a_row.base_node_id := NULL;
            a_row.bottom_hole_latitude := NULL;
            a_row.bottom_hole_longitude := NULL;
            a_row.casing_flange_elev := NULL;
            a_row.casing_flange_elev_ouom := NULL;
            a_row.completion_date := NULL;
            a_row.confidential_date := NULL;
            a_row.confidential_depth := NULL;
            a_row.confidential_depth_ouom := NULL;
            a_row.confid_strat_name_set_id := NULL;
            a_row.confid_strat_unit_id := NULL;
            a_row.confidential_type := NULL;
            a_row.country := NULL;
            a_row.county := NULL;
            a_row.current_class := NULL;
            a_row.current_status := NULL;
            a_row.current_status_date := NULL;
            a_row.deepest_depth := NULL;
            a_row.deepest_depth_ouom := NULL;
            a_row.depth_datum := NULL;
            a_row.depth_datum_elev := NULL;
            a_row.depth_datum_elev_ouom := NULL;
            a_row.derrick_floor_elev := NULL;
            a_row.derrick_floor_elev_ouom := NULL;
            a_row.difference_lat_msl := NULL;
            a_row.discovery_ind := NULL;
            a_row.district := NULL;
            a_row.drill_td := NULL;
            a_row.drill_td_ouom := NULL;
            a_row.effective_date := NULL;
            a_row.elev_ref_datum := NULL;
            a_row.expiry_date := NULL;
            a_row.faulted_ind := NULL;
            a_row.final_drill_date := NULL;
            a_row.final_td := NULL;
            a_row.final_td_ouom := NULL;
            a_row.geographic_region := NULL;
            a_row.geologic_province := NULL;
            a_row.ground_elev := NULL;
            a_row.ground_elev_ouom := NULL;
            a_row.ground_elev_type := NULL;
            a_row.initial_class := NULL;
            a_row.kb_elev := NULL;
            a_row.kb_elev_ouom := NULL;
            a_row.lease_name := NULL;
            a_row.lease_num := NULL;
            a_row.legal_survey_type := NULL;
            a_row.location_type := NULL;
            a_row.log_td := NULL;
            a_row.log_td_ouom := NULL;
            a_row.max_tvd := NULL;
            a_row.max_tvd_ouom := NULL;
            a_row.net_pay := NULL;
            a_row.net_pay_ouom := NULL;
            a_row.oldest_strat_name_set_age := NULL;
            a_row.oldest_strat_age := NULL;
            a_row.oldest_strat_name_set_id := NULL;
            a_row.oldest_strat_unit_id := NULL;
            a_row.OPERATOR := NULL;
            a_row.parent_relationship_type := NULL;
            a_row.parent_uwi := NULL;
            a_row.platform_id := NULL;
            a_row.platform_sf_type := NULL;
            a_row.plot_name := NULL;
            a_row.plot_symbol := NULL;
            a_row.plugback_depth := NULL;
            a_row.plugback_depth_ouom := NULL;
            a_row.ppdm_guid := NULL;
            a_row.profile_type := NULL;
            a_row.province_state := NULL;
            a_row.regulatory_agency := NULL;
            a_row.remark := NULL;
            a_row.rig_on_site_date := NULL;
            a_row.rig_release_date := NULL;
            a_row.rotary_table_elev := NULL;
            a_row.SOURCE := NULL;
            a_row.source_document := NULL;
            a_row.spud_date := NULL;
            a_row.status_type := NULL;
            a_row.subsea_elev_ref_type := NULL;
            a_row.surface_latitude := NULL;
            a_row.surface_longitude := NULL;
            a_row.surface_node_id := NULL;
            a_row.tax_credit_code := NULL;
            a_row.td_strat_name_set_age := NULL;
            a_row.td_strat_age := NULL;
            a_row.td_strat_name_set_id := NULL;
            a_row.td_strat_unit_id := NULL;
            a_row.water_acoustic_vel := NULL;
            a_row.water_acoustic_vel_ouom := NULL;
            a_row.water_depth := NULL;
            a_row.water_depth_ouom := NULL;
            a_row.well_government_id := NULL;
            a_row.well_intersect_md := NULL;
            a_row.well_name := NULL;
            a_row.well_num := NULL;
            a_row.well_numeric_id := NULL;
            a_row.whipstock_depth := NULL;
            a_row.whipstock_depth_ouom := NULL;
            a_row.ipl_licensee := NULL;
            a_row.well_event_num := NULL;
            a_row.ipl_offshore_ind := NULL;
            a_row.ipl_pidstatus := NULL;
            a_row.ipl_prstatus := NULL;
            a_row.ipl_orstatus := NULL;
            a_row.ipl_onprod_date := NULL;
            a_row.ipl_oninject_date := NULL;
            a_row.ipl_confidential_strat_age := NULL;
            a_row.ipl_pool := NULL;
            a_row.ipl_last_update := NULL;
            a_row.ipl_uwi_sort := NULL;
            a_row.ipl_uwi_display := NULL;
            a_row.ipl_td_tvd := NULL;
            a_row.ipl_plugback_tvd := NULL;
            a_row.ipl_whipstock_tvd := NULL;
            a_row.ipl_water_tvd := NULL;
            a_row.ipl_alt_source := NULL;
            a_row.ipl_xaction_code := NULL;
            a_row.row_changed_by := NULL;
            a_row.row_changed_date := NULL;
            a_row.row_created_by := NULL;
            a_row.row_created_date := NULL;
            a_row.ipl_basin := NULL;
            a_row.ipl_block := NULL;
            a_row.ipl_area := NULL;
            a_row.ipl_twp := NULL;
            a_row.ipl_tract := NULL;
            a_row.ipl_lot := NULL;
            a_row.ipl_conc := NULL;
            a_row.ipl_uwi_local := NULL;
            a_row.row_quality := NULL;
     END null_well_row;
     
     
    -- LOCAL PROCEDURE to update the WELL_VERSION table with the highest
    --  precedence location for the specified source 
     PROCEDURE Update_WV_Location (pTLM_ID   IN VARCHAR2,
                                   pSource   IN VARCHAR2,
                                   pPosition IN VARCHAR2) IS

          cNode_ID   ppdm.well_node_version.Node_ID%TYPE;
          cLatitude  ppdm.well_node_version.Latitude%TYPE;
          cLongitude ppdm.well_node_version.Longitude%TYPE;

          --  Returns active nodes in precedence order given the well, source and position 
          CURSOR Node_Version
          IS
            SELECT Node_ID, Latitude, Longitude
                FROM ppdm.well_node_version
               WHERE IPL_UWI = pTLM_ID
                 AND Source = pSource
                 AND Node_position = pPosition
                 and Active_Ind = 'Y'
            ORDER BY GEOG_Coord_System_ID DESC,
                     Location_Qualifier,
                     Node_Obs_no DESC;
        
     BEGIN
        
          OPEN Node_version;
        
          -- Take the first entry in the cursor - this will be highest precedence
          FETCH Node_version INTO cNode_ID, cLatitude, cLongitude;
          
--dbms_output.put_line('Update_WV_Location : Well: ' || pTLM_ID || ', NODE: ' || cNode_ID || ',' || pSource ||','|| ',' || pPosition);
          
          --  Update the values into the WELL_VERSION table
          IF pPosition = 'B'
            THEN
              
                --  Update WELL_VERSION table with the highest precedence location
                --  Note: This will be NULL if no node found and resets the values 
                UPDATE PPDM.Well_Version
                   SET bottom_hole_latitude = cLatitude,
                       bottom_hole_longitude = cLongitude,
                       base_node_id = cNode_id
                 WHERE uwi = pTLM_ID
                   AND Source = pSource;
          ELSIF pPosition = 'S'
            THEN

                UPDATE PPDM.Well_Version
                   SET surface_latitude = cLatitude,
                       surface_longitude = cLongitude,
                       surface_node_id = cNode_id
                 WHERE uwi = pTLM_ID
                   AND Source = pSource;

          END IF;
        
          CLOSE Node_version;
        
     END Update_WV_Location;


        -- LOCAL PROCEDURE - Sets the new composite node record to NULL ready to roll up into
        PROCEDURE null_node_row (a_row IN OUT NOCOPY ppdm.well_node_version%ROWTYPE)
        IS
        BEGIN
            a_row.node_id := NULL;
            a_row.node_obs_no := NULL;
            a_row.acquisition_id := NULL;
            a_row.active_ind := NULL;
            a_row.country := NULL;
            a_row.county := NULL;
            a_row.easting := NULL;
            a_row.easting_ouom := NULL;
            a_row.effective_date := NULL;
            a_row.elev := NULL;
            a_row.elev_ouom := NULL;
            a_row.ew_direction := NULL;
            a_row.expiry_date := NULL;
            a_row.geog_coord_system_id := NULL;
            a_row.latitude := NULL;
            a_row.legal_survey_type := NULL;
            a_row.location_qualifier := NULL;
            a_row.location_quality := NULL;
            a_row.longitude := NULL;
            a_row.map_coord_system_id := NULL;
            a_row.md := NULL;
            a_row.md_ouom := NULL;
            a_row.monument_id := NULL;
            a_row.monument_sf_type := NULL;
            a_row.node_position := NULL;
            a_row.northing := NULL;
            a_row.northing_ouom := NULL;
            a_row.north_type := NULL;
            a_row.ns_direction := NULL;
            a_row.polar_azimuth := NULL;
            a_row.polar_offset := NULL;
            a_row.polar_offset_ouom := NULL;
            a_row.ppdm_guid := NULL;
            a_row.preferred_ind := NULL;
            a_row.province_state := NULL;
            a_row.remark := NULL;
            a_row.reported_tvd := NULL;
            a_row.reported_tvd_ouom := NULL;
            a_row.SOURCE := NULL;
            a_row.version_type := NULL;
            a_row.x_offset := NULL;
            a_row.x_offset_ouom := NULL;
            a_row.y_offset := NULL;
            a_row.y_offset_ouom := NULL;
            a_row.ipl_xaction_code := NULL;
            a_row.row_changed_by := NULL;
            a_row.row_changed_date := NULL;
            a_row.row_created_by := NULL;
            a_row.row_created_date := NULL;
            a_row.ipl_uwi := NULL;
            a_row.row_quality := NULL;
        END null_node_row;

        PROCEDURE merge_node (a_row IN OUT NOCOPY ppdm.well_node_version%ROWTYPE)
        IS
            l_coord_system_id   ppdm.well_node.coord_system_id%TYPE;
        BEGIN
            l_coord_system_id := geog2epsg (a_row.geog_coord_system_id);
            MERGE INTO ppdm.well_node dst
                USING (SELECT a_row.node_id node_id, a_row.SOURCE SOURCE,
                              a_row.node_obs_no node_obs_no,
                              a_row.acquisition_id acquisition_id,
                              a_row.active_ind active_ind,
                              a_row.country country, a_row.county county,
                              a_row.easting easting,
                              a_row.easting_ouom easting_ouom,
                              a_row.effective_date effective_date,
                              a_row.elev elev, a_row.elev_ouom elev_ouom,
                              a_row.ew_direction ew_direction,
                              a_row.expiry_date expiry_date,
                              a_row.geog_coord_system_id geog_coord_system_id,
                              a_row.latitude latitude,
                              a_row.legal_survey_type legal_survey_type,
                              a_row.location_qualifier location_qualifier,
                              a_row.location_quality location_quality,
                              a_row.longitude longitude,
                              a_row.map_coord_system_id map_coord_system_id,
                              a_row.md md, a_row.md_ouom md_ouom,
                              a_row.monument_id monument_id,
                              a_row.monument_sf_type monument_sf_type,
                              a_row.node_position node_position,
                              a_row.northing northing,
                              a_row.northing_ouom northing_ouom,
                              a_row.north_type north_type,
                              a_row.ns_direction ns_direction,
                              a_row.polar_azimuth polar_azimuth,
                              a_row.polar_offset polar_offset,
                              a_row.polar_offset_ouom polar_offset_ouom,
                              a_row.ppdm_guid ppdm_guid,
                              a_row.preferred_ind preferred_ind,
                              a_row.province_state province_state,
                              a_row.remark remark,
                              a_row.reported_tvd reported_tvd,
                              a_row.reported_tvd_ouom reported_tvd_ouom,
                              a_row.version_type version_type,
                              a_row.x_offset x_offset,
                              a_row.x_offset_ouom x_offset_ouom,
                              a_row.y_offset y_offset,
                              a_row.y_offset_ouom y_offset_ouom,
                              a_row.ipl_xaction_code ipl_xaction_code,
                              a_row.row_changed_by row_changed_by,
                              a_row.row_changed_date row_changed_date,
                              a_row.row_created_by row_created_by,
                              a_row.row_created_date row_created_date,
                              a_row.ipl_uwi ipl_uwi,
                              a_row.row_quality row_quality,
                              l_coord_system_id coord_system_id
                         FROM DUAL) src
                ON (dst.node_id = src.node_id)
                WHEN MATCHED THEN
                    UPDATE
                       SET node_obs_no = src.node_obs_no,
                           SOURCE = src.SOURCE,
                           acquisition_id = src.acquisition_id,
                           active_ind = src.active_ind,
                           country = src.country, county = src.county,
                           easting = src.easting,
                           easting_ouom = src.easting_ouom,
                           effective_date = src.effective_date,
                           elev = src.elev, elev_ouom = src.elev_ouom,
                           ew_direction = src.ew_direction,
                           expiry_date = src.expiry_date,
                           geog_coord_system_id = src.geog_coord_system_id,
                           latitude = src.latitude,
                           legal_survey_type = src.legal_survey_type,
                           location_qualifier = src.location_qualifier,
                           location_quality = src.location_quality,
                           longitude = src.longitude,
                           map_coord_system_id = src.map_coord_system_id,
                           md = src.md, md_ouom = src.md_ouom,
                           monument_id = src.monument_id,
                           monument_sf_type = src.monument_sf_type,
                           node_position = src.node_position,
                           northing = src.northing,
                           northing_ouom = src.northing_ouom,
                           north_type = src.north_type,
                           ns_direction = src.ns_direction,
                           polar_azimuth = src.polar_azimuth,
                           polar_offset = src.polar_offset,
                           polar_offset_ouom = src.polar_offset_ouom,
                           ppdm_guid = src.ppdm_guid,
                           preferred_ind = src.preferred_ind,
                           province_state = src.province_state,
                           remark = src.remark,
                           reported_tvd = src.reported_tvd,
                           reported_tvd_ouom = src.reported_tvd_ouom,
                           version_type = src.version_type,
                           x_offset = src.x_offset,
                           x_offset_ouom = src.x_offset_ouom,
                           y_offset = src.y_offset,
                           y_offset_ouom = src.y_offset_ouom,
                           ipl_xaction_code = src.ipl_xaction_code,
                           row_changed_by = src.row_changed_by,
                           row_changed_date = src.row_changed_date,
                           row_created_by = src.row_created_by,
                           row_created_date = src.row_created_date,
                           ipl_uwi = src.ipl_uwi,
                           row_quality = src.row_quality,
                           coord_system_id = src.coord_system_id
                WHEN NOT MATCHED THEN
                    INSERT (node_id, SOURCE, node_obs_no, acquisition_id,
                            active_ind, country, county, easting,
                            easting_ouom, effective_date, elev, elev_ouom,
                            ew_direction, expiry_date, geog_coord_system_id,
                            latitude, legal_survey_type, location_qualifier,
                            location_quality, longitude, map_coord_system_id,
                            md, md_ouom, monument_id, monument_sf_type,
                            node_position, northing, northing_ouom,
                            north_type, ns_direction, polar_azimuth,
                            polar_offset, polar_offset_ouom, ppdm_guid,
                            preferred_ind, province_state, remark,
                            reported_tvd, reported_tvd_ouom, version_type,
                            x_offset, x_offset_ouom, y_offset, y_offset_ouom,
                            ipl_xaction_code, row_changed_by,
                            row_changed_date, row_created_by,
                            row_created_date, ipl_uwi, row_quality,
                            coord_system_id)
                    VALUES (src.node_id, src.SOURCE, src.node_obs_no,
                            src.acquisition_id, src.active_ind, src.country,
                            src.county, src.easting, src.easting_ouom,
                            src.effective_date, src.elev, src.elev_ouom,
                            src.ew_direction, src.expiry_date,
                            src.geog_coord_system_id, src.latitude,
                            src.legal_survey_type, src.location_qualifier,
                            src.location_quality, src.longitude,
                            src.map_coord_system_id, src.md, src.md_ouom,
                            src.monument_id, src.monument_sf_type,
                            src.node_position, src.northing,
                            src.northing_ouom, src.north_type,
                            src.ns_direction, src.polar_azimuth,
                            src.polar_offset, src.polar_offset_ouom,
                            src.ppdm_guid, src.preferred_ind,
                            src.province_state, src.remark, src.reported_tvd,
                            src.reported_tvd_ouom, src.version_type,
                            src.x_offset, src.x_offset_ouom, src.y_offset,
                            src.y_offset_ouom, src.ipl_xaction_code,
                            src.row_changed_by, src.row_changed_date,
                            src.row_created_by, src.row_created_date,
                            src.ipl_uwi, src.row_quality,
                            src.coord_system_id);
        EXCEPTION
            WHEN OTHERS
            THEN
                ppdm.tlm_process_logger.sqlerror ('WIM_Rollup.Merge_node: Exception during roll up of node '
                                              ||a_row.node_id || '(' || a_row.source || ')');
                          
                RAISE;
        END merge_node;
     

    -- LOCAL Procedure
    PROCEDURE well_version_rollup (input_uwi IN VARCHAR2)
    IS
        -- Build a well row that accumulates all information from WELL_VERSION
        -- rows.
        --
        -- The order of rows returned by the cursor Well_List defined below
        -- establishes priority with which non-null values are accumulated.
        -- The first non-null encountered while processing the cursor's result
        -- set establishes the value for a column in the resulting WELL row.
            
        --  Note : Only active versions are rolled up. Well Data Steward confirmed
        --         there is no need to retaim an inactive composite so it will be
        --         removed if there are no versions or they are all inactive.

        new_row            ppdm.well_version%ROWTYPE;
        Row_Count          NUMBER;

        -- Lists the wells in source precedence order
        CURSOR Well_list
        IS
            SELECT   *
                FROM ppdm.well_version
               WHERE uwi = input_uwi
                 AND ACTIVE_IND = 'Y'
                 AND SOURCE IN
                         ('075TLMO',
                          '100TLM',
                          '150TLMX',
                          '200TLI',
                          '300IPL',
                          '400FNDR',
                          '450PID',
                          '500PRB',
                          '600TLMD',
                          '650TLMC',
                          '700TLME',
                          '800TLMP',
                          '850TLML')
            ORDER BY uwi, SOURCE;


    BEGIN
    
        -- Clear the new row ready to roll up into
        null_well_row (new_row);

--dbms_output.put_line('Well_version_rollup : Well: ' || input_UWI);


        -- Take each well version in order of HIGHEST precedence first and populate the new row 
        FOR old_row IN Well_list LOOP

            -- for each column, accumulate the highest priority non-null value
            IF new_row.uwi IS NULL AND old_row.uwi IS NOT NULL
            THEN
                new_row.uwi := old_row.uwi;
            END IF;

            IF     new_row.SOURCE IS NULL
               AND old_row.SOURCE IS NOT NULL
            THEN
                new_row.SOURCE := old_row.SOURCE;
            END IF;

            IF     new_row.abandonment_date IS NULL
               AND old_row.abandonment_date IS NOT NULL
            THEN
                new_row.abandonment_date := old_row.abandonment_date;
            END IF;

            IF new_row.active_ind IS NULL AND old_row.active_ind IS NOT NULL
            THEN
                new_row.active_ind := old_row.active_ind;
            END IF;

            IF     new_row.assigned_field IS NULL
               AND old_row.assigned_field IS NOT NULL
            THEN
                new_row.assigned_field := old_row.assigned_field;
            END IF;

            IF     new_row.base_node_id IS NULL
               AND old_row.base_node_id IS NOT NULL
            THEN
                new_row.base_node_id := old_row.base_node_id;
            END IF;

            IF     new_row.bottom_hole_latitude IS NULL
               AND old_row.bottom_hole_latitude IS NOT NULL
            THEN
                new_row.bottom_hole_latitude := old_row.bottom_hole_latitude;
            END IF;

            IF     new_row.bottom_hole_longitude IS NULL
               AND old_row.bottom_hole_longitude IS NOT NULL
            THEN
                new_row.bottom_hole_longitude := old_row.bottom_hole_longitude;
            END IF;

            IF     new_row.casing_flange_elev IS NULL
               AND old_row.casing_flange_elev IS NOT NULL
            THEN
                new_row.casing_flange_elev := old_row.casing_flange_elev;
                new_row.casing_flange_elev_ouom :=
                                              old_row.casing_flange_elev_ouom;
            END IF;

            IF     new_row.completion_date IS NULL
               AND old_row.completion_date IS NOT NULL
            THEN
                new_row.completion_date := old_row.completion_date;
            END IF;

            IF     new_row.confidential_date IS NULL
               AND old_row.confidential_date IS NOT NULL
            THEN
                new_row.confidential_date := old_row.confidential_date;
            END IF;
            
            IF  new_row.confidential_depth IS NULL
               AND old_row.confidential_depth IS NOT NULL
            THEN
                new_row.confidential_depth := old_row.confidential_depth;
                new_row.confidential_depth_ouom :=
                                              old_row.confidential_depth_ouom;
            END IF;

            IF (new_row.confid_strat_name_set_id IS NULL
                AND old_row.confid_strat_name_set_id IS NOT NULL
               )
               AND
               (new_row.confid_strat_unit_id IS NULL
                AND old_row.confid_strat_unit_id IS NOT NULL
               )
            THEN new_row.confid_strat_name_set_id := old_row.confid_strat_name_set_id;
                new_row.confid_strat_unit_id := old_row.confid_strat_unit_id;
            END IF;

            IF     new_row.confidential_type IS NULL
               AND old_row.confidential_type IS NOT NULL
            THEN
                new_row.confidential_type := old_row.confidential_type;
            END IF;

            IF new_row.country IS NULL AND old_row.country IS NOT NULL
            THEN
                new_row.country := old_row.country;
            END IF;

            IF new_row.county IS NULL AND old_row.county IS NOT NULL
            THEN
                new_row.county := old_row.county;
            END IF;

            IF     new_row.current_class IS NULL
               AND old_row.current_class IS NOT NULL
            THEN
                new_row.current_class := old_row.current_class;
            END IF;

            IF     new_row.current_status IS NULL
               AND old_row.current_status IS NOT NULL
            THEN
                new_row.current_status := old_row.current_status;
            END IF;

            IF     new_row.current_status_date IS NULL
               AND old_row.current_status_date IS NOT NULL
            THEN
                new_row.current_status_date := old_row.current_status_date;
            END IF;

            IF     new_row.deepest_depth IS NULL
               AND old_row.deepest_depth IS NOT NULL
            THEN
                new_row.deepest_depth := old_row.deepest_depth;
                new_row.deepest_depth_ouom := old_row.deepest_depth_ouom;
            END IF;

            IF new_row.depth_datum IS NULL AND old_row.depth_datum IS NOT NULL
            THEN
                new_row.depth_datum := old_row.depth_datum;
            END IF;

            IF     new_row.depth_datum_elev IS NULL
               AND old_row.depth_datum_elev IS NOT NULL
            THEN
                new_row.depth_datum_elev := old_row.depth_datum_elev;
                new_row.depth_datum_elev_ouom :=
                                                old_row.depth_datum_elev_ouom;
            END IF;

            IF     new_row.derrick_floor_elev IS NULL
               AND old_row.derrick_floor_elev IS NOT NULL
            THEN
                new_row.derrick_floor_elev := old_row.derrick_floor_elev;
                new_row.derrick_floor_elev_ouom :=
                                              old_row.derrick_floor_elev_ouom;
            END IF;

            IF     new_row.difference_lat_msl IS NULL
               AND old_row.difference_lat_msl IS NOT NULL
            THEN
                new_row.difference_lat_msl := old_row.difference_lat_msl;
            END IF;

            IF     new_row.discovery_ind IS NULL
               AND old_row.discovery_ind IS NOT NULL
            THEN
                new_row.discovery_ind := old_row.discovery_ind;
            END IF;

            IF new_row.district IS NULL AND old_row.district IS NOT NULL
            THEN
                new_row.district := old_row.district;
            END IF;

            IF new_row.drill_td IS NULL AND old_row.drill_td IS NOT NULL
            THEN
                new_row.drill_td := old_row.drill_td;
                new_row.drill_td_ouom := old_row.drill_td_ouom;
            END IF;

            IF     new_row.effective_date IS NULL
               AND old_row.effective_date IS NOT NULL
            THEN
                new_row.effective_date := old_row.effective_date;
            END IF;

            IF     new_row.elev_ref_datum IS NULL
               AND old_row.elev_ref_datum IS NOT NULL
            THEN
                new_row.elev_ref_datum := old_row.elev_ref_datum;
            END IF;

            IF new_row.expiry_date IS NULL AND old_row.expiry_date IS NOT NULL
            THEN
                new_row.expiry_date := old_row.expiry_date;
            END IF;

            IF new_row.faulted_ind IS NULL AND old_row.faulted_ind IS NOT NULL
            THEN
                new_row.faulted_ind := old_row.faulted_ind;
            END IF;

            IF     new_row.final_drill_date IS NULL
               AND old_row.final_drill_date IS NOT NULL
            THEN
                new_row.final_drill_date := old_row.final_drill_date;
            END IF;

            IF new_row.final_td IS NULL AND old_row.final_td IS NOT NULL
            THEN
                new_row.final_td := old_row.final_td;
                new_row.final_td_ouom := old_row.final_td_ouom;
            END IF;

            IF     new_row.geographic_region IS NULL
               AND old_row.geographic_region IS NOT NULL
            THEN
                new_row.geographic_region := old_row.geographic_region;
            END IF;

            IF     new_row.geologic_province IS NULL
               AND old_row.geologic_province IS NOT NULL
            THEN
                new_row.geologic_province := old_row.geologic_province;
            END IF;

            IF new_row.ground_elev IS NULL AND old_row.ground_elev IS NOT NULL
            THEN
                new_row.ground_elev := old_row.ground_elev;
                new_row.ground_elev_ouom := old_row.ground_elev_ouom;
            END IF;

            IF     new_row.ground_elev_type IS NULL
               AND old_row.ground_elev_type IS NOT NULL
            THEN
                new_row.ground_elev_type := old_row.ground_elev_type;
            END IF;

            IF     new_row.initial_class IS NULL
               AND old_row.initial_class IS NOT NULL
            THEN
                new_row.initial_class := old_row.initial_class;
            END IF;

            IF new_row.kb_elev IS NULL AND old_row.kb_elev IS NOT NULL
            THEN
                new_row.kb_elev := old_row.kb_elev;
                new_row.kb_elev_ouom := old_row.kb_elev_ouom;
            END IF;

            IF new_row.lease_name IS NULL AND old_row.lease_name IS NOT NULL
            THEN
                new_row.lease_name := old_row.lease_name;
            END IF;

            IF new_row.lease_num IS NULL AND old_row.lease_num IS NOT NULL
            THEN
                new_row.lease_num := old_row.lease_num;
            END IF;

            IF     new_row.legal_survey_type IS NULL
               AND old_row.legal_survey_type IS NOT NULL
            THEN
                new_row.legal_survey_type := old_row.legal_survey_type;
            END IF;

            IF     new_row.location_type IS NULL
               AND old_row.location_type IS NOT NULL
            THEN
                new_row.location_type := old_row.location_type;
            END IF;

            IF new_row.log_td IS NULL AND old_row.log_td IS NOT NULL
            THEN
                new_row.log_td := old_row.log_td;
                new_row.log_td_ouom := old_row.log_td_ouom;
            END IF;

            IF new_row.max_tvd IS NULL AND old_row.max_tvd IS NOT NULL
            THEN
                new_row.max_tvd := old_row.max_tvd;
                new_row.max_tvd_ouom := old_row.max_tvd_ouom;
            END IF;

            IF new_row.net_pay IS NULL AND old_row.net_pay IS NOT NULL
            THEN
                new_row.net_pay := old_row.net_pay;
                new_row.net_pay_ouom := old_row.net_pay_ouom;
            END IF;

            IF     new_row.oldest_strat_name_set_age IS NULL
               AND old_row.oldest_strat_name_set_age IS NOT NULL
            THEN
                new_row.oldest_strat_name_set_age :=
                                            old_row.oldest_strat_name_set_age;
            END IF;

            IF     new_row.oldest_strat_age IS NULL
               AND old_row.oldest_strat_age IS NOT NULL
            THEN
                new_row.oldest_strat_age := old_row.oldest_strat_age;
            END IF;

            IF     (new_row.oldest_strat_name_set_id IS NULL
               AND old_row.oldest_strat_name_set_id IS NOT NULL)
            AND (new_row.oldest_strat_unit_id IS NULL
               AND old_row.oldest_strat_unit_id IS NOT NULL)
            THEN new_row.oldest_strat_name_set_id :=
                                             old_row.oldest_strat_name_set_id;
                new_row.oldest_strat_unit_id := old_row.oldest_strat_unit_id;
            END IF;

            IF new_row.OPERATOR IS NULL AND old_row.OPERATOR IS NOT NULL
            THEN
                new_row.OPERATOR := old_row.OPERATOR;
            END IF;

            IF     new_row.parent_relationship_type IS NULL
               AND old_row.parent_relationship_type IS NOT NULL
            THEN
                new_row.parent_relationship_type :=
                                             old_row.parent_relationship_type;
            END IF;

            IF new_row.parent_uwi IS NULL AND old_row.parent_uwi IS NOT NULL
            THEN
                new_row.parent_uwi := old_row.parent_uwi;
            END IF;

            IF new_row.platform_id IS NULL AND old_row.platform_id IS NOT NULL
            THEN
                new_row.platform_id := old_row.platform_id;
            END IF;

            IF     new_row.platform_sf_type IS NULL
               AND old_row.platform_sf_type IS NOT NULL
            THEN
                new_row.platform_sf_type := old_row.platform_sf_type;
            END IF;

            IF new_row.plot_name IS NULL AND old_row.plot_name IS NOT NULL
            THEN
                new_row.plot_name := old_row.plot_name;
            END IF;

            IF new_row.plot_symbol IS NULL AND old_row.plot_symbol IS NOT NULL
            THEN
                new_row.plot_symbol := old_row.plot_symbol;
            END IF;

            IF     new_row.plugback_depth IS NULL
               AND old_row.plugback_depth IS NOT NULL
            THEN
                new_row.plugback_depth := old_row.plugback_depth;
                new_row.plugback_depth_ouom := old_row.plugback_depth_ouom;
            END IF;

            IF new_row.ppdm_guid IS NULL AND old_row.ppdm_guid IS NOT NULL
            THEN
                new_row.ppdm_guid := old_row.ppdm_guid;
            END IF;

            IF     new_row.profile_type IS NULL
               AND old_row.profile_type IS NOT NULL
            THEN
                new_row.profile_type := old_row.profile_type;
            END IF;

            IF     new_row.province_state IS NULL
               AND old_row.province_state IS NOT NULL
            THEN
                new_row.province_state := old_row.province_state;
            END IF;

            IF     new_row.regulatory_agency IS NULL
               AND old_row.regulatory_agency IS NOT NULL
            THEN
                new_row.regulatory_agency := old_row.regulatory_agency;
            END IF;

            IF new_row.remark IS NULL AND old_row.remark IS NOT NULL
            THEN
                new_row.remark := old_row.remark;
            END IF;

            IF     new_row.rig_on_site_date IS NULL
               AND old_row.rig_on_site_date IS NOT NULL
            THEN
                new_row.rig_on_site_date := old_row.rig_on_site_date;
            END IF;

            IF     new_row.rig_release_date IS NULL
               AND old_row.rig_release_date IS NOT NULL
            THEN
                new_row.rig_release_date := old_row.rig_release_date;
            END IF;

            IF     new_row.rotary_table_elev IS NULL
               AND old_row.rotary_table_elev IS NOT NULL
            THEN
                new_row.rotary_table_elev := old_row.rotary_table_elev;
            END IF;

            IF     new_row.source_document IS NULL
               AND old_row.source_document IS NOT NULL
            THEN
                new_row.source_document := old_row.source_document;
            END IF;

            IF new_row.spud_date IS NULL AND old_row.spud_date IS NOT NULL
            THEN
                new_row.spud_date := old_row.spud_date;
            END IF;

            IF new_row.status_type IS NULL AND old_row.status_type IS NOT NULL
            THEN
                new_row.status_type := old_row.status_type;
            END IF;

            IF     new_row.subsea_elev_ref_type IS NULL
               AND old_row.subsea_elev_ref_type IS NOT NULL
            THEN
                new_row.subsea_elev_ref_type := old_row.subsea_elev_ref_type;
            END IF;

            IF     new_row.surface_latitude IS NULL
               AND old_row.surface_latitude IS NOT NULL
            THEN
                new_row.surface_latitude := old_row.surface_latitude;
            END IF;

            IF     new_row.surface_longitude IS NULL
               AND old_row.surface_longitude IS NOT NULL
            THEN
                new_row.surface_longitude := old_row.surface_longitude;
            END IF;

            IF     new_row.surface_node_id IS NULL
               AND old_row.surface_node_id IS NOT NULL
            THEN
                new_row.surface_node_id := old_row.surface_node_id;
            END IF;

            IF     new_row.tax_credit_code IS NULL
               AND old_row.tax_credit_code IS NOT NULL
            THEN
                new_row.tax_credit_code := old_row.tax_credit_code;
            END IF;

            IF     (new_row.td_strat_name_set_age IS NULL
               AND old_row.td_strat_name_set_age IS NOT NULL)
            AND
            (new_row.td_strat_age IS NULL
               AND old_row.td_strat_age IS NOT NULL)
            THEN new_row.td_strat_name_set_age :=
                                                old_row.td_strat_name_set_age;
                new_row.td_strat_age := old_row.td_strat_age;
            END IF;

            IF     (new_row.td_strat_name_set_id IS NULL
               AND old_row.td_strat_name_set_id IS NOT NULL)
            AND
             (new_row.td_strat_unit_id IS NULL
               AND old_row.td_strat_unit_id IS NOT NULL)
            THEN new_row.td_strat_name_set_id := old_row.td_strat_name_set_id;
                new_row.td_strat_unit_id := old_row.td_strat_unit_id;
            END IF;

            IF     new_row.water_acoustic_vel IS NULL
               AND old_row.water_acoustic_vel IS NOT NULL
            THEN
                new_row.water_acoustic_vel := old_row.water_acoustic_vel;
                new_row.water_acoustic_vel_ouom :=
                                              old_row.water_acoustic_vel_ouom;
            END IF;

            IF new_row.water_depth IS NULL AND old_row.water_depth IS NOT NULL
            THEN
                new_row.water_depth := old_row.water_depth;
                new_row.water_depth_ouom := old_row.water_depth_ouom;
            END IF;

            IF     new_row.well_government_id IS NULL
               AND old_row.well_government_id IS NOT NULL
            THEN
                new_row.well_government_id := old_row.well_government_id;
            END IF;

            IF     new_row.well_intersect_md IS NULL
               AND old_row.well_intersect_md IS NOT NULL
            THEN
                new_row.well_intersect_md := old_row.well_intersect_md;
            END IF;

            IF new_row.well_name IS NULL AND old_row.well_name IS NOT NULL
            THEN
                new_row.well_name := old_row.well_name;
            END IF;

            IF new_row.well_num IS NULL AND old_row.well_num IS NOT NULL
            THEN
                new_row.well_num := old_row.well_num;
            END IF;

            IF     new_row.well_numeric_id IS NULL
               AND old_row.well_numeric_id IS NOT NULL
            THEN
                new_row.well_numeric_id := old_row.well_numeric_id;
            END IF;

            IF     new_row.whipstock_depth IS NULL
               AND old_row.whipstock_depth IS NOT NULL
            THEN
                new_row.whipstock_depth := old_row.whipstock_depth;
            END IF;

            IF     new_row.whipstock_depth_ouom IS NULL
               AND old_row.whipstock_depth_ouom IS NOT NULL
            THEN
                new_row.whipstock_depth_ouom := old_row.whipstock_depth_ouom;
            END IF;

            IF     new_row.ipl_licensee IS NULL
               AND old_row.ipl_licensee IS NOT NULL
            THEN
                new_row.ipl_licensee := old_row.ipl_licensee;
            END IF;

            IF     new_row.well_event_num IS NULL
               AND old_row.well_event_num IS NOT NULL
            THEN
                new_row.well_event_num := old_row.well_event_num;
            END IF;

            IF     new_row.ipl_offshore_ind IS NULL
               AND old_row.ipl_offshore_ind IS NOT NULL
            THEN
                new_row.ipl_offshore_ind := old_row.ipl_offshore_ind;
            END IF;

            IF     new_row.ipl_pidstatus IS NULL
               AND old_row.ipl_pidstatus IS NOT NULL
            THEN
                new_row.ipl_pidstatus := old_row.ipl_pidstatus;
            END IF;

            IF     new_row.ipl_prstatus IS NULL
               AND old_row.ipl_prstatus IS NOT NULL
            THEN
                new_row.ipl_prstatus := old_row.ipl_prstatus;
            END IF;

            IF     new_row.ipl_orstatus IS NULL
               AND old_row.ipl_orstatus IS NOT NULL
            THEN
                new_row.ipl_orstatus := old_row.ipl_orstatus;
            END IF;

            IF     new_row.ipl_onprod_date IS NULL
               AND old_row.ipl_onprod_date IS NOT NULL
            THEN
                new_row.ipl_onprod_date := old_row.ipl_onprod_date;
            END IF;

            IF     new_row.ipl_oninject_date IS NULL
               AND old_row.ipl_oninject_date IS NOT NULL
            THEN
                new_row.ipl_oninject_date := old_row.ipl_oninject_date;
            END IF;

            IF     new_row.ipl_confidential_strat_age IS NULL
               AND old_row.ipl_confidential_strat_age IS NOT NULL
            THEN
                new_row.ipl_confidential_strat_age :=
                                           old_row.ipl_confidential_strat_age;
            END IF;

            IF new_row.ipl_pool IS NULL AND old_row.ipl_pool IS NOT NULL
            THEN
                new_row.ipl_pool := old_row.ipl_pool;
            END IF;

            IF     new_row.ipl_last_update IS NULL
               AND old_row.ipl_last_update IS NOT NULL
            THEN
                new_row.ipl_last_update := old_row.ipl_last_update;
            END IF;

            IF     new_row.ipl_uwi_sort IS NULL
               AND old_row.ipl_uwi_sort IS NOT NULL
            THEN
                new_row.ipl_uwi_sort := old_row.ipl_uwi_sort;
            END IF;

            IF     new_row.ipl_uwi_display IS NULL
               AND old_row.ipl_uwi_display IS NOT NULL
            THEN
                new_row.ipl_uwi_display := old_row.ipl_uwi_display;
            END IF;

            IF new_row.ipl_td_tvd IS NULL AND old_row.ipl_td_tvd IS NOT NULL
            THEN
                new_row.ipl_td_tvd := old_row.ipl_td_tvd;
            END IF;

            IF     new_row.ipl_plugback_tvd IS NULL
               AND old_row.ipl_plugback_tvd IS NOT NULL
            THEN
                new_row.ipl_plugback_tvd := old_row.ipl_plugback_tvd;
            END IF;

            IF     new_row.ipl_whipstock_tvd IS NULL
               AND old_row.ipl_whipstock_tvd IS NOT NULL
            THEN
                new_row.ipl_whipstock_tvd := old_row.ipl_whipstock_tvd;
            END IF;

            IF     new_row.ipl_water_tvd IS NULL
               AND old_row.ipl_water_tvd IS NOT NULL
            THEN
                new_row.ipl_water_tvd := old_row.ipl_water_tvd;
            END IF;

            IF     new_row.ipl_alt_source IS NULL
               AND old_row.ipl_alt_source IS NOT NULL
            THEN
                new_row.ipl_alt_source := old_row.ipl_alt_source;
            END IF;

            IF     new_row.ipl_xaction_code IS NULL
               AND old_row.ipl_xaction_code IS NOT NULL
            THEN
                new_row.ipl_xaction_code := old_row.ipl_xaction_code;
            END IF;

           --  Always capture the LATEST update date regardless of the precedence
            IF new_row.row_changed_date is NULL
               OR new_row.row_changed_date < old_row.row_changed_date
            THEN
                new_row.row_changed_date := old_row.row_changed_date;
                new_row.row_changed_by := old_row.row_changed_by;
            END IF;

           --  Always capture the EARLIEST creation date regardless of the precedence
            IF new_row.row_created_date IS NULL
               OR new_row.row_created_date > old_row.row_created_date
            THEN
                new_row.row_created_date := old_row.row_created_date;
                new_row.row_created_by := old_row.row_created_by;
            END IF;

            IF new_row.ipl_basin IS NULL AND old_row.ipl_basin IS NOT NULL
            THEN
                new_row.ipl_basin := old_row.ipl_basin;
            END IF;

            IF new_row.ipl_block IS NULL AND old_row.ipl_block IS NOT NULL
            THEN
                new_row.ipl_block := old_row.ipl_block;
            END IF;

            IF new_row.ipl_area IS NULL AND old_row.ipl_area IS NOT NULL
            THEN
                new_row.ipl_area := old_row.ipl_area;
            END IF;

            IF new_row.ipl_twp IS NULL AND old_row.ipl_twp IS NOT NULL
            THEN
                new_row.ipl_twp := old_row.ipl_twp;
            END IF;

            IF new_row.ipl_tract IS NULL AND old_row.ipl_tract IS NOT NULL
            THEN
                new_row.ipl_tract := old_row.ipl_tract;
            END IF;

            IF new_row.ipl_lot IS NULL AND old_row.ipl_lot IS NOT NULL
            THEN
                new_row.ipl_lot := old_row.ipl_lot;
            END IF;

            IF new_row.ipl_conc IS NULL AND old_row.ipl_conc IS NOT NULL
            THEN
                new_row.ipl_conc := old_row.ipl_conc;
            END IF;

            IF     new_row.ipl_uwi_local IS NULL
               AND old_row.ipl_uwi_local IS NOT NULL
            THEN
                new_row.ipl_uwi_local := old_row.ipl_uwi_local;
            END IF;

            IF new_row.row_quality IS NULL AND old_row.row_quality IS NOT NULL
            THEN
                new_row.row_quality := old_row.row_quality;
            END IF;
        END LOOP;

        --  Attributes have been rolled up into the new record
        IF new_row.uwi IS NOT NULL
        THEN

            -- Save the new composite well to the WELL table
           merge_well (new_row);

--dbms_output.put_line('Well version Rollup - Versions Merged');


        ELSE
        
--dbms_output.put_line('Well version Rollup - WELL record deleted');


           --  No active versions found for this well, so remove the composite if there is one
           SELECT COUNT(1) INTO Row_Count
             FROM PPDM.WELL
            WHERE UWI = Input_UWI; 
           
           IF Row_Count != 0 THEN
             DELETE FROM PPDM.WELL
              WHERE UWI = Input_UWI; 
            
             PPDM.TLM_Process_Logger.INFO ('The Well ' || Input_UWI || ' has no active versions left. Composite well removed.');

           END IF;
           
        END IF;
        
        
    EXCEPTION
        WHEN OTHERS
        THEN
            ppdm.tlm_process_logger.sqlerror ('WIM_Rollup.Well_Version_Rollup: Exception during roll up of well '
                                          || new_row.uwi || '(' || new_row.source || ')');
            RAISE;
    END Well_Version_Rollup;


    PROCEDURE node_rollup (input_TLM_ID        IN VARCHAR2,
                           input_node_id       IN VARCHAR2,
                           input_node_position IN VARCHAR2)
    IS
            -- Build a well_node row that accumulates all information from
            -- well_node_version rows.
            -- Note that this procedure requires that:
            --  1) The correct value for the uwi is in the ipl_uwi column
            --
            -- The order of rows returned by the cursor Node_list defined below
            -- establishes priority with which non-null values are accumulated.
            -- The first non-null encountered while processing the cursor's result
            -- set establishes the value for a column in the resulting WELL_NODE
            -- row.
            --
            --  NOTE: 1. The source precedence order for nodes is not the same as
            --           the precedence order for wells
            --        2. Only active versions are rolled up. Well Data Steward confirmed
            --           there is no need to retaim an inactive composite so it will be
            --           removed if there are no versions or they are all inactive.

            -- WARNING: this code uses a WELL_NODE table which has the same (or
            --          almost the same) columns as WELL_NODE_VERSION. Changes will be
            --          required when we migrate to a WELL_NODE table which is more
            --          compatible with the PPDM 3.7.1 column set.
            
        new_row            ppdm.well_node_version%ROWTYPE;
        Row_Count          NUMBER;

        -- Lists the nodes in source precedence order
        CURSOR Node_list
        IS
            SELECT   *
                FROM ppdm.well_node_version
               WHERE node_id = input_node_id
                 AND Node_Position = input_node_position
                 AND active_ind = 'Y'
                 AND SOURCE IN
                         ('075TLMO',
                          '100TLM',
                          '150TLMX',
                          '200TLI',
                          '300IPL',
                          '400FNDR',
                          '450PID',
                          '500PRB',
                          '600TLMD',
                          '650TLMC',
                          '700TLME',
                          '800TLMP',
                          '850TLML')
            ORDER BY node_id,
                     DECODE (SOURCE,
                             '075TLMO', 1,
                             '150TLMX', 2,
                             '200TLI', 3,
                             '300IPL', 4,
                             '100TLM', 5,
                             '400FNDR', 6,
                             '450PID', 7,
                             '500PRB', 8,
                             '600TLMD', 9,
                             '650TLMC', 10,
                             '700TLME', 11,
                             '800TLMP', 12,
                             '850TLML', 13,
                             99
                            ),
                     Geog_Coord_System_ID DESC, -- IHS27, IHS83, NAD27, NAD83, WGS84, ...
                     Location_Qualifier,
                     Node_Obs_No DESC;
                     
        

    
    BEGIN
    
--dbms_output.put_line('Node Rollup: Well: ' || input_TLM_id|| ', Node: ' || input_node_id|| ',' || input_node_position);

        -- Clear the new row ready to roll up into
        null_node_row (new_row);

        --  Take each of the node versions, HIGHEST precedence first and apply to the new row
        FOR old_row IN Node_list
        LOOP
        
--dbms_output.put_line('Node Rollup.Node Merging node: ' || old_row.Node_ID || ',' || old_row.Source ||','|| old_row.ipl_uwi || ',' || old_row.Node_Position);

            -- for each column, accumulate the highest priority non-null value
            IF new_row.node_id IS NULL AND old_row.node_id IS NOT NULL
            THEN
                new_row.node_id := old_row.node_id;
            END IF;

            IF     new_row.SOURCE IS NULL
               AND old_row.SOURCE IS NOT NULL
            THEN
                new_row.SOURCE := old_row.SOURCE;
            END IF;

            IF new_row.node_obs_no IS NULL AND old_row.node_obs_no IS NOT NULL
            THEN
                new_row.node_obs_no := old_row.node_obs_no;
            END IF;

            IF     new_row.acquisition_id IS NULL
               AND old_row.acquisition_id IS NOT NULL
            THEN
                new_row.acquisition_id := old_row.acquisition_id;
            END IF;

            IF new_row.active_ind IS NULL AND old_row.active_ind IS NOT NULL
            THEN
                new_row.active_ind := old_row.active_ind;
            END IF;

            IF new_row.country IS NULL AND old_row.country IS NOT NULL
            THEN
                new_row.country := old_row.country;
            END IF;

            IF new_row.county IS NULL AND old_row.county IS NOT NULL
            THEN
                new_row.county := old_row.county;
            END IF;

            IF new_row.easting IS NULL AND old_row.easting IS NOT NULL
            THEN
                new_row.easting := old_row.easting;
                new_row.easting_ouom := old_row.easting_ouom;
            END IF;

            IF     new_row.effective_date IS NULL
               AND old_row.effective_date IS NOT NULL
            THEN
                new_row.effective_date := old_row.effective_date;
            END IF;

            IF new_row.elev IS NULL AND old_row.elev IS NOT NULL
            THEN
                new_row.elev := old_row.elev;
                new_row.elev_ouom := old_row.elev_ouom;
            END IF;

            IF     new_row.ew_direction IS NULL
               AND old_row.ew_direction IS NOT NULL
            THEN
                new_row.ew_direction := old_row.ew_direction;
            END IF;

            IF new_row.expiry_date IS NULL AND old_row.expiry_date IS NOT NULL
            THEN
                new_row.expiry_date := old_row.expiry_date;
            END IF;

            IF     new_row.geog_coord_system_id IS NULL
               AND old_row.geog_coord_system_id IS NOT NULL
            THEN
                new_row.geog_coord_system_id := old_row.geog_coord_system_id;
            END IF;

            IF new_row.latitude IS NULL AND old_row.latitude IS NOT NULL
            THEN
                new_row.latitude := old_row.latitude;
            END IF;

            IF     new_row.legal_survey_type IS NULL
               AND old_row.legal_survey_type IS NOT NULL
            THEN
                new_row.legal_survey_type := old_row.legal_survey_type;
            END IF;

            IF     new_row.location_qualifier IS NULL
               AND old_row.location_qualifier IS NOT NULL
            THEN
                new_row.location_qualifier := old_row.location_qualifier;
            END IF;

            IF     new_row.location_quality IS NULL
               AND old_row.location_quality IS NOT NULL
            THEN
                new_row.location_quality := old_row.location_quality;
            END IF;

            IF new_row.longitude IS NULL AND old_row.longitude IS NOT NULL
            THEN
                new_row.longitude := old_row.longitude;
            END IF;

            IF     new_row.map_coord_system_id IS NULL
               AND old_row.map_coord_system_id IS NOT NULL
            THEN
                new_row.map_coord_system_id := old_row.map_coord_system_id;
            END IF;

            IF new_row.md IS NULL AND old_row.md IS NOT NULL
            THEN
                new_row.md := old_row.md;
                new_row.md_ouom := old_row.md_ouom;
            END IF;

            IF new_row.monument_id IS NULL AND old_row.monument_id IS NOT NULL
            THEN
                new_row.monument_id := old_row.monument_id;
            END IF;

            IF     new_row.monument_sf_type IS NULL
               AND old_row.monument_sf_type IS NOT NULL
            THEN
                new_row.monument_sf_type := old_row.monument_sf_type;
            END IF;

            IF     new_row.node_position IS NULL
               AND old_row.node_position IS NOT NULL
            THEN
                new_row.node_position := old_row.node_position;
            END IF;

            IF new_row.northing IS NULL AND old_row.northing IS NOT NULL
            THEN
                new_row.northing := old_row.northing;
                new_row.northing_ouom := old_row.northing_ouom;
            END IF;

            IF new_row.north_type IS NULL AND old_row.north_type IS NOT NULL
            THEN
                new_row.north_type := old_row.north_type;
            END IF;

            IF     new_row.ns_direction IS NULL
               AND old_row.ns_direction IS NOT NULL
            THEN
                new_row.ns_direction := old_row.ns_direction;
            END IF;

            IF     new_row.polar_azimuth IS NULL
               AND old_row.polar_azimuth IS NOT NULL
            THEN
                new_row.polar_azimuth := old_row.polar_azimuth;
            END IF;

            IF     new_row.polar_offset IS NULL
               AND old_row.polar_offset IS NOT NULL
            THEN
                new_row.polar_offset := old_row.polar_offset;
                new_row.polar_offset_ouom := old_row.polar_offset_ouom;
            END IF;

            IF new_row.ppdm_guid IS NULL AND old_row.ppdm_guid IS NOT NULL
            THEN
                new_row.ppdm_guid := old_row.ppdm_guid;
            END IF;

            IF     new_row.preferred_ind IS NULL
               AND old_row.preferred_ind IS NOT NULL
            THEN
                new_row.preferred_ind := old_row.preferred_ind;
            END IF;

            IF     new_row.province_state IS NULL
               AND old_row.province_state IS NOT NULL
            THEN
                new_row.province_state := old_row.province_state;
            END IF;

            IF new_row.remark IS NULL AND old_row.remark IS NOT NULL
            THEN
                new_row.remark := old_row.remark;
            END IF;

            IF     new_row.reported_tvd IS NULL
               AND old_row.reported_tvd IS NOT NULL
            THEN
                new_row.reported_tvd := old_row.reported_tvd;
                new_row.reported_tvd_ouom := old_row.reported_tvd_ouom;
            END IF;

            IF     new_row.version_type IS NULL
               AND old_row.version_type IS NOT NULL
            THEN
                new_row.version_type := old_row.version_type;
            END IF;

            IF new_row.x_offset IS NULL AND old_row.x_offset IS NOT NULL
            THEN
                new_row.x_offset := old_row.x_offset;
                new_row.x_offset_ouom := old_row.x_offset_ouom;
            END IF;

            IF new_row.y_offset IS NULL AND old_row.y_offset IS NOT NULL
            THEN
                new_row.y_offset := old_row.y_offset;
                new_row.y_offset_ouom := old_row.y_offset_ouom;
            END IF;

            IF     new_row.ipl_xaction_code IS NULL
               AND old_row.ipl_xaction_code IS NOT NULL
            THEN
                new_row.ipl_xaction_code := old_row.ipl_xaction_code;
            END IF;

           --  Always capture the LATEST update date regardless of the precedence
            IF new_row.row_changed_date is NULL
               OR new_row.row_changed_date < old_row.row_changed_date
            THEN
                new_row.row_changed_date := old_row.row_changed_date;
                new_row.row_changed_by := old_row.row_changed_by;
            END IF;

           --  Always capture the EARLIEST creation date regardless of the precedence
            IF new_row.row_created_date IS NULL
               OR new_row.row_created_date > old_row.row_created_date
            THEN
                new_row.row_created_date := old_row.row_created_date;
                new_row.row_created_by := old_row.row_created_by;
            END IF;

            IF new_row.ipl_uwi IS NULL AND old_row.ipl_uwi IS NOT NULL
            THEN
                new_row.ipl_uwi := old_row.ipl_uwi;
            END IF;

            IF new_row.row_quality IS NULL AND old_row.row_quality IS NOT NULL
            THEN
                new_row.row_quality := old_row.row_quality;
            END IF;

        END LOOP;

         --  Attribute roll up complete
         --  If node versions were found and rolled up then update the composite
        IF new_row.node_id IS NOT NULL THEN
         
--dbms_output.put_line('Merge the row: ' || new_row.Node_ID || ',' || new_row.Source ||','|| new_row.ipl_uwi || ',' || new_row.Node_Position);

           -- At least one version rolled up, so save the composite node
           merge_node (new_row);

        ELSE

--dbms_output.put_line('Well node deleted');
 
           --  No versions found for this node, so remove the composite node if there is one
           SELECT COUNT(1) INTO Row_Count
             FROM PPDM.WELL_NODE
            WHERE Node_ID = Input_Node_ID
              AND Node_Position = Input_Node_Position;
           
           IF Row_Count != 0 THEN
             DELETE FROM PPDM.WELL_NODE
              WHERE Node_ID = Input_Node_ID
                AND Node_Position = Input_Node_Position; 

             PPDM.TLM_Process_Logger.INFO ('The Node ' || Input_Node_ID || ' has no active versions left. Composite node removed.');
           END IF;
        
        END IF;        
         
        --  Apply any changes to the composite WELL table        
        --  NOTE: If no nodes were found then this will reset the location
        --        information in the WELL table to NULL
         IF input_node_position = 'B'
           THEN

--dbms_output.put_line('Update BASE node');              

                --  Update WELL table with the highest precedence location 
                UPDATE ppdm.well
                   SET bottom_hole_latitude = new_row.latitude,
                       bottom_hole_longitude = new_row.longitude,
                       base_node_id = new_row.node_id
                 WHERE uwi = Input_TLM_ID;
         ELSIF input_node_position = 'S'
              THEN

--dbms_output.put_line('Update SURFACE node');              

                UPDATE ppdm.well
                   SET surface_latitude = new_row.latitude,
                       surface_longitude = new_row.longitude,
                       surface_node_id = new_row.node_id
                 WHERE uwi = Input_TLM_ID;
         END IF;
         
         -- Apply the location changes to the WELL_VERSION table for each source
         FOR Node_Source IN (SELECT SOURCE
                               FROM PPDM.Well_Version
                              WHERE uwi = Input_TLM_ID
                                AND Active_IND = 'Y'
                            ) 
          LOOP
            Update_WV_Location (pTLM_ID   => Input_TLM_ID,
                                pSource   => Node_source.Source,
                                pPosition => Input_Node_Position);
          END LOOP;

    EXCEPTION
        WHEN OTHERS
        THEN
            ppdm.tlm_process_logger.sqlerror ('WIM_Rollup.Node_Rollup: Exception during roll up of node '
                                               || new_row.node_id || '(' || new_row.source || ')');
            RAISE;
    END Node_Rollup;


    PROCEDURE Source_Rollup (input_source IN VARCHAR2)
    IS
        -- Rollup all the WELLs for the given source. Finds any wells that have
        -- a version from the specified source and rolls up those wells.
	    Source_Wells_Total BINARY_INTEGER;
        Rolled_Up_Wells    BINARY_INTEGER := 0;
        Commit_Period      BINARY_INTEGER := 1000;
        Next_Commit        BINARY_INTEGER := Commit_Period;

        CURSOR Source_Wells
        IS
            SELECT uwi
              FROM ppdm.well_version
             WHERE SOURCE = input_source;

    BEGIN

        -- Find out how many wells there will be to roll up
        SELECT COUNT(UWI) INTO Source_Wells_Total
          FROM ppdm.well_version
             WHERE SOURCE = input_source;

        ppdm.tlm_process_logger.info ('WIM_Rollup.Source_Rollup: Start Rollup for '
                                      || TO_CHAR (Source_Wells_Total) || ' "' || input_source || '" wells.'
                                     );
        --  Roll up each well on by one, committing periodically to minimise locking
        FOR Next_Well IN Source_Wells
        LOOP
            WIM_Rollup.Well_Version_Rollup (Next_Well.uwi);
            Rolled_Up_Wells := Rolled_Up_Wells + 1;
            IF Rolled_Up_Wells = Next_Commit THEN
		        COMMIT;
                Next_Commit := Next_Commit + Commit_Period;
                ppdm.tlm_process_logger.info ('WIM_Rollup.Source_Rollup: Roll up progress: '
                                              || TO_CHAR(ROUND(Rolled_Up_Wells/Source_Wells_Total*100)) || '% complete: '
                                              || TO_CHAR (Rolled_Up_Wells) || ' out of ' || TO_CHAR (Source_Wells_Total)
                                              || ' "' || input_source || '" wells.'
                                             );
            END IF;
        END LOOP;

        COMMIT;
        ppdm.tlm_process_logger.info ('WIM_Rollup.Source_Rollup: Rollup Complete. Rolled up '
                                      || TO_CHAR (Rolled_Up_Wells) || ' "' || input_source || '" wells.'
                                     );
    END Source_Rollup;

    PROCEDURE Well_Rollup (input_uwi IN VARCHAR2)
    IS
        -- Rollup the WELL, including the WELL_NODE rows for the specified well.
        -- Find the well nodes by using the node_id convention - ensures new nodes
        -- are included

    BEGIN

        --  Rollup the well first
        Well_Version_Rollup (Input_UWI);

        -- Rollup the Surface Location
        WIM_Rollup.Node_Rollup (Input_UWI, Input_UWI || '1', 'S');

       -- Rollup the Base Location
        WIM_Rollup.Node_Rollup (Input_UWI, Input_UWI || '0', 'B');

    END Well_Rollup;

END WIM_Rollup;
/
