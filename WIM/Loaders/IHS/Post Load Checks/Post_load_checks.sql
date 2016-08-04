-- SCRIPT: Post_Load_checks.sql
--
-- PURPOSE:
--   The WIM post load checks are a set of simple queries used to check the content of the WIM
--   database AFTER a bulk data load.  It lists some basic statistic about what has been loaded and
--   compares the results to a "control" database. The script can be used on:
--     a) Staging loads (e.g. PID)
--        i) to check the content of the TEST database after the load test (uses staging as the control)
--        ii) to check the production database after the production load (uses test as the control)
--     b) Direct loads (e.g. IHS incremental) to check the production database after the production load (uses test as the control)
--   
--   See also the Pre_load_checks.sql script for checks to run before a load
--
-- DEPENDENCIES
--   Calls the embedded script: Common_load_checks.sql
--
-- EXECUTION:
--   Runs in SQL*PLUS with a parameter to define the "source" of the load. Can take up to an hour to run.
--   Run it as TEST36@v82c for checking TEST36 test load content
--   Run it as TALISMAN37_BROWSE@v82c for checking a PRODUCTION load
--
--   Syntax:
--    @Post_load_checks.sql <source>
--
--    e.g.   
--    @Post_load_checks.sql 450PID
--    

-- HISTORY:
--   28-Aug-09  R. Masterman  Initial version based on PID load checker
--   31-Aug-09  R. Masterman  Factored out the common checks to a separate script

-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'Post_load_check'

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
--  Using a combination of the user and the selected source determine which schemas to compare
----------------------------------------------------------------------------------------------

var control_schema VARCHAR2(30);
var control_link   VARCHAR2(128);
var load_schema    VARCHAR2(30);

--  Assign the schema and database link depending on which user the script is running under
--    1) For TEST36 compare TEST to staging tables
--    2) For Talisman37_browse compare production to TEST36
begin
  if user = 'TEST36' then
    :load_schema    := 'TEST36';
    if '&&source' = '450PID' then
      :control_schema := 'TLM_PID_STG.';
      :control_link   := '@STAGING.IHSENERGY.COM';
    else
      :control_schema := 'TALISMAN37';
      :control_link   := '';
    end if;
  elsif user = 'TALISMAN37_BROWSE' or user = 'TALISMAN37' then
    :control_schema := 'TEST36.';
    :control_link   := '';
    :load_schema    := 'TALISMAN37';
  end if;
end;
/

-- Define the SQL*PLUS variables to use
column cs new_value control_schema noprint
column cl new_value control_link noprint
column ls new_value load_schema noprint
select :control_schema cs from dual;
select :control_link   cl from dual;
select :load_schema    ls from dual;



-- Start logging
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' ||'_&&source' || '_&&load_schema' || '_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

prompt **************************************************************************
prompt
prompt    Running &&script_name on &&source data loaded into &&load_schema schema
prompt    Checking against the data loaded in the &&control_schema schema
prompt
prompt    Logging to file: &&spool_file
prompt
prompt **************************************************************************

-- Log who is running this and when
prompt Running as user:
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;

set echo on

--------------------------------------------------------------------------------
--  Collect some basic stats on the loaded data
--------------------------------------------------------------------------------
Select count (1) as "Total &&source Wells"
  from &&load_schema..well
 where primary_source='&&source';

Select count (1) as "Total &&source Well Versions"
  from &&load_schema..well_version
 where source='&&source';

Select count (1) as "Total &&source Well Alias"
  from &&load_schema..well_alias
 where source='&&source';

Select count (1) as "Total &&source Well nodes"
  from &&load_schema..well_node
 where source='&&source';

-- Source summaries - can compare to see only this source has changed
select count (1) cnt, source
  from &&load_schema..well_version
 group by rollup(source)
 order by source;

--------------------------------------------------------------------------------
--  Compare the loaded results with control database - Should all have ZERO diffs
--------------------------------------------------------------------------------

--  Compare WELL data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Difference"
  from (select count(1) as Source
          from &&control_schema..well&&control_link
         where primary_source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well
         where primary_source = '&&source');

--  Compare WELL_VERSION data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Version Difference"
  from (select count(1) as Source
          from &&control_schema..well_version&&control_link
         where source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well_version
         where source = '&&source');

--  Compare WELL_NODE data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Node Difference"
  from (select count(1) as Source
          from &&control_schema..well_node&&control_link
         where source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well_node
         where source = '&&source');

--  Compare WELL_NODE_VERSION data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well node Version Difference"
  from (select count(1) as Source
          from &&control_schema..well_node_version&&control_link
         where source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well_node_version
         where source = '&&source');

--  Compare WELL_ALIAS data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Alias Difference"
  from (select count(1) as Source
          from &&control_schema..well_alias&&control_link
         where source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well_alias
         where source = '&&source');

--  Compare WELL_LICENSE data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well License Difference" 
  from (select count(1) as Source
          from &&control_schema..well_license&&control_link
         where source = '&&source'),
       (select count(1) as Target
          from &&load_schema..well_license
         where source = '&&source');
       
--  Compare OPERATOR data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Operator Difference"
  from (select count(operator) as Source
          from &&control_schema..well_version&&control_link
         where source = '&&source'),
       (select count(operator) as Target
          from &&load_schema..well_version
         where source = '&&source');

 --  Compare STATUS data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Status Difference"
  from (select count(current_status) as Source
          from &&control_schema..well_version&&control_link
         where source = '&&source'),
       (select count(current_status) as Target
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
