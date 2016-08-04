/**********************************************************************************************************************
 Trigger for TLM directional survey station data
 Ensure the dir srvy header has a value for coord_system_id.  Get this from the first depth_obs_no from station data.
 
 History
  2015-01-06    cdong   TIS Task 1563.  Initial creation.

 **********************************************************************************************************************/
 
 
--drop trigger PPDM.T_TLM_WELL_DIR_SRVY_STN_AUI1;

CREATE OR REPLACE TRIGGER PPDM.T_TLM_WELL_DIR_SRVY_STN_AUI1
    AFTER UPDATE OR INSERT
    ON PPDM.TLM_WELL_DIR_SRVY_STATION  FOR EACH ROW
DECLARE

BEGIN
/*-------------------------------------------------------------------------------------
Trigger:    T_TLM_WELL_DIR_SRVY_STN_AUI1
purpose:    test

History:
1.0.0   2015-01-06  cdong   initial creation.  trigger for each row, because it needs details from the row
                            update the dir srvy header and set the coord_system_id
                            assumption is that the header record is created before the station data (there is FK to enforce this)
                            TIS Task 1563

--------------------------------------------------------------------------------------*/

    IF UPDATING OR INSERTING THEN
        --ensure trigger only fires for the first depth_obs_no
        IF :NEW.DEPTH_OBS_NO = 1 THEN
            --ppdm_admin.tlm_process_logger.info('Trigger T_TLM_WELL_DIR_SRVY_STN_AUI1: after update or insert on tlm_well_dir_srvy_STATION for uwi ' || :NEW.UWI || ' at ' || to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ss.ffff'));
            
            UPDATE PPDM.TLM_WELL_DIR_SRVY 
               SET COORD_SYSTEM_ID = :NEW.GEOG_COORD_SYSTEM_ID
             WHERE UWI = :NEW.UWI
                   AND SURVEY_ID = :NEW.SURVEY_ID
                   AND SOURCE = :NEW.SOURCE
            ;
        END IF;
    END IF;

END;
