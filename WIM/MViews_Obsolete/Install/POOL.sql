DROP MATERIALIZED VIEW PPDM.POOL ;
CREATE MATERIALIZED VIEW PPDM.POOL 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    0
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
            PCTFREE    0
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
/* Formatted on 2010/05/29 12:34 (Formatter Plus v4.8.8) */
SELECT p.pool_id, p.active_ind, p.business_associate, p.country, p.county,
       p.current_status_date, p.discovery_date, p.district, p.effective_date,
       p.expiry_date, p.field_id, p.geologic_province, p.pool_code,
       p.pool_name, p.pool_name_abbreviation, p.pool_status, p.pool_type,
       p.ppdm_guid, p.province_state, p.remark, p.SOURCE, p.strat_name_set_id,
       p.strat_unit_id, p.row_changed_by, p.row_changed_date,
       p.row_created_by, p.row_created_date, p.row_quality
  FROM pool@"TLM37.WORLD" p;

COMMENT ON TABLE PPDM.POOL IS 'snapshot table for snapshot PPDM.POOL';

CREATE UNIQUE INDEX PPDM.PL_PK ON PPDM.POOL
(POOL_ID)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    0
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

GRANT SELECT ON PPDM.POOL TO AMT_READ;

GRANT SELECT ON PPDM.POOL TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.POOL TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.POOL TO PPDM_CHANGE;

GRANT SELECT ON PPDM.POOL TO PPDM_OW;

GRANT SELECT ON PPDM.POOL TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.POOL TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.POOL TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.POOL TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.POOL TO UPDATE_OBJECTS;
