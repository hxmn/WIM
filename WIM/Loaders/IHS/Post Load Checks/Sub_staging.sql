-- SCRIPT: Sub_staging.sql
--
-- PURPOSE:
--   This is a sub-script of Load_check_*.sql scripts. It performs staging specific checks
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--   9-Sep-09  R. Masterman  Factored out of the main scripts to make maintenance easier
--  31-Mar-10  R. Masterman  Added a check to make sure any staging wells don't overlap
--

--  ... From main script

--  List any well versions in the staging area that have the wrong source - Expect NONE
select uwi as "Invalid source wells"
  from &&load_schema..well_version&&load_link
 where source != '&&source';

--  List any wells that have the same UWI as a well in the other staging tables but are from different countries - Expect NONE
select pid.uwi as UWI, pid.country as "PID Country", prb.country as "PROBE Country"
  from well_version@pid_stg.ihsenergy.com pid, well_version@prb_stg.ihsenergy.com prb
 where pid.uwi = prb.uwi
   and pid.country != prb.country;

--  Return to main script ...
