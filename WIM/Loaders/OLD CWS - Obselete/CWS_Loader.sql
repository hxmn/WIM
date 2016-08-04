-- SCRIPT: CWS_Loader.sql
--
-- PURPOSE:
--   Run the old CWS Load scripts to load CWS well identities from the CWS database
--   to the WIM database. All steps are logged for review after the load.
--   Still uses the old ROLLUP process, so can result in too many wells in the WELL table.
--   Takes just over an hour to run.
--   Should be run AFTER the Spatial MVIEW completes each evening as it deletes all of the 100 source wells.
--
-- DEPENDENCIES
--   Calls each of the OLD CWS update scripts in order
--
-- EXECUTION:
--   Runs in SQL*PLUS and logs the steps
--   Runs in production as Talisman37@IHSDATA and CORPLOAD@CWSP
--
--   Syntax:
--    @CWS_Loader.sql
--
-- HISTORY:
--   19-Jun-11  R. Masterman  Initial version

-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'CWS_loader'

-- Set up logging
set echo off
set trimspool on
set serveroutput on
set feedback on
set time on
set pagesize 50
set termout on

-- Start logging
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' || '_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

prompt *****************************************************************************
prompt
prompt    Running the &&script_name script.
prompt
prompt    Logging to file: &&spool_file
prompt
prompt *****************************************************************************

-- Log who is running this and when
prompt Running as user:
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;

set echo on

--  STEP 1 - Get Well node data from CWS and store in temp tables
connect corpload/corpload@cwsp
@01_TEMP100_CWS.sql


--  STEP 2 - Create a temp node table for the CWS nodes
connect talisman37/voodoo@ihsdata
@02_TEMP100_T37.sql

--  STEP 3 - Transfer the nodes from CWS to TALISMAN37
connect corpload/corpload@cwsp
@03_TEMP100_CWS.sql

--  STEP 4 - Modify the nodes data to make it PPDM format ready for insert, convert values, create well data from the node data
connect talisman37/voodoo@ihsdata
@04_TEMP100_T37.sql

--  STEP 5 - Backup the old Wells and versions
--         - delete all 100 source wells and versions
--         - insert the new wells and versions
--        -  Roll them up
@05_TEMP100_T37.sql

--  STEP 6 - Set up the aliases
@06_TEMP100_ALIAS_T37.sql

--  STEP 7 - Clean up the data that needs to be prepared for the new loader
connect ppdm/26may2009@petp
@07_TEMP100_PPDM.sql

--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;

prompt ******************************************************************************
prompt
prompt    Script: &&script_name complete
prompt
prompt    Data logged to file: &&spool_file
prompt
prompt ******************************************************************************

spool off
quit
