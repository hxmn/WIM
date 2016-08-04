-- SCRIPT: WIM_Housekeeping_Install.sql
--
-- PURPOSE:
--   Set up a housekeeping procedure that runs overnight. The procedure will 
--   consist of fixes that keep the database clean and tidy. Once long term
--   solutions are added to WIM then the fixes can be removed.
--
--   This script need only be run once to set up the job and procedure.
--
--   Once this instal has been run any changes should be made to the script
--   WIM_Houskeeping_PRocdure.sql to add or remove fixes.
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Install using TOAD in PET* as PPDM
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   1-Dec-09  R. Masterman  Initial version
--   8-Jun-10  R. Masterman  Remove PROCESS_LOGGER INSTALL - already in place now


--  Create a dummy procedure so the job can be submitted.
--  while leaving the real procedure at the end of the script
CREATE OR REPLACE PROCEDURE wim_housekeeping IS
BEGIN
 null;
END;

--  Submit the job to run the housekeeping procedure every night.
DECLARE
  JOBNO BINARY_INTEGER;
BEGIN
 DBMS_JOB.SUBMIT (JOB=>JOBNO,
                    WHAT=>'WIM_HOUSEKEEPING;',
                    NEXT_DATE=>TRUNC(SYSDATE)+1,
                    INTERVAL=>'sysdate+1');    
 commit;
END;

-- See that the job made it to the queue OK
select job, last_date, this_date, next_date, broken, failures, what from all_jobs order by next_date; 


-- End of script
