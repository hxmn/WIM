/*******************************************************************************

 Define BIRT report schedule and recipients for WIM Duplicate UWI (ipl_uwi_local) report

 RUN FROM: BIRT schema in SEI* database, from where the BIRT Scheduler gets its job information

 Attention: modify the script for the appropriate region and environment. Additionally, only specify
   the recipients for the region the report is being deployed to.

 History
  2014xxxx  cdong   created script

 *******************************************************************************/


----define job

insert into BIRT.REPORT_JOB
(
  report_job_id,
  report_server_id,
  name,
  description,
  email_subject,
  email_from,
  report_path,
  report_format,
  second,
  minute,
  hour,
  day_of_week,
  row_created_by,
  row_created_date,
  row_changed_by,
  row_changed_date
)
(
select 19,
       RS.REPORT_SERVER_ID,
       'WIM Duplicate UWI',
       'WIM issues report. (1) Government UWI (ipl_uwi_local) duplicated in multiple North America wells (Canada and the United States). (2) Government UWI duplicated in multiple well versions in multiple wells.  (3) Wells with multiple government UWI values across active well versions.',
       'WIM Duplicate Wells (IPL_UWI_LOCAL) Report',
       'BirtScheduler@Talisman-Energy.Com',
       ----north america
       '/app/explweb/BirtReports/GDM/wim_report/1_dupe_uwi.rptdesign',
       ----asia pacific.... NOT deloyed
       'PDF',
       '10',
       '30',
       '6',
       'Mon-Fri',
       'CDONG',
       SYSDATE,
       'CDONG',
       SYSDATE
  from BIRT.REPORT_SERVER rs
 where RS.NAME = 'Calgary-01'
----Calgary TEST environment
-- where RS.NAME = 'Calgary-Test-01'
----Asia Pacific
-- where RS.NAME = 'KL-01'
)
;


---- specify report recipients

insert into birt.report_recipient (report_recipient_id, report_job_id, recipient_type, smtp_address, row_created_by, row_created_date, row_changed_by, row_changed_date)
select birt.seq_report_recipient_id.nextval,
       rj.report_job_id,
       'CC',
       'zTIS_Support@talisman-energy.com',
       user,
       sysdate,
       user,
       sysdate,
  from birt.report_job rj
 where rj.name = 'WIM Duplicate UWI'
)
;


/***************************************************************************************************/
----North America recipients (data stewards)
insert into birt.report_recipient (report_recipient_id, report_job_id, recipient_type, smtp_address, row_created_by, row_created_date, row_changed_by, row_changed_date)
select birt.seq_report_recipient_id.nextval,
       rj.report_job_id,
       'TO',
       'lmcallister@talisman-energy.com',
       user,
       sysdate,
       user,
       sysdate,
  from birt.report_job rj
 where rj.name = 'WIM Duplicate UWI'
;


/***************************************************************************************************/
---- Asia-Pacific recipients (data stewards)
---- report not deployed in AP
