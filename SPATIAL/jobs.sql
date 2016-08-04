BEGIN 
  SYS.DBMS_JOB.REMOVE(189);
COMMIT;
END;
/

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
  ( job       => X 
   ,what      => 'EXECUTE IMMEDIATE ''TRUNCATE TABLE WELL_SPATIAL_MV'';  tlm_mview_util.freshen_spatial(189);'
   ,next_date => to_date('08/03/2013 15:00:00','dd/mm/yyyy hh24:mi:ss')
   ,interval  => 'TRUNC(SYSDATE+1)+15/24'
   ,no_parse  => FALSE
  );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;
/



BEGIN 
  SYS.DBMS_JOB.REMOVE(349);
COMMIT;
END;
/

DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
  ( job       => X 
   ,what      => 'dbms_mview.refresh( ''TLM_WELL_DIR_SRVY_SPATIAL_MV'',''C'');'
   ,next_date => to_date('08/03/2013 21:00:00','dd/mm/yyyy hh24:mi:ss')
   ,interval  => 'TRUNC(SYSDATE+1)+21/24'
   ,no_parse  => FALSE
  );
  SYS.DBMS_OUTPUT.PUT_LINE('Job Number is: ' || to_char(x));
COMMIT;
END;
/



