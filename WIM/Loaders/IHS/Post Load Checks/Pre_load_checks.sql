-- SCRIPT: Pre_load_checks.sql
--
-- PURPOSE:
--   The WIM pre-load checks are a simple set of queries for checking the content
--   of a load BEFORE loading into a target database. The script can be used with
--   staging loads (e.g. PID) to check the content of the staging tables prior to
--   loading into test, or with direct loads (e.g. IHS incremental) to check the
--   content of the test database prior to loading into production.
--
--   See also the Post_load_checks.sql script for checks to run after a load into
--   TEST or PRODUCTION.
--
-- DEPENDENCIES
--   Calls the embedded script: Common_load_checks.sql
--
-- EXECUTION:
--   Runs in SQL*PLUS with parameters to define the source of the load and the schema
--   that contains the load data. Can take up to an hour to run.
--   Run as Talisman37@V82c as this user can see the staging, production and test environments
--
--   Syntax:
--    @Pre_load_checks.sql <source> <target_schema>
-
--    e.g.   
--    @Pre_load_checks.sql 450PID TLM_PID_STG
--    
--
-- HISTORY:
--   17-Aug-09  R. Masterman  Initial version based on Ralph's scripts and 
--                            Floy and Neetu's notes
--   28-Aug-09  R. Masterman  Expanded to include extra checks and operate for any load type
--   31-Aug-09  R. Masterman  Factored out the common checks to a separate script

-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'Pre_load_checks'

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

--  Set the load schema (where is the data we need to check? e.g. staging or test database)
--  (If not provided as a parameter then the user will be prompted)
prompt Enter the name of the schema that contains the data we need to check (e.g. TEST36 or TLM_PID_STG)
set termout off
define load_schema = &2
set termout on

-- Start logging
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' ||'_&&source' || '_&&load_schema' || '_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

prompt *****************************************************************************
prompt
prompt    Running &&script_name for &&source data loaded in the &&load_schema schema
prompt
prompt    Logging to file: &&spool_file
prompt
prompt *****************************************************************************

-- Log who is running this and when
prompt Running as user:
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;

set echo on

-------------------------------------------------
--  Collect some basic stats on the pre-load data
-------------------------------------------------

-- Total number of wells in the load data
Select count(1) "Total &&source Wells in the load"
  from &&load_schema..well_version
 where source = '&&source';

--  Show how many wells may be updated as part of the load
Select count(1) as "&&source Wells to update"
  from &&load_schema..well_version
 where source = '&&source'
   and uwi in (select uwi
                 from well_version
                where source = '&&source');

-- Show how many wells will be added as part of the load
select count (1) as "&&source Wells to add"
  from &&load_schema..well_version
 where source = '&&source'
   and uwi not in (select uwi
                     from well_version
                    where source = '&&source');

-- Show how many wells will be removed as part of the load
select count (1) as "&&source Wells to Remove"
  from well_version
 where source = '&&source'
   and uwi not in (select uwi
                     from &&load_schema..well_version
                    where source = '&&source');

--------------------------------------------------------------------------------
--  Call the common load checks - used by both pre-load and post load scripts
--------------------------------------------------------------------------------

@Common_load_checks.sql

--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;

prompt ******************************************************************************
prompt
prompt    &&script_name for &&source data loaded in the &&load_schema schema complete
prompt
prompt    Data logged to file: &&spool_file
prompt
prompt ******************************************************************************

spool off
quit
