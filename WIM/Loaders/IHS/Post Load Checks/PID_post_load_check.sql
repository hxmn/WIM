-- SCRIPT: PID_post_load_check.sql
--
-- PURPOSE:
--   A set of simple queries used to check the content of the WIM database after
--   a PID load.  It lists some basic statistic about what has been loaded and
--   compares the results to the TEST or staging data.
--
--   See also the PID_pre_load_check.sql script that should be run before loading into test
--
-- EXECUTION:
--   Run it as TEST36@v82c for checking TEST36 test load against PID staging
--   Run it as TALISMAN37_BROWSE@v82c for checking a PID PRODUCTION load against the test load results
--
-- HISTORY:
--   18-Aug-09  R. Masterman  Initial version based on Ralph's queries & Floy and Neetu's notes

-- Set up logging
set trimspool on
set serveroutput on
set feedback on
set time on
set pagesize 50

-- Start logging
define script_name = 'PID_post_load_check';
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' ||'_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

--  Create dynamic variables to allow the script to be used to check & compare different databases
var source_schema VARCHAR2(30);
var source_link   VARCHAR2(128);

--  Assign the schema and database link depending on which user the script is running under
--    1) For TEST36 compare to PID staging
--    2) For Talisman37_browse compare to TEST36
begin
  if user = 'TEST36' then
    :source_schema := 'TLM_PID_STG.';
    :source_link   := '@STAGING.IHSENERGY.COM';
  elsif user = 'TALISMAN37_BROWSE' or user = 'TALISMAN37' then
    :source_schema := 'TEST36.';
    :source_link   := '';
  end if;
end;
/

-- Define the SQL*PLUS variables to use
column ss new_value source_schema noprint
column sl new_value source_link noprint
select :source_schema ss from dual;
select :source_link   sl from dual;


-- Track what is being run, by who and when
prompt Running Script: &&script_name..sql
show user
prompt Checking the PID data loaded into the above user's schema with the schema &&source_schema &&source_link
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;
set echo on

--------------------------------------------------------------------------------
--  Collect some basic stats on the loaded data
--------------------------------------------------------------------------------
Select count (1) as "Total PID Wells"
  from well
 where primary_source='450PID';

Select count (1) as "Total PID Well Versions"
  from well_version
 where source='450PID';

Select count (1) as "Total PID Well Alias"
  from well_alias
 where source='450PID';

Select count (1) as "Total PID Well nodes"
  from well_node
 where source='450PID';

-- Source summaries - can compare to see only PID has changed
select count (1) cnt, source
  from well_version
 group by rollup(source)
 order by source;

--------------------------------------------------------------------------------
--  Compare the loaded results with staging or test - Should all have ZERO diffs
--------------------------------------------------------------------------------

--  Compare WELL data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Difference"
  from (select count(1) as Source
          from &&source_schema.well&&source_link
         where primary_source = '450PID'),
       (select count(1) as Target
          from well
         where primary_source = '450PID');

--  Compare WELL_VERSION data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Version Difference"
  from (select count(1) as Source
          from &&source_schema.well_version&&source_link
         where source = '450PID'),
       (select count(1) as Target
          from well_version
         where source = '450PID');

--  Compare WELL_NODE data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Node Difference"
  from (select count(1) as Source
          from &&source_schema.well_node&&source_link
         where source = '450PID'),
       (select count(1) as Target
          from well_node
         where source = '450PID');

--  Compare WELL_NODE_VERSION data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well node Version Difference"
  from (select count(1) as Source
          from &&source_schema.well_node_version&&source_link
         where source = '450PID'),
       (select count(1) as Target
          from well_node_version
         where source = '450PID');

--  Compare WELL_ALIAS data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well Alias Difference"
  from (select count(1) as Source
          from &&source_schema.well_alias&&source_link
         where source = '450PID'),
       (select count(1) as Target
          from well_alias
         where source = '450PID');

--  Compare WELL_LICENSE data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Well License Difference" 
  from (select count(1) as Source
          from &&source_schema.well_license&&source_link
         where source = '450PID'),
       (select count(1) as Target
          from well_license
         where source = '450PID');
       
--  Compare OPERATOR data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Operator Difference"
  from (select count(operator) as Source
          from &&source_schema.well_version&&source_link
         where source = '450PID'),
       (select count(operator) as Target
          from well_version
         where source = '450PID');

 --  Compare STATUS data in test and production - Expect ZERO diffs
