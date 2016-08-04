DROP MATERIALIZED VIEW PPDM.BUSINESS_ASSOCIATE;
CREATE MATERIALIZED VIEW PPDM.BUSINESS_ASSOCIATE 
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
/* Formatted on 2010/05/31 08:07 (Formatter Plus v4.8.8) */
SELECT b.business_associate, b.active_ind, b.ba_abbreviation, b.ba_category,
       b.ba_code, b.ba_name, b.ba_short_name, b.ba_type, b.credit_check_date,
       b.credit_check_ind, b.credit_check_source, b.credit_rating,
       b.credit_rating_source, b.current_status, b.effective_date,
       b.expiry_date, b.first_name, b.last_name, b.main_email_address,
       b.main_fax_num, b.main_phone_num, b.main_web_url, b.middle_initial,
       b.ppdm_guid, b.remark, b.SOURCE, b.row_changed_by, b.row_changed_date,
       b.row_created_by, b.row_created_date, b.row_quality,
       b.ipl_xaction_code,
       CAST ('IPL_BUSINESS_ASSOCIATE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.ipl_business_associate b
UNION ALL
SELECT t.business_associate, t.active_ind, t.ba_abbreviation, t.ba_category,
       t.ba_code, t.ba_name, t.ba_short_name, t.ba_type, t.credit_check_date,
       t.credit_check_ind, t.credit_check_source, t.credit_rating,
       t.credit_rating_source, t.current_status, t.effective_date,
       t.expiry_date, t.first_name, t.last_name, t.main_email_address,
       t.main_fax_num, t.main_phone_num, t.main_web_url, t.middle_initial,
       t.ppdm_guid, t.remark, t.SOURCE, t.row_changed_by, t.row_changed_date,
       t.row_created_by, t.row_created_date, t.row_quality,
       CAST (NULL AS VARCHAR2 (1)) AS ipl_xaction_code,
       CAST ('TLM_BUSINESS_ASSOCIATE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.tlm_business_associate t
 WHERE t.business_associate NOT IN (SELECT i.business_associate
                                      FROM ppdm.ipl_business_associate i);

COMMENT ON TABLE PPDM.BUSINESS_ASSOCIATE IS 'snapshot table for snapshot PPDM.BUSINESS_ASSOCIATE';

COMMENT ON COLUMN PPDM.BUSINESS_ASSOCIATE.IPL_XACTION_CODE IS 'IPL XACTION CODE: IPL transaction code (obsolete).';

CREATE UNIQUE INDEX PPDM.MV_BA_PK ON PPDM.BUSINESS_ASSOCIATE
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

GRANT SELECT ON PPDM.BUSINESS_ASSOCIATE TO AMT_READ;

GRANT SELECT ON PPDM.BUSINESS_ASSOCIATE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.BUSINESS_ASSOCIATE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.BUSINESS_ASSOCIATE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.BUSINESS_ASSOCIATE TO PPDM_OW;

GRANT SELECT ON PPDM.BUSINESS_ASSOCIATE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.BUSINESS_ASSOCIATE TO PPDM_WRITE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.BUSINESS_ASSOCIATE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.BUSINESS_ASSOCIATE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.BUSINESS_ASSOCIATE TO UPDATE_OBJECTS;
