-- SCRIPT: MVIEW_COMPLETE_REFRESH.sql
--
-- PURPOSE:
--   Create procedure to fully refresh all of the WIM MViews in PET*
--   Run by an Oracle job overnight or weekends to ensure the Mviews
--   are kept up to date.
--   The complete refresh takes several hours and each MVIEW will be
--   emptied and recreated so must be done outside of normal hours
--
-- DEPENDENCIES
--   WIM built in package TLM_MVIEW_UTILS
--
-- EXECUTION:
--   Run as PET* - Usually run through TOAD
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   30-May-10  R. Masterman  Initial version
--   31-May-10  R. Masterman  Added the spatial mview to the list too

CREATE OR REPLACE PROCEDURE PPDM.Mview_Complete_Refresh IS
 
BEGIN

  -- Log the Refresh check is starting
  tlm_process_logger.info ('MVIEW_COMPLETE_REFRESH: Started');

  --  Main views
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_ALIAS','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_VERSION','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_NODE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_NODE_VERSION','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_LICENSE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_NODE_M_B','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_STATUS','C');
  
  --  Secondary mviews
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_COUNTRY','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_COUNTY','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_DISTRICT','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_GEOLOGIC_PROVINCE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_PLOT_SYMBOL','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','POOL','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','IPL_BUSINESS_ASSOCIATE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','IPL_R_ALIAS_REASON_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','IPL_R_ALIAS_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_PROVINCE_STATE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','IPL_R_SOURCE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_WATER_DATUM','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_WELL_CLASS','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_WELL_STATUS','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','STRAT_UNIT','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','PROD_STRING','C');

  -- The following MViews are local and merge the IPL mviews with
  -- local tables.
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','BUSINESS_ASSOCIATE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_REASON_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_ALIAS_TYPE','C');
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','R_SOURCE','C');

  --  The spatial MVIEW is a local mview and is dependent on several
  --  of the above mviews, so must be done last
  TLM_MVIEW_UTIL.FRESHEN_MVIEW('PPDM','WELL_SPATIAL_MVIEW1','C');

  -- Log the Refresh check is done
  tlm_process_logger.info ('MVIEW_COMPLETE_REFRESH: Complete');
 
END;