select Source, Target,  Source - Target as "Status Difference"
  from (select count(current_status) as Source
          from &&source_schema.well_version&&source_link
         where source = '450PID'),
       (select count(current_status) as Target
          from well_version
         where source = '450PID');
     
--------------------------------------------------------------------------------
--    Check for incomplete records in the loaded data
--------------------------------------------------------------------------------

--  Find any PID wells that don't have the well name set - Expect NONE
Select uwi as "Null Well Name"
  from well_version
 where source = '450PID'
   and well_name is null;

-- Find any PID wells that don't have the country set to the US - Expect NONE
Select uwi as "Invalid country"
  from well_version
 where source='450PID'
   and country != '7US'
   and country is not null;
   
--  Find any PID wells that don't have the IPL_UWI_local set - Expect NONE
Select uwi as "Null IPL_UWI_Local"
  from well_version
 where source = '450PID'
   and IPL_UWI_LOCAL is null;

--  Find any PID wells that don't have an Operator -  Expect some
Select count (1) as "Null Operator"
  from well_version
 where source = '450PID'
   and operator is null;

--  Find any PID wells that don't have a status -  Expect some
Select count (1) as "Null Status"
  from well_version
 where source = '450PID'
   and current_status is null;
   
--  Count wells with no surface node
select count (1) as "No Surface Node"
  from well_version
 where source = '450PID'
   and surface_node_id is null;

--  Count wells with no base node
select count (1) as "No Base Node"
  from well_version
 where source = '450PID'
   and base_node_id is null;
 
 
------------------------------------------------------------------
--  Check integrity and conventions in the loaded data
------------------------------------------------------------------

 --  Check the base node id numbering follows convention - Expect ZERO
select count(1) as "Invalid Base Node ids"
  from well_version
 where source = '450PID'
   and base_node_id != concat(UWI,'0');

--  Check the surface node id numbering follows convention - Expect ZERO
select count(1) as "Invalid Surface Node ids"
  from well_version
 where source = '450PID'
   and surface_node_id != concat(UWI,'1');
    
-- Check for missing base nodes - expect ZERO
select count(1)  as "Missing base nodes"
  from (select base_node_id as "node_id"
          from well_version
         where source = '450PID'
        minus
        select node_id
          from well_node_version
         where source = '450PID'
           and node_position = 'B');

-- Check for missing surface nodes - Expect ZERO
select count(1) as "Missing Surface nodes"
  from (select surface_node_id as "node_id"
          from well_version
         where source = '450PID'
        minus
        select node_id
          from well_node_version
         where source = '450PID'
           and node_position = 'S');

  -- Check for missing licenses - Expect ZERO
select uwi as "Missing Licenses"
 from well_version
where source = '450PID'
  and uwi not in (select uwi from well_license where source = '450PID');

-- Check for old PID wells that have been merged - Expect ZERO
select count(1) as "Merged PID wells"
  from well_alias
 where alias_type = 'UWI_PRIOR'
   and well_alias in (select uwi
                        from well_version
                       where source = '450PID');
 
--------------------------------------------------------------------
--  Look for any references that are not in the IHS ref. tables
--  These should have been resolved in the test stage. If you still
--  find any, get them corrected or add them to the TLM versions of
--  the tables in PET*
--------------------------------------------------------------------
  
--  New Current Status reference values - Expect some
select current_status
  from well_version
 where source = '450PID'
 minus
select status
  from r_well_status;

--  New Operator reference values - Expect some
select operator
  from well_version
 where source = '450PID'
 minus
select business_associate
  from business_associate;

--  New Licensee reference values - Expect some
select licensee
  from well_license
 where source = '450PID'
minus
select business_associate
  from business_associate;

--------------------------------------------------------------------------------
-- Check for bad characters in the reference attributes
-- Find any trailing spaces, leading spaces, double spaces, special characters etc.
--------------------------------------------------------------------------------

-- Check Well Name
select uwi, well_name 
  from well_version
 where source = '450PID'
   and (instr(well_name,'  ') > 0
     or instr(well_name,'@') > 0
     or instr(well_name,'!') > 0
     or instr(well_name,'"') > 0
     or instr(well_name,'?') > 0
     or instr(well_name,'#') > 0
       );

--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;
spool off
quit
