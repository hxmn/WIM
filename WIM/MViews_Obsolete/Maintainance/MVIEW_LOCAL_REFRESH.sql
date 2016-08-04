-- SCRIPT: MVIEW_LOCAL_REFRESH.sql
--
-- PURPOSE:
--   Create procedure to fully refresh the WIM MViews in PET* that DO NOT
--   link to IHS - ie. the local mviews.
--   Run by an Oracle job overnight or weekends to ensure the Mviews
--   are kept up to date.
--   The complete refresh takes a few minutes and each MVIEW will be
--   emptied and recreated so must be done outside of normal hours
--
-- DEPENDENCIES
--   WIM built in package TLM_MVIEW_UTILS
--
-- EXECUTION:
--   Run as PET* - Usually run as an Oracle job
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   8-Jun-10  R. Masterman  Initial version

CREATE OR REPLACE PROCEDURE PPDM.Mview_Local_Refresh IS
 
BEGIN

  -- Log the Refresh check is starting
  tlm_process_logger.info ('MVIEW_LOCAL_REFRESH: Started');

  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','BUSINESS_ASSOCIATE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_REASON_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_SOURCE','C');

  -- Log the Refresh check is done
  tlm_process_logger.info ('MVIEW_LOCAL_REFRESH: Complete');
 
END;

