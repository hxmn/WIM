DROP PROCEDURE REFRESH_IPL_MVIEWS;

CREATE OR REPLACE PROCEDURE            REFRESH_IPL_MVIEWS (p_mviews_refreshed OUT Number)
is
begin 
   -- tlm_process_logger.info ('WIM_LOADER_IHS_CDN MViews Refresh - STARTED');
    p_mviews_refreshed := 1;
    
EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_IPLSTG_MV';
dbms_mview.refresh( 'WELL_IPLSTG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_NODE_VERSIONIPL_STG_MV';
 dbms_mview.refresh('WELL_NODE_VERSIONIPL_STG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_LICENSEIPL_STG_MV';
dbms_mview.refresh('WELL_LICENSEIPL_STG_MV', 'C' );

EXECUTE IMMEDIATE 'TRUNCATE TABLE WELL_STATUSIPL_STG_MV';
dbms_mview.refresh( 'WELL_STATUSIPL_STG_MV', 'C' );

-- tlm_process_logger.info ('WIM_LOADER_IHS_CDN MViews Refresh - COMPLETED');
 
 EXCEPTION
  WHEN OTHERS THEN
    -- tlm_process_logger.info ('WIM_LOADER_IHS_CDN MViews Refresh - FAILED '|| sqlerrm);
     p_mviews_refreshed := 0;
       
end;

/
