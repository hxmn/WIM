/***********************************************************************************************************************
 QC1653 check IHS refresh dates on the data types we are getting (well, dir srvy, pden, strat, etc)
 
 Create database links for WIM schema to IHS US-PID and IHS International databases
 Run this script before creating the procedure
 
 Run as: WIM schema
 
 History
  20151109  cdong       script scration

 **********************************************************************************************************************/

----drop database link c_tlm_pid_stg;

create database link c_tlm_pid_stg
 connect to c_tlm_pid_stg
 identified by &&ihs_us_pid_pwd
 using 'IHSDATAQ';


----drop database link c_tlm_probe;

create database link c_tlm_probe
 connect to c_tlm_probe_stg
 identified by &&ihs_intl_pwd
 using 'IHSDATAQ';
