
DROP MATERIALIZED VIEW PPDM.R_COUNTRY;
CREATE MATERIALIZED VIEW PPDM.R_COUNTRY 
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
/* Formatted on 2010/05/29 13:35 (Formatter Plus v4.8.8) */
SELECT r.country, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.short_name,
       r.SOURCE, r.ipl_xaction_code, r.row_changed_by, r.row_changed_date,
       r.row_created_by, r.row_created_date, r.row_quality
  FROM r_country@"TLM37.WORLD" r;

COMMENT ON TABLE PPDM.R_COUNTRY IS 'snapshot table for snapshot PPDM.R_COUNTRY';

CREATE UNIQUE INDEX PPDM.R_C1_PK ON PPDM.R_COUNTRY
(COUNTRY)
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

GRANT SELECT ON PPDM.R_COUNTRY TO AMT_READ;

GRANT SELECT ON PPDM.R_COUNTRY TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.R_COUNTRY TO GEOL_REC_WL;

GRANT SELECT ON PPDM.R_COUNTRY TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_COUNTRY TO PPDM_CHANGE;

GRANT SELECT ON PPDM.R_COUNTRY TO PPDM_OW;

GRANT SELECT ON PPDM.R_COUNTRY TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_COUNTRY TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.R_COUNTRY TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_COUNTRY TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_COUNTRY TO UPDATE_OBJECTS;
