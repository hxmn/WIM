/*******************************************************************************

 Define BIRT report schedule and recipients for TIS Housekeeping Counts report

 RUN FROM: BIRT schema in SEI* database, from where the BIRT Scheduler gets its job information

 Attention: modify the script for the appropriate region and environment. Additionally, only specify
   the recipients for the region the report is being deployed to.

 History
  20141002  cdong   TIS Task 1453 - created script

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
select 20,
       RS.REPORT_SERVER_ID,
       'TIS Housekeeping Counts',
       'Report summarizing the WIM Housekeeping activity counts.  Each Housekeeping task runs a check of the data and outputs a count to the log.',
       'TIS Housekeeping Summary report',
       'BirtScheduler@Talisman-Energy.Com',
       ----north america
       '/app/explweb/BirtReports/GDM/tis/TIS_Summary.rptdesign',
       ----asia pacific
       --'/data/pdmsweb/BirtReports/GDM/tis/TIS_Summary_AP.rptdesign',
       'PDF',
       '10',
       '30',
       '1',
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
       'TO',
       'zTIS_Support@talisman-energy.com',
       user,
       sysdate,
       user,
       sysdate,
  from birt.report_job rj
 where rj.name = 'TIS Housekeeping Counts'
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
 where rj.name = 'TIS Housekeeping Counts'
;


/***************************************************************************************************/
---- Asia-Pacific recipients (data stewards)
insert into birt.report_recipient (report_recipient_id, report_job_id, recipient_type, smtp_address, row_created_by, row_created_date, row_changed_by, row_changed_date)
select birt.seq_report_recipient_id.nextval,
       rj.report_job_id,
       'TO',
       'szabakar@talisman-energy.com',
       user,
       sysdate,
       user,
       sysdate,
  from birt.report_job rj
 where rj.name = 'TIS Housekeeping Counts'
;

insert into birt.report_recipient (report_recipient_id, report_job_id, recipient_type, smtp_address, row_created_by, row_created_date, row_changed_by, row_changed_date)
select birt.seq_report_recipient_id.nextval,
       rj.report_job_id,
       'TO',
       'rsymonds@talisman-energy.com',
       user,
       sysdate,
       user,
       sysdate,
  from birt.report_job rj
 where rj.name = 'TIS Housekeeping Counts'
;
