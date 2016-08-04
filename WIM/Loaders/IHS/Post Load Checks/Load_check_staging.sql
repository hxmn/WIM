-- SCRIPT: Load_check_staging.sql
--
-- PURPOSE:
--   Check the content of the staging tables BEFORE loading into a target database.
--   For example, check the PID staging tables before loading into TEST or Production.
--
--   See also the Load_check_test.sql and Load_check_prod scripts for checks to run
--   after a load into TEST or PRODUCTION.
--
-- DEPENDENCIES
--   Calls embedded scripts: Sub_load_check*.sql
--
-- EXECUTION:
--   Runs in SQL*PLUS with a parameter to define the source of the load.
--   Can take up to an hour to run.
--   Run as TEST (Talisman37@IHSDATAQ) and check against STAGING.
--
--   Syntax:
--    @Load_check_staging.sql <source>
-
--    e.g.   
--    @Load_check_staging.sql 450PID
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
define script_name = 'Load_check_staging'

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
  --  Staging is always compared to production - Assume running from IHSDATA so no link
  :control_schema := 'TALISMAN37';
  :control_link   := '';

  --  Select a staging schema to check
  if '&&source' = '450PID' then
    :load_schema    := 'C_TLM_PID_STG';
    :load_link   := '@PID_STG.IHSENERGY.COM';
  elsif '&&source' = '500PRB' then
    :load_schema    := 'C_TLM_PROBE_STG';
    :load_link   := '@PRB_STG.IHSENERGY.COM';
  else
    -- Assume TEST is used as the staging database
    :load_schema    := 'Talisman37';
    :load_link   := '@TEST.IHSENERGY.COM';
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

--  Run the staging specific checks
@Sub_staging.sql

--  Run the source specific checks
@Sub_&&source..sql




--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;

prompt ******************************************************************************
prompt
prompt    Script: &&script_name for &&source data loaded in the &&load_schema schema complete.
prompt
prompt    Data logged to file: &&spool_file
prompt
prompt ******************************************************************************

spool off
quit
