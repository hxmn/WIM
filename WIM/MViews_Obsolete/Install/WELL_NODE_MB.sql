

DROP MATERIALIZED VIEW PPDM.WELL_NODE_M_B;
CREATE MATERIALIZED VIEW PPDM.WELL_NODE_M_B 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOCACHE
NOLOGGING
NOPARALLEL
BUILD IMMEDIATE
USING INDEX
            TABLESPACE PPDMINDEX
            PCTFREE    10
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          1M
                        NEXT             1040K
                        MINEXTENTS       1
                        MAXEXTENTS       UNLIMITED
                        PCTINCREASE      0
                        FREELISTS        1
                        FREELIST GROUPS  1
                        BUFFER_POOL      DEFAULT
                       )
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2010/05/29 15:17 (Formatter Plus v4.8.8) */
SELECT w.node_id, w.SOURCE, w.active_ind, w.dls_road_allowance_id,
       w.effective_date, w.ew_direction, w.ew_distance, w.ew_distance_ouom,
       w.ew_start_line, w.expiry_date, w.location_type, w.ns_direction,
       w.ns_distance, w.ns_distance_ouom, w.ns_start_line, w.orientation,
       w.parcel_carter_id, w.parcel_congress_id, w.parcel_dls_id,
       w.parcel_fps_id, w.parcel_ne_loc_id, w.parcel_north_sea_id,
       w.parcel_nts_id, w.parcel_offshore_id, w.parcel_ohio_id,
       w.parcel_pbl_id, w.parcel_texas, w.ppdm_guid, w.reference_loc,
       w.remark, w.surface_loc, w.ipl_uwi, w.ipl_alt_source,
       w.ipl_xaction_code, w.row_changed_by, w.row_changed_date,
       w.row_created_by, w.row_created_date, w.row_quality
  FROM well_node_m_b@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL_NODE_M_B IS 'snapshot table for snapshot PPDM.WELL_NODE_M_B';

CREATE INDEX PPDM.WNMB_ID01 ON PPDM.WELL_NODE_M_B
(IPL_UWI, SOURCE)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE UNIQUE INDEX PPDM.WNMB_PK ON PPDM.WELL_NODE_M_B
(NODE_ID, SOURCE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE INDEX PPDM.WNMB_R_S_IDX ON PPDM.WELL_NODE_M_B
(SOURCE)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO AMT_READ;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO GEOWIZ;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE_M_B TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_NODE_M_B TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE_M_B TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL_NODE_M_B TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE_M_B TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE_M_B TO UPDATE_OBJECTS;
