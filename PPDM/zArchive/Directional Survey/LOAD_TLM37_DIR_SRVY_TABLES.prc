CREATE OR REPLACE PROCEDURE PPDM.LOAD_TLM37_DIR_SRVY_TABLES IS

/*-----------------------------------------------------------------------------------
Name:       PPDM.LOAD_TLM37_DIR_SRVY_TABLES
Purpose:    to load Dir Srvys and SirSrvy Stations from PPDM to TLM37.WORLD
Created by: V.Rajpoot
History:    May 2011        - Created

            June 10, 2011   - Changed to  get IPL_UWI_LOCAL from well table and update
                              Well_Dir_Srvy_Station@tlm37.world table.  
                            - If source if IHSE, then change to 300IPL, Otherwise it wil 
                              create duplicate rows.
                              if SRVYS.source = 'IHSE' then v_source:= '300IPL';
     

------------------------------------------------------------------------------------*/


    CURSOR DIR_SRVY_CUR ( ihs_last_date date,ppdm_last_date date) IS
        select *
        from WELL_DIR_SRVY
        WHERE (TRUNC(Row_Created_Date) >= TRUNC(ihs_last_date) AND TRUNC(Row_Created_Date) <= TRUNC(ppdm_last_date ))
       OR (TRUNC(Row_Changed_Date) >= TRUNC(ihs_last_date) AND TRUNC(Row_Changed_Date) <= TRUNC(ppdm_last_date ));
            --  and uwi in ('144774' ,'50100322000' , '50000244585','50000214626');    
  
    CURSOR DIR_SRVY_STATION_CUR( ihs_last_run_date date,ppdm_last_run_date date)  IS
        select * 
        from WELL_DIR_SRVY_STATION    
       WHERE (TRUNC(Row_Created_Date) >= TRUNC(ihs_last_run_date) AND TRUNC(Row_Created_Date) <= TRUNC(ppdm_last_run_date ))
        OR (TRUNC(Row_Changed_Date) >= TRUNC(ihs_last_run_date) AND TRUNC(Row_Changed_Date) <= TRUNC(ppdm_last_run_date ));
          --  and uwi in ('144774' ,'50100322000' , '50000244585','50000214626');    
            
  v_updated Number;
  v_inserted Number;
  v_num Number;
  v_ppdm_last_date Date;
  v_ihs_last_date Date;
  v_ppdm_created_date Date;
  v_ppdm_changed_date Date;
  v_ihs_created_date Date;
  v_ihs_changed_date Date;
    v_source varchar2 (15);
  v_ipl_uwi_local varchar2(20);
 v_i NUMBER;
  
