create or replace PACKAGE BODY     WIM_WELL_ACTION 
IS

/*---------------------------------------------------------------------------------------------------------------------
    SCRIPT: WIM.WIM_Well_Action.pkb

 PURPOSE:
   Package body for the WIM Action ( Update, Create, Inactivate, Reactivate, Delete..) functionality

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   See Package Specification

   Syntax:
    N/A

 HISTORY:
          ??          S.Makarov      Initial version
       26-Mar-2012    V.Rajpoot      Modified Well_Action_Reactivate - Exlcude Expiry_Date check
       7-May-2012     V.Rajpoot      Modified well_action_update (where it checks if Alias need to added or not), If new or old values is Null
                                     comparison doesnt work properly, Added 2 other checks for all alias types.
       16-Aug-2012    V.Rajpoot      Modifed Add_Alias procedure, Changed MAX (well_alias_id) to MAX (to_number(well_alias_id))
                                     so the max  function will return the correct number.
      27-Aug-2012     V.Rajpoot      Added a check before Reactivation. Check if active well is already there with the same well_num/source.
                                     If there is, then do not reactivate. This is part of WIM_GATEWAY version: 1.0.2
      13-Sept-2012    V.Rajpoot      Changed WELL_ACTION_UPDATE procedure ( Changed the logic where it decides to add an alias.)
                                     (If Alias(e.g Well_Name) is Null before, then no alias will added because well_alias can not be Null.
                                     If well_name is not null and changed to some other value, alias will be added
                                     If well_name is not null and changed to null then alias will be added.)
                                     This is part of WIM_GATEWAY version: 1.0.3 
      29-Nov-2012     V.Rajpoot      Modified Well_Move procedure  
                                     When transferring an alias, sometimes it will create a constraint error, because of duplications.
                                     Changed it: When transferring , it will now increment Well_Alias_Id
                                     This is part of WIM_GATEWAY version: 1.2.0 
      8-Feb-2013      V.Rajpoot      1)Added a logic in well_Action to add/update an override version if there are specials chars in the well_name
                                     2) Delete Inactive version while merging
                                     3) Delete Inactive version while adding
                                     4) Modified Well_Action_Delete to delete all well, not just Active ones 
                                      This is part of WIM_GATEWAY version: 1.3.1
                                      
     5-June-2013    V.Rajpoot       Removed a call to Well_Action_Override procedure. This procedure created
                                    override version if there specials chars in a well_name
                                     This is part of WIM_GATEWAY version: 1.4.1
                                    
     29-July-2013   V.Rajpoot       Added new attribute Location_Accuracy and Rig_Name
                                    This is part of WIM_GATEWAY version: 1.4.2
    May 14, 2014    K.Edwards       Changed the update ('U') section of well_node_version_process
                                  so on update of a record the row_changed_date is kept in
                                  sync with the source data.
    April 10, 2015	KXEDWARD		  Added geochem_count to the well_inventory check
                                  - changed all sql queries for last active well to use wim_util.is_last_version
                                  - called from well_action_delete, well_move, and well_action_inactivate                                  
	June 02, 2016	KXEDWARD	 - Changed delete function to ONLY inactivate aliases
----------------------------------------------------------------------------------------------------------------------------*/
   v_current_action   VARCHAR (50);
   
   
/*----------------------------------------------------------------------------------------------------------
Function:  TO_NUMBER_EXT
Detail:    This Function converts string to Number
    
History of Change:
------------------------------------------------------------------------------------------------------------*/

   FUNCTION to_number_ext (p_string VARCHAR2)
      RETURN NUMBER
   IS
      dummy_x   NUMBER;
   BEGIN
      IF (p_string IS NULL)
      THEN
         RETURN ('NOT A NUMBER');
      END IF;

      dummy_x := TO_NUMBER (p_string);
      -- select to_number(p_string) into dummy_x from dual;
      RETURN dummy_x;
   EXCEPTION
      WHEN INVALID_NUMBER OR VALUE_ERROR
      THEN
         RETURN NULL;
   END;

/*----------------------------------------------------------------------------------------------------------
Procedure: Well_Action_Override
Detail:    This procedure checks if well_name  has special chars in them.
           if there are then it creates or updates override version with well_name without special chars.
    
History of Change:
------------------------------------------------------------------------------------------------------------*/
/*PROCEDURE Well_Action_Override(ptlm_id well.uwi%type)
IS

v_well_name     well_Version.well_name%type;
v_country       well_version.country%type;
vtlm_id         well_version.uwi%type;
v_count         number;
v_status        number; 

BEGIN
      
    Select count(1) into v_count
      from ppdm.well
     where uwi = ptlm_id      
       AND REGEXP_INSTR (well_name,'[][`''~!@#$%^~&*()|+"=}{;:.,><?/\_-]') >0 ;
       --AND  REGEXP_LIKE (well_name, '[^A-Z,a-z,0-9,[:space:]]') ;
        
       --Found this well in Well table'
      IF v_count >0 then
      
        Select count(1) into v_count
          from ppdm.well
          where uwi = ptlm_id
           and primary_source = '075TLMO';
           
           select uwi,well_name, country into vtlm_id,v_well_name, v_country
              from ppdm.well
              where uwi = ptlm_id;
              
              --Remove spacial chars from well_name
      
              v_well_name := wim.wim_util.cleanup_Special_Chars(v_well_name);
      
                       
           IF v_count > 0 -- means there is already over ride version there, so we need to  update it with plot_name and well_name
           THEN
           
--            dbms_output.put_line('This well has override version ');  
              
              v_status := wim_gateway.Update_Well(  P_TLM_ID     => vtlm_id,
                                                    P_SOURCE     => '075TLMO',
                                                    P_COUNTRY    => v_country,
                                                    P_WELL_NAME  => v_well_name
                                                   
                                      );
               
           ELSE -- Create (adding) override version
          --  dbms_output.put_line('This well doesn''t have  override version ');
             v_status := wim_gateway.Create_well( P_TLM_ID     => vtlm_id,
                                      P_SOURCE     => '075TLMO',
                                      P_COUNTRY     => v_country,
                                      P_WELL_NAME  => v_well_name                                     
                                      );
             
           END IF;
      END IF;
END;
*/
/*----------------------------------------------------------------------------------------------------------
Procedure:  ADD_ALIAS
Detail:    This Procedure adds alias to WELL_ALIAS table everytime there is change in ( WELL_NAME,
          WELL_NUM, TLM_ID, PLOT_NAME, COUNTRY attributes) and on well move/merge
    
History of Change:
------------------------------------------------------------------------------------------------------------*/

   PROCEDURE add_alias (
      ptlm_id        well_alias.uwi%TYPE,
      psource        well_alias.SOURCE%TYPE,
      palias_type    well_alias.alias_type%TYPE,
      palias_value   well_alias.well_alias%TYPE,
      preason_type   well_alias.reason_type%TYPE DEFAULT 'Update',
      puser          well_alias.row_created_by%TYPE DEFAULT USER
   )
   IS
      v_well_alias_id    well_alias.well_alias_id%TYPE;
      v_num              NUMBER;
      v_effective_date   DATE;
   BEGIN
      v_current_action := 'add_alias';

      BEGIN
          SELECT MAX (to_number(well_alias_id))
           INTO v_num
           FROM well_alias
          WHERE uwi = ptlm_id
            AND SOURCE = psource
            --AND active_ind = 'Y'    /*Active ind is not part of the WA_PK constraint so can have error adding the same record again*/
            AND alias_type = palias_type
            AND NVL (LENGTH (TRIM (TRANSLATE (well_alias_id,
                                              '0123456789',
                                              '          '
                                             )
                                  )
                            ),
                     0
                    ) = 0;                /* to check only numeric alias_ids*/

         --AND expiry_date IS NULL;
         v_well_alias_id := NVL (v_num, 0) + 1;
         
      EXCEPTION
         WHEN OTHERS
         THEN
            v_well_alias_id := 1;
      END;

      /* Let's find out what would be the effective date*/
      /* if should be either last expiry date for the same type of alias for this uwi and source*/
      /* or created_date for well version*/
      BEGIN
         SELECT MAX (expiry_date)
           INTO v_effective_date
           FROM well_alias
          WHERE uwi = ptlm_id AND SOURCE = psource
                AND alias_type = palias_type;
                
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT row_created_date
              INTO v_effective_date
              FROM well_version
             WHERE uwi = ptlm_id AND SOURCE = psource;
      END;

      UPDATE well_alias
         SET expiry_date = v_effective_date
       WHERE uwi = ptlm_id
         AND SOURCE = psource
         AND active_ind = 'Y'
         AND alias_type = palias_type
         AND alias_type <> 'TLM_ID'
         /* for TLM_ID we want to keep all active aliases not expired*/
         AND expiry_date IS NULL;

      IF palias_type <> 'TLM_ID'
      THEN
         INSERT INTO well_alias
                     (uwi, SOURCE, well_alias_id, active_ind, alias_type,
                      reason_type, effective_date, expiry_date, well_alias,
                      row_created_by, row_created_date
                     )
              VALUES (ptlm_id, psource, v_well_alias_id, 'Y', palias_type,
                      preason_type, v_effective_date, SYSDATE, palias_value,
                      puser, SYSDATE
                     );
                     
      ELSE
         INSERT INTO well_alias
                     (uwi, SOURCE, well_alias_id, active_ind, alias_type,
                      reason_type, effective_date, expiry_date, well_alias,
                      row_created_by, row_created_date
                     )
              VALUES (ptlm_id, psource, v_well_alias_id, 'Y', palias_type,
                      preason_type, v_effective_date, NULL, palias_value,
                      puser, SYSDATE
                     );
      
      END IF;
      
      
   END add_alias;

   
/*----------------------------------------------------------------------------------------------------------
Procedure:  INACTIVATE_ALIAS
Detail:     This procedure Inactivates an alias in the Well Alias table.
            Used when the xref it represents is no longer valid
    
History of Change:
------------------------------------------------------------------------------------------------------------*/
   PROCEDURE inactivate_alias (
      ptlm_id       well_alias.uwi%TYPE,
      psource       well_alias.SOURCE%TYPE,
      palias_type   well_alias.alias_type%TYPE,
      puser         well_alias.row_changed_by%TYPE DEFAULT USER
   )
   IS
   BEGIN
      v_current_action := 'inactivate_alias';

      UPDATE well_alias
         SET active_ind = 'N',
             expiry_date = SYSDATE,
             row_changed_by = puser,
             row_changed_date = SYSDATE
       WHERE uwi = ptlm_id AND SOURCE = psource AND alias_type = palias_type;
   END inactivate_alias;


/*----------------------------------------------------------------------------------------------------------
Procedure:  OUM_CONVERSION
Detail:     This procedure doesUnit conversions for well_version and child tables
    
History of Change:
------------------------------------------------------------------------------------------------------------*/
   PROCEDURE oum_conversion (pwim_stg_id NUMBER)
   IS
   BEGIN
      v_current_action := 'oum_conversion - wl';

      UPDATE wim_stg_well_license
         SET wim_direction_to_loc_std =
                wim_util.uom_conversion (wim_direction_to_loc_cuom,
                                         'M',
                                         direction_to_loc
                                        ),
             wim_distance_to_loc_std =
                wim_util.uom_conversion (wim_distance_to_loc_cuom,
                                         'M',
                                         distance_to_loc
                                        ),
             wim_projected_depth_std =
                wim_util.uom_conversion (wim_projected_depth_cuom,
                                         'M',
                                         projected_depth
                                        ),
             wim_projected_tvd_std =
                wim_util.uom_conversion (wim_projected_tvd_cuom,
                                         'M',
                                         projected_tvd
                                        ),
             wim_rig_substr_height_std =
                wim_util.uom_conversion (wim_rig_substr_height_cuom,
                                         'M',
                                         rig_substr_height
                                        )
       WHERE wim_stg_id = pwim_stg_id AND wim_action_cd IN ('C', 'A', 'U');
      
      v_current_action := 'oum_conversion - wn_m_b';
    
      UPDATE wim_stg_well_node_m_b
         SET wim_ew_distance_std =
                wim_util.uom_conversion (wim_ew_distance_cuom,
                                         'M',
                                         ew_distance
                                        ),
             wim_ns_distance_std =
                wim_util.uom_conversion (wim_ns_distance_cuom,
                                         'M',
                                         ns_distance
                                        )
       WHERE wim_stg_id = pwim_stg_id AND wim_action_cd IN ('C', 'A', 'U');
      
      v_current_action := 'oum_conversion - wnv';
      
      UPDATE wim_stg_well_node_version
         SET wim_easting_std =
                      wim_util.uom_conversion (wim_easting_cuom, 'M', easting),
             wim_elev_std = wim_util.uom_conversion (wim_elev_cuom, 'M', elev),
             wim_md_std = wim_util.uom_conversion (wim_md_cuom, 'M', md),
             wim_northing_std =
                    wim_util.uom_conversion (wim_northing_cuom, 'M', northing),
             wim_polar_offset_std =
                wim_util.uom_conversion (wim_polar_offset_cuom,
                                         'M',
                                         polar_offset
                                        ),
             wim_reported_tvd_std =
                wim_util.uom_conversion (wim_reported_tvd_cuom,
                                         'M',
                                         reported_tvd
                                        ),
             wim_x_offset_std =
                    wim_util.uom_conversion (wim_x_offset_cuom, 'M', x_offset),
             wim_y_offset_std =
                    wim_util.uom_conversion (wim_y_offset_cuom, 'M', y_offset)
       WHERE wim_stg_id = pwim_stg_id AND wim_action_cd IN ('C', 'A', 'U');

      v_current_action := 'oum_conversion - ws';
      
      UPDATE wim_stg_well_status
         SET wim_status_depth_std =
                wim_util.uom_conversion (wim_status_depth_cuom,
                                         'M',
                                         status_depth
                                        )
       WHERE wim_stg_id = pwim_stg_id AND wim_action_cd IN ('C', 'A', 'U');
      
      v_current_action := 'oum_conversion - wv';
      
      UPDATE wim_stg_well_version
         SET wim_casing_flange_elev_std =
                wim_util.uom_conversion (wim_casing_flange_elev_cuom,
                                         'M',
                                         casing_flange_elev
                                        ),
             wim_confidential_depth_std =
                wim_util.uom_conversion (wim_confidential_depth_cuom,
                                         'M',
                                         confidential_depth
                                        ),
             wim_deepest_depth_std =
                wim_util.uom_conversion (wim_deepest_depth_cuom,
                                         'M',
                                         deepest_depth
                                        ),
             wim_depth_datum_elev_std =
                wim_util.uom_conversion (wim_depth_datum_elev_cuom,
                                         'M',
                                         depth_datum_elev
                                        ),
             wim_derrick_floor_elev_std =
                wim_util.uom_conversion (wim_derrick_floor_elev_cuom,
                                         'M',
                                         derrick_floor_elev
                                        ),
             wim_drill_td_std =
                    wim_util.uom_conversion (wim_drill_td_cuom, 'M', drill_td),
             wim_final_td_std =
                    wim_util.uom_conversion (wim_final_td_cuom, 'M', final_td),
             wim_ground_elev_std =
                wim_util.uom_conversion (wim_ground_elev_cuom,
                                         'M',
                                         ground_elev
                                        ),
             wim_kb_elev_std =
                      wim_util.uom_conversion (wim_kb_elev_cuom, 'M', kb_elev),
             wim_log_td_std =
                        wim_util.uom_conversion (wim_log_td_cuom, 'M', log_td),
             wim_max_tvd_std =
                      wim_util.uom_conversion (wim_max_tvd_cuom, 'M', max_tvd),
             wim_net_pay_std =
                      wim_util.uom_conversion (wim_net_pay_cuom, 'M', net_pay),
             wim_plugback_depth_std =
                wim_util.uom_conversion (wim_plugback_depth_cuom,
                                         'M',
                                         plugback_depth
                                        ),
             wim_water_depth_std =
                wim_util.uom_conversion (wim_water_depth_cuom,
                                         'M',
                                         water_depth
                                        ),
             wim_whipstock_depth_std =
                wim_util.uom_conversion (wim_whipstock_depth_cuom,
                                         'M',
                                         whipstock_depth
                                        )
       WHERE wim_stg_id = pwim_stg_id AND wim_action_cd IN ('C', 'A', 'U');
   END;



