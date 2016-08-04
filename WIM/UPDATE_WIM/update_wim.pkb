create or replace PACKAGE BODY     "UPDATE_WIM"
AS
   /*-----------------------------------------------------------------------------------------------------------------------------------
    SCRIPT: WIM.UPDATE_WIM.pkb

    PURPOSE:
         This package contains functions and procedures to implement the
         simpler update interface  to update/Add/Create wells.
         It is part of WIM_GATEWAY.

         Procedre/Function Detail
           See Package Spec for details.


   DEPENDENCIES
      WIM_GATEWAY
      WIM_WELL_ACTION
      TLM_PROCESS_LOGGER
      WIM_AUDIT_EVENT


   HISTORY:
     1.0.0         Jan 2013    V.Rajpoot             Initial Creation
     1.0.1         March 2013  V.Rajpoot             Added 3 new parametest to Update_WEll and Create_Well
                                                     P_KB_ELEV_OUOM
                                                     P_GROUND_ELEV
                                                     P_GROUND_ELEV_OUOM
     1.0.2      18-Jun-2013      V.Rajpoot           a small fix to Create_Well procedure. In Surface Lat section was passing Bottom hole location my mistake.
     1.0.3      21-Feb-2013      K.Edwards           Added OPERATOR, IPL_LICENSEE, CONTRACTOR and WL_LICENSEE attributes
     1.0.4      13-Mar-2014      k.edwards           Added basic (INFO) logging to tlm_process_log                                                  
     1.0.5      17-Mar-2014      k.edwards           Added atributes P_WV_REGULATORY_AGENCY, P_WL_AGENT, P_WL_LICENSEE_CONTACT_ID, P_WL_REGULATORY_AGENCY, P_WL_REGULATORY_CONTACT_ID, P_WL_SURVEYOR
	   1.0.6	    02-Jul-2014	     k.edwards		       Changed CREATE_WELL and UPDATE_WELL to cascade country changes down to the node tables. 
   -----------------------------------------------------------------------------------------------------------*/

   /*----------------------------------------------------------------------------------------------------------
   FUNCTION: Version
   Detail:   This function returns version # of the pcakage

   Created On: August. 2012
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
      RETURN '1.0.6';
   END Version;

   /*----------------------------------------------------------------------------------------------------------
   Function:  CheckWellNodeVersion
   Detail:    This Procedure checks if Node needs to be updated or Added

             This is called from POPULATE_WELL_NODES_STG.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION CheckWellNodeVersion (P_NODE_ID                 VARCHAR2,
                                  P_GEOG_COORD_SYSTEM_ID    VARCHAR2,
                                  P_NODE_OBS_NO             NUMBER,
                                  P_SOURCE                  VARCHAR2,
                                  P_LOCATION_QUALIFIER      VARCHAR2)
      RETURN VARCHAR2
   IS
      v_num   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_num
        FROM well_node_version
       WHERE     NODE_ID = P_NODE_ID
             AND source = P_SOURCE
             AND node_obs_no = P_NODE_OBS_NO
             AND geog_coord_system_id = P_GEOG_COORD_SYSTEM_ID
             AND location_qualifier = P_LOCATION_QUALIFIER;           --'N/A';

      IF v_num > 0
      THEN
         RETURN 'U';
      ELSE
         RETURN 'A';
      END IF;
   END;


   /*----------------------------------------------------------------------------------------------------------
   Function:  CheckWellLicense
   Detail:    This Procedure checks if License record needs to be updated or Added.

             This is called from POPULATE_WELL_LICENSE_STG.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION CheckwellLicense (P_TLM_ID VARCHAR2, P_SOURCE VARCHAR2)
      RETURN VARCHAR2
   IS
      v_num   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_num
        FROM PPDM.well_license
       WHERE uwi = P_TLM_ID AND LICENSE_ID = P_TLM_ID AND source = P_SOURCE;

      IF v_num > 0
      THEN
         RETURN 'U';
      ELSE
         RETURN 'A';
      END IF;
   END;

   /*----------------------------------------------------------------------------------------------------------
   Function:  Get_Coord_System_ID
   Detail:    This Function get coord_system_Id from ref table CS_Coordinate_table
              This is called from POPULATE_STG_WELL_NODE_VERSION procedure.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/

   FUNCTION Get_Coord_System_ID (p_Geog_Coord_System_ID VARCHAR2)
      RETURN VARCHAR2
   IS
      V_GEOG_COORD_SYS_ID   VARCHAR2 (20);
      v_count               NUMBER;
   BEGIN
      V_GEOG_COORD_SYS_ID := p_Geog_Coord_System_ID;

      --dbms_output.puT_line('p_Geog_Coord_System_ID '||p_Geog_Coord_System_ID);
      SELECT COUNT (1)
        INTO v_count
        FROM PPDM.CS_COORDINATE_SYSTEM
       WHERE     ACTIVE_IND = 'Y'
             AND (   COORD_SYSTEM_NAME = p_Geog_Coord_System_ID
                  OR COORD_SYSTEM_ID = p_Geog_Coord_System_ID);

      IF v_count > 0
      THEN
         SELECT coord_system_id
           INTO V_GEOG_COORD_SYS_ID
           FROM (  SELECT coord_system_id,
                          ROW_NUMBER () OVER (ORDER BY coord_system_id)
                             AS ROW_NUMBER
                     FROM PPDM.CS_COORDINATE_SYSTEM
                    WHERE     ACTIVE_IND = 'Y'
                          AND (   COORD_SYSTEM_NAME = p_Geog_Coord_System_ID
                               OR COORD_SYSTEM_ID = p_Geog_Coord_System_ID)
                 ORDER BY coord_system_id)
          WHERE ROW_NUMBER = 1;
      END IF;


      RETURN V_GEOG_COORD_SYS_ID;
   EXCEPTION
      WHEN OTHERS
      THEN
         tlm_process_logger.error (
               'WIM_GATEWAY.Update_Well interface FAILED: Oracle Error : '
            || ' - '
            || SQLERRM);
         RETURN NULL;
   END;

   /*----------------------------------------------------------------------------------------------------------
   Function:  GetWellStatus
   Detail:    This Function gets status from r_well_status.
              This is called from CREATE_WELL.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION GetWellStatus (P_STATUS VARCHAR2)
      RETURN VARCHAR2
   IS
      v_num      NUMBER;
      v_status   VARCHAR2 (20);
   BEGIN
      v_status := NULL;

      --get status Code
      SELECT COUNT (*)
        INTO v_num
        FROM r_well_status
       WHERE     active_ind = 'Y'
             AND (STATUS LIKE P_STATUS OR SHORT_NAME LIKE P_STATUS);

      IF v_num > 0
      THEN
         SELECT DISTINCT Status
           INTO v_STATUS
           FROM r_well_status
          WHERE     active_ind = 'Y'
                AND (STATUS LIKE P_STATUS OR SHORT_NAME LIKE P_STATUS)
                AND ROWNUM = 1;
      END IF;

      IF v_STATUS IS NULL
      THEN
         v_status := P_STATUS;
      END IF;

      RETURN v_STATUS;
   END;

   /*----------------------------------------------------------------------------------------------------------
   Function:  CheckWellStatus
   Detail:    This Function checks if status needs to be updated or Added.
              If needs to be added then return status as an out parameter

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION CheckWellStatus (P_TLM_ID          WELL_VERSION.UWI%TYPE,
                             P_SOURCE          WELL_VERSION.SOURCE%TYPE,
                             P_STATUS_CD       WELL_STATUS.STATUS%TYPE,
                             P_STATUS_ID   OUT WELL_STATUS.STATUS_ID%TYPE)
      RETURN VARCHAR2
   IS
      v_num         NUMBER;
      v_status      NUMBER;
      v_count       NUMBER;
      v_status_id   WELL_STATUS.Status_ID%TYPE;
   BEGIN
      SELECT COUNT (*)
        INTO v_num
        FROM WELL_STATUS
       WHERE     UWI = P_TLM_ID
             AND SOURCE = P_SOURCE
             AND STATUS = P_STATUS_CD
             AND ACTIVE_IND = 'Y';



      IF v_num > 0
      THEN                                            -- Status already exists
         --Get the max
         SELECT MAX (STATUS_ID)
           INTO V_STATUS_ID
           FROM WELL_STATUS
          WHERE     UWI = P_TLM_ID
                AND SOURCE = P_SOURCE
                AND STATUS = P_STATUS_CD
                AND ACTIVE_IND = 'Y';

         P_STATUS_ID := V_STATUS_ID;

         RETURN 'U';                                                  --exists
      ELSE                                                       -- NEW status
         SELECT COUNT (*)
           INTO v_count
           FROM well_status
          WHERE uwi = p_TLM_ID AND source = P_SOURCE;

         IF v_count > 0
         THEN
            --get the new status_id
            SELECT MAX (status_id) + 1
              INTO V_STATUS_ID
              FROM well_status
             WHERE uwi = p_tlm_id AND source = p_source;
         ELSE
            V_STATUS_ID := 1;                         -- This is the first one
         END IF;

         P_STATUS_ID := '00' || V_STATUS_ID;
         --dbms_output.puT_line ('P_STATUS_ID ' || P_STATUS_ID );
         RETURN 'A';                                                     --new
      END IF;
   END;

   PROCEDURE null_well_row (a_row IN OUT NOCOPY well_version%ROWTYPE)
   IS
   BEGIN
      -- initialize all the new row columns
      a_row.uwi := NULL;
      a_row.abandonment_date := NULL;
      a_row.active_ind := NULL;
      a_row.assigned_field := NULL;
      a_row.base_node_id := NULL;
      a_row.bottom_hole_latitude := NULL;
      a_row.bottom_hole_longitude := NULL;
      a_row.casing_flange_elev := NULL;
      a_row.casing_flange_elev_ouom := NULL;
      a_row.completion_date := NULL;
      a_row.confidential_date := NULL;
      a_row.confidential_depth := NULL;
      a_row.confidential_depth_ouom := NULL;
      a_row.confid_strat_name_set_id := NULL;
      a_row.confid_strat_unit_id := NULL;
      a_row.confidential_type := NULL;
      a_row.country := NULL;
      a_row.county := NULL;
      a_row.current_class := NULL;
      a_row.current_status := NULL;
      a_row.current_status_date := NULL;
      a_row.deepest_depth := NULL;
      a_row.deepest_depth_ouom := NULL;
      a_row.depth_datum := NULL;
      a_row.depth_datum_elev := NULL;
      a_row.depth_datum_elev_ouom := NULL;
      a_row.derrick_floor_elev := NULL;
      a_row.derrick_floor_elev_ouom := NULL;
      a_row.difference_lat_msl := NULL;
      a_row.discovery_ind := NULL;
      a_row.district := NULL;
      a_row.drill_td := NULL;
      a_row.drill_td_ouom := NULL;
      a_row.effective_date := NULL;
      a_row.elev_ref_datum := NULL;
      a_row.expiry_date := NULL;
      a_row.faulted_ind := NULL;
      a_row.final_drill_date := NULL;
      a_row.final_td := NULL;
      a_row.final_td_ouom := NULL;
      a_row.geographic_region := NULL;
      a_row.geologic_province := NULL;
      a_row.ground_elev := NULL;
      a_row.ground_elev_ouom := NULL;
      a_row.ground_elev_type := NULL;
      a_row.initial_class := NULL;
      a_row.kb_elev := NULL;
      a_row.kb_elev_ouom := NULL;
      a_row.lease_name := NULL;
      a_row.lease_num := NULL;
      a_row.legal_survey_type := NULL;
      a_row.location_type := NULL;
      a_row.log_td := NULL;
      a_row.log_td_ouom := NULL;
      a_row.max_tvd := NULL;
      a_row.max_tvd_ouom := NULL;
      a_row.net_pay := NULL;
      a_row.net_pay_ouom := NULL;
      a_row.oldest_strat_name_set_age := NULL;
      a_row.oldest_strat_age := NULL;
      a_row.oldest_strat_name_set_id := NULL;
      a_row.oldest_strat_unit_id := NULL;
      a_row.OPERATOR := NULL;
      a_row.parent_relationship_type := NULL;
      a_row.parent_uwi := NULL;
      a_row.platform_id := NULL;
      a_row.platform_sf_type := NULL;
      a_row.plot_name := NULL;
      a_row.plot_symbol := NULL;
      a_row.plugback_depth := NULL;
      a_row.plugback_depth_ouom := NULL;
      a_row.ppdm_guid := NULL;
      a_row.profile_type := NULL;
      a_row.province_state := NULL;
      a_row.regulatory_agency := NULL;
      a_row.remark := NULL;
      a_row.rig_on_site_date := NULL;
      a_row.rig_release_date := NULL;
      a_row.rotary_table_elev := NULL;
      a_row.SOURCE := NULL;
      a_row.source_document := NULL;
      a_row.spud_date := NULL;
      a_row.status_type := NULL;
      a_row.subsea_elev_ref_type := NULL;
      a_row.surface_latitude := NULL;
      a_row.surface_longitude := NULL;
      a_row.surface_node_id := NULL;
      a_row.tax_credit_code := NULL;
      a_row.td_strat_name_set_age := NULL;
      a_row.td_strat_age := NULL;
      a_row.td_strat_name_set_id := NULL;
      a_row.td_strat_unit_id := NULL;
      a_row.water_acoustic_vel := NULL;
      a_row.water_acoustic_vel_ouom := NULL;
      a_row.water_depth := NULL;
      a_row.water_depth_ouom := NULL;
      a_row.well_government_id := NULL;
      a_row.well_intersect_md := NULL;
      a_row.well_name := NULL;
      a_row.well_num := NULL;
      a_row.well_numeric_id := NULL;
      a_row.whipstock_depth := NULL;
      a_row.whipstock_depth_ouom := NULL;
      a_row.ipl_licensee := NULL;
      a_row.well_event_num := NULL;
      a_row.ipl_offshore_ind := NULL;
      a_row.ipl_pidstatus := NULL;
      a_row.ipl_prstatus := NULL;
      a_row.ipl_orstatus := NULL;
      a_row.ipl_onprod_date := NULL;
      a_row.ipl_oninject_date := NULL;
      a_row.ipl_confidential_strat_age := NULL;
      a_row.ipl_pool := NULL;
      a_row.ipl_last_update := NULL;
      a_row.ipl_uwi_sort := NULL;
      a_row.ipl_uwi_display := NULL;
      a_row.ipl_td_tvd := NULL;
      a_row.ipl_plugback_tvd := NULL;
      a_row.ipl_whipstock_tvd := NULL;
      a_row.ipl_water_tvd := NULL;
      a_row.ipl_alt_source := NULL;
      a_row.ipl_xaction_code := NULL;
      a_row.row_changed_by := NULL;
      a_row.row_changed_date := NULL;
      a_row.row_created_by := NULL;
      a_row.row_created_date := NULL;
      a_row.ipl_basin := NULL;
      a_row.ipl_block := NULL;
      a_row.ipl_area := NULL;
      a_row.ipl_twp := NULL;
      a_row.ipl_tract := NULL;
      a_row.ipl_lot := NULL;
      a_row.ipl_conc := NULL;
      a_row.ipl_uwi_local := NULL;
      a_row.row_quality := NULL;
   END null_well_row;

   /*----------------------------------------------------------------------------------------------------------
   Function:  null_node_row
   Detail:    This procedure set all the attributes to null in the well_node_version row

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE null_node_row (a_row IN OUT NOCOPY well_node_version%ROWTYPE)
   IS
   BEGIN
      a_row.node_id := NULL;
      a_row.node_obs_no := NULL;
      a_row.acquisition_id := NULL;
      a_row.active_ind := NULL;
      a_row.country := NULL;
      a_row.county := NULL;
      a_row.easting := NULL;
      a_row.easting_ouom := NULL;
      a_row.effective_date := NULL;
      a_row.elev := NULL;
      a_row.elev_ouom := NULL;
      a_row.ew_direction := NULL;
      a_row.expiry_date := NULL;
      a_row.geog_coord_system_id := NULL;
      a_row.latitude := NULL;
      a_row.legal_survey_type := NULL;
      a_row.location_qualifier := NULL;
      a_row.location_quality := NULL;
      a_row.longitude := NULL;
      a_row.map_coord_system_id := NULL;
      a_row.md := NULL;
      a_row.md_ouom := NULL;
      a_row.monument_id := NULL;
      a_row.monument_sf_type := NULL;
      a_row.node_position := NULL;
      a_row.northing := NULL;
      a_row.northing_ouom := NULL;
      a_row.north_type := NULL;
      a_row.ns_direction := NULL;
      a_row.polar_azimuth := NULL;
      a_row.polar_offset := NULL;
      a_row.polar_offset_ouom := NULL;
      a_row.ppdm_guid := NULL;
      a_row.preferred_ind := NULL;
      a_row.province_state := NULL;
      a_row.remark := NULL;
      a_row.reported_tvd := NULL;
      a_row.reported_tvd_ouom := NULL;
      a_row.SOURCE := NULL;
      a_row.version_type := NULL;
      a_row.x_offset := NULL;
      a_row.x_offset_ouom := NULL;
      a_row.y_offset := NULL;
      a_row.y_offset_ouom := NULL;
      a_row.ipl_xaction_code := NULL;
      a_row.row_changed_by := NULL;
      a_row.row_changed_date := NULL;
      a_row.row_created_by := NULL;
      a_row.row_created_date := NULL;
      a_row.ipl_uwi := NULL;
      a_row.row_quality := NULL;
   END null_node_row;

   /*----------------------------------------------------------------------------------------------------------
   Function:  null_license_row
   Detail:    This procedure set all the attributes to null in the well license row

   Created On: Jan. 2013
   History of Change:
   -----------------------------------------------------------------------------------------------------------*/
   PROCEDURE null_license_row (a_row IN OUT NOCOPY well_license%ROWTYPE)
   IS
   BEGIN
      a_row.UWI := NULL;
      a_row.LICENSE_ID := NULL;
      a_row.SOURCE := NULL;
      a_row.ACTIVE_IND := NULL;
      a_row.AGENT := NULL;
      a_row.APPLICATION_ID := NULL;
      a_row.AUTHORIZED_STRAT_UNIT_ID := NULL;
      a_row.BIDDING_ROUND_NUM := NULL;
      a_row.CONTRACTOR := NULL;
      a_row.DIRECTION_TO_LOC := NULL;
      a_row.DIRECTION_TO_LOC_OUOM := NULL;
      a_row.DISTANCE_REF_POINT := NULL;
      a_row.DISTANCE_TO_LOC := NULL;
      a_row.DISTANCE_TO_LOC_OUOM := NULL;
      a_row.DRILL_RIG_NUM := NULL;
      a_row.DRILL_SLOT_NO := NULL;
      a_row.DRILL_TOOL := NULL;
      a_row.EFFECTIVE_DATE := NULL;
      a_row.EXCEPTION_GRANTED := NULL;
      a_row.EXCEPTION_REQUESTED := NULL;
      a_row.EXPIRED_IND := NULL;
      a_row.EXPIRY_DATE := NULL;
      a_row.FEES_PAID_IND := NULL;
      a_row.LICENSEE := NULL;
      a_row.LICENSEE_CONTACT_ID := NULL;
      a_row.LICENSE_DATE := NULL;
      a_row.LICENSE_NUM := NULL;
      a_row.NO_OF_WELLS := NULL;
      a_row.OFFSHORE_COMPLETION_TYPE := NULL;
      a_row.PERMIT_REFERENCE_NUM := NULL;
      a_row.PERMIT_REISSUE_DATE := NULL;
      a_row.PERMIT_TYPE := NULL;
      a_row.PLATFORM_NAME := NULL;
      a_row.PPDM_GUID := NULL;
      a_row.PROJECTED_DEPTH := NULL;
      a_row.PROJECTED_DEPTH_OUOM := NULL;
      a_row.PROJECTED_STRAT_UNIT_ID := NULL;
      a_row.PROJECTED_TVD := NULL;
      a_row.PROJECTED_TVD_OUOM := NULL;
      a_row.PROPOSED_SPUD_DATE := NULL;
      a_row.PURPOSE := NULL;
      a_row.RATE_SCHEDULE_ID := NULL;
      a_row.REGULATION := NULL;
      a_row.REGULATORY_AGENCY := NULL;
      a_row.REGULATORY_CONTACT_ID := NULL;
      a_row.REMARK := NULL;
      a_row.RIG_CODE := NULL;
      a_row.RIG_SUBSTR_HEIGHT := NULL;
      a_row.RIG_SUBSTR_HEIGHT_OUOM := NULL;
      a_row.RIG_TYPE := NULL;
      a_row.SECTION_OF_REGULATION := NULL;
      a_row.STRAT_NAME_SET_ID := NULL;
      a_row.SURVEYOR := NULL;
      a_row.TARGET_OBJECTIVE_FLUID := NULL;
      a_row.IPL_PROJECTED_STRAT_AGE := NULL;
      a_row.IPL_ALT_SOURCE := NULL;
      a_row.IPL_XACTION_CODE := NULL;
      a_row.ROW_CHANGED_BY := NULL;
      a_row.ROW_CHANGED_DATE := NULL;
      a_row.ROW_CREATED_BY := NULL;
      a_row.ROW_CREATED_DATE := NULL;
      a_row.IPL_WELL_OBJECTIVE := NULL;
      a_row.ROW_QUALITY := NULL;
   END null_license_row;

   /*----------------------------------------------------------------------------------------------------------
   Function:  null_status_row
   Detail:    This procedure set all the attributes to null in the well status row

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE null_status_row (a_row IN OUT NOCOPY well_status%ROWTYPE)
   IS
   BEGIN
      a_row.UWI := NULL;
      a_row.SOURCE := NULL;
      a_row.ACTIVE_IND := NULL;
      a_row.STATUS_ID := NULL;
      a_row.EFFECTIVE_DATE := NULL;
      a_row.EXPIRY_DATE := NULL;
      a_row.PPDM_GUID := NULL;
      a_row.REMARK := NULL;
      a_row.STATUS := NULL;
      a_row.STATUS_DATE := NULL;
      a_row.STATUS_DEPTH := NULL;
      a_row.STATUS_DEPTH_OUOM := NULL;
      a_row.IPL_XACTION_CODE := NULL;
      a_row.Status_Type := NULL;
      a_row.ROW_CHANGED_BY := NULL;
      a_row.ROW_CHANGED_DATE := NULL;
      a_row.ROW_CREATED_BY := NULL;
      a_row.ROW_CREATED_DATE := NULL;
      a_row.ROW_QUALITY := NULL;
   END null_status_row;

   /*----------------------------------------------------------------------------------------------------------
   Function:  UPDATE_WV_ATTRIBUTES
   Detail:    This procedure sets attributes to the new values.

   Created On: Jan. 2013
   History of Change:
       K.Edwards       Added params OPERATOR and IPL_LICENSEE
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE UPDATE_WV_ATTRIBUTES (
      WV_REC                    IN OUT WELL_VERSION%ROWTYPE,
      P_TLM_ID                         WELL_VERSION.UWI%TYPE,
      P_SOURCE                         WELL_VERSION.SOURCE%TYPE,
      P_COUNTRY                        WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE                 WELL_VERSION.PROVINCE_STATE%TYPE,
      P_WELL_NAME                      WELL_VERSION.WELL_NAME%TYPE,
      P_PLOT_NAME                      WELL_VERSION.PLOT_NAME%TYPE,
      P_KB_ELEV                        WELL_VERSION.KB_ELEV%TYPE,
      P_KB_ELEV_OUOM                   WELL_VERSION.KB_ELEV_OUOM%TYPE,
      P_GROUND_ELEV                    WELL_VERSION.GROUND_ELEV%TYPE,
      P_GROUND_ELEV_OUOM               WELL_VERSION.GROUND_ELEV_OUOM%TYPE,
      P_REMARK                         WELL_VERSION.REMARK%TYPE,
      P_WELL_NUM                       WELL_VERSION.WELL_NUM%TYPE,
      P_UWI                            WELL_VERSION.IPL_UWI_LOCAL%TYPE,
      P_BOTTOM_HOLE_LATITUDE           WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE,
      P_BOTTOM_HOLE_LONGITUDE          WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE,
      P_SURFACE_LATITUDE               WELL_VERSION.SURFACE_LATITUDE%TYPE,
      P_SURFACE_LONGITUDE              WELL_VERSION.SURFACE_LONGITUDE%TYPE,
      P_STATUS                         WELL_VERSION.CURRENT_STATUS%TYPE,
      P_DRILL_TD                       WELL_VERSION.DRILL_TD%TYPE,
      P_DRILL_TD_OUOM                  WELL_VERSION.DRILL_TD_OUOM%TYPE,
      P_OPERATOR                       WELL_VERSION.OPERATOR%TYPE,
      P_IPL_LICENSEE                   WELL_VERSION.IPL_LICENSEE%TYPE,
      P_REGULATORY_AGENCY              WELL_VERSION.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_ACTION_CD                      VARCHAR2)
   IS
      V_WELL_STATUS_CD   WELL_VERSION.CURRENT_STATUS%TYPE;
   BEGIN
      WV_REC.UWI := P_TLM_ID;
      WV_REC.SOURCE := P_SOURCE;
      WV_REC.ACTIVE_IND := 'Y';

      IF P_ACTION_CD = 'U'
      THEN
         WV_REC.ROW_CHANGED_DATE := SYSDATE;
         WV_REC.ROW_CHANGED_BY := USER;
      ELSE
         WV_REC.ROW_CREATED_DATE := SYSDATE;
         WV_REC.ROW_CREATED_BY := USER;
      END IF;

      --NOW UPDATE ONLY REQUIRED ATTRIBUTES
      IF P_COUNTRY IS NOT NULL
      THEN
         WV_REC.COUNTRY := P_COUNTRY;
      END IF;

      IF P_PROVINCE_STATE IS NOT NULL
      THEN
         WV_REC.PROVINCE_STATE := P_PROVINCE_STATE;
      END IF;

      IF P_WELL_NAME IS NOT NULL
      THEN
         WV_REC.WELL_NAME := P_WELL_NAME;
      END IF;

      IF P_PLOT_NAME IS NOT NULL
      THEN
         WV_REC.PLOT_NAME := P_PLOT_NAME;
      END IF;

      IF P_KB_ELEV IS NOT NULL
      THEN
         WV_REC.KB_ELEV := P_KB_ELEV;
      END IF;

      IF P_KB_ELEV_OUOM IS NOT NULL
      THEN
         WV_REC.KB_ELEV_OUOM := P_KB_ELEV_OUOM;
      END IF;

      IF P_GROUND_ELEV IS NOT NULL
      THEN
         WV_REC.GROUND_ELEV := P_GROUND_ELEV;
      END IF;

      IF P_GROUND_ELEV_OUOM IS NOT NULL
      THEN
         WV_REC.GROUND_ELEV_OUOM := P_GROUND_ELEV_OUOM;
      END IF;

      IF P_REMARK IS NOT NULL
      THEN
         WV_REC.REMARK := P_REMARK;
      END IF;

      --?????
      --SHOULD WE ALLOW CHANGING WELL_NUM FOR 300, 500 OR 450 SOURCE
      IF P_WELL_NUM IS NOT NULL
      THEN
         WV_REC.WELL_NUM := P_WELL_NUM;
      END IF;

      IF P_UWI IS NOT NULL
      THEN
         WV_REC.IPL_UWI_LOCAL := P_UWI;
      END IF;

      IF P_WELL_NUM IS NOT NULL
      THEN
         WV_REC.WELL_NUM := P_WELL_NUM;
      END IF;

      IF P_BOTTOM_HOLE_LATITUDE IS NOT NULL
      THEN
         WV_REC.BOTTOM_HOLE_LATITUDE := P_BOTTOM_HOLE_LATITUDE;
      END IF;

      IF P_BOTTOM_HOLE_LONGITUDE IS NOT NULL
      THEN
         WV_REC.BOTTOM_HOLE_LONGITUDE := P_BOTTOM_HOLE_LONGITUDE;
      END IF;

      IF P_SURFACE_LATITUDE IS NOT NULL
      THEN
         WV_REC.SURFACE_LATITUDE := P_SURFACE_LATITUDE;
      END IF;

      IF P_SURFACE_LONGITUDE IS NOT NULL
      THEN
         WV_REC.SURFACE_LONGITUDE := P_SURFACE_LONGITUDE;
      END IF;

      IF P_STATUS IS NOT NULL
      THEN
         --GET THE STATUS ID TO POPULATE CURRENT_STATUS AND USE THE SAME STATUS ID TO POPULATE WELL_STATUS TABLE.
         V_WELL_STATUS_CD := GETWELLSTATUS (P_STATUS);
         WV_REC.CURRENT_STATUS := V_WELL_STATUS_CD;
      END IF;
      
      IF P_DRILL_TD IS NOT NULL
      THEN
          WV_REC.DRILL_TD := P_DRILL_TD;
      END IF;
      
      IF P_DRILL_TD_OUOM IS NOT NULL
      THEN
          WV_REC.DRILL_TD_OUOM := P_DRILL_TD_OUOM;
      END IF;
      
      IF P_OPERATOR IS NOT NULL
      THEN
         WV_REC.OPERATOR := P_OPERATOR;
      END IF;

      IF P_IPL_LICENSEE IS NOT NULL
      THEN
         WV_REC.IPL_LICENSEE := P_IPL_LICENSEE;
      END IF;
      
      IF P_REGULATORY_AGENCY IS NOT NULL
      THEN
         WV_REC.REGULATORY_AGENCY := P_REGULATORY_AGENCY;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE_APPLICATION_ERROR (
            -20002,
               'AN ERROR WAS ENCOUNTERED IN UPDATE_WIM.UPDATE_WV_ATTRIBUTES '
            || SQLERRM);
   END;
  
  /*----------------------------------------------------------------------------------------------------------
   Function:  UPDATE_WNV_ATTRIBUTE_COUNTRY
   Detail:    This procedure sets Well_Node_Version's COUNTRY AND PROVINCE/STATE attributes to the new values.

   Created On: Nov. 2014
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE UPDATE_WNV_ATTRIBUTE_COUNTRY (
      P_SOURCE                        WELL_VERSION.SOURCE%TYPE,
      P_TLM_ID                        WELL_VERSION.UWI%TYPE,
      P_COUNTRY                       WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE                WELL_VERSION.PROVINCE_STATE%TYPE)
   IS
   BEGIN
      update ppdm.well_node_version
      set country = p_country,
        province_state = p_province_state
      where ipl_uwi = p_tlm_id
          and source = p_source
      ;
      
      wim.wim_rollup.well_rollup(p_tlm_id);
   END UPDATE_WNV_ATTRIBUTE_COUNTRY;
  
   /*----------------------------------------------------------------------------------------------------------
   Function:  UPDATE_WNV_ATTRIBUTES
   Detail:    This procedure sets Well_Node_Version's attributes to the new values.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE UPDATE_WNV_ATTRIBUTES (
      WNV_REC                  IN OUT WELL_NODE_VERSION%ROWTYPE,
      P_SOURCE                        WELL_VERSION.SOURCE%TYPE,
      P_TLM_ID                        WELL_VERSION.UWI%TYPE,
      P_LATITUDE                      WELL_NODE_VERSION.LATITUDE%TYPE,
      P_LONGITUDE                     WELL_NODE_VERSION.LONGITUDE%TYPE,
      P_NODE_ID                       WELL_NODE_VERSION.NODE_ID%TYPE,
      P_GEOG_COORD_SYSTEM_ID          WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE,
      P_LOCATION_QUALIFIER            WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE,
      P_NODE_POSITION                 WELL_NODE_VERSION.NODE_POSITION%TYPE,
      P_NODE_OBS_NO                   WELL_NODE_VERSION.NODE_OBS_NO%TYPE,
      P_ACTION_CD                     VARCHAR2,
      P_COUNTRY                       WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE                WELL_VERSION.PROVINCE_STATE%TYPE,
      P_REMARK                        WELL_NODE_VERSION.REMARK%TYPE)
   IS
   BEGIN
      WNV_REC.NODE_ID := P_NODE_ID;
      WNV_REC.GEOG_COORD_SYSTEM_ID := P_GEOG_COORD_SYSTEM_ID;
      WNV_REC.LOCATION_QUALIFIER := P_LOCATION_QUALIFIER;
      WNV_REC.SOURCE := P_SOURCE;
      WNV_REC.ACTIVE_IND := 'Y';
      WNV_REC.IPL_UWI := P_TLM_ID;
      
      IF P_ACTION_CD = 'U'
      THEN
         WNV_REC.ROW_CHANGED_DATE := SYSDATE;
         WNV_REC.ROW_CHANGED_BY := USER;
      END IF;

      IF P_ACTION_CD = 'A'
      THEN
         WNV_REC.ROW_CREATED_DATE := SYSDATE;
         WNV_REC.ROW_CREATED_BY := USER;
      END IF;

      WNV_REC.NODE_POSITION := P_NODE_POSITION;
      
      IF P_COUNTRY IS NOT NULL THEN
        WNV_REC.COUNTRY := P_COUNTRY;
      END IF;
      
      IF P_PROVINCE_STATE IS NOT NULL THEN
        WNV_REC.PROVINCE_STATE := P_PROVINCE_STATE;
      END IF;  
      
      IF P_LATITUDE IS NOT NULL
      THEN
         WNV_REC.LATITUDE := P_LATITUDE;
      END IF;

      IF P_LONGITUDE IS NOT NULL
      THEN
         WNV_REC.LONGITUDE := P_LONGITUDE;
      END IF;
      
      IF P_REMARK IS NOT NULL
      THEN
         WNV_REC.REMARK := P_REMARK;
      END IF;
   END UPDATE_WNV_ATTRIBUTES;

   /*----------------------------------------------------------------------------------------------------------
   Function:  UPDATE_WL_ATTRIBUTES
   Detail:    This procedure sets Well_License's attributes to the new values.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/

   PROCEDURE UPDATE_WL_ATTRIBUTES (
      WL_REC          IN OUT     WELL_LICENSE%ROWTYPE,
      P_SOURCE                   WELL_VERSION.SOURCE%TYPE,
      P_TLM_ID                   WELL_VERSION.UWI%TYPE,
      P_WL_AGENT                 WELL_LICENSE.AGENT%TYPE DEFAULT NULL,
      P_WL_LICENSE_NUM           WELL_LICENSE.LICENSE_NUM%TYPE DEFAULT NULL,
      P_WL_CONTRACTOR            WELL_LICENSE.CONTRACTOR%TYPE DEFAULT NULL,
      P_WL_LICENSEE              WELL_LICENSE.LICENSEE%TYPE DEFAULT NULL,
      P_WL_LICENSEE_CONTACT_ID   WELL_LICENSE.LICENSEE_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_REGULATORY_AGENCY     WELL_LICENSE.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_WL_REGULATORY_CONTACT_ID WELL_LICENSE.REGULATORY_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_SURVEYOR              WELL_LICENSE.SURVEYOR%TYPE DEFAULT NULL,
      P_ACTION_CD                VARCHAR2)
   IS
   BEGIN
      WL_REC.UWI := P_TLM_ID;
      WL_REC.LICENSE_ID := P_TLM_ID;
      WL_REC.SOURCE := P_SOURCE;
      WL_REC.ACTIVE_IND := 'Y';

      IF P_ACTION_CD = 'U'
      THEN
         WL_REC.ROW_CHANGED_DATE := SYSDATE;
         WL_REC.ROW_CHANGED_BY := USER;
      END IF;

      IF P_ACTION_CD = 'A'
      THEN
         WL_REC.ROW_CREATED_DATE := SYSDATE;
         WL_REC.ROW_CREATED_BY := USER;
      END IF;


      IF P_WL_AGENT IS NOT NULL
      THEN
         WL_REC.AGENT := P_WL_AGENT;
      END IF;
      
      IF P_WL_LICENSE_NUM IS NOT NULL
      THEN
         WL_REC.LICENSE_NUM := P_WL_LICENSE_NUM;
      END IF;
      
      IF P_WL_CONTRACTOR IS NOT NULL
      THEN
         WL_REC.CONTRACTOR := P_WL_CONTRACTOR;
      END IF;
      
      IF P_WL_LICENSEE IS NOT NULL
      THEN
         WL_REC.LICENSEE := P_WL_LICENSEE;
      END IF;
      
      IF P_WL_LICENSEE_CONTACT_ID IS NOT NULL
      THEN
         WL_REC.LICENSEE_CONTACT_ID := P_WL_LICENSEE_CONTACT_ID;
      END IF;
      
      IF P_WL_REGULATORY_AGENCY IS NOT NULL
      THEN
         WL_REC.REGULATORY_AGENCY := P_WL_REGULATORY_AGENCY;
      END IF;
      
      IF P_WL_REGULATORY_CONTACT_ID IS NOT NULL
      THEN
         WL_REC.REGULATORY_CONTACT_ID := P_WL_REGULATORY_CONTACT_ID;
      END IF;
      
      IF P_WL_SURVEYOR IS NOT NULL
      THEN
         WL_REC.SURVEYOR := P_WL_SURVEYOR;
      END IF;
   END UPDATE_WL_ATTRIBUTES;

   /*----------------------------------------------------------------------------------------------------------
   Function:  UPDATE_WS_ATTRIBUTES
   Detail:    This procedure sets Well_Status' attributes to the new values.

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/

   PROCEDURE UPDATE_WS_ATTRIBUTES (
      WS_REC        IN OUT WELL_STATUS%ROWTYPE,
      P_SOURCE             WELL_VERSION.SOURCE%TYPE,
      P_TLM_ID             WELL_VERSION.UWI%TYPE,
      P_STATUS             WELL_STATUS.STATUS%TYPE,
      P_ACTION_CD          VARCHAR2)
   IS
   BEGIN
      WS_REC.UWI := P_TLM_ID;
      WS_REC.SOURCE := P_SOURCE;
      WS_REC.ACTIVE_IND := 'Y';

      IF P_ACTION_CD = 'U'
      THEN
         WS_REC.ROW_CHANGED_DATE := SYSDATE;
         WS_REC.ROW_CHANGED_BY := USER;
      END IF;

      IF P_ACTION_CD = 'A'
      THEN
         WS_REC.ROW_CREATED_DATE := SYSDATE;
         WS_REC.ROW_CREATED_BY := USER;
      END IF;


      IF P_STATUS IS NOT NULL
      THEN
         WS_REC.STATUS := P_STATUS;
      END IF;
   END UPDATE_WS_ATTRIBUTES;

   /*----------------------------------------------------------------------------------------------------------
   PROCEDURE: Populate_STG_well_Version
   Detail:    This procedure POPULATES WIM_STG_WELL_VERSION TABLE

              This is called from UPDATE_WELL and CREATE_WELL functions

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE Populate_STG_well_Version (
      P_WIM_STG_ID    WIM.WIM_STG_REQUEST.WIM_STG_ID%TYPE,
      P_ACTION_CD     WIM.WIM_STG_WELL_VERSION.WIM_ACTION_CD%TYPE,
      P_WELL          WELL_VERSION%ROWTYPE)
   IS
   BEGIN
      INSERT INTO WIM.WIM_STG_WELL_VERSION (WIM_STG_ID,
                                            WIM_ACTION_CD,
                                            ACTIVE_IND,
                                            UWI,
                                            SOURCE,
                                            ABANDONMENT_DATE,
                                            ASSIGNED_FIELD,
                                            BASE_NODE_ID,
                                            BOTTOM_HOLE_LATITUDE,
                                            BOTTOM_HOLE_LONGITUDE,
                                            CASING_FLANGE_ELEV,
                                            WIM_CASING_FLANGE_ELEV_CUOM,
                                            CASING_FLANGE_ELEV_OUOM,
                                            Completion_Date,
                                            CONFIDENTIAL_DATE,
                                            CONFIDENTIAL_DEPTH,
                                            WIM_CONFIDENTIAL_DEPTH_CUOM,
                                            CONFIDENTIAL_DEPTH_OUOM,
                                            CONFIDENTIAL_TYPE,
                                            CONFID_STRAT_NAME_SET_ID,
                                            CONFID_STRAT_UNIT_ID,
                                            COUNTRY,
                                            COUNTY,
                                            CURRENT_CLASS,
                                            CURRENT_STATUS,
                                            CURRENT_STATUS_DATE,
                                            DEEPEST_DEPTH,
                                            WIM_DEEPEST_DEPTH_CUOM,
                                            DEEPEST_DEPTH_OUOM,
                                            Depth_Datum,
                                            Depth_Datum_Elev,
                                            WIM_Depth_Datum_Elev_CUOM,
                                            Depth_Datum_Elev_OUOM,
                                            DERRICK_FLOOR_ELEV,
                                            WIM_DERRICK_FLOOR_ELEV_CUOM,
                                            DERRICK_FLOOR_ELEV_OUOM,
                                            DIFFERENCE_LAT_MSL,
                                            DISCOVERY_IND,
                                            DISTRICT,
                                            DRILL_TD,
                                            WIM_Drill_TD_CUOM,
                                            Drill_TD_OUOM,
                                            EFFECTIVE_DATE,
                                            ELEV_REF_DATUM,
                                            EXPIRY_DATE,
                                            FAULTED_IND,
                                            FINAL_DRILL_DATE,
                                            FINAL_TD,
                                            WIM_FINAL_TD_CUOM,
                                            FINAL_TD_OUOM,
                                            GEOGRAPHIC_REGION,
                                            GEOLOGIC_PROVINCE,
                                            Ground_Elev,
                                            WIM_Ground_Elev_CUOM,
                                            Ground_Elev_OUOM,
                                            GROUND_ELEV_TYPE,
                                            INITIAL_CLASS,
                                            KB_ELEV,
                                            WIM_KB_ELEV_CUOM,
                                            KB_ELEV_OUOM,
                                            LEASE_NAME,
                                            LEASE_NUM,
                                            LEGAL_SURVEY_TYPE,
                                            LOCATION_TYPE,
                                            LOG_TD,
                                            WIM_LOG_TD_CUOM,
                                            LOG_TD_OUOM,
                                            MAX_TVD,
                                            WIM_MAX_TVD_CUOM,
                                            MAX_TVD_OUOM,
                                            NET_PAY,
                                            WIM_NET_PAY_CUOM,
                                            NET_PAY_OUOM,
                                            Oldest_Strat_Age,
                                            OLDEST_STRAT_NAME_SET_AGE,
                                            OLDEST_STRAT_NAME_SET_ID,
                                            Oldest_Strat_Unit_Id,
                                            Operator,
                                            PARENT_RELATIONSHIP_TYPE,
                                            Parent_UWI,
                                            PLATFORM_ID,
                                            PLATFORM_SF_TYPE,
                                            Plot_Name,
                                            Plot_Symbol,
                                            PLUGBACK_DEPTH,
                                            WIM_PLUGBACK_DEPTH_CUOM,
                                            PLUGBACK_DEPTH_OUOM,
                                            PPDM_GUID,
                                            PROFILE_TYPE,
                                            PROVINCE_STATE,
                                            REGULATORY_AGENCY,
                                            REMARK,
                                            RIG_ON_SITE_DATE,
                                            RIG_RELEASE_DATE,
                                            ROTARY_TABLE_ELEV,
                                            SOURCE_DOCUMENT,
                                            Spud_Date,
                                            STATUS_TYPE,
                                            SUBSEA_ELEV_REF_TYPE,
                                            SURFACE_LATITUDE,
                                            SURFACE_LONGITUDE,
                                            SURFACE_NODE_ID,
                                            TAX_CREDIT_CODE,
                                            TD_STRAT_AGE,
                                            TD_STRAT_NAME_SET_AGE,
                                            TD_STRAT_NAME_SET_ID,
                                            TD_STRAT_UNIT_ID,
                                            WATER_ACOUSTIC_VEL,
                                            WATER_ACOUSTIC_VEL_OUOM,
                                            Water_Depth,
                                            WATER_DEPTH_DATUM,
                                            WIM_WATER_DEPTH_CUOM,
                                            WATER_DEPTH_OUOM,
                                            WELL_EVENT_NUM,
                                            WELL_GOVERNMENT_ID,
                                            WELL_INTERSECT_MD,
                                            WELL_NAME,
                                            WELL_NUM,
                                            WELL_NUMERIC_ID,
                                            WHIPSTOCK_DEPTH,
                                            WIM_WHIPSTOCK_DEPTH_CUOM,
                                            WHIPSTOCK_DEPTH_OUOM,
                                            IPL_Licensee,
                                            IPL_OFFSHORE_IND,
                                            IPL_PIDStatus,
                                            IPL_PRSTATUS,
                                            IPL_ORSTATUS,
                                            IPL_ONPROD_DATE,
                                            IPL_ONINJECT_DATE,
                                            IPL_CONFIDENTIAL_STRAT_AGE,
                                            IPL_POOL,
                                            IPL_LAST_UPDATE,
                                            IPL_UWI_Sort,
                                            IPL_UWI_DISPLAY,
                                            IPL_TD_TVD,
                                            IPL_PLUGBACK_TVD,
                                            IPL_WHIPSTOCK_TVD,
                                            IPL_WATER_TVD,
                                            IPL_ALT_Source,
                                            IPL_xAction_Code,
                                            ROW_CHANGED_BY,
                                            ROW_CHANGED_DATE,
                                            ROW_CREATED_BY,
                                            ROW_CREATED_DATE,
                                            IPL_BASIN,
                                            IPL_BLOCK,
                                            IPL_AREA,
                                            IPL_TWP,
                                            IPL_TRACT,
                                            IPL_LOT,
                                            IPL_CONC,
                                            IPL_UWI_LOCAL,
                                            ROW_QUALITY)
           VALUES (P_WIM_STG_ID,
                   P_ACTION_CD,
                   P_WELL.ACTIVE_IND,
                   P_WELL.UWI,
                   P_WELL.SOURCE,
                   P_WELL.ABANDONMENT_DATE,
                   P_WELL.ASSIGNED_FIELD,
                   P_WELL.BASE_NODE_ID,
                   P_WELL.BOTTOM_HOLE_LATITUDE,
                   P_WELL.BOTTOM_HOLE_LONGITUDE,
                   P_WELL.CASING_FLANGE_ELEV,
                   'M',
                   P_WELL.CASING_FLANGE_ELEV_OUOM,
                   P_WELL.Completion_Date,
                   P_WELL.CONFIDENTIAL_DATE,
                   P_WELL.CONFIDENTIAL_DEPTH,
                   'M',
                   P_WELL.CONFIDENTIAL_DEPTH_OUOM,
                   P_WELL.CONFIDENTIAL_TYPE,
                   P_WELL.CONFID_STRAT_NAME_SET_ID,
                   P_WELL.CONFID_STRAT_UNIT_ID,
                   P_WELL.COUNTRY,
                   P_WELL.COUNTY,
                   P_WELL.CURRENT_CLASS,
                   P_WELL.CURRENT_STATUS,
                   P_WELL.CURRENT_STATUS_DATE,
                   P_WELL.DEEPEST_DEPTH,
                   'M',
                   P_WELL.DEEPEST_DEPTH_OUOM,
                   P_WELL.Depth_Datum,
                   P_WELL.Depth_Datum_Elev,
                   'M',
                   P_WELL.Depth_Datum_Elev_OUOM,
                   P_WELL.DERRICK_FLOOR_ELEV,
                   'M',
                   P_WELL.DERRICK_FLOOR_ELEV_OUOM,
                   P_WELL.DIFFERENCE_LAT_MSL,
                   P_WELL.DISCOVERY_IND,
                   P_WELL.DISTRICT,
                   P_WELL.DRILL_TD,
                   'M',
                   P_WELL.Drill_TD_OUOM,
                   P_WELL.EFFECTIVE_DATE,
                   P_WELL.ELEV_REF_DATUM,
                   P_WELL.EXPIRY_DATE,
                   P_WELL.FAULTED_IND,
                   P_WELL.FINAL_DRILL_DATE,
                   P_WELL.FINAL_TD,
                   'M',
                   P_WELL.FINAL_TD_OUOM,
                   P_WELL.GEOGRAPHIC_REGION,
                   P_WELL.GEOLOGIC_PROVINCE,
                   P_WELL.Ground_Elev,
                   'M',
                   P_WELL.Ground_Elev_OUOM,
                   P_WELL.GROUND_ELEV_TYPE,
                   P_WELL.INITIAL_CLASS,
                   P_WELL.KB_ELEV,
                   'M',
                   P_WELL.KB_ELEV_OUOM,
                   P_WELL.LEASE_NAME,
                   P_WELL.LEASE_NUM,
                   P_WELL.LEGAL_SURVEY_TYPE,
                   P_WELL.LOCATION_TYPE,
                   P_WELL.LOG_TD,
                   'M',
                   P_WELL.LOG_TD_OUOM,
                   P_WELL.MAX_TVD,
                   'M',
                   P_WELL.MAX_TVD_OUOM,
                   P_WELL.NET_PAY,
                   'M',
                   P_WELL.NET_PAY_OUOM,
                   P_WELL.Oldest_Strat_Age,
                   P_WELL.OLDEST_STRAT_NAME_SET_AGE,
                   P_WELL.OLDEST_STRAT_NAME_SET_ID,
                   P_WELL.Oldest_Strat_Unit_Id,
                   P_WELL.Operator,
                   P_WELL.PARENT_RELATIONSHIP_TYPE,
                   P_WELL.Parent_UWI,
                   P_WELL.PLATFORM_ID,
                   P_WELL.PLATFORM_SF_TYPE,
                   P_WELL.Plot_Name,
                   P_WELL.Plot_Symbol,
                   P_WELL.PLUGBACK_DEPTH,
                   'M',
                   P_WELL.PLUGBACK_DEPTH_OUOM,
                   P_WELL.PPDM_GUID,
                   P_WELL.PROFILE_TYPE,
                   P_WELL.PROVINCE_STATE,
                   P_WELL.REGULATORY_AGENCY,
                   P_WELL.REMARK,
                   P_WELL.RIG_ON_SITE_DATE,
                   P_WELL.RIG_RELEASE_DATE,
                   P_WELL.ROTARY_TABLE_ELEV,
                   P_WELL.SOURCE_DOCUMENT,
                   P_WELL.Spud_Date,
                   P_WELL.STATUS_TYPE,
                   P_WELL.SUBSEA_ELEV_REF_TYPE,
                   P_WELL.SURFACE_LATITUDE,
                   P_WELL.SURFACE_LONGITUDE,
                   P_WELL.SURFACE_NODE_ID,
                   P_WELL.TAX_CREDIT_CODE,
                   P_WELL.TD_STRAT_AGE,
                   P_WELL.TD_STRAT_NAME_SET_AGE,
                   P_WELL.TD_STRAT_NAME_SET_ID,
                   P_WELL.TD_STRAT_UNIT_ID,
                   P_WELL.WATER_ACOUSTIC_VEL,
                   P_WELL.WATER_ACOUSTIC_VEL_OUOM,
                   P_WELL.Water_Depth,
                   P_WELL.WATER_DEPTH_DATUM,
                   'M',
                   P_WELL.WATER_DEPTH_OUOM,
                   P_WELL.WELL_EVENT_NUM,
                   P_WELL.WELL_GOVERNMENT_ID,
                   P_WELL.WELL_INTERSECT_MD,
                   P_WELL.WELL_NAME,
                   P_WELL.WELL_NUM,
                   P_WELL.WELL_NUMERIC_ID,
                   P_WELL.WHIPSTOCK_DEPTH,
                   'M',
                   P_WELL.WHIPSTOCK_DEPTH_OUOM,
                   P_WELL.IPL_Licensee,
                   P_WELL.IPL_OFFSHORE_IND,
                   P_WELL.IPL_PIDStatus,
                   P_WELL.IPL_PRSTATUS,
                   P_WELL.IPL_ORSTATUS,
                   P_WELL.IPL_ONPROD_DATE,
                   P_WELL.IPL_ONINJECT_DATE,
                   P_WELL.IPL_CONFIDENTIAL_STRAT_AGE,
                   P_WELL.IPL_POOL,
                   P_WELL.IPL_LAST_UPDATE,
                   P_WELL.IPL_UWI_Sort,
                   P_WELL.IPL_UWI_DISPLAY,
                   P_WELL.IPL_TD_TVD,
                   P_WELL.IPL_PLUGBACK_TVD,
                   P_WELL.IPL_WHIPSTOCK_TVD,
                   P_WELL.IPL_WATER_TVD,
                   P_WELL.IPL_ALT_Source,
                   P_WELL.IPL_xAction_Code,
                   P_WELL.ROW_CHANGED_BY,
                   P_WELL.ROW_CHANGED_DATE,
                   P_WELL.ROW_CREATED_BY,
                   P_WELL.ROW_CREATED_DATE,
                   P_WELL.IPL_BASIN,
                   P_WELL.IPL_BLOCK,
                   P_WELL.IPL_AREA,
                   P_WELL.IPL_TWP,
                   P_WELL.IPL_TRACT,
                   P_WELL.IPL_LOT,
                   P_WELL.IPL_CONC,
                   P_WELL.IPL_UWI_LOCAL,
                   P_WELL.ROW_QUALITY);
   EXCEPTION
      WHEN OTHERS
      THEN
         tlm_process_logger.error (
               'WIM_GATEWAY.UPDATE_WIM Interface FAILED in POPULATE_STG_WELL_VERSION: Oracle Error - '
            || SQLERRM);
         ROLLBACK;
   END Populate_STG_well_Version;

   /*----------------------------------------------------------------------------------------------------------
   PROCEDURE: Populate_STG_well_Node_Version
   Detail:    This procedure POPULATES WIM_STG_WELL_NODE_VERSION TABLE

              This is called from UPDATE_WELL and CREATE_WELL functions

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/

   PROCEDURE POPULATE_STG_WELL_NODE_VERSION (
      P_WELL_NODE     WELL_NODE_vERSION%ROWTYPE,
      P_SEQ           NUMBER,
      P_WIM_STG_ID    WIM_STG_REQUEST.WIM_STG_ID%TYPE,
      P_ACTION_CD     VARCHAR2)
   IS
      v_Geog_Coord_System_ID   PPDM.CS_COORDINATE_SYSTEM.COORD_SYSTEM_ID%TYPE;
   BEGIN
      --DBMS_OUTPUT.PUT_LINE('NODE ACTION ' || P_ACTION_CD);
      --DBMS_OUTPUT.PUT_LINE(P_WELL_NODE.Geog_Coord_System_ID);
      --Need to use this wehn all the geog_coord_system_ids are converted to numeric
      --  v_Geog_Coord_System_ID := Get_Coord_System_ID(P_WELL_NODE.Geog_Coord_System_ID);

      v_Geog_Coord_System_ID := P_WELL_NODE.Geog_Coord_System_ID;


      INSERT INTO WIM.WIM_STG_WELL_NODE_VERSION (WIM_STG_ID,
                                                 WIM_SEQ,
                                                 WIM_ACTION_CD,
                                                 Node_Id,
                                                 SOURCE,
                                                 NODE_OBS_NO,
                                                 ACQUISITION_ID,
                                                 ACTIVE_IND,
                                                 COUNTRY,
                                                 COUNTY,
                                                 EASTING,
                                                 WIM_EASTING_CUOM,
                                                 EASTING_OUOM,
                                                 EFFECTIVE_DATE,
                                                 ELEV,
                                                 WIM_ELEV_CUOM,
                                                 ELEV_OUOM,
                                                 EW_DIRECTION,
                                                 EXPIRY_DATE,
                                                 GEOG_COORD_SYSTEM_ID,
                                                 Latitude,
                                                 Legal_Survey_type,
                                                 LOCATION_QUALIFIER,
                                                 LOCATION_QUALITY,
                                                 Longitude,
                                                 MAP_COORD_SYSTEM_ID,
                                                 MD,
                                                 WIM_MD_CUOM,
                                                 MD_OUOM,
                                                 MONUMENT_ID,
                                                 MONUMENT_SF_TYPE,
                                                 NODE_POSITION,
                                                 NORTHING,
                                                 WIM_NORTHING_CUOM,
                                                 NORTHING_OUOM,
                                                 NORTH_TYPE,
                                                 NS_DIRECTION,
                                                 POLAR_AZIMUTH,
                                                 POLAR_OFFSET,
                                                 WIM_POLAR_OFFSET_CUOM,
                                                 POLAR_OFFSET_OUOM,
                                                 PPDM_GUID,
                                                 PREFERRED_IND,
                                                 PROVINCE_STATE,
                                                 Remark,
                                                 REPORTED_TVD,
                                                 WIM_REPORTED_TVD_CUOM,
                                                 REPORTED_TVD_OUOM,
                                                 VERSION_TYPE,
                                                 X_OFFSET,
                                                 WIM_X_OFFSET_CUOM,
                                                 X_OFFSET_OUOM,
                                                 Y_OFFSET,
                                                 WIM_Y_OFFSET_CUOM,
                                                 Y_OFFSET_OUOM,
                                                 IPL_XACTION_CODE,
                                                 ROW_CHANGED_BY,
                                                 ROW_CHANGED_DATE,
                                                 ROW_CREATEd_BY,
                                                 ROW_CREATED_DATE,
                                                 IPL_UWI,
                                                 ROW_QUALITY)
           VALUES (P_WIM_STG_ID,
                   P_SEQ,
                   P_Action_Cd,
                   P_WELL_NODE.Node_ID,
                   P_WELL_NODE.source,
                   P_WELL_NODE.NODE_OBS_NO,
                   P_WELL_NODE.ACQUISITION_ID,
                   P_WELL_NODE.ACTIVE_IND,
                   P_WELL_NODE.COUNTRY,
                   P_WELL_NODE.COUNTY,
                   P_WELL_NODE.EASTING,
                   'M',
                   P_WELL_NODE.EASTING_OUOM,
                   P_WELL_NODE.EFFECTIVE_DATE,
                   P_WELL_NODE.ELEV,
                   'M',
                   P_WELL_NODE.ELEV_OUOM,
                   P_WELL_NODE.EW_DIRECTION,
                   P_WELL_NODE.EXPIRY_DATE,
                   v_GEOG_COORD_SYSTEM_ID,
                   P_WELL_NODE.Latitude,
                   P_WELL_NODE.Legal_Survey_type,
                   P_WELL_NODE.LOCATION_QUALIFIER,
                   P_WELL_NODE.LOCATION_QUALITY,
                   P_WELL_NODE.Longitude,
                   P_WELL_NODE.MAP_COORD_SYSTEM_ID,
                   P_WELL_NODE.MD,
                   'M',
                   P_WELL_NODE.MD_OUOM,
                   P_WELL_NODE.MONUMENT_ID,
                   P_WELL_NODE.MONUMENT_SF_TYPE,
                   P_WELL_NODE.NODE_POSITION,
                   P_WELL_NODE.NORTHING,
                   'M',
                   P_WELL_NODE.NORTHING_OUOM,
                   P_WELL_NODE.NORTH_TYPE,
                   P_WELL_NODE.NS_DIRECTION,
                   P_WELL_NODE.POLAR_AZIMUTH,
                   P_WELL_NODE.POLAR_OFFSET,
                   'M',
                   P_WELL_NODE.POLAR_OFFSET_OUOM,
                   P_WELL_NODE.PPDM_GUID,
                   P_WELL_NODE.PREFERRED_IND,
                   P_WELL_NODE.PROVINCE_STATE,
                   P_WELL_NODE.Remark,
                   P_WELL_NODE.REPORTED_TVD,
                   'M',
                   P_WELL_NODE.REPORTED_TVD_OUOM,
                   P_WELL_NODE.VERSION_TYPE,
                   P_WELL_NODE.X_OFFSET,
                   'M',
                   P_WELL_NODE.X_OFFSET_OUOM,
                   P_WELL_NODE.Y_OFFSET,
                   'M',
                   P_WELL_NODE.Y_OFFSET_OUOM,
                   P_WELL_NODE.IPL_XACTION_CODE,
                   P_WELL_NODE.ROW_CHANGED_BY,
                   P_WELL_NODE.ROW_CHANGED_DATE,
                   P_WELL_NODE.ROW_CREATEd_BY,
                   P_WELL_NODE.ROW_CREATED_DATE,
                   P_WELL_NODE.ipl_uwi,
                   P_WELL_NODE.ROW_QUALITY);
   EXCEPTION
      WHEN OTHERS
      THEN
         tlm_process_logger.error (
               'WIM_GATEWAY.UPDATE_WIM Interface FAILED in POPULATE_STG_WELL_NODE_VERSION: Oracle Error - '
            || SQLERRM);
         ROLLBACK;
   END;

   /*----------------------------------------------------------------------------------------------------------
   PROCEDURE: Populate_STG_well_Status
   Detail:    This procedure POPULATES WIM_STG_WELL_STATUS TABLE

              This is called from UPDATE_WELL and CREATE_WELL functions

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE POPULATE_STG_WELL_STATUS (
      P_WELL_STATUS    WELL_STATUS%ROWTYPE,
      P_WIM_STG_ID     WIM_STG_REQUEST.WIM_STG_ID%TYPE,
      P_ACTION_CD      VARCHAR2,
      P_STATUS_ID      WELL_STATUS.STATUS_ID%TYPE,
      P_SEQ            NUMBER)
   IS
   BEGIN
      INSERT INTO WIM_STG_WELL_STATUS (WIM_STG_ID,
                                       WIM_SEQ,
                                       WIM_ACTION_CD,
                                       UWI,
                                       SOURCE,
                                       ACTIVE_IND,
                                       status_id,
                                       EFFECTIVE_DATE,
                                       EXPIRY_DATE,
                                       PPDM_GUID,
                                       REMARK,
                                       STATUS,
                                       STATUS_DATE,
                                       STATUS_DEPTH,
                                       WIM_STATUS_DEPTH_CUOM,
                                       STATUS_DEPTH_OUOM,
                                       IPL_XACTION_CODE,
                                       STATUS_TYPE,
                                       ROW_CHANGED_BY,
                                       ROW_CHANGED_DATE,
                                       ROW_CREATED_BY,
                                       ROW_CREATED_DATE,
                                       ROW_QUALITY)
           VALUES (P_WIM_STG_ID,
                   P_SEQ,
                   p_Action_Cd,
                   P_WELL_STATUS.UWI,
                   P_WELL_STATUS.SOURCE,
                   P_WELL_STATUS.ACTIVE_IND,
                   P_STATUS_ID,
                   P_WELL_STATUS.EFFECTIVE_DATE,
                   P_WELL_STATUS.EXPIRY_DATE,
                   P_WELL_STATUS.PPDM_GUID,
                   P_WELL_STATUS.REMARK,
                   P_WELL_STATUS.STATUS,
                   P_WELL_STATUS.STATUS_DATE,
                   P_WELL_STATUS.STATUS_DEPTH,
                   'M',
                   P_WELL_STATUS.STATUS_DEPTH_OUOM,
                   P_WELL_STATUS.IPL_XACTION_CODE,
                   P_WELL_STATUS.STATUS_TYPE,
                   P_WELL_STATUS.ROW_CHANGED_BY,
                   P_WELL_STATUS.ROW_CHANGED_DATE,
                   P_WELL_STATUS.ROW_CREATED_BY,
                   P_WELL_STATUS.ROW_CREATED_DATE,
                   P_WELL_STATUS.ROW_QUALITY);
   EXCEPTION
      WHEN OTHERS
      THEN
         tlm_process_logger.error (
               'WIM_GATEWAY.UPDATE_WIM Interface FAILED in POPULATE_STG_WELL_STATUS: Oracle Error - '
            || SQLERRM);
         ROLLBACK;
   END;

   /*----------------------------------------------------------------------------------------------------------
   PROCEDURE: Populate_STG_well_License
   Detail:    This procedure POPULATES WIM_STG_WELL_LICENSE TABLE

              This is called from UPDATE_WELL and CREATE_WELL functions

   Created On: Jan. 2013
   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE POPULATE_STG_WELL_LICENSE (
      P_WELL_LIC      WELL_LICENSE%ROWTYPE,
      P_WIM_STG_ID    WIM_STG_REQUEST.WIM_STG_ID%TYPE,
      P_ACTION_CD     VARCHAR2)
   IS
   BEGIN
      INSERT INTO WIM.WIM_STG_WELL_LICENSE (WIM_STG_ID,
                                            WIM_ACTION_CD,
                                            UWI,
                                            LICENSE_ID,
                                            ACTIVE_IND,
                                            AGENT,
                                            APPLICATION_ID,
                                            AUTHORIZED_STRAT_UNIT_ID,
                                            BIDDING_ROUND_NUM,
                                            CONTRACTOR,
                                            DIRECTION_TO_LOC,
                                            WIM_DIRECTION_TO_LOC_CUOM,
                                            DIRECTION_TO_LOC_OUOM,
                                            DISTANCE_REF_POINT,
                                            DISTANCE_TO_LOC,
                                            WIM_DISTANCE_TO_LOC_CUOM,
                                            DISTANCE_TO_LOC_OUOM,
                                            DRILL_RIG_NUM,
                                            DRILL_SLOT_NO,
                                            DRILL_TOOL,
                                            EFFECTIVE_DATE,
                                            EXCEPTION_GRANTED,
                                            EXCEPTION_REQUESTED,
                                            EXPIRED_IND,
                                            EXPIRY_DATE,
                                            FEES_PAID_IND,
                                            LICENSEE,
                                            LICENSEE_CONTACT_ID,
                                            LICENSE_DATE,
                                            LICENSE_NUM,
                                            NO_OF_WELLS,
                                            OFFSHORE_COMPLETION_TYPE,
                                            PERMIT_REFERENCE_NUM,
                                            PERMIT_REISSUE_DATE,
                                            PERMIT_TYPE,
                                            PLATFORM_NAME,
                                            PPDM_GUID,
                                            PROJECTED_DEPTH,
                                            WIM_PROJECTED_DEPTH_CUOM,
                                            PROJECTED_DEPTH_OUOM,
                                            PROJECTED_STRAT_UNIT_ID,
                                            PROJECTED_TVD,
                                            WIM_PROJECTED_TVD_CUOM,
                                            PROJECTED_TVD_OUOM,
                                            PROPOSED_SPUD_DATE,
                                            PURPOSE,
                                            RATE_SCHEDULE_ID,
                                            REGULATION,
                                            REGULATORY_AGENCY,
                                            REGULATORY_CONTACT_ID,
                                            REMARK,
                                            RIG_CODE,
                                            RIG_SUBSTR_HEIGHT,
                                            WIM_RIG_SUBSTR_HEIGHT_CUOM,
                                            RIG_SUBSTR_HEIGHT_OUOM,
                                            RIG_TYPE,
                                            SECTION_OF_REGULATION,
                                            STRAT_NAME_SET_ID,
                                            SURVEYOR,
                                            TARGET_OBJECTIVE_FLUID,
                                            IPL_PROJECTED_STRAT_AGE,
                                            IPL_ALT_SOURCE,
                                            IPL_XACTION_CODE,
                                            ROW_CHANGED_BY,
                                            ROW_CHANGED_DATE,
                                            ROW_CREATED_BY,
                                            ROW_CREATED_DATE,
                                            IPL_WELL_OBJECTIVE,
                                            ROW_QUALITY)
           VALUES (P_WIM_STG_ID,
                   P_ACTION_CD,
                   P_WELL_LIC.UWI,
                   P_WELL_LIC.UWI,
                   P_WELL_LIC.ACTIVE_IND,
                   P_WELL_LIC.AGENT,
                   P_WELL_LIC.APPLICATION_ID,
                   P_WELL_LIC.AUTHORIZED_STRAT_UNIT_ID,
                   P_WELL_LIC.BIDDING_ROUND_NUM,
                   P_WELL_LIC.CONTRACTOR,
                   P_WELL_LIC.DIRECTION_TO_LOC,
                   'M',
                   P_WELL_LIC.DIRECTION_TO_LOC_OUOM,
                   P_WELL_LIC.DISTANCE_REF_POINT,
                   P_WELL_LIC.DISTANCE_TO_LOC,
                   'M',
                   P_WELL_LIC.DISTANCE_TO_LOC_OUOM,
                   P_WELL_LIC.DRILL_RIG_NUM,
                   P_WELL_LIC.DRILL_SLOT_NO,
                   P_WELL_LIC.DRILL_TOOL,
                   P_WELL_LIC.EFFECTIVE_DATE,
                   P_WELL_LIC.EXCEPTION_GRANTED,
                   P_WELL_LIC.EXCEPTION_REQUESTED,
                   P_WELL_LIC.EXPIRED_IND,
                   P_WELL_LIC.EXPIRY_DATE,
                   P_WELL_LIC.FEES_PAID_IND,
                   P_WELL_LIC.LICENSEE,
                   P_WELL_LIC.LICENSEE_CONTACT_ID,
                   P_WELL_LIC.LICENSE_DATE,
                   P_WELL_LIC.LICENSE_NUM,
                   P_WELL_LIC.NO_OF_WELLS,
                   P_WELL_LIC.OFFSHORE_COMPLETION_TYPE,
                   P_WELL_LIC.PERMIT_REFERENCE_NUM,
                   P_WELL_LIC.PERMIT_REISSUE_DATE,
                   P_WELL_LIC.PERMIT_TYPE,
                   P_WELL_LIC.PLATFORM_NAME,
                   P_WELL_LIC.PPDM_GUID,
                   P_WELL_LIC.PROJECTED_DEPTH,
                   'M',
                   P_WELL_LIC.PROJECTED_DEPTH_OUOM,
                   P_WELL_LIC.PROJECTED_STRAT_UNIT_ID,
                   P_WELL_LIC.PROJECTED_TVD,
                   'M',
                   P_WELL_LIC.PROJECTED_TVD_OUOM,
                   P_WELL_LIC.PROPOSED_SPUD_DATE,
                   P_WELL_LIC.PURPOSE,
                   P_WELL_LIC.RATE_SCHEDULE_ID,
                   P_WELL_LIC.REGULATION,
                   P_WELL_LIC.REGULATORY_AGENCY,
                   P_WELL_LIC.REGULATORY_CONTACT_ID,
                   P_WELL_LIC.REMARK,
                   P_WELL_LIC.RIG_CODE,
                   P_WELL_LIC.RIG_SUBSTR_HEIGHT,
                   'M',
                   P_WELL_LIC.RIG_SUBSTR_HEIGHT_OUOM,
                   P_WELL_LIC.RIG_TYPE,
                   P_WELL_LIC.SECTION_OF_REGULATION,
                   P_WELL_LIC.STRAT_NAME_SET_ID,
                   P_WELL_LIC.SURVEYOR,
                   P_WELL_LIC.TARGET_OBJECTIVE_FLUID,
                   P_WELL_LIC.IPL_PROJECTED_STRAT_AGE,
                   P_WELL_LIC.IPL_ALT_SOURCE,
                   P_WELL_LIC.IPL_XACTION_CODE,
                   P_WELL_LIC.ROW_CHANGED_BY,
                   P_WELL_LIC.ROW_CHANGED_DATE,
                   P_WELL_LIC.ROW_CREATED_BY,
                   P_WELL_LIC.ROW_CREATED_DATE,
                   P_WELL_LIC.IPL_WELL_OBJECTIVE,
                   P_WELL_LIC.ROW_QUALITY);
   EXCEPTION
      WHEN OTHERS
      THEN
         tlm_process_logger.error (
               'WIM_GATEWAY.UPDATE_WIM Interface FAILED in POPULATE_STG_WELL_LICENSE: Oracle Error - '
            || SQLERRM);
         ROLLBACK;
   END;

   /*----------------------------------------------------------------------------------------------------------
   FUNCTION:    UPDATE_WELL
   DETAIL:        THIS FUNCTION UPATES EXISTING WELL IN WIM DATABASE USING PARAMETERS PROVIDED.
               ONLY IF THE NEW VALUES PROVIDED ARE DIFFERENT FROM WHAT IN THE TABLE
               IF NODE DATA IS PROVIDED, THEN IT WILL ADD OR UPDATE NODE
               IF LICENSE_NUM IS PROVIDED, IT WILL ADD OR UPDATE LICENSE RECORD
               IF STATUS IS PROVIDED, IT WILL ADD OR UPDATE STATUS RECORD.

   CREATED ON: JAN. 2013
   HISTORY OF CHANGE:
       K.Edwards    21-Feb-2013        Added OPERATOR, IPL_LICENSEE, CONTRACTOR and WL_LICENSEE attributes
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION UPDATE_WELL (
      P_TLM_ID                      WELL_VERSION.UWI%TYPE,
      P_SOURCE                      WELL_VERSION.SOURCE%TYPE,
      P_COUNTRY                     WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE              WELL_VERSION.PROVINCE_STATE%TYPE DEFAULT NULL,
      P_WELL_NAME                   WELL_VERSION.WELL_NAME%TYPE DEFAULT NULL, --could be null for override version
      P_PLOT_NAME                   WELL_VERSION.PLOT_NAME%TYPE DEFAULT NULL,
      P_KB_ELEV                     WELL_VERSION.KB_ELEV%TYPE DEFAULT NULL,
      P_KB_ELEV_OUOM                WELL_VERSION.KB_ELEV_OUOM%TYPE DEFAULT NULL,
      P_GROUND_ELEV                 WELL_VERSION.GROUND_ELEV%TYPE DEFAULT NULL,
      P_GROUND_ELEV_OUOM            WELL_VERSION.GROUND_ELEV_OUOM%TYPE DEFAULT NULL,
      P_REMARK                      WELL_VERSION.REMARK%TYPE DEFAULT NULL,
      P_WELL_NUM                    WELL_VERSION.WELL_NUM%TYPE DEFAULT NULL,
      P_UWI                         WELL_VERSION.IPL_UWI_LOCAL%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LATITUDE        WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LONGITUDE       WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LATITUDE            WELL_VERSION.SURFACE_LATITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LONGITUDE           WELL_VERSION.SURFACE_LONGITUDE%TYPE DEFAULT NULL,
      P_STATUS                      WELL_VERSION.CURRENT_STATUS%TYPE DEFAULT NULL,
      P_DRILL_TD                    WELL_VERSION.DRILL_TD%TYPE DEFAULT NULL,
      P_DRILL_TD_OUOM               WELL_VERSION.DRILL_TD_OUOM%TYPE DEFAULT NULL,
      P_OPERATOR                    WELL_VERSION.OPERATOR%TYPE DEFAULT NULL,
      P_IPL_LICENSEE                WELL_VERSION.IPL_LICENSEE%TYPE DEFAULT NULL,
      P_REGULATORY_AGENCY           WELL_VERSION.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_BH_LOCATION_QUALIFIER       WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_BH_GEOG_COORD_SYSTEM_ID     WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_BH_NODE_OBS_NO              WELL_NODE_VERSION.NODE_OBS_NO%TYPE DEFAULT NULL,
      P_SUR_LOCATION_QUALIFIER      WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_SUR_GEOG_COORD_SYSTEM_ID    WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_SUR_NODE_OBS_NO             WELL_NODE_VERSION.NODE_OBS_NO%TYPE DEFAULT NULL,
      P_WL_AGENT                    WELL_LICENSE.AGENT%TYPE DEFAULT NULL,
      P_WL_LICENSE_NUM              WELL_LICENSE.LICENSE_NUM%TYPE DEFAULT NULL,
      P_WL_CONTRACTOR               WELL_LICENSE.CONTRACTOR%TYPE DEFAULT NULL,
      P_WL_LICENSEE                 WELL_LICENSE.LICENSEE%TYPE DEFAULT NULL,
      P_WL_LICENSEE_CONTACT_ID      WELL_LICENSE.LICENSEE_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_REGULATORY_AGENCY        WELL_LICENSE.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_WL_REGULATORY_CONTACT_ID    WELL_LICENSE.REGULATORY_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_SURVEYOR                 WELL_LICENSE.SURVEYOR%TYPE DEFAULT NULL)          
      RETURN NUMBER
   IS
      V_ACTION_CD        VARCHAR2 (1);
      V_NUM              NUMBER;
      V_WIM_STG_ID       WIM_STG_REQUEST.WIM_STG_ID%TYPE;
      V_TLM_ID           WELL_VERSION.UWI%TYPE;
      V_WELL_STATUS_CD   WELL_VERSION.CURRENT_STATUS%TYPE;
      V_SOURCE           WELL_VERSION.SOURCE%TYPE;
      V_STATUS           VARCHAR2 (20);
      V_AUDIT_ID         NUMBER;
      V_AUDIT_NO         NUMBER;
      V_NODE_ID          WELL_NODE_VERSION.NODE_ID%TYPE;
      WV_REC             WELL_VERSION%ROWTYPE;
      WNV_REC            WELL_NODE_VERSION%ROWTYPE;
      WL_REC             WELL_LICENSE%ROWTYPE;
      WS_REC             WELL_STATUS%ROWTYPE;
      V_STATUS_ID        WELL_STATUS.STATUS_ID%TYPE;
      V_CURRENT_ACTION   VARCHAR2 (50);
      V_CHANGES          NUMBER;
   BEGIN
      V_ACTION_CD := 'U';
      V_SOURCE := P_SOURCE;
      V_CHANGES := 0;

      IF P_SOURCE IS NULL
      THEN
         PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO (
            'WIM_GATEWAY.UPDATE_WELL FAILED: SOURCE IS MISSING');
         RETURN 0;
      END IF;

      IF P_TLM_ID IS NULL
      THEN
         PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO (
            'WIM_GATEWAY.UPDATE_WELL FAILED: TLM_ID IS MISSING');
         RETURN 0;
      END IF;

      --CHECK IF UWI ALREADY EXISTS
      IF WIM_GATEWAY.FIND_WELL (P_TLM_ID,
                                'TLM_ID',
                                P_SOURCE,
                                'V')
            IS NULL
      THEN
         PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO (
            'WIM_GATEWAY.UPDATE_WELL FAILED: TLM_ID IS NOT FOUND');
         RETURN 0;
      END IF;

      V_CURRENT_ACTION := 'WELL_VERSION';

      --WELL_VERSION--
      -- GET THE CURRENT ROW OF WELL_VERSION
      SELECT *
        INTO WV_REC
        FROM WELL_VERSION
       WHERE UWI = P_TLM_ID AND SOURCE = V_SOURCE AND ACTIVE_IND = 'Y';

      -- GET COUNTRY CODE AND PROVINCE STATE CODES FROM REF TABLES???
      -- CHECK IF PARAMETERS PASSED ARE DIFFERENT FROM WHAT IS IN THE TABLE. IF NO DIFFERENCE,
      -- NO NEED TO DO ANYTHING.
      IF (
          (P_COUNTRY IS NULL OR WV_REC.COUNTRY = P_COUNTRY)
          AND (P_PROVINCE_STATE IS NULL OR WV_REC.PROVINCE_STATE = P_PROVINCE_STATE)
          AND (P_WELL_NAME IS NULL OR WV_REC.WELL_NAME = P_WELL_NAME)
          AND (P_PLOT_NAME IS NULL OR WV_REC.PLOT_NAME = P_PLOT_NAME)
          AND (P_KB_ELEV IS NULL OR WV_REC.KB_ELEV = P_KB_ELEV)
          AND (P_KB_ELEV_OUOM IS NULL OR WV_REC.KB_ELEV_OUOM = P_KB_ELEV_OUOM)
          AND (P_GROUND_ELEV IS NULL OR WV_REC.GROUND_ELEV = P_GROUND_ELEV)
          AND (P_GROUND_ELEV_OUOM IS NULL OR WV_REC.GROUND_ELEV_OUOM = P_GROUND_ELEV_OUOM)
          AND (P_REMARK IS NULL OR WV_REC.REMARK = P_REMARK)
          AND (P_WELL_NUM IS NULL OR WV_REC.WELL_NUM = P_WELL_NUM)
          AND (P_UWI IS NULL OR WV_REC.IPL_UWI_LOCAL = P_UWI)
          AND (P_BOTTOM_HOLE_LATITUDE IS NULL OR WV_REC.BOTTOM_HOLE_LATITUDE = P_BOTTOM_HOLE_LATITUDE)
          AND (P_BOTTOM_HOLE_LONGITUDE IS NULL OR WV_REC.BOTTOM_HOLE_LONGITUDE = P_BOTTOM_HOLE_LONGITUDE)
          AND (P_SURFACE_LATITUDE IS NULL OR WV_REC.SURFACE_LATITUDE = P_SURFACE_LATITUDE)
          AND (P_SURFACE_LONGITUDE IS NULL OR WV_REC.SURFACE_LONGITUDE = P_SURFACE_LONGITUDE)
          AND (P_STATUS IS NULL OR  WV_REC.CURRENT_STATUS = GETWELLSTATUS (P_STATUS))
          AND (P_DRILL_TD IS NULL OR WV_REC.DRILL_TD = P_DRILL_TD)
          AND (P_DRILL_TD_OUOM IS NULL OR WV_REC.DRILL_TD_OUOM = P_DRILL_TD_OUOM)
          AND (P_OPERATOR IS NULL OR WV_REC.OPERATOR = P_OPERATOR)
          AND (P_IPL_LICENSEE IS NULL OR WV_REC.IPL_LICENSEE = P_IPL_LICENSEE)
      )
      THEN
         -- NO CHANGE TO WELL_VERSION, THERE COULD BE CHANGES TO WELL_STATUS OR WELL_LICENSE OR NODES.
         -- CAN'T END HERE
         V_ACTION_CD := 'X';
      --  DBMS_OUTPUT.PUT_LINE('NO CHANGES TO WELL_VERSION');
      --RETURN 0;
      ELSE
         V_CHANGES := V_CHANGES + 1;
         --UPDATE THE ATTRIBUTES PROVIDED
         UPDATE_WV_ATTRIBUTES (WV_REC,
                               P_TLM_ID,
                               P_SOURCE,
                               P_COUNTRY,
                               P_PROVINCE_STATE,
                               P_WELL_NAME,
                               P_PLOT_NAME,
                               P_KB_ELEV,
                               P_KB_ELEV_OUOM,
                               P_GROUND_ELEV,
                               P_GROUND_ELEV_OUOM,
                               P_REMARK,
                               P_WELL_NUM,
                               P_UWI,
                               P_BOTTOM_HOLE_LATITUDE,
                               P_BOTTOM_HOLE_LONGITUDE,
                               P_SURFACE_LATITUDE,
                               P_SURFACE_LONGITUDE,
                               P_STATUS,
                               P_DRILL_TD,
                               P_DRILL_TD_OUOM,
                               P_OPERATOR,
                               P_IPL_LICENSEE,
                               P_REGULATORY_AGENCY,
                               V_ACTION_CD);
      END IF;

         -- INSERT INTO WIM_STG_REQUEST
         INSERT
           INTO WIM.WIM_STG_REQUEST (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
         VALUES ('R', USER, SYSDATE)
      RETURNING WIM_STG_ID
           INTO V_WIM_STG_ID;

      --POPULATE WIM_STG_WELL_VERSION TABLE
      POPULATE_STG_WELL_VERSION (V_WIM_STG_ID, V_ACTION_CD, WV_REC);

      --******  NODES ******----
      IF (P_SURFACE_LATITUDE IS NOT NULL AND P_SURFACE_LONGITUDE IS NOT NULL)
      
      THEN
         V_CURRENT_ACTION := 'WELL_NODE_VERSION-SURFACE';

         --CHECK IF REQUIRED DATA IS PROVIDED
         IF (   P_SUR_GEOG_COORD_SYSTEM_ID IS NULL
             OR P_SUR_LOCATION_QUALIFIER IS NULL
             OR P_SUR_NODE_OBS_NO IS NULL)
         THEN
            -- ERROR: DATA MISSING
            TLM_PROCESS_LOGGER.ERROR (
               'WIM_GATEWAY.UPDATE_WELL INTERFACE FAILED. NOT ALL THE REQUIRED DATA PROVIDED FOR SURFACE NODE UPDATES');
            RETURN 0;                               --OR GO TO THE NEXT STEP??
         END IF;

         V_NODE_ID := P_TLM_ID || '1';
         V_ACTION_CD :=
            CHECKWELLNODEVERSION (V_NODE_ID,
                                  P_SUR_GEOG_COORD_SYSTEM_ID,
                                  P_SUR_NODE_OBS_NO,
                                  P_SOURCE,
                                  P_SUR_LOCATION_QUALIFIER);

         IF V_ACTION_CD = 'A'
         THEN
            SELECT *
              INTO WNV_REC
              FROM WELL_NODE_VERSION
             WHERE ROWNUM = 1;

            NULL_NODE_ROW (WNV_REC);
         END IF;

         IF V_ACTION_CD = 'U'
         THEN
            SELECT *
              INTO WNV_REC
              FROM WELL_NODE_VERSION
             WHERE     IPL_UWI = P_TLM_ID
                   AND SOURCE = P_SOURCE
                   AND NODE_POSITION = 'S'
                   AND NODE_OBS_NO = P_SUR_NODE_OBS_NO
                   AND NODE_ID = V_NODE_ID
                   AND GEOG_COORD_SYSTEM_ID = P_SUR_GEOG_COORD_SYSTEM_ID
                   AND LOCATION_QUALIFIER = P_SUR_LOCATION_QUALIFIER;

            --CHECK WE NEED TO RUN THIS UPDATE

            IF (    (   P_SURFACE_LATITUDE IS NULL
                     OR WNV_REC.LATITUDE = P_SURFACE_LATITUDE)
                AND (   P_COUNTRY IS NULL
                     OR WNV_REC.COUNTRY = P_COUNTRY)
                AND (   P_PROVINCE_STATE IS NULL
                     OR WNV_REC.PROVINCE_STATE = P_PROVINCE_STATE)
                AND (   P_SURFACE_LONGITUDE IS NULL
                     OR WNV_REC.LONGITUDE = P_SURFACE_LONGITUDE)
                AND (   P_SUR_GEOG_COORD_SYSTEM_ID IS NULL
                     OR WNV_REC.GEOG_COORD_SYSTEM_ID =
                           P_SUR_GEOG_COORD_SYSTEM_ID)
                AND (   P_SUR_LOCATION_QUALIFIER IS NULL
                     OR WNV_REC.LOCATION_QUALIFIER = P_SUR_LOCATION_QUALIFIER)
                AND (   P_SUR_NODE_OBS_NO IS NULL
                     OR WNV_REC.NODE_OBS_NO = P_SUR_NODE_OBS_NO))
            THEN
               GOTO THE_SUR_END;
            END IF;
         END IF;

         V_CHANGES := V_CHANGES + 1;
         
         -- UPDATE WELL_NODE_VERSION ATTRIBUTES
         UPDATE_WNV_ATTRIBUTES (WNV_REC,
                                P_SOURCE,
                                P_TLM_ID,
                                P_SURFACE_LATITUDE,
                                P_SURFACE_LONGITUDE,
                                V_NODE_ID,
                                P_SUR_GEOG_COORD_SYSTEM_ID,
                                P_SUR_LOCATION_QUALIFIER,
                                'S',
                                P_SUR_NODE_OBS_NO,
                                V_ACTION_CD,
                                P_COUNTRY,
                                P_PROVINCE_STATE,
                                P_REMARK);

         --POPULATE WIM_STG_WELL_NODE_VERSION TABLE
         POPULATE_STG_WELL_NODE_VERSION (WNV_REC,
                                         1,
                                         V_WIM_STG_ID,
                                         V_ACTION_CD);

        <<THE_SUR_END>>
         NULL;
      ELSE
          UPDATE_WNV_ATTRIBUTE_COUNTRY(P_SOURCE,
                                P_TLM_ID,
                                P_COUNTRY,
                                P_PROVINCE_STATE
                                );
      END IF;


      IF (P_BOTTOM_HOLE_LATITUDE IS NOT NULL AND P_BOTTOM_HOLE_LONGITUDE IS NOT NULL)
      THEN
         V_CURRENT_ACTION := 'WELL_NODE_VERSION-BASE';

         --CHECK IF REQUIRED DATA IS PROVIDED
         IF (   P_BH_GEOG_COORD_SYSTEM_ID IS NULL
             OR P_BH_LOCATION_QUALIFIER IS NULL
             OR P_BH_NODE_OBS_NO IS NULL)
         THEN
            -- ERROR: DATA MISSING
            TLM_PROCESS_LOGGER.ERROR (
               'WIM_GATEWAY.UPDATE_WELL INTERFACE FAILED: NOT ALL THE REQUIRED DATA PROVIDED FOR BASE NODE UPDATE');
            RETURN 0;                               --OR GO TO THE NEXT STEP??
         END IF;

         V_NODE_ID := P_TLM_ID || '0';
         V_ACTION_CD :=
            CHECKWELLNODEVERSION (V_NODE_ID,
                                  P_BH_GEOG_COORD_SYSTEM_ID,
                                  P_BH_NODE_OBS_NO,
                                  P_SOURCE,
                                  P_BH_LOCATION_QUALIFIER);

         IF V_ACTION_CD = 'A'
         THEN
            SELECT *
              INTO WNV_REC
              FROM WELL_NODE_VERSION
             WHERE ROWNUM = 1;

            NULL_NODE_ROW (WNV_REC);
         END IF;

         IF V_ACTION_CD = 'U'
         THEN
            SELECT *
              INTO WNV_REC
              FROM WELL_NODE_VERSION
             WHERE     IPL_UWI = P_TLM_ID
                   AND SOURCE = P_SOURCE
                   AND NODE_POSITION = 'B'
                   AND NODE_OBS_NO = P_BH_NODE_OBS_NO
                   AND NODE_ID = V_NODE_ID
                   AND GEOG_COORD_SYSTEM_ID = P_BH_GEOG_COORD_SYSTEM_ID
                   AND LOCATION_QUALIFIER = P_BH_LOCATION_QUALIFIER;

            IF (    (   P_BOTTOM_HOLE_LATITUDE IS NULL
                     OR WNV_REC.LATITUDE = P_BOTTOM_HOLE_LATITUDE)
                AND (   P_BOTTOM_HOLE_LONGITUDE IS NULL
                     OR WNV_REC.LONGITUDE = P_BOTTOM_HOLE_LONGITUDE)
                AND (   P_COUNTRY IS NULL
                     OR WNV_REC.COUNTRY = P_COUNTRY)
                AND (   P_PROVINCE_STATE IS NULL
                     OR WNV_REC.PROVINCE_STATE = P_PROVINCE_STATE)
                 AND (   P_BH_GEOG_COORD_SYSTEM_ID IS NULL
                     OR WNV_REC.GEOG_COORD_SYSTEM_ID =
                           P_BH_GEOG_COORD_SYSTEM_ID)
                AND (   P_BH_LOCATION_QUALIFIER IS NULL
                     OR WNV_REC.LOCATION_QUALIFIER = P_BH_LOCATION_QUALIFIER)
                AND (   P_BH_NODE_OBS_NO IS NULL
                     OR WNV_REC.NODE_OBS_NO = P_BH_NODE_OBS_NO))
            THEN
               GOTO THE_BH_END;
            END IF;
         END IF;

         V_CHANGES := V_CHANGES + 1;
        
         -- UPDATE ATTRIBUTES
         UPDATE_WNV_ATTRIBUTES (WNV_REC,
                                P_SOURCE,
                                P_TLM_ID,
                                P_BOTTOM_HOLE_LATITUDE,
                                P_BOTTOM_HOLE_LONGITUDE,
                                V_NODE_ID,
                                P_BH_GEOG_COORD_SYSTEM_ID,
                                P_BH_LOCATION_QUALIFIER,
                                'B',
                                P_BH_NODE_OBS_NO,
                                V_ACTION_CD,
                                P_COUNTRY,
                                P_PROVINCE_STATE,
                                P_REMARK);

         --POPULATE WIM_STG_WELL_NODE_VERSION TABLE
         POPULATE_STG_WELL_NODE_VERSION (WNV_REC,
                                         2,
                                         V_WIM_STG_ID,
                                         V_ACTION_CD);

        <<THE_BH_END>>
         NULL;
      else
          UPDATE_WNV_ATTRIBUTE_COUNTRY(P_SOURCE,
                                P_TLM_ID,
                                P_COUNTRY,
                                P_PROVINCE_STATE
                                );
      END IF;


      --WIM_STG_WELL_LICENSE
      IF P_WL_LICENSE_NUM IS NOT NULL
      THEN
         V_CURRENT_ACTION := 'WELL_LICENSE';

         --FIND OUT WHAT THE ACTION CODE IS
         V_ACTION_CD := CHECKWELLLICENSE (P_TLM_ID, P_SOURCE);

         IF V_ACTION_CD = 'A'
         THEN
            SELECT *
              INTO WL_REC
              FROM WELL_LICENSE
             WHERE ROWNUM = 1;

            NULL_LICENSE_ROW (WL_REC);
         ELSIF V_ACTION_CD = 'U'
         THEN
            --IF IT IS THERE ALREADY, DO NEED DO ANYTHING??
            SELECT *
              INTO WL_REC
              FROM WELL_LICENSE
             WHERE     UWI = P_TLM_ID
                   AND SOURCE = V_SOURCE
                   AND LICENSE_ID = P_TLM_ID
                   AND ACTIVE_IND = 'Y';

            IF (    (   P_WL_LICENSE_NUM IS NULL
                     OR WL_REC.LICENSE_NUM = P_WL_LICENSE_NUM)
                AND (   P_WL_AGENT IS NULL
                     OR WL_REC.AGENT = P_WL_AGENT)
                AND (   P_WL_CONTRACTOR IS NULL
                     OR WL_REC.CONTRACTOR = P_WL_CONTRACTOR)
                AND (   P_WL_LICENSEE IS NULL
                     OR WL_REC.LICENSEE = P_WL_LICENSEE)
                AND (   P_WL_LICENSEE_CONTACT_ID IS NULL
                     OR WL_REC.LICENSEE_CONTACT_ID = P_WL_LICENSEE_CONTACT_ID)
                AND (   P_WL_REGULATORY_AGENCY IS NULL
                     OR WL_REC.REGULATORY_AGENCY = P_WL_REGULATORY_AGENCY)
                AND (   P_WL_REGULATORY_CONTACT_ID IS NULL
                     OR WL_REC.REGULATORY_CONTACT_ID = P_WL_REGULATORY_CONTACT_ID)
                AND (   P_WL_SURVEYOR IS NULL
                     OR WL_REC.SURVEYOR = P_WL_SURVEYOR))
            THEN
               GOTO THE_LIC_END;
            END IF;
         END IF;

         V_CHANGES := V_CHANGES + 1;

         UPDATE_WL_ATTRIBUTES (WL_REC,
                               P_SOURCE,
                               P_TLM_ID,
                               P_WL_AGENT,
                               P_WL_LICENSE_NUM,
                               P_WL_CONTRACTOR,
                               P_WL_LICENSEE,
                               P_WL_LICENSEE_CONTACT_ID,
                               P_WL_REGULATORY_AGENCY,
                               P_WL_REGULATORY_CONTACT_ID,
                               P_WL_SURVEYOR,
                               V_ACTION_CD);

         POPULATE_STG_WELL_LICENSE (P_WELL_LIC     => WL_REC,
                                    P_WIM_STG_ID   => V_WIM_STG_ID,
                                    P_ACTION_CD    => V_ACTION_CD);

        <<THE_LIC_END>>
         NULL;
      END IF;

      --WIM_STG_WELL_STATUS
      IF P_STATUS IS NOT NULL
      THEN
         V_CURRENT_ACTION := 'WELL_STATUS';
         V_WELL_STATUS_CD := GETWELLSTATUS (P_STATUS);

         -- IF V_WELL_STATUS_CD IS NULL, MEANS DOESN'T EXIST IN R_WELL_STATUS TABLE, THEN DONT PROCESS IT.
         -- DBMS_OUTPUT.PUT_LINE(V_WELL_STATUS_CD);
         IF V_WELL_STATUS_CD IS NOT NULL
         THEN
            V_ACTION_CD :=
               CHECKWELLSTATUS (P_TLM_ID,
                                V_SOURCE,
                                V_WELL_STATUS_CD,
                                V_STATUS_ID);

            -- DBMS_OUTPUT.PUT_LINE(V_ACTION_CD ||'-'||P_TLM_ID || '-' || V_SOURCE ||'-' || V_WELL_STATUS_CD || '-' || V_STATUS_ID);
            IF V_ACTION_CD = 'A'
            THEN
               SELECT *
                 INTO WS_REC
                 FROM WELL_STATUS
                WHERE ROWNUM = 1;

               NULL_STATUS_ROW (WS_REC);
            ELSIF V_ACTION_CD = 'U'
            THEN
               -- DONT NEED TO DO ANYTHING HERE, IT IS THERE ALREADY. ??????
               -- COULD RETURN MULTIPLES
               -- CHANGE TO GET THE LATEST ONE
               SELECT *
                 INTO WS_REC
                 FROM WELL_STATUS
                WHERE     UWI = P_TLM_ID
                      AND SOURCE = V_SOURCE
                      AND STATUS = V_WELL_STATUS_CD
                      AND ACTIVE_IND = 'Y';

               IF (P_STATUS IS NULL OR WS_REC.STATUS = V_WELL_STATUS_CD)
               THEN
                  GOTO THE_STATUS_END;
               END IF;
            END IF;

            V_CHANGES := V_CHANGES + 1;

            UPDATE_WS_ATTRIBUTES (WS_REC,
                                  P_SOURCE,
                                  P_TLM_ID,
                                  V_WELL_STATUS_CD,
                                  V_ACTION_CD);

            POPULATE_STG_WELL_STATUS (P_WELL_STATUS   => WS_REC,
                                      P_WIM_STG_ID    => V_WIM_STG_ID,
                                      P_ACTION_CD     => V_ACTION_CD,
                                      P_STATUS_ID     => V_STATUS_ID,
                                      P_SEQ           => 1);
         END IF;

        <<THE_STATUS_END>>
         -- DBMS_OUTPUT.PUT_LINE('NO STATUS CHANGES');
         NULL;
      END IF;

      IF V_CHANGES > 0
      THEN
         COMMIT;
         --CALL WELL_ACTION
         WIM.WIM_GATEWAY.WELL_ACTION (V_WIM_STG_ID,
                                      V_TLM_ID,
                                      V_STATUS,
                                      V_AUDIT_NO);
         RETURN 1;
      END IF;

      --DBMS_OUTPUT.PUT_LINE ('NO CHANGES WERE MADE');
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_AUDIT_ID := WIM_AUDIT.GET_AUDIT_ID ();
         WIM_AUDIT.AUDIT_EVENT (
            PAUDIT_ID     => V_AUDIT_ID,
            PACTION       => V_ACTION_CD,
            PTLM_ID       => P_TLM_ID,
            PSOURCE       => V_SOURCE,
            PTEXT         => SUBSTR (
                                  'UPDATE_WIM INTERFACE FAILED IN '
                               || V_CURRENT_ACTION
                               || ' : ORACLE ERROR : '
                               || ' - '
                               || SQLERRM,
                               1,
                               255),
            PAUDIT_TYPE   => 'F',
            PUSER         => USER);
         ROLLBACK;
         RETURN 0;
   END UPDATE_WELL;

   /*----------------------------------------------------------------------------------------------------------
   Function:  CREATE_WELL
   Detail:    This Function creates a new well in WIM database using parameters provided.
              Create new Node(s) if provided
              Creates License if provided
              Created Status if provided

   Created On: Jan. 2013
   History of Change:
       K.Edwards    21-Feb-2013        Added OPERATOR, IPL_LICENSEE, CONTRACTOR and WL_LICENSEE attributes
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION CREATE_WELL (
      P_TLM_ID                     IN OUT WELL_VERSION.UWI%TYPE,
      P_SOURCE                            WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      P_COUNTRY                           WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE                    WELL_VERSION.PROVINCE_STATE%TYPE DEFAULT NULL,
      P_WELL_NAME                         WELL_VERSION.WELL_NAME%TYPE DEFAULT NULL, --could be null for override version
      P_PLOT_NAME                         WELL_VERSION.PLOT_NAME%TYPE DEFAULT NULL,
      P_KB_ELEV                           WELL_VERSION.KB_ELEV%TYPE DEFAULT NULL,
      P_KB_ELEV_OUOM                      WELL_VERSION.KB_ELEV_OUOM%TYPE DEFAULT NULL,
      P_GROUND_ELEV                       WELL_VERSION.GROUND_ELEV%TYPE DEFAULT NULL,
      P_GROUND_ELEV_OUOM                  WELL_VERSION.GROUND_ELEV_OUOM%TYPE DEFAULT NULL,
      P_REMARK                            WELL_VERSION.REMARK%TYPE DEFAULT NULL,
      P_WELL_NUM                          WELL_VERSION.WELL_NUM%TYPE DEFAULT NULL,
      P_UWI                               WELL_VERSION.IPL_UWI_LOCAL%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LATITUDE              WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LONGITUDE             WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LATITUDE                  WELL_VERSION.SURFACE_LATITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LONGITUDE                 WELL_VERSION.SURFACE_LONGITUDE%TYPE DEFAULT NULL,
      P_STATUS                            WELL_VERSION.CURRENT_STATUS%TYPE DEFAULT NULL,
      P_DRILL_TD                          WELL_VERSION.DRILL_TD%TYPE DEFAULT NULL,
      P_DRILL_TD_OUOM                     WELL_VERSION.DRILL_TD_OUOM%TYPE DEFAULT NULL,      
      P_OPERATOR                          WELL_VERSION.OPERATOR%TYPE DEFAULT NULL,
      P_IPL_LICENSEE                      WELL_VERSION.IPL_LICENSEE%TYPE DEFAULT NULL,
      P_REGULATORY_AGENCY                 WELL_VERSION.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_BH_LOCATION_QUALIFIER             WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_BH_GEOG_COORD_SYSTEM_ID           WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_SUR_LOCATION_QUALIFIER            WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_SUR_GEOG_COORD_SYSTEM_ID          WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_WL_AGENT                          WELL_LICENSE.AGENT%TYPE DEFAULT NULL,
      P_WL_LICENSE_NUM                    WELL_LICENSE.LICENSE_NUM%TYPE DEFAULT NULL,
      P_WL_CONTRACTOR                     WELL_LICENSE.CONTRACTOR%TYPE DEFAULT NULL,
      P_WL_LICENSEE                       WELL_LICENSE.LICENSEE%TYPE DEFAULT NULL,
      P_WL_LICENSEE_CONTACT_ID            WELL_LICENSE.LICENSEE_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_REGULATORY_AGENCY              WELL_LICENSE.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_WL_REGULATORY_CONTACT_ID          WELL_LICENSE.REGULATORY_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_SURVEYOR                       WELL_LICENSE.SURVEYOR%TYPE DEFAULT NULL)          
      RETURN NUMBER
   IS
      V_ACTION_CD        VARCHAR2 (1);
      V_NUM              NUMBER;
      V_WIM_STG_ID       WIM_STG_REQUEST.WIM_STG_ID%TYPE;
      V_WELL_STATUS_CD   WELL_VERSION.CURRENT_STATUS%TYPE;
      V_NEW_TLM_ID       WELL_VERSION.UWI%TYPE;
      V_TLM_ID           WELL_VERSION.UWI%TYPE;
      V_NODE_ID          WELL_NODE_VERSION.NODE_ID%TYPE;
      V_STATUS_ID        WELL_STATUS.STATUS_ID%TYPE;
      V_SOURCE           WELL_VERSION.SOURCE%TYPE;
      V_STATUS           VARCHAR2 (20);
      V_AUDIT_NO         NUMBER;
      V_AUDIT_ID         NUMBER;
      WV_REC             WELL_VERSION%ROWTYPE;
      WNV_REC            WELL_NODE_VERSION%ROWTYPE;
      WL_REC             WELL_LICENSE%ROWTYPE;
      WS_REC             WELL_STATUS%ROWTYPE;
   BEGIN
      V_ACTION_CD := 'A';
      V_TLM_ID := P_TLM_ID;

      IF P_SOURCE IS NULL
      THEN
         V_SOURCE := '700TLME';
      ELSE
         V_SOURCE := P_SOURCE;
      END IF;

      --BEFORE STARTING, CHECK IF ALL THE MANDATORY PARAMETERS ARE PROVIDED,
      IF P_COUNTRY IS NULL OR (P_WELL_NAME IS NULL AND V_SOURCE != '075TLMO')
      THEN
         --DBMS_OUTPUT.PUT_LINE('UPDATE_WIM INTERFACE FAILED: REQUIRED DATA MISSING.');
         TLM_PROCESS_LOGGER.ERROR (
            'WIM_GATEWAY.CREATE_WELL INTERFACE FAILED: REQUIRED DATA MISSING.');
         RETURN 0;
      END IF;

      --IF UWI IS PROVIDED, CHECK IF UWI ALREADY EXISTS
      IF V_TLM_ID IS NOT NULL
      THEN                                        --AND V_ACTION_CD = 'C' THEN
         SELECT COUNT (1)
           INTO V_NUM
           FROM WELL_VERSION
          WHERE UWI = V_TLM_ID AND SOURCE = V_SOURCE;

         IF V_NUM > 0
         THEN                                                 -- ALREADY THERE
            TLM_PROCESS_LOGGER.ERROR (
                  'WIM_GATEWAY.CREATE_WELL INTERFACE FAILED: TLM_ID '
               || P_TLM_ID
               || '('
               || V_SOURCE
               || ') ALREADY EXISTS');
            RETURN 0;
         END IF;

         --CHECK IF OTHER VERSION OF THIS WELL EXISTS. IF NOT, THEN  REJECT
         SELECT COUNT (1)
           INTO V_NUM
           FROM WELL_VERSION
          WHERE UWI = V_TLM_ID AND SOURCE != V_SOURCE;

         IF V_NUM = 0
         THEN
            TLM_PROCESS_LOGGER.ERROR (
                  'WIM_GATEWAY.CREATE_WELL INTERFACE FAILED: TLM_ID '
               || P_TLM_ID
               || ' DOES NOT EXIST');
            RETURN 0;
         END IF;
      ELSE
         V_ACTION_CD := 'C'; --IF TLM_ID IS NOT PROVIDED, THEN ACTION_CD WILL BE'C'
      END IF;

         -- INSERT INTO WIM_STG_* TABLES

         --WIM_STG_REQUEST
         INSERT
           INTO WIM.WIM_STG_REQUEST (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
         VALUES ('R', USER, SYSDATE)
      RETURNING WIM_STG_ID
           INTO V_WIM_STG_ID;

      --WELL_VERSION--
      -- GET THE CURRENT ROW OF WELL_VERSION
      SELECT *
        INTO WV_REC
        FROM WELL_VERSION
       WHERE ROWNUM = 1;

      NULL_WELL_ROW (WV_REC);

      --UPDATE THE ATTRIBUTES PROVIDED
      UPDATE_WV_ATTRIBUTES (WV_REC,
                            P_TLM_ID,
                            V_SOURCE,
                            P_COUNTRY,
                            P_PROVINCE_STATE,
                            P_WELL_NAME,
                            P_PLOT_NAME,
                            P_KB_ELEV,
                            P_KB_ELEV_OUOM,
                            P_GROUND_ELEV,
                            P_GROUND_ELEV_OUOM,
                            P_REMARK,
                            P_WELL_NUM,
                            P_UWI,
                            P_BOTTOM_HOLE_LATITUDE,
                            P_BOTTOM_HOLE_LONGITUDE,
                            P_SURFACE_LATITUDE,
                            P_SURFACE_LONGITUDE,
                            P_STATUS,
                            P_DRILL_TD,
                            P_DRILL_TD_OUOM,
                            P_OPERATOR,
                            P_IPL_LICENSEE,
                            P_REGULATORY_AGENCY,
                            V_ACTION_CD);

      --POPULATE WIM_STG_WELL_VERSION TABLE
      POPULATE_STG_WELL_VERSION (V_WIM_STG_ID, V_ACTION_CD, WV_REC);

      --SURFACE NODES
      IF (P_SURFACE_LATITUDE IS NOT NULL AND P_SURFACE_LONGITUDE IS NOT NULL)
      THEN
         IF ( P_SUR_GEOG_COORD_SYSTEM_ID IS NULL
             OR P_SUR_LOCATION_QUALIFIER IS NULL)
         THEN
            -- ERROR: DATA MISSING
            TLM_PROCESS_LOGGER.ERROR (
               'WIM_GATEWAY.CREATE_WELL INTERFACE FAILED. NOT ALL THE REQUIRED DATA PROVIDED FOR SURFACE NODE CREATION');
            RETURN 0;                               --OR GO TO THE NEXT STEP??
         END IF;

         V_ACTION_CD := 'A';
         V_NODE_ID := P_UWI || '1';

         SELECT *
           INTO WNV_REC
           FROM WELL_NODE_VERSION
          WHERE ROWNUM = 1;

         NULL_NODE_ROW (WNV_REC);

         -- UPDATE ATTRIBUTES
         UPDATE_WNV_ATTRIBUTES (WNV_REC,
                                V_SOURCE,
                                P_TLM_ID,
                                P_SURFACE_LATITUDE,
                                P_SURFACE_LONGITUDE,
                                V_NODE_ID,
                                P_SUR_GEOG_COORD_SYSTEM_ID,
                                P_SUR_LOCATION_QUALIFIER,
                                'S',
                                1,
                                V_ACTION_CD,
                                P_COUNTRY,
                                P_PROVINCE_STATE,
                                P_REMARK);

         --POPULATE WIM_STG_WELL_NODE_VERSION TABLE
         POPULATE_STG_WELL_NODE_VERSION (WNV_REC,
                                         1,
                                         V_WIM_STG_ID,
                                         V_ACTION_CD);
      END IF;

      --BASE NODES
      IF (P_BOTTOM_HOLE_LATITUDE IS NOT NULL AND P_BOTTOM_HOLE_LONGITUDE IS NOT NULL)
      THEN
         --CHECK IF REQUIRED DATA IS PROVIDED
         IF (   P_BH_GEOG_COORD_SYSTEM_ID IS NULL
             OR P_BH_LOCATION_QUALIFIER IS NULL)
         THEN
            -- ERROR: DATA MISSING
            TLM_PROCESS_LOGGER.ERROR (
               'WIM_GATEWAY.CREATE_WELL INTERFACE FAILED. NOT ALL THE REQUIRED DATA PROVIDED FOR BASE NODE CREATION');
            RETURN 0;                               --OR GO TO THE NEXT STEP??
         END IF;

         V_ACTION_CD := 'A';
         V_NODE_ID := P_UWI || '0';

         SELECT *
           INTO WNV_REC
           FROM WELL_NODE_VERSION
          WHERE ROWNUM = 1;

         NULL_NODE_ROW (WNV_REC);

         -- UPDATE ATTRIBUTES
         UPDATE_WNV_ATTRIBUTES (WNV_REC,
                                V_SOURCE,
                                P_TLM_ID,
                                P_BOTTOM_HOLE_LATITUDE,
                                P_BOTTOM_HOLE_LONGITUDE,
                                V_NODE_ID,
                                P_BH_GEOG_COORD_SYSTEM_ID,
                                P_BH_LOCATION_QUALIFIER,
                                'B',
                                1,
                                V_ACTION_CD,
                                P_COUNTRY,
                                P_PROVINCE_STATE,
                                P_REMARK);

         --POPULATE WIM_STG_WELL_NODE_VERSION TABLE
         POPULATE_STG_WELL_NODE_VERSION (WNV_REC,
                                         2,
                                         V_WIM_STG_ID,
                                         V_ACTION_CD);
      END IF;


      --WELL LICENSES
      IF P_WL_LICENSE_NUM IS NOT NULL
      THEN
         SELECT *
           INTO WL_REC
           FROM WELL_LICENSE
          WHERE ROWNUM = 1;

         V_ACTION_CD := 'A';

         NULL_LICENSE_ROW (WL_REC);

         UPDATE_WL_ATTRIBUTES (WL_REC,
                               V_SOURCE,
                               P_TLM_ID,
                               P_WL_AGENT,
                               P_WL_LICENSE_NUM,
                               P_WL_CONTRACTOR,
                               P_WL_LICENSEE,
                               P_WL_LICENSEE_CONTACT_ID,
                               P_WL_REGULATORY_AGENCY,
                               P_WL_REGULATORY_CONTACT_ID,
                               P_WL_SURVEYOR,              
                               V_ACTION_CD);

         POPULATE_STG_WELL_LICENSE (P_WELL_LIC     => WL_REC,
                                    P_WIM_STG_ID   => V_WIM_STG_ID,
                                    P_ACTION_CD    => V_ACTION_CD);
      END IF;

      -- WELL STATUS
      IF P_STATUS IS NOT NULL
      THEN
         SELECT *
           INTO WS_REC
           FROM WELL_STATUS
          WHERE ROWNUM = 1;

         V_ACTION_CD := 'A';
         V_STATUS_ID := '001';
         NULL_STATUS_ROW (WS_REC);

         V_WELL_STATUS_CD := GETWELLSTATUS (P_STATUS);
         UPDATE_WS_ATTRIBUTES (WS_REC,
                               V_SOURCE,
                               P_TLM_ID,
                               V_WELL_STATUS_CD,
                               V_ACTION_CD);

         POPULATE_STG_WELL_STATUS (P_WELL_STATUS   => WS_REC,
                                   P_WIM_STG_ID    => V_WIM_STG_ID,
                                   P_ACTION_CD     => V_ACTION_CD,
                                   P_STATUS_ID     => V_STATUS_ID,
                                   P_SEQ           => 1);
      END IF;

      COMMIT;

      --CALL WELL_ACTION
      WIM.WIM_GATEWAY.WELL_ACTION (V_WIM_STG_ID,
                                   V_NEW_TLM_ID,
                                   V_STATUS,
                                   V_AUDIT_NO);

      P_TLM_ID := V_NEW_TLM_ID;
      RETURN 1;                                                      --SUCCESS
   EXCEPTION
      WHEN OTHERS
      THEN
         V_AUDIT_ID := WIM_AUDIT.GET_AUDIT_ID ();
         --DBMS_OUTPUT.PUT_LINE('UPDATE_WIM CREATE_WELL INTERFACE FAILED: ' || SQLERRM);
         WIM_AUDIT.AUDIT_EVENT (
            PAUDIT_ID     => V_AUDIT_ID,
            PACTION       => V_ACTION_CD,
            PTLM_ID       => P_TLM_ID,
            PSOURCE       => V_SOURCE,
            PTEXT         => SUBSTR (
                                  'UPDATE_WIM UPDATE WELL INTERFACE FAILED: ORACLE ERROR : '
                               || ' - '
                               || SQLERRM,
                               1,
                               255),
            PAUDIT_TYPE   => 'F',
            PUSER         => USER);
         RETURN 0;
   END CREATE_WELL;     
END UPDATE_WIM;