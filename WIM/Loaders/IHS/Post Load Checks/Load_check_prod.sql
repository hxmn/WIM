-- SCRIPT: Load_check_prod.sql
--
-- PURPOSE:
--   Check the content of the production tables AFER loading.
--   For example, check the 300IPL production load against the earlier test load.
--
--   See also the Load_check_staging.sql and Load_check_test.sql scripts for checks to run
--   before a staging load and after a test load.
--
-- DEPENDENCIES
--   Calls embedded scripts: Sub_*.sql
--
-- EXECUTION:
--   Runs in SQL*PLUS with a parameter to define the source of the load.
--   Can take up to an hour to run.
--   Run as production (Talisman37@IHSDATA) and check against TEST (Talisman37@IHSDATAQ)
--
--   Syntax:
--    @Load_check_prod.sql <source>
-
--    e.g.   
--    @Load_check_prod.sql 450PID
--    
--
-- HISTORY:
--   17-Aug-09  R. Masterman  Initial version based on Ralph's scripts and 
--                            Floy and Neetu's notes
--   28-Aug-09  R. Masterman  Expanded to include extra checks and operate for any load type
--   31-Aug-09  R. Masterman  Factored out the common checks to a separate script
--    8-Sep-09  R. Masterman  Restructured to focus on Staging only
--   18-May-10  R. Masterman  Schema & DB link changes for new IHS environment
--   25-May-10  R. Masterman  Assume run from TALISMAN37@IHSDATA

-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'Load_check_prod'

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

--  For production checks always check production against test
define load_schema = 'Talisman37'
define load_link= ''
define control_schema = 'Talisman37'
define control_link= '@TEST.IHSENERGY.COM'

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

--  Compare the control data to the loaded data
@Sub_difference_checks.sql

--  Checks common to all load types
@Sub_common_checks.sql

--  Checks for no-staging loads
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
