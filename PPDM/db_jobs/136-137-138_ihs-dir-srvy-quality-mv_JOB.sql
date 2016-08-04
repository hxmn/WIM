/************************************************************************************

  Create Oracle job to refresh the DATA_FINDER.WELL_DIR_SRVY_SPATIAL_US_MV materialized view

  History: 20160519 cdong
            create job to refresh ppdm.ihs_cdn_dir_srvy_quality_mv

  Dev:  21:15 cdn / 22:30-Sa us  (and then tlm_dir_srvy at 23:00)
  Test: 22:15 cdn / 20:30-Sa us  (and then tlm_dir_srvy at 23:00)
  Prod: 23:00 cdn / 22:00-Sa us  (and then tlm_dir_srvy at 23:30)
  
  History:
   201605xx cdong QC1669  Modify process for computing directional survey quality mviews
                          Set job schedule.

 ************************************************************************************/


begin
  sys.dbms_job.remove(136);
  commit;
end;
/


declare
  --X NUMBER;
begin
  sys.dbms_job.isubmit
  ( job           => 136
     , what       => 'execute immediate ''truncate table ppdm.ihs_cdn_dir_srvy_quality_mv''; ppdm_admin.tlm_mview_util.freshen_mview(''ppdm'', ''ihs_cdn_dir_srvy_quality_mv'', ''C'');'
     , next_date  => trunc(sysdate)+23/24
     , interval   => 'trunc(sysdate+1)+23/24'
     , no_parse   => false
  );
  --SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
  commit;
end;
/



begin
  sys.dbms_job.remove(137);
  commit;
end;
/


declare
  --X NUMBER;
begin
  sys.dbms_job.isubmit
  ( job           => 137
     , what       => 'execute immediate ''truncate table ppdm.ihs_us_dir_srvy_quality_mv''; ppdm_admin.tlm_mview_util.freshen_mview(''ppdm'', ''ihs_us_dir_srvy_quality_mv'', ''C'');'
     , next_date  => trunc(sysdate)+7 +mod(7-to_char(trunc(sysdate),'D')-7,7) +22/24
     , interval   => 'trunc(sysdate)+7 +mod(7-to_char(trunc(sysdate),''D'')-7,7) +22/24'
     , no_parse   => false
  );
  --SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
  commit;
end;
/


----change main mview with ALL THREE dir srvy sources
execute dbms_job.next_date(138, trunc(sysdate)+23.5/24);
execute dbms_job.interval(138, 'trunc(sysdate+1)+23.5/24');
commit;


----select job, last_date, this_date, next_date, what, interval, broken, failures from all_jobs order by next_date;
