-- SCRIPT: Direction_Survey_Spatial_View_Install.sql
--
-- PURPOSE:
--   Installs a summary view for use in generating the spatial layers which show
--   the Directional Survey data.
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Can be executed from SQPLUS or Toad
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   09-Jun-10 R. Masterman  Initial version
--   16-Nov-10 R. Masterman  New query for the view now GeoWiz loadds coord system into station table
--   18-Nov-10 R. Masterman  Dropped Loc Qual and added filter for IHS Loc Quals
--   10-Jan-11 R. Masterman  Converted to just TLM DIR SRVYS (OPTION 3) for now for performance. Keep structure so we can revert back if required.
--   23-Feb-11 R. Masterman  Added KB to the view


-- Create the view
-----------------------------------------------------------------------------------------------------------------------------------
-- OPTION 1 - Full TLM & IHS merged view (Has performance issues until WELL table becomes a local table)
/*
CREATE OR REPLACE VIEW WELL_DIR_SRVY_SPATIAL_FULL AS
SELECT WDSS.UWI, WDSS.LATITUDE, WDSS.LONGITUDE, WDSS.STATION_TVD, WDSS.STATION_MD, W.DEPTH_DATUM_ELEV, WDSS.GEOG_COORD_SYSTEM_ID, WDSS.SURVEY_ID, WDSS.SOURCE 
  FROM WELL_DIR_SRVY_STATION WDSS JOIN WELL W ON WDSS.UWI = W.UWI
 WHERE WDSS.Location_Qualifier = 'MST0305' or WDSS.Location_Qualifier = 'Not Applicable';

GRANT SELECT ON PPDM.WELL_DIR_SRVY_SPATIAL_FULL TO PPDM_READ;

*/
 
-----------------------------------------------------------------------------------------------------------------------------------
-- OPTION 2 - Full TLM & IHS merged view but not using the composite views to improve performance - Still has performance issues on PETT.
/*
CREATE OR REPLACE VIEW WELL_DIR_SRVY_SPATIAL AS
SELECT w.uwi, wdss.latitude, wdss.longitude, wdss.station_tvd,
          wdss.station_md, w.depth_datum_elev, wdss.geog_coord_system_id,
          wdss.survey_id, wdss.SOURCE
     FROM tlm_well_dir_srvy_station wdss JOIN Well W ON w.uwi = wdss.uwi
   UNION ALL
   SELECT w.uwi, wdss.latitude, wdss.longitude, wdss.station_tvd,
          wdss.station_md, w.depth_datum_elev, wdss.geog_coord_system_id,
          wdss.survey_id, wdss.SOURCE
     FROM well_dir_srvy_station@ihsdata.world wdss JOIN Well W ON w.ipl_uwi_local = wdss.uwi
    WHERE WDSS.Location_Qualifier = 'MST0305';
*/

-----------------------------------------------------------------------------------------------------------------------------------
-- OPTION 3 - Just show the TLM data and by-pass the composite views to improve performance 

CREATE OR REPLACE VIEW WELL_DIR_SRVY_SPATIAL AS
SELECT w.uwi, wdss.latitude, wdss.longitude, wdss.station_tvd,
          wdss.station_md, w.depth_datum_elev, wdss.geog_coord_system_id,
          wdss.survey_id, wdss.SOURCE, w.kb_elev
     FROM tlm_well_dir_srvy_station wdss JOIN Well W ON w.uwi = wdss.uwi;

-- Set up Access
GRANT SELECT ON WELL_DIR_SRVY_SPATIAL TO PPDM_BROWSE;

-- Create Synonyms
-- Run for PPDM_READ
CREATE SYNONYM WELL_DIR_SRVY_SPATIAL FOR PPDM.WELL_DIR_SRVY_SPATIAL;

--------------------------------------------------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------------------------------------------------

--  Tests of the standard view
SELECT * FROM WELL_DIR_SRVY_STATION WHERE UWI IN ('143731');  -- 1s  404 rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731');  -- 1s  404 rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('5302');  -- 1s  440 rows  (zero in PETD)
SELECT * FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731','143752','143771');  -- 1s  844 rows  (742 rows in PETD)
SELECT * FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731','143752','14753','143771');  --  (742 rows in PETD) (INCLUDES KB for 143752)
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731','143752');  -- 1s  844 rows  (580 in PETD)
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL;  -- Greater than 10s
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731','143752','14753','143771',  -- 1s  2553 rows  (1260 in PETD)
                                                  '143797','134128','100438','143752',
                                                  '15136','143799','5302','125943','1157',
                                                  '5049','334','136915','15195','1096',
                                                  '963','50104479000','143753') ;
SELECT * FROM WELL_DIR_SRVY_SPATIAL WHERE UWI IN ('143731','143752','14753','143771',  -- 1s  2553 rows  (1260 in PETD)
                                                  '143797','134128','100438','143752',
                                                  '15136','143799','5302','125943','1157',
                                                  '5049','334','136915','15195','1096',
                                                  '963','50104479000','143753') ;


--------------------------------------------------------------------------------------------------------------------------
--  PETD tests of the full TLM & IHS combined view - ONLY IN PETD for now
SELECT * FROM WELL_DIR_SRVY_STATION WHERE UWI IN ('143731');  -- 1s  404 rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731');  -- 1s  404 rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('5302');  -- 1s  zero rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731','143752','143771');  -- 1s  912 rows
SELECT * FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731','143752','14753','143771'); -- 2s 912 rows
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731','143752');  -- 1s  668 rows
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL_FULL; -- Greater then 10s
SELECT count(1) FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731','143752','14753','143771',  -- 3s   1691rows
                                                  '143797','134128','100438','143752',
                                                  '15136','143799','5302','125943','1157',
                                                  '5049','334','136915','15195','1096',
                                                  '963','50104479000','143753') ;
SELECT * FROM WELL_DIR_SRVY_SPATIAL_FULL WHERE UWI IN ('143731','143752','14753','143771',  -- 3s  1691 rows
                                                  '143797','134128','100438','143752',
                                                  '15136','143799','5302','125943','1157',
                                                  '5049','334','136915','15195','1096',
                                                  '963','50104479000','143753') ;

-- End of script 