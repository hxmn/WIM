DROP VIEW CWS_WELLS_CHANGES_VW;

/* Formatted on 30/09/2013 9:18:15 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW CWS_WELLS_CHANGES_VW
(
   UWI
)
AS
   SELECT UWI
     FROM (SELECT uwi,
                  source,
                  active_ind,
                  Well_Name,
                  ROUND (Bottom_Hole_Latitude, 7),
                  ROUND (Bottom_hole_Longitude, 7),
                  Current_Status,
                  CURRENT_STATUS_DATE,
                  DRILL_TD,
                  KB_ELEV,
                  PROVINCE_STATE,
                  RIG_RELEASE_DATE,
                  SPUD_DATE,
                  ROUND (SURFACE_LATITUDE, 7),
                  ROUND (SURFACE_LONGITUDE, 7),
                  IPL_OFFSHORE_IND,
                  IPL_ONPROD_DATE,
                  IPL_UWI_LOCAL
             FROM CWS_WELLS_STG_VW                       --where uwi ='135222'
           MINUS
           SELECT DISTINCT WV.UWI,
                           WV.SOURCE,
                           WV.ACTIVE_IND,
                           WV.WELL_NAME,
                           WV.Bottom_Hole_Latitude,
                           WV.Bottom_hole_Longitude,
                           --   WV.COUNTRY,
                           WV.Current_Status,
                           WV.CURRENT_STATUS_DATE,
                           WV.DRILL_TD,
                           WV.KB_ELEV,
                           WV.PROVINCE_STATE,
                           WV.RIG_RELEASE_DATE,
                           WV.SPUD_DATE,
                           WV.SURFACE_LATITUDE,
                           WV.SURFACE_LONGITUDE,
                           wv.IPL_OFFSHORE_IND,
                           wv.IPL_ONPROD_DATE,
                           IPL_UWI_LOCAL --, wv.row_changed_date, wv.row_created_date
             FROM WELL_VERSION WV
            WHERE wv.source = '100TLM' AND wv.ACTIVE_IND = 'Y' --and uwi ='135222'
                                                              )
   UNION
   --NOdes- Base

   SELECT UWI
     FROM (SELECT uwi,
                  source,
                  activE_ind,
                  ROUND (Latitude, 7),
                  ROUND (Longitude, 7),
                  geog_coord_system_id,
                  location_qualifier,
                  node_position,
                  row_changed_date,
                  row_created_date
             FROM CWS_WELL_NODE_STG_VW
            WHERE Node_Position = 'B'
           MINUS
           SELECT DISTINCT B.IPL_UWI,
                           B.SOURCE,
                           B.ACTIVE_IND,
                           B.Latitude,
                           B.Longitude,
                           geog_coord_system_id,
                           location_qualifier,
                           node_position,
                           b.row_changed_date,
                           b.row_created_date
             FROM well_version wv, well_node_Version B
            WHERE     wv.uwi = b.ipl_uwi
                  AND wv.source = '100TLM'
                  AND B.source = '100TLM'
                  AND B.ACTIVE_IND = 'Y'
                  AND B.Node_Position = 'B')
   UNION
   -- Surface

   SELECT uwi
     FROM (SELECT uwi,
                  source,
                  activE_ind,
                  ROUND (Latitude, 7),
                  ROUND (Longitude, 7),
                  geog_coord_system_id,
                  location_qualifier,
                  node_position,
                  row_changed_date,
                  row_created_date
             FROM CWS_WELL_NODE_STG_VW
            WHERE Node_Position = 'S'
           MINUS
           SELECT DISTINCT S.IPL_UWI,
                           S.SOURCE,
                           S.ACTIVE_IND,
                           S.Latitude Surface_Latitude,
                           S.Longitude Surface_Longitude,
                           geog_coord_system_id,
                           location_qualifier,
                           node_position,
                           s.row_changed_date,
                           s.row_created_Date
             FROM well_version wv, well_node_Version S
            WHERE     wv.uwi = s.ipl_uwi
                  AND wv.source = '100TLM'
                  AND S.source = '100TLM'
                  AND S.ACTIVE_IND = 'Y'
                  AND S.Node_Position = 'S')
   UNION
   --Well License
   SELECT uwi
     FROM (SELECT uwi,
                  source,
                  wl_activE_ind,
                  wl_license_id,
                  wl_License_num,
                  Wl_Projected_Depth,
                  WL_row_changed_date,
                  WL_row_Created_Date
             FROM CWS_WELLS_STG_VW
            WHERE wl_license_num IS NOT NULL
           MINUS
           SELECT DISTINCT WL.UWI,
                           WL.SOURCE,
                           WL.ACTIVE_IND,
                           WL.LICENSE_ID,
                           WL.LICENSE_NUM,
                           WL.PROJECTED_DEPTH,
                           wl.row_changed_date,
                           wl.row_created_date
             FROM well_license WL, well_version wv
            WHERE     wl.uwi = wv.uwi
                  AND wv.source = '100TLM'
                  AND wl.source = '100TLM'
                  AND wv.active_ind = 'Y'
                  AND wl.ACTIVE_IND = 'Y'
                  AND wl.license_num IS NOT NULL)
   UNION
   --STATUS

   SELECT uwi
     FROM (SELECT uwi,
                  source,
                  active_ind,
                  status,
                  Status_date
             FROM CWS_WELL_STATUS_STG_VW                -- where uwi ='100050'
           MINUS
           SELECT uwi,
                  source,
                  active_ind,
                  current_status,
                  current_Status_date
             FROM well_Version
            WHERE source = '100TLM' AND active_ind = 'Y'   --and uwi ='100050'
                                                        )
   UNION
   --Diffs by Dates only
   SELECT CWS.UWI
     FROM (SELECT CAST (w.well_id AS VARCHAR (20)) uwi,
                  GREATEST (c.last_update_dt, w.last_update_dt)
                     row_changed_date,
                  GREATEST (c.create_dt, w.create_dt) row_created_date,
                  base.last_update_dt b_row_changed_date,
                  base.create_dt b_row_created_date,
                  surface.last_update_dt s_row_changed_date,
                  surface.create_dt s_row_created_date,
                  wl.last_update_dt AS wl_row_changed_date,
                  wl.create_dt AS wl_row_created_date
             FROM well_current_data@cws.world c,
                  well@cws.world w,
                  well_node@cws.world base,
                  well_node@cws.world surface,
                  well_license@cws.world wl
            WHERE     w.well_id = c.well_id
                  AND surface.well_node_id = c.surface_node_id
                  AND base.well_node_id = c.base_node_id
                  AND w.well_license_id = wl.well_license_id(+)
                  AND (NVL (c.well_status_cd, 'z') != 'CANCEL')) cws
          LEFT JOIN
          (SELECT wv.uwi,
                  NVL (
                     GREATEST (
                        NVL (wv.row_Changed_date, wv.row_created_date),
                        NVL (wv.row_created_date, wv.row_Changed_date)),
                     SYSDATE)
                     Well_date,
                  NVL (
                     GREATEST (
                        NVL (nv_b.row_Changed_date, nv_b.row_created_date),
                        NVL (nv_b.row_created_date, nv_b.row_Changed_date)),
                     SYSDATE)
                     Base_Node_Date,
                  NVL (
                     GREATEST (
                        NVL (nv_s.row_Changed_date, nv_s.row_created_date),
                        NVL (nv_s.row_created_date, nv_s.row_Changed_date)),
                     SYSDATE)
                     Surface_Node_Date,
                  NVL (
                     GREATEST (
                        NVL (wl.row_Changed_date, wl.row_created_date),
                        NVL (wl.row_created_date, wl.row_Changed_date)),
                     SYSDATE)
                     Lic_Date
             FROM well_version wv
                  LEFT JOIN well_node_version nv_b
                     ON wv.uwi = nv_b.ipl_uwi AND wv.source = nv_b.source
                  LEFT JOIN well_node_version nv_s
                     ON wv.uwi = nv_s.ipl_uwi AND wv.source = nv_s.source
                  LEFT JOIN well_license wl
                     ON wv.uwi = wl.uwi AND wv.source = wl.source
            WHERE     wv.source = '100TLM'
                  AND nv_b.Node_Position = 'B'
                  AND nv_s.Node_Position = 'S') ppdm
             ON cws.uwi = ppdm.uwi
    WHERE    ppdm.uwi IS NULL
          OR (   (   ROW_Created_Date > well_date
                  OR ROW_Changed_Date > well_date)
              OR (   S_ROW_Created_Date > Surface_node_date
                  OR S_ROW_Changed_Date > Surface_node_date)
              OR (   B_ROW_Created_Date > Base_node_date
                  OR B_ROW_Changed_Date > Base_node_date)
              OR (   WL_ROW_Created_Date > lic_date
                  OR WL_ROW_Changed_Date > lic_date));
