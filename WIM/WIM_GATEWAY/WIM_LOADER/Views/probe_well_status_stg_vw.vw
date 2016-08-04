DROP VIEW PROBE_WELL_STATUS_STG_VW;

/* Formatted on 30/09/2013 9:18:22 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW PROBE_WELL_STATUS_STG_VW
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
          CAST (ws.status_id AS VARCHAR (20)) ws_status_id,
          ws.active_ind ws_active_ind,
          ws.effective_date ws_effective_date,
          ws.expiry_date ws_expiry_date,
          ws.ppdm_guid ws_ppdm_guid,
          ws.remark ws_remark,
          ws.status ws_status,
          ws.status_date ws_status_date,
          ws.status_depth ws_status_depth,
          CAST ('M' AS VARCHAR (2)) AS ws_status_depth_cuom,             --NEW
          ws.status_depth_ouom ws_status_depth_ouom,
          ws.ipl_xaction_code ws_ipl_xaction_code,
          ws.status_type ws_status_type,
          CAST (ws.row_changed_by AS VARCHAR (30)) AS ws_row_changed_by,
          ws.row_changed_date ws_row_changed_date,
          CAST (ws.row_created_by AS VARCHAR (30)) AS ws_row_created_by,
          ws.row_created_date ws_row_created_date,
          ws.row_quality ws_row_quality
     FROM well_version@c_tlm_probe.world wv, well_status@c_tlm_probe.world ws
    WHERE ws.uwi = wv.uwi;
