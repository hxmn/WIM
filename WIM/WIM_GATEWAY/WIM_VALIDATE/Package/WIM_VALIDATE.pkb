create or replace PACKAGE BODY     wim_validate
IS
/*-----------------------------------------------------------------------------------------------------------------------------------
 SCRIPT: WIM.WIM_VALIDATE.pkb

 PURPOSE:
      This package contains functions and procedures to validate well information before inserting/updating/Inactivating/Reactivating.
      It is called from WIM_WELL_ACTION package.

      It is part of WIM_GATEWAY.

      Procedure/Function Details
            See Package Spec.


HISTORY:

Nov 2 2012  VRajpoot             In REF_Check Function, Changed the vMsg_Txt
                                 to display only the field_name ( instead of table and field_name) and replaced unknown with invalid.

Dec 5 2012  VRajpoot            Procedure: Validate_WEll_Node_Version
                                modified to check if need to run validation rule or not for the given wim_Action_cd
                                e.g. when inactivating a node, dont need to run validation rule.
Feb 27 2013  VRajpoot           Modified internal_validate 
                                If Action Cd is A, no need to check if Inactive version exists.   
                                This is part of WIM_GATEWAY 2.0.0 version  
Apr 19 2015 KXEDWARD            Added ipl_offshore_ind_trnsfand ipl_sort_display_trnsf functions
                                Gateway 2.0.2 version
-----------------------------------------------------------------------------------------------------------------------------------*/
   v_current_action_cd   wim_stg_well_version.wim_action_cd%TYPE;

/*----------------------------------------------------------------------------------------------------------
Function:  GET_REQUEST_CREATED_BY_VALUE
Detail:    This function returns Row_created_By from WIM_STG_REQUEST table.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION get_request_created_by_value (pwim_stg_id NUMBER)
      RETURN wim_stg_request.row_created_by%TYPE
   IS
      v_request_created_by     wim_stg_request.row_created_by%TYPE;
      v_request_created_date   wim_stg_request.row_created_date%TYPE;
   BEGIN
      SELECT row_created_by, row_created_date
        INTO v_request_created_by, v_request_created_date
        FROM wim_stg_request
       WHERE wim_stg_id = pwim_stg_id;

      RETURN v_request_created_by;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  GET_RULE_ATTRIBUTE_VALUE
Detail:    This function returns attribute value from Validate_Rule_atribute table.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION get_rule_attribute_value (
      prule_id        NUMBER,
      pattribute_cd   validate_rule_attribute_type.rule_attribute_type_cd%TYPE
   )
      RETURN validate_rule_attribute.attribute_value%TYPE
   IS
      v_ret_value   validate_rule_attribute.attribute_value%TYPE;
   BEGIN
      SELECT attribute_value
        INTO v_ret_value
        FROM validate_rule_attribute
       WHERE rule_id = prule_id
         AND rule_attribute_type_cd = UPPER (pattribute_cd)
         AND ROWNUM = 1;

      RETURN v_ret_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

/*----------------------------------------------------------------------------------------------------------
Procedure:  ADD_UOM_ERROR_MESSAGE
Detail:    This procedure create a error message in wim_audi_log in case UOM is not provided.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   PROCEDURE add_uom_error_message (
      paudit_id          NUMBER,
      pseq               NUMBER,
      ptable_name        VARCHAR2,
      pfield_name        VARCHAR2,
      puser         IN   wim_audit_log.row_created_by%TYPE
   )
   IS
      vmsg_text   VARCHAR2 (255);
      vaudit_id   NUMBER;
   BEGIN
      vaudit_id := paudit_id;
      vmsg_text :=
            'Table: '
         || UPPER (ptable_name)
         || ' field:'
         || UPPER (pfield_name)
         || ' - value is missing.';
      wim_audit.audit_event (paudit_id        => vaudit_id,
                             paction          => NULL,
                             psource          => NULL,
                             ptext            => vmsg_text,
                             ptlm_id          => NULL,
                             pattribute       =>    ptable_name
                                                 || '.'
                                                 || pfield_name,
                             paudit_type      => 'E',
                             pseq             => pseq,
                             puser            => puser
                            );
   END;

/***********************************/

   /************************************/
/* Validation Types implementation */
/***********************************/