BEGIN
  v_updated := 0;
  v_inserted := 0;
  
  --Get the last date
  
  Select Max(row_created_Date), Max(row_changed_date) into v_ihs_created_date, v_ihs_changed_date    
  from WELL_DIR_SRVY@TLM37.WORLD;
  
  if v_ihs_created_date > v_ihs_changed_date then
    v_ihs_last_date := v_ihs_created_date;
  else
    v_ihs_last_date := v_ihs_changed_date;
  end if;
  
  Select Max(row_created_Date), Max(row_changed_date) into v_ppdm_created_date, v_ppdm_changed_date    
  from WELL_DIR_SRVY;
  
  if v_ppdm_created_date > v_ppdm_changed_date then
    v_ppdm_last_date := v_ppdm_created_date;
  else
    v_ppdm_last_date := v_ppdm_changed_date;
  end if;


  ppdm.tlm_process_logger.info ('TLM37 DIR SRVY TABLES - LOAD STARTED');
  
  if v_ihs_last_date > v_ppdm_last_date then   
         ppdm.tlm_process_logger.info ('TLM37 DIR SRVY LOAD: COMPLETE: Total Updated = ' || v_updated || ' Total Added = ' || v_inserted);
  -- Nothing to update/add
    GoTo Stations;
  end if; 
  
  
    --OPEN DIR_SRVY;
     FOR SRVYS IN DIR_SRVY_CUR(v_ihs_last_date,v_ppdm_last_date) 
     LOOP     
        
        if SRVYS.source = 'IHSE' then
           v_source:= '300IPL';
        else
            v_source := SRVYS.source;
        end if;
        Select count(*) into v_num from WELL_DIR_SRVY@TLM37.WORLD
         Where UWI = SRVYS.UWI
           AND Survey_ID = SRVYS.Survey_ID
           AND Source = v_source       
           AND NVL(Survey_Numeric_ID,0) = NVL(SRVYS.Survey_Numeric_ID,0);            
       -- dbms_OUTPUT.PUT_LINE(v_num);
        
        IF v_num = 1 THEN
        --dbms_OUTPUT.PUT_LINE('Updating '  || SRVYS.UWI);
            UPDATE WELL_DIR_SRVY@TLM37.WORLD
               SET ACTIVE_IND = SRVYS.ACTIVE_IND,
                   AZIMUTH_NORTH_TYPE = SRVYS.AZIMUTH_NORTH_TYPE,
                   BASE_DEPTH = SRVYS.BASE_DEPTH,
                   BASE_DEPTH_OUOM = SRVYS.BASE_DEPTH_OUOM,
                   COMPUTE_METHOD = SRVYS.COMPUTE_METHOD,
                   COORD_SYSTEM_ID = SRVYS.COORD_SYSTEM_ID,
                   DIR_SURVEY_CLASS = SRVYS.DIR_SURVEY_CLASS,
                   EFFECTIVE_DATE = SRVYS.EFFECTIVE_DATE,
                   EW_DIRECTION = SRVYS.EW_DIRECTION,
                   EXPIRY_DATE = SRVYS.EXPIRY_DATE,
                   MAGNETIC_DECLINATION = SRVYS.MAGNETIC_DECLINATION,
                   OFFSET_NORTH_TYPE = SRVYS.OFFSET_NORTH_TYPE,
                   PLANE_OF_PROPOSAL    = SRVYS.PLANE_OF_PROPOSAL,
                   PPDM_GUID = SRVYS.ppdm_guid,
                   RECORD_MODE = SRVYS.RECORD_MODE,
                   REMARK = SRVYS.REMARK,
                   REPORT_APD = SRVYS.REPORT_APD,
                   REPORT_LOG_DATUM = SRVYS.REPORT_LOG_DATUM,
                   REPORt_LOG_DATUM_ELEV = SRVYS.REPORT_LOG_DATUM_ELEV,
                   REPORT_LOG_DATUM_ELEV_OUOM = SRVYS.REPORT_LOG_DATUM_ELEV_OUOM,
                   REPORT_PERM_DATUM = SRVYS.REPORT_PERM_DATUM,
                   REPORT_PERM_DATUM_ELEV = SRVYS.REPORT_PERM_DATUM_ELEV,
                   REPORT_PERM_DATUM_ELEV_OUOM = SRVYS.REPORT_PERM_DATUM_ELEV_OUOM,
                   SOURCE_DOCUMENT = SRVYS.SOURCE_DOCUMENT,
                   SURVEY_COMPANY = SRVYS.SURVEY_COMPANY,
                   SURVEY_DATE = SRVYS.SURVEY_DATE,
                   SURVEY_QUALITY = SRVYS.SURVEY_QUALITY,
                   SURVEY_TYPE = SRVYS.SURVEY_TYPE,
                   TOP_DEPTH = SRVYS.TOP_DEPTH,
                   TOP_DEPTH_OUOM = SRVYS.TOP_DEPTH_OUOM,
                   ROW_CHANGED_BY = SRVYS.ROW_CHANGED_BY,
                   ROW_CHANGED_DATE = SRVYS.ROW_CHANGED_DATE,
                   ROW_QUALITY = SRVYS.ROW_QUALITY,
                  --PROVINCE_STATE = SRVYS.PROVINCE_STATE,
                   X_ORIG_DOCUMENT = SRVYS.X_ORIG_DOCUMENT
             WHERE UWI = SRVYS.UWI
               AND Survey_ID = SRVYS.Survey_ID
               AND Source = v_source
               AND NVL(Survey_Numeric_ID,0) = NVL(SRVYS.Survey_Numeric_ID,0);             
               v_updated := v_updated +1;
               
               
           ELSIF v_num = 0 THEN
            
            --dbms_OUTPUT.PUT_LINE('Inserting ' || SRVYS.UWI);
                INSERT INTO WELL_DIR_SRVY@TLM37.WORLD
                  (UWI, SURVEY_ID,SOURCE, ACTIVE_IND, AZIMUTH_NORTH_TYPE,BASE_DEPTH, BASE_DEPTH_OUOM,
                   COMPUTE_METHOD, COORD_SYSTEM_ID, DIR_SURVEY_CLASS, EFFECTIVE_DATE,EW_DIRECTION,
                   EXPIRY_DATE,MAGNETIC_DECLINATION,OFFSET_NORTH_TYPE,PLANE_OF_PROPOSAL,ppdm_guid,RECORD_MODE,
                   REMARK,REPORT_APD,REPORT_LOG_DATUM,REPORT_LOG_DATUM_ELEV,REPORT_LOG_DATUM_ELEV_OUOM,
                   REPORT_PERM_DATUM,REPORT_PERM_DATUM_ELEV,REPORT_PERM_DATUM_ELEV_OUOM,SOURCE_DOCUMENT, 
                   SURVEY_COMPANY,SURVEY_DATE,SURVEY_NUMERIC_ID,SURVEY_QUALITY,  SURVEY_TYPE, TOP_DEPTH, TOP_DEPTH_OUOM,
                   ROW_CHANGED_BY, ROW_CHANGED_DATE,row_CREATED_BY, ROW_CREATED_DATE,ROW_QUALITY,X_ORIG_DOCUMENT)                   
                  
                  VALUES (SRVYS.UWI, SRVYS.SURVEY_ID,v_source, SRVYS.ACTIVE_IND,SRVYS.AZIMUTH_NORTH_TYPE,SRVYS.BASE_DEPTH,SRVYS.BASE_DEPTH_OUOM,
                   SRVYS.COMPUTE_METHOD,SRVYS.COORD_SYSTEM_ID,SRVYS.DIR_SURVEY_CLASS,SRVYS.EFFECTIVE_DATE,SRVYS.EW_DIRECTION,
                   SRVYS.EXPIRY_DATE,SRVYS.MAGNETIC_DECLINATION,SRVYS.OFFSET_NORTH_TYPE,SRVYS.PLANE_OF_PROPOSAL,SRVYS.ppdm_guid,SRVYS.RECORD_MODE,
                   SRVYS.REMARK,SRVYS.REPORT_APD,SRVYS.REPORT_LOG_DATUM,SRVYS.REPORT_LOG_DATUM_ELEV, SRVYS.REPORT_LOG_DATUM_ELEV_OUOM,
                   SRVYS.REPORT_PERM_DATUM,SRVYS.REPORT_PERM_DATUM_ELEV,SRVYS.REPORT_PERM_DATUM_ELEV_OUOM,SRVYS.SOURCE_DOCUMENT,
                   SRVYS.SURVEY_COMPANY,SRVYS.SURVEY_DATE,SRVYS.SURVEY_NUMERIC_ID,SRVYS.SURVEY_QUALITY,SRVYS.SURVEY_TYPE,SRVYS.TOP_DEPTH,SRVYS.TOP_DEPTH_OUOM,
                   SRVYS.ROW_CHANGED_BY,SRVYS.ROW_CHANGED_DATE,SRVYS.ROW_CREATED_BY, SRVYS.ROW_CREATED_DATE,SRVYS.ROW_QUALITY,SRVYS.X_ORIG_DOCUMENT);
                               
                   v_inserted := v_inserted+1;
               
               ELSE               
                 -- through an exception
                 ppdm.tlm_process_logger.error ('TLM37 DIR SRVY LOAD FAILED: More than one rows exist for uwi ' || SRVYS.UWI);
                  
      END IF;
     END LOOP;
      
     ppdm.tlm_process_logger.info ('TLM37 DIR SRVY LOAD: COMPLETE: Total Updated = ' || v_updated || ' Total Added = ' || v_inserted);
    COMMIT;
     
     <<Stations>>
   
    
    
      Select Max(row_created_Date), Max(row_changed_date) into v_ihs_created_date, v_ihs_changed_date    
      from WELL_DIR_SRVY_STATION@TLM37.WORLD;
      
      if v_ihs_created_date > v_ihs_changed_date then
        v_ihs_last_date := v_ihs_created_date;
      else
        v_ihs_last_date := v_ihs_changed_date;
      end if;
          
      Select Max(row_created_Date), Max(row_changed_date) into v_ppdm_created_date, v_ppdm_changed_date    
      from WELL_DIR_SRVY_STATION;
      
      if v_ppdm_created_date > v_ppdm_changed_date then
        v_ppdm_last_date := v_ppdm_created_date;
      else
        v_ppdm_last_date := v_ppdm_changed_date;
      end if;
    
      if v_ihs_last_date > v_ppdm_last_date then
          --dbms_OUTPUT.PUT_LINE('return from stations');
           ppdm.tlm_process_logger.info ('TLM37 DIR SRVY STATION LOAD: COMPLETE: Total Updated = ' || v_updated || ' Total Added = ' || v_inserted);
           ppdm.tlm_process_logger.info ('TLM37 DIR SRVY TABLES LOAD COMPLETED');
          -- Nothing to update/add
           RETURN;
      end if;
     v_updated := 0;
     v_inserted := 0;
       
     FOR stations IN DIR_SRVY_STATION_CUR(v_ihs_last_date,v_ppdm_last_date) 
     LOOP     
     
        if stations.source = 'IHSE' then
            v_source := '300IPL';
         else
            v_source := stations.source;
        end if;
        
        select count(uwi) into v_i
        from well
        where uwi = stations.UWI;
        
        if v_i > 0 then
            select ipl_uwi_local into v_ipl_uwi_local 
             from well
            where uwi = stations.UWI;
              
        end if;
        Select count(*) into v_num from WELL_DIR_SRVY_STATION@TLM37.WORLD
         Where UWI = stations.UWI
           AND Survey_ID = stations.Survey_ID
           AND Source = v_source        
           AND Depth_obs_No = stations.Depth_obs_No
           AND Location_Qualifier = stations.location_qualifier
           AND Geog_coord_system_id = stations.Geog_coord_system_id;           
    
        IF v_num = 1 THEN
        --dbms_OUTPUT.PUT_LINE('Updating '  || v_num);
        
            UPDATE WELL_DIR_SRVY_STATION@TLM37.WORLD
               SET ACTIVE_IND = stations.ACTIVE_IND,                   
                   AZIMUTH = stations.AZIMUTH,
                   DOG_LEG_SEVERITY = stations.DOG_LEG_SEVERITY,
                   EFFECTIVE_DATE = stations.EFFECTIVE_DATE,
                   EW_DIRECTION = stations.EW_DIRECTION,
                   EXPIRY_DATE = stations.EXPIRY_DATE,
                   INCLINATION = stations.INCLINATION,
                   INCLINATION_OUOM = stations.INCLINATION_OUOM,                   
                   LATITUDE = stations.LATITUDE,
                   LONGITUDE = stations.LONGITUDE,
                   NS_DIRECTION = stations.NS_DIRECTION,
                   POINT_TYPE = stations.POINT_TYPE,
                   PPDM_GUID = stations.PPDM_GUID,
                   REMARK = stations.REMARK,
                   STATION_ID = stations.STATION_ID,
                   STATION_MD = stations.STATION_MD,
                   STATION_MD_OUOM = stations.STATION_MD_OUOM,
                   STATION_TVD = stations.STATION_TVD,
                   STATION_TVD_OUOM = stations.STATION_TVD_OUOM,
                   VERTICAL_SECTION = stations.VERTICAL_SECTION,
                   VERTICAL_SECTION_OUOM = stations.VERTICAL_SECTION_OUOM,
                   X_OFFSET = stations.X_OFFSET,
                   X_OFFSET_OUOM = stations.X_OFFSET_OUOM,
                   Y_OFFSET = stations.Y_OFFSET,
                   Y_OFFSET_OUOM = stations.Y_OFFSET_OUOM,
                   ROW_CHANGED_BY = stations.ROW_CHANGED_BY, 
                   ROW_CHANGED_DATE = stations.ROW_CHANGED_DATE,
                   ROW_QUALITY = stations.ROW_QUALITY,
                   GEOG_COORD_SYSTEM_ID = stations.GEOG_COORD_SYSTEM_ID,
                   LOCATION_QUALIFIER = stations.LOCATION_QUALIFIER,
                   IPL_UWI_LOCAL = v_ipl_uwi_local
                  WHERE UWI = stations.UWI
               AND Survey_ID = stations.Survey_ID
               AND Source = stations.Source
               AND Depth_Obs_No = stations.Depth_Obs_No
               AND (stations.location_qualifier IS NULL OR location_qualifier = stations.location_qualifier)
               AND (stations.Geog_coord_system_id IS NULL OR  Geog_coord_system_id = stations.Geog_coord_system_id);
               v_updated := v_updated +1;
                     
               
           ELSIF v_num = 0 THEN            
      
                INSERT INTO WELL_DIR_SRVY_STATION@TLM37.WORLD
                  (UWI, SURVEY_ID,SOURCE, ACTIVE_IND, DEPTH_OBS_NO,
                   AZIMUTH,DOG_LEG_SEVERITY,EFFECTIVE_DATE,EW_DIRECTION,EXPIRY_DATE,INCLINATION,
                   INCLINATION_OUOM,LATITUDE,LONGITUDE,NS_DIRECTION,POINT_TYPE,PPDM_GUID,REMARK,
                   STATION_ID,STATION_MD,STATION_MD_OUOM,STATION_TVD,
                   STATION_TVD_OUOM,VERTICAL_SECTION,VERTICAL_SECTION_OUOM,X_OFFSET,X_OFFSET_OUOM,
                   Y_OFFSET,  Y_OFFSET_OUOM, ROW_CHANGED_BY, ROW_CHANGED_DATE,ROW_CREATED_BY, ROW_CREATED_DATE,
                   ROW_QUALITY, GEOG_COORD_SYSTEM_ID,LOCATION_QUALIFIER,IPL_UWI_LOCAL)                   
                  
                  VALUES (stations.UWI, stations.SURVEY_ID,v_source, stations.ACTIVE_IND,stations.DEPTH_OBS_NO,
                   stations.AZIMUTH,stations.DOG_LEG_SEVERITY,stations.EFFECTIVE_DATE,stations.EW_DIRECTION,stations.EXPIRY_DATE,stations.INCLINATION,
                   stations.INCLINATION_OUOM,stations.LATITUDE,stations.LONGITUDE,stations.NS_DIRECTION,stations.POINT_TYPE,stations.PPDM_GUID,stations.REMARK,
                   stations.STATION_ID,stations.STATION_MD,stations.STATION_MD_OUOM,stations.STATION_TVD,
                   stations.STATION_TVD_OUOM,stations.VERTICAL_SECTION,stations.VERTICAL_SECTION_OUOM,stations.X_OFFSET,stations.X_OFFSET_OUOM,
                   stations.Y_OFFSET, stations.Y_OFFSET_OUOM, stations.ROW_CHANGED_BY, stations.ROW_CHANGED_DATE, 
                   stations.ROW_CREATED_BY, stations.ROW_CREATED_DATE,
                   stations.ROW_QUALITY, stations.GEOG_COORD_SYSTEM_ID,stations.LOCATION_QUALIFIER,v_ipl_uwi_local);
                               
                   v_inserted := v_inserted+1;
               
               ELSE               
                 -- throw an exception
                 ppdm.tlm_process_logger.error ('TLM37 DIR SRVY STATIONS LOAD FAILED: More than one rows exist for uwi ' || stations.UWI);
                 ROLLBACK;
      END IF;
     END LOOP;
     
     ppdm.tlm_process_logger.info ('TLM37 DIR SRVY STATION LOAD: COMPLETE: Total Updated = ' || v_updated || ' Total Added = ' || v_inserted);
     ppdm.tlm_process_logger.info ('TLM37 DIR SRVY TABLES LOAD COMPLETED');
     COMMIT;
    

    EXCEPTION
    WHEN OTHERS
      THEN
      ppdm.tlm_process_logger.error ('TLM37 DIR SRVY TABLES LOAD FAILED: Oracle Error - ' || SQLERRM);                                                        
      ROLLBACK;
     
     
END;
/
