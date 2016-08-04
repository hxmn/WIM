

DROP MATERIALIZED VIEW PPDM.R_WELL_CLASS;
CREATE MATERIALIZED VIEW PPDM.R_WELL_CLASS 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    0
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
                        INITIAL          1M
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
/* Formatted on 2010/05/29 13:45 (Formatter Plus v4.8.8) */
SELECT r.well_class, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.short_name,
       r.SOURCE, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.ipl_xaction_code, r.row_quality
  FROM r_well_class@"TLM37.WORLD" r;

COMMENT ON TABLE PPDM.R_WELL_CLASS IS 'snapshot table for snapshot PPDM.R_WELL_CLASS';

CREATE UNIQUE INDEX PPDM.R_WC_PK ON PPDM.R_WELL_CLASS
(WELL_CLASS)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    0
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

GRANT SELECT ON PPDM.R_WELL_CLASS TO AMT_READ;

GRANT SELECT ON PPDM.R_WELL_CLASS TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.R_WELL_CLASS TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WELL_CLASS TO PPDM_CHANGE;

GRANT SELECT ON PPDM.R_WELL_CLASS TO PPDM_OW;

GRANT SELECT ON PPDM.R_WELL_CLASS TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WELL_CLASS TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.R_WELL_CLASS TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WELL_CLASS TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WELL_CLASS TO UPDATE_OBJECTS;