/*----------------------------------------------------------------------------------------------------------
Function:  IF_THEN_CHECK
Detail:    Checks data depending on IF Conditions set up in Validate_Rule tables  
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION if_then_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table            VARCHAR2 (255);
      v_err_field        VARCHAR2 (255);
      v_if_condition     VARCHAR2 (255);
      v_then_condition   VARCHAR2 (255);
      vcount             NUMBER;
      vaudit_id          NUMBER;
      vtlm_id            wim_stg_well_version.uwi%TYPE;
      vcodeblock         VARCHAR2 (500);
      vmsg_text          VARCHAR (255);
      vaudit_type        wim_audit_log.audit_type%TYPE;
      vattribute         wim_audit_log.ATTRIBUTE%TYPE;
      vaction_cd         wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd         wim_stg_well_version.SOURCE%TYPE;
      vuser              wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      v_table := get_rule_attribute_value (prule_id, 'TABLE_NAME');
      v_if_condition := get_rule_attribute_value (prule_id, 'IF_CONDITION');
      v_then_condition :=
                         get_rule_attribute_value (prule_id, 'THEN_CONDITION');
      v_err_field := get_rule_attribute_value (prule_id, 'ERR_FIELD_NAME');
      -- Build and run the check
      vcodeblock :=
            'SELECT COUNT(1) FROM '
         || v_table
         || ' WHERE ('
         || v_if_condition
         || ') AND NOT ('
         || v_then_condition
         || ' ) AND WIM_STG_ID = :pSTG_ID ';

      IF pseq IS NOT NULL
      THEN                                        -- apply secondary ID filter
         vcodeblock := vcodeblock || ' AND WIM_SEQ= ' || pseq;
      END IF;

      EXECUTE IMMEDIATE vcodeblock
                   INTO vcount
                  USING pstg_id;

      IF vcount > 0        -- IF condition is true but THEN condition is false
      THEN
         vmsg_text :=
            NVL (vmsg_text,
                 'Condition (' || v_then_condition || ' ) is false'
                );
         IF v_err_field IS NOT NULL
         THEN
            vattribute := v_table || '.' || v_err_field;
            dbms_output.put_line(vattribute);
         END IF;

         wim_audit.audit_event (paudit_id        => vaudit_id,
                                paction          => v_current_action_cd,
                                psource          => vsource_cd,
                                ptext            => vmsg_text,
                                ptlm_id          => vtlm_id,
                                pattribute       => vattribute,
                                paudit_type      => vaudit_type,
                                pseq             => pseq,
                                puser            => vuser
                               );
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  CONDITION_CHECK
Detail:    Checks data depending on Conditions set up in Validate_Rule tables
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION condition_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table       VARCHAR2 (255);
      v_err_field   VARCHAR2 (255);
      v_condition   VARCHAR2 (255);
      vcount        NUMBER;
      vaudit_id     NUMBER;
      vtlm_id       wim_stg_well_version.uwi%TYPE;
      vcodeblock    VARCHAR2 (500);
      vmsg_text     VARCHAR (255);
      vaudit_type   wim_audit_log.audit_type%TYPE;
      vattribute    wim_audit_log.ATTRIBUTE%TYPE;
      vaction_cd    wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd    wim_stg_well_version.SOURCE%TYPE;
      vuser         wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      v_table := get_rule_attribute_value (prule_id, 'TABLE_NAME');
      v_condition := get_rule_attribute_value (prule_id, 'CONDITION');
      v_err_field := get_rule_attribute_value (prule_id, 'ERR_FIELD_NAME');
      -- Build and run the check
      vcodeblock :=
            'SELECT COUNT(1) FROM '
         || v_table
         || ' WHERE '
         || v_condition
         || ' AND WIM_STG_ID = :pSTG_ID ';

       dbms_output.put_line ('v_table ' || v_table);
        dbms_output.put_line ('v_condition ' || v_condition);
        dbms_output.put_line (v_err_field);
        dbms_output.put_line (vcodeblock);
        
      IF pseq IS NOT NULL
      THEN                                        -- apply secondary ID filter
         vcodeblock := vcodeblock || ' AND WIM_SEQ= ' || pseq;
      END IF;
dbms_output.put_line (vcodeblock);
      EXECUTE IMMEDIATE vcodeblock
                   INTO vcount
                  USING pstg_id;

      IF vcount = 0
      THEN
         vmsg_text :=
               NVL (vmsg_text, 'Condition (' || v_condition || ' ) is false');

         IF v_err_field IS NOT NULL
         THEN
            vattribute := v_table || '.' || v_err_field;
         END IF;

         wim_audit.audit_event (paudit_id        => vaudit_id,
                                paction          => v_current_action_cd,
                                psource          => vsource_cd,
                                ptext            => vmsg_text,
                                ptlm_id          => vtlm_id,
                                pattribute       => vattribute,
                                paudit_type      => vaudit_type,
                                pseq             => pseq,
                                puser            => vuser
                               );
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  MANDATORY_FIELD
Detail:    Checks data depending on REQ_FIELD_NAME setup in Validate_Rule, * tables
           Returns number of errors; 0 means success
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION mandatory_field (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table              VARCHAR2 (255);
      v_field              VARCHAR2 (255);
      vcount               NUMBER;
      vaudit_id            NUMBER;
      vtlm_id              wim_stg_well_version.uwi%TYPE;
      vcodeblock           VARCHAR2 (500);
      vmsg_text            VARCHAR (255);
      vmsg_text_template   VARCHAR (255);
      vaudit_type          wim_audit_log.audit_type%TYPE;
      v_errors             NUMBER                                    := 0;
      vaction_cd           wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd           wim_stg_well_version.SOURCE%TYPE;
      vuser                wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text_template, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      v_table := get_rule_attribute_value (prule_id, 'TABLE_NAME');

      FOR req_field_rec IN (SELECT attribute_value
                              FROM validate_rule_attribute
                             WHERE rule_id = prule_id
                               AND rule_attribute_type_cd = 'REQ_FIELD_NAME')
      LOOP
         --v_field := get_rule_attribute_value (prule_id, 'REQ_FIELD_NAME');
         v_field := req_field_rec.attribute_value;
         -- Build and run the check
         vcodeblock :=
               'SELECT COUNT(1) FROM '
            || v_table
            || ' WHERE '
            || v_field
            || ' IS NULL'
            || ' AND WIM_STG_ID = :pSTG_ID ';

         IF pseq IS NOT NULL
         THEN                                     -- apply secondary ID filter
            vcodeblock := vcodeblock || ' AND WIM_SEQ= ' || pseq;
         END IF;

         EXECUTE IMMEDIATE vcodeblock
                      INTO vcount
                     USING pstg_id;

         IF vcount <> 0
         THEN
            vmsg_text :=
                        REPLACE (vmsg_text_template, '{FIELD_NAME}', v_field);
            --NVL (vmsg_text, v_table || '.' || v_field || ' is unknown');
            wim_audit.audit_event (paudit_id        => vaudit_id,
                                   paction          => v_current_action_cd,
                                   psource          => vsource_cd,
                                   ptext            => vmsg_text,
                                   ptlm_id          => vtlm_id,
                                   pattribute       => v_table || '.'
                                                       || v_field,
                                   paudit_type      => vaudit_type,
                                   pseq             => pseq,
                                   puser            => vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  REF_CHECK
Detail:    This function checks data depending on REQ_FIELD_NAME/REF_TABLE_NAME set up in Validate_Rule, * tables
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION ref_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table         VARCHAR2 (255);
      v_field         VARCHAR2 (255);
      v_ref_table     VARCHAR2 (255);
      v_ref_field     VARCHAR2 (255);
      vcount          NUMBER;
      vvalue          VARCHAR2 (255);
      vaudit_id       NUMBER;
      vtlm_id         wim_stg_well_version.uwi%TYPE;
      vcodeblock      VARCHAR2 (500);
      vcodeblockseq   VARCHAR2 (500)                            := '';
      vmsg_text       VARCHAR (255);
      vaudit_type     wim_audit_log.audit_type%TYPE;
      vaction_cd      wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd      wim_stg_well_version.SOURCE%TYPE;
      vuser           wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      v_table := get_rule_attribute_value (prule_id, 'TABLE_NAME');
      v_field := get_rule_attribute_value (prule_id, 'REQ_FIELD_NAME');
      v_ref_table := get_rule_attribute_value (prule_id, 'REF_TABLE_NAME');
      v_ref_field := get_rule_attribute_value (prule_id, 'REF_PK_FIELD_NAME');
      -- Build and run the check
      -- NULL values are fine
      vcodeblock :=
            'SELECT COUNT(1) FROM '
         || v_table
         || ' WHERE ('
         || v_field
         || ' IS NULL OR '
         || v_field
         || ' IN (SELECT '
         || v_ref_field
         || ' FROM '
         || v_ref_table
         || ')) '
         || ' AND WIM_STG_ID = :pSTG_ID ';

      IF pseq IS NOT NULL
      THEN                                        -- apply secondary ID filter
         vcodeblockseq := ' AND WIM_SEQ = ' || pseq;
      END IF;

      vcodeblock := vcodeblock || vcodeblockseq;

      EXECUTE IMMEDIATE vcodeblock
                   INTO vcount
                  USING pstg_id;

      IF vcount = 0
      THEN
         vcodeblock :=
               'SELECT '
            || v_field
            || ' FROM '
            || v_table
            || ' WHERE WIM_STG_ID = :pSTG_ID '
            || vcodeblockseq;

         EXECUTE IMMEDIATE vcodeblock
                      INTO vvalue
                     USING pstg_id;

         vmsg_text :=
            NVL (vmsg_text,
                 v_field || ' "' || vvalue || '" is invalid'
                );
         wim_audit.audit_event (paudit_id        => vaudit_id,
                                paction          => v_current_action_cd,
                                psource          => vsource_cd,
                                ptext            => vmsg_text,
                                ptlm_id          => vtlm_id,
                                pattribute       => v_table || '.' || v_field,
                                paudit_type      => vaudit_type,
                                pseq             => pseq,
                                puser            => vuser
                               );
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  TLM_ID_CHECK
Detail:    This function 
           Checks if TLM_ID is provided (when Inserting a new Well)
           Checks to make sure if exists in well_Version table ( when Updating, Adding, Inactivating or Reactivating)
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION tlm_id_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table         VARCHAR2 (255);
      v_field         VARCHAR2 (255);
      v_ref_table     VARCHAR2 (255);
      v_ref_field     VARCHAR2 (255);
      vcount          NUMBER;
      vvalue          VARCHAR2 (255);
      vaudit_id       NUMBER;
      vtlm_id         wim_stg_well_version.uwi%TYPE;
      vaction_cd      wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd      wim_stg_well_version.SOURCE%TYPE;
      vcodeblock      VARCHAR2 (500);
      vcodeblockseq   VARCHAR2 (500)                            := '';
      vmsg_text       VARCHAR (255);
      vaudit_type     wim_audit_log.audit_type%TYPE;
      vuser           wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      IF vtlm_id IS NULL
      THEN
         IF vaction_cd != 'C'
         THEN
            vmsg_text := NVL (vmsg_text, 'No TLM ID was specified');
            wim_audit.audit_event (paudit_id        => vaudit_id,
                                   paction          => vaction_cd,
                                   psource          => vsource_cd,
                                   ptext            => vmsg_text,
                                   ptlm_id          => NULL,
                                   pattribute       => 'wim_stg_well_version.uwi',
                                   paudit_type      => vaudit_type,
                                   puser            => vuser
                                  );
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
        
         IF wim_search.find_well (palias => vtlm_id, 
                                 pfind_type => 'TLM_ID',
                                 psource =>     NULL,
                                 pfindbyalias_fg => 'V') IS NULL
                                                  /*when CREATE we will generate new TLM ID from sequence*/
            AND vaction_cd != 'C'
         THEN
            vmsg_text :=
                        NVL (vmsg_text, 'TLM ID ' || vtlm_id || ' not found');
            wim_audit.audit_event (paudit_id        => vaudit_id,
                                   paction          => vaction_cd,
                                   psource          => vsource_cd,
                                   ptext            => vmsg_text,
                                   ptlm_id          => vtlm_id,
                                   pattribute       => 'TLM_ID',
                                   paudit_type      => vaudit_type,
                                   puser            => vuser
                                  );
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   END;
   
