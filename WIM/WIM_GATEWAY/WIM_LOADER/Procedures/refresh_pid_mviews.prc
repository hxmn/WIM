DROP PROCEDURE REFRESH_PID_MVIEWS;

CREATE OR REPLACE PROCEDURE            "REFRESH_PID_MVIEWS" (p_mviews_refreshed OUT Number)
is
begin
/*-------------------------------------------------------------------------------
Proocedure: REFRESH_PID_MVIEWS
Purpose:    To refresh PID (IHS US) MViews


History:

Feb 07, 2012  0.1  V.Rajpoot   Initial Creation
June 15 2013  0.2  V.Rajpoot  Changed to show 'WIM_LOADER_IHS_US  in the process 				  		 log table.        

-------------------------------------------------------------------------------*/

 
    tlm_process_logger.info ('WIM_LOADER_IHS_US MViews Refresh - STARTED');
    p_mviews_refreshed := 1;

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_PIDSTG_MV';
dbms_mview.refresh( 'WELL_PIDSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_NODE_VERSIONPIDSTG_MV';
dbms_mview.refresh('WELL_NODE_VERSIONPIDSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_LICENSEPIDSTG_MV';
dbms_mview.refresh('WELL_LICENSEPIDSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_STATUSPIDSTG_MV';
dbms_mview.refresh( 'WELL_STATUSPIDSTG_MV', 'C' );

tlm_process_logger.info ('WIM_LOADER_IHS_US MViews Refresh - COMPLETED');
 
 EXCEPTION
  WHEN OTHERS THEN
     tlm_process_logger.info ('WIM_LOADER_IHS_US MViews Refresh - FAILED '|| sqlerrm);
     p_mviews_refreshed := 0;
        

end;

/
