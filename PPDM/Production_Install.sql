-- SCRIPT: Production_Install.sql
--
-- PURPOSE:
--   Installs the components for the the combined TLM and IHS Production approach.
--   The public data is provided through IHS in the C_TALISMAN schema.
--   TLM proprietary data is loaded into local TLM_* tables in the PPDM schema on PET*
--   The approach is to take the public data from IHS and merge it with the local TLM
--   data to provide a combined view of all available data.
--
--   This is implemented as:
--   1) Local tables TLM_* in PETP 
--   2) Views at IHS to map public data to wells
--   3) Views in PETP merge the TLM and IHS public data to offer a combined view
--       of all data
--
-- DEPENDENCIES
--   None
--
--
-- EXECUTION:
--   Can be executed from SQLPLUS or Toad
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   25-Jan-10 R. Masterman  Initial version
--   03-Feb-11 R. Masterman  Update to use MVIEWS as Views are too slow
--   24-Feb-11 R. Masterman  Add new indexes to speed up inventory
--   20-May-11 R. Masterman  Switch to a views on IHS server as MVIEWs failing too often
--

----------------------------------
--  Create as VIEWS  - TALISMAN37
----------------------------------

--  Create the views to represent the Public data. These are built as separate views
--  to allow them to be easily replaced by Mviews if performance becomes an issue.
--    The DB Link C_TALISMAN.IHS.INTERNAL.CORP points to the C_TALISMAN schema on IHSDATA hub.
--    The view converts the IHS UWI to a TLM_ID to provide a common key in the UWI column

CREATE OR REPLACE VIEW IHS_PDEN_VOL_BY_MONTH
AS
SELECT /*+ RULE */  wv.uwi AS "PDEN_ID", pvbm."PDEN_TYPE", pvbm."PDEN_SOURCE",
          pvbm."VOLUME_METHOD", pvbm."ACTIVITY_TYPE", pvbm."PRODUCT_TYPE",
          pvbm."YEAR", pvbm."AMENDMENT_SEQ_NO", pvbm."ACTIVE_IND",
          pvbm."AMEND_REASON", pvbm."APR_VOLUME", pvbm."APR_VOLUME_QUAL",
          pvbm."AUG_VOLUME", pvbm."AUG_VOLUME_QUAL", pvbm."CUM_VOLUME",
          pvbm."DEC_VOLUME", pvbm."DEC_VOLUME_QUAL", pvbm."EFFECTIVE_DATE",
          pvbm."EXPIRY_DATE", pvbm."FEB_VOLUME", pvbm."FEB_VOLUME_QUAL",
          pvbm."JAN_VOLUME", pvbm."JAN_VOLUME_QUAL", pvbm."JUL_VOLUME",
          pvbm."JUL_VOLUME_QUAL", pvbm."JUN_VOLUME", pvbm."JUN_VOLUME_QUAL",
          pvbm."MAR_VOLUME", pvbm."MAR_VOLUME_QUAL", pvbm."MAY_VOLUME",
          pvbm."MAY_VOLUME_QUAL", pvbm."NOV_VOLUME", pvbm."NOV_VOLUME_QUAL",
          pvbm."OCT_VOLUME", pvbm."OCT_VOLUME_QUAL", pvbm."POSTED_DATE",
          pvbm."PPDM_GUID", pvbm."REMARK", pvbm."SEP_VOLUME",
          pvbm."SEP_VOLUME_QUAL", pvbm."VOLUME_END_DATE", pvbm."VOLUME_OUOM",
          pvbm."VOLUME_QUALITY_OUOM", pvbm."VOLUME_START_DATE",
          pvbm."VOLUME_UOM", pvbm."YTD_VOLUME", pvbm."ROW_CHANGED_BY",
          pvbm."ROW_CHANGED_DATE", pvbm."ROW_CREATED_BY",
          pvbm."ROW_CREATED_DATE", pvbm."ROW_QUALITY", pvbm."PROVINCE_STATE",
          pvbm."POOL_ID", pvbm."X_STRAT_UNIT_ID", pvbm."TOP_STRAT_AGE",
          pvbm."BASE_STRAT_AGE", pvbm."STRAT_NAME_SET_ID"
  FROM PDEN_VOL_BY_MONTH@C_TALISMAN.IHS.INTERNAL.CORP PVBM, well_version wv
    WHERE wv.ipl_uwi_local = pvbm.pden_id
      AND pvbm.pden_type = 'PDEN_WELL'
      AND wv.SOURCE = '300IPL'
      AND wv.active_ind = 'Y';