/*----------------------------------------------------------------------------------------------------------
Function:  COUNTRY_CONSISTENCY_CHECK
Detail:    This function checks Checks wells with country Australia, if it is consistent with others versions of 
           the same well.
                             
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION country_consistency_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      vcount        NUMBER;
      vaudit_id     NUMBER;
      vtlm_id       wim_stg_well_version.uwi%TYPE;
      vmsg_text     VARCHAR (255);
      vaudit_type   wim_audit_log.audit_type%TYPE;
      vcountry      wim_stg_well_version.country%TYPE;
      vaction_cd    wim_stg_well_version.wim_action_cd%TYPE;
      vsource       wim_stg_well_version.SOURCE%TYPE;
      vuser         wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT uwi, country, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vcountry, vaction_cd, vsource, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      IF INSTR ('AU', vaction_cd) > 0
      THEN
         SELECT COUNT (1)
           INTO vcount
           FROM well_version
          WHERE uwi = vtlm_id AND SOURCE <> vsource AND country <> vcountry and active_ind <> 'N';

         IF vcount > 0
         THEN
            vmsg_text :=
               NVL (vmsg_text,
                       'Country code: '
                    || vcountry
                    || ' is not consistent with exisiting well version records.'
                   );
            wim_audit.audit_event
                                (paudit_id        => vaudit_id,
                                 paction          => vaction_cd,
                                 psource          => vsource,
                                 ptext            => vmsg_text,
                                 ptlm_id          => vtlm_id,
                                 pattribute       => 'wim_stg_well_version.country',
                                 paudit_type      => vaudit_type,
                                 puser            => vuser
                                );
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  COUNTRY_LATLONG_CHECK
Detail:    This function checks if well's lat/longs are between lat/longs and in country
           as specificed in Validate_Country_LatLong table.
           Validate_Country_LatLong table is used to perform this check. 
            RETURNS number of errors, 0 means no errors.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION country_latlong_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_count       NUMBER;
      vaudit_id     NUMBER;
      vtlm_id       wim_stg_well_version.uwi%TYPE;
      vmsg_text     VARCHAR (255);
      vaudit_type   wim_audit_log.audit_type%TYPE;
      vcountry      wim_stg_well_version.country%TYPE;
      vaction_cd    wim_stg_well_version.wim_action_cd%TYPE;
      vsource       wim_stg_well_version.SOURCE%TYPE;
      vlatitude     wim_stg_well_version.bottom_hole_latitude%TYPE;
      vlongitude    wim_stg_well_version.bottom_hole_longitude%TYPE;
      verrors       NUMBER                                            := 0;
      vuser         wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;
      vuser := get_request_created_by_value (pstg_id);

      SELECT uwi, country, wim_action_cd, SOURCE, bottom_hole_latitude,
             bottom_hole_longitude
        INTO vtlm_id, vcountry, vaction_cd, vsource, vlatitude,
             vlongitude
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      IF vaction_cd IN ('A', 'U', 'C')
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM validate_country_latlong
          WHERE country = UPPER (vcountry)
            AND vlatitude BETWEEN latitude_min AND latitude_max;

         IF v_count = 0
         THEN
            vmsg_text :=
                'Latitude: ' || vlatitude || ' is not valid for this country';
            wim_audit.audit_event
                  (paudit_id        => vaudit_id,
                   paction          => vaction_cd,
                   psource          => vsource,
                   ptext            => vmsg_text,
                   ptlm_id          => vtlm_id,
                   pattribute       => 'wim_stg_well_version.BOTTOM_HOLE_LATITUDE',
                   paudit_type      => vaudit_type,
                   puser            => vuser
                  );
            verrors := verrors + 1;
         END IF;

         SELECT COUNT (*)
           INTO v_count
           FROM validate_country_latlong
          WHERE country = UPPER (vcountry)
            AND vlongitude BETWEEN longitude_min AND longitude_max;

         IF v_count = 0
         THEN
            vmsg_text :=
               'Longtitude: ' || vlongitude
               || ' is not valid for this country';
            wim_audit.audit_event
                 (paudit_id        => vaudit_id,
                  paction          => vaction_cd,
                  psource          => vsource,
                  ptext            => vmsg_text,
                  ptlm_id          => vtlm_id,
                  pattribute       => 'wim_stg_well_version.BOTTOM_HOLE_LONGITUDE',
                  paudit_type      => vaudit_type,
                  puser            => vuser
                 );
            verrors := verrors + 1;
         END IF;
      END IF;

      FOR node_rec IN (SELECT wim_seq, latitude, longitude
                         FROM wim_stg_well_node_version
                        WHERE wim_stg_id = pstg_id
                          AND wim_action_cd IN ('A', 'U', 'C'))
      LOOP
         vlatitude := node_rec.latitude;
         vlongitude := node_rec.longitude;

         IF vlatitude IS NULL
         THEN
            vmsg_text := 'Latitude is null';
            wim_audit.audit_event
                         (paudit_id        => vaudit_id,
                          paction          => vaction_cd,
                          psource          => vsource,
                          ptext            => vmsg_text,
                          ptlm_id          => vtlm_id,
                          pattribute       => 'wim_stg_well_node_version.LATITUDE',
                          pseq             => node_rec.wim_seq,
                          paudit_type      => vaudit_type,
                          puser            => vuser
                         );
            verrors := verrors + 1;
         ELSE
            SELECT COUNT (*)
              INTO v_count
              FROM validate_country_latlong
             WHERE country = UPPER (vcountry)
               AND vlatitude BETWEEN latitude_min AND latitude_max;

            IF v_count = 0
            THEN
               vmsg_text :=
                  'Latitude: ' || vlatitude
                  || ' is not valid for this country';
               wim_audit.audit_event
                         (paudit_id        => vaudit_id,
                          paction          => vaction_cd,
                          psource          => vsource,
                          ptext            => vmsg_text,
                          ptlm_id          => vtlm_id,
                          pattribute       => 'wim_stg_well_node_version.LATITUDE',
                          pseq             => node_rec.wim_seq,
                          paudit_type      => vaudit_type,
                          puser            => vuser
                         );
               verrors := verrors + 1;
            END IF;
         END IF;

         IF vlongitude IS NULL
         THEN
            vmsg_text := 'Longtitude is null';
            wim_audit.audit_event
                        (paudit_id        => vaudit_id,
                         paction          => vaction_cd,
                         psource          => vsource,
                         ptext            => vmsg_text,
                         ptlm_id          => vtlm_id,
                         pattribute       => 'wim_stg_well_node_version.LONGITUDE',
                         pseq             => node_rec.wim_seq,
                         paudit_type      => vaudit_type,
                         puser            => vuser
                        );
            verrors := verrors + 1;
         ELSE
            SELECT COUNT (*)
              INTO v_count
              FROM validate_country_latlong
             WHERE country = UPPER (vcountry)
               AND vlongitude BETWEEN longitude_min AND longitude_max;

            IF v_count = 0
            THEN
               vmsg_text :=
                     'Longtitude: '
                  || vlongitude
                  || ' is not valid for this country';
               wim_audit.audit_event
                         (paudit_id        => vaudit_id,
                          paction          => vaction_cd,
                          psource          => vsource,
                          ptext            => vmsg_text,
                          ptlm_id          => vtlm_id,
                          pattribute       => 'wim_stg_well_node_version.LONGITUDE',
                          pseq             => node_rec.wim_seq,
                          paudit_type      => vaudit_type,
                          puser            => vuser
                         );
               verrors := verrors + 1;
            END IF;
         END IF;
      END LOOP;

      RETURN verrors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  LAT_LONG_PREC_CHECK
Detail:    This function Checks if lat/longs precision is same as it is specified in Validate_Rule tables. 
           This applies when Creating, Adding or Updating wells.
      
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION lat_long_prec_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      vaudit_id     NUMBER;
      vtlm_id       wim_stg_well_version.uwi%TYPE;
      vmsg_text     VARCHAR (255);
      vaudit_type   wim_audit_log.audit_type%TYPE;
      vcountry      wim_stg_well_version.country%TYPE;
      vaction_cd    wim_stg_well_version.wim_action_cd%TYPE;
      vsource       wim_stg_well_version.SOURCE%TYPE;
      vlatitude     wim_stg_well_version.bottom_hole_latitude%TYPE;
      vlongitude    wim_stg_well_version.bottom_hole_longitude%TYPE;
      v_prec        NUMBER;
      verrors       NUMBER                                            := 0;
      vuser         wim_stg_request.row_created_by%TYPE;
   BEGIN
      vaudit_id := paudit_id;
      vuser := get_request_created_by_value (pstg_id);
      v_prec :=
         NVL (TO_NUMBER (get_rule_attribute_value (prule_id, 'LAT_LONG_PREC')),
              5
             );

      SELECT uwi, country, wim_action_cd, SOURCE, bottom_hole_latitude,
             bottom_hole_longitude
        INTO vtlm_id, vcountry, vaction_cd, vsource, vlatitude,
             vlongitude
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      IF vaction_cd IN ('A', 'U', 'C')
      THEN
         IF vlatitude - TRUNC (vlatitude, v_prec - 1) = 0
         THEN
            vmsg_text :=
                  'Latitude: '
               || vlatitude
               || ', precision is less then '
               || v_prec
               || ' decimal places';
            wim_audit.audit_event
                   (paudit_id        => vaudit_id,
                    paction          => vaction_cd,
                    psource          => vsource,
                    ptext            => vmsg_text,
                    ptlm_id          => vtlm_id,
                    pattribute       => 'wim_stg_well_version.BOTTOM_HOLE_LATITUDE',
                    paudit_type      => vaudit_type,
                    puser            => vuser
                   );
            verrors := verrors + 1;
         END IF;

         IF vlongitude - TRUNC (vlongitude, v_prec - 1) = 0
         THEN
            vmsg_text :=
                  'Longtitude: '
               || vlongitude
               || ', precision is less then '
               || v_prec
               || ' decimal places';
            wim_audit.audit_event
                  (paudit_id        => vaudit_id,
                   paction          => vaction_cd,
                   psource          => vsource,
                   ptext            => vmsg_text,
                   ptlm_id          => vtlm_id,
                   pattribute       => 'wim_stg_well_version.BOTTOM_HOLE_LONGITUDE',
                   paudit_type      => vaudit_type,
                   puser            => vuser
                  );
            verrors := verrors + 1;
         END IF;
      END IF;

      FOR node_rec IN (SELECT wim_seq, latitude, longitude
                         FROM wim_stg_well_node_version
                        WHERE wim_stg_id = pstg_id
                          AND wim_action_cd IN ('A', 'U', 'C'))
      LOOP
         vlatitude := node_rec.latitude;
         vlongitude := node_rec.longitude;

         IF vlatitude - TRUNC (vlatitude, v_prec - 1) = 0
         THEN
            vmsg_text :=
                  'Latitude: '
               || vlatitude
               || ', precision is less then '
               || v_prec
               || ' decimal places';
            wim_audit.audit_event
                          (paudit_id        => vaudit_id,
                           paction          => vaction_cd,
                           psource          => vsource,
                           ptext            => vmsg_text,
                           ptlm_id          => vtlm_id,
                           pattribute       => 'wim_stg_well_node_version.LATITUDE',
                           pseq             => node_rec.wim_seq,
                           paudit_type      => vaudit_type,
                           puser            => vuser
                          );
            verrors := verrors + 1;
         END IF;

         IF vlongitude - TRUNC (vlongitude, v_prec - 1) = 0
         THEN
            vmsg_text :=
                  'Longtitude: '
               || vlongitude
               || ', precision is less then '
               || v_prec
               || ' decimal places';
            wim_audit.audit_event
                         (paudit_id        => vaudit_id,
                          paction          => vaction_cd,
                          psource          => vsource,
                          ptext            => vmsg_text,
                          ptlm_id          => vtlm_id,
                          pattribute       => 'wim_stg_well_node_version.LONGITUDE',
                          pseq             => node_rec.wim_seq,
                          paudit_type      => vaudit_type,
                          puser            => vuser
                         );
            verrors := verrors + 1;
         END IF;
      END LOOP;

      RETURN verrors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  ipl_sort_display_trnsf
Detail:    This function Checks if ipl_uwi_local (government id) is not null
           and will populate the IPL_UWI_SORT and IPL_UWI_DISPLAY
           This applies when Creating, Adding or Updating wells.
      
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
    function ipl_sort_display_trnsf (
        pstg_id     wim_stg_request.wim_stg_id%type,
        pseq        number,
        prule_id    number,
        paudit_id   number
    ) return number
    is
        -- DLS
        v_meridiandir     varchar2(1);
        v_meridian        varchar2(2);
        v_township        varchar2(3);
        v_range           varchar(2);    
        v_legal_subdiv    varchar(2);
        
        -- NTS
        v_prim_quad       varchar2(3);
        v_letter_quad     varchar2(1);
        v_sixteenth       varchar2(2);
        v_block           varchar2(1);    
        v_quarter_unit    varchar2(1);
        
        -- FPS    
        v_lat_deg         varchar2(2);
        v_lat_min         varchar2(2);
        v_long_deg        varchar2(3);
        v_long_min        varchar2(2);
             
        -- Common
        v_loctype         varchar2(1);
        v_unit            varchar2(3);
        v_section         varchar2(2);
        v_loc_exception   varchar2(2);
        v_event_sequence  varchar2(2);
        
        vuser             wim_stg_request.row_created_by%type;
        vtlm_id           wim_stg_well_version.uwi%type;
        vaudit_type       wim_audit_log.audit_type%type;
        vcountry          wim_stg_well_version.country%type;
        vaction_cd        wim_stg_well_version.wim_action_cd%type;
        vsource           wim_stg_well_version.source%type;
        vipl_uwi_sort     wim_stg_well_version.ipl_uwi_sort%type;
        vipl_uwi_display  wim_stg_well_version.ipl_uwi_display%type;
        vipl_uwi_local    wim_stg_well_version.ipl_uwi_local%type;
        verrors           number := 0;
        vaudit_id         number;
        vmsg_text         varchar2(255);
    begin
        vaudit_id := paudit_id;
        vuser := get_request_created_by_value (pstg_id);
        
        SELECT uwi, country, wim_action_cd, source, ipl_uwi_local, ipl_uwi_sort, ipl_uwi_display
        into vtlm_id, vcountry, vaction_cd, vsource, vipl_uwi_local, vipl_uwi_sort, vipl_uwi_display
        from wim_stg_well_version
        where wim_stg_id = pstg_id
        ;
  
        select msg_text, failure_level_cd
        into vmsg_text, vaudit_type
        from validate_rule
        where rule_id = prule_id;
        
        -- sort
        if vcountry = ('7CN') and vaction_cd in ('A', 'U', 'C') then
            vipl_uwi_sort := null;
            vipl_uwi_display := null;
            
--            v_ipl(1).sort := v_loctype || v_meridiandir || v_meridian || v_township || v_range || v_section || v_legal_subdiv || v_loc_exception || v_event_sequence; 
--            v_ipl(1).display := v_loc_exception || '/' || v_legal_subdiv || '-' || v_section || '-' || v_township || '-' || v_range || ' ' || v_meridiandir || v_meridian || '/' || substr(v_event_sequence, -1, 1);
        
            begin
                case
                    -- DLS
                    when substr(vipl_uwi_local, 1,1) = '1' then
                        v_loctype         :=  substr(vipl_uwi_local,1,1);
                        v_meridiandir     :=  substr(vipl_uwi_local, 13, 1);
                        v_meridian        :=  substr(vipl_uwi_local, 14, 1);
                        v_township        :=  substr(vipl_uwi_local, 8, 3);
                        v_range           :=  substr(vipl_uwi_local, 11, 2);
                        v_section         :=  substr(vipl_uwi_local, 6, 2);       
                        v_legal_subdiv    :=  substr(vipl_uwi_local, 4, 2);
                        v_loc_exception   :=  substr(vipl_uwi_local, 2, 2);
                        v_event_sequence  :=  '0' || substr(vipl_uwi_local, 16, 1);
                        
                        vipl_uwi_sort := v_loctype || v_meridiandir || v_meridian || v_township || v_range || v_section || v_legal_subdiv || v_loc_exception || v_event_sequence;
                        vipl_uwi_display := v_loc_exception || '/' || v_legal_subdiv || '-' || v_section || '-' || v_township || '-' || v_range || v_meridiandir || v_meridian || '/' || substr(v_event_sequence, -1, 1);
                    
                    -- NTS
                    when substr(vipl_uwi_local, 1,1) = '2' then
                        v_loctype         := substr(vipl_uwi_local,1, 1);  
                        v_prim_quad       := substr(vipl_uwi_local, 9, 3);
                        v_letter_quad     := substr(vipl_uwi_local, 12, 1);   
                        v_sixteenth       := substr(vipl_uwi_local, 13, 2);
                        v_block           := substr(vipl_uwi_local, 8, 1);
                        v_unit            := substr(vipl_uwi_local, 5, 3); 
                        v_quarter_unit    := substr(vipl_uwi_local, 4, 1);
                        v_loc_exception   := substr(vipl_uwi_local, 2, 2);
                        v_event_sequence  := '0' || substr(vipl_uwi_local, 16, 1);
                      
                        vipl_uwi_sort := v_loctype || v_prim_quad || v_letter_quad || v_sixteenth || v_block || v_unit || v_quarter_unit || v_loc_exception || v_event_sequence;
                        vipl_uwi_display := v_loc_exception || '/' || v_legal_subdiv || '-' || v_section || '-' || v_township || '-' || v_range || ' ' || v_meridiandir || v_meridian || '/' || substr(v_event_sequence, -1, 1);
                    
                    -- FPS
                    when substr(vipl_uwi_local, 1,1) = '3' then
                        v_loctype         := substr(vipl_uwi_local,1, 1);      
                        v_lat_deg         := substr(vipl_uwi_local, 7, 2);
                        v_lat_min         := substr(vipl_uwi_local, 9, 2);
                        v_long_deg        := substr(vipl_uwi_local, 11, 3);
                        v_long_min        := substr(vipl_uwi_local, 14, 2);
                        v_section         := substr(vipl_uwi_local, 5, 2);
                        v_unit            := substr(vipl_uwi_local, 4, 1);
                        v_loc_exception   := substr(vipl_uwi_local, 2, 2);
                        v_event_sequence  := substr(vipl_uwi_local, 16, 1);  
                          
                        vipl_uwi_sort := v_loctype || v_lat_deg || v_lat_min || v_long_deg || v_long_min || v_section || v_unit || v_loc_exception || v_event_sequence;
                        vipl_uwi_display := v_loc_exception || '/' || v_legal_subdiv || '-' || v_section || '-' || v_township || '-' || v_range || ' ' || v_meridiandir || v_meridian || '/' || substr(v_event_sequence, -1, 1);
                end case;
            exception
                when others then 
                    verrors := 1;
            end;
        end if;
        
        update wim.wim_stg_well_version
        set ipl_uwi_sort = vipl_uwi_sort
            , ipl_uwi_display = vipl_uwi_display
        where wim_stg_id = pstg_id;

        return verrors;
   end ipl_sort_display_trnsf;
   
/*----------------------------------------------------------------------------------------------------------
Function:  ipl_offshore_ind_trnsf
Detail:    This function Checks if ipl_uwi_local (government id) is not null
           and will populate the IPL_UWI_SORT and IPL_UWI_DISPLAY
           This applies when Creating, Adding or Updating wells.
      
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
    function ipl_offshore_ind_trnsf (
        pstg_id     wim_stg_request.wim_stg_id%type,
        pseq        number,
        prule_id    number,
        paudit_id   number
    ) return number
    is
        vtlm_id           wim_stg_well_version.uwi%type;
        vaudit_type       wim_audit_log.audit_type%type;
        vaction_cd        wim_stg_well_version.wim_action_cd%type;
        vsource           wim_stg_well_version.source%type;
        vipl_offshore_ind wim_stg_well_version.ipl_offshore_ind%type;
        vuser             wim_stg_request.row_created_by%type;
        verrors           number := 0;
        vaudit_id         number;
        vmsg_text         varchar2(255);
        
        
    begin
        vaudit_id := paudit_id;
        vuser := get_request_created_by_value (pstg_id);
        
        select uwi, source, wim_action_cd, ipl_offshore_ind
        into vtlm_id, vsource, vaction_cd, vipl_offshore_ind
        from wim_stg_well_version
        where wim_stg_id = pstg_id
        ;
        
        if vipl_offshore_ind = 'Y' then
            vipl_offshore_ind := 'OFFSHORE';    
        else
            vipl_offshore_ind := 'ONSHORE';
        end if;
        
        begin
            update wim_stg_well_version
            set ipl_offshore_ind = vipl_offshore_ind
            where wim_stg_id = pstg_id
            ;
        exception
            when others then
                select msg_text, failure_level_cd
                into vmsg_text, vaudit_type
                from validate_rule
                where rule_id = prule_id
                ;
        
                vmsg_text := vmsg_text || ', the value '
                    || vipl_offshore_ind
                    || ' was received.'
                ;
            
                wim_audit.audit_event (
                    paudit_id   => vaudit_id,
                    paction     => vaction_cd,
                    psource     => vsource,
                    ptext       => vmsg_text,
                    ptlm_id     => vtlm_id,
                    pattribute  => 'wim_stg_well_version.ipl_offshore_ind',
                    paudit_type => vaudit_type,
                    puser       => vuser
                );
                verrors := verrors + 1;    
        end;
        
        return verrors;
    end ipl_offshore_ind_trnsf;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_RULE_GENERIC
Detail:    This function performas all custom and non-table specific validations.
           This function gets called from Validate_Generic.
                     
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_rule_generic (
      pstg_id      wim_stg_request.wim_stg_id%TYPE,
      pseq         NUMBER,
      paudit_id    NUMBER,
      prule_id     validate_rule.rule_id%TYPE,
      pbody_code   validate_rule.body_code%TYPE
   )
      RETURN NUMBER
   IS
      v_retvalue       NUMBER;
      v_codeblock      VARCHAR (2000);
      v_errors         NUMBER                                    := 0;
      v_audit_id       NUMBER;
      verrmsg          VARCHAR2 (500);
      vaudit_type      wim_audit_log.audit_type%TYPE             := 'F';
      v_table          VARCHAR2 (255);
      v_if_condition   VARCHAR2 (255);
      v_count          NUMBER;
      vaction_cd       wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd       wim_stg_well_version.SOURCE%TYPE;
      vtlm_id          wim_stg_well_version.uwi%TYPE;
      vuser            wim_stg_request.row_created_by%TYPE;
   BEGIN
      vuser := get_request_created_by_value (pstg_id);
      /*check if_condition - may be we don't even need to run this rule*/
      v_table := get_rule_attribute_value (prule_id, 'TABLE_NAME');
      v_if_condition := get_rule_attribute_value (prule_id, 'IF_CONDITION');

      IF v_if_condition IS NOT NULL AND v_table IS NOT NULL
      THEN
         -- Build and run the check
         v_codeblock :=
               'SELECT COUNT(1) FROM '
            || v_table
            || ' WHERE '
            || v_if_condition
            || ' AND WIM_STG_ID = :pSTG_ID ';

         IF pseq IS NOT NULL
         THEN                                     -- apply secondary ID filter
            v_codeblock := v_codeblock || ' AND WIM_SEQ= ' || pseq;
         END IF;

         EXECUTE IMMEDIATE v_codeblock
                      INTO v_count
                     USING pstg_id;

         IF v_count = 0
         THEN
