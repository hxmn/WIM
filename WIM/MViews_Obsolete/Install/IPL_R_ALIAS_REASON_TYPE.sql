DROP MATERIALIZED VIEW PPDM.IPL_R_ALIAS_REASON_TYPE;
CREATE MATERIALIZED VIEW PPDM.IPL_R_ALIAS_REASON_TYPE 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    0
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
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
            PCTFREE    0
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          64K
                        NEXT             1M
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
/* Formatted on 2010/05/29 12:25 (Formatter Plus v4.8.8) */
SELECT r.reason_type, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.short_name,
       r.SOURCE, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.ipl_xaction_code, r.row_quality
  FROM r_alias_reason_type@"TLM37.WORLD" r;

COMMENT ON TABLE PPDM.IPL_R_ALIAS_REASON_TYPE IS 'snapshot table for snapshot PPDM.IPL_R_ALIAS_REASON_TYPE';

CREATE UNIQUE INDEX PPDM.IR_ART_PK ON PPDM.IPL_R_ALIAS_REASON_TYPE
(REASON_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    0
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO AMT_READ;

GRANT SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_ALIAS_REASON_TYPE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO PPDM_OW;

GRANT SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_ALIAS_REASON_TYPE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.IPL_R_ALIAS_REASON_TYPE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_ALIAS_REASON_TYPE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_ALIAS_REASON_TYPE TO UPDATE_OBJECTS;