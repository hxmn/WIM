--------------------------------------------------------
--  File created - Thursday-August-13-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body WIM_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "WIM"."WIM_SEARCH" 
IS
-- SCRIPT: WIM.WIM_Search.pkb
--
-- PURPOSE:
--   Package body for the WIM Search functionality
--
-- DEPENDENCIES
--   See Package Specification
--
-- EXECUTION:
--   See Package Specification
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   0.1    08-Apr-10   R.Masterman    Initial version
--   0.2    01-May-10   S.Makarov       Extended Find well functionality
--   0.3    03-Feb-12   V.Rajpoot       Changed Fill_Temp_Table, changed LAt/Longs' digit from 3 to 5
--   0.4    01-Mar-12   V.Rajpoot       Modified Find_WEll_Ext_300 procedure .
--   0.5    23-Mar-12   V.Rajpoot       Modified Find_Well_Ext_300, Find_Well_Ext_450
--                                      in the second check, It checks if there is a match by IPL_UWI_LOCAL in other sources
--                                      if it finds a match, 
--                                      Added a another criteria to exclude if the well found already has the source version
--                                      Modified Fill_temp_table to exlcude any matches where same source version exists.
--  1.1.0    21-June-12   V.Rajpoot      
--                                      Changed Find_Well_By_Alias - Filtered out the Inactive aliases.
--                                      Modified Find_Well_Extended and Find_well: Passed new parameter "pfindbyalias_fg"
--                                      only find by alias if pfindbyalias_fg = 'Y'
--                  
--                                      Modified 100TLM search: If the well matched with other well versions, then Add a warning  
--                                      message to wim_audit_log.

