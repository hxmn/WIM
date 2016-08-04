CREATE OR REPLACE PACKAGE BODY WIM.wim_audit
IS
-- SCRIPT: WIM_Audit.pkb
--
-- PURPOSE:
--   Package body for the WIM Audit functionality
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
--   08-Apr-10  R. Masterman  Initial version
--

   -- *****************************************************************************
--  Get_Audit_ID procedure
--      Gets an audit ID to allow audit entries to be grouped for a specific
--      transaction, or action.
--
-- *****************************************************************************
   FUNCTION get_audit_id
      RETURN NUMBER
   IS
      vaudit_id   NUMBER (14) := 0;
   BEGIN
      SELECT wim_audit_id_seq.NEXTVAL
        INTO vaudit_id
        FROM DUAL;

      RETURN vaudit_id;
   END get_audit_id;

-- *****************************************************************************
--  Audit_Event procedure
--      Adds an entry to the Audit log.
-- *****************************************************************************
   PROCEDURE audit_event (
      paudit_id     IN OUT   wim_audit_log.audit_id%TYPE,
      paction       IN       wim_audit_log.action%TYPE,
      psource       IN       wim_audit_log.SOURCE%TYPE,
      ptext         IN       wim_audit_log.text%TYPE,
      ptlm_id       IN       wim_audit_log.tlm_id%TYPE DEFAULT NULL,
      paudit_type   IN       wim_audit_log.audit_type%TYPE DEFAULT 'E',
      pattribute    IN       wim_audit_log.ATTRIBUTE%TYPE DEFAULT NULL,
      pseq          IN       wim_audit_log.wim_seq%TYPE DEFAULT NULL,
      puser         IN       wim_audit_log.row_created_by%TYPE-- DEFAULT USER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF paudit_id IS NULL
      THEN
         paudit_id := get_audit_id ();
      END IF;

      INSERT INTO wim_audit_log
                  (audit_id, action, audit_type, ATTRIBUTE, tlm_id,
                   SOURCE, text, wim_seq, row_created_date, row_created_by
                  )
           VALUES (paudit_id, paction, paudit_type, pattribute, ptlm_id,
                   psource, ptext, pseq, SYSTIMESTAMP, puser
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
         ROLLBACK;
   END audit_event;

   PROCEDURE clear_audit_event_log (
      paudit_id   IN OUT   wim_audit_log.audit_id%TYPE
   )
   IS
   --PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM wim_audit_log
            WHERE audit_id = paudit_id;
   END clear_audit_event_log;
END wim_audit;
/

