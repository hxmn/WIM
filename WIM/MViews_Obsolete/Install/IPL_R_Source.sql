DROP MATERIALIZED VIEW PPDM.IPL_R_SOURCE;
CREATE MATERIALIZED VIEW PPDM.IPL_R_SOURCE 
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
/* Formatted on 2010/05/29 12:32 (Formatter Plus v4.8.8) */
SELECT r.SOURCE, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.row_source,
       r.short_name, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.row_quality
  FROM r_source@"TLM37.WORLD" r;

COMMENT ON TABLE PPDM.IPL_R_SOURCE IS 'snapshot table for snapshot PPDM.IPL_R_SOURCE';

CREATE UNIQUE INDEX PPDM.IR_S_PK ON PPDM.IPL_R_SOURCE
(SOURCE)
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

GRANT SELECT ON PPDM.IPL_R_SOURCE TO AMT_READ;

GRANT SELECT ON PPDM.IPL_R_SOURCE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.IPL_R_SOURCE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_SOURCE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.IPL_R_SOURCE TO PPDM_OW;

GRANT SELECT ON PPDM.IPL_R_SOURCE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_SOURCE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.IPL_R_SOURCE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_SOURCE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_R_SOURCE TO UPDATE_OBJECTS;
