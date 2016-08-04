DROP PROCEDURE REFRESH_PROBE_MVIEWS;

CREATE OR REPLACE PROCEDURE            "REFRESH_PROBE_MVIEWS" (p_mviews_refreshed OUT Number)
is
/*-------------------------------------------------------------------------------
Proocedure: REFRESH_PROBE_MVIEWS
Purpose:    To refresh PROBE(IHS INT) MViews


History:

Feb 07, 2012  0.1  V.Rajpoot   Initial Creation
June 15 2013  0.2  V.Rajpoot  Changed to show 'WIM_LOADER_IHS_INT  in the process 				  		 log table.        

-------------------------------------------------------------------------------*/
 
begin 
tlm_process_logger.info ('WIM_LOADER_IHS_INT MViews Refresh - STARTED');
  p_mviews_refreshed := 1;
EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_VERSIONPRBSTG_MV';
dbms_mview.refresh( 'WELL_VERSIONPRBSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_NODE_VERSIONPRBSTG_MV';
dbms_mview.refresh('WELL_NODE_VERSIONPRBSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_LICENSEPrbSTG_MV';
dbms_mview.refresh('WELL_LICENSEPrbSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_STATUSPRBSTG_MV';
dbms_mview.refresh( 'WELL_STATUSPRBSTG_MV', 'C' );

 tlm_process_logger.info ('WIM_LOADER_IHS_INT MViews Refresh - COMPLETED');
 EXCEPTION
  WHEN OTHERS THEN
     tlm_process_logger.info ('WIM_LOADER_IHS_INT MViews Refresh - FAILED '|| sqlerrm);
     p_mviews_refreshed := 0;
       
end;

/
