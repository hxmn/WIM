/************************************************************************************

  Create Oracle job to refresh the PPDM.TLM_WELL_DIR_SRVY_QUALITY_MV materialized view

  History: 20141010 cdong
            create job to refresh PPDM.TLM_WELL_DIR_SRVY_QUALITY_MV

 ************************************************************************************/

----from PPDM_ADMIN schema, grant rights to run refresh package

GRANT EXECUTE ON PPDM_ADMIN.TLM_MVIEW_UTIL TO PPDM ;


----create job

/*
BEGIN
  SYS.DBMS_JOB.REMOVE(138);
COMMIT;
END;
*/


DECLARE
  --X NUMBER;
BEGIN
  SYS.DBMS_JOB.ISUBMIT
  ( job           => 138
     , what       => 'EXECUTE IMMEDIATE ''TRUNCATE TABLE PPDM.TLM_WELL_DIR_SRVY_QUALITY_MV''; ppdm_admin.tlm_mview_util.freshen_mview(''PPDM'', ''TLM_WELL_DIR_SRVY_QUALITY_MV'', ''C'');'
     , next_date  => to_date('2024/12/31 20:00:00','yyyy/mm/dd hh24:mi:ss')
     , interval   => 'TRUNC(SYSDATE+1)+20/24'
     , no_parse   => FALSE
  );
  --SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;



SELECT JOB, LAST_DATE, THIS_DATE, NEXT_DATE, WHAT, INTERVAL, BROKEN, FAILURES FROM ALL_JOBS ORDER BY NEXT_DATE;
