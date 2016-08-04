-- SCRIPT: Mview_refresh_Check.sql
--
-- PURPOSE:
--   This script installs a procedure to check and refresh the primary Mviews on a
--   PET* database. This should be run on each PET* database to create the 
--   procedure and submit a job to run it each week prior to the load.
--
--  *** This should become part of the MVIEW_UTILS package once proven ***
--
-- DEPENDENCIES
--   WIM built in package TLM_MVIEW_UTILS and Oracle DBMS_JOBS package
--
-- EXECUTION:
--   Usually run through TOAD or SQLplus as PPDM on PET*
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   18-Dec-09  R. Masterman  Initial version
--   20-Jan-10  R. Masterman  Restructured and added remainder of the mviews
--

----------------------------------------------------------------------------------
-- Procedure to check each Mview log and refresh the mview if required.
----------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE Mview_Refresh_Check IS

  --  Local procedure to check the log of one specified MVIEW and refresh if required
  procedure UPDATE_MVIEW (MVIEW     in VARCHAR2,
                          MVIEW_LOG in VARCHAR2) is

     Log_Count NUMBER(14) := 0;
     SQL_TEXT  VARCHAR(1000) := '';

  begin

    -- Assemble the log check statement using the MVIEW log name passed in
    SQL_TEXT := 'SELECT COUNT(1) FROM ppdm37.mlog$_' || MVIEW_LOG || '@tlm37.world';
    execute immediate SQL_TEXT into Log_Count;

    --  Record the size of the MVIEW log
    tlm_process_logger.info ('MVIEW_REFRESH_CHECK: ' || MVIEW_LOG || ' log size: ' || TO_CHAR(Log_Count));

    --  If the log isn't empty then refresh the MVIEW using the Mview logs
    IF Log_Count > 0 THEN
     TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM', MVIEW ,'F');
    END IF;

  end UPDATE_MVIEW;



BEGIN

  -- Note that Refresh check is starting
  tlm_process_logger.info ('MVIEW_REFRESH_CHECK: Started');

  --  For each Mview, check the log and if it isn't empty run a refresh
  UPDATE_MVIEW('WELL','WELL');
  UPDATE_MVIEW('WELL_ALIAS','WELL_ALIAS');
  UPDATE_MVIEW('WELL_VERSION','WELL_VERSION');
  UPDATE_MVIEW('WELL_NODE','WELL_NODE');
  UPDATE_MVIEW('WELL_NODE_VERSION','WELL_NODE_VERSION');
  UPDATE_MVIEW('WELL_LICENSE','WELL_LICENSE');
  UPDATE_MVIEW('WELL_NODE_M_B','WELL_NODE_M_B');
  UPDATE_MVIEW('WELL_STATUS','WELL_STATUS');
  UPDATE_MVIEW('POOL','POOL');
  UPDATE_MVIEW('IPL_BUSINESS_ASSOCIATE','BUSINESS_ASSOCIATE');
  UPDATE_MVIEW('IPL_R_ALIAS_REASON_TYPE','R_ALIAS_REASON_TYPE');
  UPDATE_MVIEW('IPL_R_ALIAS_TYPE','R_ALIAS_TYPE');
  UPDATE_MVIEW('R_COUNTRY','R_COUNTRY');
  UPDATE_MVIEW('R_COUNTY','R_COUNTY');
  UPDATE_MVIEW('R_DISTRICT','R_DISTRICT');
  UPDATE_MVIEW('R_GEOLOGIC_PROVINCE','R_GEOLOGIC_PROVINCE');
  UPDATE_MVIEW('R_PLOT_SYMBOL','R_PLOT_SYMBOL');
  UPDATE_MVIEW('R_PROVINCE_STATE','R_PROVINCE_STATE');
  UPDATE_MVIEW('IPL_R_SOURCE','R_SOURCE');
  UPDATE_MVIEW('R_WATER_DATUM','R_WATER_DATUM');
  UPDATE_MVIEW('R_WELL_CLASS','R_WELL_CLASS');
  UPDATE_MVIEW('R_WELL_STATUS','R_WELL_STATUS');
  UPDATE_MVIEW('STRAT_UNIT','STRAT_UNIT');
  UPDATE_MVIEW('PROD_STRING','PROD_STRING');

  -- The following MViews are local and merge the IPL mviews with
  -- local tables. They have no logs so have to be complete refreshed
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','BUSINESS_ASSOCIATE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_REASON_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_SOURCE','C');

  -- Note that the Refresh check is done
  tlm_process_logger.info ('MVIEW_REFRESH_CHECK: Complete');
 
END;


--  Submit a job to check and refresh all of the main Mviews NOW
DECLARE
  JOBNO BINARY_INTEGER;
BEGIN
 DBMS_JOB.SUBMIT (JOB=>JOBNO,
                    WHAT=>'MVIEW_REFRESH_CHECK;');
 commit;
END;


--  Sumbit a job to check and refresh all of the main Mviews once a week 
--  ready for the load. Run this on a Friday before 3pm to set up.
DECLARE
  JOBNO BINARY_INTEGER;
BEGIN
 DBMS_JOB.SUBMIT (JOB=>JOBNO,
                    WHAT=>'MVIEW_REFRESH_CHECK;',
                    NEXT_DATE=>TRUNC(SYSDATE)+7+15/24,
                    INTERVAL=>'sysdate+7');    
 commit;
END;


--  Submit a job to check and refresh all of the main Mviews once a week 
--  AFTER the load. Run this on a Friday to set up the first time so it runs on
-- Sunday at midday. (may need longer to run if a big PID load?)
DECLARE
  JOBNO BINARY_INTEGER;
BEGIN
 DBMS_JOB.SUBMIT (JOB=>JOBNO,
                    WHAT=>'MVIEW_REFRESH_CHECK;',
                    NEXT_DATE=>TRUNC(SYSDATE)+2.5,
                    INTERVAL=>'sysdate+7');    
 commit;
END;


-- See that the jobs made it to the queue OK
select job, last_date, next_date, what, interval, broken from all_jobs order by next_date; 

-- Check the log for messages too - should see the checks have been started
select klass, code, text, session_id, row_created_by, to_char(row_created_on)
  from tlm_process_log
 where row_created_on > sysdate - 7  
 order by row_created_on desc;

-- End of script


 