--  2.0.0    12-Jul-12     V.Rajpoot    Generic Find_Well that returns multiple matches. To be used by Wim_Loader, iWim, DataFinder and ....
--  2.0.1    29-Jan-2013   V.Rajpoot    Added  PRAGMA AUTONOMOUS_TRANSACTION to Find_WElls 
  
 /*----------------------------------------------------------------------------------------------------------
Function:  Version
Detail:    This Function Returns package version number
            
Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION Version
 RETURN VARCHAR2
 IS

 -- Format: nn.mm.ll (kk)
 -- nn - Major version (Numeric)
 -- mm - Functional change (Numeric)
 -- ll - Bug fix revision (Numeric)
 -- k - Optional - Test version (letters) 
 
 BEGIN
 RETURN '2.0.0';
 END Version; 
 
 /*----------------------------------------------------------------------------------------------------------
Function:  FIND_BY_ALIAS
Detail:    This Function find wells using well_alias table. and inserts results to WIM_FIND_WELL table.
            
Called By:  FIND_WELLS
Calls:      

Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION find_by_Alias(
      p_alias            IN   WELL_ALIAS.WELL_ALIAS%TYPE,
      p_alias_type       IN   VARCHAR2,
      p_source           IN   WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      p_effective_date   IN   DATE DEFAULT NULL
   ) RETURN VARCHAR2
 IS
  
 v_operator VARCHAR2(10);
 v_sql VARCHAR2(2000);
 v_insertsql VARCHAR2(2000);
 v_where VARCHAR2(2000);
 v_remark VARCHAR2(30);
 v_TLMID  well_version.uwi%type;
 v_num number; 
 BEGIN
 
   
    v_remark := 'Alias Match By ' || p_alias_type;
 
    IF p_alias_type = 'WELL_NUM'
    then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID,WELL_NUM,  SOURCE, MATCH_TYPE,REMARK) ';
        v_sql := 'SELECT  uwi,well_alias, ';
    elsif p_alias_type = 'TLM_ID' then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID,SOURCE, MATCH_TYPE, REMARK) ';
        v_sql := 'SELECT  uwi, ';                           
    elsif p_alias_type = 'UWI' then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID, UWI,  SOURCE, MATCH_TYPE, REMARK) ';
        v_sql := 'SELECT  uwi,well_alias, ';
    elsif p_alias_type = 'WELL_NAME' then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID, WELL_NAME, SOURCE,MATCH_TYPE, REMARK) ';
        v_sql := 'SELECT  uwi,well_alias, ';
    elsif p_alias_type = 'PLOT_NAME' then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID,PLOT_NAME, SOURCE, MATCH_TYPE,REMARK) ';
        v_sql := 'SELECT  uwi,well_alias, ';
    elsif p_alias_type = 'COUNTRY' then
        v_insertsql := 'INSERT INTO WIM_FIND_WELL (TLM_ID,COUNTRY, SOURCE, MATCH_TYPE,REMARK) ';
        v_sql := 'SELECT  uwi,well_alias, ';
 
    end if;
    
    v_sql := v_sql ||
        ' SOURCE, ' || '''A''' || ',' ||'''' || v_remark || '''' ||
        ' FROM WELL_ALIAS ';
    
    v_where := ' WHERE  ACTIVE_IND = ''Y'' ';
    v_where := v_where ||  ' AND ALIAS_TYPE = ' || '''' || p_alias_type || '''' ;
    
    if p_source is not null then
        v_where := v_where || ' AND SOURCE = ' || '''' || p_source|| '''' ;
    end if;
    
             
    IF instr(p_alias, '%') > 0  -- If there is wildcard used
    THEN
        v_operator := ' LIKE ';       
    ELSE 
        v_operator := '=';
    END IF;
      
    IF p_alias_type = 'WELL_NAME' AND v_operator = '=' ---- Use compressed_well_name function for WELL_NAME Alias
    THEN
      v_where := v_where || ' AND wim_util.compress_well_name(WELL_ALIAS) ' || v_operator || 'wim_util.compress_well_name(' || '''' || p_alias || '''' || ') ';
    ELSE
       v_where := v_where || ' AND upper(REPLACE(WELL_ALIAS, chr(39),' || '''' || '''' || ')) ' || v_operator || 'UPPER(' || '''' || p_alias || '''' || ')';
    END IF;
    
    
  --dbms_output.put_line('ALIAS SEARCH ' || v_insertsql || v_Sql || v_where);
 
     EXECUTE IMMEDIATE v_insertsql || v_Sql || v_where;
     EXECUTE IMMEDIATE 'COMMIT';
 
     select count(distinct TLM_ID) into V_num
      from wim_find_well;
      
      
      IF v_Num = 1 then -- single match found, Return it
              
        Select distinct TLM_ID into v_TLMID
          from wim_find_well;
        
         -- If we are looking for a specific version and found it via aliases  let's make sure it exists
          IF p_source IS NOT NULL AND v_TLMID IS NOT NULL
          THEN
             SELECT COUNT (1)
               INTO v_Num
               FROM well_version
              WHERE uwi = v_TLMID AND SOURCE = p_source;

             IF v_Num = 0
             THEN
                v_TLMID := NULL;
             END IF;
          END IF;

      end if;
       
      RETURN  v_TLMID; 
      
     EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   
 END;
 
 /*----------------------------------------------------------------------------------------------------------
Function:  FIND_WELL
Detail:    This function returns the TLM_ID of a well based on the provided parameters
                                (WELL_NUM, TLM_ID, IPL_UWI_LOCAL, WELL_NAME,PLOT_NAME)
            
Called By:  WIM_GATEWAY
Calls:      FIND_WELLS

Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION find_well (
      palias            well_alias.well_alias%TYPE,
      pfind_type        WELL_ALIAS.ALIAS_TYPE%TYPE  DEFAULT 'TLM_ID',
      psource           well_version.SOURCE%TYPE    DEFAULT NULL,
      pfindbyalias_fg   VARCHAR2                    DEFAULT 'A'      
   )
      RETURN VARCHAR2
   IS
      vtlm_id     well_version.uwi%TYPE    := NULL;
      vcount      NUMBER;
      vaudit_id   NUMBER                   := NULL;
      vnumwells_matched NUMBER := 0;  
          
   BEGIN
      
      
      
      IF pfind_type = 'TLM_ID'
      THEN
          vtlm_id := palias;
          vnumwells_matched := find_wells ( ptlm_id           => vtlm_id,
                                            psource           => psource,                                                                                 
                                            pfindbyalias_fg   => pfindbyalias_fg);
          if vnumwells_matched = 0 
          THEN
            vtlm_id :=NULL;
          END IF;                        
      ELSIF pfind_type =  'WELL_NUM'
      THEN
           vnumwells_matched := find_wells ( ptlm_id           => vtlm_Id,
                                             pwell_num         => palias,
                                             psource           => psource,
                                             pfindbyalias_fg   => pfindbyalias_fg);
                                                
                
       ELSIF pfind_type =  'WELL_NAME'
       THEN
           vnumwells_matched := find_wells ( ptlm_id           => vtlm_Id,
                                             pwell_name        => palias,
                                             psource           => psource,
                                             pfindbyalias_fg   => pfindbyalias_fg);   
                          
       ELSIF pfind_type =  'UWI'
       THEN
           vnumwells_matched := find_wells ( ptlm_id           => vtlm_Id,
                                             puwi              => palias,
                                             psource           => psource,
                                             pfindbyalias_fg   => pfindbyalias_fg);     
              
       ELSIF pfind_type =  'PLOT_NAME'
       THEN
           vnumwells_matched := find_wells ( ptlm_id           => vtlm_Id,
                                             pplot_name        => palias,
                                             psource           => psource,
                                             pfindbyalias_fg   => pfindbyalias_fg);     
          
       ELSE
            -- An invalid FIND_WELL option was used
            wim_audit.audit_event
               (paudit_id        => vaudit_id,
                paction          => 'F',
                paudit_type      => 'E',
                pattribute       => 'N/A',
                ptlm_id          => palias,
                psource          => psource,
                ptext            =>    'Find Well called with an invalid pFind_type of '
                                    || pfind_type,
                puser            => USER
               );
      END IF;
     
      RETURN vtlm_id;
      
   END find_well;

  
 /*----------------------------------------------------------------------------------------------------------
Function:  BUILD_REMARK
Detail:    This Function build dynamic sql  for Remark field to show what is it matched by, specially when
            doing Wide Search. 
          

Called By:  BUILD_SQL
Calls:      

Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION Build_Remark (
      ptlm_id                  WELL_VERSION.UWI%TYPE,
      pcountry                 WELL_VERSION.COUNTRY%TYPE,
      pwell_num                WELL_VERSION.WELL_NUM%TYPE,
      puwi                     WELL_VERSION.IPL_UWI_LOCAL%TYPE,
      pwell_name               WELL_VERSION.WELL_NAME%TYPE,
      pspud_date               WELL_VERSION.SPUD_DATE%TYPE,
      prig_release_date        WELL_VERSION.RIG_RELEASE_DATE%TYPE,
      pkb_elev                 WELL_VERSION.KB_ELEV%TYPE,
      pdrill_td                WELL_VERSION.DRILL_TD%TYPE,
      pbottom_hole_latitude    WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE,
      pbottom_hole_longitude   WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE,
      psurface_latitude        WELL_VERSION.SURFACE_LATITUDE%TYPE,
      psurface_longitude       WELL_VERSION.SURFACE_LONGITUDE%TYPE,
      pplot_name               WELL_VERSION.PLOT_NAME%TYPE,
      plicense_num             WELL_LICENSE.LICENSE_NUM%TYPE,
      psource                  WELL_VERSION.SOURCE%TYPE,      
      pwide_search_fg          VARCHAR2,
      pfindbyalias_fg          VARCHAR2,
      ptolerance               NUMBER,
      pelevtolerance           NUMBER    
   )
      RETURN VARCHAR2
   IS
   
      v_Remark          VARCHAR2(2000);
      v_operator        VARCHAR2(10);
      v_match_operator  VARCHAR2(10);
     
   BEGIN
          
        --Build Remark attribute
        If pwide_search_fg = 'N' THEN
            v_Remark := '''Matched in ''' || ' || w.source || ' || ''' source ''';            
        else  
             v_Remark := '''Wide Search Matched By: ''' ;
             
             IF puwi is not null then     
                v_Remark := v_Remark || ' || CASE ' ||' WHEN w.IPL_UWI_LOCAL = ' || '''' || puwi || '''' || ' THEN ' || '''IPL_UWI_LOCAL, ''' || ' END ';
             END IF;
             
             IF ptlm_id is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN w.UWI = ' || '''' || ptlm_id || '''' || ' THEN ' || '''UWI, ''' || ' END ';
             END IF;
             
             IF pkb_elev is not null then                
                 v_Remark := v_Remark || ' || CASE ' || ' WHEN w.kb_elev =  ' || pkb_elev || ' THEN ' || '''KB_ELEV, ''' || ' END ';         
             END IF;
             
             IF pcountry is not null then         
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN w.COUNTRY = ' || '''' || pcountry || '''' || ' THEN ' || '''COUNTRY, ''' || ' END '; 
             END IF;
             
             IF pwell_num is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN w.WELL_NUM = ' || '''' || pwell_num || '''' || ' THEN ' || '''WELL_NUM, ''' || ' END ';
             END IF;
             
             IF pspud_date is not null then      
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(w.SPUD_DATE) = ' || 'trunc(to_date( ' || '''' ||  pspud_date || '''' || ')) THEN ' || '''SPUD_DATE, ''' || ' END ';
             END IF;
              
             If prig_release_date is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(to_date(w.RIG_RELEASE_DATE)) = ' || 'trunc(to_date( ' || '''' ||  prig_release_date || '''' || ')) THEN ' || '''RIG_RELEASE_DATE, ''' || ' END ';
             end if;
             
             IF pdrill_td is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(w.DRILL_TD) = ' ||  'TRUNC(' || pdrill_Td || ')'||  ' THEN ' || '''DRILL_TD, ''' || ' END ';
             END IF;
              
             IF pbottom_hole_latitude is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(w.BOTTOM_HOLE_LATITUDE, ' || ptolerance || ')'  || ' = ' ||  'TRUNC(' || pbottom_hole_latitude || ',' || ptolerance || ')' || ' THEN ' || '''BOTTOM_HOLE_LATITUDE, ''' || ' END ';             
            
             END IF;
             
             IF  pbottom_hole_longitude is not null then
                  v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(w.BOTTOM_HOLE_LONGITUDE, ' || ptolerance || ')'  || ' = ' ||  'TRUNC(' || pbottom_hole_longitude || ',' || ptolerance || ')' || ' THEN ' || '''BOTTOM_HOLE_LONGITUDE, ''' || ' END ';
             END IF;
             
             IF psurface_longitude is not null then
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc(w.SURFACE_LONGITUDE, ' || ptolerance || ')'  || ' = ' ||  'TRUNC(' || psurface_longitude || ',' || ptolerance || ')' || ' THEN ' || '''SURFACE_LONGITUDE, ''' || ' END ';
             END IF;
             
             IF psurface_latitude is not null then     
                     v_Remark := v_Remark || ' || CASE ' ||' WHEN trunc( w.SURFACE_LATITUDE, ' || ptolerance || ')' || ' = ' ||  'TRUNC(' || psurface_latitude || ',' || ptolerance || ')' || ' THEN ' || '''SURFACE_LATITUDE, ''' || ' END ';
             END IF;    
                 
              --For well_name and Plot_name, update remark later
             if pwell_name is not null then
                if instr(pwell_name, '%') > 0 then         
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN UPPER(w.WELL_NAME) LIKE ' || 'UPPER(' || '''' || pwell_name || '''' || ')' || ' THEN ' || '''WELL_NAME, ''' || ' END ';         
                else
                 v_Remark := v_Remark || ' || CASE ' ||' WHEN wim_util.compress_well_name(w.WELL_NAME) = ' ||  'WIM_UTIL.COMPRESS_WELL_NAME(' || '''' || pwell_name || '''' || ')' || ' THEN ' || '''WELL_NAME, ''' || ' END ';            
                end if;  
             end if;    
                 
             If pplot_name is not null then
                if instr(pplot_name, '%') > 0 then           
                   v_Remark := v_Remark || ' || CASE ' ||' WHEN UPPER(w.PLOT_NAME) LIKE ' || 'UPPER(' || '''' || pplot_name || '''' || ')' || ' THEN ' || '''PLOT_NAME, ''' || ' END ';
                else
                   v_Remark := v_Remark || ' || CASE ' ||' WHEN UPPER(w.PLOT_NAME) = ' || 'UPPER(' || '''' || pplot_name || '''' || ')' || ' THEN ' || '''PLOT_NAME, ''' || ' END ';
                end if;  
             end if;   
             if plicense_num is not null then
                   v_Remark := v_Remark || ' || CASE ' ||' WHEN WL.LICENSE_NUM = ' || '''' || plicense_num || '''' || ' THEN ' || '''LICENSE_NUM, ''' || ' END ';
             end if;
             
            v_Remark := v_Remark || ' ||' || '''in ''' || ' || w.source || ' || ''' source ''' || ' Remark';
        
        end if; 
        
              RETURN v_Remark;

   END Build_Remark;


 /*----------------------------------------------------------------------------------------------------------
Function:  BUILD_FROM_SQL
Detail:    This Function builds part of sql  (From)
            Depending on source and findbyalias flag, it determins which table to read from Well_Version or Well
          

Called By:  BUILD_SQL
Calls:      

Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 
FUNCTION build_FROM_SQL (
        pfindbyalias_fg         VARCHAR2, 
        psource                 WELL_VERSION.SOURCE%TYPE)
        
RETURN VARCHAR2

IS

    v_sql VARCHAR2(2000);
BEGIN

  IF pfindbyalias_fg = 'W' --Use Well Table
    THEN
      v_sql := ' ( select UWI,  PRIMARY_SOURCE as SOURCE, ACTIVE_IND, BOTTOM_HOLE_LATITUDE,  BOTTOM_HOLE_LONGITUDE,  COUNTRY, ' ||
              ' DRILL_TD,  KB_ELEV,  PLOT_NAME,  RIG_RELEASE_DATE,  SPUD_DATE,  SURFACE_LATITUDE, ' ||
              ' SURFACE_LONGITUDE,  WELL_NAME,  WELL_NUM,  IPL_UWI_LOCAL from well ) w ';
    ELSE -- User well_version table
      v_sql := '(select UWI,  SOURCE, ACTIVE_IND, BOTTOM_HOLE_LATITUDE,  BOTTOM_HOLE_LONGITUDE,  COUNTRY, ' ||
              ' DRILL_TD,  KB_ELEV,  PLOT_NAME,  RIG_RELEASE_DATE,  SPUD_DATE,  SURFACE_LATITUDE, ' ||
              ' SURFACE_LONGITUDE,  WELL_NAME,  WELL_NUM,  IPL_UWI_LOCAL from well_Version ) w ';
        
    END IF;


    RETURN 'FROM ' || v_sql;
    
END;
/*----------------------------------------------------------------------------------------------------------
Function:  BUILD_SQL
Detail:    This Function build dynamic sql from parameters provided. 
           This function calls by FIND_WELLS      

Called By:  FIND_WELLS
Calls:      

Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION Build_SQL (
      ptlm_id                  WELL_VERSION.UWI%TYPE ,
      pcountry                 WELL_VERSION.COUNTRY%TYPE,
      pwell_num                WELL_VERSION.WELL_NUM%TYPE,
      puwi                     WELL_VERSION.IPL_UWI_LOCAL%TYPE,
      pwell_name               WELL_VERSION.WELL_NAME%TYPE,
      pspud_date               WELL_VERSION.SPUD_DATE%TYPE,
      prig_release_date        WELL_VERSION.RIG_RELEASE_DATE%TYPE,
      pkb_elev                 WELL_VERSION.KB_ELEV%TYPE,
      pdrill_td                WELL_VERSION.DRILL_TD%TYPE,
      pbottom_hole_latitude    WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE,
      pbottom_hole_longitude   WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE,
      psurface_latitude        WELL_VERSION.SURFACE_LATITUDE%TYPE,
      psurface_longitude       WELL_VERSION.SURFACE_LONGITUDE%TYPE,
      pgeog_coord_system_id    WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE,   
      pplot_name               WELL_VERSION.PLOT_NAME%TYPE,
      plicense_num             WELL_LICENSE.LICENSE_NUM%TYPE,
      psource                  WELL_VERSION.SOURCE%TYPE,      
      pwide_search_fg          VARCHAR2,
      pfindbyalias_fg          VARCHAR2,
      ptolerance               NUMBER,  
      pelevtolerance           NUMBER   
   )
      RETURN VARCHAR2
   IS
      v_selectsql       VARCHAR2(2000);
      v_fromsql         VARCHAR2(2000);
      v_wheresql        VARCHAR2(2000);
      v_insertinto_sql  VARCHAR2(2000);
      v_Remark          VARCHAR2(2000);
      v_NodeMatchtbl    VARCHAR2(200);
      v_operator        VARCHAR2(10);
      v_match_operator  VARCHAR2(10);
      v_match_type      VARCHAR2(10);
      v_well_name       well_version.well_name%TYPE;
      v_continue_fg     VARCHAR2(1);      
      v_elev_From       well_version.kb_elev%TYPE;
      v_elev_To         well_version.kb_elev%TYPE;
     
   BEGIN
     
        v_continue_fg := 'Y';
      
        if pwide_search_fg = 'Y' THEN
           v_match_type := '''W''';  --Wide search match
        else        
           v_match_type := '''E''';  -- Exact Match
        END IF;
        
                 
         --Build Remark attribute
            v_Remark := BUILD_REMARK(
                        ptlm_id                 => ptlm_id,
                        pcountry                => pcountry,
                        pwell_num               => pwell_num,
                        puwi                    => puwi,
                        pwell_name              => pwell_name, 
                        pspud_date              => pspud_date,
                        prig_release_date       => prig_release_date,
                        pkb_elev                => pkb_elev,
                        pdrill_td               => pdrill_td,
                        pbottom_hole_latitude   => pbottom_hole_latitude,
                        pbottom_hole_longitude  => pbottom_hole_longitude,
                        psurface_latitude       => psurface_latitude,
                        psurface_longitude      => psurface_longitude,
                        pplot_name              => pplot_name,
                        plicense_num            => plicense_num,
                        psource                 => psource,      
                        pwide_search_fg         => pwide_search_fg,
                        pfindbyalias_fg         => pfindbyalias_fg,
                        ptolerance              => ptolerance,
                        pelevtolerance          => pelevtolerance );
       
       
     
       
        v_fromsql := build_FROM_SQL (pfindbyalias_fg,psource);
       
        IF pfindbyalias_fg = 'W' 
        THEN
           v_NodeMatchtbl := 'Well_Node'; 
        ELSE
            v_NodeMatchtbl := 'Well_Node_Version'; 
        END IF;
        
      v_selectsql :=  'SELECT w.uwi, w.source, w.well_name, w.plot_name, w.surface_latitude, ' ||
                      ' w.surface_longitude, w.bottom_hole_latitude, ' ||
                      ' w.bottom_hole_longitude, w.rig_release_date, w.spud_date, ' ||
                      ' w.kb_elev, w.drill_td, w.well_num, w.country, w.ipl_uwi_local,  ' || '' || v_match_type || ''; 
        
         v_selectsql := v_selectsql || ', ' || v_Remark;
        v_wheresql := 'WHERE w.active_ind = ''Y''';
  
      
  
        v_insertinto_sql :=  'INSERT INTO wim_find_well ' ||
                            ' (tlm_id, SOURCE, well_name, plot_name, surface_latitude, ' ||
                            ' surface_longitude, bottom_hole_latitude,' ||
                            ' bottom_hole_longitude, rig_release_date, spud_date, ' ||
                            ' kb_elev, drill_td, well_num, country, uwi, match_type, remark,license_num)  ' ;       
 
       -- Check if all the parameters are null , then dont do anything
      IF ptlm_id                is null AND
             pcountry               is null AND
             pwell_num              is null AND
             puwi                   is null AND
             pwell_name             is null AND
             pspud_date             is null AND
             prig_release_date      is null AND
             pkb_elev               is null AND
             pdrill_td              is null AND
             pbottom_hole_latitude  is null AND
             pbottom_hole_longitude is null AND
             psurface_latitude      is null AND
             psurface_longitude     is null AND
             pplot_name             is null AND
             plicense_num           is null AND
             psource                is null 
        THEN         
             v_wheresql := v_wheresql || 'AND (1=2 ';  -- if all parameters are null, then dont return anyting  
        ELSE    
            IF pwide_search_fg = 'Y'
            THEN
                v_match_operator := 'OR';
                v_wheresql := v_wheresql || 'AND ( 1=2 '; -- This is used to start a bracket
            ELSE
                v_match_operator :=  'AND';            
                v_wheresql := v_wheresql || 'AND ( 1=1 '; -- This is used to start a bracket
            END IF; 
       END IF;
        -- Build the Where clause with the parameters provided
        If ptlm_id is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' w.uwi = ' || '''' || ptlm_id || '''';
         end if;
        
        If pwell_num is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' w.well_num = ' || '''' || pwell_num|| '''';
        end if;
        
        If puwi is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' w.ipl_uwi_local = ' || '''' || puwi || '''';
        end if;
        
        If pcountry is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' w.country = ' || '''' || pcountry || '''';
        end if;
        
        If psource is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' w.source = ' || '''' || psource || '''';
        end if;
        
        If pwell_name is not NULL THEN  
            if instr(pwell_name, '%') > 0 then
                v_operator := 'LIKE ';
                v_wheresql := v_wheresql || ' ' || v_match_operator || ' upper(REPLACE(w.well_name,chr(39),' || '''' || '''' || ')) ' || v_operator || 'UPPER(' || '''' || pwell_name || '''' || ')';
            else
                v_operator := '= ';
                v_wheresql := v_wheresql || ' ' || v_match_operator || ' wim_util.compress_well_name(w.well_name) ' || v_operator ||  'WIM_UTIL.COMPRESS_WELL_NAME(' || '''' || pwell_name || '''' || ')';
            end if;  
        end if;
    
        If pplot_name is not NULL THEN
            if instr(pplot_name, '%') > 0 then
                v_operator := 'LIKE ';
            else
                v_operator := '= ';
            end if;  
              --IF instr(w.Plot_Name, chr(39)) > 0 then
                v_wheresql := v_wheresql || ' ' || v_match_operator || ' UPPER(REPLACE(w.plot_name,chr(39),'|| '''' || '''' || ')) ' || v_operator || 'UPPER(' || '''' || pplot_name || '''' || ')';
              --else       
              --  v_wheresql := v_wheresql || ' ' || v_match_operator || ' UPPER(w.plot_name) ' || v_operator || 'UPPER(' || '''' || pplot_name || '''' || ')';
            --  end if;              
        end if;
   
        If pspud_date is not NULL THEN            
              v_wheresql := v_wheresql || ' ' || v_match_operator || ' trunc(w.spud_date) = ' || 'trunc( to_date( ' || '''' || pspud_date ||  '''' || '))  ';
        end if;
      
        If prig_release_date is not NULL THEN
             v_wheresql := v_wheresql || ' ' || v_match_operator || ' trunc(w.rig_release_date) = ' || 'trunc( to_date( ' || '''' || prig_release_date ||  '''' || '))  ';  
        end if;
      
        If pkb_elev is not NULL THEN
            v_elev_From := pkb_elev-pelevtolerance;
            v_elev_To := pkb_elev+pelevtolerance;                     
            v_wheresql := v_wheresql || ' ' || v_match_operator ||  '( w.kb_elev >= ' || v_elev_From || ' AND w.kb_elev <= ' || v_elev_To || ')';            
        end if;
      
        If pdrill_Td is not NULL THEN
            v_elev_From := pdrill_Td-pelevtolerance;
            v_elev_To   := pdrill_Td+pelevtolerance;
            v_wheresql := v_wheresql || ' ' || v_match_operator ||  '( w.drill_Td >= ' || v_elev_From || ' AND w.drill_Td <= ' || v_elev_To || ')';
        end if;
  
       
        If psurface_latitude is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' TRUNC(w.surface_latitude, ' || ptolerance || ')' || ' = ' || 'TRUNC(' || psurface_latitude || ',' || ptolerance || ')';
        end if;
        
        If psurface_longitude is not NULL THEN    
            v_wheresql := v_wheresql ||  ' ' || v_match_operator || ' TRUNC(w.surface_longitude, ' || ptolerance || ')' || ' = ' || 'TRUNC(' || psurface_longitude || ',' || ptolerance || ')';            
        end if;
        
        If pbottom_hole_latitude is not NULL THEN      
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' TRUNC(w.bottom_hole_latitude, ' || ptolerance || ')' || ' = ' || 'TRUNC(' || pbottom_hole_latitude || ',' || ptolerance || ')';            
        end if;
        
        If pbottom_hole_longitude is not NULL THEN
            v_wheresql := v_wheresql || ' ' || v_match_operator || ' TRUNC(w.bottom_hole_longitude, ' || ptolerance || ')' || ' = ' || 'TRUNC(' || pbottom_hole_longitude || ',' || ptolerance || ')';            
        end if;
        
         --License --
        if plicense_num is not null then
            v_selectsql := v_selectsql || ' , wl.license_num ';          
            v_fromsql   := v_fromsql || ' , well_license wl ';
            
            if pwide_search_fg = 'N'
            then                
                v_wheresql  := v_wheresql || ' AND wl.license_num = '  || '''' || plicense_num || '''';
                v_wheresql := v_wheresql || ' )';
                v_wheresql  := v_wheresql || ' AND wl.uwi = w.uwi AND wl.source = w.source AND wl.ACTIVE_IND = ''Y''';
               
            else               
                v_wheresql  := v_wheresql || ' OR wl.license_num = '  || '''' || plicense_num || '''';
                v_wheresql := v_wheresql || ' )';
                v_wheresql  := v_wheresql || ' AND wl.uwi(+) = w.uwi AND wl.source(+) = w.source ';
            end if;
        else
            v_selectsql := v_selectsql || ' , NULL ';
            v_wheresql := v_wheresql || ' )';       
        end if;

       -- Add logic to check well_node_version if pgeog_coord_system_is provided       
       if pgeog_coord_system_id is not null then
          IF pbottom_hole_latitude is not null OR pbottom_hole_longitude is not null then
            
             v_fromsql := v_fromsql || ' , ( Select * from ' || v_NodeMatchtbl || ' Where node_position = ' || '''B''' || ') B ';
              if pwide_search_fg = 'Y' THEN
               v_wheresql := v_wheresql || ' AND w.SOURCE = B.SOURCE(+) ' ;                
                v_wheresql := v_wheresql || ' AND w.UWI = B.IPL_UWI(+) ' ;              
                v_wheresql := v_wheresql || ' AND w.bottom_hole_latitude = B.latitude(+) ' ;
                v_wheresql := v_wheresql || ' AND w.bottom_hole_longitude = B.longitude(+) ' ;
                v_wheresql := v_wheresql || ' AND B.geog_coord_system_id(+) = ' || '''' || pgeog_coord_system_id || ''''  ;
              ELSE
                v_wheresql := v_wheresql || ' AND w.SOURCE = B.SOURCE ' ;                
                v_wheresql := v_wheresql || ' AND w.UWI = B.IPL_UWI ' ;              
                v_wheresql := v_wheresql || ' AND w.bottom_hole_latitude = B.latitude ' ;
                v_wheresql := v_wheresql || ' AND w.bottom_hole_longitude = B.longitude ' ;
                v_wheresql := v_wheresql || ' AND B.geog_coord_system_id = ' || '''' || pgeog_coord_system_id || ''''  ;
             END IF;
          end if;
          
          IF psurface_latitude is not null OR psurface_longitude is not null then
               
              v_fromsql := v_fromsql || ' , ( Select * from ' || v_NodeMatchtbl || ' Where node_position = ' || '''S''' || ') S ';
              if pwide_search_fg = 'Y' THEN              
                  v_wheresql := v_wheresql || ' AND w.SOURCE = S.SOURCE(+) ' ;               
                  v_wheresql := v_wheresql || ' AND w.UWI = S.IPL_UWI(+) ' ;              
                  v_wheresql := v_wheresql || ' AND w.surface_latitude = S.latitude(+) ' ;
                  v_wheresql := v_wheresql || ' AND w.surface_longitude = S.longitude(+) ' ;
                  v_wheresql := v_wheresql || ' AND S.geog_coord_system_id(+) = ' || '''' || pgeog_coord_system_id || ''''  ;
              ELSE
                  v_wheresql := v_wheresql || ' AND w.SOURCE = S.SOURCE ' ;               
                  v_wheresql := v_wheresql || ' AND w.UWI = S.IPL_UWI ' ;              
                  v_wheresql := v_wheresql || ' AND w.surface_latitude = S.latitude ' ;
                  v_wheresql := v_wheresql || ' AND w.surface_longitude = S.longitude ' ;
                  v_wheresql := v_wheresql || ' AND S.geog_coord_system_id = ' || '''' || pgeog_coord_system_id || ''''  ;
              END IF;
          end if;
          
        end if;
 
        RETURN v_insertinto_sql ||  v_selectsql ||  v_fromsql || v_wheresql;

   END Build_SQL;

/*----------------------------------------------------------------------------------------------------------
Function:  FIND_WELLS
Detail:    This Function used the parametes provided and does a simple search.  
            It calls Build_SQL fundtion to build dynamic sql from parameters provided. Executes the sql that insert the results to the temp table:
            WIM_FIND_WELL.
            Currently, it does the Exact match and/or  Wide search match.
            If pwide_search_fg flag  ='Y', it will do Exact Match and Wide match and insert the results to Wim_Find_Well
            table with result and Remark (how it matched).
            
            Source and AliasFg to determine which table to read from Well or Well_Version:
            
            Source    AliasFg     Action                                            
            Null         W       Search only wells for any source                            
            Null         A       Search versions and aliases for all sources            
            Specified    V       Search only versions for this source                      
            Specified    A       Search versions and aliases but only for this source  
            Null         V       Search only versions for any source                
            Specified    W       Search only wells for this source                      

            This function is used by application ( e.g. iWim, DataFinder) and WIM_LOADER.      

Called By:  WIM_LOADER
Calls:      BUILD_SQL

Created On: July. 2012
History of Change:
Jan 29, 2013        V.Rajpoot       Added  PRAGMA AUTONOMOUS_TRANSACTION
------------------------------------------------------------------------------------------------------------*/

  FUNCTION find_wells (
      ptlm_id         IN OUT   WELL_VERSION.UWI%TYPE,
      pcountry                 WELL_VERSION.COUNTRY%TYPE                    DEFAULT NULL,
      pwell_num                WELL_VERSION.WELL_NUM%TYPE                   DEFAULT NULL,
      puwi                     WELL_VERSION.IPL_UWI_LOCAL%TYPE              DEFAULT NULL,
      pwell_name               WELL_VERSION.WELL_NAME%TYPE                  DEFAULT NULL,
      pspud_date               WELL_VERSION.SPUD_DATE%TYPE                  DEFAULT NULL,
      prig_release_date        WELL_VERSION.RIG_RELEASE_DATE%TYPE           DEFAULT NULL,
      pkb_elev                 WELL_VERSION.KB_ELEV%TYPE                    DEFAULT NULL,
      pdrill_td                WELL_VERSION.DRILL_TD%TYPE                   DEFAULT NULL,
      pbottom_hole_latitude    WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE       DEFAULT NULL,
      pbottom_hole_longitude   WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE      DEFAULT NULL,
      psurface_latitude        WELL_VERSION.SURFACE_LATITUDE%TYPE           DEFAULT NULL,
      psurface_longitude       WELL_VERSION.SURFACE_LONGITUDE%TYPE          DEFAULT NULL,
      pgeog_coord_system_id    WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE  DEFAULT NULL,
      pplot_name               WELL_VERSION.PLOT_NAME%TYPE                  DEFAULT NULL,
      plicense_num             WELL_LICENSE.LICENSE_NUM%TYPE                DEFAULT NULL,
      psource                  WELL_VERSION.SOURCE%TYPE                     DEFAULT NULL,
      pwide_search_fg          VARCHAR2                                     DEFAULT 'N',
      pfindbyalias_fg          VARCHAR2                                     DEFAULT 'A',      
      ptolerance               NUMBER                                       DEFAULT 5,
      pelevtolerance           NUMBER                                       DEFAULT 1
   ) RETURN NUMBER  
     
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      
      v_matched_tlmID       WELL_VERSION.UWI%TYPE;
      v_count               NUMBER;
      v_sql                 VARCHAR2(5000);
      v_matched_by_alias    VARCHAR2(1);
      vnumwells_matched     NUMBER;     
      
   BEGIN
       v_matched_tlmID := NULL; 
       v_matched_by_alias := 'N';
       v_count :=0;
       
       DELETE FROM wim_find_well;
       COMMIT;
      
      --First do exact match        
       --Build dynamic SQL 
        v_Sql := BUILD_SQL(
                        ptlm_id                 => ptlm_id,
                        pcountry                => pcountry,
                        pwell_num               => pwell_num,
                        puwi                    => puwi,
                        pwell_name              => REPLACE (pwell_name, CHR(39), ''), --Removing apostrophe, otherwise it creates syntax error.     
                        pspud_date              => pspud_date,
                        prig_release_date       => prig_release_date,
                        pkb_elev                => pkb_elev,
                        pdrill_td               => pdrill_td,
                        pbottom_hole_latitude   => pbottom_hole_latitude,
                        pbottom_hole_longitude  => pbottom_hole_longitude,
                        psurface_latitude       => psurface_latitude,
                        psurface_longitude      => psurface_longitude,
                        pgeog_coord_system_id   => pgeog_coord_system_id,
                        pplot_name              => REPLACE(pplot_name,CHR(39),''),
                        plicense_num            => plicense_num,
                        psource                 => psource,      
                        pwide_search_fg         => 'N',  --Do Exact match first
                        pfindbyalias_fg         => pfindbyalias_fg,
                        ptolerance              => ptolerance, 
                        pelevtolerance          => pelevtolerance   );
        
        --dbms_output.put_line ('EXACT MATCH ' || v_sql);
      execute immediate v_sql;
      execute immediate 'COMMIT';

    
   --Wide Search
     IF pwide_search_fg = 'Y'
     THEN
        -- do search using 'OR'       
        --Build dynamic SQL 
      
       v_sql := BUILD_SQL(
                        ptlm_id                 => ptlm_id,
                        pcountry                => pcountry,
                        pwell_num               => pwell_num,
                        puwi                    => puwi,
                        pwell_name              => REPLACE (pwell_name, CHR(39), ''), --Removing apostrophe, otherwise it creates syntax error.   ,
                        pspud_date              => pspud_date,
                        prig_release_date       => prig_release_date,
                        pkb_elev                => pkb_elev,
                        pdrill_td               => pdrill_td,
                        pbottom_hole_latitude   => pbottom_hole_latitude,
                        pbottom_hole_longitude  => pbottom_hole_longitude,
                        psurface_latitude       => psurface_latitude,
                        psurface_longitude      => psurface_longitude,
                        pgeog_coord_system_id   => pgeog_coord_system_id,  
                        pplot_name              => pplot_name,
                        plicense_num            => plicense_num,
                        psource                 => psource,      
                        pwide_search_fg         => 'Y',  --Do Wide search
                        pfindbyalias_fg         => pfindbyalias_fg,
                        ptolerance              => ptolerance,   
                        pelevtolerance          => pelevtolerance  );


        --If There is already a Exact match for these parameters, we dont want to insert another match
        v_sql := v_sql ||  ' AND w.uwi not in ( select tlm_id from wim_find_well where match_type = ''E'') ';
       --dbms_output.put_line ('WIDE SEARCH MATCH ' || v_sql);
       execute immediate v_sql;
       
