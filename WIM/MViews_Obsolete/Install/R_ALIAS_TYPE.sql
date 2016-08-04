DROP MATERIALIZED VIEW PPDM.R_ALIAS_TYPE;
CREATE MATERIALIZED VIEW PPDM.R_ALIAS_TYPE 
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
/* Formatted on 2010/05/31 08:15 (Formatter Plus v4.8.8) */
SELECT r.alias_type, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.short_name,
       r.SOURCE, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.ipl_xaction_code, r.row_quality,
       CAST ('IPL_ALIAS_TYPE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.ipl_r_alias_type r
UNION ALL
SELECT t.alias_type, t.abbreviation, t.active_ind, t.effective_date,
       t.expiry_date, t.long_name, t.ppdm_guid, t.remark, t.short_name,
       t.SOURCE, t.row_changed_by, t.row_changed_date, t.row_created_by,
       t.row_created_date, CAST (NULL AS VARCHAR2 (1)) AS ipl_action_code,
       t.row_quality,
       CAST ('TLM_ALIAS_TYPE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.tlm_r_alias_type t
 WHERE t.alias_type NOT IN (SELECT i.alias_type
                              FROM ppdm.ipl_r_alias_type i);

COMMENT ON TABLE PPDM.R_ALIAS_TYPE IS 'snapshot table for snapshot PPDM.R_ALIAS_TYPE';

CREATE UNIQUE INDEX PPDM.MV_RAT3_PK ON PPDM.R_ALIAS_TYPE
(ALIAS_TYPE)
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

GRANT SELECT ON PPDM.R_ALIAS_TYPE TO AMT_READ;

GRANT SELECT ON PPDM.R_ALIAS_TYPE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.R_ALIAS_TYPE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_ALIAS_TYPE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.R_ALIAS_TYPE TO PPDM_OW;

GRANT SELECT ON PPDM.R_ALIAS_TYPE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_ALIAS_TYPE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.R_ALIAS_TYPE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_ALIAS_TYPE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_ALIAS_TYPE TO UPDATE_OBJECTS;
