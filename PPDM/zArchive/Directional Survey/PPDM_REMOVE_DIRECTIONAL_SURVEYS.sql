CREATE OR REPLACE PACKAGE PPDM.DIR_SRVY_UTILS AS

-- SCRIPT: PPDM_REMOVE_DIRECTIONAL_SURVEYS
--
-- PURPOSE:
-- The procedure in this package is used to REMOVE Directional Surveys.  
--
-- DEPENDENCIES:
--
-- EXECUTION:
-- Owned by PPDM, executable by PPDM_WRITE & PPDM_CHANGE
--
-- SYNTAX:
-- Need to provide UWI, SURVEY_ID, SOURCE in variables P_UWI, P_SURVEY_ID, P_SOURCE to delete that particular Directional Survey.
-- Need to provide YES in variable P_Commit to commit the changes.
--
-- Created by: 	N. Grewal
-- History:	June 14, 2011 	-Created	


  PROCEDURE REMOVE_SURVEY(
                    P_UWI          IN TLM_WELL_DIR_SRVY.UWI%TYPE,
                    P_SURVEY_ID    IN TLM_WELL_DIR_SRVY.SURVEY_ID%TYPE,
		    P_SOURCE	   IN TLM_WELL_DIR_SRVY.SOURCE%TYPE,
                    P_Commit       IN VARCHAR2
                    );

END DIR_SRVY_UTILS;
/


====================================================================================================================================
CREATE OR REPLACE PACKAGE BODY PPDM.DIR_SRVY_UTILS AS

-- SCRIPT: PPDM_REMOVE_DIRECTIONAL_SURVEYS
--
-- PURPOSE:
-- The procedure in this package is used to REMOVE Directional Surveys.  
--
-- DEPENDENCIES:
--
-- EXECUTION:
-- Owned by PPDM, executable by PPDM_WRITE & PPDM_CHANGE
--
-- SYNTAX:
-- Need to provide UWI, SURVEY_ID, SOURCE in variables P_UWI, P_SURVEY_ID, P_SOURCE to delete that particular Directional Survey.
-- Need to provide YES in variable P_Commit to commit the changes.
--
-- Created by: 	N. Grewal
-- History:	June 14, 2011 	-Created	

PROCEDURE REMOVE_SURVEY(
                    P_UWI          IN TLM_WELL_DIR_SRVY.UWI%TYPE,
                    P_SURVEY_ID    IN TLM_WELL_DIR_SRVY.SURVEY_ID%TYPE,
		    P_SOURCE	   IN TLM_WELL_DIR_SRVY.SOURCE%TYPE,
                    P_Commit       IN VARCHAR2
                    ) IS


    V_InputCount        	NUMBER := 0;
    V_TLMWELLDIRSRVY_C    	NUMBER := 0;
    V_TLMWELLDIRSRVYSTAT_C	NUMBER := 0;
    V_TotalChangeCount     	NUMBER := 0;
    
  BEGIN
    
    -- Start Logging the existence of Directional Survey
    ppdm.tlm_process_logger.info ('Verifying existence of Directional Survey for UWI ='||P_UWI||', SURVEY_ID ='||P_SURVEY_ID||', SOURCE ='||P_SOURCE);
    	SELECT COUNT(*) 
	INTO V_InputCount
      	FROM TLM_WELL_DIR_SRVY
    	WHERE UWI = P_UWI
       	AND SURVEY_ID = P_SURVEY_ID
      	AND SOURCE = P_SOURCE;

    IF V_InputCount = 0 THEN							-- can not delete data
      ppdm.tlm_process_logger.info ('No Directional Survey Exist for UWI ='||P_UWI||', SURVEY_ID ='||P_SURVEY_ID||', SOURCE ='||P_SOURCE||'!'); 
    ELSE

        ppdm.tlm_process_logger.info ('Deleting TLM_WELL_DIR_SRVY records');    -- can delete data
        DELETE FROM TLM_WELL_DIR_SRVY
        WHERE UWI = P_UWI
       	AND SURVEY_ID = P_SURVEY_ID
      	AND SOURCE = P_SOURCE;
        V_TLMWELLDIRSRVY_C := SQL%ROWCOUNT;

	ppdm.tlm_process_logger.info ('Deleting TLM_WELL_DIR_SRVY_STATION records');
	DELETE FROM TLM_WELL_DIR_SRVY_STATION
        WHERE UWI = P_UWI
       	AND SURVEY_ID = P_SURVEY_ID
      	AND SOURCE = P_SOURCE;
        V_TLMWELLDIRSRVYSTAT_C := SQL%ROWCOUNT;


	V_TotalChangeCount := V_TLMWELLDIRSRVY_C+V_TLMWELLDIRSRVYSTAT_C;   -- total number of records deleted


    IF V_TLMWELLDIRSRVY_C > 0 THEN					-- number of records deleted in TLM_WELL_DIR_SRVY table
       ppdm.tlm_process_logger.info (LPAD(TO_CHAR(V_TLMWELLDIRSRVY_C),5)||' TLM_WELL_DIR_SRVY row(s) deleted from '||P_UWI||', SURVEY_ID ='||P_SURVEY_ID||', SOURCE ='||P_SOURCE||'.');
    END IF;

   IF V_TLMWELLDIRSRVYSTAT_C > 0 THEN					-- number of records deleted in TLM_WELL_DIR_SRVY_STATION table
       ppdm.tlm_process_logger.info (LPAD(TO_CHAR(V_TLMWELLDIRSRVYSTAT_C),5)||' TLM_WELL_DIR_SRVY_STATION row(s) deleted from '||P_UWI||', SURVEY_ID ='||P_SURVEY_ID||', SOURCE ='||P_SOURCE||'.');
    END IF;

   IF V_TotalChangeCount = 0 THEN					-- can not delete data
      ppdm.tlm_process_logger.info ('No Directional Survey Deleted for UWI ='||P_UWI||', SURVEY_ID ='||P_SURVEY_ID||', SOURCE ='||P_SOURCE||'.'); 
   ELSE
    IF UPPER(P_Commit) = 'YES' THEN   				-- YES to commit changes
            COMMIT;
            ppdm.tlm_process_logger.info (LPAD(TO_CHAR(V_TotalChangeCount),5)||' Total changes commited when deleting DIR SVRYs !'); -- number of records commited
          ELSE
            ROLLBACK;
            ppdm.tlm_process_logger.info (LPAD(TO_CHAR(V_TotalChangeCount),5)||' Total changes rolled back when deleting DIR SVRYs !'); -- number of records rolled back
          END IF;
        END IF;

      END IF;     

    COMMIT;

EXCEPTION
    WHEN OTHERS
      THEN
      ppdm.tlm_process_logger.error ('Oracle Error - ' || SQLERRM);  -- logging other Oracle errors
  END REMOVE_SURVEY;
       
END DIR_SRVY_UTILS;
/



====================================================================================================================================
====================================================================================================================================

-- Grant execute privilege to users PPDM_WRITE & PPDM_UPDATE
grant execute on PPDM.DIR_SRVY_UTILS to PPDM_WRITE;--user
grant execute on PPDM.DIR_SRVY_UTILS to PPDM_CHANGE;--role

-- Running the Procedure
exec DIR_SRVY_UTILS.REMOVE_SURVEY('1000000244','001','700TLME','YES');
exec DIR_SRVY_UTILS.REMOVE_SURVEY('1000000244','002','700TLME','YES');


-- See that the procedure ran and it logged messages
select klass, text, session_id, row_created_by, to_char(row_created_on)
  from ppdm.tlm_process_log
 where row_created_on > sysdate - 7
 order by row_created_on desc;
     