DROP VIEW PID_WELL_STATUS_STG_VW;

/* Formatted on 30/09/2013 9:18:19 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW PID_WELL_STATUS_STG_VW
(
   UWI,
   SOURCE,
   STATUS_ID,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   STATUS,
   STATUS_DATE,
   STATUS_DEPTH,
   STATUS_DEPTH_CUOM,
   STATUS_DEPTH_OUOM,
   IPL_XACTION_CODE,
   STATUS_TYPE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY
)
AS
   SELECT wv.uwi,
          wv.SOURCE,
          CAST ('00' || ws.status_id AS VARCHAR (20)) status_id,
          ws.active_ind active_ind,
          ws.effective_date effective_date,
          ws.expiry_date expiry_date,
          ws.ppdm_guid ppdm_guid,
          ws.remark remark,
          ws.status status,
          ws.status_date status_date,
          ws.status_depth status_depth,
          --(select ABREV from r_unit_of_measure@c_talisman_us
          --            where table_name = 'WELL_STATUS'
          --            and uom_system_id = 'IMPERIAL'
          --          and column_name = 'STATUS_DEPTH') ??
          'FT' AS status_depth_cuom,                                     --NEW
          ws.status_depth_ouom status_depth_ouom,
          CAST ('' AS VARCHAR (1)) ipl_xaction_code,
          ws.status_type status_type,
          CAST (ws.row_changed_by AS VARCHAR (30)) AS row_changed_by,
          --decode(ws.row_changed_date, NULL, SYSDATE, ws.row_changed_Date ) row_changed_date,
          ws.row_changed_date,
          CAST (ws.row_created_by AS VARCHAR (30)) AS row_created_by,
          --decode(ws.row_created_date, NULL, SYSDATE, ws.row_created_date) row_created_date,
          ws.row_created_date,
          ws.row_quality row_quality
     FROM well_pidstg_mv wv, well_statuspidstg_mv ws
    WHERE ws.uwi = wv.uwi;


GRANT SELECT ON PID_WELL_STATUS_STG_VW TO VRAJPOOT;
