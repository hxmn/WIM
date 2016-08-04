---Insert into PRODUTION ALIAS Records for 300IPL Ammended / Inventory (DELETED / OBSOLETE) Wells 
---Created:  Oct 26, 2009
---Author:  F. Baird
---Reviewer:
---Run Date:
---**********---**********---**********---**********---**********---***********
--
---Nov 6, 2009
---Divide process into two types - Amended and Deleted
---****OBSOLETE WELLS******
--OBSOLETE (maybe either Amended or Deleted) WELLS

----Check Inventories
---Run in PETP as PPDM
--Check total of orphaned inventory wells to track if this is increasing and 
----Inventory for these deleted wells
---Total number check

select WI.*
  from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
 where wi.uwi in (select well_alias
          from TEMP_WA_300IPL_DELETED@TLM37.world
         where alias_type in ('UWI_PRIOR','UWI')
         and TEMP_WA_300IPL_DELETED.rundate > to_date ('3-APR-2010', 'DD-MON-YYYY') );
--- 7 wells have inventory from Nov 5 load only 4 are IPL versions only (50000160717,50000181968,50434441000,50434566000)
---****ISSUE IS TO GET TALISMAN37 to see DATA_ACCESS_COAT_CHECK.WELL_INVENTORY since only PETP can

--- Update INVENTORY with Y for these wells - this doesn't work since TALISMAN37 cannot see 
---DATA_ACCESS_COAT_CHECK.WELL_INVENTORY since only PETP can
--- use an in statement instead...
--- 50480072000 only well with inventory from Dec 19/09 load

