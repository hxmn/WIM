DROP MATERIALIZED VIEW PPDM.PROD_STRING;
CREATE MATERIALIZED VIEW PPDM.PROD_STRING 
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
/* Formatted on 2010/05/29 13:32 (Formatter Plus v4.8.8) */
SELECT p.uwi, p.SOURCE, p.string_id, p.active_ind, p.base_depth,
       p.base_depth_ouom, p.business_associate, p.commingled_ind,
       p.current_status, p.current_status_date, p.effective_date,
       p.expiry_date, p.facility_id, p.facility_type, p.field_id,
       p.government_string_id, p.lease_unit_id, p.on_injection_date,
       p.on_production_date, p.plot_symbol, p.pool_id, p.ppdm_guid,
       p.prod_string_tvd, p.prod_string_tvd_ouom, p.prod_string_type,
       p.profile_type, p.remark, p.status_type, p.strat_name_set_id,
       p.strat_unit_id, p.tax_credit_code, p.top_depth, p.top_depth_ouom,
       p.total_depth, p.total_depth_ouom, p.row_changed_by,
       p.row_changed_date, p.row_created_by, p.row_created_date,
       p.row_quality
  FROM prod_string@"TLM37.WORLD" p;

COMMENT ON TABLE PPDM.PROD_STRING IS 'snapshot table for snapshot PPDM.PROD_STRING';

CREATE UNIQUE INDEX PPDM.PS_PK ON PPDM.PROD_STRING
(UWI, SOURCE, STRING_ID)
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

GRANT SELECT ON PPDM.PROD_STRING TO AMT_READ;

GRANT SELECT ON PPDM.PROD_STRING TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.PROD_STRING TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.PROD_STRING TO PPDM_CHANGE;

GRANT SELECT ON PPDM.PROD_STRING TO PPDM_OW;

GRANT SELECT ON PPDM.PROD_STRING TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.PROD_STRING TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.PROD_STRING TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.PROD_STRING TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.PROD_STRING TO UPDATE_OBJECTS;
