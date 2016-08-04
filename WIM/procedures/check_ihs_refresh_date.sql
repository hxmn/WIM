/***********************************************************************************************************************
 QC1653 check IHS refresh dates on the data types we are getting (well, dir srvy, pden, strat, etc)

 Procedure to query IHS databases to get the last refresh date.
 Run this script after creating database links

 Run as: WIM schema

 History
  20151109  cdong   QC1653 script creation
  20151113  cdong   Per IHS (Kevin), only Canadian well header info (plus license, status, location) is daily.
                      The other Canadian well data is weekly (weekends), while PDEN may be monthly (as available)
  20160610  cdong   QC1834 leverage table at IHS-Canada: IHSD_DATA_CURRENCY,
                     instead of checking for most recent changed date.
                     Use the refresh date in the comparison. IHS refreshed the data on that particular date, for 
                     a specific table; however, it may not match the last modified date in the table-data (data_currency_date).

 **********************************************************************************************************************/

----drop procedure wim.check_ihs_refresh_date;

create or replace procedure wim.check_ihs_refresh_date
/*******************************************************************************
 Procedure to return the most recent row changed date from each of the
   IHS databases and data-types we provision to users.

 See Vault for master copy of script for this procedure.
   History of changes should be logged to master script.

 Updated: 20160610 cdong


 ******************************************************************************/
as
--declare
    v_intv_daily                number          := 2;
    v_intv_weekly               number          := 9;
    v_intv_monthly              number          := 30;
    v_invt_max_daily            number          := 7;
    v_invt_max_weekly           number          := 15;
    v_max_date                  date            := sysdate-1;
    v_str_can                   varchar2(250)   := 'IHS last refresh - Canada';
    v_str_usa                   varchar2(250)   := 'IHS last refresh - USA';
    v_str_int                   varchar2(250)   := 'IHS last refresh - International';
    v_str                       varchar2(2000);
    v_currency_date             date            := sysdate-1;

