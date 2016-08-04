CREATE OR REPLACE PROCEDURE WIM."WIM_HOUSEKEEPING" IS


  -- Local procedure to check for and set null active indicators
  PROCEDURE NULL_ACTIVE_INDICATORS (TABLE_NAME VARCHAR2) IS
    Nulls    NUMBER(10) := 0;
    SQL_Text VARCHAR2(1000);
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ' || TABLE_NAME || ' WHERE ACTIVE_IND IS NULL' INTO NULLS;
    IF Nulls > 0 THEN
      ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: NULL active indicators in ' || TABLE_NAME || ': ' || NULLS);
      execute immediate 'update ' || TABLE_NAME || ' set active_ind = ''Y'' where active_ind is null';
      commit;
    END IF;
  END;
    
BEGIN

  -- Log the start of housekeeping
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Housekeeping');



  -- *****************************************************************************
  --  FIX : ACTIVE INDICATOR NOT SET  (Task #334, #34)
  --   Some loaders and the Well Master application don't set the ACTIVE_IND field
  --   These steps clean that up in the primary tables.
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Set null active indicators');
  NULL_ACTIVE_INDICATORS('WELL');
  NULL_ACTIVE_INDICATORS('WELL_VERSION');
  NULL_ACTIVE_INDICATORS('WELL_NODE');
  NULL_ACTIVE_INDICATORS('WELL_NODE_VERSION');
  NULL_ACTIVE_INDICATORS('WELL_STATUS');
  NULL_ACTIVE_INDICATORS('WELL_LICENSE');
  NULL_ACTIVE_INDICATORS('WELL_ALIAS');
  NULL_ACTIVE_INDICATORS('POOL');
  NULL_ACTIVE_INDICATORS('WELL_NODE_M_B');
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Set null active indicators');


  -- *****************************************************************************
  --  FIX : INACTIVE WELLS
  --   Find and inactivate WELLS with no active versions
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Inactivate Wells');

  DECLARE
    CURSOR remove_inactive_well_cursor IS
        select uwi from  well where active_ind = 'Y'
         minus
        select uwi from  well_version where active_ind = 'Y';

  BEGIN
    for riwc in remove_inactive_well_cursor loop
      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: Well '||riwc.uwi || ' inactivated - it has no active versions');
      update  well set active_ind = 'N' where uwi=riwc.uwi;
      update  well_status set active_ind ='N' where uwi=riwc.uwi;
      update  well_license set active_ind ='N' where uwi=riwc.uwi;
      -- Can't do the following yet as they may be used by other wells at the moment.
        --update well_node set active_ind ='N' where surface_node_id=riwc.surface_node_id (*)
        --update well_node set active_ind ='N' where base_node_id=riwc.base_node_id (*)
        --update well_node_version set active_ind ='N' where node_id=riwc.surface_node_id (*)
        --update well_node_version set active_ind ='N' where node_id=riwc.base_node_id  (*)
    end loop;
    commit;
  END;  
  
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Inactivate Wells');

  -- *****************************************************************************
  --  FIX : Empty Nesters
  --   Find any WELLS with no versions and deactivate (soft delete) them
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : De-activate Empty Nesters');

  DECLARE
    CURSOR remove_emptynester_well_cursor IS
        select uwi from  well where active_ind = 'Y'
      MINUS
        select uwi from  well_version;
        
    emptynester_row  well%rowtype;

  BEGIN
    for rewc in remove_emptynester_well_cursor loop
      select * into emptynester_row from  well where uwi=rewc.uwi; 
      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: Empty Nester Inactivated: UWI='||rewc.uwi||', Source='||emptynester_row.primary_source||', Country='||emptynester_row.country);
      update  well set active_ind = 'N' where uwi=rewc.uwi;
      update  well_alias set active_ind = 'N' where uwi=rewc.uwi;
      update  well_status set active_ind = 'N' where uwi=rewc.uwi;
      update  well_license set active_ind = 'N' where uwi=rewc.uwi;
    end loop;
    commit;
  END;
  
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Deactivate Empty Nesters');

/*  
   -- *****************************************************************************
  --  FIX : Force a rollup of the CWS (100TLM) source wells after the daily load
  --        These changes may not be picked up by the standard roll up checker
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : CWS (100TLM) source Roll Ups');

  WIM.WIM_ROLLUP.SOURCE_ROLLUP('100TLM');

  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : CWS (100TLM) source Roll Ups');
*/  
  -- *****************************************************************************
  --  FIX : Find any missed roll ups (Task #471)
  --   Checks for wells that are not rolled up and rolls them up
  --   We still need this in case a load or manual DELETE leaves an inconsistent
  --   composite node.
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Missed Roll Ups');

  DECLARE
  
    -- Finds:
    --  1) Active well versions not appearing as an active composite - active versions should rollup
    --  2) Composite wells that are not in the well version table - should be removed
    --  3) Wells with active nodes that are not in the composite node table  - active versions should rollup
    --  4) Wells with composite nodes that are not in the node version table - nodes should be removed
  
    CURSOR wells_to_roll_up IS
      (select uwi from  well_version where active_ind = 'Y'
         minus
      select uwi from  well where active_ind = 'Y')
      union
     (select uwi from  well
         minus
      select uwi from  well_version)
      union
     (select ipl_uwi from  well_node_version where active_ind = 'Y'
         minus
      select ipl_uwi from  well_node where active_ind = 'Y')
      union
     (select ipl_uwi from  well_node
         minus
      select ipl_uwi from  well_node_version);
  
  BEGIN
    for TLM_ID in wells_to_roll_up loop
      WIM.WIM_ROLLUP.WELL_ROLLUP(TLM_ID.UWI);
      ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: Rolled up well ' || TLM_ID.UWI);
      commit;
    end loop;
  END;

  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Missed Roll Ups');

  -- *****************************************************************************
  --  FIX : Recursive Aliases (Task #773)
  --   Checks for alises that point to themselves - will cause FIND_WELL failure
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Recursive Alias Check');

  --  Check for alias recursion
  DECLARE

    pCount NUMBER;  -- Recursion counter
  
    --  Cursor to find TLM_ID aliases
    CURSOR ALIAS_WELLS IS
       select uwi, source, well_alias
         from  well_alias
        where alias_type = 'TLM_ID'
          and Active_Ind = 'Y';

   
    --  Checks for recursion data
    PROCEDURE CHECK_ALIAS (pFROM   IN     VARCHAR,
                           pTO     IN     VARCHAR,
                           pSource IN     VARCHAR,
                           pCount  IN OUT NUMBER) IS

      cMax_Levels NUMBER DEFAULT 20;
      vNEW_TO      WELL_VERSION.UWI%TYPE;
      
    BEGIN
       pCount := pCount + 1;
       IF pCount > cMax_Levels OR pFROM = pTO THEN
          ppdm_admin.tlm_process_logger.error ('WIM_HOUSEKEEPING: Recursive alias ALIAS=' || pFROM || ', TLM_ID=' || pTO || ', Source= ' || pSOURCE || ' with recursion depth of ' || pCount);
       ELSE
         SELECT MAX(UWI) INTO vNEW_TO   -- Get the next level and use MAX to avoid multiple returns
           FROM  WELL_ALIAS
          WHERE WELL_ALIAS = pTO
            AND Alias_type = 'TLM_ID'
            AND Source = pSource
            AND Active_Ind = 'Y';
                 
         IF vNEW_TO IS NOT NULL THEN -- Drill down to next level
           CHECK_ALIAS(pTO, vNEW_TO, pSource,pCount);
         END IF;
         
       END IF;
    END;


  BEGIN
  
    -- For each of the TLM_ID aliases check they don't stick in infinite loops
    FOR Next_Well IN ALIAS_WELLS LOOP
      BEGIN
        pCount := 0;
        CHECK_ALIAS (Next_Well.Well_alias, Next_Well.UWI, Next_Well.Source, pCount);
      END;
    END LOOP;

  END;

  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Recursive Alias Check');


  -- *****************************************************************************
  --  FIX : Check for fatal errors in the WIM audit log (#790)
  --   
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WIM Audit fatal error check');


  DECLARE

    pCount NUMBER;        -- Error counter
    pPeriod NUMBER := 7;  -- Days to check (e.g. 7 for the last week)
  
  BEGIN
  
    SELECT COUNT(1) INTO pCount
      FROM WIM_AUDIT_LOG
     WHERE AUDIT_TYPE = 'F'
       AND ROW_CREATED_DATE > SYSDATE - pPeriod;
    IF pCount > 0 THEN
      ppdm_admin.tlm_process_logger.error ('WIM_HOUSEKEEPING: ' || pCount || ' WIM fatal errors in the last ' || pPeriod || ' day(s)');
    END IF; 

  END;

  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WIM Audit fatal error check');

-- *****************************************************************************
  --  CHECK : Country Consistency Check
  --  WIM Housekeeping - Country Consistency Check (Task #905)
  -- ***************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : COUNTRY CONSISTENCY CHECK');

  DECLARE

   P_WV_UWI         VARCHAR2(20);
   P_WV_SOURCE      VARCHAR2(20);         
   P_WV_COUNTRY     VARCHAR2(20); 
   P_WV_ACTIVE_IND    VARCHAR2(1);           
   P_WV_WELLNAME     VARCHAR2(66);              
   P_WNV_NODEID     VARCHAR2(20);                  
   P_WNV_SOURCE      VARCHAR2(20);    
   P_WNV_COUNTRY      VARCHAR2(20);
   P_WNV_IPLUWI        VARCHAR2(20);

   CURSOR CURSOR_COUNTRY_CONSISTENCY_CHK
   IS

    SELECT WV.UWI, WV.SOURCE, WV.COUNTRY, WV.ACTIVE_IND, WV.WELL_NAME, WNV.NODE_ID, WNV.SOURCE, WNV.COUNTRY, WNV.IPL_UWI
    FROM  WELL_VERSION WV,  WELL_NODE_VERSION WNV
    WHERE WV.ACTIVE_IND = 'Y'
    AND WV.UWI = WNV.IPL_UWI
    AND WV.SOURCE = WNV.SOURCE
    AND WV.COUNTRY != WNV.COUNTRY;

BEGIN

   OPEN CURSOR_COUNTRY_CONSISTENCY_CHK;

   LOOP
      FETCH CURSOR_COUNTRY_CONSISTENCY_CHK
      INTO P_WV_UWI, P_WV_SOURCE, P_WV_COUNTRY, P_WV_ACTIVE_IND, P_WV_WELLNAME, P_WNV_NODEID, P_WNV_SOURCE, P_WNV_COUNTRY, P_WNV_IPLUWI;

      EXIT WHEN CURSOR_COUNTRY_CONSISTENCY_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.
      warning (
            'WIM_HOUSEKEEPING: COUNTRY INCONSISTENT FOR UWI ='
         || P_WV_UWI
         || ', SOURCE ='
         || P_WV_SOURCE
     || ', WITH COUNTRY IN WELL_VERSION ='
     || P_WV_COUNTRY
     || ', AND WITH COUNTRY IN WELL_NODE_VERSION ='
     || P_WNV_COUNTRY);

   END LOOP;

   CLOSE CURSOR_COUNTRY_CONSISTENCY_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : COUNTRY CONSISTENCY CHECK');

-- *****************************************************************************
  --  CHECK : Wells with Duplicate IPL_UWI_LOCAL Check
  --  WIM Housekeeping - Wells with Duplicate IPL_UWI_LOCAL Check (Task #1093)
  -- ***************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Wells with Duplicate IPL_UWI_LOCAL CHECK');

  DECLARE

   P_LOCAL_UWI    VARCHAR2(20);
   P_UWI        VARCHAR2(4000);
   P_COUNT    NUMBER;
   
   CURSOR CURSOR_DUP_LOCALUWI_CHK
   IS

        select ipl_uwi_local, uwi 
    from WV_DUP_LOCAL_UWI_VW;


BEGIN

   OPEN CURSOR_DUP_LOCALUWI_CHK;

    select count(*)
    INTO P_COUNT
    from WV_DUP_LOCAL_UWI_VW;

    ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL CHECK : Total number of duplicate IPL_UWI_LOCALs found = ' ||P_COUNT);

   LOOP
      FETCH CURSOR_DUP_LOCALUWI_CHK INTO P_LOCAL_UWI, P_UWI;

      EXIT WHEN CURSOR_DUP_LOCALUWI_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL =' || P_LOCAL_UWI
                                         || ', AND UWI IN =' || P_UWI);

   END LOOP;

   CLOSE CURSOR_DUP_LOCALUWI_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Wells with Duplicate IPL_UWI_LOCAL CHECK');

-- *****************************************************************************
  --  CHECK : Wells with Duplicate WELL_NUM Check
  --  WIM Housekeeping - Wells with Duplicate WELL_NUM Check
  -- ***************************************************************************
 ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Wells with Duplicate WELL_NUM CHECK');
  DECLARE

   P_WELL_NUM    VARCHAR2(20);
   P_UWI          VARCHAR2(4000);
   P_COUNT        NUMBER;
   
   CURSOR CURSOR_DUP_WELL_NUM_CHK
   IS

        select well_num, UWI
        from wv_dup_well_num_vw  ;


BEGIN

   OPEN CURSOR_DUP_WELL_NUM_CHK;

    select count(*)
    INTO P_COUNT
    from wv_dup_well_num_vw;
    
    IF p_count > 0 
    THEN
        ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: Wells with Duplicate WELL_NUM CHECK : Total number of duplicate WELL_NUMs found = ' ||P_COUNT);
    END IF;
    
   LOOP
      FETCH CURSOR_DUP_WELL_NUM_CHK INTO P_WELL_NUM, P_UWI;

      EXIT WHEN CURSOR_DUP_WELL_NUM_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: Wells with Duplicate WELL_NUM =' || P_WELL_NUM
                                         || ', AND UWI IN =' || P_UWI);

   END LOOP;

   CLOSE CURSOR_DUP_WELL_NUM_CHK;
   END;

   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Wells with Duplicate WELL_NUM CHECK');

-- *****************************************************************************
  --  CHECK : Wells with wrong coord system (NAD27) check
  --  WIM Housekeeping - Wells with wrong coord system (NAD27) Check (Task #1095)
  -- ***************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH WRONG COORD SYSTEM (NAD27) CHECK');  

  DECLARE
         
   P_WV_COUNTRY             VARCHAR2(20);              
   P_WNV_GEOG_COORD_SYSTEM_ID     VARCHAR2(20);                  
   P_WNV_IPL_UWI              VARCHAR2(20);    
   P_RC_LONG_NAME              VARCHAR2(60);
   

   CURSOR CURSOR_WRONG_NAD27_CHK
   IS

        SELECT WV.COUNTRY, WNV.GEOG_COORD_SYSTEM_ID, WNV.IPL_UWI, RC.LONG_NAME
    FROM PPDM.WELL_VERSION WV, PPDM.WELL_NODE_VERSION WNV, PPDM.R_COUNTRY RC
    WHERE WNV.NODE_ID IN (WV.BASE_NODE_ID, WV.SURFACE_NODE_ID)
    AND WV.ACTIVE_IND = 'Y'
    AND WNV.ACTIVE_IND = 'Y'
    AND WNV.GEOG_COORD_SYSTEM_ID in ('NAD27')
    AND WV.COUNTRY NOT IN ('2BA', '2CU', '2HA', '2DR', '2BE', '2HO', '2GU', '2NI', '2ES', '2BR',
               '2BM', '2SL', '2GE', '2KY', '2VI', '5UKAI', '2MT', '2NA', '2PR', '7US', 
               '7CN', '7SM', '2ME', '2CR', '2KN', '2AB', '2AG', '2TT', '2JA')
    AND WV.COUNTRY = RC.COUNTRY
    GROUP BY WV.COUNTRY, WNV.GEOG_COORD_SYSTEM_ID, WNV.IPL_UWI, RC.COUNTRY, RC.LONG_NAME;

BEGIN

   OPEN CURSOR_WRONG_NAD27_CHK;

   LOOP
      FETCH CURSOR_WRONG_NAD27_CHK INTO P_WV_COUNTRY, P_WNV_GEOG_COORD_SYSTEM_ID, P_WNV_IPL_UWI, P_RC_LONG_NAME;

      EXIT WHEN CURSOR_WRONG_NAD27_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: WELLS WITH WRONG COORD SYSTEM (NAD27) FOR TLMID ='|| P_WNV_IPL_UWI
                     || ', AND COUNTRY IN  ='|| P_RC_LONG_NAME 
                     || '('|| P_WV_COUNTRY ||')');

   END LOOP;

   CLOSE CURSOR_WRONG_NAD27_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WELLS WITH WRONG COORD SYSTEM (NAD27) CHECK'); 


-- *****************************************************************************
  --  CHECK : Wells with wrong coord system (NAD83) check
  --  WIM Housekeeping - Wells with wrong coord system (NAD83) Check (Task #1095)
  -- ***************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH WRONG COORD SYSTEM (NAD83) CHECK');  

  DECLARE
         
   P_WV_COUNTRY             VARCHAR2(20);              
   P_WNV_GEOG_COORD_SYSTEM_ID     VARCHAR2(20);                  
   P_WNV_IPL_UWI              VARCHAR2(20);    
   P_RC_LONG_NAME              VARCHAR2(60);
   

   CURSOR CURSOR_WRONG_NAD83_CHK
   IS

        SELECT WV.COUNTRY, WNV.GEOG_COORD_SYSTEM_ID, WNV.IPL_UWI, RC.LONG_NAME
    FROM PPDM.WELL_VERSION WV, PPDM.WELL_NODE_VERSION WNV, PPDM.R_COUNTRY RC
    WHERE WNV.NODE_ID IN (WV.BASE_NODE_ID, WV.SURFACE_NODE_ID)
    AND WV.ACTIVE_IND = 'Y'
    AND WNV.ACTIVE_IND = 'Y'
    AND WNV.GEOG_COORD_SYSTEM_ID in ('NAD83')
    AND WV.COUNTRY NOT IN ('2BA', '2CU', '2HA', '2DR', '2BE', '2BM', '2KY', '2VI', '5UKAI', '2NA',
               '2PR', '7US', '7CN', '7SM', '2KN', '2AG', '2JA')
    AND WV.COUNTRY = RC.COUNTRY
    GROUP BY WV.COUNTRY, WNV.GEOG_COORD_SYSTEM_ID, WNV.IPL_UWI, RC.LONG_NAME;

BEGIN

   OPEN CURSOR_WRONG_NAD83_CHK;

   LOOP
      FETCH CURSOR_WRONG_NAD83_CHK INTO P_WV_COUNTRY, P_WNV_GEOG_COORD_SYSTEM_ID, P_WNV_IPL_UWI, P_RC_LONG_NAME;

      EXIT WHEN CURSOR_WRONG_NAD83_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: WELLS WITH WRONG COORD SYSTEM (NAD83) FOR TLMID ='|| P_WNV_IPL_UWI
                     || ', AND COUNTRY IN  ='|| P_RC_LONG_NAME 
                     || ' ('|| P_WV_COUNTRY ||')');

   END LOOP;

   CLOSE CURSOR_WRONG_NAD83_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WELLS WITH WRONG COORD SYSTEM (NAD83) CHECK');  

-- *****************************************************************************
  --  CHECK : WIM Inconsistent node and well active indicators Check
  --  WIM Housekeeping - WIM Inconsistent node and well active indicators Check (Task #1096)
  -- ***************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WIM INCONSISTENT NODE AND WELL ACTIVE INDICATORS CHECK');

  DECLARE

   P_WV_UWI         VARCHAR2(20);
   P_WV_SOURCE      VARCHAR2(20);           
   
   CURSOR CURSOR_NODE_INCONSISTENCY_CHK
   IS

        SELECT A.UWI, A.SOURCE
    FROM PPDM.WELL_VERSION A, PPDM.WELL_NODE_VERSION B
    WHERE A.UWI = B.IPL_UWI
    AND A.SOURCE = B.SOURCE
    AND A.ACTIVE_IND = 'N'
    AND B.ACTIVE_IND = 'Y'
    GROUP BY A.UWI, A.SOURCE;

BEGIN

   OPEN CURSOR_NODE_INCONSISTENCY_CHK;

   LOOP
      FETCH CURSOR_NODE_INCONSISTENCY_CHK INTO P_WV_UWI, P_WV_SOURCE;

      EXIT WHEN CURSOR_NODE_INCONSISTENCY_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NODE ACTIVE INDICATOR INCONSISTENT FOR UWI ='|| P_WV_UWI || ', SOURCE =' || P_WV_SOURCE);

   END LOOP;

   CLOSE CURSOR_NODE_INCONSISTENCY_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WIM INCONSISTENT NODE AND WELL ACTIVE INDICATORS CHECK');
 

  -- ************************************************************************************************************************************
  --  CHECK : Undefined geog_coordinate_system_id Check
  --  WIM Housekeeping - check to look for wells (nodes) with an undefined geog_coordinate_system_id i.e is set to "0000" (Task #1199)
  -- ************************************************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : UNDEFINED GEOG_COORDINATE_SYSTEM_ID CHECK');

  DECLARE

   P_IPL_UWI            VARCHAR2(20);
   P_SOURCE             VARCHAR2(20);
   P_GEOG_COORD_SYSTEM_ID         VARCHAR2(20);
   
   CURSOR CURSOR_UNDEFINED_COORD_CHK
   IS

        SELECT IPL_UWI, SOURCE, GEOG_COORD_SYSTEM_ID
    FROM PPDM.WELL_NODE_VERSION
    WHERE GEOG_COORD_SYSTEM_ID = '0000'
    GROUP BY IPL_UWI, SOURCE, GEOG_COORD_SYSTEM_ID;

BEGIN

   OPEN CURSOR_UNDEFINED_COORD_CHK;

   LOOP
      FETCH CURSOR_UNDEFINED_COORD_CHK INTO P_IPL_UWI, P_SOURCE, P_GEOG_COORD_SYSTEM_ID;

      EXIT WHEN CURSOR_UNDEFINED_COORD_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: UNDEFINED GEOG_COORDINATE_SYSTEM_ID = '|| P_GEOG_COORD_SYSTEM_ID || ',' 
                                                      || ' UWI = ' || P_IPL_UWI || ',' 
                                                      || ' SOURCE = ' || P_SOURCE);


   END LOOP;

   CLOSE CURSOR_UNDEFINED_COORD_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : UNDEFINED GEOG_COORDINATE_SYSTEM_ID CHECK');


-- *************************************************************************************************
  --  CHECK : Node Versions with no country check
  --  WIM Housekeeping - Node Versions with no country Check (Task #1200)
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : NODE VERSIONS WITH NO COUNTRY CHECK');  

  DECLARE
                          
   P_WNV_IPL_UWI    VARCHAR2(20);    

   CURSOR CURSOR_NODE_NO_COUNTRY_CHK
   IS

        SELECT IPL_UWI 
    FROM PPDM.WELL_NODE_VERSION 
    WHERE COUNTRY IS NULL 
    GROUP BY IPL_UWI;

BEGIN

   OPEN CURSOR_NODE_NO_COUNTRY_CHK;

   LOOP
      FETCH CURSOR_NODE_NO_COUNTRY_CHK INTO P_WNV_IPL_UWI;

      EXIT WHEN CURSOR_NODE_NO_COUNTRY_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NODE VERSIONS WITH NO COUNTRY FOR TLMID ='|| P_WNV_IPL_UWI );

   END LOOP;

   CLOSE CURSOR_NODE_NO_COUNTRY_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : NODE VERSIONS WITH NO COUNTRY CHECK'); 


-- *************************************************************************************************
  --  CHECK : Node Versions with no node position check
  --  WIM Housekeeping - Node Versions with no node position Check (Task #1200)
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : NODE VERSIONS WITH NO NODE POSITION CHECK');  

  DECLARE
                          
   P_WNV_IPL_UWI    VARCHAR2(20);    

   CURSOR CURSOR_NODE_NO_N_POSITION_CHK
   IS

        SELECT IPL_UWI 
    FROM PPDM.WELL_NODE_VERSION 
    WHERE NODE_POSITION IS NULL 
    GROUP BY IPL_UWI;

BEGIN

   OPEN CURSOR_NODE_NO_N_POSITION_CHK;

   LOOP
      FETCH CURSOR_NODE_NO_N_POSITION_CHK INTO P_WNV_IPL_UWI;

      EXIT WHEN CURSOR_NODE_NO_N_POSITION_CHK%NOTFOUND;

      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NODE VERSIONS WITH NO NODE_POSITION FOR TLMID ='|| P_WNV_IPL_UWI );

   END LOOP;

   CLOSE CURSOR_NODE_NO_N_POSITION_CHK;
   END;


   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : NODE VERSIONS WITH NO NODE POSITION CHECK'); 

-- *************************************************************************************************
  --  CHECK : Wells with No Well_Name
  --  WIM Housekeeping - Well with no well_name
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH NO WELL NAME CHECK');  
DECLARE
v_count     NUMBER;
BEGIN
    SELECT COUNT(1) into v_count
      FROM WELL
     WHERE ACTIVE_IND ='Y'
       AND WELL_NAME IS NULL;
      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NUMBER OF WELLS WITH NO WELL_NAME = '|| v_count );
  
END;

ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WELLS WITH NO WELL NAME CHECK');  
-- *************************************************************************************************
  --  CHECK : Wells with only Override version Left
  --  WIM Housekeeping - Check is there any wells with only Override version Left
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH ONLY OVERRIDE VERSION CHECK');  
DECLARE
v_count     NUMBER;
BEGIN
    SELECT COUNT(1) into v_count
      from well_Version
     where source = '075TLMO'
       and active_ind = 'Y' --and remark is null
       and uwi not in ( select uwi from well_Version
                         where source <> '075TLMO' and active_ind ='Y');
     
    
      ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NUMBER OF WELLS WITH ONLY OVERRIDE VERSION = '|| v_count );
  
END;

ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WELLS WITH ONLY OVERRIDE VERSION CHECK');  

-- *************************************************************************************************
  --  CHECK : Wells with INvalid Node IDs
  --  WIM Housekeeping - Check is there any wells there Base_Node_Id or Surface_Node_Id dont follow the standard
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH INVALID NODE IDs CHECK');  
DECLARE
v_count     NUMBER;
BEGIN
      FOR rec in (select * from ppdm.well_version where active_ind = 'Y' and uwi || '0' != base_node_id)
      LOOP
        ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: WELL VERSION WITH INVALID BASE NODE ID ='|| REC.UWI || '( ' || REC.SOURCE || ' )' );
      
      END LOOP;
      
      FOR rec in (select * from ppdm.well_version where active_ind = 'Y' and uwi || '1' != surface_node_id)
      LOOP
        ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: WELL VERSION WITH INVALID SURFACE NODE ID ='|| REC.UWI || '( ' || REC.SOURCE || ' )' );      
      END LOOP;
   
  
END;

-- *************************************************************************************************
  --  CHECK : Wells with Invalid Country codes
  --  WIM Housekeeping - Check is there any wells where country is not valid
  -- *************************************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : WELLS WITH NON-STANDARD COUNTRY CODES CHECK');  
DECLARE
v_count     NUMBER;
BEGIN
      
      select count(1) into v_count 
        from well_version
        where country not in ( select country from ppdm.r_country where active_ind ='Y' and source <> 'DM');
        
        ppdm_admin.tlm_process_logger.warning ('WIM_HOUSEKEEPING: NUMBER OF WELLS WITH NON-STANDARD COUNTRY CODES = '|| v_count );
       
  
END;
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : WELLS WITH NON-STANDARD COUNTRY CODES CHECK');  


--********************************************************************************
--Check:  Execute BlackList Wells
--Wim Housekeeping - runs a process to inactivate wells are in Blacklist_wells tables.
--These are the wells that we dont need in our WIM database, but IHS hasn't removed them
-- from their database.
--*********************************************************************************
ppdm.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : Black List Wells Check');

BEGIN
    wim_loader.WIM_LOADER.BLACKLIST_WELLS(NULL);
END;

ppdm.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : Black List Wells Check');



--********************************************************************************
--Check: Check if there are wells in WIM which are NOT in DM
--Wim Housekeeping - gets a count of records from view WIM.WIM_DM_MISSING_WELLS_MV
--Log an error if count is greater than zero.
--If there are wells missing, then need to trigger some kind of update to the wells
--  in order for the well to be detected by the WIM-DM interface view
--Ideally, the count will be zero.  Users can run the view to see a list of wells.  
--*********************************************************************************
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : CHECK FOR WIM WELLS THAT ARE NOT IN DM');  
DECLARE
v_count     NUMBER;
BEGIN
      
      SELECT COUNT(1) INTO v_count 
      FROM WIM.WIM_DM_MISSING_WELLS_VW;
      
      IF v_count > 0 THEN
          PPDM_ADMIN.TLM_PROCESS_LOGGER.ERROR ('WIM_HOUSEKEEPING: NUMBER OF WELLS NOT IN DM = '|| V_COUNT );
      ELSE
          PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO ('WIM_HOUSEKEEPING: ALL WIM WELLS IN DM');
      END IF;
  
END;
  
ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : CHECK FOR WIM WELLS THAT ARE NOT IN DM');



 /* 
-- *****************************************************************************
  --  CHECK : Null Surface Node Ids for 300IPL wells 
  --  WIM Housekeeping - Checks and updates Null Surface Node Ids ( only if
-- surface and base nodes are the same in source)
  -- ***************************************************************************
  
   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: START : 300IPL Surface Node Ids CHECK');
   
   BEGIN
        WIM.UPDATE_300IPL_SUR_NODE_ID; 
   END;
   ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END : 300IPL Surface Node Ids CHECK');
*/
  -- *****************************************************************************
  -- Log the end of housekeeping
  ppdm_admin.tlm_process_logger.info ('WIM_HOUSEKEEPING: END Housekeeping');


END;
/
