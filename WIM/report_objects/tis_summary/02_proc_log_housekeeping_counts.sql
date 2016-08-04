
CREATE OR REPLACE procedure       log_housekeeping_counts
/******************************************************************************
 Procedure to extract counts from the ppdm_admin.tlm_process_log
   from log entries written by the WIM Housekeeping task.
   The counts are used to identify/benchmark particular aspects about the data.

 History:
  20150327  cdong   TIS Task 1453 - created procedure
  20150707  cdong   TIS Task 1654 - add active_ind to cursor definition
                    This is especially useful for Asia-Pacific, where some of
                    the checks are specific only to North America.
  20150806  cdong   Found issue with procedure and fixed
                      include with QC1686 or QC1713 deployment

 ******************************************************************************/
is

  --cursor to go through list of items to report on
  cursor csr_report
  is
  select r_id, pattern
    from z_benchmark
   where r_type = 'logcount'
         and active_ind = 'Y'
   order by r_id
  ;

  type t_data_array     is table of csr_report%rowtype index by pls_integer;
  v_rec                 t_data_array;

  v_str_query           varchar2(4000);

  v_cnt                 int;

  v_startdate           timestamp;
  --when the log entry was originally logged
  v_logdate             timestamp;
  v_last_batch          timestamp;

begin

  dbms_output.put_line('*** Task 1529: start housekeeping counts ... START');
  ppdm_admin.tlm_process_logger.info('*** Task 1529: start housekeeping counts ... START');

  v_cnt         :=  0;

  --get the latest timestamp from the count table; use this as the starting point
  select nvl(trunc(max(log_date))+1, trunc(systimestamp - 1)) into v_startdate
    from z_benchmark_stats
  ;

  dbms_output.put_line(' > start date: ' || to_char(v_startdate, 'yyyy-mm-dd hh24:mi:ss'));

  --identify the latest group of benchmark stats
  select to_date(max(batch), 'yyyy-mm-dd hh24:mi:ss') into v_last_batch
    from z_benchmark_stats;

  dbms_output.put_line(' > last batch: ' || to_char(v_last_batch, 'yyyy-mm-dd hh24:mi:ss'));

  --check if wim housekeeping didn't run
  if v_startdate = v_last_batch then
      v_startdate   :=  v_startdate + 1;
  end if;

  --if there is a gap between when the log counts was last run and the last time counts were logged
  --  the start date can be older than the batch date
  if v_startdate < v_last_batch then
      v_startdate   := trunc(v_last_batch) + 1;
  end if;

  dbms_output.put_line(' > start date: ' || to_char(v_startdate, 'yyyy-mm-dd hh24:mi:ss'));
  ppdm_admin.tlm_process_logger.info(' > start date: ' || to_char(v_startdate, 'yyyy-mm-dd hh24:mi:ss'));

  if (v_startdate < sysdate) then

      open csr_report;

      loop

        fetch csr_report bulk collect into v_rec limit 50;

        exit when v_rec.count = 0;

        for idx in 1 .. v_rec.count
        loop

            v_logdate       := null;

            --build query to get the count from each log warning/error
            v_str_query     := 'SELECT TRIM(LTRIM(LTRIM(REGEXP_SUBSTR(text, ''(:|=)([^:]|[^=])[0-9]+$''), '':''), ''='')) '
                                || ', row_created_on '
                                || ' FROM PPDM_ADMIN.TLM_PROCESS_LOG '
                                || ' WHERE ROW_CREATED_ON BETWEEN TO_DATE(''' || to_char(v_startdate, 'yyyy-mm-dd hh24:mi:ss') || ''', ''yyyy-mm-dd hh24:mi:ss'') '
                                || ' AND TO_DATE(''' || to_char(v_startdate + 1, 'yyyy-mm-dd hh24:mi:ss') || ''', ''yyyy-mm-dd hh24:mi:ss'') '
                                || ' AND LOWER(text) LIKE ''%' || lower(v_rec(idx).pattern) || '%'''
                                || ' AND ROWNUM = 1'
            ;

           dbms_output.put_line('command to execute: ' || nvl(v_str_query, '-nothing-'));

            begin

              --execute query to get count
              execute immediate v_str_query into v_cnt, v_logdate;

            --if no warning/error exists, then set count to zero
            exception
              when no_data_found then
                v_cnt       :=  0;

            end;

            dbms_output.put_line('count is ' || nvl(cast(v_cnt as varchar2), '-nothing-'));

            --now, set the count into the table
            insert into z_benchmark_stats (batch, r_id, log_date, count)
              values(to_char(v_startdate, 'yyyy-mm-dd hh24:mi:ss'), v_rec(idx).r_id, v_logdate, nvl(v_cnt, -999999));

        end loop;
      end loop;

      commit;

  else

    dbms_output.put_line(' ... no action since next batch is in the future or already logged ... ');
    ppdm_admin.tlm_process_logger.info(' ... no action since next batch is in the future or already logged ... ');

  end if;

  dbms_output.put_line('*** Task 1529: start housekeeping counts ... END');
  ppdm_admin.tlm_process_logger.info('*** Task 1529: start housekeeping counts ... END');

exception
    when others then
        ppdm_admin.tlm_process_logger.error(' *** Error > housekeeping counts - ended with errors, sqlerrm ' || sqlerrm);

end
;