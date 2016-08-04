-- SCRIPT: WIM_User_monitor.sql
--
-- PURPOSE:
--   Set up a job to check and log users of the database instance.
--   Quick a dirty solution to get a rough idea of who is using the database.
--
--   This script need only be run once to set up the job and procedure.
--   The job and procedure need to be run with an account that has access to\
--    V$SESSION system view.
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Install using TOAD in PET*
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   17-Dec-09  R. Masterman  Initial version


--  Create the table to log to
CREATE TABLE WIM_USER_LOG as
select sysdate as "Logtime", username, osuser, machine, program, module, logon_time
  from v$session
where rownum <1;

--  Get a list of currently connected users 
insert into WIM_USER_LOG
 (
 select sysdate, username, osuser, machine, program, module, logon_time
  from v_$session
  where osuser != 'oracle');

commit;

-- See what has been logged 
select * from wim_user_log;

-- End of script



DECLARE
BEGIN

  --  Repetitively log the users
  Loop 
    insert into WIM_USER_LOG
      (select sysdate, username, osuser, machine, program, module, logon_time
         from v$session
        where osuser != 'oracle');
     commit work;

     --  Pause for half an hour
     dbms_lock.sleep(60*1);
     
  end loop;

END;