--  In future we may need to include other, non well PDENs
--  Currently ALL IHS PDEn volumes are WELL based volumes
/*
UNION ALL
SELECT *
  FROM PDEN_VOL_BY_MONTH@IHSDATA.WORLD PVBM
    WHERE pvbm.pden_type != 'PDEN_WELL';
*/

--  Test the new views - compare the new view and the source table
--  May be a slight difference if we can't match some UWIs to a TLM_ID

select count(1) from IHS_PDEN_VOL_BY_MONTH; -- 20M rows, 12 mins
select * from IHS_PDEN_VOL_BY_MONTH;  -- <1s
select * from IHS_PDEN_VOL_BY_MONTH where PDEN_ID = '50256439000'; -- 27 rows < 1s
select * from IHS_PDEN_VOL_BY_MONTH where pden_id = '50256439000' or pden_id = '50000037865';
select * from IHS_PDEN_VOL_BY_MONTH where pden_id in ('50256439000','50000037865','50000000728','50000052751','50422106000','50422929000','50428261000','50435449000');

-- *************************
--  Create the local tables in PPDM @ PET*
-- *************************

-- Normally create new and remove old tables, but in this case simply rename the table
ALTER TABLE PDEN_VOL_BY_MONTH RENAME TO TLM_PDEN_VOL_BY_MONTH;

-- ***********************************************************
--  Clean up an old Strat objects
-- ***********************************************************

-- No old objects to clean up

-- ***********************************************************
--  Create the local views to combine the public and TLM data
-- ***********************************************************
create or replace view PDEN_VOL_BY_MONTH AS
   select 
          "PDEN_ID", "PDEN_TYPE", "PDEN_SOURCE", "VOLUME_METHOD",
          "ACTIVITY_TYPE", "PRODUCT_TYPE", "YEAR", "AMENDMENT_SEQ_NO",
          "ACTIVE_IND", "AMEND_REASON", "APR_VOLUME", "APR_VOLUME_QUAL",
          "AUG_VOLUME", "AUG_VOLUME_QUAL", "CUM_VOLUME", "DEC_VOLUME",
          "DEC_VOLUME_QUAL", "EFFECTIVE_DATE", "EXPIRY_DATE", "FEB_VOLUME",
          "FEB_VOLUME_QUAL", "JAN_VOLUME", "JAN_VOLUME_QUAL", "JUL_VOLUME",
          "JUL_VOLUME_QUAL", "JUN_VOLUME", "JUN_VOLUME_QUAL", "MAR_VOLUME",
          "MAR_VOLUME_QUAL", "MAY_VOLUME", "MAY_VOLUME_QUAL", "NOV_VOLUME",
          "NOV_VOLUME_QUAL", "OCT_VOLUME", "OCT_VOLUME_QUAL", "POSTED_DATE",
          "PPDM_GUID", "REMARK", "SEP_VOLUME", "SEP_VOLUME_QUAL",
          "VOLUME_END_DATE", "VOLUME_OUOM", "VOLUME_QUALITY_OUOM",
          "VOLUME_START_DATE", "VOLUME_UOM", "YTD_VOLUME", "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS Extensions
          NULL AS "PROVINCE_STATE",
          NULL AS "POOL_ID",
          NULL AS "X_STRAT_UNIT_ID",
          NULL AS "TOP_STRAT_AGE",
          NULL AS "BASE_STRAT_AGE",
          NULL AS "STRAT_NAME_SET_ID"
     from TLM_PDEN_VOL_BY_MONTH