--        --Remove extra comma at the end from Remark
        Update wim_find_well
        set remark =SUBSTR(remark, 1, INSTR(remark, ',', -1) - 1) || substr(Remark, Instr(Remark, ',',-1)- Length(Remark),   Instr(Remark, ',',-1)) 
        where remark NOT LIKE 'Exact Match%';
        COMMIT;
        
        END IF;
     

      --Find by Alias
      IF pfindbyalias_fg = 'A' --'Y' 
      THEN
           IF ptlm_id is not null 
           THEN
              v_matched_tlmID := find_by_alias (ptlm_id, 'TLM_ID', psource);                
           END IF;
           
           IF puwi is not null 
           THEN
                v_matched_tlmID := find_by_alias (puwi, 'UWI', psource);                
           END IF;
           
           IF pwell_num is not null 
           THEN
               v_matched_tlmID := find_by_alias (pwell_num, 'WELL_NUM', psource);                
           END IF;
           
           IF pwell_name is not null 
           THEN                
                v_matched_tlmID := find_by_alias (REPLACE (pwell_name, CHR(39), '')  , 'WELL_NAME', psource);               
           END IF;
           
           IF pplot_name is not null 
           THEN
               v_matched_tlmID := find_by_alias (REPLACE (pplot_name, CHR(39), '') , 'PLOT_NAME', psource);
           END IF;
           
           IF pcountry is not null 
           THEN
               v_matched_tlmID := find_by_alias (pcountry, 'COUNTRY', psource);
           END IF;   
                          
      END IF;

       select count(distinct TLM_ID) into v_count 
       from wim_find_well;
      
       if v_count = 1 then -- There is single match,
            select distinct TLM_ID into v_matched_tlmID 
            from wim_find_well;
            PTLM_ID := v_matched_tlmID; --assign to OUT parameter
       end if;
     
       --Return total # of matches
       SELECT COUNT(TLM_ID) into vnumwells_matched
       from wim_find_well;
            
       RETURN vnumwells_matched;
   END;
   
END wim_search; 

/