/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_NODE_VERSION_PROCCESS
Detail:     This procedure updates Well_Node_Version table depends on what action_cd is.
    
History of Change:
July 29, 2013   V.Rajpoot   Added new atribute Location_Accuracy to Update and Inserts
May 14, 2014    K.Edwards   Changed the update ('U') section of well_node_version_process
                            so on update of a record the row_changed_date is kept in
                            sync with the source data.
------------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_node_version_proccess (pwim_stg_id NUMBER, paudit_id NUMBER)
   IS
      v_audit_id      NUMBER;
      v_node_obs_no   NUMBER;
      v_changed_date  date;
   BEGIN
      v_current_action := 'well_node_version_proccess';
      v_audit_id := paudit_id;

      
      FOR node_rec IN (SELECT   a.*, b.row_created_by AS request_created_by,
                                b.row_created_date AS request_created_date
                           FROM wim_stg_well_node_version a INNER JOIN wim_stg_request b
                                ON a.wim_stg_id = b.wim_stg_id
                          WHERE a.wim_stg_id = pwim_stg_id
                       ORDER BY wim_seq)
      LOOP
         CASE
            WHEN node_rec.wim_action_cd = 'A' OR node_rec.wim_action_cd = 'C'
            THEN
               IF node_rec.node_obs_no IS NULL
               THEN
                  SELECT MAX (node_obs_no) + 1
                    INTO v_node_obs_no
                    FROM well_node_version wnv
                   WHERE wnv.node_id = node_rec.node_id
                     AND wnv.SOURCE = node_rec.SOURCE
                     --AND wnv.node_obs_no = node_rec.node_obs_no
                     AND wnv.geog_coord_system_id = node_rec.geog_coord_system_id
                     AND wnv.location_qualifier = node_rec.location_qualifier;

                  v_node_obs_no := NVL (v_node_obs_no, 1);
               ELSE
                  v_node_obs_no := node_rec.node_obs_no;
               END IF;

               -- Must be a new node for this well
               INSERT INTO well_node_version
                           (node_id, SOURCE, node_obs_no,
                            acquisition_id, active_ind,
                            country, county,
                            easting, easting_ouom,
                            effective_date, elev,
                            elev_ouom, ew_direction,
                            expiry_date,
                            geog_coord_system_id, latitude,
                            legal_survey_type,
                            location_qualifier,
                            location_quality, longitude,
                            map_coord_system_id,
                            md, md_ouom,
                            monument_id, monument_sf_type,
                            node_position,
                            northing,
                            northing_ouom, north_type,
                            ns_direction, polar_azimuth,
                            polar_offset,
                            polar_offset_ouom, ppdm_guid,
                            preferred_ind, province_state,
                            remark, reported_tvd,
                            reported_tvd_ouom,
                            version_type, x_offset,
                            x_offset_ouom,
                            y_offset,
                            y_offset_ouom,
                            ipl_xaction_code,
                            row_changed_by,
                            row_changed_date,
                            row_created_by,
                            row_created_date, ipl_uwi,
                            row_quality,
                            location_accuracy                            
                           )
                    VALUES (node_rec.node_id, node_rec.SOURCE, v_node_obs_no,
                            --node_rec.node_obs_no,
                            node_rec.acquisition_id, node_rec.active_ind,
                            node_rec.country, node_rec.county,
                            node_rec.wim_easting_std, node_rec.easting_ouom,
                            node_rec.effective_date, node_rec.wim_elev_std,
                            node_rec.elev_ouom, node_rec.ew_direction,
                            node_rec.expiry_date,
                            node_rec.geog_coord_system_id, node_rec.latitude,
                            node_rec.legal_survey_type,
                            node_rec.location_qualifier,
                            node_rec.location_quality, node_rec.longitude,
                            node_rec.map_coord_system_id,
                            node_rec.wim_md_std, node_rec.md_ouom,
                            node_rec.monument_id, node_rec.monument_sf_type,
                            node_rec.node_position,
                            node_rec.wim_northing_std,
                            node_rec.northing_ouom, node_rec.north_type,
                            node_rec.ns_direction, node_rec.polar_azimuth,
                            node_rec.wim_polar_offset_std,
                            node_rec.polar_offset_ouom, node_rec.ppdm_guid,
                            node_rec.preferred_ind, node_rec.province_state,
                            node_rec.remark, node_rec.wim_reported_tvd_std,
                            node_rec.reported_tvd_ouom,
                            node_rec.version_type, node_rec.wim_x_offset_std,
                            node_rec.x_offset_ouom,
                            node_rec.wim_y_offset_std,
                            node_rec.y_offset_ouom,
                            node_rec.ipl_xaction_code,
                            node_rec.row_changed_by,
                            node_rec.row_changed_date,
                            --node_rec.request_created_by,     --row_created_by,
                            --node_rec.request_created_date,
                            node_rec.row_created_by,
                            node_rec.row_created_date, node_rec.ipl_uwi,
                            node_rec.row_quality,
                            node_rec.location_accuracy                            
                           );
            WHEN node_rec.wim_action_cd = 'U'
            THEN
               select row_changed_date into v_changed_date
               from ppdm.well_node_version wnv
               WHERE wnv.node_id = node_rec.node_id
                  AND wnv.SOURCE = node_rec.SOURCE
                  AND wnv.node_obs_no = node_rec.node_obs_no
                  AND wnv.geog_coord_system_id = node_rec.geog_coord_system_id
                  AND wnv.location_qualifier = node_rec.location_qualifier;
                  
               -- Update the node
               UPDATE well_node_version wnv
                  SET acquisition_id = node_rec.acquisition_id,
                      active_ind = node_rec.active_ind,
                      country = node_rec.country,
                      county = node_rec.county,
                      easting = node_rec.wim_easting_std,
                      easting_ouom = node_rec.easting_ouom,
                      effective_date = node_rec.effective_date,
                      elev = node_rec.wim_elev_std,
                      elev_ouom = node_rec.elev_ouom,
                      ew_direction = node_rec.ew_direction,
                      expiry_date = node_rec.expiry_date,
                      --geog_coord_system_id = node_rec.geog_coord_system_id,
                      latitude = node_rec.latitude,
                      legal_survey_type = node_rec.legal_survey_type,
                      --location_qualifier = node_rec.location_qualifier,
                      location_quality = node_rec.location_quality,
                      longitude = node_rec.longitude,
                      map_coord_system_id = node_rec.map_coord_system_id,
                      md = node_rec.wim_md_std,
                      md_ouom = node_rec.md_ouom,
                      monument_id = node_rec.monument_id,
                      monument_sf_type = node_rec.monument_sf_type,
                      node_position = node_rec.node_position,
                      northing = node_rec.wim_northing_std,
                      northing_ouom = node_rec.northing_ouom,
                      north_type = node_rec.north_type,
                      ns_direction = node_rec.ns_direction,
                      polar_azimuth = node_rec.polar_azimuth,
                      polar_offset = node_rec.wim_polar_offset_std,
                      polar_offset_ouom = node_rec.polar_offset_ouom,
                      ppdm_guid = node_rec.ppdm_guid,
                      preferred_ind = node_rec.preferred_ind,
                      province_state = node_rec.province_state,
                      remark = node_rec.remark,
                      reported_tvd = node_rec.wim_reported_tvd_std,
                      reported_tvd_ouom = node_rec.reported_tvd_ouom,
                      version_type = node_rec.version_type,
                      x_offset = node_rec.wim_x_offset_std,
                      x_offset_ouom = node_rec.x_offset_ouom,
                      y_offset = node_rec.wim_y_offset_std,
                      y_offset_ouom = node_rec.y_offset_ouom,
                      ipl_xaction_code = node_rec.ipl_xaction_code,
                      row_changed_by = node_rec.row_changed_by,
                      -- 1096 - WIM_WELL_ACTION.Well_Node_Version_Process 
                      row_changed_date =  case
                          when node_rec.row_changed_date is null then v_changed_date
                          else node_rec.row_changed_date
                      end,
                      row_created_by = node_rec.row_created_by,
                      row_created_date = node_rec.row_created_date,
                      ipl_uwi = node_rec.ipl_uwi,
                      row_quality = node_rec.row_quality,
                      location_accuracy = node_rec.location_accuracy                      
                WHERE wnv.node_id = node_rec.node_id
                  AND wnv.SOURCE = node_rec.SOURCE
                  AND wnv.node_obs_no = node_rec.node_obs_no
                  AND wnv.geog_coord_system_id = node_rec.geog_coord_system_id
                  AND wnv.location_qualifier = node_rec.location_qualifier;

               IF SQL%ROWCOUNT <> 1
               THEN
                  wim_audit.audit_event
                     (paudit_id        => v_audit_id,
                      paction          => node_rec.wim_action_cd,
                      paudit_type      => 'W',
                      ptlm_id          => node_rec.ipl_uwi,
                      psource          => node_rec.SOURCE,
                      ptext            =>    'Inserted record - No record found for Node version update.'
                                          || node_rec.wim_action_cd,
                      puser            => node_rec.request_created_by
                     );

                  INSERT INTO well_node_version
                              (node_id, SOURCE,
                               node_obs_no, acquisition_id,
                               active_ind, country,
                               county, easting,
                               easting_ouom,
                               effective_date,
                               elev, elev_ouom,
                               ew_direction, expiry_date,
                               geog_coord_system_id,
                               latitude, legal_survey_type,
                               location_qualifier,
                               location_quality, longitude,
                               map_coord_system_id,
                               md, md_ouom,
                               monument_id,
                               monument_sf_type,
                               node_position,
                               northing,
                               northing_ouom, north_type,
                               ns_direction, polar_azimuth,
                               polar_offset,
                               polar_offset_ouom,
                               ppdm_guid, preferred_ind,
                               province_state, remark,
                               reported_tvd,
                               reported_tvd_ouom,
                               version_type,
                               x_offset,
                               x_offset_ouom,
                               y_offset,
                               y_offset_ouom,
                               ipl_xaction_code,
                               row_changed_by,
                               row_changed_date,
                               row_created_by,
                               row_created_date, ipl_uwi,
                               row_quality,
                               location_accuracy                               
                              )
                       VALUES (node_rec.node_id, node_rec.SOURCE,
                               node_rec.node_obs_no, node_rec.acquisition_id,
                               node_rec.active_ind, node_rec.country,
                               node_rec.county, node_rec.wim_easting_std,
                               node_rec.easting_ouom,
                               node_rec.effective_date,
                               node_rec.wim_elev_std, node_rec.elev_ouom,
                               node_rec.ew_direction, node_rec.expiry_date,
                               node_rec.geog_coord_system_id,
                               node_rec.latitude, node_rec.legal_survey_type,
                               node_rec.location_qualifier,
                               node_rec.location_quality, node_rec.longitude,
                               node_rec.map_coord_system_id,
                               node_rec.wim_md_std, node_rec.md_ouom,
                               node_rec.monument_id,
                               node_rec.monument_sf_type,
                               node_rec.node_position,
                               node_rec.wim_northing_std,
                               node_rec.northing_ouom, node_rec.north_type,
                               node_rec.ns_direction, node_rec.polar_azimuth,
                               node_rec.wim_polar_offset_std,
                               node_rec.polar_offset_ouom,
                               node_rec.ppdm_guid, node_rec.preferred_ind,
                               node_rec.province_state, node_rec.remark,
                               node_rec.wim_reported_tvd_std,
                               node_rec.reported_tvd_ouom,
                               node_rec.version_type,
                               node_rec.wim_x_offset_std,
                               node_rec.x_offset_ouom,
                               node_rec.wim_y_offset_std,
                               node_rec.y_offset_ouom,
                               node_rec.ipl_xaction_code,
                               node_rec.row_changed_by,
                               node_rec.row_changed_date,
                               --node_rec.request_created_by,  --row_created_by,
                               --node_rec.request_created_date,
                               node_rec.row_created_by,      --row_created_by,
                               node_rec.row_created_date, node_rec.ipl_uwi,
                               node_rec.row_quality,
                               node_rec.location_accuracy                               
                              );
                              
               END IF;
            WHEN node_rec.wim_action_cd = 'I'
            THEN
               UPDATE well_node_version wnv
                  SET active_ind = 'N',
                      expiry_date = SYSDATE,
                      row_changed_by = node_rec.row_changed_by,
                      row_changed_date =
                                      NVL (node_rec.row_changed_date, SYSDATE)
                WHERE wnv.node_id = node_rec.node_id
                  AND wnv.SOURCE = node_rec.SOURCE
                  AND wnv.node_obs_no = node_rec.node_obs_no
                  AND wnv.geog_coord_system_id = node_rec.geog_coord_system_id
                  AND wnv.location_qualifier = node_rec.location_qualifier;
            WHEN node_rec.wim_action_cd = 'D'
            THEN
               DELETE FROM well_node_version wnv
                     WHERE wnv.node_id = node_rec.node_id
                       AND wnv.SOURCE = node_rec.SOURCE
                       AND wnv.node_obs_no = node_rec.node_obs_no
                       AND wnv.geog_coord_system_id =
                                                 node_rec.geog_coord_system_id
                       AND wnv.location_qualifier =
                                                   node_rec.location_qualifier;
            ELSE
               wim_audit.audit_event (paudit_id        => v_audit_id,
                                      paction          => node_rec.wim_action_cd,
                                      paudit_type      => 'E',
                                      ptlm_id          => node_rec.ipl_uwi,
                                      psource          => node_rec.SOURCE,
                                      ptext            =>    'Unknown action - '
                                                          || node_rec.wim_action_cd,
                                      puser            => node_rec.request_created_by
                                     );
         END CASE;
      END LOOP;
   END;


