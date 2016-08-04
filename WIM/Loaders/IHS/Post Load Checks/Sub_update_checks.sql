-- SCRIPT: Sub_update_checks.sql
--
-- PURPOSE:
--   Checks what is changing as part of the data load.
--   This is a sub-script of the Load_check_* scripts.
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--    8-Sep-09  R. Masterman  New sub script for use with database specific load checks
--   29-Sep-09  R. Masterman  Revised the queries to speed them up
--    9-Apr-09  R. Masterman  Changed checks to rely on changed and created dates
--

--  ... From main script

-------------------------------------------------
--  Load updates summary
--
--    Brief summary of what will be loaded, updated
--    and deleted
--
-------------------------------------------------

--  Show how many wells will be updated as part of the load
Select count(1) as "&&source update Wells"
  from &&load_schema..well_version&&load_link
 where source = '&&source'
   and row_changed_date > (select max(row_changed_date)
                             from &&control_schema..well_version&&control_link
                            where source = '&&source');

-- Show how many wells will be added as part of the load
select count (1) as "&&source new Wells"
  from &&load_schema..well_version&&load_link
 where source = '&&source'
   and row_created_date > (select max(row_created_date)
                             from &&control_schema..well_version&&control_link
                            where source = '&&source');

-- Show how many wells will be removed as part of the load
select count (1) as "&&source obselete Wells"
  from (select uwi
          from &&control_schema..well_version&&control_link
         where source = '&&source'
        minus
       select uwi
         from &&load_schema..well_version&&load_link
        where source = '&&source');

--  Return to main script ...
