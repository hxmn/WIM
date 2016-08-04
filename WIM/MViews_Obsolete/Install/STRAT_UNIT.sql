

DROP MATERIALIZED VIEW PPDM.STRAT_UNIT;
CREATE MATERIALIZED VIEW PPDM.STRAT_UNIT 
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
/* Formatted on 2010/05/29 13:48 (Formatter Plus v4.8.8) */
SELECT s.strat_name_set_id, s.strat_unit_id, s.abbreviation, s.active_ind,
       s.area_id, s.area_type, s.business_associate, s.confidence_id,
       s.current_status_date, s.description, s.effective_date, s.expiry_date,
       s.fault_type, s.form_code, s.group_code, s.long_name,
       s.ordinal_age_code, s.ppdm_guid, s.preferred_ind, s.remark,
       s.short_name, s.SOURCE, s.strat_interpret_method, s.strat_status,
       s.strat_type, s.strat_unit_type, s.x_strat_unit_id_num, s.x_base_age,
       s.row_changed_by, s.row_changed_date, s.row_created_by,
       s.row_created_date, s.row_quality, s.x_lithology
  FROM strat_unit@"TLM37.WORLD" s;

COMMENT ON TABLE PPDM.STRAT_UNIT IS 'snapshot table for snapshot PPDM.STRAT_UNIT';

CREATE UNIQUE INDEX PPDM.STU_PK ON PPDM.STRAT_UNIT
(STRAT_NAME_SET_ID, STRAT_UNIT_ID)
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

GRANT SELECT ON PPDM.STRAT_UNIT TO AMT_READ;

GRANT SELECT ON PPDM.STRAT_UNIT TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.STRAT_UNIT TO GEOWIZ;

GRANT SELECT ON PPDM.STRAT_UNIT TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.STRAT_UNIT TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.STRAT_UNIT TO PPDM_CHANGE;

GRANT SELECT ON PPDM.STRAT_UNIT TO PPDM_OW;

GRANT SELECT ON PPDM.STRAT_UNIT TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.STRAT_UNIT TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.STRAT_UNIT TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.STRAT_UNIT TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.STRAT_UNIT TO UPDATE_OBJECTS;