/* if this condition is not true there is no reason to process with actual rule*/
            RETURN 0;
         END IF;
      END IF;
      
      v_codeblock := 'CALL ' || pbody_code || '(:p1, :p2, :p3, :p4) INTO :p5';

      EXECUTE IMMEDIATE v_codeblock
                  USING IN     pstg_id,
                        IN     pseq,
                        IN     prule_id,
                        IN     paudit_id,
                        OUT    v_retvalue;

-- DBMS_OUTPUT.put_line ( 'rule ID:'
-- || prule_id
-- || ' code: '
-- || v_codeblock
-- || ' returned value is '
-- || v_retvalue
-- );
      RETURN v_retvalue;
   EXCEPTION
      WHEN OTHERS
      THEN
         verrmsg :=
               'rule ID:'
            || prule_id
            || ' code: '
            || v_codeblock
            || ' error: '
            || SUBSTR (SQLERRM, 1, 255);
         --DBMS_OUTPUT.put_line (verrmsg);
         v_audit_id := paudit_id;

         SELECT uwi, wim_action_cd, SOURCE
           INTO vtlm_id, vaction_cd, vsource_cd
           FROM wim_stg_well_version
          WHERE wim_stg_id = pstg_id;

         wim_audit.audit_event (paudit_id        => v_audit_id,
                                paction          => NULL,
                                psource          => vsource_cd,
                                ptext            => verrmsg,
                                ptlm_id          => vtlm_id,
                                pattribute       => NULL,
                                paudit_type      => vaudit_type,
                                puser            => vuser
                               );
         RETURN 1;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_GENERIC
