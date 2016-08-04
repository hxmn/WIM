DROP MATERIALIZED VIEW PPDM.IPL_BUSINESS_ASSOCIATE;
CREATE MATERIALIZED VIEW PPDM.IPL_BUSINESS_ASSOCIATE 
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
/* Formatted on 2010/05/29 12:14 (Formatter Plus v4.8.8) */
SELECT b.business_associate, b.active_ind, b.ba_abbreviation, b.ba_category,
       b.ba_code, b.ba_name, b.ba_short_name, b.ba_type, b.credit_check_date,
       b.credit_check_ind, b.credit_check_source, b.credit_rating,
       b.credit_rating_source, b.current_status, b.effective_date,
       b.expiry_date, b.first_name, b.last_name, b.main_email_address,
       b.main_fax_num, b.main_phone_num, b.main_web_url, b.middle_initial,
       b.ppdm_guid, b.remark, b.SOURCE, b.row_changed_by, b.row_changed_date,
       b.row_created_by, b.row_created_date, b.row_quality,
       b.ipl_xaction_code
  FROM business_associate@"TLM37.WORLD" b;

COMMENT ON TABLE PPDM.IPL_BUSINESS_ASSOCIATE IS 'snapshot table for snapshot PPDM.IPL_BUSINESS_ASSOCIATE';

CREATE UNIQUE INDEX PPDM.I_BA_PK ON PPDM.IPL_BUSINESS_ASSOCIATE
(BUSINESS_ASSOCIATE)
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

GRANT SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO AMT_READ;

GRANT SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_BUSINESS_ASSOCIATE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO PPDM_OW;

GRANT SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_BUSINESS_ASSOCIATE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.IPL_BUSINESS_ASSOCIATE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_BUSINESS_ASSOCIATE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.IPL_BUSINESS_ASSOCIATE TO UPDATE_OBJECTS;