/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_LICENSE_PROCCESS
Detail:     This procedure updates Well_License table depends on what action_cd is.
    
History of Change:
Sep 25, 2013     Vrajpoot   Added new field RIG_NAME
------------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_license_proccess (pwim_stg_id NUMBER, paudit_id NUMBER)
   IS
      v_license_id   wim_stg_well_license.license_id%TYPE;
      v_count        NUMBER;
      v_audit_id     NUMBER;
   BEGIN
      v_current_action := 'well_license_proccess';

      FOR rec IN (SELECT a.*, b.row_created_by AS request_created_by,
                         b.row_created_date AS request_created_date
                    FROM wim_stg_well_license a INNER JOIN wim_stg_request b
                         ON a.wim_stg_id = b.wim_stg_id
                   WHERE a.wim_stg_id = pwim_stg_id)
      LOOP
         SELECT COUNT (*)
           INTO v_count
           FROM well_license
          WHERE uwi = rec.uwi
            AND license_id = rec.license_id
            AND SOURCE = rec.SOURCE
            AND active_ind <> 'Y';

         IF rec.wim_action_cd IN ('A', 'C', 'U') AND v_count <> 0
         THEN                               /*There is inactive license here*/
            v_audit_id := paudit_id;
            wim_audit.audit_event
                 (paudit_id       => v_audit_id,
                  paction         => 'A',
                  psource         => rec.SOURCE,
                  ptext           =>    'Inactive license already exists for TLM_ID: '
                                     || rec.uwi
                                     || ' and source: '
                                     || rec.SOURCE,
                  ptlm_id         => rec.uwi,
                  pattribute      => 'WIM_STG_WELL_LICENSE.LICENSE_NUM',
                  puser           => rec.request_created_by
                 );
            RETURN;
         END IF;

         SELECT COUNT (*)
           INTO v_count
           FROM well_license
          WHERE uwi = rec.uwi
            AND license_id = rec.license_id
            AND SOURCE = rec.SOURCE;

         CASE
            WHEN rec.wim_action_cd = 'A'
             OR rec.wim_action_cd = 'C'
             OR (rec.wim_action_cd = 'U' AND v_count = 0
                                                        /*Action is update but there is no existing license so we will create license record*/
                )
            THEN
               -- Check the LicenseID
               IF rec.license_id IS NULL
               THEN
                  SELECT rec.uwi
--province_state || rec.license_num
/* We decided to use tlm_id as a new license_id*/
                  INTO   v_license_id
                    FROM wim_stg_well_version
                   WHERE wim_stg_id = pwim_stg_id;

                  UPDATE wim_stg_well_license
                     SET license_id = v_license_id
                   WHERE wim_stg_id = pwim_stg_id;
               END IF;

               INSERT INTO well_license
                           (uwi, license_id,
                            SOURCE, active_ind, AGENT,
                            application_id, authorized_strat_unit_id,
                            bidding_round_num, contractor,
                            direction_to_loc,
                            direction_to_loc_ouom,
                            distance_ref_point,
                            distance_to_loc,
                            distance_to_loc_ouom, drill_rig_num,
                            Rig_Name,
                            drill_slot_no, drill_tool,
                            effective_date, exception_granted,
                            exception_requested, expired_ind,
                            expiry_date, fees_paid_ind, licensee,
                            licensee_contact_id, license_date,
                            license_num, no_of_wells,
                            offshore_completion_type,
                            permit_reference_num,
                            permit_reissue_date, permit_type,
                            platform_name, ppdm_guid,
                            projected_depth,
                            projected_depth_ouom,
                            projected_strat_unit_id,
                            projected_tvd,
                            projected_tvd_ouom, proposed_spud_date,
                            purpose, rate_schedule_id,
                            regulation, regulatory_agency,
                            regulatory_contact_id, remark,
                            rig_code, rig_substr_height,
                            rig_substr_height_ouom, rig_type,
                            section_of_regulation, strat_name_set_id,
                            surveyor, target_objective_fluid,
                            ipl_projected_strat_age, ipl_alt_source,
                            ipl_xaction_code,
                            row_changed_by,
                            row_changed_date,
                            row_created_by,
                            row_created_date, ipl_well_objective,
                            row_quality
                           )
                    VALUES (rec.uwi, NVL (rec.license_id, v_license_id),
                            rec.SOURCE, rec.active_ind, rec.AGENT,
                            rec.application_id, rec.authorized_strat_unit_id,
                            rec.bidding_round_num, rec.contractor,
                            rec.wim_direction_to_loc_std,
                            rec.direction_to_loc_ouom,
                            rec.distance_ref_point,
                            rec.wim_distance_to_loc_std,
                            rec.distance_to_loc_ouom, rec.drill_rig_num,
                            rec.Rig_Name,
                            rec.drill_slot_no, rec.drill_tool,
                            rec.effective_date, rec.exception_granted,
                            rec.exception_requested, rec.expired_ind,
                            rec.expiry_date, rec.fees_paid_ind, rec.licensee,
                            rec.licensee_contact_id, rec.license_date,
                            rec.license_num, rec.no_of_wells,
                            rec.offshore_completion_type,
                            rec.permit_reference_num,
                            rec.permit_reissue_date, rec.permit_type,
                            rec.platform_name, rec.ppdm_guid,
                            rec.wim_projected_depth_std,
                            rec.projected_depth_ouom,
                            rec.projected_strat_unit_id,
                            rec.wim_projected_tvd_std,
                            rec.projected_tvd_ouom, rec.proposed_spud_date,
                            rec.purpose, rec.rate_schedule_id,
                            rec.regulation, rec.regulatory_agency,
                            rec.regulatory_contact_id, rec.remark,
                            rec.rig_code, rec.wim_rig_substr_height_std,
                            rec.rig_substr_height_ouom, rec.rig_type,
                            rec.section_of_regulation, rec.strat_name_set_id,
                            rec.surveyor, rec.target_objective_fluid,
                            rec.ipl_projected_strat_age, rec.ipl_alt_source,
                            rec.ipl_xaction_code,
                            rec.row_changed_by,
                            rec.row_changed_date,
--                            rec.request_created_by,
--                            rec.request_created_date,
                                                 rec.row_created_by,
                            rec.row_created_date, rec.ipl_well_objective,
                            rec.row_quality
                           );
            WHEN rec.wim_action_cd = 'U'
            THEN
               UPDATE well_license
                  SET            --UWI                      = rec.UWI,
                                 --LICENSE_ID               = rec.LICENSE_ID,
                                 --SOURCE                   = rec.SOURCE,
                     active_ind = rec.active_ind,
                     AGENT = rec.AGENT,
                     application_id = rec.application_id,
                     authorized_strat_unit_id = rec.authorized_strat_unit_id,
                     bidding_round_num = rec.bidding_round_num,
                     contractor = rec.contractor,
                     direction_to_loc = rec.wim_direction_to_loc_std,
                     direction_to_loc_ouom = rec.direction_to_loc_ouom,
                     distance_ref_point = rec.distance_ref_point,
                     distance_to_loc = rec.wim_distance_to_loc_std,
                     distance_to_loc_ouom = rec.distance_to_loc_ouom,
                     drill_rig_num = rec.drill_rig_num,
                     Rig_Name = rec.Rig_Name,
                     drill_slot_no = rec.drill_slot_no,
                     drill_tool = rec.drill_tool,
                     effective_date = rec.effective_date,
                     exception_granted = rec.exception_granted,
                     exception_requested = rec.exception_requested,
                     expired_ind = rec.expired_ind,
                     expiry_date = rec.expiry_date,
                     fees_paid_ind = rec.fees_paid_ind,
                     licensee = rec.licensee,
                     licensee_contact_id = rec.licensee_contact_id,
                     license_date = rec.license_date,
                     license_num = rec.license_num,
                     no_of_wells = rec.no_of_wells,
                     offshore_completion_type = rec.offshore_completion_type,
                     permit_reference_num = rec.permit_reference_num,
                     permit_reissue_date = rec.permit_reissue_date,
                     permit_type = rec.permit_type,
                     platform_name = rec.platform_name,
                     ppdm_guid = rec.ppdm_guid,
                     projected_depth = rec.wim_projected_depth_std,
                     projected_depth_ouom = rec.projected_depth_ouom,
                     projected_strat_unit_id = rec.projected_strat_unit_id,
                     projected_tvd = rec.wim_projected_tvd_std,
                     projected_tvd_ouom = rec.projected_tvd_ouom,
                     proposed_spud_date = rec.proposed_spud_date,
                     purpose = rec.purpose,
                     rate_schedule_id = rec.rate_schedule_id,
                     regulation = rec.regulation,
                     regulatory_agency = rec.regulatory_agency,
                     regulatory_contact_id = rec.regulatory_contact_id,
                     remark = rec.remark,
                     rig_code = rec.rig_code,
                     rig_substr_height = rec.wim_rig_substr_height_std,
                     rig_substr_height_ouom = rec.rig_substr_height_ouom,
                     rig_type = rec.rig_type,
                     section_of_regulation = rec.section_of_regulation,
                     strat_name_set_id = rec.strat_name_set_id,
                     surveyor = rec.surveyor,
                     target_objective_fluid = rec.target_objective_fluid,
                     ipl_projected_strat_age = rec.ipl_projected_strat_age,
                     ipl_alt_source = rec.ipl_alt_source,
                     ipl_xaction_code = rec.ipl_xaction_code,
--                     row_changed_by = rec.request_created_by,
--                     row_changed_date = rec.request_created_date,
                     row_changed_by = rec.row_changed_by,
                     row_changed_date = rec.row_changed_date,
                     ROW_CREATED_BY           = rec.ROW_CREATED_BY,
                     ROW_CREATED_DATE         = rec.ROW_CREATED_DATE,
                     ipl_well_objective = rec.ipl_well_objective,
                     row_quality = rec.row_quality
                WHERE uwi = rec.uwi
                  AND license_id = rec.license_id
                  AND SOURCE = rec.SOURCE;
            WHEN rec.wim_action_cd = 'I'
            THEN
               UPDATE well_license
                  SET active_ind = 'N',
                      expiry_date = SYSDATE,
                      row_changed_by = NVL (rec.row_changed_by, USER),
                      row_changed_date = NVL (rec.row_changed_date, SYSDATE)
                WHERE uwi = rec.uwi
                  AND license_id = rec.license_id
                  AND SOURCE = rec.SOURCE;
            WHEN rec.wim_action_cd = 'D'
            THEN
               DELETE FROM well_license
                     WHERE uwi = rec.uwi
                       AND license_id = rec.license_id
                       AND SOURCE = rec.SOURCE;
            ELSE
               v_audit_id := paudit_id;
               wim_audit.audit_event (paudit_id        => v_audit_id,
                                      paction          => rec.wim_action_cd,
                                      paudit_type      => 'E',
                                      ptlm_id          => rec.uwi,
                                      psource          => rec.SOURCE,
                                      ptext            =>    'Unknown action - '
                                                          || rec.wim_action_cd,
                                      puser            => rec.request_created_by
                                     );
         END CASE;
      END LOOP;
   END;

/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_NODE_M_B_PROCCESS
Detail:     This procedure updates Well_Node_M_B table depends on what action_cd is.
    
