-- SCRIPT: Sub_direct_checks.sql
--
-- PURPOSE:
--   This is a sub-script of Load_check_*.sql scripts. It performs specific checks for direct
--   Loads into the test and production databases.
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--   8-Sep-09  R. Masterman Factored out of the main scripts to make maintenance easier
--  13-May-11  R. Masterman Added check to ignore inactive well & node versions
--

--  ... From main script

-- List any wells that have not been rolled up  - Expect NONE
select uwi as "UWIs Not rolled up", source
from &&load_schema..well_version&&load_link
where uwi in (select uwi
                from &&load_schema..well_version&&load_link
               where active_ind = 'Y'
              minus
              select uwi
               from &&load_schema..well&&load_link);


-- List any nodes that have not been rolled up  - Expect NONE
select node_id as "Nodes not rolled up", source
from &&load_schema..well_node_version&&load_link
where node_id in (select node_id
                    from &&load_schema..well_node_version&&load_link
                   where active_ind = 'Y'
                  minus
                  select node_id
                    from &&load_schema..well_node&&load_link);


--  Return to main script ...