update TALISMAN37.TEMP_WV_300IPL_DELETED
   set inventory = 'Y'
   where (;
select WI.uwi
  from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
 where wi.uwi in (select well_alias
          from TEMP_WA_300IPL_DELETED@TLM37.world
         where TEMP_WA_300IPL_DELETED.rundate > to_date ('25-FEB-2010', 'DD-MON-YYYY')
         and alias_type in ('UWI_PRIOR','UWI'));
  
---use UWI from above in statement as below 
select * from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY  
where 
uwi in ('138061','139515','139784','141020','141268','141270','141480','141661','141667','141730','142897','50000148067');

select uwi, inventory from TALISMAN37.TEMP_WV_300IPL_DELETED 
where 
uwi in 
('50000160717','50000164210','50000189414','50000263982','50281524000','50434441000');

select uwi, inventory from TALISMAN37.TEMP_WV_300IPL_DELETED 
where 
uwi in ('140617','142149','50000012111');

---UWIs from Feb 20th load ('50000259004','50000259005','50000259006','50000259007')
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi in ('50000259004','50000259005','50000259006','50000259007');

--UWIs from Feb 13 load('50000034017','50000255673','50000260964','50000263714','50000265949','50000267189','50000267972','50000272361')
select * from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY
where 
uwi in ('50000034017','50000255673','50000260964','50000263714','50000265949','50000267189','50000267972');

update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi in ('50000034017','50000255673','50000260964','50000263714','50000265949','50000267189',
'50000267972','50000272361');

--- Mar 6, 2010 load 0 wells 
--- Feb 6th load has no wells
---Jan 30th load has no wells
---Jan 23 load has 12 wells with inventory only 1 is 300IPL('50000148067') - rest are CWS
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi = '50000148067';
--Jan 14 load has 3 wells with inventory two are CWS and only one is 300IPL '50000012111'
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi ='50000012111';
---Dec 19/09--- 50480072000 only well with inventory from Dec 19/09 load
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi ='50480072000';
---Dec 11/09 Load 1 Well '50000166475'
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi ='50000166475';
---Dec 3/09 1 well 50000191171
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi ='50000191171';
--- None from Nov 28/29 load
---Nov 25, 2009
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi ='50000189414';
---Nov 17th 2009   ---only one new well since Nov 17th - '50000189414'
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi in (
'50000164210','50000263982','50000268717','50281524000');
---Nov 10th 2009   
update TALISMAN37.TEMP_WV_300IPL_DELETED
set inventory = 'Y'
where uwi in ('50000160717','50000181968','50434441000','50434566000');

commit;

---Assess total numbers of wells
select count(1) uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('24-JAN-2010', 'DD-MON-YYYY')
and twv.uwi like '5%';

---33 IPL wells from Nov 6 load
---36 total wells (3 TLM sourced wells) Nov 10th
---17 new wells Nov 17 2009 (53 total in table)

---Assess how many are AMENDED vs DELETED  set REASON to either A or D

---Amended
select count(1) uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv, well_version wv
where twv.rundate > to_date ('15-SEP-2010', 'DD-MON-YYYY')
and wv.well_num=twv.well_num
and twv.uwi like '5%';

select * from TALISMAN37.TEMP_WV_300IPL_DELETED
where rundate > to_date ('09-JUN-2010', 'DD-MON-YYYY')
and uwi like '5%';

---Update REASON TO A in TEMP_WV_300IPL_DELETED
update TALISMAN37.TEMP_WV_300IPL_DELETED twv
set reason = 'A'
where twv.uwi in (
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv, well_version wv
where twv.rundate > to_date ('15-SEP-2010', 'DD-MON-YYYY')
and wv.well_num=twv.well_num
and twv.uwi like '5%');

-- select count(1) from TALISMAN37.TEMP_WV_300IPL_DELETED
-- where rundate > to_date ('16-MAR-2010', 'DD-MON-YYYY');
--25 rows updated Nov 9/09
---13 rows updated Nov 17/09
---19 rows updated Nov 26/09
--- 8 wells updated Nov 30/09
--- 4 rows updated Dec 7/09
----19 rows upded from Dec 11/09 update on Dec 17/09
---- 15 rows updated from Dec 19th load
---15 rows updated Jan 14 Load
--26 rows updated from Jan 23 load
--16 rows updated from Jan  30th load
-- 12 rows updated from Feb 6th load
--16 rows updated from Feb 13 load
--12 rows updated from February 26 load
---11 rows updated from Mar 6 load
-- 96 wells from March 20 load

select uwi, well_num, well_name, reason from TEMP_WV_300IPL_DELETED where reason='A';
select count(*) from TEMP_WV_300IPL_DELETED where reason='A';
---***
---Identify Deleted Wells
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('16-SEP-2010', 'DD-MON-YYYY') and twv.uwi like '5%'
minus (
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv, well_version wv
where twv.rundate > to_date ('16-SEP-2010', 'DD-MON-YYYY')
and wv.well_num=twv.well_num
and twv.uwi like '5%');

select * from TEMP_WV_300IPL_DELETED where uwi='50000266090';
select * from well_license where uwi='50000266090';
select * from well_version where ipl_uwi_local='100091105702W402';
select * from well_version where country='7CN' and well_num='A3909932';
select * from well_license where license_num='0390993';
select * from well_version where country='7CN' and uwi in ('50000214344','50000266090');

---8 wells are deleted Nov 9/09
---4 wells Nov 17/09
---0 wells Nov 26/09
--- 2 wells Nov 30/09
---0 wells Dec 7/09
--- 15 rows updated from Dec 19 load
--509 rows updated from Jan 22 load
--0 from Jan 30th load
--0 from Feb 6th load
--4 wells Feb 13 load (50000034017,50000255673,50000267972,50000272361)
-- 1 well - 50000278016 from Feb 26 loa--0 wells from Mar 6 load
-- 1428 wells from March 20 load


---Update REASON to D in TEMP_WV_300IPL_DELETED
update TALISMAN37.TEMP_WV_300IPL_DELETED twv
set reason = 'D'
where twv.uwi in (
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY') and twv.uwi like '5%'
minus (
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv, well_version wv
where twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and wv.well_num=twv.well_num
and twv.uwi like '5%'));

select count(*) from TEMP_WV_300IPL_DELETED where reason='D';

select * from TALISMAN37.TEMP_WV_300IPL_DELETED 
where source= '300IPL' and rundate > to_date ('21-JAN-2010', 'DD-MON-YYYY') and reason like '%Z%'; 

--**-- 450 wells are to all set to deleted
/*update TALISMAN37.TEMP_WV_300IPL_DELETED twv
set reason = 'D'
where twv.uwi in (
select twv.uwi from TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('14-JAN-2010', 'DD-MON-YYYY') and source='450PID');*/

select count(*) from TEMP_WV_300IPL_DELETED where reason='D';

---Check Inventories
---***Run in PETP as PPDM
---Update INVENTORY in to Y TEMP_WV_300IPL_DELETED where inventory exists
select WI.*
  from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
 where wi.uwi in (select well_alias
          from TEMP_WA_300IPL_DELETED@TLM37.world
         where alias_type in ('UWI_PRIOR','UWI'));
--- 7 wells have inventory from Nov 5 load only 4 are IPL versions only (50000160717,50000181968,50434441000,50434566000)
---****ISSUE IS TO GET TALISMAN37 to see DATA_ACCESS_COAT_CHECK.WELL_INVENTORY since only PETP can


---******---AMENDED WELLS PROCESS
---*****---
---Amended Wells 
---Identify these wells by matching on well_num and restrict to only IPL well version
---Insert REASON as A for amended
---Insert UWI_PRIOR
---Insert UWI_LOCAL (this value should change if a license amended was applied and received)
---Insert WELL_NAME (his value should change if a license amended was applied and received)
---*****----
---Insert UWI_PRIOR Well_Alias Type into Well_Alias table (AMENDED)
insert into WELL_ALIAS WA 
(uwi, source, well_alias_id, alias_type, active_ind, effective_date, reason_type, 
well_alias, row_created_by, row_created_date)
select wv.uwi, wv.source, 'TLM' as well_alias_id, 'UWI_PRIOR' as ALIAS_TYPE, 
'Y' as active_ind, twv.rundate as effective_date, 'A' as reason_type, twv.uwi as well_alias,
'FBAIRD' as ROW_CREATED_BY, twv.rundate as ROW_CREATED_DATE
from well_version wv, TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and twv.reason='A'
and wv.well_num=twv.well_num;

commit;
--13 rows inserted Nov 17/09
---19 rows Nov 26/09
--- 8 rows inserted Nov 30/09
---4 rows inserted Dec 7/09
---19 rows updated on Dec 17 from the Dec 11 load
--- 15 rows inserted Dec 22 for Dec 19 load
--15 rows from Jan 14 load
-- 26 rows from Jan 23 load
--16 rows inserted from Jan 30th load
--12 rows Feb 6th load
--16 rows Feb 13 load
---32 rows inserted from Feb 20 load
--12 rows from Feb 26 load
--11 rows from Mar 6 load
-- 96 rows March 20 load

---Insert UWI_LOCAL Well_Alias Type into Well_Alias table (AMENDED)
---Check to see if this value is identical - if so do not insert
insert into WELL_ALIAS WA 
(uwi, source, well_alias_id, alias_type, active_ind, effective_date, reason_type, 
well_alias, row_created_by, row_created_date)
select wv.uwi, wv.source, 'TLM' as well_alias_id, 'UWI_LOCAL' as ALIAS_TYPE, 
'Y' as active_ind, twv.rundate as effective_date, 'A' as reason_type, twv.ipl_uwi_local as well_alias,
'FBAIRD' as ROW_CREATED_BY, sysdate as ROW_CREATED_DATE
from well_version wv, TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and 
wv.well_num=twv.well_num
and wv.ipl_uwi_local!=twv.ipl_uwi_local
and twv.uwi like '5%';

commit;

---Insert WELL_NAME Well_Alias Type into Well_Alias table (AMENDED)
---Check to see if this value is identical - if so do not insert
insert into WELL_ALIAS WA 
(uwi, source, well_alias_id, alias_type, active_ind, effective_date, reason_type, 
well_alias, row_created_by, row_created_date)
select wv.uwi, wv.source, 'TLM' as well_alias_id, 'WELL_NAME' as ALIAS_TYPE, 
'Y' as active_ind, twv.rundate as effective_date, 'A' as reason_type, twv.well_name as well_alias,
'FBAIRD' as ROW_CREATED_BY, sysdate as ROW_CREATED_DATE
from well_version wv, TALISMAN37.TEMP_WV_300IPL_DELETED twv
where twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and 
wv.well_num=twv.well_num
and 
wv.well_name!=twv.well_name
and twv.uwi like '5%';

commit;
---3 rows Nov 17/09
---2 rows Nov 26/09
---5 rows insert Nov 30/09
--- 2 rows inserted Dec 7/09
---9 rows inserted Dec 17 for the Dec 11 load
--- 7 rows from Dec 19 load
--5 rows from Jan 14 load
--2 rows from Jan. 23 load
--9 rows inserted from Jan 30 load
--5 rows inserted from Feb 6th load
--9 rows from Feb 13 load
---4 rows from Feb 20 load
--9 rows from Feb 26 load
-- 3 rows from Mar 6 load
-- 56 rows mar 20

---*****DELETED WELLS PROCESS
---*****---
---Deleted Wells 
---Identify these wells by minus amended from total in select while restricting to only IPL well version
---Create 700TLME version for these wells 
---Create alias records with following
-------Insert REASON as D for DELETED
-------Insert only UWI_PRIOR as an alias
---*****----

---Create 700TLME Versions using old UWI

----Well_Version Table
insert into WELL_VERSION
select 
UWI,'700TLME' as SOURCE,ABANDONMENT_DATE,ACTIVE_IND,ASSIGNED_FIELD,BASE_NODE_ID,BOTTOM_HOLE_LATITUDE,
BOTTOM_HOLE_LONGITUDE,CASING_FLANGE_ELEV,CASING_FLANGE_ELEV_OUOM,COMPLETION_DATE,
CONFIDENTIAL_DATE,CONFIDENTIAL_DEPTH,CONFIDENTIAL_DEPTH_OUOM,CONFIDENTIAL_TYPE,CONFID_STRAT_NAME_SET_ID,CONFID_STRAT_UNIT_ID,
COUNTRY,COUNTY,CURRENT_CLASS,CURRENT_STATUS,CURRENT_STATUS_DATE,DEEPEST_DEPTH,DEEPEST_DEPTH_OUOM,DEPTH_DATUM,DEPTH_DATUM_ELEV,
DEPTH_DATUM_ELEV_OUOM,DERRICK_FLOOR_ELEV,DERRICK_FLOOR_ELEV_OUOM,DIFFERENCE_LAT_MSL,DISCOVERY_IND,DISTRICT,DRILL_TD,
DRILL_TD_OUOM,EFFECTIVE_DATE,ELEV_REF_DATUM,EXPIRY_DATE,FAULTED_IND,FINAL_DRILL_DATE,FINAL_TD,FINAL_TD_OUOM,GEOGRAPHIC_REGION,
GEOLOGIC_PROVINCE,GROUND_ELEV,GROUND_ELEV_OUOM,GROUND_ELEV_TYPE,INITIAL_CLASS,KB_ELEV,KB_ELEV_OUOM,LEASE_NAME,LEASE_NUM,
LEGAL_SURVEY_TYPE,LOCATION_TYPE,LOG_TD,LOG_TD_OUOM,MAX_TVD,MAX_TVD_OUOM,NET_PAY,NET_PAY_OUOM,OLDEST_STRAT_AGE,
OLDEST_STRAT_NAME_SET_AGE,OLDEST_STRAT_NAME_SET_ID,OLDEST_STRAT_UNIT_ID,OPERATOR,PARENT_RELATIONSHIP_TYPE,PARENT_UWI,
PLATFORM_ID,PLATFORM_SF_TYPE,PLOT_NAME,PLOT_SYMBOL,PLUGBACK_DEPTH,PLUGBACK_DEPTH_OUOM,PPDM_GUID,PROFILE_TYPE,PROVINCE_STATE,
REGULATORY_AGENCY,REMARK,RIG_ON_SITE_DATE,RIG_RELEASE_DATE,ROTARY_TABLE_ELEV,SOURCE_DOCUMENT,SPUD_DATE,STATUS_TYPE,
SUBSEA_ELEV_REF_TYPE,SURFACE_LATITUDE,SURFACE_LONGITUDE,SURFACE_NODE_ID,TAX_CREDIT_CODE,TD_STRAT_AGE,TD_STRAT_NAME_SET_AGE,
TD_STRAT_NAME_SET_ID,TD_STRAT_UNIT_ID,WATER_ACOUSTIC_VEL,WATER_ACOUSTIC_VEL_OUOM,WATER_DEPTH,WATER_DEPTH_DATUM,WATER_DEPTH_OUOM,
WELL_EVENT_NUM,WELL_GOVERNMENT_ID,WELL_INTERSECT_MD,WELL_NAME,WELL_NUM,WELL_NUMERIC_ID,WHIPSTOCK_DEPTH,WHIPSTOCK_DEPTH_OUOM,
IPL_LICENSEE,IPL_OFFSHORE_IND,IPL_PIDSTATUS,IPL_PRSTATUS,IPL_ORSTATUS,IPL_ONPROD_DATE,IPL_ONINJECT_DATE,IPL_CONFIDENTIAL_STRAT_AGE,
IPL_POOL,IPL_LAST_UPDATE,IPL_UWI_SORT,IPL_UWI_DISPLAY,IPL_TD_TVD,IPL_PLUGBACK_TVD,IPL_WHIPSTOCK_TVD,IPL_WATER_TVD,IPL_ALT_SOURCE,
IPL_XACTION_CODE,ROW_CHANGED_BY,ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,IPL_BASIN,IPL_BLOCK,IPL_AREA,IPL_TWP,
IPL_TRACT,IPL_LOT,IPL_CONC,IPL_UWI_LOCAL,ROW_QUALITY
from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and twv.uwi like '5%'
and source='300IPL';

select uwi,source, active_ind from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('25-JAN-2010', 'DD-MON-YYYY')
and twv.uwi like '5%';
---and source='300IPL';

----Well_Alias Table
insert into well_alias wa
select UWI,'700TLME' as source,WELL_ALIAS_ID,ACTIVE_IND,ALIAS_OWNER_BA_ID,ALIAS_TYPE,
APPLICATION_ID,EFFECTIVE_DATE,EXPIRY_DATE,LOCATION_TYPE,PPDM_GUID,PREFERRED_IND,
REASON_TYPE,REMARK,WELL_ALIAS,IPL_ALT_SOURCE,IPL_XACTION_CODE,ROW_CHANGED_BY,
ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,ROW_QUALITY
from TEMP_WA_300IPL_DELETED twa
where uwi in (
select twv.uwi from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('10-SEP-2010', 'DD-MON-YYYY')
and twv.uwi like '5%') 
and source='300IPL' order by uwi;


/*
select uwi, source from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('21-JAN-2010', 'DD-MON-YYYY')
and twv.uwi like '5%' 
and source='650TLMC' order by uwi;*/

---Add UWI_PRIOR for auditing
insert into WELL_ALIAS WA 
(uwi, source, well_alias_id, alias_type, active_ind, effective_date, reason_type, 
well_alias, row_created_by, row_created_date)
select wv.uwi, '300IPL' as source, 'TLM' as well_alias_id, 'UWI_PRIOR' as ALIAS_TYPE, 
'Y' as active_ind, twv.rundate as effective_date, 'D' as reason_type, twv.uwi as well_alias,
'FBAIRD' as ROW_CREATED_BY, twv.rundate as ROW_CREATED_DATE
from TALISMAN37.TEMP_WV_300IPL_DELETED twv, well_version wv
where  twv.uwi=wv.uwi
and twv.rundate > to_date ('17-AUG-2010', 'DD-MON-YYYY')
and twv.uwi like '5%';

select rowid,uwi,source,active_ind, alias_type,well_alias,reason_type,well_alias_id 
from well_alias where uwi='50480072000';

---Well_Node_Version Table
insert into  well_node_version
select NODE_ID,'700TLME' as SOURCE,NODE_OBS_NO,ACQUISITION_ID,ACTIVE_IND,COUNTRY,COUNTY,
EASTING,EASTING_OUOM,EFFECTIVE_DATE,ELEV,ELEV_OUOM,EW_DIRECTION,EXPIRY_DATE,
GEOG_COORD_SYSTEM_ID,LATITUDE,LEGAL_SURVEY_TYPE,LOCATION_QUALIFIER,
LOCATION_QUALITY,LONGITUDE,MAP_COORD_SYSTEM_ID,MD,MD_OUOM,MONUMENT_ID,
MONUMENT_SF_TYPE,NODE_POSITION,NORTHING,NORTHING_OUOM,NORTH_TYPE,NS_DIRECTION,
POLAR_AZIMUTH,POLAR_OFFSET,POLAR_OFFSET_OUOM,PPDM_GUID,PREFERRED_IND,
PROVINCE_STATE,REMARK,REPORTED_TVD,REPORTED_TVD_OUOM,VERSION_TYPE,X_OFFSET,
X_OFFSET_OUOM,Y_OFFSET,Y_OFFSET_OUOM,IPL_XACTION_CODE,ROW_CHANGED_BY,
ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,IPL_UWI,ROW_QUALITY,
IPL_UWI_LOCAL
from TEMP_WNV_300IPL_DELETED twnv
where node_id in 
(select surface_node_id from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('17-AUG-2010', 'DD-MON-YYYY')
and twv.uwi like '5%'
union
select base_node_id from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('17-AUG-2010', 'DD-MON-YYYY')
and twv.uwi like '5%');

---Well_Status Table
insert into well_Status 
select UWI,'700TLME' as SOURCE,STATUS_ID,ACTIVE_IND,EFFECTIVE_DATE,EXPIRY_DATE,PPDM_GUID,
REMARK,STATUS,STATUS_DATE,STATUS_DEPTH,STATUS_DEPTH_OUOM,IPL_XACTION_CODE,
STATUS_TYPE,ROW_CHANGED_BY,ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,
ROW_QUALITY,IPL_UWI_LOCAL
from TEMP_WS_300IPL_DELETED 
where uwi in (
select twv.uwi from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('17-AUG-2010', 'DD-MON-YYYY')
and twv.uwi like '5%');


---Well_License Table
insert into well_License wl 
select UWI,LICENSE_ID,'700TLME' as SOURCE,ACTIVE_IND,AGENT,APPLICATION_ID,AUTHORIZED_STRAT_UNIT_ID,
BIDDING_ROUND_NUM,CONTRACTOR,DIRECTION_TO_LOC,DIRECTION_TO_LOC_OUOM,DISTANCE_REF_POINT,
DISTANCE_TO_LOC,DISTANCE_TO_LOC_OUOM,DRILL_RIG_NUM,DRILL_SLOT_NO,DRILL_TOOL,
EFFECTIVE_DATE,EXCEPTION_GRANTED,EXCEPTION_REQUESTED,EXPIRED_IND,EXPIRY_DATE,
FEES_PAID_IND,LICENSEE,LICENSEE_CONTACT_ID,LICENSE_DATE,LICENSE_NUM,NO_OF_WELLS,
OFFSHORE_COMPLETION_TYPE,PERMIT_REFERENCE_NUM,PERMIT_REISSUE_DATE,PERMIT_TYPE,
PLATFORM_NAME,PPDM_GUID,PROJECTED_DEPTH,PROJECTED_DEPTH_OUOM,
PROJECTED_STRAT_UNIT_ID,PROJECTED_TVD,PROJECTED_TVD_OUOM,PROPOSED_SPUD_DATE,
PURPOSE,RATE_SCHEDULE_ID,REGULATION,REGULATORY_AGENCY,REGULATORY_CONTACT_ID,
REMARK,RIG_CODE,RIG_SUBSTR_HEIGHT,RIG_SUBSTR_HEIGHT_OUOM,RIG_TYPE,
SECTION_OF_REGULATION,STRAT_NAME_SET_ID,SURVEYOR,TARGET_OBJECTIVE_FLUID,
IPL_PROJECTED_STRAT_AGE,IPL_ALT_SOURCE,IPL_XACTION_CODE,ROW_CHANGED_BY,
ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,IPL_WELL_OBJECTIVE,
ROW_QUALITY,IPL_UWI_LOCAL
from TEMP_WL_300IPL_DELETED twl
where uwi in (
select twv.uwi from TEMP_WV_300IPL_DELETED twv
where twv.REASON='D' 
and twv.rundate > to_date ('17-AUG-2010', 'DD-MON-YYYY')
and twv.uwi like '5%');

--find all wells in well_version that have been transformed to 700 source
select uwi,source, active_ind, current_status from well_version 
where source='700TLME'
and uwi like '5%' order by uwi;

select * from well_status where uwi='50000031328';

---RollUp well versions and nodes
---Nov 26/09
exec TLM_REFRESH.WELL_AND_NODES('50000189414');
exec TLM_REFRESH.WELL_AND_NODES('50000251594');
exec TLM_REFRESH.WELL_AND_NODES('50000253990');
exec TLM_REFRESH.WELL_AND_NODES('50000254273');
exec TLM_REFRESH.WELL_AND_NODES('50000254274');
exec TLM_REFRESH.WELL_AND_NODES('50000264325');
exec TLM_REFRESH.WELL_AND_NODES('50282238000');
exec TLM_REFRESH.WELL_AND_NODES('50282244000');

---Nov 30/09
exec TLM_REFRESH.WELL_AND_NODES('50000266956');
exec TLM_REFRESH.WELL_AND_NODES('50000266980');
exec TLM_REFRESH.WELL_AND_NODES('50000269463');
exec TLM_REFRESH.WELL_AND_NODES('50000269461');
exec TLM_REFRESH.WELL_AND_NODES('50000266275');
exec TLM_REFRESH.WELL_AND_NODES('50000264316');
exec TLM_REFRESH.WELL_AND_NODES('50000268146');
exec TLM_REFRESH.WELL_AND_NODES('50000268901');


exec TLM_REFRESH.GROUP_WELL_REFRESH('700TLME');
exec TLM_REFRESH.GROUP_NODE_REFRESH('700TLME');

--June 12 load
exec TLM_REFRESH.WELL_AND_NODES('50000141615');
exec TLM_REFRESH.WELL_AND_NODES('50000156914');
exec TLM_REFRESH.WELL_AND_NODES('50000194291');
exec TLM_REFRESH.WELL_AND_NODES('50000278670');
exec TLM_REFRESH.WELL_AND_NODES('50000283095');
exec TLM_REFRESH.WELL_AND_NODES('50255278200');



---TOTAL INVENTORY COUNT
---*****
select WI.*
  from DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
 where wi.uwi not in (select well_alias
          from ppdm.well_alias
         where alias_type in ('UWI_PRIOR','UWI'));
--- 1098 Oct 26/09
----1096 Nov 9/09 (2 wells fixed for DM)
---1096 Nov 17/09 
         