History of Change:
------------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_node_m_b_proccess (pwim_stg_id NUMBER, paudit_id NUMBER)
   IS
      v_audit_id   NUMBER;
   BEGIN
      v_current_action := 'well_node_m_b_proccess';

      FOR rec IN (SELECT   a.*, b.row_created_by AS request_created_by,
                           b.row_created_date AS request_created_date
                      FROM wim_stg_well_node_m_b a INNER JOIN wim_stg_request b
                           ON a.wim_stg_id = b.wim_stg_id
                     WHERE a.wim_stg_id = pwim_stg_id
                  ORDER BY wim_seq)
      LOOP
         CASE
            WHEN rec.wim_action_cd = 'A' OR rec.wim_action_cd = 'C'
            THEN
               INSERT INTO well_node_m_b
                           (node_id, SOURCE, active_ind,
                            dls_road_allowance_id, effective_date,
                            ew_direction, ew_distance,
                            ew_distance_ouom, ew_start_line,
                            expiry_date, location_type,
                            ns_direction, ns_distance,
                            ns_distance_ouom, ns_start_line,
                            orientation, parcel_carter_id,
                            parcel_congress_id, parcel_dls_id,
                            parcel_fps_id, parcel_ne_loc_id,
                            parcel_north_sea_id, parcel_nts_id,
                            parcel_offshore_id, parcel_ohio_id,
                            parcel_pbl_id, parcel_texas,
                            ppdm_guid, reference_loc, remark,
                            surface_loc, ipl_uwi,
                            ipl_alt_source, ipl_xaction_code,
                            row_changed_by,
                            row_changed_date,
                            row_created_by, row_created_date,
                            row_quality
                           )
                    VALUES (rec.node_id, rec.SOURCE, rec.active_ind,
                            rec.dls_road_allowance_id, rec.effective_date,
                            rec.ew_direction, rec.wim_ew_distance_std,
                            rec.ew_distance_ouom, rec.ew_start_line,
                            rec.expiry_date, rec.location_type,
                            rec.ns_direction, rec.wim_ns_distance_std,
                            rec.ns_distance_ouom, rec.ns_start_line,
                            rec.orientation, rec.parcel_carter_id,
                            rec.parcel_congress_id, rec.parcel_dls_id,
                            rec.parcel_fps_id, rec.parcel_ne_loc_id,
                            rec.parcel_north_sea_id, rec.parcel_nts_id,
                            rec.parcel_offshore_id, rec.parcel_ohio_id,
                            rec.parcel_pbl_id, rec.parcel_texas,
                            rec.ppdm_guid, rec.reference_loc, rec.remark,
                            rec.surface_loc, rec.ipl_uwi,
                            rec.ipl_alt_source, rec.ipl_xaction_code,
                            rec.row_changed_by,
                            rec.row_changed_date,
                            rec.row_created_by, rec.row_created_date,
                            rec.row_quality
                           );
            WHEN rec.wim_action_cd = 'U'
            THEN
               UPDATE well_node_m_b
                  SET node_id = rec.node_id,
                      SOURCE = rec.SOURCE,
                      active_ind = rec.active_ind,
                      dls_road_allowance_id = rec.dls_road_allowance_id,
                      effective_date = rec.effective_date,
                      ew_direction = rec.ew_direction,
                      ew_distance = rec.wim_ew_distance_std,
                      ew_distance_ouom = rec.ew_distance_ouom,
                      ew_start_line = rec.ew_start_line,
                      expiry_date = rec.expiry_date,
                      location_type = rec.location_type,
                      ns_direction = rec.ns_direction,
                      ns_distance = rec.wim_ns_distance_std,
                      ns_distance_ouom = rec.ns_distance_ouom,
                      ns_start_line = rec.ns_start_line,
                      orientation = rec.orientation,
                      parcel_carter_id = rec.parcel_carter_id,
                      parcel_congress_id = rec.parcel_congress_id,
                      parcel_dls_id = rec.parcel_dls_id,
                      parcel_fps_id = rec.parcel_fps_id,
                      parcel_ne_loc_id = rec.parcel_ne_loc_id,
                      parcel_north_sea_id = rec.parcel_north_sea_id,
                      parcel_nts_id = rec.parcel_nts_id,
                      parcel_offshore_id = rec.parcel_offshore_id,
                      parcel_ohio_id = rec.parcel_ohio_id,
                      parcel_pbl_id = rec.parcel_pbl_id,
                      parcel_texas = rec.parcel_texas,
                      ppdm_guid = rec.ppdm_guid,
                      reference_loc = rec.reference_loc,
                      remark = rec.remark,
                      surface_loc = rec.surface_loc,
                      ipl_uwi = rec.ipl_uwi,
                      ipl_alt_source = rec.ipl_alt_source,
                      ipl_xaction_code = rec.ipl_xaction_code,
                      row_changed_by = rec.row_changed_by,
                      row_changed_date = rec.row_changed_date,
                      row_created_by = rec.row_created_by,
                      row_created_date = rec.row_created_date,
                      row_quality = rec.row_quality
                WHERE node_id = rec.node_id
                  AND SOURCE = rec.SOURCE
                  AND ipl_uwi = rec.ipl_uwi;

               IF SQL%ROWCOUNT <> 1
               THEN
                  wim_audit.audit_event
                         (paudit_id        => v_audit_id,
                          paction          => rec.wim_action_cd,
                          paudit_type      => 'W',
                          ptlm_id          => rec.ipl_uwi,
                          psource          => rec.SOURCE,
                          ptext            =>    'No record found for Node M/B update.'
                                              || rec.wim_action_cd,
                          puser            => rec.request_created_by
                         );
               END IF;
            WHEN rec.wim_action_cd = 'I'
            THEN
               UPDATE well_node_m_b
                  SET active_ind = 'N',
                      expiry_date = SYSDATE,
                      row_changed_by = NVL (rec.row_changed_by, USER),
                      row_changed_date = NVL (rec.row_changed_date, SYSDATE)
                WHERE node_id = rec.node_id
                  AND SOURCE = rec.SOURCE
                  AND ipl_uwi = rec.ipl_uwi;
            WHEN rec.wim_action_cd = 'D'
            THEN
               DELETE FROM well_node_m_b
                     WHERE node_id = rec.node_id
                       AND SOURCE = rec.SOURCE
                       AND ipl_uwi = rec.ipl_uwi;
            ELSE
               v_audit_id := paudit_id;
               wim_audit.audit_event (paudit_id        => v_audit_id,
                                      paction          => rec.wim_action_cd,
                                      paudit_type      => 'E',
                                      ptlm_id          => rec.ipl_uwi,
                                      psource          => rec.SOURCE,
                                      ptext            =>    'Unknown action - '
                                                          || rec.wim_action_cd,
                                      puser            => rec.request_created_by
                                     );
         END CASE;
      END LOOP;
   END;

/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_STATUS_PROCCESS
Detail:     This procedure updates Well_Status table depends on what action_cd is.
    
History of Change:
---------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_status_proccess (pwim_stg_id NUMBER, paudit_id NUMBER)
   IS
      v_audit_id   NUMBER;
   BEGIN
      v_current_action := 'well_status_proccess';

      FOR rec IN (SELECT   a.*, b.row_created_by AS request_created_by,
                           b.row_created_date AS request_created_date
                      FROM wim_stg_well_status a INNER JOIN wim_stg_request b
                           ON a.wim_stg_id = b.wim_stg_id
                     WHERE a.wim_stg_id = pwim_stg_id
                  ORDER BY wim_seq)
      LOOP
         CASE
            WHEN rec.wim_action_cd = 'A' OR rec.wim_action_cd = 'C'
            THEN
               INSERT INTO well_status
                           (uwi, SOURCE, status_id,
                            active_ind, effective_date,
                            expiry_date, ppdm_guid, remark,
                            status, status_date,
                            status_depth, status_depth_ouom,
                            ipl_xaction_code, status_type,
                            row_changed_by,
                            row_changed_date,
                            row_created_by, row_created_date,
                            row_quality
                           )
                    VALUES (rec.uwi, rec.SOURCE, rec.status_id,
                            rec.active_ind, rec.effective_date,
                            rec.expiry_date, rec.ppdm_guid, rec.remark,
                            rec.status, rec.status_date,
                            rec.wim_status_depth_std, rec.status_depth_ouom,
                            rec.ipl_xaction_code, rec.status_type,
                            rec.row_changed_by,
                            rec.row_changed_date,
                            rec.row_created_by, rec.row_created_date,
                            rec.row_quality
                           );
            WHEN rec.wim_action_cd = 'U'
            THEN
               UPDATE well_status
                  SET uwi = rec.uwi,
                      SOURCE = rec.SOURCE,
                      status_id = rec.status_id,
                      active_ind = rec.active_ind,
                      effective_date = rec.effective_date,
                      expiry_date = rec.expiry_date,
                      ppdm_guid = rec.ppdm_guid,
                      remark = rec.remark,
                      status = rec.status,
                      status_date = rec.status_date,
                      status_depth = rec.wim_status_depth_std,
                      status_depth_ouom = rec.status_depth_ouom,
                      ipl_xaction_code = rec.ipl_xaction_code,
                      status_type = rec.status_type,
                      row_changed_by = rec.row_changed_by,
                      row_changed_date = rec.row_changed_date,
                      row_created_by = rec.row_created_by,
                      row_created_date = rec.row_created_date,
                      row_quality = rec.row_quality
                WHERE uwi = rec.uwi
                  AND SOURCE = rec.SOURCE
                  AND status_id = rec.status_id;

               IF SQL%ROWCOUNT <> 1
               THEN
                  wim_audit.audit_event
                      (paudit_id        => v_audit_id,
                       paction          => rec.wim_action_cd,
                       paudit_type      => 'W',
                       ptlm_id          => rec.uwi,
                       psource          => rec.SOURCE,
                       ptext            =>    'No record found for well status update.'
                                           || rec.wim_action_cd,
                       puser            => rec.request_created_by
                      );
               END IF;
            WHEN rec.wim_action_cd = 'I'
            THEN
               UPDATE well_status
                  SET active_ind = 'N',
                      expiry_date = SYSDATE,
                      row_changed_by = NVL (rec.row_changed_by, USER),
                      row_changed_date = NVL (rec.row_changed_date, SYSDATE)
                WHERE uwi = rec.uwi
                  AND SOURCE = rec.SOURCE
                  AND status_id = rec.status_id;
            WHEN rec.wim_action_cd = 'D'
            THEN
               DELETE FROM well_status
                     WHERE uwi = rec.uwi
                       AND SOURCE = rec.SOURCE
                       AND status_id = rec.status_id;
            ELSE
               v_audit_id := paudit_id;
               wim_audit.audit_event (paudit_id        => v_audit_id,
                                      paction          => rec.wim_action_cd,
                                      paudit_type      => 'E',
                                      ptlm_id          => rec.uwi,
                                      psource          => rec.SOURCE,
                                      ptext            =>    'Unknown action - '
                                                          || rec.wim_action_cd,
                                      puser            => rec.request_created_by
                                     );
         END CASE;
      END LOOP;
   END well_status_proccess;


/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_UPDATE
Detail:     This procedure updates WELL_VERSION table.
            And calls Child table procedures to update well_node_Version, well_license and well_status tables.
            And it also adds alias to well_alias table
            
            Calls:
            ADD_ALIAS
            WELL_NODE_VERSION_PROCCESS
            WELL_NODE_M_B_PROCCESS
            WELL_LICENSE_PROCCESS
            WELL_STATUS_PROCCESS
    