union all
   select 
          "PDEN_ID", "PDEN_TYPE", "PDEN_SOURCE", "VOLUME_METHOD",
          "ACTIVITY_TYPE", "PRODUCT_TYPE", "YEAR", "AMENDMENT_SEQ_NO",
          "ACTIVE_IND", "AMEND_REASON", "APR_VOLUME", "APR_VOLUME_QUAL",
          "AUG_VOLUME", "AUG_VOLUME_QUAL", "CUM_VOLUME", "DEC_VOLUME",
          "DEC_VOLUME_QUAL", "EFFECTIVE_DATE", "EXPIRY_DATE", "FEB_VOLUME",
          "FEB_VOLUME_QUAL", "JAN_VOLUME", "JAN_VOLUME_QUAL", "JUL_VOLUME",
          "JUL_VOLUME_QUAL", "JUN_VOLUME", "JUN_VOLUME_QUAL", "MAR_VOLUME",
          "MAR_VOLUME_QUAL", "MAY_VOLUME", "MAY_VOLUME_QUAL", "NOV_VOLUME",
          "NOV_VOLUME_QUAL", "OCT_VOLUME", "OCT_VOLUME_QUAL", "POSTED_DATE",
          "PPDM_GUID", "REMARK", "SEP_VOLUME", "SEP_VOLUME_QUAL",
          "VOLUME_END_DATE", "VOLUME_OUOM", "VOLUME_QUALITY_OUOM",
          "VOLUME_START_DATE", "VOLUME_UOM", "YTD_VOLUME", "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS Extensions
          "PROVINCE_STATE",
          "POOL_ID",
          "X_STRAT_UNIT_ID",
          "TOP_STRAT_AGE",
          "BASE_STRAT_AGE",
          "STRAT_NAME_SET_ID"
  from TALISMAN37.IHS_PDEN_VOL_BY_MONTH@TLM37.WORLD;

-- *********************************
-- GRANT ACCESS to the new objects
-- *********************************

--  Grant Access to the other users - this list needs to be reviewed but they are the
--   current users with access to re-create for now

-- Read Access
GRANT SELECT ON PPDM.PDEN_VOL_BY_MONTH TO PPDM_BROWSE, PPDM_READ, PPDM_WRITE;

-- Write Access
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_STRAT_WELL_SECTION TO PPDM_WRITE;

-- ************************
-- TESTING - PPDM @ PET*
-- ************************

--  Test the new views - Note the COUNT queries still take a long time to run
--select count(1) from IHS_PDEN_VOL_BY_MONTH@TLM37.WORLD;
--select count(1) from TLM_PDEN_VOL_BY_MONTH;
--select count(1) from PDEN_VOL_BY_MONTH; -- should total sum of above
select * from TLM_PDEN_VOL_BY_MONTH;
select * from PDEN_VOL_BY_MONTH@ihsdata.world;
select * from PDEN_VOL_BY_MONTH;

--  test a sample - 
select * from TLM_PDEN_VOL_BY_MONTH  where PDEN_ID = '132612';   -- Local
select * from PDEN_VOL_BY_MONTH@ihsdata.world where pden_id = '100010102221W400';  -- Remote - 27 rows
select * from IHS_PDEN_VOL_BY_MONTH where pden_id = '50256439000';  -- View of remote - with converted UWI
select * from PDEN_VOL_BY_MONTH where pden_id = '50256439000'; -- Combined view

-- List of results
select * from PDEN_VOL_BY_MONTH where pden_id in ('50256439000');
select * from PDEN_VOL_BY_MONTH where pden_id in ('50256439000','50000000728');
select * from PDEN_VOL_BY_MONTH where pden_id in ('50256439000','50000037865','50000000728','50000052751','50422106000','50422929000','50428261000','50435449000');

----  Test typical DF type inventory list creation - 30+ minutes on PETT/PETD 
--select PDEN_ID, count(PDEN_ID)
--  from PDEN_VOL_BY_MONTH
-- group by PDEN_ID;
 
--  End of Script