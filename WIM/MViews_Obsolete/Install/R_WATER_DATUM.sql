


DROP MATERIALIZED VIEW PPDM.R_WATER_DATUM;
CREATE MATERIALIZED VIEW PPDM.R_WATER_DATUM 
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
/* Formatted on 2010/05/29 13:44 (Formatter Plus v4.8.8) */
SELECT r.water_datum, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.short_name,
       r.SOURCE, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.row_quality
  FROM r_water_datum@"TLM37.WORLD" r;

COMMENT ON TABLE PPDM.R_WATER_DATUM IS 'snapshot table for snapshot PPDM.R_WATER_DATUM';

CREATE UNIQUE INDEX PPDM.R_WD_PK ON PPDM.R_WATER_DATUM
(WATER_DATUM)
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

GRANT SELECT ON PPDM.R_WATER_DATUM TO AMT_READ;

GRANT SELECT ON PPDM.R_WATER_DATUM TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.R_WATER_DATUM TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WATER_DATUM TO PPDM_CHANGE;

GRANT SELECT ON PPDM.R_WATER_DATUM TO PPDM_OW;

GRANT SELECT ON PPDM.R_WATER_DATUM TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WATER_DATUM TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.R_WATER_DATUM TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WATER_DATUM TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_WATER_DATUM TO UPDATE_OBJECTS;