History of Change:
July 29, 2013   V.Rajpoot   Added new atribute Location_Accuracy to Update and Inserts
---------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_action_update (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_uwi                    wim_stg_well_version.uwi%TYPE;
      v_source                 wim_stg_well_version.SOURCE%TYPE;
      v_well_name              well_version.well_name%TYPE;
      v_plot_name              well_version.plot_name%TYPE;
      v_ipl_uwi_local          well_version.ipl_uwi_local%TYPE;
      v_well_num               well_version.well_num%TYPE;
      v_country                well_version.country%TYPE;
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      v_current_action := 'well_action_update';

      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      --  Capture pre-update well values for alias creation
      SELECT well_name, plot_name, ipl_uwi_local, country, well_num
        INTO v_well_name, v_plot_name, v_ipl_uwi_local, v_country, v_well_num
        FROM well_version
       WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;

      -- Update the well - Blind update, no way of telling which attributes have changed
      UPDATE well_version wv
         SET
--               UWI                            = pWell_version.UWI,
--               SOURCE                         = pWell_Version.Source,
             abandonment_date = pwell_version.abandonment_date,
             active_ind = pwell_version.active_ind,
             assigned_field = pwell_version.assigned_field,
             base_node_id = pwell_version.base_node_id,
             bottom_hole_latitude = pwell_version.bottom_hole_latitude,
             bottom_hole_longitude = pwell_version.bottom_hole_longitude,
             casing_flange_elev = pwell_version.wim_casing_flange_elev_std,
             casing_flange_elev_ouom = pwell_version.casing_flange_elev_ouom,
             completion_date = pwell_version.completion_date,
             confidential_date = pwell_version.confidential_date,
             confidential_depth = pwell_version.wim_confidential_depth_std,
             confidential_depth_ouom = pwell_version.confidential_depth_ouom,
             confidential_type = pwell_version.confidential_type,
             confid_strat_name_set_id = pwell_version.confid_strat_name_set_id,
             confid_strat_unit_id = pwell_version.confid_strat_unit_id,
             country = pwell_version.country,
             county = pwell_version.county,
             current_class = pwell_version.current_class,
             current_status = pwell_version.current_status,
             current_status_date = pwell_version.current_status_date,
             deepest_depth = pwell_version.wim_deepest_depth_std,
             deepest_depth_ouom = pwell_version.deepest_depth_ouom,
             depth_datum = pwell_version.depth_datum,
             depth_datum_elev = pwell_version.wim_depth_datum_elev_std,
             depth_datum_elev_ouom = pwell_version.depth_datum_elev_ouom,
             derrick_floor_elev = pwell_version.wim_derrick_floor_elev_std,
             derrick_floor_elev_ouom = pwell_version.derrick_floor_elev_ouom,
             difference_lat_msl = pwell_version.difference_lat_msl,
             discovery_ind = pwell_version.discovery_ind,
             district = pwell_version.district,
             drill_td = pwell_version.wim_drill_td_std,
             drill_td_ouom = pwell_version.drill_td_ouom,
             effective_date = pwell_version.effective_date,
             elev_ref_datum = pwell_version.elev_ref_datum,
             expiry_date = pwell_version.expiry_date,
             faulted_ind = pwell_version.faulted_ind,
             final_drill_date = pwell_version.final_drill_date,
             final_td = pwell_version.wim_final_td_std,
             final_td_ouom = pwell_version.final_td_ouom,
             geographic_region = pwell_version.geographic_region,
             geologic_province = pwell_version.geologic_province,
             ground_elev = pwell_version.wim_ground_elev_std,
             ground_elev_ouom = pwell_version.ground_elev_ouom,
             ground_elev_type = pwell_version.ground_elev_type,
             initial_class = pwell_version.initial_class,
             kb_elev = pwell_version.wim_kb_elev_std,
             kb_elev_ouom = pwell_version.kb_elev_ouom,
             lease_name = pwell_version.lease_name,
             lease_num = pwell_version.lease_num,
             legal_survey_type = pwell_version.legal_survey_type,
             location_type = pwell_version.location_type,
             log_td = pwell_version.wim_log_td_std,
             log_td_ouom = pwell_version.log_td_ouom,
             max_tvd = pwell_version.wim_max_tvd_std,
             max_tvd_ouom = pwell_version.max_tvd_ouom,
             net_pay = pwell_version.wim_net_pay_std,
             net_pay_ouom = pwell_version.net_pay_ouom,
             oldest_strat_age = pwell_version.oldest_strat_age,
             oldest_strat_name_set_age =
                                       pwell_version.oldest_strat_name_set_age,
             oldest_strat_name_set_id = pwell_version.oldest_strat_name_set_id,
             oldest_strat_unit_id = pwell_version.oldest_strat_unit_id,
             OPERATOR = pwell_version.OPERATOR,
             parent_relationship_type = pwell_version.parent_relationship_type,
             parent_uwi = pwell_version.parent_uwi,
             platform_id = pwell_version.platform_id,
             platform_sf_type = pwell_version.platform_sf_type,
             plot_name = pwell_version.plot_name,
             plot_symbol = pwell_version.plot_symbol,
             plugback_depth = pwell_version.wim_plugback_depth_std,
             plugback_depth_ouom = pwell_version.plugback_depth_ouom,
             ppdm_guid = pwell_version.ppdm_guid,
             profile_type = pwell_version.profile_type,
             province_state = pwell_version.province_state,
             regulatory_agency = pwell_version.regulatory_agency,
             remark = pwell_version.remark,
             rig_on_site_date = pwell_version.rig_on_site_date,
             rig_release_date = pwell_version.rig_release_date,
             rotary_table_elev = pwell_version.rotary_table_elev,
             source_document = pwell_version.source_document,
             spud_date = pwell_version.spud_date,
             status_type = pwell_version.status_type,
             subsea_elev_ref_type = pwell_version.subsea_elev_ref_type,
             surface_latitude = pwell_version.surface_latitude,
             surface_longitude = pwell_version.surface_longitude,
             surface_node_id = pwell_version.surface_node_id,
             tax_credit_code = pwell_version.tax_credit_code,
             td_strat_age = pwell_version.td_strat_age,
             td_strat_name_set_age = pwell_version.td_strat_name_set_age,
             td_strat_name_set_id = pwell_version.td_strat_name_set_id,
             td_strat_unit_id = pwell_version.td_strat_unit_id,
             water_acoustic_vel = pwell_version.water_acoustic_vel,
             water_acoustic_vel_ouom = pwell_version.water_acoustic_vel_ouom,
             water_depth = pwell_version.wim_water_depth_std,
             water_depth_datum = pwell_version.water_depth_datum,
             water_depth_ouom = pwell_version.water_depth_ouom,
             well_event_num = pwell_version.well_event_num,
             well_government_id = pwell_version.well_government_id,
             well_intersect_md = pwell_version.well_intersect_md,
             well_name = pwell_version.well_name,
             well_num = pwell_version.well_num,
             well_numeric_id = pwell_version.well_numeric_id,
             whipstock_depth = pwell_version.wim_whipstock_depth_std,
             whipstock_depth_ouom = pwell_version.whipstock_depth_ouom,
             ipl_licensee = pwell_version.ipl_licensee,
             ipl_offshore_ind = pwell_version.ipl_offshore_ind,
             ipl_pidstatus = pwell_version.ipl_pidstatus,
             ipl_prstatus = pwell_version.ipl_prstatus,
             ipl_orstatus = pwell_version.ipl_orstatus,
             ipl_onprod_date = pwell_version.ipl_onprod_date,
             ipl_oninject_date = pwell_version.ipl_oninject_date,
             ipl_confidential_strat_age =
                                      pwell_version.ipl_confidential_strat_age,
             ipl_pool = pwell_version.ipl_pool,
             ipl_last_update = pwell_version.ipl_last_update,
             ipl_uwi_sort = pwell_version.ipl_uwi_sort,
             ipl_uwi_display = pwell_version.ipl_uwi_display,
             ipl_td_tvd = pwell_version.ipl_td_tvd,
             ipl_plugback_tvd = pwell_version.ipl_plugback_tvd,
             ipl_whipstock_tvd = pwell_version.ipl_whipstock_tvd,
             ipl_water_tvd = pwell_version.ipl_water_tvd,
             ipl_alt_source = pwell_version.ipl_alt_source,
             ipl_xaction_code = pwell_version.ipl_xaction_code,
             row_changed_by = pwell_version.row_changed_by,
             row_changed_date = pwell_version.row_changed_date,
               ROW_CREATED_BY                 = pWell_Version.ROW_CREATED_BY,
               ROW_CREATED_DATE               = pWell_Version.ROW_CREATED_DATE,
             ipl_basin = pwell_version.ipl_basin,
             ipl_block = pwell_version.ipl_block,
             ipl_area = pwell_version.ipl_area,
             ipl_twp = pwell_version.ipl_twp,
             ipl_tract = pwell_version.ipl_tract,
             ipl_lot = pwell_version.ipl_lot,
             ipl_conc = pwell_version.ipl_conc,
             ipl_uwi_local = pwell_version.ipl_uwi_local,
             row_quality = pwell_version.row_quality,
             surface_location_accuracy = pwell_version.surface_location_accuracy,
             bottom_hole_location_accuracy = pwell_version.bottom_hole_location_accuracy
       WHERE wv.uwi = pwell_version.uwi AND wv.SOURCE = pwell_version.SOURCE;

      --  Update License
      well_license_proccess (pwim_stg_id, paudit_id);
      --  Update the nodes if required (NOTE: Will ignore any nodes with an action of NULL)
      well_node_version_proccess (pwim_stg_id, paudit_id);
      well_node_m_b_proccess (pwim_stg_id, paudit_id);
      -- Update/add any new status records for this well
      well_status_proccess (pwim_stg_id, paudit_id);

      -- Apply alias changes
      -- Add Well_Name alias if the name has changed
     
     --If well_name is Null before, there will be no alias added because well_alias can not be Null.
     --If well_name is not null and changed to some value, alias will be added
     --If well_name is not null and changed to null, alias will be added.
       IF ( v_well_name != pwell_version.well_name OR
         --   (v_well_name is null and pwell_version.well_name is not null) or
            (v_well_name is not null and pwell_version.well_name is null) )
    
      THEN
         add_alias (pwell_version.uwi,
                    pwell_version.SOURCE,
                    'WELL_NAME',
                    v_well_name,
                    'Update',
                    v_request_created_by
                   );
      END IF;

      --  Add PLOT_NAME alias if the plot name has changed
     
     --If plot_name is Null before, there will no alias added because well_alias can not be Null.
     --If plot_name is not null and change to some value, alias will be added
     --If plot_name is not null and change to null, alias will be added.     
       IF ( v_plot_name != pwell_version.plot_name OR
            --(v_plot_name is null and pwell_version.plot_name is not null) ) or
                (v_plot_name is not null and pwell_version.plot_name is null) )
    
      THEN
         add_alias (pwell_version.uwi,
                    pwell_version.SOURCE,
                    'PLOT_NAME',
                    v_plot_name,
                    'Update',
                    v_request_created_by
                   );
      END IF;

      --  Add WELL_NUM alias if the WELL_NUM has changed
     --If well_num is Null before, there will no alias added because well_alias can not be Null.
     --If well_num is not null and change to some value, alias will be added
     --If well_num is not null and change to null, alias will be added.
         IF ( v_well_num != pwell_version.well_num OR
           -- (v_well_num is null and pwell_version.well_num is not null) or
            (v_well_num is not null and pwell_version.well_num is null) )
   
      THEN
         add_alias (pwell_version.uwi,
                    pwell_version.SOURCE,
                    'WELL_NUM',
                    v_well_num,
                    'Update',
                    v_request_created_by
                   );
      END IF;

      --  Add UWI alias if the UWI has changed
      --If ipl_uwi_local is Null before, there will no alias added because well_alias can not be Null.
     --If ipl_uwi_local is not null and change to some value, alias will be added
     --If ipl_uwi_local is not null and change to null, alias will be added.
      IF ( v_ipl_uwi_local != pwell_version.ipl_uwi_local OR
           -- (v_ipl_uwi_local is null and     pwell_version.ipl_uwi_local is not null) or
            (v_ipl_uwi_local is not null and pwell_version.ipl_uwi_local is null) )
    
      THEN
         add_alias (pwell_version.uwi,
                    pwell_version.SOURCE,
                    'UWI',
                    v_ipl_uwi_local,
                    'Update',
                    v_request_created_by
                   );
      END IF;

      --  Add COUNTRY alias if the UWI has changed
     --If country is Null before, there will no alias added because well_alias can not be Null.
     --If country is not null and change to some value, alias will be added
     --If country is not null and change to null, alias will be added.
        IF ( v_country != pwell_version.country OR
          --  (v_country is null and pwell_version.country is not null) or
            (v_country is not null and pwell_version.country is null) )
   
      THEN
         add_alias (pwell_version.uwi,
                    pwell_version.SOURCE,
                    'COUNTRY',
                    v_country,
                    'Update',
                    v_request_created_by
                   );
      END IF;
   END well_action_update;

/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_CREATE
Detail:     This procedure creates a new well in well_Version table
            And calls Child table procedures to update well_node_Version, well_license and well_status tables.
                      
            Calls:            
            WELL_NODE_VERSION_PROCCESS
            WELL_NODE_M_B_PROCCESS
            WELL_LICENSE_PROCCESS
            WELL_STATUS_PROCCESS
            
