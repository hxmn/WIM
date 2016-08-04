

DROP MATERIALIZED VIEW PPDM.WELL_NODE;
CREATE MATERIALIZED VIEW PPDM.WELL_NODE 
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
/* Formatted on 2010/05/29 15:16 (Formatter Plus v4.8.8) */
SELECT w.node_id, w.SOURCE, w.node_obs_no, w.acquisition_id, w.active_ind,
       w.country, w.county, w.easting, w.easting_ouom, w.effective_date,
       w.elev, w.elev_ouom, w.ew_direction, w.expiry_date,
       w.geog_coord_system_id, w.latitude, w.legal_survey_type,
       w.location_qualifier, w.location_quality, w.longitude,
       w.map_coord_system_id, w.md, w.md_ouom, w.monument_id,
       w.monument_sf_type, w.node_position, w.northing, w.northing_ouom,
       w.north_type, w.ns_direction, w.polar_azimuth, w.polar_offset,
       w.polar_offset_ouom, w.ppdm_guid, w.preferred_ind, w.province_state,
       w.remark, w.reported_tvd, w.reported_tvd_ouom, w.version_type,
       w.x_offset, w.x_offset_ouom, w.y_offset, w.y_offset_ouom,
       w.ipl_xaction_code, w.row_changed_by, w.row_changed_date,
       w.row_created_by, w.row_created_date, w.ipl_uwi, w.row_quality,
       w.coord_system_id
  FROM well_node@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL_NODE IS 'snapshot table for snapshot PPDM.WELL_NODE';

CREATE INDEX PPDM.WN_CS_IDX ON PPDM.WELL_NODE
(COORD_SYSTEM_ID)
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

CREATE INDEX PPDM.WN_CS_IDX2 ON PPDM.WELL_NODE
(GEOG_COORD_SYSTEM_ID)
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

CREATE INDEX PPDM.WN_ID01 ON PPDM.WELL_NODE
(LONGITUDE, LATITUDE, NODE_ID, SOURCE)
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

CREATE INDEX PPDM.WN_ID02 ON PPDM.WELL_NODE
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

CREATE INDEX PPDM.WN_ID1 ON PPDM.WELL_NODE
(LATITUDE, LONGITUDE)
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

CREATE UNIQUE INDEX PPDM.WN_PK ON PPDM.WELL_NODE
(NODE_ID)
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

CREATE INDEX PPDM.WN_R_NP_IDX ON PPDM.WELL_NODE
(NODE_POSITION)
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

GRANT SELECT ON PPDM.WELL_NODE TO AMT_READ;

GRANT SELECT ON PPDM.WELL_NODE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL_NODE TO GEOWIZ;

GRANT SELECT ON PPDM.WELL_NODE TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.WELL_NODE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_NODE TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_NODE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL_NODE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_NODE TO UPDATE_OBJECTS;
