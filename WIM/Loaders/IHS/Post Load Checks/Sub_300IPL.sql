-- SCRIPT: Sub_300IPL.sql
--
-- PURPOSE:
--   This is a sub-script of Load_check_*.sql scripts. It performs 300IPL specific checks
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--   8-Sep-09  R. Masterman  Factored out of the main scripts to make maintenance easier
--

--  ... From main script

--  List a breakdown of Canadian wells by province to verify coverage
select rps.province_state, count(uwi) as Wells
  from r_province_state rps left outer join &&load_schema..well_version&&load_link wv
    on rps.province_state = wv.province_state
   and wv.source = '&&source'
 where rps.country = '7CN'
   and rps.active_ind = 'Y'
 group by rps.province_state
 order by rps.province_state;

--  Return to main script ...
