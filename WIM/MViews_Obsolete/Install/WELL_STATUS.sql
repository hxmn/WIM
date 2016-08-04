


DROP MATERIALIZED VIEW PPDM.WELL_STATUS;
CREATE MATERIALIZED VIEW PPDM.WELL_STATUS 
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
/* Formatted on 2010/05/29 15:18 (Formatter Plus v4.8.8) */
SELECT w.uwi, w.SOURCE, w.status_id, w.active_ind, w.effective_date,
       w.expiry_date, w.ppdm_guid, w.remark, w.status, w.status_date,
       w.status_depth, w.status_depth_ouom, w.ipl_xaction_code, w.status_type,
       w.row_changed_by, w.row_changed_date, w.row_created_by,
       w.row_created_date, w.row_quality
  FROM well_status@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL_STATUS IS 'snapshot table for snapshot PPDM.WELL_STATUS';

CREATE UNIQUE INDEX PPDM.WST_PK ON PPDM.WELL_STATUS
(UWI, SOURCE, STATUS_ID)
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

GRANT SELECT ON PPDM.WELL_STATUS TO AMT_READ;

GRANT SELECT ON PPDM.WELL_STATUS TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL_STATUS TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_STATUS TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_STATUS TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_STATUS TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_STATUS TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL_STATUS TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_STATUS TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_STATUS TO UPDATE_OBJECTS;
