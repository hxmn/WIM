-- SCRIPT: CWS_WIM_Compare_MView_Install.sql
--
-- PURPOSE:
--   Creates the Mview for listing the differences between the CWS US wells and the WIM US wells
--
--  Assumptions:
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Run as PPDM users on the PET* databases
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   21-Jul-10 R. Masterman  Initial version
--   25-May-11 R. Masterman  Extended comparison to allows for NULLs too
--   21-Jun-11 R. Masterman  Removed comparison for US well names as we know they will be different 

-- *****************
-- Run as PPDM User
-- *****************

DROP MATERIALIZED VIEW CWS_WIM_Compare_MV;
CREATE MATERIALIZED VIEW CWS_WIM_Compare_MV
   BUILD DEFERRED  
 AS
 /*  CWS requested to exlude this check as they know the CWS names will be different - append TEUSA to the name 
  SELECT   wv.uwi, 'WELL_NAME' AS difference, cwcd.well_nm cws_value,
            wv.well_name wim_value
       FROM well_current_data@cws.world cwcd, well_version wv
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.country_cd = 'US'
        AND cwcd.well_nm != wv.well_name
   UNION ALL    */
   SELECT   wv.uwi, 'SURF_LAT' AS difference,
            TO_CHAR (cwn.well_node_latitude) cws_value, TO_CHAR (wv.surface_latitude) wim_value
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.country_cd = 'US'
        AND cwn.well_node_id = cwcd.surface_node_id
        AND NVL(TO_CHAR(cwn.well_node_latitude),'NULL') != NVL(TO_CHAR(wv.surface_latitude),'NULL')
   UNION ALL
   SELECT   wv.uwi, 'SURF_LON' AS difference,
            TO_CHAR (cwn.well_node_longitude), TO_CHAR (wv.surface_longitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.country_cd = 'US'
        AND cwn.well_node_id = cwcd.base_node_id
        AND NVL(TO_CHAR(cwn.well_node_longitude),'NULL') != NVL(TO_CHAR(wv.surface_longitude),'NULL')
   UNION ALL
   SELECT   wv.uwi, 'BH_LAT' AS difference, TO_CHAR (cwn.well_node_latitude),
            TO_CHAR (wv.bottom_hole_latitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.country_cd = 'US'
        AND cwn.well_node_id = cwcd.base_node_id
        AND NVL(TO_CHAR(cwn.well_node_latitude),'NULL') != NVL(TO_CHAR(wv.bottom_hole_latitude),'NULL')
   UNION ALL
   SELECT   wv.uwi, 'BH_LON' AS difference, TO_CHAR (cwn.well_node_longitude),
            TO_CHAR (wv.bottom_hole_longitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.country_cd = 'US'
        AND cwn.well_node_id = cwcd.base_node_id
        AND NVL(TO_CHAR(cwn.well_node_longitude),'NULL') != NVL(TO_CHAR(wv.bottom_hole_longitude),'NULL')
   UNION ALL
   SELECT   wv.uwi, 'SPUD' AS difference, TO_CHAR (cw.well_spud_dt),
            TO_CHAR (wv.spud_date)
       FROM well_current_data@cws.world cwcd,
            well_version wv,
            well@cws.world cw
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.well_id = cw.well_id
        AND cwcd.country_cd = 'US'
        AND NVL(TO_CHAR(cw.well_spud_dt),'NULL') != NVL(TO_CHAR(wv.spud_date),'NULL')
   UNION ALL
   SELECT   wv.uwi, 'RIGREL' AS difference, TO_CHAR (cw.well_rig_release_dt),
            TO_CHAR (wv.rig_release_date)
       FROM well_current_data@cws.world cwcd,
            well_version wv,
            well@cws.world cw
      WHERE wv.country = '7US'
        AND wv.SOURCE = '450PID'
        AND cwcd.well_id = wv.uwi
        AND cwcd.well_id = cw.well_id
        AND cwcd.country_cd = 'US'
        AND NVL(TO_CHAR(cw.well_rig_release_dt),'NULL') != NVL(TO_CHAR(wv.rig_release_date),'NULL')
;

-- Set the refresh period - Refreshed each day at 5am to be ready for daytime use
--  This step creates an Oracle job to refresh the MVIEW - the steps below alter this job to set it up for TIS use 
ALTER MATERIALIZED VIEW CWS_WIM_Compare_MV
  REFRESH NEXT (TRUNC(SYSDATE+1)+5/24);

-- Update the job to set it to run as TLM logged refresh 
--  Find the new job create by the ALTER command above
select job, last_date, this_date, next_date, what, interval, broken, failures from all_jobs order by next_date;

--  Replace ALL occurances of job number with the job number from the new job just created for the MVIEW
execute dbms_job.what(3262,'PPDM.TLM_MVIEW_UTIL.FRESHEN_ONE_MVIEW(3262,''PPDM'',''CWS_WIM_COMPARE_MV'',''C'');');

--  Set the refresh interval (Substitute the job number)
execute dbms_job.interval(3262,'TRUNC(SYSDATE+7)+5/24');

--  Force it to run now to test it (Substitute the job number & set the date to few minutes away)
execute dbms_job.next_date(3262,to_date('27/6/2011:11:20AM','dd/mm/yyyy:hh:miam'));
commit;

-- Check created OK
select * from tlm_process_log where row_created_on < sysdate - 1 order by row_created_on desc;


-- Create indexes
CREATE INDEX PPDM.CWC_UWI ON CWS_WIM_Compare_MV
(UWI)
NOLOGGING;

--  Access rights
GRANT SELECT ON CWS_WIM_Compare_MV to PPDM_READ;


-- Test it in PPDM
select * from PPDM.CWS_WIM_Compare_MV;


-- End of Script
