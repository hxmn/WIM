  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."IPL_WELLS_CHANGES_VW" ("BASE_NODE_ID") AS 
  SELECT base_node_id
      FROM (SELECT base_node_id,
                   abandonment_date,
                   active_ind,
                   assigned_field,
                   casing_flange_elev,
                   casing_flange_elev_ouom,
                   completion_date,
                   confidential_date,
                   confidential_depth,
                   confidential_depth_ouom,
                   confidential_type,
                   confid_strat_name_set_id,
                   confid_strat_unit_id,
                   country,
                   county,
                   current_class,
                   current_status,
                   current_status_date,
                   deepest_depth,
                   deepest_depth_ouom,
                   depth_datum,
                   depth_datum_elev,
                   depth_datum_elev_ouom,
                   derrick_floor_elev,
                   derrick_floor_elev_ouom,
                   difference_lat_msl,
                   discovery_ind,
                   district,
                   drill_td,
                   drill_td_ouom,
                   effective_date,
                   elev_ref_datum,
                   expiry_date,
                   faulted_ind,
                   final_drill_date,
                   final_td,
                   final_td_ouom,
                   geographic_region,
                   geologic_province,
                   ground_elev,
                   ground_elev_ouom,
                   ground_elev_type,
                   initial_class,
                   kb_elev,
                   kb_elev_ouom,
                   lease_name,
                   lease_num,
                   legal_survey_type,
                   location_type,
                   log_td,
                   log_td_ouom,
                   max_tvd,

                   max_tvd_ouom,
                   net_pay,

                   net_pay_ouom,
                   CAST (oldest_strat_age AS VARCHAR (20)),
                   oldest_strat_name_set_age,
                   oldest_strat_name_set_id,
                   oldest_strat_unit_id,
                   OPERATOR,
                   parent_relationship_type,
                   parent_uwi,
                   platform_id,
                   platform_sf_type,
                   plot_name,
                   plot_symbol,
                   plugback_depth,
                   plugback_depth_ouom,
                   ppdm_guid,
                   profile_type,
                   province_state,
                   regulatory_agency,
                   remark,
                   rig_on_site_date,
                   rig_release_date,
                   rotary_table_elev,
                   source_document,
                   spud_date,
                   status_type,
                   subsea_elev_ref_type,
                   tax_credit_code,
                   CAST (td_strat_age AS VARCHAR (20)),
                   td_strat_name_set_age,
                   td_strat_name_set_id,
                   td_strat_unit_id,
                   water_acoustic_vel,
                   water_acoustic_vel_ouom,
                   water_depth,
                   water_depth_datum,
                   water_depth_ouom,
                   well_event_num,
                   well_government_id,
                   well_intersect_md,
                   well_name,
                   well_numeric_id,
                   whipstock_depth,
                   whipstock_depth_ouom,
                   ipl_licensee AS ipl_licensee,
                   case
                      when ipl_offshore_ind = 'Y' then 'OFFSHORE'
                      when ipl_offshore_ind = 'N' then 'ONSHORE'
                      else null
                   end as ipl_offshore_ind,
                   ipl_prstatus AS ipl_prstatus,
                   ipl_orstatus AS ipl_orstatus,
                   ipl_onprod_date AS ipl_onprod_date,
                   ipl_oninject_date AS ipl_oninject_date,
                   CAST (ipl_confidential_strat_age AS VARCHAR (12))
                      AS ipl_confidential_strat_age,
                   ipl_pool AS ipl_pool,
                   -- QC#1650
--                   ipl_uwi_sort AS ipl_uwi_sort,
--                   ipl_uwi_display AS ipl_uwi_display,
                   ipl_td_tvd AS ipl_td_tvd,
                   ipl_plugback_tvd AS ipl_plugback_tvd,
                   ipl_whipstock_tvd AS ipl_whipstock_tvd,
                   row_changed_date,
                   row_created_date
              FROM ipl_wells_stg_vw
             WHERE source = 'IHSE' AND active_ind = 'Y'
            --and ( trunc(row_changed_date) > to_date('2012-03-01','yyyy-mm-dd') or
            --      trunc(row_created_date) > to_date('2012-03-01','yyyy-mm-dd') )
            MINUS

            SELECT well_num,
                   abandonment_date,
                   active_ind,
                   assigned_field,
                   casing_flange_elev,
                   casing_flange_elev_ouom,
                   completion_date,
                   confidential_date,
                   confidential_depth,
                   confidential_depth_ouom,
                   confidential_type,
                   confid_strat_name_set_id,
                   confid_strat_unit_id,
                   country,
                   county,
                   current_class,
                   current_status,
                   current_status_date,
                   deepest_depth,
                   deepest_depth_ouom,
                   depth_datum,
                   depth_datum_elev,
                   depth_datum_elev_ouom,
                   derrick_floor_elev,
                   derrick_floor_elev_ouom,
                   difference_lat_msl,
                   discovery_ind,
                   district,
                   drill_td,
                   drill_td_ouom,
                   effective_date,
                   elev_ref_datum,
                   expiry_date,
                   faulted_ind,
                   final_drill_date,
                   final_td,
                   final_td_ouom,
                   geographic_region,
                   geologic_province,
                   ground_elev,
                   ground_elev_ouom,
                   ground_elev_type,
                   initial_class,
                   kb_elev,
                   kb_elev_ouom,
                   lease_name,
                   lease_num,
                   legal_survey_type,
                   location_type,
                   log_td,
                   log_td_ouom,
                   max_tvd,
                   max_tvd_ouom,
                   net_pay,
                   net_pay_ouom,
                   oldest_strat_age,
                   oldest_strat_name_set_age,
                   oldest_strat_name_set_id,
                   oldest_strat_unit_id,
                   OPERATOR,
                   parent_relationship_type,
                   parent_uwi,
                   platform_id,
                   platform_sf_type,
                   plot_name,
                   plot_symbol,
                   plugback_depth,
                   plugback_depth_ouom,
                   ppdm_guid,
                   profile_type,
                   province_state,
                   regulatory_agency,
                   remark,
                   rig_on_site_date,
                   rig_release_date,
                   rotary_table_elev,
                   source_document,
                   spud_date,
                   status_type,
                   subsea_elev_ref_type,
                   tax_credit_code,
                   td_strat_age,
                   td_strat_name_set_age,
                   td_strat_name_set_id,
                   td_strat_unit_id,
                   water_acoustic_vel,
                   water_acoustic_vel_ouom,
                   water_depth,
                   water_depth_datum,
                   water_depth_ouom,
                   well_event_num,
                   well_government_id,
                   well_intersect_md,
                   well_name,
                   well_numeric_id,
                   whipstock_depth,
                   whipstock_depth_ouom,
                   ipl_licensee,
                   ipl_offshore_ind,
                   ipl_prstatus,
                   ipl_orstatus,
                   ipl_onprod_date,
                   ipl_oninject_date,
                   ipl_confidential_strat_age,
                   ipl_pool,
                   -- QC#1650
--                   ipl_uwi_sort,
--                   ipl_uwi_display,
                   ipl_td_tvd,
                   ipl_plugback_tvd,
                   ipl_whipstock_tvd,
                   row_changed_date,
                   row_created_date
              FROM well_version
             WHERE SOURCE = '300IPL' AND active_ind = 'Y' --and ( trunc(row_changed_date) > to_date('2012-03-01','yyyy-mm-dd') or
                                                         --trunc(row_created_date) > to_date('2012-03-01','yyyy-mm-dd') )
           )

    UNION
    SELECT base_node_id
      FROM ( ( -- This is for al Base nodes where surface_node_Id = base_node_id
              SELECT w.base_node_id,
                     wnv.node_obs_no,
                     node_position,
                     wnv.geog_coord_system_id,
                     wnv.location_qualifier,
                     wnv.latitude,
                     wnv.longitude,
                     wnv.row_changed_date,
                     wnv.row_created_date
                FROM ipl_wells_stg_vw w, ipl_well_node_stg_vw wnv
               WHERE w.uwi = wnv.uwi AND w.base_node_id = w.surface_node_id
              UNION

              -- This is for all Surface nodes where surface_node_Id = base_node_id, IHS only has the base nodes, in this case
              -- copying Base Nodes and replacing Node_Position = 'S'
              SELECT w.base_node_id,
                     wnv.node_obs_no,
                     'S',

                     wnv.geog_coord_system_id,
                     wnv.location_qualifier,
                     wnv.latitude,
                     wnv.longitude,
                     wnv.row_changed_date,
                     wnv.row_created_date
                FROM ipl_wells_stg_vw w, ipl_well_node_stg_vw wnv
               WHERE w.uwi = wnv.uwi AND w.base_node_id = w.surface_node_id
              UNION

              --This of for rest of the nodes where Base_Node_Id <> Surface_Node_Id
              SELECT w.base_node_id,
                     wnv.node_obs_no,
                     node_position,
                     wnv.geog_coord_system_id,
                     wnv.location_qualifier,
                     wnv.latitude,
                     wnv.longitude,
                     wnv.row_changed_date,
                     wnv.row_created_date
                FROM ipl_wells_stg_vw w, ipl_well_node_stg_vw wnv
               WHERE w.uwi = wnv.uwi AND base_node_id <> surface_node_id)
            MINUS

            SELECT wv.well_num,
                   wnv.node_obs_no,
                   wnv.node_position,
                   wnv.geog_coord_system_id,
                   wnv.location_qualifier,
                   wnv.latitude,
                   wnv.longitude,
                   wnv.row_changed_date,
                   wnv.row_created_date
              FROM well_version wv, well_node_version wnv
             WHERE     wv.uwi = wnv.ipl_uwi
                   AND wv.SOURCE = '300IPL'
                   AND wv.SOURCE = wnv.SOURCE
                   AND wnv.active_ind = 'Y')
    UNION
    SELECT base_node_id
      FROM (SELECT w.base_node_id,
                   ws.status_id,
                   ws.status,
                   ws.effective_date,
                   ws.expiry_date,
                   ws.ppdm_guid,
                   ws.status_date,
                   ws.status_depth,
                   ws.status_depth_ouom,
                   ws.status_type,
                   ws.row_changed_date,
                   ws.row_created_date
              FROM ipl_wells_stg_vw w, ipl_well_status_stg_vw ws
             WHERE w.uwi = ws.uwi AND ws.status_id IS NOT NULL
            MINUS

            SELECT w.well_num,
                   ws.status_id,
                   ws.status,
                   ws.effective_date,
                   ws.expiry_date,
                   ws.ppdm_guid,
                   ws.status_date,
                   ws.status_depth,
                   ws.status_depth_ouom,
                   ws.status_type,
                   ws.row_changed_date,
                   ws.row_created_date
              FROM well_version w, well_status ws
             WHERE     w.uwi = ws.uwi
                   AND w.SOURCE = '300IPL'
                   AND w.SOURCE = ws.SOURCE
                   AND ws.active_ind = 'Y')
    UNION
    --STATUSES
    SELECT base_node_id
      FROM (SELECT W.BASE_NODE_ID,
                   WS.Status_ID,
                   WS.ACTIVE_IND,
                   WS.EFFECTIVE_DATE,
                   WS.EXPIRY_DATE,
                   WS.PPDM_GUID,
                   WS.REMARK,
                   WS.Status,
                   WS.Status_Date,
                   WS.STATUS_DEPTH,
                   WS.STATUS_DEPTH_OUOM,
                   WS.STATUS_TYPE,
                   WS.ROW_QUALITY,
                   WS.ROW_CHANGED_DATE,
                   WS.ROW_CREATED_DATE
              FROM ipl_wells_stg_vw W,
                   ipl_well_status_stG_vw WS
             WHERE WS.UWI = W.UWI AND W.SOURCE = 'IHSE'
            MINUS

            SELECT W.WELL_NUM,
                   WS.Status_ID,
                   WS.ACTIVE_IND,
                   WS.EFFECTIVE_DATE,
                   WS.EXPIRY_DATE,
                   WS.PPDM_GUID,
                   WS.REMARK,
                   WS.Status,
                   WS.Status_Date,
                   WS.STATUS_DEPTH,
                   WS.STATUS_DEPTH_OUOM,
                   WS.STATUS_TYPE,
                   WS.ROW_QUALITY,
                   WS.ROW_CHANGED_DATE,
                   WS.ROW_CREATED_DATE
              FROM well_VERSION W, well_status WS
             WHERE     WS.UWI = W.UWI
                   AND w.source = '300IPL'
                   AND WS.SOURCE = '300IPL')
 ;
