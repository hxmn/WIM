-- SCRIPT: PID_pre_load_check.sql
--
-- PURPOSE:
--   A set of simple queries for checking the PID staging area prior to loading
--   the data into the TEST or PRODUCTION databases. It checks the content of the
--   data in the PID staging tables for completness and compares the proposed changes
--   against the production dataset to look for problems.
--
--   See also the PID_post_load_check.sql script for checks to run after a load into
--   TEST or PRODUCTION.
--
-- EXECUTION:
--   Run it in SQL*PLUS as Talisman37@V82c as this user can see staging environment
--   and can compare to the current production content. Takes up to an hour to run.
--
-- HISTORY:
--   17-Aug-09  R. Masterman  Initial version based on Ralph's scripts and 
--                            Floy and Neetu's notes

-- Set up logging
set trimspool on
set serveroutput on
set feedback on
set time on
set pagesize 50

-- Start logging
define script_name = 'PID_pre_load_check';
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' ||'_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

-- Track what is being run, by who and when
prompt Running Script: &&script_name..sql
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;
set echo on


-------------------------------------------------
--  Collect some basic stats on the staging area
-------------------------------------------------

-- Total number of wells in the staging area
Select count(1) "Total Wells in Staging"
  from TLM_PID_STG.well_version;

--  Show how many wells will be replaced as part of the load
Select count(1) as "Wells to update"
  from TLM_PID_STG.well_version
 where uwi in (select uwi
                 from well_version
                where source = '450PID');

-- Find out how many wells will be added as part of the load
select count (1) as "Wells to add"
  from TLM_PID_STG.well_version
 where uwi not in (select uwi
                     from well_version
                    where source = '450PID');

-- COunt how many wells will be removed as part of the load
select count (1) as "Wells to Remove"
  from well_version
 where source = '450PID'
   and uwi not in (select uwi from TLM_PID_STG.well_version);

--------------------------------------------------------------
--  Check for incomplete records in the staging area data
--------------------------------------------------------------

-- List wells with a NULL well name - Expect ZERO
Select uwi as "Null Well Name"
 from TLM_PID_STG.well_version
where well_name is null;

--  List wells to be loaded with an invalid country - Expect ZERO
Select uwi as "Invalid Country"
 from TLM_PID_STG.well_version
where country is null
   or country != '7US';

--  List wells to be loaded with NULL IPL_UWI_Local - Expect ZERO
Select uwi as "Null IPL_UWI_local"
 from TLM_PID_STG.well_version
where ipl_uwi_local is null;

--  Count wells to be loaded with NULL Operator - Preferably ZERO, but often quite a few
Select count (1) as "Null Operator"
 from TLM_PID_STG.well_version
where operator is null;

--  Count wells to be loaded with NULL Current_Status - Preferably ZERO, but often quite a few
Select count (1) as "Null Status"
 from TLM_PID_STG.well_version
where current_status is null;

--  Count wells with no surface node - Preferably ZERO, but there may be some
select count (1) as "Null Surface Node"
 from TLM_PID_STG.well_version
where surface_node_id is null;

--  Count wells with no base node - Preferably ZERO, but probably quite a few
select count (1) as "Null Base Node"
  from TLM_PID_STG.well_version
 where base_node_id is null;


------------------------------------------------------------------
--  Check integrity and conventions within the staging data
------------------------------------------------------------------

-- List any wells that are to be deleted without leaving an alias entry - Expect NONE
select uwi as "Missing alias entries"
  from (select uwi
  	  from well_version
	 where source = '450PID'
           and uwi not in (select uwi from TLM_PID_STG.well_version)) Deleted_Wells
 where Deleted_Wells.uwi not in (select uwi
                                   from well_alias
				  where source = '450PID');


--  Count wells that don't follow the base node id numbering convention - Expect ZERO
select count(1) as "Invalid Base Node ids"
  from TLM_PID_STG.well_version
 where base_node_id != concat(UWI,'0');

--  Count wells that don't follow the surface node id numbering convention - Expect ZERO
select count(1) as "Invalid Surface Node ids"
  from TLM_PID_STG.well_version
 where surface_node_id != concat(UWI,'1');
    
-- List base nodes that are referenced by a well but don't exist as a node version - expect ZERO
select base_node_id as "node_id"
  from TLM_PID_STG.well_version
minus
select node_id
  from TLM_PID_STG.well_node_version
 where node_position = 'B';

-- List surface nodes that are referenced by a well but don't exist as a node version - expect NONE
select surface_node_id as "node_id"
  from TLM_PID_STG.well_version
minus
select node_id
  from TLM_PID_STG.well_node_version
 where node_position = 'S';

--  List any well versions that have the wrong source - Expect NONE
select uwi as "Invalid source wells"
 from TLM_PID_STG.well_version
where source != '450PID';
   
--  List any wells that will be updated as PID wells but are not currently
--  identified as US wells in production  - Expect NONE
select uwi as "Updates to non US wells"
 from TLM_PID_STG.well_version
 where UWI in (select UWI from well_version where country != '7US');

-- List wells that don't have a corresponding license entry - Expect NONE
select uwi as "Wells with no license"
 from TLM_PID_STG.well_version
where uwi not in (select uwi from TLM_PID_STG.well_license);

-- List old PID wells that have been merged - Expect ZERO
select uwi as "Merged PID wells"
  from well_alias
 where alias_type = 'UWI_PRIOR'
   and well_alias in (select uwi from TLM_PID_STG.well_version);

  
--------------------------------------------------------------------
--  Look for any references that are not in the IHS ref. tables
--  If you find any, get them corrected or add them to the TLM 
--  versions of the tables in PET*
--------------------------------------------------------------------
  
--  New Current Status reference values - Expect None
select current_status
  from TLM_PID_STG.well_version
 minus
select status
  from r_well_status;

--  New Operator reference values - Expect NONE
select operator
  from TLM_PID_STG.well_version
 minus
select business_associate
  from business_associate;

--  New Licensee reference values - Expect NONE
select uwi, licensee
  from TLM_PID_STG.well_license
 where licensee not in (select business_associate from business_associate);

--------------------------------------------------------------------------------
-- Check for bad characters in the reference attributes
-- Find any trailing spaces, leading spaces, double spaces, special characters etc.
--------------------------------------------------------------------------------

-- List wells with special characters in the Well Name - Expect NONE
select uwi, well_name 
  from TLM_PID_STG.well_version
 where instr(well_name,'  ') > 0
    or instr(well_name,'@') > 0
    or instr(well_name,'!') > 0
    or instr(well_name,'"') > 0
    or instr(well_name,'?') > 0
    or instr(well_name,'#') > 0;

--------------------------------------------------------------------------------
--  Tidy up                        
--------------------------------------------------------------------------------
set echo off
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;
spool off
quit
