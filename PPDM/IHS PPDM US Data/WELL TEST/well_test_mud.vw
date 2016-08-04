DROP VIEW PPDM.WELL_TEST_MUD;

/* Formatted on 4/2/2013 11:41:03 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_TEST_MUD
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   MUD_TYPE,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   FILTRATE_RESISTIVITY,
   FILTRATE_RESISTIVITY_OUOM,
   FILTRATE_SALINITY,
   FILTRATE_SALINITY_OUOM,
   FILTRATE_SALINITY_UOM,
   FILTRATE_TEMPERATURE,
   FILTRATE_TEMPERATURE_OUOM,
   MUD_PH,
   MUD_RESISTIVITY,
   MUD_RESISTIVITY_OUOM,
   MUD_SALINITY,
   MUD_SALINITY_OUOM,
   MUD_SALINITY_UOM,
   MUD_SAMPLE_TYPE,
   MUD_TEMPERATURE,
   MUD_TEMPERATURE_OUOM,
   MUD_VISCOSITY,
   MUD_VISCOSITY_OUOM,
   MUD_WEIGHT,
   MUD_WEIGHT_OUOM,
   MUD_WEIGHT_UOM,
   PPDM_GUID,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT "UWI",
          "SOURCE",
          "TEST_TYPE",
          "RUN_NUM",
          "TEST_NUM",
          "MUD_TYPE",
          "ACTIVE_IND",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "FILTRATE_RESISTIVITY",
          "FILTRATE_RESISTIVITY_OUOM",
          "FILTRATE_SALINITY",
          "FILTRATE_SALINITY_OUOM",
          "FILTRATE_SALINITY_UOM",
          "FILTRATE_TEMPERATURE",
          "FILTRATE_TEMPERATURE_OUOM",
          "MUD_PH",
          "MUD_RESISTIVITY",
          "MUD_RESISTIVITY_OUOM",
          "MUD_SALINITY",
          "MUD_SALINITY_OUOM",
          "MUD_SALINITY_UOM",
          "MUD_SAMPLE_TYPE",
          "MUD_TEMPERATURE",
          "MUD_TEMPERATURE_OUOM",
          "MUD_VISCOSITY",
          "MUD_VISCOSITY_OUOM",
          "MUD_WEIGHT",
          "MUD_WEIGHT_OUOM",
          "MUD_WEIGHT_UOM",
          "PPDM_GUID",
          "REMARK",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS EXTENSIONS
          NULL AS "PROVINCE_STATE"
     FROM tlm_well_test_mud
   UNION ALL
   SELECT wtmud.uwi,
          wtmud.SOURCE,
          wtmud.test_type,
          wtmud.run_num,
          wtmud.test_num,
          wtmud.mud_type,
          wtmud.active_ind,
          wtmud.effective_date,
          wtmud.expiry_date,
          wtmud.filtrate_resistivity,
          wtmud.filtrate_resistivity_ouom,
          wtmud.filtrate_salinity,
          wtmud.filtrate_salinity_ouom,
          wtmud.filtrate_salinity_uom,
          wtmud.filtrate_temperature,
          wtmud.filtrate_temperature_ouom,
          wtmud.mud_ph,
          wtmud.mud_resistivity,
          wtmud.mud_resistivity_ouom,
          wtmud.mud_salinity,
          wtmud.mud_salinity_ouom,
          wtmud.mud_salinity_uom,
          wtmud.mud_sample_type,
          wtmud.mud_temperature,
          wtmud.mud_temperature_ouom,
          wtmud.mud_viscosity,
          wtmud.mud_viscosity_ouom,
          wtmud.mud_weight,
          wtmud.mud_weight_ouom,
          wtmud.mud_weight_uom,
          wtmud.ppdm_guid,
          wtmud.remark,
          wtmud.row_changed_by,
          wtmud.row_changed_date,
          wtmud.row_created_by,
          wtmud.row_created_date,
          wtmud.row_quality,
          -- IHS EXTENSIONS
          wtmud.province_state
     FROM IHS_CDN_WELL_TEST_mud wtmud
   UNION ALL
   SELECT iuwtm.uwi,
          iuwtm.SOURCE,
          iuwtm.test_type,
          iuwtm.run_num,
          iuwtm.test_num,
          iuwtm.mud_type,
          iuwtm.active_ind,
          iuwtm.effective_date,
          iuwtm.expiry_date,
          iuwtm.filtrate_resistivity,
          iuwtm.filtrate_resistivity_ouom,
          iuwtm.filtrate_salinity,
          iuwtm.filtrate_salinity_ouom,
          iuwtm.filtrate_salinity_uom,
          iuwtm.filtrate_temperature,
          iuwtm.filtrate_temperature_ouom,
          iuwtm.mud_ph,
          iuwtm.mud_resistivity,
          iuwtm.mud_resistivity_ouom,
          iuwtm.mud_salinity,
          iuwtm.mud_salinity_ouom,
          iuwtm.mud_salinity_uom,
          iuwtm.mud_sample_type,
          iuwtm.mud_temperature,
          iuwtm.mud_temperature_ouom,
          iuwtm.mud_viscosity,
          iuwtm.mud_viscosity_ouom,
          iuwtm.mud_weight,
          iuwtm.mud_weight_ouom,
          iuwtm.mud_weight_uom,
          iuwtm.ppdm_guid,
          iuwtm.remark,
          iuwtm.row_changed_by,
          iuwtm.row_changed_date,
          iuwtm.row_created_by,
          iuwtm.row_created_date,
          iuwtm.row_quality,
          -- IHS EXTENSIONS
          iuwtm.province_state
     FROM IHS_US_WELL_TEST_mud iuwtm;


DROP SYNONYM DATA_FINDER.WELL_TEST_MUD;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_MUD FOR PPDM.WELL_TEST_MUD;


DROP SYNONYM EDIOS_ADMIN.WELL_TEST_MUD;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_MUD FOR PPDM.WELL_TEST_MUD;


DROP SYNONYM PPDM.WTM;

CREATE OR REPLACE SYNONYM PPDM.WTM FOR PPDM.WELL_TEST_MUD;



GRANT SELECT ON PPDM.WELL_TEST_MUD TO PPDM_RO;