Detail:    This function performas all custom and non-table specific validations.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
/* Validate all rules not applicable for any of the staging tables*/
   FUNCTION validate_generic (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR rule_cur
      IS
         SELECT vr.rule_id, vr.rule_type_cd,
                NVL (vr.body_code, vrt.body_code) AS body_code
           FROM validate_rule vr INNER JOIN validate_rule_type vrt
                ON vr.rule_type_cd = vrt.rule_type_cd
                LEFT JOIN validate_rule_attribute vra
                ON vr.rule_id = vra.rule_id
              AND vra.rule_attribute_type_cd = 'TABLE_NAME'
          WHERE vr.active_ind = 'Y'
            AND vr.priority_level_cd <= ppriority_level_cd
            -- check for priority
            AND (   vra.attribute_value IS NULL
                 OR vra.attribute_value NOT IN
                       ('WIM_STG_WELL_VERSION', 'WIM_STG_WELL_STATUS',
                        'WIM_STG_WELL_LICENSE', 'WIM_STG_WELL_NODE_VERSION',
                        'WIM_STG_WELL_NODE_M_B')
                );                                       /*no table specific*/

      rule_rec      rule_cur%ROWTYPE;
      vaudit_id     NUMBER;
      v_retvalue    NUMBER;
      v_codeblock   VARCHAR (255);
      v_errors      NUMBER             := 0;
   BEGIN
      /* we can't determin action for generic validatetion rule*/
      v_current_action_cd := NULL;

      OPEN rule_cur;

      LOOP
         FETCH rule_cur
          INTO rule_rec;

         EXIT WHEN rule_cur%NOTFOUND;
         v_retvalue :=
            validate_rule_generic (pstg_id,
                                   NULL,
                                   paudit_id,
                                   rule_rec.rule_id,
                                   rule_rec.body_code
                                  );
         v_errors := v_errors + v_retvalue;
      END LOOP;

      CLOSE rule_cur;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_UOM
Detail:    This function Checks if UOM value is missing, 
            (e.g if distance_to_loc value is provided but wim_distance_to_loc_uom is not ) 
            If it is, adds an Error message to wim_audit_log table.
            This applies when Creating, Adding or Updating wells.

           
History of Change:
------------------------------------------------------------------------------------------------------------*/

/* Validate UoM conversion fields*/
   FUNCTION validate_uom (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_errors   NUMBER                                := 0;
      vuser      wim_stg_request.row_created_by%TYPE;
   BEGIN
      vuser := get_request_created_by_value (pstg_id);

      FOR rec IN (SELECT *
                    FROM wim_stg_well_license
                   WHERE wim_stg_id = pstg_id
                     AND wim_action_cd IN ('C', 'A', 'U'))
      LOOP
         IF     rec.direction_to_loc IS NOT NULL
            AND rec.wim_direction_to_loc_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_license',
                                   'wim_direction_to_loc_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.distance_to_loc IS NOT NULL
            AND rec.wim_distance_to_loc_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_license',
                                   'wim_distance_to_loc_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.projected_depth IS NOT NULL
            AND rec.wim_distance_to_loc_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_license',
                                   'wim_projected_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.projected_tvd IS NOT NULL
            AND rec.wim_projected_tvd_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_license',
                                   'wim_projected_tvd_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.rig_substr_height IS NOT NULL
            AND rec.wim_projected_tvd_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_license',
                                   'wim_rig_substr_height_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      FOR rec IN (SELECT *
                    FROM wim_stg_well_node_version
                   WHERE wim_stg_id = pstg_id
                     AND wim_action_cd IN ('C', 'A', 'U'))
      LOOP
         IF rec.easting IS NOT NULL AND rec.wim_easting_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_easting_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.elev IS NOT NULL AND rec.wim_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.md IS NOT NULL AND rec.wim_md_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_md_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.northing IS NOT NULL AND rec.wim_northing_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_northing_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.polar_offset IS NOT NULL AND rec.wim_polar_offset_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_polar_offset_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.reported_tvd IS NOT NULL AND rec.wim_reported_tvd_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_reported_tvd_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.x_offset IS NOT NULL AND rec.wim_x_offset_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_x_offset_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.y_offset IS NOT NULL AND rec.wim_y_offset_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_version',
                                   'wim_y_offset_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      FOR rec IN (SELECT *
                    FROM wim_stg_well_status
                   WHERE wim_stg_id = pstg_id
                     AND wim_action_cd IN ('C', 'A', 'U'))
      LOOP
         IF rec.status_depth IS NOT NULL
            AND rec.wim_status_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_status',
                                   'wim_status_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      FOR rec IN (SELECT *
                    FROM wim_stg_well_node_m_b
                   WHERE wim_stg_id = pstg_id
                     AND wim_action_cd IN ('C', 'A', 'U'))
      LOOP
         IF rec.ew_distance IS NOT NULL AND rec.wim_ew_distance_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_m_b',
                                   'wim_ew_distance_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.ns_distance IS NOT NULL AND rec.wim_ns_distance_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   rec.wim_seq,
                                   'wim_stg_well_node_m_b',
                                   'wim_ns_distance_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      FOR rec IN (SELECT *
                    FROM wim_stg_well_version
                   WHERE wim_stg_id = pstg_id
                     AND wim_action_cd IN ('C', 'A', 'U'))
      LOOP
         IF     rec.casing_flange_elev IS NOT NULL
            AND rec.wim_casing_flange_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_casing_flange_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.confidential_depth IS NOT NULL
            AND rec.wim_confidential_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_confidential_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.deepest_depth IS NOT NULL
            AND rec.wim_deepest_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_deepest_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.depth_datum_elev IS NOT NULL
            AND rec.wim_depth_datum_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_depth_datum_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.derrick_floor_elev IS NOT NULL
            AND rec.wim_derrick_floor_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_derrick_floor_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.drill_td IS NOT NULL AND rec.wim_drill_td_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_drill_td_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.final_td IS NOT NULL AND rec.wim_final_td_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_final_td_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.ground_elev IS NOT NULL AND rec.wim_ground_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_ground_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.kb_elev IS NOT NULL AND rec.wim_kb_elev_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_kb_elev_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.log_td IS NOT NULL AND rec.wim_log_td_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_log_td_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.max_tvd IS NOT NULL AND rec.wim_max_tvd_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_max_tvd_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.net_pay IS NOT NULL AND rec.wim_net_pay_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_net_pay_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.plugback_depth IS NOT NULL
            AND rec.wim_plugback_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_plugback_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF rec.water_depth IS NOT NULL AND rec.wim_water_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_water_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;

         IF     rec.whipstock_depth IS NOT NULL
            AND rec.wim_whipstock_depth_cuom IS NULL
         THEN
            add_uom_error_message (paudit_id,
                                   NULL,
                                   'wim_stg_well_version',
                                   'wim_whipstock_depth_cuom',
                                   vuser
                                  );
            v_errors := v_errors + 1;
         END IF;
      END LOOP;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL_VERSION
