/*******************************************************************************

 Create database job to execute the procedure that extracts counts from the log

 History
  20141002  cdong   TIS Task 1453 - created script
  20150707  cdong   TIS Task 1656 - move objects to WIM schema

 *******************************************************************************/


---- OR, set your own job number
DECLARE
  --X NUMBER;
BEGIN
  SYS.DBMS_JOB.ISUBMIT
  ( job       => 193
   ,what      => 'log_housekeeping_counts;'
   ,next_date => trunc(sysdate+1)+1/24
   ,interval  => 'trunc(sysdate+1)+1/24'
   ,no_parse  => FALSE
  );
  --SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;


/* --debugging
---- review existing jobs
SELECT JOB, LAST_DATE, THIS_DATE, NEXT_DATE, WHAT, INTERVAL, BROKEN, FAILURES FROM ALL_JOBS ORDER BY NEXT_DATE;

*/