History of Change:
July 29, 2013   V.Rajpoot   Added new atribute Location_Accuracy to Inserts
---------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_action_create (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      v_current_action := 'well_action_create';

      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      INSERT INTO well_version
                  (uwi, SOURCE,
                   abandonment_date, active_ind,
                   assigned_field, base_node_id,
                   bottom_hole_latitude,
                   bottom_hole_longitude,
                   casing_flange_elev,
                   casing_flange_elev_ouom,
                   completion_date,
                   confidential_date,
                   confidential_depth,
                   confidential_depth_ouom,
                   confidential_type,
                   confid_strat_name_set_id,
                   confid_strat_unit_id, country,
                   county, current_class,
                   current_status,
                   current_status_date,
                   deepest_depth,
                   deepest_depth_ouom,
                   depth_datum,
                   depth_datum_elev,
                   depth_datum_elev_ouom,
                   derrick_floor_elev,
                   derrick_floor_elev_ouom,
                   difference_lat_msl,
                   discovery_ind, district,
                   drill_td,
                   drill_td_ouom, effective_date,
                   elev_ref_datum, expiry_date,
                   faulted_ind, final_drill_date,
                   final_td,
                   final_td_ouom,
                   geographic_region,
                   geologic_province,
                   ground_elev,
                   ground_elev_ouom,
                   ground_elev_type,
                   initial_class,
                   kb_elev, kb_elev_ouom,
                   lease_name, lease_num,
                   legal_survey_type,
                   location_type, log_td,
                   log_td_ouom, max_tvd,
                   max_tvd_ouom, net_pay,
                   net_pay_ouom,
                   oldest_strat_age,
                   oldest_strat_name_set_age,
                   oldest_strat_name_set_id,
                   oldest_strat_unit_id,
                   OPERATOR,
                   parent_relationship_type,
                   parent_uwi, platform_id,
                   platform_sf_type, plot_name,
                   plot_symbol,
                   plugback_depth,
                   plugback_depth_ouom,
                   ppdm_guid, profile_type,
                   province_state,
                   regulatory_agency, remark,
                   rig_on_site_date,
                   rig_release_date,
                   rotary_table_elev,
                   source_document, spud_date,
                   status_type,
                   subsea_elev_ref_type,
                   surface_latitude,
                   surface_longitude,
                   surface_node_id,
                   tax_credit_code, td_strat_age,
                   td_strat_name_set_age,
                   td_strat_name_set_id,
                   td_strat_unit_id,
                   water_acoustic_vel,
                   water_acoustic_vel_ouom,
                   water_depth,
                   water_depth_datum,
                   water_depth_ouom,
                   well_event_num,
                   well_government_id,
                   well_intersect_md, well_name,
                   well_num, well_numeric_id,
                   whipstock_depth,
                   whipstock_depth_ouom,
                   ipl_licensee,
                   ipl_offshore_ind,
                   ipl_pidstatus, ipl_prstatus,
                   ipl_orstatus, ipl_onprod_date,
                   ipl_oninject_date,
                   ipl_confidential_strat_age,
                   ipl_pool, ipl_last_update,
                   ipl_uwi_sort, ipl_uwi_display,
                   ipl_td_tvd, ipl_plugback_tvd,
                   ipl_whipstock_tvd,
                   ipl_water_tvd, ipl_alt_source,
                   ipl_xaction_code,
                   row_changed_by,
                   row_changed_date,
                   row_created_by,
                   row_created_date, ipl_basin,
                   ipl_block, ipl_area,
                   ipl_twp, ipl_tract,
                   ipl_lot, ipl_conc,
                   ipl_uwi_local, row_quality, surface_location_accuracy,bottom_hole_location_accuracy
                  )
           VALUES (pwell_version.uwi, pwell_version.SOURCE,
                   pwell_version.abandonment_date, pwell_version.active_ind,
                   pwell_version.assigned_field, pwell_version.base_node_id,
                   pwell_version.bottom_hole_latitude,
                   pwell_version.bottom_hole_longitude,
                   pwell_version.wim_casing_flange_elev_std,
                   pwell_version.casing_flange_elev_ouom,
                   pwell_version.completion_date,
                   pwell_version.confidential_date,
                   pwell_version.wim_confidential_depth_std,
                   pwell_version.confidential_depth_ouom,
                   pwell_version.confidential_type,
                   pwell_version.confid_strat_name_set_id,
                   pwell_version.confid_strat_unit_id, pwell_version.country,
                   pwell_version.county, pwell_version.current_class,
                   pwell_version.current_status,
                   pwell_version.current_status_date,
                   pwell_version.wim_deepest_depth_std,
                   pwell_version.deepest_depth_ouom,
                   pwell_version.depth_datum,
                   pwell_version.wim_depth_datum_elev_std,
                   pwell_version.depth_datum_elev_ouom,
                   pwell_version.wim_derrick_floor_elev_std,
                   pwell_version.derrick_floor_elev_ouom,
                   pwell_version.difference_lat_msl,
                   pwell_version.discovery_ind, pwell_version.district,
                   pwell_version.wim_drill_td_std,
                   pwell_version.drill_td_ouom, pwell_version.effective_date,
                   pwell_version.elev_ref_datum, pwell_version.expiry_date,
                   pwell_version.faulted_ind, pwell_version.final_drill_date,
                   pwell_version.wim_final_td_std,
                   pwell_version.final_td_ouom,
                   pwell_version.geographic_region,
                   pwell_version.geologic_province,
                   pwell_version.wim_ground_elev_std,
                   pwell_version.ground_elev_ouom,
                   pwell_version.ground_elev_type,
                   pwell_version.initial_class,
                   pwell_version.wim_kb_elev_std, pwell_version.kb_elev_ouom,
                   pwell_version.lease_name, pwell_version.lease_num,
                   pwell_version.legal_survey_type,
                   pwell_version.location_type, pwell_version.wim_log_td_std,
                   pwell_version.log_td_ouom, pwell_version.wim_max_tvd_std,
                   pwell_version.max_tvd_ouom, pwell_version.wim_net_pay_std,
                   pwell_version.net_pay_ouom,
                   pwell_version.oldest_strat_age,
                   pwell_version.oldest_strat_name_set_age,
                   pwell_version.oldest_strat_name_set_id,
                   pwell_version.oldest_strat_unit_id,
                   pwell_version.OPERATOR,
                   pwell_version.parent_relationship_type,
                   pwell_version.parent_uwi, pwell_version.platform_id,
                   pwell_version.platform_sf_type, pwell_version.plot_name,
                   pwell_version.plot_symbol,
                   pwell_version.wim_plugback_depth_std,
                   pwell_version.plugback_depth_ouom,
                   pwell_version.ppdm_guid, pwell_version.profile_type,
                   pwell_version.province_state,
                   pwell_version.regulatory_agency, pwell_version.remark,
                   pwell_version.rig_on_site_date,
                   pwell_version.rig_release_date,
                   pwell_version.rotary_table_elev,
                   pwell_version.source_document, pwell_version.spud_date,
                   pwell_version.status_type,
                   pwell_version.subsea_elev_ref_type,
                   pwell_version.surface_latitude,
                   pwell_version.surface_longitude,
                   pwell_version.surface_node_id,
                   pwell_version.tax_credit_code, pwell_version.td_strat_age,
                   pwell_version.td_strat_name_set_age,
                   pwell_version.td_strat_name_set_id,
                   pwell_version.td_strat_unit_id,
                   pwell_version.water_acoustic_vel,
                   pwell_version.water_acoustic_vel_ouom,
                   pwell_version.wim_water_depth_std,
                   pwell_version.water_depth_datum,
                   pwell_version.water_depth_ouom,
                   pwell_version.well_event_num,
                   pwell_version.well_government_id,
                   pwell_version.well_intersect_md, pwell_version.well_name,
                   pwell_version.well_num, pwell_version.well_numeric_id,
                   pwell_version.wim_whipstock_depth_std,
                   pwell_version.whipstock_depth_ouom,
                   pwell_version.ipl_licensee,
                   pwell_version.ipl_offshore_ind,
                   pwell_version.ipl_pidstatus, pwell_version.ipl_prstatus,
                   pwell_version.ipl_orstatus, pwell_version.ipl_onprod_date,
                   pwell_version.ipl_oninject_date,
                   pwell_version.ipl_confidential_strat_age,
                   pwell_version.ipl_pool, pwell_version.ipl_last_update,
                   pwell_version.ipl_uwi_sort, pwell_version.ipl_uwi_display,
                   pwell_version.ipl_td_tvd, pwell_version.ipl_plugback_tvd,
                   pwell_version.ipl_whipstock_tvd,
                   pwell_version.ipl_water_tvd, pwell_version.ipl_alt_source,
                   pwell_version.ipl_xaction_code,
                   pwell_version.row_changed_by,
                   pwell_version.row_changed_date,
                   pwell_version.row_created_by,
                   pwell_version.row_created_date, pwell_version.ipl_basin,
                   pwell_version.ipl_block, pwell_version.ipl_area,
                   pwell_version.ipl_twp, pwell_version.ipl_tract,
                   pwell_version.ipl_lot, pwell_version.ipl_conc,
                   pwell_version.ipl_uwi_local, pwell_version.row_quality,
                   pwell_version.surface_location_accuracy,
                   pwell_version.bottom_hole_location_accuracy
                  );

      --DBMS_OUTPUT.put_line ('well_licence_proccess');
      well_license_proccess (pwim_stg_id, paudit_id);
      --DBMS_OUTPUT.put_line ('well_node_version_proccess');
      well_node_version_proccess (pwim_stg_id, paudit_id);
      --DBMS_OUTPUT.put_line ('well_node_m_b_proccess');
      well_node_m_b_proccess (pwim_stg_id, paudit_id);
      --DBMS_OUTPUT.put_line ('well_status_proccess');
      well_status_proccess (pwim_stg_id, paudit_id);
   END well_action_create;

/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_DELETE
Detail:     This procedure deletes a well from well_version, and its child tables (without going thru staging tables )
             
                        
History of Change:
---------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_delete (
      ptlm_id   well_version.uwi%type,
      psource   well_version.source%type      
   )
   IS
      v_count      NUMBER;
      v_audit_id   NUMBER;
      
   BEGIN
 
      v_current_action := 'well_delete';

      --  Physically Delete the well version
      DELETE FROM well_version
            WHERE uwi = ptlm_id
              AND SOURCE = psource
      ;

      IF SQL%ROWCOUNT <> 1
      THEN
         raise_application_error (-20000,
                                  'Version does not exist.',
                                  TRUE
                                 );
      END IF;

      --  Physically Delete the associated aliases
      DELETE FROM well_alias
            WHERE uwi = ptlm_id AND SOURCE = psource;

      --  Physically delete the Well Version License
      DELETE FROM well_license
            WHERE uwi = ptlm_id AND SOURCE = psource;

      --  Physically delete the Well Version Nodes
      DELETE FROM well_node_version
            WHERE ipl_uwi = ptlm_id AND SOURCE = psource;

      --  Physically delete the Well Version Nodes MBs
      DELETE FROM well_node_m_b
            WHERE ipl_uwi = ptlm_id
                  AND SOURCE = psource;

      --  Physically delete the Well Statuses
      DELETE FROM well_status
            WHERE uwi = ptlm_id AND SOURCE = psource;
            
      --  Add a new ALIAS to show the DELETE
      wim.wim_well_action.add_alias(
          ptlm_id => ptlm_id
          , psource => psource
          , palias_type => 'DEL'
          , palias_value => ptlm_id
          , preason_type => 'Deleted'
          , puser => user
      );            
   END;
   
  
/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_ADD
Detail:     This procedure add a new well by calling WELL_ACTION_CREATE procedure
            and modify any exisitng ACTIVE aliases that redirect this version to another well
                      
            Calls:            
            WELL_ACTION_CREATE
            
History of Change:
---------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_action_add (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_count                  NUMBER;
      vaudit_id                NUMBER;
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      v_current_action := 'well_action_add';

      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      --  Make sure this version doesn't already exist
      SELECT COUNT (1)
        INTO v_count
        FROM well_version
       WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;
        
     
       IF v_count >0
       THEN
        
          Select Count(1) into v_count
            From Well_Version
           where uwi = pwell_version.uwi 
             AND SOURCE = pwell_version.SOURCE
             AND ACTIVE_IND = 'N';
            
           -- If To well exists but it is Inactive, then Delete it, so merge can be complete.
            IF v_count>0 THEN
      
              well_delete(pwell_version.uwi,pwell_version.SOURCE);
              --Log this to wim_audit_log table
              vaudit_id := paudit_id;
              wim_audit.audit_event (paudit_id      => vaudit_id,
                                   paction          => 'A',
                                   paudit_type      => 'I',
                                   pattribute       => 'TLM_ID',
                                   ptlm_id          => pwell_version.uwi,
                                   psource          => pwell_version.SOURCE ,
                                   ptext            =>    'Add Well Version: Inactive Well ' || pwell_version.uwi
                                                       || '(' || pwell_version.SOURCE ||')'
                                                       || ' deleted to complete Adding a well version',
                                   puser            => v_request_created_by
                                  );
       
            ELSE
                vaudit_id := paudit_id;
                wim_audit.audit_event
                 (paudit_id       => vaudit_id,
                  paction         => 'A',
                  psource         => pwell_version.SOURCE,
                  ptext           =>    'A '
                                     || pwell_version.SOURCE
                                     || ' source well version already exists for TLM_ID: '
                                     || pwell_version.uwi,
                  ptlm_id         => pwell_version.uwi,
                  pattribute      => 'WIM_STG_WELL_VERSION.SOURCE',
                  puser           => v_request_created_by
                 );
                RETURN;
            END IF;
      END IF;
      
      well_action_create (pwim_stg_id, paudit_id, pwell_version);

      /*Modify any exisitng ACTIVE aliases that redirect this version to another well*/
      UPDATE Well_alias
         SET active_ind = 'N',
             expiry_date = SYSDATE,
             --reason_type = 'Inactivate',
             row_changed_date = pwell_version.row_created_date,
             row_changed_by = pwell_version.row_created_by
       WHERE alias_type = 'TLM_ID'
         AND well_alias = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';
   END well_action_add;

/*----------------------------------------------------------------------------------------------------------
Function:   WELL_INVENTORY_CHECK
Detail:     This function checks if there any inventory associated with a well
            It checks DATA_ACCESS_COAT_CHECK.WELL_INVENTORY table          
                        
History of Change:
---------------------------------------------------------------------------------------------------------*/

   FUNCTION well_inventory_check (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE,
      vlast_active_wellversion out varchar2
   )
      RETURN NUMBER
   IS
      v_count                  NUMBER;
      v_audit_id               NUMBER;
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      v_current_action := 'well_inventory_check';

      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      vlast_active_wellversion := wim_util.is_last_version(pwell_version.uwi, pwell_version.source);
      
      if vlast_active_wellversion = 1
      then
         v_count := 0;



          
         v_count := well_inventory.get_inventory_count(p_tlm_id => pwell_version.uwi);


















         
         if v_count > 0 and pwell_version.source in ('300IPL', '450PID', '500PRB') then
              v_count := well_inventory.get_inventory_count(p_tlm_id => pwell_version.uwi, p_local_ind => 'Y');
         end if;

         IF v_count > 0
         THEN
            v_audit_id := paudit_id;
            wim_audit.audit_event
               (paudit_id        => v_audit_id,
                paction          => pwell_version.wim_action_cd,
                paudit_type      => 'E',
                ptlm_id          => pwell_version.uwi,
                psource          => pwell_version.SOURCE,
                ptext            => 'Well cannot be deleted/inactivated. There is inventory associated with this well.',
                puser            => v_request_created_by
               );
            RETURN v_count;
         END IF;
      END IF;

      RETURN 0;
   END;
   
/*----------------------------------------------------------------------------------------------------------
Procedure:  create_inventory_source
Detail:     This procedure creates a source entry into the well version table to hold inventory
                       
Calls:
            
History of Change:
---------------------------------------------------------------------------------------------------------*/
--    function create_inventory_source(paudit_id number, pwell_version wim_stg_well_version%ROWTYPE)
--    return varchar2

--    is
--        v_wim_stg_id  wim.wim_stg_request.wim_stg_id%type;
--        v_status          varchar2(30) := null;
--        v_audit_id        varchar2(30); 
--        v_ptlm_id         varchar2(30) := null;
--        v_return          number;
--    begin
--        if pwell_version.source <> '700TLME' then
--            insert into wim.wim_stg_request(status_cd, row_created_by, row_created_date)
--            values('R', user, sysdate)
--            returning wim_stg_id into v_wim_stg_id;

--              
--            insert into wim.wim_stg_well_version(wim_stg_id, wim_action_cd, uwi, source, active_ind, country, well_name, remark)
--            select v_wim_stg_id, 'A', w.uwi, '700TLME', 'Y', w.country, w.well_name, sysdate || ' - Created for inventory, all other versions removed'
--            from ppdm.well w
--            where uwi = pwell_version.uwi

--            ;          
--            wim.wim_well_action.well_action(v_wim_stg_id, v_ptlm_id, v_status, v_audit_id);  

--            
--            v_return :=  1;

--        else
--            v_audit_id := paudit_id;
--            wim_audit.audit_event
--               (paudit_id        => v_audit_id,
--                paction          => pwell_version.wim_action_cd,
--                paudit_type      => 'E',
--                ptlm_id          => pwell_version.uwi,
--                psource          => pwell_version.SOURCE,
--                ptext            => 'The 700TLME exists for associated inventory and cannot be deleted/inactivated.',


--                puser            => user
--               );
--               v_return :=  0;
--        end if;

--        
--        return v_return;
--end create_inventory_source;

/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_DELETE
Detail:     This procedure deletes a well from well_version, and its child tables ( if there is no inventory attached)
             
                       
            CALLS:
            WELL_INVENTORY_CHECKS
            
History of Change:
---------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_action_delete (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_count      NUMBER;
      v_audit_id   NUMBER;
      v_success    varchar2(1);
      vlast_active_wellversion varchar2(1);
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      ppdm_admin.tlm_process_logger.debug('DELETE called');
      
      SELECT row_created_by, row_created_date
      INTO v_request_created_by, v_request_created_date
      FROM wim_stg_request
      WHERE wim_stg_id = pwim_stg_id;
      
      IF well_inventory_check (pwim_stg_id, paudit_id, pwell_version, vlast_active_wellversion) > 0 THEN
          return;
      END IF;

      v_current_action := 'well_action_delete';
      
      --  Physically Delete the well version
      DELETE FROM well_version
            WHERE uwi = pwell_version.uwi
              AND SOURCE = pwell_version.SOURCE;
      
      IF SQL%ROWCOUNT <> 1
      THEN
         raise_application_error (-20000,
                                  'Version does not exist or inactive.',
                                  TRUE
                                 );
      END IF;

      --  Physically Delete the associated aliases
--      DELETE FROM well_alias
--            WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;
        update ppdm.well_alias
        set active_ind = 'N', 
            expiry_date = v_request_created_date
        where uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;

      --  Physically delete the Well Version License
      DELETE FROM well_license
            WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;

      --  Physically delete the Well Version Nodes
      DELETE FROM well_node_version
            WHERE ipl_uwi = pwell_version.uwi
                  AND SOURCE = pwell_version.SOURCE;

      --  Physically delete the Well Version Nodes MBs
      DELETE FROM well_node_m_b
            WHERE ipl_uwi = pwell_version.uwi
                  AND SOURCE = pwell_version.SOURCE;

      --  Physically delete the Well Statuses
      DELETE FROM well_status
            WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;
            
      IF vlast_active_wellversion = '1' then
          for well in (
              select wv.uwi, wv.source
              from ppdm.well_version wv
              join wim.r_rollup r on wv.source = r.source and wv.active_ind = r.active_ind and override_ind = 'Y'
              where wv.uwi = pwell_version.uwi
                  and wv.active_ind = 'Y'
                  and wv.source <> pwell_version.source
          )
          loop
              wim_well_action.well_delete(well.uwi, well.source);
          end loop;
      end if;
      
      --  Add a new ALIAS to show the DELETE
      wim.wim_well_action.add_alias(
          ptlm_id => pwell_version.uwi
          , psource => pwell_version.source
          , palias_type => 'DEL'
          , palias_value => pwell_version.uwi
          , preason_type => 'Deleted'


          , puser => v_request_created_by
      );
   END;
   
  
/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_INACTIVATE
Detail:     This procedure inactivates a well in well_version table and its child tables ( if there is no inventory attached).
          
            CALLS:
            WELL_INVENTORY_CHECKS  
History of Change:
---------------------------------------------------------------------------------------------------------*/

PROCEDURE well_action_inactivate (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_count                  NUMBER;
      v_audit_id               NUMBER;
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
      v_expiry_date            DATE;
      v_wim_stg_id             wim.wim_stg_request.wim_stg_id%type;
      vlast_active_wellversion varchar2(1);
      v_success                number;
   BEGIN
      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;
       
      IF well_inventory_check (pwim_stg_id, paudit_id, pwell_version, vlast_active_wellversion) > 0 then
          return;
      END IF;

      v_current_action := 'well_action_inactivate';
      
      SELECT SYSDATE
        INTO v_expiry_date
        FROM DUAL;

/*
we use wim_stg_request.row_created_by and wim_stg_request.row_created_date
becasue for inactivate we don't need all children staging tablers to be populated
so we can rely on in row_created_date and row_created_by from WIM_STG_REQUEST
*/

      -- Inactivate the well
      UPDATE well_version
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';

      IF SQL%ROWCOUNT <> 1
      THEN
         raise_application_error (-20000,
                                  'Version does not exist or inactive.',
                                  TRUE
                                 );
      END IF;

      --  Inactivate the Well License
      UPDATE well_license
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';

      --  nactivate the associated aliases
      UPDATE well_alias
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             --reason_type = 'Inactivate',
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';

      --  Inactivate Well Version Nodes
      UPDATE well_node_version
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE ipl_uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';

      --  Inactivate Well Version Nodes MBs
      UPDATE well_node_m_b
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE ipl_uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';

      --  Inactivate Well Statuses
      UPDATE well_status
         SET active_ind = 'N',
             expiry_date = v_expiry_date,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         AND expiry_date IS NULL
         AND active_ind = 'Y';
    
    
--        wim.wim_nad27.nad27_inactivate(pwim_stg_id);
        
        
    IF vlast_active_wellversion = 'Y' then
          for well in (
              select wv.uwi, wv.source
              from ppdm.well_version wv
              join wim.r_rollup r on wv.source = r.source and wv.active_ind = r.active_ind and override_ind = 'Y'
              where wv.uwi = pwell_version.uwi
                  and wv.active_ind = 'Y'
                  and wv.source <> pwell_version.source
          )
          loop
              wim_well_action.well_delete(well.uwi, well.source);
          end loop;
      end if;
      
   END well_action_inactivate;



/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION_REACTIVATE
Detail:     This procedure re-activates a well in well_version table and its child tables ( if there is no inventory attached).
            And updates Well_Alias table by Reactivating the LATEST aliases for each alias type for this well version
             
History of Change:
-------------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE well_action_reactivate (
      pwim_stg_id     NUMBER,
      paudit_id       NUMBER,
      pwell_version   wim_stg_well_version%ROWTYPE
   )
   IS
      v_count                  NUMBER;
      v_audit_id               NUMBER;
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
      v_inactivated_date       DATE;
      v_well_num               WELL_VERSION.WELL_NUM%TYPE;
   BEGIN
      v_current_action := 'well_action_reactivate';

      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

    /*  SELECT expiry_date
        INTO v_inactivated_date
        FROM well_version
       WHERE uwi = pwell_version.uwi AND SOURCE = pwell_version.SOURCE;

      IF v_inactivated_date IS NULL
      THEN
         raise_application_error (-20000,
                                  'Well Version does not exist or active.',
                                  TRUE
                                 );
      END IF;
*/

/*
we use wim_stg_request.row_created_by and wim_stg_request.row_created_date
becasue for inactivate we don't need all children staging tablers to be populated
so we can rely on in row_created_date and row_created_by from WIM_STG_REQUEST
*/

      -- Reactivate the well
      UPDATE well_version
         SET active_ind = 'Y',
             expiry_date = NULL,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         --AND expiry_date IS NOT NULL
         --AND expiry_date = v_inactivated_date
         AND active_ind = 'N';

      IF SQL%ROWCOUNT <> 1
      THEN
         raise_application_error (-20000,
                                  'Version does not exist or inactive.',
                                  TRUE
                                 );
      END IF;

      --  Inactivate the Well License
      UPDATE well_license
         SET active_ind = 'Y',
             expiry_date = NULL,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         --AND expiry_date IS NOT NULL
        -- AND expiry_date = v_inactivated_date
         AND active_ind = 'N';

      --  Inactivate Well Version Nodes
      UPDATE well_node_version
         SET active_ind = 'Y',
             expiry_date = NULL,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE ipl_uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         --AND expiry_date IS NOT NULL
        -- AND expiry_date = v_inactivated_date
         AND active_ind = 'N';

      --  Inactivate Well Version Nodes MBs
      UPDATE well_node_m_b
         SET active_ind = 'Y',
             expiry_date = NULL,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE ipl_uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         --AND expiry_date IS NOT NULL
     --    AND expiry_date = v_inactivated_date
         AND active_ind = 'N';

      --  Inactivate Well Statuses
      UPDATE well_status
         SET active_ind = 'Y',
             expiry_date = NULL,
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
         --AND expiry_date IS NOT NULL
         --AND expiry_date = v_inactivated_date
         AND active_ind = 'N';
      
      --ppdm_admin.tlm_process_logger.info('Updating aliases for uwi: ' || pwell_version.uwi || ' and source: ' || pwell_version.SOURCE);
      
      --  Reactivate the LATEST aliases for each alias type for this well version
      UPDATE well_alias
         SET active_ind = 'Y',
             expiry_date = NULL,
             --reason_type = 'Activate',
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = pwell_version.uwi
         AND SOURCE = pwell_version.SOURCE
        -- AND expiry_date = v_inactivated_date
         AND active_ind = 'N';
   /*
   FOR rec IN (SELECT   alias_type, well_alias,
                        MAX (effective_date) AS effective_date
                   FROM ppdm.well_alias
                  WHERE uwi = ptlm_id
                    AND SOURCE = psource
                    AND active_ind = 'N'
               GROUP BY alias_type, well_alias)
   LOOP
      UPDATE ppdm.well_alias
         SET active_ind = 'Y',
             expiry_date = NULL,
             --reason_type = 'Activate',
             row_changed_date = v_request_created_date,
             row_changed_by = v_request_created_by
       WHERE uwi = ptlm_id
         AND SOURCE = psource
         AND alias_type = rec.alias_type
         AND well_alias = rec.well_alias
         AND effective_date = rec.effective_date
         AND expiry_date IS NOT NULL
         AND active_ind = 'N';
   END LOOP;
    */
   END well_action_reactivate;



/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_ACTION
Detail:     This procedure provides the ability to Create a new well, add a new version to an existing well, 
            update the attributes of an existing well, deactivate the well version or permenantly delete it.
            
            After updating/adding/Creating a well, it also will create or update TLM
            override version if there are any special characters in the well_name.
            
            The pAction parameter controls which of these actions is performed. The pStatus parameter returns an ID 
            to retrieve validation messages from the WIM_AUDIT_LOG table.

            
          CALLS:
            wim_audit.get_audit_id
            wim_audit.clear_audit_event_log
            wim_validate.validate_well
            well_action_create
            well_action_add
            well_action_Update
            well_action_Inactivate
            well_action_Reactivate
            well_action_Delete
            wim_rollup.well_rollup 
            Well_Action_Override           

History of Change:
-------------------------------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_action (
      pwim_stg_id                   NUMBER,
      ptlm_id              IN OUT   VARCHAR2,
      pstatus_cd           OUT      VARCHAR2,
      paudit_id            OUT      NUMBER,
      ppriority_level_cd            validate_rule.priority_level_cd%TYPE
            DEFAULT 10
   )
   IS
      v_count          NUMBER;
      v_errors         NUMBER                         := 0;
      v_stg_request    wim_stg_request%ROWTYPE;
      v_well_version   wim_stg_well_version%ROWTYPE;
      v_Well_num       well_version.well_num%Type;
   BEGIN
      v_current_action := 'well_action';

      SELECT *
        INTO v_stg_request
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      IF v_stg_request.status_cd = 'C'
      THEN
         RETURN;
      END IF;

      IF v_stg_request.audit_no IS NULL
      THEN
         paudit_id := wim_audit.get_audit_id ();

         UPDATE wim_stg_request
            SET audit_no = paudit_id
          WHERE wim_stg_id = pwim_stg_id;
      ELSE
         paudit_id := v_stg_request.audit_no;
         wim_audit.clear_audit_event_log (paudit_id);
      END IF;

      v_current_action := 'validate_well';
      v_errors :=
           v_errors
         + wim_validate.validate_well (pwim_stg_id, ppriority_level_cd);
     v_current_action := 'well_action';

-- We need wim_stg_well_version record to be able to process any changes
-------------------------------------------------------------------------------
      SELECT COUNT (*)
        INTO v_count
        FROM wim_stg_well_version
       WHERE wim_stg_id = pwim_stg_id;

      IF v_count = 0
      THEN
         --  Log the error
         wim_audit.audit_event
            (paudit_id        => paudit_id,
             paction          => NULL,
             paudit_type      => 'F',
             ptlm_id          => NULL,
             psource          => NULL,
             ptext            =>    'There is no record in wim_stg_well_version for wim_stg_id = '
                                 || pwim_stg_id,
             puser            => v_stg_request.row_created_by
            );
         v_errors := v_errors + 1;
      ELSE
         SELECT *
           INTO v_well_version
           FROM wim_stg_well_version
          WHERE wim_stg_id = pwim_stg_id;

         ptlm_id := v_well_version.uwi;
      END IF;

      /* rule can generate warning but still return 1 as error,
       so it is much simpler to count all errors after*/
      SELECT COUNT (*)
        INTO v_errors
        FROM wim_audit_log
       WHERE audit_id = paudit_id
         AND UPPER (audit_type) IN ('FATAL', 'ERROR', 'F', 'E');

-------------------------------------------------------------------------------
      IF v_errors = 0
      THEN
         CASE v_well_version.wim_action_cd
            WHEN 'C'
            THEN
               well_action_create (pwim_stg_id, paudit_id, v_well_version);
            WHEN 'A'
            THEN
               well_action_add (pwim_stg_id, paudit_id, v_well_version);
            WHEN 'U'
            THEN
               well_action_update (pwim_stg_id, paudit_id, v_well_version);
            WHEN 'D'
            THEN
               well_action_delete (pwim_stg_id, paudit_id, v_well_version);
            WHEN 'I'
            THEN
               well_action_inactivate (pwim_stg_id, paudit_id,
                                       v_well_version);
            WHEN 'R'
            THEN
                v_count := 0;
               --Check if well doesnt exist already,
                  --Get well_num, usually only tlm_id is provided when reactivating
                  select well_num into  v_well_num
                     from WELL_VERSION
                    WHERE UWI = ptlm_ID
                        AND ACTIVE_IND = 'N'
                        AND SOURCE = v_well_version.source;
                  
                  --if well_num is not null, then check if there are any other active well with the same well_num, in the given source                  
                  IF v_well_num is not NULL 
                  THEN
                    SELECT count(1) into v_count
                      from WELL_VERSION
                     WHERE well_num = v_well_num
                       AND ACTIVE_IND = 'Y'
                       AND SOURCE = v_well_version.source;
                  END IF;
                                                               
                  IF v_count = 0 
                  THEN             
                    well_action_reactivate (pwim_stg_id, paudit_id,  v_well_version);
                  ELSE
                    --Create a Error Message                     
                     wim_audit.audit_event
                        (paudit_id        => paudit_id,
                         paction          => NULL,
                         paudit_type      => 'E',
                         ptlm_id          => NVL(v_well_version.uwi, ptlm_id),                      
                         psource          => v_well_version.source,
                         ptext            => 'Well ' || nvl(v_well_Version.uwi,ptlm_id) || ' can not be reactivated. There is already a ' || v_well_version.source ||' source well with the same Well_Num ' || v_well_num ||'.',                                             
                         puser            => v_stg_request.row_created_by
                        );
                     
                  END IF;
                 
            WHEN 'X'
            THEN  /*Process all child tables, no changes to the well_version*/
               well_license_proccess (pwim_stg_id, paudit_id);
               well_node_version_proccess (pwim_stg_id, paudit_id);
               well_node_m_b_proccess (pwim_stg_id, paudit_id);
               well_status_proccess (pwim_stg_id, paudit_id);
            ELSE
               wim_audit.audit_event
                                    (paudit_id        => paudit_id,
                                     paction          => v_well_version.wim_action_cd,
                                     paudit_type      => 'E',
                                     ptlm_id          => NVL
                                                            (v_well_version.uwi,
                                                             ptlm_id
                                                            ),
                                     psource          => v_well_version.SOURCE,
                                     ptext            =>    'Unknown action - '
                                                         || v_well_version.wim_action_cd,
                                     puser            => v_stg_request.row_created_by
                                    );
         END CASE;

         SELECT COUNT (*)
           INTO v_errors
           FROM wim_audit_log
          WHERE audit_id = paudit_id
            AND UPPER (audit_type) IN ('FATAL', 'ERROR', 'F', 'E');

         IF v_errors = 0
         THEN
            --  Rollup the changes into the WELL table
            v_current_action := 'WIM_Rollup.Well_Rollup ';
            wim_rollup.well_rollup (NVL (v_well_version.uwi, ptlm_id));
            --TODO    - notify DM and other systems????

  --          DBMS_OUTPUT.PUT_LINE(v_well_version.uwi || '-' || v_well_version.source);
--            WIM.WIM_UTIL.blackList_Wells(v_well_version.UWI, v_well_version.SOURCE, 'N');
         
            --  Log message that it's done
            wim_audit.audit_event (paudit_id        => paudit_id,
                                   paction          => v_well_version.wim_action_cd,
                                   paudit_type      => 'I',
                                   ptlm_id          => NVL
                                                          (v_well_version.uwi,
                                                           ptlm_id
                                                          ),
                                   psource          => v_well_version.SOURCE,
                                   ptext            => 'Well change completed',
                                   puser            => v_stg_request.row_created_by
                                  );
            -- Set success status and commit the changes
            pstatus_cd := 'C';
         ELSE
            pstatus_cd := 'E';
         END IF;
      ELSE
         pstatus_cd := 'E';
      END IF;

      UPDATE wim_stg_request
         SET audit_no = paudit_id,
             status_cd = pstatus_cd,
             row_changed_by = row_created_by,                          --USER,
             row_changed_date = SYSDATE
       WHERE wim_stg_id = pwim_stg_id;

      COMMIT;
      
     /* --Check if there are spacial chars in well_name or plot_name , if there are then create an override version with out specials chars, it
      -- override version is already there then update it.
       v_current_action := 'well_action_override';
      IF v_well_version.wim_action_cd in ('A', 'U', 'C')
      THEN
          --call procedure          
          Well_Action_Override(NVL (v_well_version.uwi, ptlm_id));
      END IF;
      */
      
   EXCEPTION
      WHEN OTHERS
      THEN
         wim_audit.audit_event (paudit_id        => paudit_id,
                                paction          => v_well_version.wim_action_cd,
                                ptlm_id          => v_well_version.uwi,
                                psource          => v_well_version.SOURCE,
                                ptext            => SUBSTR
                                                        ( 'Oracle Error : '
                                                         || ' in '
                                                         || v_current_action
                                                         || ' - '
                                                         || SQLERRM,
                                                         1,
                                                         255
                                                        ),
                                paudit_type      => 'F',
                                puser            => v_stg_request.row_created_by
                               );
--      DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
         ROLLBACK;
         pstatus_cd := 'F';

         UPDATE wim_stg_request
            SET audit_no = paudit_id,
                status_cd = 'F',
                row_changed_by = row_created_by,
                row_changed_date = SYSDATE
          WHERE wim_stg_id = pwim_stg_id;
          COMMIT;
   END well_action;


/*----------------------------------------------------------------------------------------------------------
Procedure:  WELL_MOVE
Detail:     This procedure provides the ability to Move or Merge a well.

          CALLS:
         
History of Change:
-------------------------------------------------------------------------------------------------------------------------------*/

   PROCEDURE well_move (
      pfrom_tlm_id   IN       well_version.uwi%TYPE,
      pfrom_source   IN       well_version.SOURCE%TYPE,
      pto_tlm_id     IN OUT   well_version.uwi%TYPE,
      puser          IN       well_version.row_created_by%TYPE
            DEFAULT USER,
      pstatus        OUT      NUMBER
   )
   IS
      caction          CONSTANT VARCHAR2 (1)                            :='M';
      verrors                   NUMBER (14)                             := 0;
      vcount                    NUMBER (14)                             := 0;
      v_node_id                 wim_stg_well_node_version.node_id%TYPE;
      presult_msg               wim_audit_log.text%TYPE;
      v_nextalias_id            well_alias.well_alias_id%type; 
      v_alias_id                well_alias.well_alias_id%type;
      
      vlast_active_wellversion varchar2(1);
      v_wim_stg_id  wim.wim_stg_request.wim_stg_id%type;
      
      v_status          varchar2(30) := null;
      v_audit_no        varchar2(30); 
      v_ptlm_id         varchar2(30) := null;
   BEGIN
      v_current_action := 'well_move';
      -- 1 get a new Audit ID for this operation
      pstatus := wim_audit.get_audit_id ();
-- 2 Validate the request and the content against the business rules????
      verrors :=
           verrors
         + wim_validate.validate_tlm_id (pstatus,
                                         caction,
                                         pfrom_tlm_id,
                                         pfrom_source,
                                         puser
                                        );

--  vErrors := vErrors + WIM_Validate.Validate_Reference (pStatus, cAction, pFROM_TLM_ID, pFROM_Source, 'Source', 'R_SOURCE', pFROM_Source);

      -- If this is a split, get a new ID to move the version to
      IF pto_tlm_id IS NULL
      THEN
         SELECT wim_tlm_id_seq.NEXTVAL
           INTO pto_tlm_id
           FROM DUAL;
      ELSE
         -- TODO
         verrors :=
              verrors
            + wim_validate.validate_tlm_id (pstatus,
                                            caction,
                                            pto_tlm_id,
                                            pfrom_source,
                                            puser
                                           );
      END IF;

-- 3 Ensure that "From" well exists
      --  Fail the request if the source doesn't exist
      SELECT COUNT (1)
        INTO vcount
        FROM well_version
       WHERE uwi = pfrom_tlm_id AND SOURCE = pfrom_source;

      IF vcount = 0
      THEN
         wim_audit.audit_event (paudit_id        => pstatus,
                                paction          => caction,
                                paudit_type      => 'E',
                                pattribute       => 'Source',
                                ptlm_id          => pto_tlm_id,
                                psource          => pfrom_source,
                                ptext            =>    'Unable to move the '
                                                    || pfrom_source
                                                    || ' version from well '
                                                    || pfrom_tlm_id
                                                    || ' to well '
                                                    || pto_tlm_id
                                                    || '. Well or version not found',
                                puser            => puser
                               );
         verrors := verrors + 1;
      ELSE
-- 4   --If "To" well specified but that well version already exists (Active)- what do we do?

         --  ***** Currently fail the request if the source has an existing version this needs to be done properly in future
         --         i.e take the newest version, put the older one on the PENDING stack and delete the older one.
         --             Also add an alias pointing to the surviving version and well
      
       
         Select Count(1) into vcount
           From Well_Version
          where uwi = pto_tlm_id 
            AND SOURCE = pfrom_source; 
         
         IF vcount >0 THEN
         
            Select Count(1) into vcount
              From Well_Version
             where uwi = pto_tlm_id 
               AND SOURCE = pfrom_source
               AND ACTIVE_IND = 'N';
            
           -- If To well exists but it is Inactive, then Delete it, so merge can be complete.
           IF vcount>0 THEN
              well_delete(pto_tlm_id,pfrom_source);
              --Log this to wim_audit_log table
              wim_audit.audit_event (paudit_id        => pstatus,
                                   paction          => caction,
                                   paudit_type      => 'I',
                                   pattribute       => 'TLM_ID',
                                   ptlm_id          => pto_tlm_id,
                                   psource          => pfrom_source,
                                   ptext            =>    'Well_Move: Inactive Well ' || pto_tlm_id
                                                       || '(' || pfrom_source ||')'
                                                       || ' deleted to complete Well Merge',
                                   puser            => puser
                                  );
             
           ELSE --Active version already exists
              wim_audit.audit_event (paudit_id        => pstatus,
                                   paction          => caction,
                                   paudit_type      => 'E',
                                   pattribute       => 'Source',
                                   ptlm_id          => pto_tlm_id,
                                   psource          => pfrom_source,
                                   ptext            =>    'Unable to move the '
                                                       || pfrom_source
                                                       || ' version from well '
                                                       || pfrom_tlm_id
                                                       || ' to well '
                                                       || pto_tlm_id
                                                       || '. Version already exists.',
                                   puser            => puser
                                  );
            verrors := verrors + 1;
           
           END IF;
           
         END IF;
         
      END IF;

      IF wim_util.is_last_version(pfrom_tlm_id, pfrom_source) = 1
      THEN
         -- We are moving the last well version - Inform other systems about changes in WELLS
-------------------------------------------------------------------------------------
         vlast_active_wellversion := 'Y';
      END IF;

-- 5 If "To" well is not specified, create a new well

      -- *******************
--  APPLY THE CHANGES
-- *******************
--  If there have been no errors, make the change
      IF verrors = 0
      THEN
         -- Move the version from the FROM to the TO well

         -- 6 Apply the appropriate changes to the well tables - ???
         UPDATE well_version
            SET uwi = pto_tlm_id 
          WHERE uwi = pfrom_tlm_id AND SOURCE = pfrom_source;

/* Move all realted child tables records*/
/*-----------------------------------------------------*/
         UPDATE well_license
            SET uwi = pto_tlm_id,
                /* in case if license_id was genereted based on old TLM_ID, we need to change it too*/
                license_id =
                   CASE
                      WHEN license_id = pfrom_tlm_id
                         THEN pto_tlm_id
                      ELSE license_id
                   END
          WHERE uwi = pfrom_tlm_id AND SOURCE = pfrom_source;

--- moving nodes are more complicated, we need to change node_ids in both well_node_version and well_node_m_b
--- becasue our node_ids are generated based on the rule TLM_ID + '0' or '1' depends on the node position we
--  have to go thru each record in wwell_version and update related nodes in well_node_m_b first and then in well_node_version
         FOR node_rec IN (SELECT *
                            FROM well_node_version
                           WHERE ipl_uwi = pfrom_tlm_id
                             AND SOURCE = pfrom_source)
         LOOP
            IF node_rec.node_position = 'B'
            THEN
               v_node_id := pto_tlm_id || '0';
            ELSE
               v_node_id := pto_tlm_id || '1';
            END IF;

            UPDATE well_node_m_b
               SET ipl_uwi = pto_tlm_id,
                   node_id = v_node_id                                /*,
                                                   row_changed_date = SYSDATE,
                                                   row_changed_by = puser*/
             WHERE ipl_uwi = pfrom_tlm_id
               AND SOURCE = pfrom_source
               AND node_id = node_rec.node_id;

            --- change old node to the new one
            UPDATE well_node_version
               SET ipl_uwi = pto_tlm_id,
                   node_id = v_node_id                  
             WHERE ipl_uwi = pfrom_tlm_id
               AND SOURCE = pfrom_source
               AND node_id = node_rec.node_id;
         --- change old node to the new one
         END LOOP;

         UPDATE well_status
            SET uwi = pto_tlm_id                
          WHERE uwi = pfrom_tlm_id AND SOURCE = pfrom_source;

/*-----------------------------------------------------*/

         -- 7 Create/Update/Inactivate the relevant alias records

         -- ***********************************
--    Apply the aliases
-- ***********************************
-- Move existing aliases, except the UWI_PRIORs - they should remain to keep
-- the path history. We don't expire them at this stage either as they are still
--  a valid hop in the chain to find the latest UWI.
         UPDATE well_alias
            SET uwi = pto_tlm_id,
                row_changed_date = SYSDATE,
                row_changed_by = puser
          WHERE uwi = pfrom_tlm_id
            AND SOURCE = pfrom_source
            AND alias_type != 'TLM_ID';

         --AND active_ind = 'Y';

         --transfer old active TLM_ID aliases
         
         --First check if it is already there (Inactivated ones),         
            SELECT count(1) into vcount 
              FROM well_alias
             WHERE uwi = pto_tlm_id
               AND pto_tlm_id <> well_alias
               /* and it's not the move back to the same old well*/
               AND SOURCE = pfrom_source
               AND alias_type = 'TLM_ID';
               
              v_nextalias_id := 1;      
          If vcount > 0 then
                --If it is already there, get well_alias_id to next one to avoid constraint eror
            SELECT MAX (to_number(well_alias_id)) into v_alias_id 
              FROM well_alias
             WHERE uwi = pto_tlm_id
               AND pto_tlm_id <> well_alias
               /* and it's not the move back to the same old well*/
               AND SOURCE = pfrom_source
               AND alias_type = 'TLM_ID';
              
              v_nextalias_id := v_alias_id +1;
                
          end if;
         
              
          INSERT INTO well_alias
                     (uwi, SOURCE, alias_type, active_ind, reason_type,
                      well_alias_id, well_alias, effective_date,
                      row_created_by, row_created_date)
            SELECT pto_tlm_id, SOURCE, alias_type, active_ind, 'Move',
                   v_nextalias_id, well_alias,SYSDATE, puser, SYSDATE
              FROM well_alias
             WHERE uwi = pfrom_tlm_id
               AND pto_tlm_id <> well_alias
                  /* and it's not the move back to the same old well*/
               AND SOURCE = pfrom_source
               AND alias_type = 'TLM_ID'
               AND active_ind = 'Y';
         
         
         -- inactivate old  TLM_ID alias
         UPDATE well_alias
            SET active_ind = 'N',
                expiry_date = SYSDATE,
                row_changed_date = SYSDATE,
                row_changed_by = puser
          WHERE uwi = pfrom_tlm_id
            AND SOURCE = pfrom_source
            AND alias_type = 'TLM_ID'
            AND active_ind = 'Y';

         --  Add a new ALIAS to show the MOVE
         add_alias (pto_tlm_id,
                    pfrom_source,
                    'TLM_ID',
                    pfrom_tlm_id,
                    'Move',
                    puser
                   );
                   
         IF vlast_active_wellversion = 'Y'
         THEN
         -- We are moving the last well version - Inform other systems about changes in WELLS
-------------------------------------------------------------------------------------
          external_dependencies.well_move(pfrom_tlm_id,
                                             pfrom_source,
                                             pto_tlm_id,
                                             puser
                                            );
            
            for well in (
                select wv.uwi, wv.source
                from ppdm.well_version wv
                join wim.r_rollup r on wv.source = r.source and wv.active_ind = r.active_ind and override_ind = 'Y'
                where wv.uwi = pfrom_tlm_id
                    and wv.active_ind = 'Y'
                    and wv.source <> pfrom_source
            )
            loop
                wim_well_action.well_delete(well.uwi, well.source);
            end loop;
            
         END IF;

         
         
         
         
         --  Rollup the updated TO WELL
         wim_rollup.well_rollup (pto_tlm_id);
         wim_rollup.well_rollup (pfrom_tlm_id);
        
        
         -- 10 Log the errors and / or change in audit log ---
         wim_audit.audit_event (paudit_id        => pstatus,
                                paction          => caction,
                                paudit_type      => 'I',
                                pattribute       => NULL,
                                ptlm_id          => pto_tlm_id,
                                psource          => pfrom_source,
                                ptext            =>    'Moved the '
                                                    || pfrom_source
                                                    || ' version from well '
                                                    || pfrom_tlm_id
                                                    || ' to well '
                                                    || pto_tlm_id,
                                puser            => puser
                               );
         -- Set return status and commit the changes
         pstatus := 0;
         
         COMMIT;
         
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         wim_audit.audit_event (paudit_id        => pstatus,
                                paction          => caction,
                                psource          => pfrom_source,
                                ptext            => SUBSTR
                                                        (   'Oracle Error : '
                                                         || ' in '
                                                         || v_current_action
                                                         || ' - '
                                                         || SQLERRM,
                                                         1,
                                                         255
                                                        ),
                                ptlm_id          => pfrom_tlm_id,
                                paudit_type      => 'F',
                                puser            => puser
                               );
--         DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
         ROLLBACK;
   END well_move;
END wim_WELL_ACTION;