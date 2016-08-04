-- SCRIPT: Sub_450PID.sql
--
-- PURPOSE:
--   This is a sub-script of Load_check_*.sql scripts. It performs PID specific checks
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--   8-Sep-09  R. Masterman  Factored out of the main scripts to make maintenance easier
--

--  ... From main script

--  Count PID wells that are in the wrong country - Expect ZERO
Select uwi, well_name, country
  from &&load_schema..well_version&&load_link
 where source = '450PID'
   and (country is null
    or country != '7US');

--  List any wells that will be updated as part of this load but are not currently
--  identified as US wells in production  - Expect NONE
select uwi, well_name, country
  from &&load_schema..well_version&&load_link
 where UWI in (select UWI
                 from &&control_schema..well_version&&control_link
                where source = '450PID'
                  and country != '7US');

--  Return to main script ...
