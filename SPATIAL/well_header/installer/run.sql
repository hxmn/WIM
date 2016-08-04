set define on
set verify off
set serveroutput on
 
-- create menu structure
accept command char prompt "Would you like to [(i)nstall | (u)ninstall ]: "
accept db_conn char prompt "Enter database environment [ (d)ev|(t)est|(p)rod ]: ";
 
-- suppress terminal output
set term off

-- bind a substitution variable selection to a SQL column
column col noprint new_value i_u
select
    case
        when '&command' = 'i' then 'src/install.sql'
        when '&command' = 'u' then 'src/uninstall.sql'
    end as col
from dual;

column col noprint new_value db_env
select
    case
        when '&db_conn' = 'd' then 'petdev'
        when '&db_conn' = 't' then 'pettest'
        when '&db_conn' = 'p' then 'petprod'
    end as col
from dual;

-- activate terminal output
set term on
 
-- execute the selected script
@&i_u &db_env
exit