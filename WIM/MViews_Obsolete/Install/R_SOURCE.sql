DROP MATERIALIZED VIEW PPDM.R_SOURCE;
CREATE MATERIALIZED VIEW PPDM.R_SOURCE 
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
/* Formatted on 2010/05/31 08:19 (Formatter Plus v4.8.8) */
SELECT r.SOURCE, r.abbreviation, r.active_ind, r.effective_date,
       r.expiry_date, r.long_name, r.ppdm_guid, r.remark, r.row_source,
       r.short_name, r.row_changed_by, r.row_changed_date, r.row_created_by,
       r.row_created_date, r.row_quality,
       CAST ('IPL_R_SOURCE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.ipl_r_source r
UNION ALL
SELECT t.SOURCE, t.abbreviation, t.active_ind, t.effective_date,
       t.expiry_date, t.long_name, t.ppdm_guid, t.remark, t.row_source,
       t.short_name, t.row_changed_by, t.row_changed_date, t.row_created_by,
       t.row_created_date, t.row_quality,
       CAST ('TLM_R_SOURCE' AS VARCHAR2 (30)) AS source_table_name
  FROM ppdm.tlm_r_source t
 WHERE t.SOURCE NOT IN (SELECT i.SOURCE
                          FROM ppdm.ipl_r_source i);

COMMENT ON TABLE PPDM.R_SOURCE IS 'snapshot table for snapshot PPDM.R_SOURCE';

CREATE UNIQUE INDEX PPDM.MV_R_S_PK ON PPDM.R_SOURCE
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

GRANT SELECT ON PPDM.R_SOURCE TO AMT_READ;

GRANT SELECT ON PPDM.R_SOURCE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.R_SOURCE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_SOURCE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.R_SOURCE TO PPDM_OW;

GRANT SELECT ON PPDM.R_SOURCE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_SOURCE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.R_SOURCE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_SOURCE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.R_SOURCE TO UPDATE_OBJECTS;
