DROP VIEW CWS_WELL_STATUS_STG_VW;

/* Formatted on 30/09/2013 9:18:14 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW CWS_WELL_STATUS_STG_VW
(
   UWI,
   SOURCE,
   STATUS_ID,
   ACTIVE_IND,
   WS_EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   STATUS,
   STATUS_DATE,
   STATUS_DEPTH,
   TATUS_DEPTH_CUOM,
   STATUS_DEPTH_OUOM,
   PL_XACTION_CODE,
   STATUS_TYPE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY
)
AS
   SELECT CAST (w.well_id AS VARCHAR (20)) uwi,
          CAST ('100TLM' AS VARCHAR (20)) SOURCE,
          (SELECT status_id
             FROM ppdm.well_status
            WHERE 1 = 2)
             ws_status_id,
          'Y' ws_active_ind,
          CAST (NULL AS DATE) ws_effective_date,
          CAST (NULL AS DATE) ws_expiry_date,
          CAST (NULL AS VARCHAR (38)) ws_ppdm_guid,
          CAST (NULL AS VARCHAR (2000)) ws_remark,
          c.well_status_cd ws_status,
          c.well_status_dt AS ws_status_date,
          CAST (NULL AS NUMBER) ws_status_depth,
          CAST ('M' AS VARCHAR (2)) AS ws_status_depth_cuom,
          CAST (NULL AS VARCHAR (20)) ws_status_depth_ouom,
          CAST (NULL AS VARCHAR (1)) ws_ipl_xaction_code,
          CAST (NULL AS VARCHAR (20)) ws_status_type,
          c.last_update_userid ws_row_changed_by,
          c.last_update_dt ws_row_changed_date,
          c.create_userid ws_row_created_by,
          c.create_dt ws_row_created_date,
          CAST (NULL AS VARCHAR (20)) ws_row_quality
     FROM well_current_data@cws.world c, well@cws.world w
    WHERE w.well_id = c.well_id AND (NVL (c.well_status_cd, 'z') != 'CANCEL');
