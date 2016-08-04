/*
This backup is taking hours when we run it overnight and is not used, so skip these stpes for now and see if we avoid the other errors)

select count (*) from WELL_VERSION;
select count (*) from WELL_NODE_VERSION;

Drop table WELL_VERSION_BKUP;
Drop table WELL_NODE_VERSION_BKUP;

Create table WELL_VERSION_BKUP 
	nologging pctfree 0 storage(initial 1m pctincrease 0)
as select * from  well_version;

Create table WELL_NODE_VERSION_BKUP 
	nologging pctfree 0 storage(initial 1m pctincrease 0)
as select * from well_node_version;

select count (*) from WELL_VERSION_BKUP;
select count (*) from WELL_NODE_VERSION_BKUP;
*/


DELETE from WELL_VERSION where source like '100TLM';

INSERT into WELL_VERSION
(UWI, SOURCE, ACTIVE_IND, BASE_NODE_ID, BOTTOM_HOLE_LATITUDE, BOTTOM_HOLE_LONGITUDE, COUNTRY, DRILL_TD,
EFFECTIVE_DATE, KB_ELEV, PROVINCE_STATE, SPUD_DATE, RIG_RELEASE_DATE, SURFACE_LATITUDE, SURFACE_LONGITUDE,
SURFACE_NODE_ID, WELL_NAME, IPL_OFFSHORE_IND, IPL_UWI_DISPLAY, IPL_UWI_LOCAL, IPL_ONPROD_DATE)
SELECT UWI, SOURCE, ACTIVE_IND, BASE_NODE_ID, BOTTOM_HOLE_LATITUDE, BOTTOM_HOLE_LONGITUDE, COUNTRY, DRILL_TD,
EFFECTIVE_DATE, KB_ELEV, PROVINCE_STATE, SPUD_DATE, RIG_RELEASE_DATE, SURFACE_LATITUDE, SURFACE_LONGITUDE,
SURFACE_NODE_ID, WELL_NAME, IPL_OFFSHORE_IND, IPL_UWI_DISPLAY, IPL_UWI_LOCAL, IPL_ONPROD_DATE
FROM TEMP100_WELL_VERSION;

commit;

-- Check country code - Expect none
select * from WELL_VERSION where country = 'IQ';


DELETE from WELL_NODE_VERSION where source like '100TLM';

INSERT INTO WELL_NODE_VERSION
(COUNTRY, PROVINCE_STATE, NODE_ID, NODE_POSITION, LEGAL_SURVEY_TYPE, LATITUDE, LONGITUDE, NODE_OBS_NO,
ROW_CREATED_DATE, ROW_CREATED_BY,ROW_CHANGED_DATE,
ROW_CHANGED_BY, IPL_UWI, SOURCE, GEOG_COORD_SYSTEM_ID, LOCATION_QUALIFIER)
SELECT COUNTRY, PROVINCE_STATE, NODE_ID, NODE_POSITION, LEGAL_SURVEY_TYPE, LATITUDE, LONGITUDE,
NODE_OBS_NO, ROW_CREATED_DATE, ROW_CREATED_BY, 
ROW_CHANGED_DATE, ROW_CHANGED_BY, IPL_UWI, SOURCE, 
NVL(GEOG_COORD_SYSTEM_ID,'PPDM36_NULL'), NVL(LOCATION_QUALIFIER,'PPDM36_NULL')
FROM TEMP100_WELL_NODE_VERSION;

commit;

-- Check country code - Expect none
select * from WELL_NODE_VERSION where country = 'IQ';

/*  The houskeeping process now rolls up correctly in PPDM at TLM
    No longer need to run this refresh
exec GROUP_WELL_REFRESH('100TLM');
exec GROUP_NODE_REFRESH('100TLM');

Delete from well_node where source = '100TLM' and node_id not in
(select node_id from well_node_version where source = '100TLM');

Delete from well where primary_source = '100TLM' and UWI not in
(select uwi from well_version where source = '100TLM');

*/

-- 2008.05.08 djh replace following two statements with third following statement
--UPDATE WELL_NODE SET COORD_SYSTEM_ID = '4267'  where GEOG_COORD_SYSTEM_ID = 'NAD27' and PRIMARY_SOURCE like '100TLM';
--UPDATE WELL_NODE SET COORD_SYSTEM_ID = '4326'  where GEOG_COORD_SYSTEM_ID = 'WGS84' and PRIMARY_SOURCE like '100TLM';
UPDATE well_node
   SET coord_system_id =
           DECODE (geog_coord_system_id
                 , 'WGS84', '4326'   -- new international
                 , 'IHS83', '4326'   -- new ihs north american
                 , 'NAD27', '4267'   -- old north american
                 , 'IHS27', '4267'   -- old ihs north american
                 , NULL
                  )
 WHERE coord_system_id IS NULL
   AND geog_coord_system_id IN ('WGS84', 'IHS83', 'NAD27', 'IHS27')
   AND source = '100TLM';

commit;

-- Check country code - Expect none
select * from WELL_VERSION where country = 'IQ';
-- Check country code - Expect none
select * from WELL_NODE_VERSION where country = 'IQ';

