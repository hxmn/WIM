-- SCRIPT: Strat_Install.sql
--
-- PURPOSE:
--   Installs the components for the the combined TLM and IHS Sratigraphy approach.
--   The public data is provided through IHS in the C_TALISMAN schema.
--   TLM proprietary data is loaded int9o local TLM_* tables in the PPDM schema on PETP.
--   The approach is to take the public data from IHS and merge it with the local TLM
--   data to provide a combined view of all available data.
--
--   This is implemented as:
--   1) Local table TLM_STRAT_WELL_SECTION in PETP - used to store the TLM local data
--   2) Views provide a local "translation" of the public data to simplify the
--      access tothe data in PETP and allow an option for replacement with materialized
--      views should performance be a problem. 
--   3) Views in PETP merge the TLM and public data to offer a combined view
--       of all data.
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
--   18-Apr-10 R. Masterman  Initial version
--   31-May-10 F. Baird  Modified to add view(STRAT_UNIT) built from added tables IHS_STRAT_UNIT & TLM_STRAT_UNIT 
--   25-Jan-11 R. Masterman  Updated to use RULE hint and restructured composites ready for PETT deployment  
--   10-Feb-11 R. Masterman  Added MVIEW options - but seems to be running OK for now, so leave this as views
--   19-Feb-11 R. Masterman  Fixed to use TALISMAN37 variant of the table link between STRAT and WELL_VERSION


--  Add an index to WELL_VERSION to support faster view - Initially ONLY applies in PETD where WELL_VERSION is a local table
--  NOTE: May already be created as part of the WELL_COMPLETION, WELL_STRAT or PRODUCTION Installs
--drop index PPDM.WV_AI_IDX;

CREATE INDEX PPDM.WV_AI_IDX ON PPDM.WELL_VERSION
(UWI, SOURCE, ACTIVE_IND, IPL_UWI_LOCAL)
NOLOGGING;

----------------------------------------------------------------------------------------------------
--  Create the View to get the Public data
--
--   ***** NOTE this a variation prototpye which installs the JOIN between STRAT and WELL_VERSION
--         over at IHS to improve performance and still be able to use a view
--         Only used on the SECTION table as the others don't need to link to the wells
---------------------------------------------------------------------------------------------------

--  INSTALL on TALISMAN7 @ IHSDATA 
CREATE OR REPLACE VIEW IHS_STRAT_WELL_SECTION  -- TALISMAN37 Version of the view
AS
   SELECT /*+ RULE */
          wv."UWI", sws."STRAT_NAME_SET_ID", sws."STRAT_UNIT_ID",
          sws."INTERP_ID", sws."ACTIVE_IND", sws."APPLICATION_NAME",
          sws."AREA_ID", sws."AREA_TYPE", sws."CERTIFIED_IND",
          sws."CONFORMITY_RELATIONSHIP", sws."DOMINANT_LITHOLOGY",
          sws."EFFECTIVE_DATE", sws."EXPIRY_DATE", sws."INTERPRETER",
          sws."ORDINAL_SEQ_NO", sws."OVERTURNED_IND", sws."PICK_DATE",
          sws."PICK_DEPTH", sws."PICK_DEPTH_OUOM", sws."PICK_LOCATION",
          sws."PICK_QUALIFIER", sws."PICK_QUALIF_REASON", sws."PICK_QUALITY",
          sws."PICK_TVD", sws."PICK_VERSION_TYPE", sws."PPDM_GUID",
          sws."PREFERRED_PICK_IND", sws."REMARK", sws."REPEAT_STRAT_OCCUR_NO",
          sws."REPEAT_STRAT_TYPE", sws."SOURCE", sws."SOURCE_DOCUMENT",
          sws."STRAT_INTERPRET_METHOD", sws."TVD_METHOD",
          sws."VERSION_OBS_NO", sws."X_BASE_STRAT_UNIT_ID",
          sws."X_BASE_DEPTH", sws."ROW_CHANGED_BY", sws."ROW_CHANGED_DATE",
          sws."ROW_CREATED_BY", sws."ROW_CREATED_DATE", sws."ROW_QUALITY",
          sws."PROVINCE_STATE", sws."X_STRAT_UNIT_ID_NUM"
     FROM c_talisman.strat_well_section@c_talisman.ihs.internal.corp sws,
          talisman37.well_version wv
    WHERE wv.ipl_uwi_local = sws.uwi
      AND wv.SOURCE = '300IPL'
      AND wv.active_ind = 'Y';

