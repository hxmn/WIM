/*******************************************************************************************
   WELL_LOG_VIEW  (View)

 *******************************************************************************************/

--drop view PPDM.WELL_LOG_VIEW;

 
create or replace force view PPDM.WELL_LOG_VIEW (UWI)
AS
   SELECT DISTINCT uwi
     FROM well_log
;


GRANT SELECT ON PPDM.WELL_LOG_VIEW TO PPDM_RO;


--CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_LOG_VIEW FOR PPDM.WELL_LOG_VIEW;
