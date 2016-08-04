-- SCRIPT: Load_check_test.sql
--
-- PURPOSE:
--   Check the content of the test tables BEFORE loading into the production database.
--   For example, check the 300IPL test load before loading into Production.
--
--   See also the Load_check_staging.sql and Load_check_prod scripts for checks to run
--   before a staging load and after a production load.
--
-- DEPENDENCIES
--   Calls embedded scripts: Sub_*.sql
--
-- EXECUTION:
--   Runs in SQL*PLUS with a parameter to define the source of the load.
--   Can take up to an hour to run.
--   Run as TEST (Talisman37@IHSDATAQ) and check against PRODUCTION (TALISMAN37@IHSDATA) or STAGING
--
--   Syntax:
--    @Load_check_test.sql <source>
-
--    e.g.   
--    @Load_check_test.sql 450PID
--    
--
-- HISTORY:
--   17-Aug-09  R. Masterman  Initial version based on Ralph's scripts and 
--                            Floy and Neetu's notes
--   28-Aug-09  R. Masterman  Expanded to include extra checks and operate for any load type
--   31-Aug-09  R. Masterman  Factored out the common checks to a separate script
--    8-Sep-09  R. Masterman  Restructured to focus on Staging only
--   29-Sep-09  R. Masterman  Added PROBE staging and corrected PID staging reference
--   18-May-10  R. Masterman  Schema & DB link changes for new IHS environment
--   25-May-10  R. Masterman  Assume run from TALISMAN37@IHSDATA

-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'Load_check_test'

-- Set up logging
set echo off
set trimspool on
set serveroutput on
set feedback on
set time on
set pagesize 50

--  Set the data source (If not provided as a parameter then the user will be prompted)
prompt Enter the code for the data source (e.g. 450PID)
set termout off
define source = &1
set termout on

----------------------------------------------------------------------------------------------
--  Use the source to determine which schemas to compare
----------------------------------------------------------------------------------------------

var control_schema VARCHAR2(30);
var control_link   VARCHAR2(128);
var load_schema    VARCHAR2(30);
var load_link      VARCHAR2(128);

begin

  --  Always check the test schema
  :load_schema := 'Talisman37';
  :load_link   := '@TEST.IHSENERGY.COM';

  --  Select a schema to compare the load against
  if '&&source' = '450PID' then
    :control_schema := 'C_TLM_PID_STG';
    :control_link   := '@PID_STG.IHSENERGY.COM';
  elsif '&&source' = '500PRB' then
    :control_schema    := 'C_TLM_PROBE_STG';
    :control_link   := '@PRB_STG.IHSENERGY.COM';
  else
    -- If not a staging load compare with production
    :control_schema    := 'Talisman37';
    :control_link   := '';
  end if;
end;
/

-- Define the SQL*PLUS variables to use
column cs new_value control_schema noprint
column cl new_value control_link noprint
column ls new_value load_schema noprint
column ll new_value load_link noprint
select :control_schema cs from dual;
select :control_link   cl from dual;
select :load_schema    ls from dual;
select :load_link      ll from dual;

-- Start logging
variable spool_file varchar2(100);
execute :spool_file := '&&source' || '_&&script_name' || '_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

prompt *****************************************************************************
prompt
prompt    Running the &&script_name script for &&source source data.
prompt
prompt     Loaded into:   &&load_schema&&load_link
prompt     Compared to:   &&control_schema&&control_link
prompt
prompt    Logging to file: &&spool_file
prompt
prompt *****************************************************************************

-- Log who is running this and when
prompt Running as user:
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;

set echo on

--  See what is changing in this load
@Sub_update_checks.sql

--  Run the common load checks
@Sub_common_checks.sql

--  Run the direct load checks
@Sub_direct_checks.sql

--  Run the source specific checks
@Sub_&&source..sql

--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;

prompt ******************************************************************************
prompt
prompt    Script: &&script_name for &&source data loaded in the &&load_schema schema complete
prompt
prompt    Data logged to file: &&spool_file
prompt
prompt ******************************************************************************

spool off
quit