begin

    ----if the current day-of-week is Sunday, or Monday, add one or two days as weekend buffer
    if to_char(trunc(sysdate), 'D') in ('1', '2') then
        v_intv_daily            := v_intv_daily + 2;
        v_intv_weekly           := v_intv_weekly + 2;
        v_invt_max_daily        := v_invt_max_daily + 1;
        v_invt_max_weekly       := v_invt_max_weekly + 1;
    end if;

    ppdm_admin.tlm_process_logger.info('IHS LAST REFRESH - check changed-date on data: START');

    ----for each data type and region, check max row_CHANGED_date (do not use created-date)

    -------- Canada -----------------------------------------------------------------
    begin

        ppdm_admin.tlm_process_logger.info('IHS last refresh - Canada (daily) - potentially out-of-date if last updated prior to ' || to_char(trunc(sysdate)-v_intv_daily, 'yyyy-mm-dd')
                                             || '   ----------');

        ----well
        --select max(row_changed_date) into v_max_date
        --  from well@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'WELL' ;

        v_str       :=  v_str_can || ' [WELL] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_daily then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_daily then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ppdm_admin.tlm_process_logger.info('IHS last refresh - Canada (weekly+) - potentially out-of-date if last updated prior to ' || to_char(trunc(sysdate)-v_intv_weekly, 'yyyy-mm-dd')
                                             || '   ----------');

        ----dir srvy
        --select max(row_changed_date) into v_max_date
        --  from well_dir_srvy@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'WELL_DIR_SRVY' ;

        v_str       :=  v_str_can || ' [DIR SRVY] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----completion
        --select max(row_changed_date) into v_max_date
        --  from well_completion@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'WELL_COMPLETION' ;

        v_str       :=  v_str_can || ' [COMPLETION] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----core
        --select max(row_changed_date) into v_max_date
        --  from well_core@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'WELL_CORE' ;

        v_str       :=  v_str_can || ' [CORE] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----stratigraphy
        --select max(row_changed_date) into v_max_date
        --  from strat_well_section@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'STRAT_WELL_SECTION' ;

        v_str       :=  v_str_can || ' [STRAT] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----test
        --select max(row_changed_date) into v_max_date
        --  from well_test@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'WELL_TEST' ;

        v_str       :=  v_str_can || ' [TEST] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----pden... check individual pden records
        --select max(row_changed_date) into v_max_date
        --  from pden@c_talisman ;
        ----20160610 cdong
        select max(ihsd_refresh_date), max(data_currency_date) into v_max_date, v_currency_date
          from ihsd_data_currency@c_talisman
         where table_name = 'PDEN' ;

        v_str       :=  v_str_can || ' [PDEN] > ' || to_char(v_currency_date, 'yyyy-mm-dd hh24:mi')
                                  || '  (last refreshed ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi') || ')';

        if trunc(v_max_date) < trunc(sysdate)-v_intv_monthly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        --elsif trunc(v_max_date) < trunc(sysdate)-v_intv_monthly then
        --    v_str   :=  v_str || ' - data could be out-of-date';
        --    ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;


    exception
      when others then ppdm_admin.tlm_process_logger.error(v_str_can || ' ** ERROR: ' || sqlerrm);
    end;


    -------- USA -----------------------------------------------------------------
    begin

        ppdm_admin.tlm_process_logger.info('IHS last refresh - USA - potentially out-of-date if last updated prior to ' || to_char(trunc(sysdate)-v_intv_weekly, 'yyyy-mm-dd')
                                             || '   ----------');

        ----well
        select max(row_changed_date) into v_max_date
          from well@c_talisman_us ;

        v_str       :=  v_str_usa || ' [WELL] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----dir srvy
        select max(row_changed_date) into v_max_date
          from well_dir_srvy@c_talisman_us ;

        v_str       :=  v_str_usa || ' [DIR SRVY] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----completion
        select max(row_changed_date) into v_max_date
          from well_completion@c_talisman_us ;

        v_str       :=  v_str_usa || ' [COMPLETION] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----core
        select max(row_changed_date) into v_max_date
          from well_core@c_talisman_us ;

        v_str       :=  v_str_usa || ' [CORE] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----stratigraphy
        select max(row_changed_date) into v_max_date
          from strat_well_section@c_talisman_us ;

        v_str       :=  v_str_usa || ' [STRAT] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----test
        select max(row_changed_date) into v_max_date
          from well_test@c_talisman_us ;

        v_str       :=  v_str_usa || ' [TEST] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

        ----pden... check individual pden records
        select max(row_changed_date) into v_max_date
          from pden@c_talisman_us ;

        v_str       :=  v_str_usa || ' [PDEN] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

    exception
      when others then ppdm_admin.tlm_process_logger.error(v_str_usa || ' ** ERROR: ' || sqlerrm);
    end;


    ------ USA, PID -----------------------------------------------------------------
    begin

        ----pden
        select max(pmp.pi_rec_upd_date) into v_max_date
          from pden_monthly_prod@c_tlm_pid_stg pmp ;

        v_str       :=  v_str_usa || ' (PID_STG) [PDEN] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

    exception
      when others then ppdm_admin.tlm_process_logger.error(v_str_usa || ' (PID_STG) ** ERROR: ' || sqlerrm);
    end;


    ------ International -----------------------------------------------------------------
    begin

        ppdm_admin.tlm_process_logger.info('IHS last refresh - International - potentially out-of-date if last updated prior to ' || to_char(trunc(sysdate)-v_intv_weekly, 'yyyy-mm-dd')
                                             || '   ----------');

        ----well
        select max(row_changed_date) into v_max_date
          from well_version@c_tlm_probe;

        v_str       :=  v_str_int || ' [WELL] > ' || to_char(v_max_date, 'yyyy-mm-dd hh24:mi');

        if trunc(v_max_date) < trunc(sysdate)-v_invt_max_weekly then
            v_str   :=  v_str || ' - data is out-of-date, contact IHS';
            ppdm_admin.tlm_process_logger.error(v_str);
        elsif trunc(v_max_date) < trunc(sysdate)-v_intv_weekly then
            v_str   :=  v_str || ' - data could be out-of-date';
            ppdm_admin.tlm_process_logger.warning(v_str);
        else
            ppdm_admin.tlm_process_logger.info(v_str);
        end if;

    exception
      when others then ppdm_admin.tlm_process_logger.error(v_str_int || ' ** ERROR: ' || sqlerrm);
    end;


    ppdm_admin.tlm_process_logger.info('IHS LAST REFRESH - check changed-date on data: ....................... END');

  exception
    when others then ppdm_admin.tlm_process_logger.error('IHS last refresh **** ERRROR - ' || sqlerrm);

end;
/






/********** Testing ***************************

DECLARE
  --X NUMBER;
BEGIN
  SYS.DBMS_JOB.ISUBMIT
  ( job           => 888
     , what       => 'wim.check_ihs_refresh_date;'
     , interval    => null
     , next_date  => sysdate
  );
  --SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;


-- from individual schemas (eg. wim_loader)
SELECT JOB, LAST_DATE, THIS_DATE, NEXT_DATE, WHAT, INTERVAL, BROKEN, FAILURES FROM ALL_JOBS ORDER BY NEXT_DATE;


--check process log to see if job started/finished and output
select *
from ppdm_admin.tlm_process_log
where row_created_on > sysdate - 10/1440
      and row_created_by = 'WIM'
order by row_created_on asc
;


 *********/