--  test it
SELECT * FROM IHS_STRAT_WELL_SECTION;

-- NOW SWITCH Back to PET* and create the other 2 views the standard way (They don't linke to well so are not slow)

--    The DB Link IHSDATA.WORLD points to the C_TALISMAN schema on IHSDATA hub.

-- STRAT_UNIT
CREATE OR REPLACE VIEW IHS_STRAT_UNIT
AS
SELECT *
  FROM STRAT_UNIT@IHSDATA.WORLD;

-- NAME SET
CREATE OR REPLACE VIEW IHS_STRAT_NAME_SET
AS
SELECT *
  FROM STRAT_NAME_SET@IHSDATA.WORLD;

------------------------------------------------------------------
--  MVIEW OPTION
--    use this is the view perfomance is poor.
------------------------------------------------------------------
/*

DROP VIEW PPDM.IHS_STRAT_WELL_SECTION;

CREATE MATERIALIZED VIEW PPDM.IHS_STRAT_WELL_SECTION
NOLOGGING
BUILD DEFERRED
USING INDEX
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS
   SELECT wv."UWI", sws."STRAT_NAME_SET_ID", sws."STRAT_UNIT_ID",
          sws."INTERP_ID", sws."ACTIVE_IND", sws."APPLICATION_NAME",
          sws."AREA_ID", sws."AREA_TYPE", sws."CERTIFIED_IND",
          sws."CONFORMITY_RELATIONSHIP", sws."DOMINANT_LITHOLOGY",
          sws."EFFECTIVE_DATE", sws."EXPIRY_DATE", sws."INTERPRETER",
          sws."ORDINAL_SEQ_NO", sws."OVERTURNED_IND", sws."PICK_DATE",
          sws."PICK_DEPTH", sws."PICK_DEPTH_OUOM", sws."PICK_LOCATION",
          sws."PICK_QUALIFIER", sws."PICK_QUALIF_REASON", sws."PICK_QUALITY",
          sws."PICK_TVD", sws."PICK_VERSION_TYPE", sws."PPDM_GUID",
          sws."PREFERRED_PICK_IND", sws."REMARK", sws."REPEAT_STRAT_OCCUR_NO",
          sws."REPEAT_STRAT_TYPE", sws."SOURCE", sws."SOURCE_DOCUMENT",
          sws."STRAT_INTERPRET_METHOD", sws."TVD_METHOD",
          sws."VERSION_OBS_NO", sws."X_BASE_STRAT_UNIT_ID",
          sws."X_BASE_DEPTH", sws."ROW_CHANGED_BY", sws."ROW_CHANGED_DATE",
          sws."ROW_CREATED_BY", sws."ROW_CREATED_DATE", sws."ROW_QUALITY",
          sws."PROVINCE_STATE", sws."X_STRAT_UNIT_ID_NUM"
  FROM STRAT_WELL_SECTION@IHSDATA.WORLD SWS, ppdm.well_version wv
    WHERE wv.ipl_uwi_local = sws.uwi
      AND wv.SOURCE = '300IPL'
      AND wv.active_ind = 'Y';


-- STRAT_UNIT
DROP VIEW PPDM.IHS_STRAT_UNIT;

CREATE MATERIALIZED VIEW PPDM.IHS_STRAT_UNIT
NOLOGGING
BUILD DEFERRED
USING INDEX
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS
SELECT *
  FROM STRAT_UNIT@IHSDATA.WORLD;


DROP VIEW PPDM.IHS_STRAT_NAME_SET;

CREATE MATERIALIZED VIEW PPDM.IHS_STRAT_NAME_SET
NOLOGGING
BUILD DEFERRED
USING INDEX
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS

SELECT *
  FROM STRAT_NAME_SET@IHSDATA.WORLD;
*/

--  Test the new views - compare the new view and the source table
--  May be a slight difference if we can't match some UWIs to a TLM_ID
select * from TALISMAN37.IHS_STRAT_WELL_SECTION@TLM37.WORLD where uwi = '124224';
select * from IHS_STRAT_UNIT;
select * from IHS_STRAT_NAME_SET;


-- *************************
--  Create the local tables
-- *************************

-- Normally create new and remove old tables, but in this case simply rename the table
ALTER TABLE STRAT_WELL_SECTION RENAME TO TLM_STRAT_WELL_SECTION;
ALTER TABLE STRAT_NAME_SET RENAME TO TLM_STRAT_NAME_SET;

--  BUT  Strat UNIT didn't exist? So need to create it:
CREATE TABLE PPDM.TLM_STRAT_UNIT
(
  STRAT_NAME_SET_ID       VARCHAR2(20 BYTE)     NOT NULL,
  STRAT_UNIT_ID           VARCHAR2(20 BYTE)     NOT NULL,
  ABBREVIATION            VARCHAR2(12 BYTE),
  ACTIVE_IND              VARCHAR2(1 BYTE),
  AREA_ID                 VARCHAR2(20 BYTE),
  AREA_TYPE               VARCHAR2(20 BYTE),
  BUSINESS_ASSOCIATE      VARCHAR2(20 BYTE),
  CONFIDENCE_ID           VARCHAR2(20 BYTE),
  CURRENT_STATUS_DATE     DATE,
  DESCRIPTION             VARCHAR2(240 BYTE),
  EFFECTIVE_DATE          DATE,
  EXPIRY_DATE             DATE,
  FAULT_TYPE              VARCHAR2(20 BYTE),
  FORM_CODE               VARCHAR2(20 BYTE),
  GROUP_CODE              VARCHAR2(20 BYTE),
  LONG_NAME               VARCHAR2(60 BYTE),
  ORDINAL_AGE_CODE        NUMBER(15,5),
  PPDM_GUID               VARCHAR2(38 BYTE),
  PREFERRED_IND           VARCHAR2(1 BYTE),
  REMARK                  VARCHAR2(2000 BYTE),
  SHORT_NAME              VARCHAR2(30 BYTE),
  SOURCE                  VARCHAR2(20 BYTE),
  STRAT_INTERPRET_METHOD  VARCHAR2(20 BYTE),
  STRAT_STATUS            VARCHAR2(20 BYTE),
  STRAT_TYPE              VARCHAR2(20 BYTE),
  STRAT_UNIT_TYPE         VARCHAR2(20 BYTE),
  ROW_CHANGED_BY          VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE        DATE,
  ROW_CREATED_BY          VARCHAR2(30 BYTE),
  ROW_CREATED_DATE        DATE,
  ROW_QUALITY             VARCHAR2(20 BYTE)
)
NOLOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
NOMONITORING;

CREATE UNIQUE INDEX PPDM.TSTU_PK ON PPDM.TLM_STRAT_UNIT
(STRAT_NAME_SET_ID, STRAT_UNIT_ID)
NOLOGGING;

CREATE INDEX PPDM.TSTU_R_S_IDX ON PPDM.TLM_STRAT_UNIT
(SOURCE)
NOLOGGING;

ALTER TABLE PPDM.TLM_STRAT_UNIT ADD (
  CONSTRAINT TSTU_PK
 PRIMARY KEY
(STRAT_NAME_SET_ID, STRAT_UNIT_ID)
    USING INDEX);

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_STRAT_UNIT TO GEOWIZ_SURVEY;
GRANT SELECT ON PPDM.TLM_STRAT_UNIT TO PPDM_BROWSE;

-- ***********************************************************
--  Clean up an old Strat objects
-- ***********************************************************

-- No old objects to clean up


-- ***********************************************************
--  Create the local views to combine the public and TLM data
-- ***********************************************************

create or replace view STRAT_WELL_SECTION AS
   select /*+ RULE */ 
          "UWI", "STRAT_NAME_SET_ID", "STRAT_UNIT_ID", "INTERP_ID",
          "ACTIVE_IND", "APPLICATION_NAME", "AREA_ID", "AREA_TYPE",
          "CERTIFIED_IND", "CONFORMITY_RELATIONSHIP", "DOMINANT_LITHOLOGY",
          "EFFECTIVE_DATE", "EXPIRY_DATE", "INTERPRETER", "ORDINAL_SEQ_NO",
          "OVERTURNED_IND", "PICK_DATE", "PICK_DEPTH", "PICK_DEPTH_OUOM",
          "PICK_LOCATION", "PICK_QUALIFIER", "PICK_QUALIF_REASON",
          "PICK_QUALITY", "PICK_TVD", "PICK_VERSION_TYPE", "PPDM_GUID",
          "PREFERRED_PICK_IND", "REMARK", "REPEAT_STRAT_OCCUR_NO",
          "REPEAT_STRAT_TYPE", "SOURCE", "SOURCE_DOCUMENT",
          "STRAT_INTERPRET_METHOD", "TVD_METHOD", "VERSION_OBS_NO",
          "ROW_CHANGED_BY", "ROW_CHANGED_DATE", "ROW_CREATED_BY",
          "ROW_CREATED_DATE", "ROW_QUALITY",
          --  IHS Extensions
          NULL AS "PROVINCE_STATE",
          NULL AS "X_STRAT_UNIT_ID_NUM",
          NULL AS "X_BASE_STRAT_UNIT_ID",
          NULL AS "X_BASE_DEPTH"
     from TLM_STRAT_Well_Section
union all
   select /*+ RULE */ 
          "UWI", "STRAT_NAME_SET_ID", "STRAT_UNIT_ID", "INTERP_ID",
          "ACTIVE_IND", "APPLICATION_NAME", "AREA_ID", "AREA_TYPE",
          "CERTIFIED_IND", "CONFORMITY_RELATIONSHIP", "DOMINANT_LITHOLOGY",
          "EFFECTIVE_DATE", "EXPIRY_DATE", "INTERPRETER", "ORDINAL_SEQ_NO",
          "OVERTURNED_IND", "PICK_DATE", "PICK_DEPTH", "PICK_DEPTH_OUOM",
          "PICK_LOCATION", "PICK_QUALIFIER", "PICK_QUALIF_REASON",
          "PICK_QUALITY", "PICK_TVD", "PICK_VERSION_TYPE", "PPDM_GUID",
          "PREFERRED_PICK_IND", "REMARK", "REPEAT_STRAT_OCCUR_NO",
          "REPEAT_STRAT_TYPE", "SOURCE", "SOURCE_DOCUMENT",
          "STRAT_INTERPRET_METHOD", "TVD_METHOD", "VERSION_OBS_NO",
           "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE",
          "ROW_QUALITY",
          --  IHS Extensions
          "PROVINCE_STATE",
          "X_STRAT_UNIT_ID_NUM",
          "X_BASE_STRAT_UNIT_ID",
          "X_BASE_DEPTH"
  from TALISMAN37.IHS_STRAT_WELL_SECTION@TLM37.WORLD;


CREATE OR REPLACE VIEW STRAT_UNIT AS
   SELECT  "STRAT_NAME_SET_ID", "STRAT_UNIT_ID", "ABBREVIATION", "ACTIVE_IND",
          "AREA_ID", "AREA_TYPE", "BUSINESS_ASSOCIATE", "CONFIDENCE_ID",
          "CURRENT_STATUS_DATE", "DESCRIPTION", "EFFECTIVE_DATE",
          "EXPIRY_DATE", "FAULT_TYPE", "FORM_CODE", "GROUP_CODE", "LONG_NAME",
          "ORDINAL_AGE_CODE", "PPDM_GUID", "PREFERRED_IND", "REMARK",
          "SHORT_NAME", "SOURCE", "STRAT_INTERPRET_METHOD", "STRAT_STATUS",
          "STRAT_TYPE", "STRAT_UNIT_TYPE", "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE",
          "ROW_QUALITY",
          --  IHS Extensions
          NULL AS "X_STRAT_UNIT_ID_NUM",
          NULL AS "BASE_STRAT_AGE",
          NULL AS "X_LITHOLOGY",
          NULL AS "X_RESOURCE"
     FROM tlm_strat_unit
UNION ALL
   SELECT "STRAT_NAME_SET_ID", "STRAT_UNIT_ID", "ABBREVIATION", "ACTIVE_IND",
          "AREA_ID", "AREA_TYPE", "BUSINESS_ASSOCIATE", "CONFIDENCE_ID",
          "CURRENT_STATUS_DATE", "DESCRIPTION", "EFFECTIVE_DATE",
          "EXPIRY_DATE", "FAULT_TYPE", "FORM_CODE", "GROUP_CODE", "LONG_NAME",
          "ORDINAL_AGE_CODE", "PPDM_GUID", "PREFERRED_IND", "REMARK",
          "SHORT_NAME", "SOURCE", "STRAT_INTERPRET_METHOD", "STRAT_STATUS",
          "STRAT_TYPE", "STRAT_UNIT_TYPE", "ROW_CHANGED_BY", "ROW_CHANGED_DATE",
          "ROW_CREATED_BY", "ROW_CREATED_DATE", "ROW_QUALITY",
          --  IHS Extensions
          "X_STRAT_UNIT_ID_NUM",
          "BASE_STRAT_AGE",
          "X_LITHOLOGY",
          "X_RESOURCE"
     FROM ihs_strat_unit;

--  Tables the same so no need to list attributes     
CREATE OR REPLACE VIEW STRAT_NAME_SET AS
   SELECT *
     FROM TLM_STRAT_NAME_SET
UNION ALL
   SELECT * 
     FROM IHS_STRAT_NAME_SET;


-- *********************************
-- GRANT ACCESS to the new objects
-- *********************************

--  Grant Access to the other users - this list needs to be reviewed but they are the
--   current users with access to re-create for now

-- Read Access
GRANT SELECT ON PPDM.STRAT_WELL_SECTION TO PPDM_BROWSE, PPDM_READ, PPDM_WRITE, GEOWIZ, GEOWIZ_SURVEY;
GRANT SELECT ON PPDM.STRAT_UNIT         TO PPDM_BROWSE, PPDM_READ, PPDM_WRITE, GEOWIZ, GEOWIZ_SURVEY;
GRANT SELECT ON PPDM.STRAT_NAME_SET     TO PPDM_BROWSE, PPDM_READ, PPDM_WRITE, GEOWIZ, GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.TLM_STRAT_WELL_SECTION TO GEOWIZ_SURVEY;
GRANT SELECT ON PPDM.TLM_STRAT_UNIT         TO GEOWIZ_SURVEY;
GRANT SELECT ON PPDM.TLM_STRAT_NAME_SET     TO GEOWIZ_SURVEY;

-- Write Access
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_STRAT_WELL_SECTION TO GEOWIZ_SURVEY;
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_STRAT_UNIT         TO GEOWIZ_SURVEY;
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_STRAT_NAME_SET     TO GEOWIZ_SURVEY;

-- ************************
-- TESTING
-- ************************

--  Test the new views - some of these take a long time to run
select count(1) from TALISMAN37.IHS_STRAT_WELL_SECTION@TLM37.WORLD;
select count(1) from TLM_STRAT_WELL_SECTION;
select count(1) from STRAT_WELL_SECTION; -- should total sum of above
select * from TLM_STRAT_WELL_SECTION;
select * from STRAT_WELL_SECTION;
select * from STRAT_WELL_SECTION@ihsdata.world;

--  test a sample - TLMID 132612 = UWI 100050305219W500
select * from TLM_STRAT_WELL_SECTION  where uwi = '1001516534';   -- Local
select * from STRAT_WELL_SECTION@ihsdata.world where uwi = '100050305219W500';  -- Remote
select * from STRAT_WELL_SECTION@ihsdata.world where uwi = '100010608606W400';  -- Remote
select * from IHS_STRAT_WELL_SECTION where uwi = '50000037865';  -- View of remote - with converted UWI
select * from STRAT_WELL_SECTION where uwi = '50000037865'; -- Combined view
select * from STRAT_WELL_SECTION@tlm37.world where uwi = '50000037865';   -- Old dataset

-- List of results
select * from STRAT_WELL_SECTION where uwi in ('50000037865');
select * from STRAT_WELL_SECTION where uwi in ('50000037865','50000000728');
select * from STRAT_WELL_SECTION where uwi in ('1001516534','50000037865','50000000728','50000052751','50422106000','50422929000','50428261000','50435449000');

-- STRAT UNIT  - Small volumes - fast results
select count(1) from IHS_STRAT_UNIT;
select count(1) from TLM_STRAT_UNIT;
select count(1) from STRAT_UNIT; -- should total sum of above
select * from STRAT_UNIT;
select * from STRAT_UNIT@ihsdata.world;

-- STRAT NAME SET  - Small volumes - fast results
select count(1) from IHS_STRAT_NAME_SET;
select count(1) from TLM_STRAT_NAME_SET;
select count(1) from STRAT_NAME_SET; -- should total sum of above
select * from STRAT_NAME_SET;
select * from STRAT_NAME_SET@ihsdata.world;


--  Test typical DF type inventory list creation - 5-6 minutes on PETT/PETD
select uwi, count(1)
  from STRAT_WELL_SECTION
 group by uwi;

--  End of Script