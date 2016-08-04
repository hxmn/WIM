-- SCRIPT: CWS_Override_Compare_View_Install.sql
--
-- PURPOSE:
--   Creates the a View for listing the differences between the CWS wells and the WIM overrides
--   This will allow CWS to see the corrections and apply them to CWS data.  
--
--  Assumptions:
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Run as PPDM user on the PET* databases
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   4-Apr-11  R. Masterman  Initial version
--  25-May-11  R. Masterman  Extended comparison to check for for NULLs too
--  9-Jun-11   R. Masterman  Ignore US well name differences as CWS change the well names anyway

-- *****************
-- Run as PPDM User
-- *****************


--  ***  Notes:
--    PLOT_NAME  :  CWS doesn't store this so couldn't be added
--    KB_ELEV_OUOM  : CWS doesn't store this so couldn't be added
--    COORD SYSTEM TYPE  : CWS doesn't store this so couldn't be added

CREATE OR REPLACE VIEW CWS_Override_Compare_VW
 AS
  SELECT   wv.uwi, 'WELL_NAME' AS difference, cwcd.well_nm cws_value,
            wv.well_name wim_value
       FROM well_current_data@cws.world cwcd, well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND wv.country != '7US'
        AND cwcd.well_id = wv.uwi
        AND cwcd.well_nm != wv.well_name
   UNION ALL
   SELECT   wv.uwi, 'SURF_LAT' AS difference,
            TO_CHAR (cwn.well_node_latitude), TO_CHAR (wv.surface_latitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND cwcd.well_id = wv.uwi
        AND cwn.well_node_id = cwcd.surface_node_id
        AND wv.surface_latitude IS NOT NULL
        AND NVL(TO_CHAR(cwn.well_node_latitude),'NULL') != TO_CHAR(wv.surface_latitude)
   UNION ALL
   SELECT   wv.uwi, 'SURF_LON' AS difference,
            TO_CHAR (cwn.well_node_longitude), TO_CHAR (wv.surface_longitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND cwcd.well_id = wv.uwi
        AND cwn.well_node_id = cwcd.surface_node_id
        AND wv.surface_longitude IS NOT NULL
        AND NVL(TO_CHAR(cwn.well_node_longitude),'NULL') != TO_CHAR(wv.surface_longitude)
   UNION ALL
   SELECT   wv.uwi, 'BH_LAT' AS difference, TO_CHAR (cwn.well_node_latitude),
            TO_CHAR (wv.bottom_hole_latitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND cwcd.well_id = wv.uwi
        AND cwn.well_node_id = cwcd.base_node_id
        AND wv.bottom_hole_latitude IS NOT NULL
        AND NVL(TO_CHAR(cwn.well_node_latitude),'NULL') != TO_CHAR(wv.bottom_hole_latitude)
   UNION ALL
   SELECT   wv.uwi, 'BH_LON' AS difference, TO_CHAR (cwn.well_node_longitude),
            TO_CHAR (wv.bottom_hole_longitude)
       FROM well_current_data@cws.world cwcd,
            well_node@cws.world cwn,
            well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND cwcd.well_id = wv.uwi
        AND cwn.well_node_id = cwcd.base_node_id
        AND wv.bottom_hole_longitude IS NOT NULL
        AND NVL(TO_CHAR(cwn.well_node_longitude),'NULL') != TO_CHAR(wv.bottom_hole_longitude)
   UNION ALL
   SELECT   wv.uwi, 'KB_ELEV' AS difference, TO_CHAR (cw.kb_elev),
            TO_CHAR (wv.kb_elev)
       FROM well@cws.world cw,
            well_version wv
      WHERE wv.SOURCE = '075TLMO'
        AND cw.well_id = wv.uwi
        AND wv.kb_elev IS NOT NULL
        AND NVL(TO_CHAR(cw.kb_elev),'NULL') != TO_CHAR(wv.kb_elev)
   ;

--  Access rights
GRANT SELECT ON CWS_Override_Compare_VW to PPDM_READ, PPDM_BROWSE;

-- Test it in PPDM
select * from PPDM.CWS_Override_Compare_VW order by uwi, difference;

--  Also check to see who made the changes and when
select uwi, row_changed_date, row_changed_by, row_created_date, row_created_by
  from well_version
 where uwi in (select uwi from PPDM.CWS_Override_Compare_VW)
   and source = '075TLMO';

-- End of Script