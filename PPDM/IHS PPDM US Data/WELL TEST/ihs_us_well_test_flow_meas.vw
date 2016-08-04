DROP VIEW PPDM.IHS_US_WELL_TEST_FLOW_MEAS;

/* Formatted on 4/2/2013 11:40:30 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_FLOW_MEAS
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   MEASUREMENT_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   FLOW_DURATION,
   FLOW_DURATION_OUOM,
   FLUID_TYPE,
   MEASUREMENT_PRESSURE,
   MEASUREMENT_PRESSURE_OUOM,
   MEASUREMENT_TIME,
   MEASUREMENT_TIME_OUOM,
   MEASUREMENT_VOLUME,
   MEASUREMENT_VOLUME_OUOM,
   MEASUREMENT_VOLUME_UOM,
   PERIOD_OBS_NO,
   PERIOD_TYPE,
   PPDM_GUID,
   REMARK,
   SURFACE_CHOKE_DIAMETER,
   SURFACE_CHOKE_DIAMETER_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT wv.uwi,
          wV.SOURCE,
          wtfm.test_type,
          wtfm.run_num,
          wtfm.test_num,
          wtfm.measurement_obs_no,
          wtfm.active_ind,
          wtfm.effective_date,
          wtfm.expiry_date,
          wtfm.flow_duration,
          wtfm.flow_duration_ouom,
          wtfm.fluid_type,
          wtfm.measurement_pressure,
          wtfm.measurement_pressure_ouom,
          wtfm.measurement_time,
          wtfm.measurement_time_ouom,
          wtfm.measurement_volume,
          wtfm.measurement_volume_ouom,
          wtfm.measurement_volume_uom,
          wtfm.period_obs_no,
          wtfm.period_type,
          wtfm.ppdm_guid,
          wtfm.remark,
          wtfm.surface_choke_diameter,
          wtfm.surface_choke_diameter_ouom,
          wtfm.row_changed_by,
          wtfm.row_changed_date,
          wtfm.row_created_by,
          wtfm.row_created_date,
          wtfm.row_quality,
          wtfm.province_state
     FROM well_test_flow_meas@C_TALISMAN_US_IHSDATAQ wtfm, well_version wv
    WHERE     wv.well_num = wtfm.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_FLOW_MEAS TO PPDM_RO;
