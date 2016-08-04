CREATE OR REPLACE PACKAGE BODY WIM.wim_validate_cust
IS

/*-----------------------------------------------------------------------------------------------------------------------------------
 SCRIPT: WIM.WIM_VALIDATE_CUST.pkb

 PURPOSE:
      TThis package contains a function to validate Nodes:
      It is part of WIM_GATEWAY.

      Procedure/Function Details
            See Package Spec.


HISTORY:


-----------------------------------------------------------------------------------------------------------------------------------*/

   v_current_action_cd   wim_stg_well_version.wim_action_cd%TYPE;


/*----------------------------------------------------------------------------------------------------------
Function:  VALIDATE_NODES
Detail:    This Function Checks for missing nodes
            checks the node id follow the numbering convention ( .e.g Surface Node should be TLM_ID || '1' )


History of Change:
------------------------------------------------------------------------------------------------------------*/

   FUNCTION validate_nodes (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER
   IS
      v_table          VARCHAR2 (255);
      v_err_field      VARCHAR2 (255);
      vcount           NUMBER;
      vaudit_id        NUMBER;
      vtlm_id          wim_stg_well_version.uwi%TYPE;
      vmsg_text        VARCHAR (255);
      vaudit_type      wim_audit_log.audit_type%TYPE;
      vattribute       wim_audit_log.ATTRIBUTE%TYPE;
      vaction_cd       wim_stg_well_version.wim_action_cd%TYPE;
      vsource_cd       wim_stg_well_version.SOURCE%TYPE;
      vuser            wim_stg_request.row_created_by%TYPE;
      v_errors         NUMBER;
      v_well_version   wim_stg_well_version%ROWTYPE;
   BEGIN
      vaudit_id := paudit_id;

      SELECT *
        INTO v_well_version
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT uwi, wim_action_cd, SOURCE, row_created_by
        INTO vtlm_id, vaction_cd, vsource_cd, vuser
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id;

      SELECT msg_text, failure_level_cd
        INTO vmsg_text, vaudit_type
        FROM validate_rule
       WHERE rule_id = prule_id;

      v_errors := 0;
      v_table := 'WIM_STG_WELL_VERSION';

      v_current_action_cd := v_well_version.wim_action_cd;

      -- Check for missing surface nodes
      v_err_field := 'surface_node_id';

      SELECT COUNT (*)
        INTO vcount
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id
         AND wim_action_cd IN ('A', 'C', 'U', 'X')
         AND (   surface_node_id IS NULL
              OR surface_node_id IN (SELECT node_id
                                       FROM wim_stg_well_node_version
                                      WHERE wim_stg_id = pstg_id)
             );

      IF vcount = 0
      THEN
         vmsg_text := 'Well ' || vtlm_id || ' missing surface node';

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
         v_errors := v_errors + 1;
      END IF;

      -- check surface node id numbering convention
--          IF     v_well_version.wim_action_cd IN ('A', 'C', 'U')
--         AND v_well_version.surface_node_id IS NOT NULL
--         AND v_well_version.surface_node_id !=
--                                              CONCAT (v_well_version.uwi, '0')
--         AND v_well_version.surface_node_id !=
--                                              CONCAT (v_well_version.uwi, '1')

          IF     v_well_version.wim_action_cd IN ('A', 'C', 'U')
         AND v_well_version.surface_node_id IS NOT NULL
         AND v_well_version.surface_node_id !=
                                              CONCAT (v_well_version.uwi, '1')

      THEN
         vmsg_text :=
               'Well '
            || vtlm_id
            || ' does not follow the surface node id numbering convention';

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
         v_errors := v_errors + 1;
      END IF;

      -- Check for missing base nodes
      v_err_field := 'base_node_id';

      SELECT COUNT (*)
        INTO vcount
        FROM wim_stg_well_version
       WHERE wim_stg_id = pstg_id
         AND wim_action_cd IN ('A', 'C', 'U', 'X')
         AND (   base_node_id IS NULL
              OR base_node_id IN (SELECT node_id
                                    FROM wim_stg_well_node_version
                                   WHERE wim_stg_id = pstg_id)
             );

      IF vcount = 0
      THEN
         vmsg_text := 'Well ' || vtlm_id || ' missing base node';

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
         v_errors := v_errors + 1;
      END IF;

      IF     v_well_version.wim_action_cd IN ('A', 'C', 'U')
         AND v_well_version.base_node_id IS NOT NULL
         AND v_well_version.base_node_id != CONCAT (v_well_version.uwi, '0')
      THEN
         vmsg_text :=
               'Well '
            || vtlm_id
            || ' does not follow the base node id numbering convention ';

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
         v_errors := v_errors + 1;
      END IF;

      RETURN v_errors;
   END;
END;
/