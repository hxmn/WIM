-- SCRIPT: IHS_load_Stats.sql
--
-- PURPOSE:
--   Consolidated set of queries that Ralph used to use to check the IHS loads.
--   Logs some basic stats on the WIM dataset and should be run before and after a load so the changes can be compared.
--
-- EXECUTION:
--   Run it as TEST36@V82C during testing and Talisman37@V82c for the actual load.
--   The output log file should be renamed after a run so it can be preserved for later comparison.
--
-- HISTORY:
--   Date	Who		What
--   25-Jun-09  R. Masterman	Initial version

-- Set up logging
set trimspool on
set serveroutput on
set feedback on
set pagesize 50
spool IHS_load_stats.log

-- Track what is being run, by who and when
prompt Running Script: IHS_load_stats.sql
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;
set echo on

-- Get the initial base numbers
Select count(*) from well_version;
Select count(country) from well_version;
Select count (well_name) from well_version;
Select count (ipl_uwi_local) from well_version;

-- Check IPL source numbers
Select count (*) from well where primary_source='300IPL';
Select count(*) from well_version where source='300IPL';
Select count(country) from well_version where source='300IPL';
Select count (well_name) from well_version where source='300IPL';
Select count (*)from  well_alias where source='300IPL';
Select count (*) from well_node where source='300IPL';
select count (surface_latitude) from well_version where source='300IPL';
select count (bottom_hole_latitude) from well_version where source='300IPL';
select count (current_status) from well_version where source='300IPL';    

-- Source summaries
select count (*) cnt, source from well_version group by rollup(source) order by source;

-- Operator check
select count (operator) from well_version where source = '300IPL';

-- BA checks
select operator from well_version where source = '300IPL' minus select business_associate from business_associate;

-- Status check
select distinct current_status from well_version minus select status from r_well_status;

-- Tidy up
set echo off
prompt Take a copy of the IHS_load_stats.log file and rename to: IHS_load_Stats_<date>_<BEFORE or AFTER>.log
select to_char(sysdate,'YYYY-MON-DD:HH:MI:SS') Finished from dual;
spool off
quit


