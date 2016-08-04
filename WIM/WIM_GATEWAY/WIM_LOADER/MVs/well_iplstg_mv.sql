DROP MATERIALIZED VIEW WELL_IPLSTG_MV;
CREATE MATERIALIZED VIEW WELL_IPLSTG_MV (UWI,ABANDONMENT_DATE,ACTIVE_IND,ASSIGNED_FIELD,BASE_NODE_ID,BOTTOM_HOLE_LATITUDE,BOTTOM_HOLE_LONGITUDE,CASING_FLANGE_ELEV,CASING_FLANGE_ELEV_OUOM,COMPLETION_DATE,CONFIDENTIAL_DATE,CONFIDENTIAL_DEPTH,CONFIDENTIAL_DEPTH_OUOM,CONFIDENTIAL_TYPE,CONFID_STRAT_NAME_SET_ID,CONFID_STRAT_UNIT_ID,COUNTRY,COUNTY,CURRENT_CLASS,CURRENT_STATUS,CURRENT_STATUS_DATE,DEEPEST_DEPTH,DEEPEST_DEPTH_OUOM,DEPTH_DATUM,DEPTH_DATUM_ELEV,DEPTH_DATUM_ELEV_OUOM,DERRICK_FLOOR_ELEV,DERRICK_FLOOR_ELEV_OUOM,DIFFERENCE_LAT_MSL,DISCOVERY_IND,DISTRICT,DRILL_TD,DRILL_TD_OUOM,EFFECTIVE_DATE,ELEV_REF_DATUM,EXPIRY_DATE,FAULTED_IND,FINAL_DRILL_DATE,FINAL_TD,FINAL_TD_OUOM,GEOGRAPHIC_REGION,GEOLOGIC_PROVINCE,GROUND_ELEV,GROUND_ELEV_OUOM,GROUND_ELEV_TYPE,INITIAL_CLASS,KB_ELEV,KB_ELEV_OUOM,LEASE_NAME,LEASE_NUM,LEGAL_SURVEY_TYPE,LOCATION_TYPE,LOG_TD,LOG_TD_OUOM,MAX_TVD,MAX_TVD_OUOM,NET_PAY,NET_PAY_OUOM,OLDEST_STRAT_AGE,OLDEST_STRAT_NAME_SET_AGE,OLDEST_STRAT_NAME_SET_ID,OLDEST_STRAT_UNIT_ID,OPERATOR,PARENT_RELATIONSHIP_TYPE,PARENT_UWI,PLATFORM_ID,PLATFORM_SF_TYPE,PLOT_NAME,PLOT_SYMBOL,PLUGBACK_DEPTH,PLUGBACK_DEPTH_OUOM,PPDM_GUID,PRIMARY_SOURCE,PROFILE_TYPE,PROVINCE_STATE,REGULATORY_AGENCY,REMARK,RIG_ON_SITE_DATE,RIG_RELEASE_DATE,ROTARY_TABLE_ELEV,SOURCE_DOCUMENT,SPUD_DATE,STATUS_TYPE,SUBSEA_ELEV_REF_TYPE,SURFACE_LATITUDE,SURFACE_LONGITUDE,SURFACE_NODE_ID,TAX_CREDIT_CODE,TD_STRAT_AGE,TD_STRAT_NAME_SET_AGE,TD_STRAT_NAME_SET_ID,TD_STRAT_UNIT_ID,WATER_ACOUSTIC_VEL,WATER_ACOUSTIC_VEL_OUOM,WATER_DEPTH,WATER_DEPTH_DATUM,WATER_DEPTH_OUOM,WELL_EVENT_NUM,WELL_GOVERNMENT_ID,WELL_INTERSECT_MD,WELL_NAME,WELL_NUM,WELL_NUMERIC_ID,WHIPSTOCK_DEPTH,WHIPSTOCK_DEPTH_OUOM,ROW_CHANGED_BY,ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,ROW_QUALITY,X_CURRENT_LICENSEE,X_EVENT_NUM,X_EVENT_NUM_MAX,X_OFFSHORE_IND,X_ONPROD_DATE,X_ONINJECT_DATE,X_POOL,X_UWI_SORT,X_UWI_DISPLAY,X_TD_TVD,X_PLUGBACK_TVD,X_WHIPSTOCK_TVD,X_ORIGINAL_STATUS,X_ORIGINAL_UNIT,X_PREVIOUS_STATUS,CONFID_STRAT_AGE,X_SURFACE_ABANDON_TYPE,GEOG_COORD_SYSTEM_ID,LOCATION_QUALIFIER,X_CONFIDENTIAL_PERIOD,X_PRIMARY_BOREHOLE_UWI,X_DIGITAL_LOG_IND,X_RASTER_LOG_IND,X_PLAY_ID,X_PLAY_TYPE)
TABLESPACE APP_DATA
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 30/09/2013 9:13:47 AM (QP5 v5.227.12220.39754) */
SELECT *
  FROM ( (SELECT * FROM well@c_talisman_ihsdata));


COMMENT ON MATERIALIZED VIEW WELL_IPLSTG_MV IS 'snapshot table for snapshot WIM_LOADER.WELL_IPLSTG_MV';

CREATE INDEX WIPL_BASENODE_ID ON WELL_IPLSTG_MV
(BASE_NODE_ID)
LOGGING
TABLESPACE APP_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE INDEX WIPL_UWI ON WELL_IPLSTG_MV
(UWI)
LOGGING
TABLESPACE APP_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;