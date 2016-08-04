

DROP MATERIALIZED VIEW PPDM.WELL_ALIAS;
CREATE MATERIALIZED VIEW PPDM.WELL_ALIAS 
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
/* Formatted on 2010/05/29 15:14 (Formatter Plus v4.8.8) */
SELECT w.uwi, w.SOURCE, w.well_alias_id, w.active_ind, w.alias_owner_ba_id,
       w.alias_type, w.application_id, w.effective_date, w.expiry_date,
       w.location_type, w.ppdm_guid, w.preferred_ind, w.reason_type, w.remark,
       w.well_alias, w.ipl_alt_source, w.ipl_xaction_code, w.row_changed_by,
       w.row_changed_date, w.row_created_by, w.row_created_date,
       w.row_quality
  FROM well_alias@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL_ALIAS IS 'snapshot table for snapshot PPDM.WELL_ALIAS';

CREATE UNIQUE INDEX PPDM.WA_PK ON PPDM.WELL_ALIAS
(UWI, SOURCE, ALIAS_TYPE, WELL_ALIAS, WELL_ALIAS_ID)
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

CREATE INDEX PPDM.WA_R_ART_IDX ON PPDM.WELL_ALIAS
(REASON_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE INDEX PPDM.WA_R_AT3_IDX ON PPDM.WELL_ALIAS
(ALIAS_TYPE)
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

CREATE INDEX PPDM.WA_R_S_IDX ON PPDM.WELL_ALIAS
(SOURCE)
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

CREATE INDEX PPDM.WA_W_IDX ON PPDM.WELL_ALIAS
(UWI)
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

CREATE INDEX PPDM.WELL_ALIASIDX ON PPDM.WELL_ALIAS
(WELL_ALIAS)
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

GRANT SELECT ON PPDM.WELL_ALIAS TO AMT_READ;

GRANT SELECT ON PPDM.WELL_ALIAS TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL_ALIAS TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_ALIAS TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_ALIAS TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_ALIAS TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_ALIAS TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL_ALIAS TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_ALIAS TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_ALIAS TO UPDATE_OBJECTS;