Detail:    This function validate data using validation rules applicable to wim_stg_well_version table..
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_well_version (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN NUMBER
   IS
      v_retvalue   NUMBER := 0;
      v_errors     NUMBER := 0;
   BEGIN
      --v_errors := validate_uom (pstg_id, paudit_id);
      --RETURN v_errors;

      -- TODO enable the rest of validation
      FOR well_version_rec IN (SELECT wim_stg_id, wim_action_cd, SOURCE,
                                      country
                                 FROM wim_stg_well_version vrec
                                WHERE wim_stg_id = pstg_id)
      LOOP
         v_current_action_cd := well_version_rec.wim_action_cd;

         FOR rule_rec IN (SELECT   vr.rule_id, vr.rule_type_cd,
                                   NVL (vr.body_code,
                                        vrt.body_code
                                       ) AS body_code
                              FROM validate_rule vr INNER JOIN validate_rule_type vrt
                                   ON vr.rule_type_cd = vrt.rule_type_cd
                                   LEFT JOIN validate_rule_source vr_source
                                   ON vr.rule_id = vr_source.rule_id
                                   LEFT JOIN validate_rule_country vr_country
                                   ON vr.rule_id = vr_country.rule_id
                                   INNER JOIN validate_rule_attribute vra
                                   ON vr.rule_id = vra.rule_id
                                 AND vra.rule_attribute_type_cd = 'TABLE_NAME'
                                 AND UPPER (vra.attribute_value) =
                                                        'WIM_STG_WELL_VERSION'
                             WHERE vr.active_ind = 'Y'
                               AND vr.priority_level_cd <= ppriority_level_cd
                               -- check for priority
                               AND (   well_version_rec.SOURCE =
                                                           vr_source.source_cd
                                    OR vr_source.source_cd IS NULL
                                   )
                               AND (   well_version_rec.country =
                                                         vr_country.country_cd
                                    OR vr_country.country_cd IS NULL
                                   )
                               AND (   vr.action_cd IS NULL
                                    OR INSTR (vr.action_cd,
                                              well_version_rec.wim_action_cd
                                             ) > 0
                                   )
                          --AND well_version_rec.wim_action_cd <> 'X' -- ignore wells with X actions
                          ORDER BY rule_order)
         LOOP
            v_retvalue :=
               validate_rule_generic (pstg_id,
                                      NULL,
                                      paudit_id,
                                      rule_rec.rule_id,
                                      rule_rec.body_code
                                     );
            v_errors := v_errors + v_retvalue;
         END LOOP;
      END LOOP;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL_LICENSE
Detail:    This function validate data using validation rules applicable to wim_stg_well_license table..
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_well_license (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN NUMBER
   IS
      v_retvalue   NUMBER;
      v_errors     NUMBER := 0;
   BEGIN
      FOR stg_rec IN (SELECT wim_stg_id, wim_action_cd, SOURCE
                        FROM wim_stg_well_license vrec
                       WHERE wim_stg_id = pstg_id)
      LOOP
         v_current_action_cd := stg_rec.wim_action_cd;

         FOR rule_rec IN (SELECT vr.rule_id, vr.rule_type_cd,
                                 NVL (vr.body_code,
                                      vrt.body_code
                                     ) AS body_code
                            FROM validate_rule vr INNER JOIN validate_rule_type vrt
                                 ON vr.rule_type_cd = vrt.rule_type_cd
                                 LEFT JOIN validate_rule_source vr_source
                                 ON vr.rule_id = vr_source.rule_id
                                 --LEFT JOIN validate_rule_country vr_country ON vr.rule_id = vr_country.rule_id
                                 INNER JOIN validate_rule_attribute vra
                                 ON vr.rule_id = vra.rule_id
                               AND vra.rule_attribute_type_cd = 'TABLE_NAME'
                               AND UPPER (vra.attribute_value) =
                                                        'WIM_STG_WELL_LICENSE'
                           WHERE vr.active_ind = 'Y'
                             AND vr.priority_level_cd <= ppriority_level_cd
                             -- check for priority
                             AND (   stg_rec.SOURCE = vr_source.source_cd
                                  OR vr_source.source_cd IS NULL
                                 )
                             --AND (well_version_rec.COUNTRY = vr_country.COUNTRY_CD OR vr_country.COUNTRY_CD IS NULL)
                             AND (   vr.action_cd IS NULL
                                  OR INSTR (vr.action_cd,
                                            stg_rec.wim_action_cd
                                           ) > 0
                                 ))
         LOOP
            v_retvalue :=
               validate_rule_generic (pstg_id,
                                      NULL,
                                      paudit_id,
                                      rule_rec.rule_id,
                                      rule_rec.body_code
                                     );
            v_errors := v_errors + v_retvalue;
         END LOOP;
      END LOOP;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL_STATUS
Detail:    This function validate data using validation rules applicable to wim_stg_well_status table..
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_well_status (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN VARCHAR2
   IS
      CURSOR rule_cur
      IS
         SELECT vr.rule_id, vr.rule_type_cd,
                NVL (vr.body_code, vrt.body_code) AS body_code
           FROM validate_rule vr INNER JOIN validate_rule_type vrt
                ON vr.rule_type_cd = vrt.rule_type_cd
                INNER JOIN validate_rule_attribute vra
                ON vr.rule_id = vra.rule_id
              AND vra.rule_attribute_type_cd = 'TABLE_NAME'
              AND UPPER (vra.attribute_value) = 'WIM_STG_WELL_STATUS'
          WHERE vr.active_ind = 'Y'
            AND vr.priority_level_cd <= ppriority_level_cd;

      -- check for priority ;
      rule_rec      rule_cur%ROWTYPE;
      vaudit_id     NUMBER;
      v_retvalue    NUMBER;
      v_codeblock   VARCHAR (255);
      v_errors      NUMBER             := 0;
   BEGIN
      OPEN rule_cur;

      LOOP
         FETCH rule_cur
          INTO rule_rec;

         EXIT WHEN rule_cur%NOTFOUND;

         FOR rec IN (SELECT wim_seq, wim_action_cd
                       FROM wim_stg_well_status
                      WHERE wim_stg_id = pstg_id)
         LOOP
            v_current_action_cd := rec.wim_action_cd;
            v_retvalue :=
               validate_rule_generic (pstg_id,
                                      rec.wim_seq,
                                      paudit_id,
                                      rule_rec.rule_id,
                                      rule_rec.body_code
                                     );
            v_errors := v_errors + v_retvalue;
         END LOOP;
      END LOOP;

      CLOSE rule_cur;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL_NODE_VERSION
Detail:    This function validate data using validation rules applicable to wim_stg_well_node_version table..
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_well_node_version (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN VARCHAR2
   IS
      CURSOR rule_cur
      IS
         SELECT vr.rule_id, vr.rule_type_cd,vr.action_cd,
                NVL (vr.body_code, vrt.body_code) AS body_code
           FROM validate_rule vr INNER JOIN validate_rule_type vrt
                ON vr.rule_type_cd = vrt.rule_type_cd
                INNER JOIN validate_rule_attribute vra
                ON vr.rule_id = vra.rule_id
              AND vra.rule_attribute_type_cd = 'TABLE_NAME'
              AND UPPER (vra.attribute_value) = 'WIM_STG_WELL_NODE_VERSION'
          WHERE vr.active_ind = 'Y'
            AND vr.priority_level_cd <= ppriority_level_cd;


      -- check for priority ;
      rule_rec      rule_cur%ROWTYPE;
      vaudit_id     NUMBER;
      v_retvalue    NUMBER;
      v_codeblock   VARCHAR (2000);
      v_errors      NUMBER             := 0;
   BEGIN
   
                                     
   
      OPEN rule_cur;

      LOOP
         FETCH rule_cur
          INTO rule_rec;

         EXIT WHEN rule_cur%NOTFOUND;

         FOR rec IN (SELECT wim_seq, wim_action_cd
                       FROM wim_stg_well_node_version
                      WHERE wim_stg_id = pstg_id)
         LOOP
            v_current_action_cd := rec.wim_action_cd;
            
            IF instr(rule_rec.action_cd, rec.wim_action_cd) > 0 then
                v_retvalue :=
                    validate_rule_generic (pstg_id,
                                          rec.wim_seq,
                                          paudit_id,
                                          rule_rec.rule_id,
                                          rule_rec.body_code
                                         );
                v_errors := v_errors + v_retvalue;
            END IF;
         END LOOP;
      END LOOP;

      CLOSE rule_cur;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL_NODE_M_B
Detail:    This function validate data using validation rules applicable to wim_stg_well_node_m_b table..
           
History of Change:
------------------------------------------------------------------------------------------------------------*/

   FUNCTION validate_well_node_m_b (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      paudit_id            NUMBER,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE
   )
      RETURN VARCHAR2
   IS
      CURSOR rule_cur
      IS
         SELECT vr.rule_id, vr.rule_type_cd,
                NVL (vr.body_code, vrt.body_code) AS body_code
           FROM validate_rule vr INNER JOIN validate_rule_type vrt
                ON vr.rule_type_cd = vrt.rule_type_cd
                INNER JOIN validate_rule_attribute vra
                ON vr.rule_id = vra.rule_id
              AND vra.rule_attribute_type_cd = 'TABLE_NAME'
              AND UPPER (vra.attribute_value) = 'WIM_STG_WELL_NODE_M_B'
          WHERE vr.active_ind = 'Y'
            AND vr.priority_level_cd <= ppriority_level_cd;

      -- check for priority ;
      rule_rec      rule_cur%ROWTYPE;
      vaudit_id     NUMBER;
      v_retvalue    NUMBER;
      v_codeblock   VARCHAR (255);
      v_errors      NUMBER             := 0;
   BEGIN
      OPEN rule_cur;

      LOOP
         FETCH rule_cur
          INTO rule_rec;

         EXIT WHEN rule_cur%NOTFOUND;

         FOR rec IN (SELECT wim_seq, wim_action_cd
                       FROM wim_stg_well_node_m_b
                      WHERE wim_stg_id = pstg_id)
         LOOP
            v_current_action_cd := rec.wim_action_cd;
            v_retvalue :=
               validate_rule_generic (pstg_id,
                                      rec.wim_seq,
                                      paudit_id,
                                      rule_rec.rule_id,
                                      rule_rec.body_code
                                     );
            v_errors := v_errors + v_retvalue;
         END LOOP;
      END LOOP;

      CLOSE rule_cur;

      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  INTERNAL_VALIDATE
Detail:    This function generateS missing data, E.G: TLM_ID, NODE_IDs, etc 
           
History of Change:
Feb 27 2012  VRajpoot           Modified so:
                                If Action Cd is A, no need to check if Inactive version exists.                                                                  

------------------------------------------------------------------------------------------------------------*/
 
   FUNCTION internal_validate (pwim_stg_id NUMBER, paudit_id NUMBER)
      RETURN NUMBER
   IS
      v_well_version      wim_stg_well_version%ROWTYPE;
      v_uwi               wim_stg_well_version.uwi%TYPE;
      v_node_id           wim_stg_well_node_version.node_id%TYPE;
      v_base_node_id      wim_stg_well_node_version.node_id%TYPE;
      v_surface_node_id   wim_stg_well_node_version.node_id%TYPE;
      v_node_obs_no       wim_stg_well_node_version.node_obs_no%TYPE;
      v_count             NUMBER;
      vaudit_id           NUMBER;
   BEGIN
      vaudit_id := paudit_id;

      SELECT *
        INTO v_well_version
        FROM wim_stg_well_version
       WHERE wim_stg_id = pwim_stg_id;

      v_base_node_id := NULL;
      v_surface_node_id := NULL;

      /* Generate new TLM_ID and propogate it on all child records*/
      IF v_well_version.uwi IS NULL AND v_well_version.wim_action_cd = 'C'
      THEN
         SELECT wim_tlm_id_seq.NEXTVAL
           INTO v_uwi
           FROM DUAL;

         UPDATE wim_stg_well_version
            SET uwi = v_uwi
          WHERE wim_stg_id = pwim_stg_id;
      ELSE
         v_uwi := v_well_version.uwi;
      END IF;

      /* Generate new TLM_ID and propogate it on all child records*/
        
      IF     v_well_version.uwi IS NOT NULL
         AND v_well_version.wim_action_cd IN ('A', 'C')
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM well_version
          WHERE uwi = v_well_version.uwi 
            AND SOURCE = v_well_version.SOURCE;
            
            If v_well_version.wim_action_cd IN ('A')
            THEN --For Add, only need to check Active Ones
                SELECT COUNT (1)
                INTO v_count
                FROM well_version
                WHERE uwi = v_well_version.uwi 
                  AND SOURCE = v_well_version.SOURCE
                  AND ACTIVE_IND = 'Y';
            end if;

         IF v_count > 0                       -- well version already existins
         THEN
            wim_audit.audit_event (paudit_id        => vaudit_id,
                                   paction          => v_well_version.wim_action_cd,
                                   paudit_type      => 'E',
                                   pattribute       => 'UWI',
                                   ptlm_id          => v_well_version.uwi,
                                   psource          => v_well_version.SOURCE,
                                   ptext            =>    'Well version '
                                                       || v_well_version.uwi
                                                       || '/'
                                                       || v_well_version.SOURCE
                                                       || ' already exists',
                                   puser            => v_well_version.row_created_by
                                  );
            RETURN 1;
         END IF;
      END IF;



      UPDATE wim_stg_well_node_version
         SET ipl_uwi = NVL (ipl_uwi, v_uwi),
             SOURCE = NVL (SOURCE, v_well_version.SOURCE),
             country = NVL (country, v_well_version.country),
             active_ind = NVL (active_ind, 'Y')
       WHERE wim_stg_id = pwim_stg_id;

      UPDATE wim_stg_well_node_m_b
         SET ipl_uwi = NVL (ipl_uwi, v_uwi),
             SOURCE = NVL (SOURCE, v_well_version.SOURCE),
             active_ind = NVL (active_ind, 'Y')
       WHERE wim_stg_id = pwim_stg_id;

      UPDATE wim_stg_well_license
         SET uwi = NVL (uwi, v_uwi),
             SOURCE = NVL (SOURCE, v_well_version.SOURCE),
             active_ind = NVL (active_ind, 'Y')
       WHERE wim_stg_id = pwim_stg_id;

      UPDATE wim_stg_well_status
         SET uwi = NVL (uwi, v_uwi),
             SOURCE = NVL (SOURCE, v_well_version.SOURCE),
             status_id = NVL (status_id, '001'),
             active_ind = NVL (active_ind, 'Y')
       WHERE wim_stg_id = pwim_stg_id;

-- Validate Node_IDS in wim_stg_well_node_version and wim_stg_well_node_m_b
------------------------------------------------------------------------------------------------
      FOR node_rec IN (SELECT   *
                           FROM wim_stg_well_node_version
                          WHERE wim_stg_id = pwim_stg_id
                       ORDER BY wim_seq)
      LOOP
         IF node_rec.wim_action_cd IN ('A', 'C', 'U')
         THEN
            -- convert source node_ids into tlm node_ids
            IF node_rec.node_position = 'B'
            THEN
               v_node_id := node_rec.ipl_uwi || '0';
               v_base_node_id := v_node_id;
            ELSE
               v_node_id := node_rec.ipl_uwi || '1';
               v_surface_node_id := v_node_id;
            END IF;

            v_node_obs_no := node_rec.node_obs_no;

            IF v_node_obs_no IS NULL AND node_rec.wim_action_cd IN ('A', 'C')
            THEN
               SELECT MAX (node_obs_no) + 1
                 INTO v_node_obs_no
                 FROM well_node_version
                WHERE ipl_uwi = node_rec.ipl_uwi AND SOURCE = node_rec.SOURCE;
            END IF;

            -- update source node_ids to the tlm_node_ids
            UPDATE wim_stg_well_node_m_b
               SET node_id = v_node_id
             WHERE wim_stg_id = pwim_stg_id
               AND NVL (node_id, '~') = NVL (node_rec.node_id, '~')
               AND wim_action_cd = node_rec.wim_action_cd;

            UPDATE wim_stg_well_node_version
               SET node_id = v_node_id,
                   node_obs_no = NVL (v_node_obs_no, 1),
                   -- TBD *** needs to be clever and apply a new NODE OBS NO if required
                   -- geog_coord_system_id = NVL (geog_coord_system_id, 'TBD'),
                   location_qualifier = NVL (location_qualifier, 'N/A'),
                   active_ind = NVL (active_ind, 'Y')
             WHERE wim_stg_id = pwim_stg_id AND wim_seq = node_rec.wim_seq;
         END IF;
      END LOOP;

------------------------------------------------------------------------------------------------
 -- ensure that surface node id is set in cases when surface node = base node
      IF     v_surface_node_id IS NULL
         AND v_well_version.surface_node_id = v_well_version.base_node_id
      THEN
         v_surface_node_id := v_base_node_id;
      END IF;

      UPDATE wim_stg_well_version
         SET base_node_id = NVL (v_base_node_id, base_node_id),
             surface_node_id = NVL (v_surface_node_id, surface_node_id)
       WHERE wim_stg_id = pwim_stg_id;

      RETURN 0;
   END;

/************************************************/
/* Main validation function *********************/
/*************************************************/
/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_WELL
Detail:    This function does the following validations:
            OUM convertion                                                
            Generate Missing Data
            All Custom and No Table specific validations
            Validates: Well_Version, Well_License, Well_Node_Version and well_Node_m_b specific data.
                        
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_well (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE DEFAULT 10
   /*
   1 - only mandatory rules will be applied
   2 - mandatory and

   */
   )
      RETURN NUMBER
   IS
      vaudit_id     NUMBER;
      v_retvalue    NUMBER;
      v_codeblock   VARCHAR (255);
      v_errors      NUMBER        := 0;
   BEGIN
      /* clear up global variable*/
      v_current_action_cd := NULL;

      SELECT audit_no
        INTO vaudit_id
        FROM wim_stg_request
       WHERE wim_stg_id = pstg_id;

      IF vaudit_id IS NULL
      THEN
         vaudit_id := wim_audit.get_audit_id ();

         UPDATE wim_stg_request
            SET audit_no = vaudit_id
          WHERE wim_stg_id = pstg_id;
      -- TODO do we need commit here?
      END IF;

 --DBMS_OUTPUT.put_line ('Audit_ID:' || vaudit_id);
/*-- this function will check if all needed uoms are provided*/
 --v_errors := v_errors + WIM.wim_validate.validate_uom (pstg_id, vaudit_id); ---? why did we decided to turn it off???
      IF v_errors = 0
      THEN
         wim_well_action.oum_conversion (pstg_id);
      END IF;

/*-- this function will generate missing data - TLM_ID, NODE_IDs, etc */
      v_errors := v_errors + internal_validate (pstg_id, vaudit_id);
      /* all custom and non-table specific validations*/
      v_errors :=
          v_errors + validate_generic (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_GENERIC:' || v_errors);
      v_errors :=
           v_errors
         + validate_well_version (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_WELL_VERSION:' || v_errors);
      v_errors :=
           v_errors
         + validate_well_license (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_WELL_LICENSE:' || v_errors);
      v_errors :=
           v_errors
         + validate_well_status (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_WELL_STATUS:' || v_errors);
      v_errors :=
           v_errors
         + validate_well_node_version (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_WELL_NODE_VERSION:' || v_errors);
      v_errors :=
           v_errors
         + validate_well_node_m_b (pstg_id, vaudit_id, ppriority_level_cd);
      --DBMS_OUTPUT.put_line ('VALIDATE_WELL_NODE_M_B:' || v_errors);
      RETURN v_errors;
   END;

/*----------------------------------------------------------------------------------------------------------
Function:  Validate_TLM_ID
Detail:    This function 
           Checks if TLM_ID is provided (when Inserting a new Well)
           Checks to make sure if exists in well_Version table (Updating, Adding, INactivating or Reactivating)
           Returns 0 if success, or 1 if the value is not found.
           
History of Change:
------------------------------------------------------------------------------------------------------------*/
   FUNCTION validate_tlm_id (
      paudit_id        wim_audit_log.audit_id%TYPE,
      paction          wim_audit_log.action%TYPE,
      ptlm_id          wim_audit_log.tlm_id%TYPE,
      psource          wim_audit_log.SOURCE%TYPE,
      puser       IN   wim_audit_log.row_created_by%TYPE
   )
      RETURN NUMBER
   IS
      vaudit_id   wim_audit_log.audit_id%TYPE   := paudit_id;
   BEGIN
      IF ptlm_id IS NULL
      THEN
         IF paction != 'C'
         THEN
            wim_audit.audit_event (paudit_id       => vaudit_id,
                                   paction         => paction,
                                   psource         => psource,
                                   ptext           => 'No TLM ID was specified',
                                   ptlm_id         => ptlm_id,
                                   pattribute      => 'TLM_ID',
                                   puser           => puser
                                  );
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
        dbms_output.put_line('in Validate_TLM_ID- calling Find_Well');
         IF wim_search.find_well (ptlm_id) IS NULL
         THEN
            wim_audit.audit_event (paudit_id       => vaudit_id,
                                   paction         => paction,
                                   psource         => psource,
                                   ptext           =>    'TLM ID '
                                                      || ptlm_id
                                                      || ' not found',
                                   ptlm_id         => ptlm_id,
                                   pattribute      => 'TLM_ID',
                                   puser           => puser
                                  );
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   END validate_tlm_id;
END wim_validate;