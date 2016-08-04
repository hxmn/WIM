CREATE OR REPLACE PACKAGE WIM.wim_audit
IS
-- SCRIPT: WIM_Audit.pks
--
-- PURPOSE:
--   Package specification for the WIM Audit functionality
--   Well Identity Master (WIM) is the TLM International Exploration well identity
--   master dataset. The WIM Audit package provides functionality to log errors,
--   warnings and events to a central audit log.
--
--   Procedure/Function Summary
--     Audit_Event     Adds an audit event message to the WIM Audit log
--
-- DEPENDENCIES
--   WIM Audit table
--   WIM Audit Sequence Generator
--
-- EXECUTION:
--   Used by other WIM packages and applications to log erros and events
--
--   Syntax:
--    e.g. WIM_GATEWAY.WELL_AUDIT(<parameter list>)
--
-- HISTORY:
--   0.1    08-Apr-10  R. Masterman    Initial version
--
-- *****************************************************************************
--  Public Definitions
-- *****************************************************************************
--
--  Audit Log
--    The WIM audit log  contains errors, warnings and information messages
--    in the WIM_AUDIT_LOG table. The audit log table contains the following:
--    Audit_ID          Groups all messages for an action under a single ID
--    Action            The action that gave rise to the message, e.g. C
--    Audit_Type        ERROR, WARNING or INFO
--    Attribute         The attribute the message refers to
--    TLM_ID            TLM ID of the well, if available
--    Source            Well source, where available
--    Text              Message text
--    Row_Created_Date  When the message was generated
--    Row_Created_By    Oracle user that generated the message
--

   -- *****************************************************************************
--  Get_Audit_ID procedure
--      Gets an audit ID to allow audit entries to be grouped for a specific
--      transaction, or action.
--
-- *****************************************************************************
   FUNCTION get_audit_id
      RETURN NUMBER;

-- *****************************************************************************
--  AUDIT_EVENT procedure
-- *****************************************************************************
--      Records an audit event in the WIM audit log. Can be used by external
--    processes to record events that affect WIM.
--
--    Parameter notes:
--      pAudit_ID      Defines a group of audit messages. This should be NULL on
--                     the first call for an activity. It will return an ID which
--                     should be used in subsequent calls for the same activity.
--                     Allows all messages for a specific activity to be selected
--                     from the audit table as a group.
--      pAction           The action that gave rise to the message, e.g. C for CREATE
--      pSource        Well source, where available
--      pText          Audit message text
--      pTLM_ID        TLM ID of the well, if available otherwise NULL.
--      pAudit_type    ERROR, WARNING or INFO
--      pAttribute     The attribute the message refers to. NULL if no specific
--                     attribute.
   PROCEDURE audit_event (
      paudit_id     IN OUT   wim_audit_log.audit_id%TYPE,
      paction       IN       wim_audit_log.action%TYPE,
      psource       IN       wim_audit_log.SOURCE%TYPE,
      ptext         IN       wim_audit_log.text%TYPE,
      ptlm_id       IN       wim_audit_log.tlm_id%TYPE DEFAULT NULL,
      paudit_type   IN       wim_audit_log.audit_type%TYPE DEFAULT 'E',
      pattribute    IN       wim_audit_log.ATTRIBUTE%TYPE DEFAULT NULL,
      pseq          IN       wim_audit_log.wim_seq%TYPE DEFAULT NULL,
      puser         IN       wim_audit_log.row_created_by%TYPE
                                                              -- DEFAULT USER
   );

   PROCEDURE clear_audit_event_log (
      paudit_id   IN OUT   wim_audit_log.audit_id%TYPE
   );
END wim_audit;
/

