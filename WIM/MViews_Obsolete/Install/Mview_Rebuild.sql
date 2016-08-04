-- SCRIPT: Mview_Rebuild.sql
--
-- PURPOSE:
--   This script recreates all of the PET* Mviews
--
-- DEPENDENCIES
--   WIM built in package TLM_MVIEW_UTILS package
--
-- EXECUTION:
--   Usually run through SQLplus as PPDM on PET*
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   29-May-10  R. Masterman  Initial version


-- For debugging turn these ON
set verify off
set echo off

--  Define constants
define script_name = 'Mview_Rebuild'

-- Set up logging
set echo off
set trimspool on
set serveroutput on
set feedback on
set time on
set pagesize 50

-- Start logging
variable spool_file varchar2(100);
execute :spool_file := '&&script_name' || '_' || to_char(sysdate(),'YYMMDD_HH.MI') ||'.log';
column sf new_value spool_file noprint
select :spool_file sf from dual;
spool &&spool_file

prompt *****************************************************************************
prompt
prompt    Running the &&script_name script
prompt
prompt    Logging to file: &&spool_file
prompt
prompt *****************************************************************************

-- Log who is running this and when
prompt Running as user:
show user
select to_char(sysdate,'YYYY-MON-DD HH:MI.SS') Started from dual;

set echo on

------------------------------------------------------------------------------------
--  Remove the constraints - Assumes they are disabled anyway so should have no
--                           noticeable impact on the database operation
------------------------------------------------------------------------------------
@Drop_MV_constraints.sql

------------------------------------------------------------------------------------
--  Primary Mviews
------------------------------------------------------------------------------------

@WELL.sql;
@WELL_ALIAS.sql;
@WELL_VERSION.sql;
@WELL_NODE.sql;
@WELL_NODE_VERSION.sql;

------------------------------------------------------------------------------------
--  Secondary Mviews
------------------------------------------------------------------------------------
@WELL_LICENSE.sql;
@WELL_NODE_M_B.sql;
@WELL_STATUS.sql;
@POOL.sql;

------------------------------------------------------------------------------------
--  Minor Mviews
------------------------------------------------------------------------------------

@IPL_BUSINESS_ASSOCIATE.sql;
@IPL_R_ALIAS_REASON_TYPE.sql;
@IPL_R_ALIAS_TYPE.sql;
@IPL_R_SOURCE.sql;
@R_COUNTRY.sql;
@R_COUNTY.sql;
@R_DISTRICT.sql;
@R_GEOLOGIC_PROVINCE.sql;
@R_PLOT_SYMBOL.sql;
@R_PROVINCE_STATE.sql;
@R_WATER_DATUM.sql;
@R_WELL_CLASS.sql;
@R_WELL_STATUS.sql;
@STRAT_UNIT.sql;
@PROD_STRING.sql;

------------------------------------------------------------------------------------
--  Dependent Local Mviews
------------------------------------------------------------------------------------

@BUSINESS_ASSOCIATE.sql;
@R_ALIAS_REASON_TYPE.sql;
@R_ALIAS_TYPE.sql;
@R_SOURCE.sql
@WELL_SPATIAL_MVIEW1.sql

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
