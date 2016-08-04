
DROP MATERIALIZED VIEW PPDM.WELL;
CREATE MATERIALIZED VIEW PPDM.WELL 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    10
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
            PCTFREE    10
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
/* Formatted on 2010/05/29 13:49 (Formatter Plus v4.8.8) */
SELECT w.uwi, w.abandonment_date, w.active_ind, w.assigned_field,
       w.base_node_id, w.bottom_hole_latitude, w.bottom_hole_longitude,
       w.casing_flange_elev, w.casing_flange_elev_ouom, w.completion_date,
       w.confidential_date, w.confidential_depth, w.confidential_depth_ouom,
       w.confidential_type, w.confid_strat_name_set_id,
       w.confid_strat_unit_id, w.country, w.county, w.current_class,
       w.current_status, w.current_status_date, w.deepest_depth,
       w.deepest_depth_ouom, w.depth_datum, w.depth_datum_elev,
       w.depth_datum_elev_ouom, w.derrick_floor_elev,
       w.derrick_floor_elev_ouom, w.difference_lat_msl, w.discovery_ind,
       w.district, w.drill_td, w.drill_td_ouom, w.effective_date,
       w.elev_ref_datum, w.expiry_date, w.faulted_ind, w.final_drill_date,
       w.final_td, w.final_td_ouom, w.geographic_region, w.geologic_province,
       w.ground_elev, w.ground_elev_ouom, w.ground_elev_type, w.initial_class,
       w.kb_elev, w.kb_elev_ouom, w.lease_name, w.lease_num,
       w.legal_survey_type, w.location_type, w.log_td, w.log_td_ouom,
       w.max_tvd, w.max_tvd_ouom, w.net_pay, w.net_pay_ouom,
       w.oldest_strat_age, w.oldest_strat_name_set_age,
       w.oldest_strat_name_set_id, w.oldest_strat_unit_id, w.OPERATOR,
       w.parent_relationship_type, w.parent_uwi, w.platform_id,
       w.platform_sf_type, w.plot_name, w.plot_symbol, w.plugback_depth,
       w.plugback_depth_ouom, w.ppdm_guid, w.primary_source, w.profile_type,
       w.province_state, w.regulatory_agency, w.remark, w.rig_on_site_date,
       w.rig_release_date, w.rotary_table_elev, w.source_document,
       w.spud_date, w.status_type, w.subsea_elev_ref_type, w.surface_latitude,
       w.surface_longitude, w.surface_node_id, w.tax_credit_code,
       w.td_strat_age, w.td_strat_name_set_age, w.td_strat_name_set_id,
       w.td_strat_unit_id, w.water_acoustic_vel, w.water_acoustic_vel_ouom,
       w.water_depth, w.water_depth_datum, w.water_depth_ouom,
       w.well_event_num, w.well_government_id, w.well_intersect_md,
       w.well_name, w.well_num, w.well_numeric_id, w.whipstock_depth,
       w.whipstock_depth_ouom, w.ipl_licensee, w.ipl_offshore_ind,
       w.ipl_pidstatus, w.ipl_prstatus, w.ipl_orstatus, w.ipl_onprod_date,
       w.ipl_oninject_date, w.ipl_confidential_strat_age, w.ipl_pool,
       w.ipl_last_update, w.ipl_uwi_sort, w.ipl_uwi_display, w.ipl_td_tvd,
       w.ipl_plugback_tvd, w.ipl_whipstock_tvd, w.ipl_water_tvd,
       w.ipl_alt_source, w.ipl_xaction_code, w.row_changed_by,
       w.row_changed_date, w.row_created_by, w.row_created_date, w.ipl_basin,
       w.ipl_block, w.ipl_area, w.ipl_twp, w.ipl_tract, w.ipl_lot, w.ipl_conc,
       w.ipl_uwi_local, w.row_quality
  FROM well@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL IS 'snapshot table for snapshot PPDM.WELL';

CREATE INDEX PPDM.W_BA_IDX ON PPDM.WELL
(OPERATOR)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_BA_IDX2 ON PPDM.WELL
(REGULATORY_AGENCY)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_BHLL_IDX ON PPDM.WELL
(BOTTOM_HOLE_LONGITUDE, BOTTOM_HOLE_LATITUDE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_FLD_IDX ON PPDM.WELL
(ASSIGNED_FIELD)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_ID04 ON PPDM.WELL
(IPL_POOL, BASE_NODE_ID, UWI)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_ID05 ON PPDM.WELL
(IPL_LICENSEE, BASE_NODE_ID, UWI)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_ID15 ON PPDM.WELL
(COUNTRY, BASE_NODE_ID)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_ID16 ON PPDM.WELL
(WELL_NAME)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_IPL_LOCAL_UWI_IDX ON PPDM.WELL
(IPL_UWI_LOCAL)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE UNIQUE INDEX PPDM.W_PK ON PPDM.WELL
(UWI)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_C1_IDX ON PPDM.WELL
(COUNTRY)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_CT3_IDX ON PPDM.WELL
(CONFIDENTIAL_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_D_IDX ON PPDM.WELL
(DISTRICT)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_LST1_IDX ON PPDM.WELL
(LEGAL_SURVEY_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_LT1_IDX ON PPDM.WELL
(LOCATION_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_PS1_IDX ON PPDM.WELL
(PLOT_SYMBOL)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_PS3_IDX ON PPDM.WELL
(COUNTRY, PROVINCE_STATE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_S_IDX ON PPDM.WELL
(PRIMARY_SOURCE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WC_IDX ON PPDM.WELL
(INITIAL_CLASS)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WC_IDX2 ON PPDM.WELL
(CURRENT_CLASS)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WDT_IDX2 ON PPDM.WELL
(DEPTH_DATUM)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WPT_IDX ON PPDM.WELL
(PROFILE_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WR_IDX ON PPDM.WELL
(PARENT_RELATIONSHIP_TYPE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_R_WS_IDX ON PPDM.WELL
(STATUS_TYPE, CURRENT_STATUS)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_SRCD_IDX ON PPDM.WELL
(SOURCE_DOCUMENT)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_STU_IDX5 ON PPDM.WELL
(OLDEST_STRAT_NAME_SET_AGE, OLDEST_STRAT_AGE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_TR_WS_IDX ON PPDM.WELL
(CURRENT_STATUS)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE UNIQUE INDEX PPDM.W_UK1 ON PPDM.WELL
(WELL_NUMERIC_ID, UWI)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_WN_IDX ON PPDM.WELL
(SURFACE_NODE_ID)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_WN_IDX2 ON PPDM.WELL
(BASE_NODE_ID)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

CREATE INDEX PPDM.W_W_IDX ON PPDM.WELL
(PARENT_UWI)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
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

GRANT SELECT ON PPDM.WELL TO AMT_READ;

GRANT SELECT ON PPDM.WELL TO DATA_ACCESS_COAT_CHECK;

GRANT SELECT ON PPDM.WELL TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL TO GEOL_REC_WL;

GRANT SELECT ON PPDM.WELL TO GEOWIZ;

GRANT SELECT ON PPDM.WELL TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.WELL TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL TO PPDM_OW;

GRANT SELECT ON PPDM.WELL TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL TO UPDATE_OBJECTS;
