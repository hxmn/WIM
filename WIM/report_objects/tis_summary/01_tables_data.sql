/*******************************************************************************

 Create objects to identify and store the counts from WIM Housekeeping.
 The counts will be used in reports.

 History
  20141002  cdong   TIS Task 1453 - created script, objects in my own schema
  20150707  cdong   TIS Task 1654 - add report to AP
                    added active_ind column to table, and added check only for AP
  20150707  cdong   TIS Task 1656 - move objects to WIM schema
  20150807  cdong   QC1713 report on records management orphans - add new checks
                    QC1686 report on wells with KB elevation zero or less
  20151116  cdong   QC1727 report on directional surveys (1) with too-many active headers
                      or (2) duplicate measured depth values in consecutive stations
  20160120  cdong   Include new items for the data check
                    QC1758 report on wells where override version is old
                    QC1760 report on wells where KB elevation is equal to Ground elevation
  20160318  cdong   QC1790/1791/1792/1793 separate item counts by region (ab,sk vs other)
                    Create new report items 002a/b, 037a/b, 042a/b, 043a/b.
  20160321  cdong   QC1783 inactive well versions and active license, node version, or status
                    QC1784 wells with multiple licenses
  20160324  cdong   QC1764 Wells with only an active GDM (700TLME) well version and no inventory.
                    QC1781 Wells with only a surface or bottom-hole location and not the other.
                    QC1740 Failed inactivations due to inventory
  20160331  cdong   QC1798 UWI's with multiple (composite) wells
  20160420  cdong   QC1810 re-purposed report item 019
                    Move 019 to 045d
                    Add new 019a through 019e
                    Modify descriptions for 045a thru c
  20160503  cdong   Correct descriptions for 016 and 017-- no longer using override well version.
                    Set 017 to inactive, because this is no longer an issue. The system-generated-NAD27
                      well version is created from the most "trusted" location version IFF that "tusted"
                      version doesn't have a NAD27.
                    Set 018 to inactive, because this check is covered by items 029-032.
  20160509  cdong
    QC1819 Expand checks in WIM Duplicate UWI-Well report to include British Columbia
    002*, 029*, 044*, and 049*
  20160511  cdong
    QC1822  Merge report items for NAD27-generation counts (015 and 016)
    Update description for 015 and Inactivate 016
  20160617  cdong
    QC1843/1844 TRIM leading/trailing blank-spaces

 *******************************************************************************/


--truncate table z_benchmark;
--drop table z_benchmark cascade constraints;
create table z_benchmark
(
  r_id                      varchar2(50)
  , active_ind              varchar2(1)     default 'Y'
  , description             varchar2(1000)
  , r_type                  varchar2(50)
  , pattern                 varchar2(2000)
  , remarks                 varchar2(4000)
  , row_created_date        timestamp       default(systimestamp)
  , row_created_by          varchar2(60)    default(user)

)
;

alter table z_benchmark
  add constraint zbenchmark_pk
  primary key (r_id) enable
;

--truncate table z_benchmark_stats;
--drop table z_benchmark_stats cascade constraints;
create table z_benchmark_stats
(
  batch                   varchar2(50)    not null
  , r_id                  varchar2(1000)
  , log_date              timestamp
  , count                 int
  , row_created_date      timestamp       default(systimestamp)
)
;

alter table z_benchmark_stats
  add constraint zbenchmarkstats_pk
  primary key (batch, r_id) enable
;


insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('001'
            , 'Directional surveys where null coord_system_id has been automatically fixed.'
            , 'wim_housekeeping: number of directional survey headers updated: '
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('002'
            --, 'well versions with duplicate ipl_uwi_local'
            , 'UWI''s (regulatory authority / government well ID) associated with well versions of more than one well.  A well can have multiple well versions. Each version can have its own UWI, which may be the same as the UWI of a version from another well.'
            , 'wim_housekeeping: wells with duplicate ipl_uwi_local check : total number of duplicate ipl_uwi_locals found'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('003'
            --, 'well versions with duplicate well_num'
            , 'Data provider''s unique identifier (well_num) associated with more than one well.  A well can have multiple well versions. Each version can have its own well_num, which may be the same as the well_num of a version from another well.'
            , 'wim_housekeeping: wells with duplicate well_num check : total number of duplicate well_nums found'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('004'
            , 'Wells with incorrect coord system (NAD27). Only certain countries should use this coordinate system.'
            , 'wim_housekeeping: number of wells with incorrect geog_coord_system_id (nad27/4267)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('005'
            , 'Wells with incorrect coord system (NAD83). Only certain countries should use this coordinate system.'
            , 'wim_housekeeping: number of wells with incorrect geog_coord_system_id (nad83/4269)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('006'
            , 'Inactive well versions with active well-node versions'
            , 'wim_housekeeping: number of inactive well versions with active well node versions'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('007'
            , 'Wells with undefined coordinate system (geog_coordinate_system_id).'
            , 'wim_housekeeping: number of wells with undefined coordinate system'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('008'
            , 'Wells where the location does not specify a country.'
            , 'wim_housekeeping: number of node versions with no country'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('009'
            , 'Well-node versions without a node position (surface/bottom).  All node records should indicate whether it is for the surface or bottom-hole location.'
            , 'wim_housekeeping: number of node versions with no node_position'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('010'
            , 'Wells without a well name.'
            , 'wim_housekeeping: number of wells with no well_name'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('011'
            , 'Wells with only override/underride version(s).  Support to remove the version(s), after-which the well will no longer exist.'
            , 'wim_housekeeping: number of wells with only override version'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('012'
            , 'Wells with inconsistent well-node ids. The node id typically follows a standard of TLM well ID followed by a zero or one.'
            , 'wim_housekeeping: number of well versions with invalid base_node_id'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('013'
            , 'Well versions with invalid country codes.'
            , 'wim_housekeeping: number of wells with non-standard country codes'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('014'
            , 'Wells in WIM that are not in DM. Only wells with a 100TLM or 700TLME well version are checked against DM.'
            , 'wim_housekeeping: number of wim wells that are not in dm'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('015'
            , 'North American wells requiring location conversion to NAD27.  DataFinder well layer is based on NAD27, therefore all wells in North America required a NAD27 location.'
            , 'wim_housekeeping: number of north america wells requiring location conversion to nad27'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('016'
            , 'North America wells, with a system-generated-NAD27 well version, where non-NAD27 coordinates are changed (for another version of the well). Update of the generated-NAD27 version is usually required.'
            , 'wim_housekeeping: number of north america wells requiring location update of override version'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('017'
            , 'Wells with both a system-generated-NAD27 well version and another well version with NAD27 coordinates.  Review generated-NAD27 version and determine if it can be removed.'
            , 'wim_housekeeping: number of 075tlmo override well-versions that have another nad27 version'
            , NULL
            , 'logcount'
            , 'N')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('018'
            , 'Wells versions with multiple UWI (ipl_uwi_local) values.  This can lead to external data (e.g. IHS) being incorrectly associated to a well.'
              || ' A well may have more than one version, so this count will be higher.'
            , 'wim_housekeeping: number of well-versions with same tlm-id and different ipl_uwi_local'
            , NULL
            , 'logcount'
            , 'N')
;

/* ----20160420 cdong QC1810 moved this check to 045d and repurposed 019
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019'
            , 'Orphaned well area records without a matching well version record. This data is automatically removed by the WIM Housekeeping process.'
            , 'wim_housekeeping: number of orphaned well_area records'
            , NULL
            , 'logcount'
            , 'Y')
;
*/

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('020'
            , 'CWS-source wells without a matched public version (Canada).'
              || ' This value includes (1) CWS version without a public version for the same proprietary well-id (TLM ID),'
              || ' and (2) CWS version with a public version for the same proprietary well-id, but different UWI (ipl_uwi_local).'
            , 'wim_housekeeping: number of canadian wells (7cn) without a (300ipl) source'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('021'
            , 'CWS-source wells without a matched public version (USA).'
              || ' This value includes (1) CWS version without a public version for the same proprietary well-id (TLM ID),'
              || ' and (2) CWS version with a public version for the same proprietary well-id, but different API (ipl_uwi_local).'
            , 'wim_housekeeping: number of us wells (7us) without a (450pid) source'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('022'
            , 'CWS-source wells without a matched public version (international).'
              || ' Note: CWS no longer maintains (update/add) international well data; it only handles Canada and US wells.'
              || ' Therefore, this data-check may have less value. International CWS wells have source 880SCWS.'
            , 'wim_housekeeping: number of international wells without a (500prb) source'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('023'
            , 'Directional surveys where header active_ind does not match station active_ind (TLM-proprietary)'
            , 'wim_housekeeping: number of dir srvy where active_ind is different between header and stations (tlm)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('024'
            , 'Directional surveys where header active_ind does not match station active_ind (IHS Canada).  Notify IHS.'
            , 'wim_housekeeping: number of dir srvy where active_ind is different between header and stations (ihs canada)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('025'
            , 'Directional surveys where header active_ind does not match station active_ind (IHS US).  Notify IHS.'
            , 'wim_housekeeping: number of dir srvy where active_ind is different between header and stations (ihs us)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('026'
            , 'Wells where null coord_system_id has been automatically fixed.'
            , 'wim_housekeeping: number of wells with null coord system_id fixed'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('027'
            , 'Wells with carriage-return-line-feed or tab in well name.  This can result in problems with data-import into other systems (Petrel).'
            , 'wim_housekeeping: number of wells with crlf or tab in well name'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('028'
            , 'Well versions with carriage-return-line-feed or tab in well name.  This can result in problems with data-import into other systems (Petrel).'
            , 'wim_housekeeping: number of active well_versions with crlf or tab in well name'
            , NULL
            , 'logcount'
            , 'Y')
;

--2015-05-05 new checks TIS Task 1628
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('029'
            , 'Wells with multiple UWI''s in active well versions - Canada (Alberta, BC, Saskatchewan). This is similar to Item 018, but is for wells (not versions) and is filtered for a specific area.'
            , 'wim_housekeeping: number of wells with multiple uwis in active well versions (canada ab, bc, sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('030'
            , 'Wells with multiple UWI''s in active well versions - Canada (other than AB, BC, SK). This is similar to Item 018, but is for wells (not versions) and is filtered for a specific area.'
            , 'wim_housekeeping: number of wells with multiple uwis in active well versions (canada other)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('031'
            , 'Wells with multiple UWI''s in active well versions - USA. This is similar to Item 018, but is for wells (not versions) and is filtered for a specific area.'
            , 'wim_housekeeping: number of wells with multiple uwis in active well versions (usa)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('032'
            , 'Wells with multiple UWI''s in active well versions - Other than Canada or USA. This is similar to Item 018, but is for wells (not versions) and is filtered for a specific area.'
            , 'wim_housekeeping: number of wells with multiple uwis in active well versions (other)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('033'
            , 'Wells with multiple countries in active well versions. All well versions should have the same country.'
            , 'wim_housekeeping: number of wells with multiple countries in active well versions'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('034'
            , 'Wells with multiple countries in active well node (location) versions. All location records should have the same country.'
            , 'wim_housekeeping: number of wells with multiple countries in active well node versions'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('035'
            , 'Wells with an active directional survey well version and no active proprietary directional survey data. Typically, the well version is based on directional survey data loaded to the system.'
            , 'wim_housekeeping: number of wells with a dir srvy well version and no active proprietary dir srvy data'
            , NULL
            , 'logcount'
            , 'Y')
;

----20150707 cdong   this is for AP only, so it is disabled (for NA)
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('036'
            , 'Asia-Pacific wells with non-WGS84 coordinate system. '
            , 'wim_housekeeping: number of active ap wells with non-wgs84 (4326) datum'
            , NULL
            , 'logcount'
            , 'N')
;

----20150807  cdong   QC1686 report on wells with KB elevation zero or less
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('037'
            , 'Wells with KB Elevation of zero or less.  This is possible, but is atypical and unusual.'
            , 'wim_housekeeping: number of wells with kb elevation of zero or negative value'
            , NULL
            , 'logcount'
            , 'Y')
;

----20150807  cdong   QC1713 report on records management orphans - add new checks
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('038'
            , 'Records Management items where the associated well is no longer active and/or does not exist.'
            , 'wim_housekeeping: number of rm records without an active well'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('039'
            , 'Records Management items where the associated area is no longer active and/or does not exist.'
            , 'wim_housekeeping: number of rm records without an active area'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('040'
            , 'Wells with three-or-more active directional survey headers.  Typically, the dir srvy loading workflow would result in with two active headers, for Canada or the USA.'
               || ' If there are "too-many" headers, this could mean there are old(er) surveys to remove.  Forward list of wells to Directional Survey steward.'
            , 'wim_housekeeping: number of directional surveys with multiple headers'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('041'
            , 'Directional Surveys with duplicate measured depth values in the station data.  This is only a problem for Petrel.'
               || ' The dir srvy loading workflow may identify the duplicates prior to loading via GeoWiz.  However, some duplication can occur as a result of'
               || ' unit conversion and rounding.'
            , 'wim_housekeeping: number of directional surveys with duplicate md'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('042'
            , 'Wells with Override well versions that were last updated or created more than one year ago.'
               || ' The Data Steward(s) should review these versions and confirm their validity.'
            , 'wim_housekeeping: number of wells with an active override well version that is old'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('043'
            , 'Wells where the KB elevation is equivalent to the ground elevation (GLE).'
               || ' The Data Steward(s) should review these wells and correct the data.'
            , 'wim_housekeeping: number of wells with kb elevation equal to ground elevation'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1790 split item 002 by regions
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('002a'
            , 'UWI''s associated with well versions of more than one well.'
              || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: wells with duplicate ipl_uwi_local check : total number of duplicate ipl_uwi_locals found (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('002b'
            , 'UWI''s associated with well versions of more than one well.'
              || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: wells with duplicate ipl_uwi_local check : total number of duplicate ipl_uwi_locals found (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1791 split item 037 by regions
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('037a'
            , 'Wells with KB Elevation of zero or less.'
              || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of wells with kb elevation of zero or negative value (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('037b'
            , 'Wells with KB Elevation of zero or less.'
              || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of wells with kb elevation of zero or negative value (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1792 split item 042 by regions
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('042a'
            , 'Wells with Override well versions that were last updated or created more than one year ago.'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of wells with an active override well version that is old (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('042b'
            , 'Wells with Override well versions that were last updated or created more than one year ago.'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of wells with an active override well version that is old (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1793 split item 043 by regions
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('043a'
            , 'Wells where the KB elevation is equivalent to the ground elevation (GLE).'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of wells with kb elevation equal to ground elevation (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('043b'
            , 'Wells where the KB elevation is equivalent to the ground elevation (GLE).'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of wells with kb elevation equal to ground elevation (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1784 wells with multiple licenses
----  CWS wells typically include a single-character prefix for their license numbers
----  For CWS license numbers, the majority of province-specific prefixes are removed prior to comparing license numbers for each well
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('044'
            , 'Wells with multiple active license numbers.'
            , 'wim_housekeeping: number of wells with multiple active license numbers'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('044a'
            , 'Wells with multiple active license numbers.'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of wells with multiple active license numbers (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('044b'
            , 'Wells with multiple active license numbers.'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of wells with multiple active license numbers (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1783 Inactive well version with active well licenses, node-versions, or statuses.
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('045a'
            , 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Fix license record(s).'
            , 'wim_housekeeping: number of inactive well versions with active license(s) fixed'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('045b'
            , 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Fix node-version record(s).'
            , 'wim_housekeeping: number of inactive well versions with active node version(s) fixed'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('045c'
            , 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Fix status record(s).'
            , 'wim_housekeeping: number of inactive well versions with active status(es) fixed'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1764 Wells with only an active GDM (700TLME) well version and no inventory.
--The GDM team may need to create a well version in order to load physical or digital "inventory" for a well.
--A well with only a GDM well version and no associated inventory should be reviewed by the data steward(s)
-- to confirm the validity of the well. This well version may not include as much well header information as other versions.
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('046'
            , 'Wells with only a GDM well version and no associated inventory.'
               || ' These should be reviewed by the data steward(s) to validate the well.'
            , 'wim_housekeeping: number of gdm-version-only wells with no inventory'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('046a'
            , 'Wells with only a GDM well version and no associated inventory.'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of gdm-version-only wells with no inventory (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('046b'
            , 'Wells with only a GDM well version and no associated inventory.'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of gdm-version-only wells with no inventory (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1781 Wells with only a surface or bottom-hole location and not the other.
----While it is not critical that a well have both, Petrel has a preference for the surface location.
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('047'
            , 'Wells with either a surface or bottom-hole location, but not both.'
               || ' The data steward(s) can use this check to confirm wells in the Petrel AOI''s have a surface and/or bottom.'
            , 'wim_housekeeping: number of wells with only one node position'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('047a'
            , 'Wells with either a surface or bottom-hole location, but not both.'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of wells with only one node position (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('047b'
            , 'Wells with either a surface or bottom-hole location, but not both.'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of wells with only one node position (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1740 Failed inactivations due to inventory
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('048'
            , 'Failed WIM Loader inactivation(s) due to associated inventory.'
               || ' The system will stop if it finds inventory during the inactivation/deletion of the last active well version.'
            , 'wim_housekeeping: number of failed well version inactivations due to inventory'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('048a'
            , 'Failed WIM Loader inactivation(s) due to associated inventory.'
               || ' Filtered for Canada (Alberta and Saskatchewan).'
            , 'wim_housekeeping: number of failed well version inactivations due to inventory (ab,sk)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('048b'
            , 'Failed WIM Loader inactivation(s) due to associated inventory.'
               || ' Filtered for regions other than Canada (AB and SK).'
            , 'wim_housekeeping: number of failed well version inactivations due to inventory (other)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----QC1798 Failed inactivations due to inventory
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('049'
            , 'UWI (regulatory authority / government well ID) with multiple (composite) wells sharing the same UWI.'
               || ' A UWI should be unique and associated with a single (composite) well, in a given country.'
               || ' This check is very similar to 002; however that check is for a UWI shared between well versions of different wells.'
               || ' The Data Steward(s) should review the affected wells.'
            , 'wim_housekeeping: number of unique well identifiers shared by multiple composite wells'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('049a'
            , 'UWI with multiple (composite) wells sharing the same UWI.'
               || ' Filtered for Canada.'
            , 'wim_housekeeping: number of unique well identifiers shared by multiple composite wells (canada)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('049b'
            , 'UWI with multiple (composite) wells sharing the same UWI.'
               || ' Filtered for the USA. The UWI is known as an API in the US.'
            , 'wim_housekeeping: number of unique well identifiers shared by multiple composite wells (usa)'
            , NULL
            , 'logcount'
            , 'Y')
;


-----------------------------------------------------------------------------------------------------------------------
----20160420 cdong  WIM Housekeeping 2016.03 changes : new report items, change text on existing report items
----QC1810 moved well_area deletions to 045d (from 019)

/*

----update descriptions for cws-unmatched report items

update z_benchmark
   set description = 'CWS-source wells without a matched public version (Canada).'
                      || ' This value includes (1) CWS version without a public version for the same proprietary well-id (TLM ID),'
                      || ' and (2) CWS version with a public version for the same proprietary well-id, but different UWI (ipl_uwi_local).'
 where r_id = '020'
;

update z_benchmark
   set description = 'CWS-source wells without a matched public version (USA).'
                      || ' This value includes (1) CWS version without a public version for the same proprietary well-id (TLM ID),'
                      || ' and (2) CWS version with a public version for the same proprietary well-id, but different API (ipl_uwi_local).'
 where r_id = '021'
;

update z_benchmark
   set description = 'CWS-source wells without a matched public version (international).'
                      || ' Note: CWS no longer maintains (update/add) international well data; it only handles Canada and US wells.'
                      || ' Therefore, this data-check may have less value. International CWS wells have source 880SCWS.'
 where r_id = '022'
;

----update descriptions to include well-area as part of clean-up

update z_benchmark
   set description = 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
                      || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
                      || ' Fix license record(s).'
 where r_id = '045a'
;

update z_benchmark
   set description = 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
                      || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
                      || ' Fix node version record(s).'
 where r_id = '045b'
;

update z_benchmark
   set description = 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
                      || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
                      || ' Fix status record(s).'
 where r_id = '045c'
;

----repurposed 019 to 045d: change r_id in counts log table (for reports)

update z_benchmark_stats
   set r_id = '045d'
--select * from z_benchmark_stats
 where r_id = '019'
       and row_created_date < sysdate
;

-----select * from z_benchmark_stats  where r_id = '045d'  order by row_created_date desc;

delete
  from z_benchmark
 where r_id = '019'
;

*/

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('045d'
            , 'Inactive well versions with active well license(s), node-version(s), status(es) and/or well-area(s).'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Fix well area record(s).'
            , 'wim_housekeeping: number of inactive well versions with active well_area(s) fixed'
            , NULL
            , 'logcount'
            , 'Y')
;

-----------------------------------------------------------------------------------------------------------------------
----20160420 cdong
----QC1810 repurposed 019 for data-cleanup of well data (node, node-version, license, status, well-area) where well_version does not exist
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019a'
            , 'Remove well (header) data where the associated well version record, matched by well-id and source, does not exist. '
               || ' Without a well version record, the data does not roll-up and is of no use.'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Remove well node record(s).'
            , 'wim_housekeeping: no well version - number of well node records deleted'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019b'
            , 'Remove well (header) data where the associated well version record, matched by well-id and source, does not exist. '
               || ' Without a well version record, the data does not roll-up and is of no use.'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Remove well node version record(s).'
            , 'wim_housekeeping: no well version - number of well node version records deleted'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019c'
            , 'Remove well (header) data where the associated well version record, matched by well-id and source, does not exist. '
               || ' Without a well version record, the data does not roll-up and is of no use.'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Remove well license record(s).'
            , 'wim_housekeeping: no well version - number of well license records deleted'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019d'
            , 'Remove well (header) data where the associated well version record, matched by well-id and source, does not exist. '
               || ' Without a well version record, the data does not roll-up and is of no use.'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Remove well status record(s).'
            , 'wim_housekeeping: no well version - number of well status records deleted'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('019e'
            , 'Remove well (header) data where the associated well version record, matched by well-id and source, does not exist. '
               || ' Without a well version record, the data does not roll-up and is of no use.'
               || ' The WIM Housekeeping process automatically resolves the data consistency issue.'
               || ' Remove well area record(s).'
            , 'wim_housekeeping: no well version - number of well area records deleted'
            , NULL
            , 'logcount'
            , 'Y')
;



-----------------------------------------------------------------------------------------------------------------------
----20160503 cdong : update description bc no longer using override for nad27, inactivate 017 and 018 bc no longer applicable

update z_benchmark
   set description = 'North America wells, with a system-generated-NAD27 well version, where non-NAD27 coordinates are changed (for another version of the well). Update of the generated-NAD27 version is usually required.'
 where r_id = '016'
;

update z_benchmark
   set active_ind = 'N'
       , description = 'Wells with both a system-generated-NAD27 well version and another well version with NAD27 coordinates.  Review generated-NAD27 version and determine if it can be removed.'
 where r_id = '017'
;

update z_benchmark
   set active_ind = 'N'
 where r_id = '018'
;

----correction to descriptions, following disabling of 018---

update z_benchmark
   set description = 'Wells with multiple UWI''s in active well versions - Canada (Alberta, BC, Saskatchewan).'
 where r_id = '029'
;

update z_benchmark
   set description = 'Wells with multiple UWI''s in active well versions - Canada (other than AB, BC, SK).'
 where r_id = '030'
;

update z_benchmark
   set description = 'Wells with multiple UWI''s in active well versions - USA.'
 where r_id = '031'
;

update z_benchmark
   set description = 'Wells with multiple UWI''s in active well versions - Other than Canada or USA.'
 where r_id = '032'
;



-----------------------------------------------------------------------------------------------------------------------
----20160509 cdong
----QC1819 expand checks to include BC (002a, 029, 044a, 049a)
----note: no action for 029 and 049a, as they already include BC

update z_benchmark
   set description = 'UWI''s associated with well versions of more than one well.'
                       || ' Filtered for Canada (Alberta, Saskatchewan, and BC).'
       , pattern = 'wim_housekeeping: wells with duplicate ipl_uwi_local check : total number of duplicate ipl_uwi_locals found (ab,sk,bc)'
 where r_id = '002a'
;

update z_benchmark
   set description = 'UWI''s associated with well versions of more than one well.'
                       || ' Filtered for regions other than Canada (AB,SK,BC).'
 where r_id = '002b'
;

update z_benchmark
   set description = 'Wells with multiple active license numbers.'
                       || ' Filtered for Canada (Alberta, Saskatchewan, and BC).'
       , pattern = 'wim_housekeeping: number of wells with multiple active license numbers (ab,sk,bc)'
 where r_id = '044a'
;

update z_benchmark
   set description = 'Wells with multiple active license numbers.'
                       || ' Filtered for regions other than Canada (AB,SK,BC).'
 where r_id = '044b'
;



-----------------------------------------------------------------------------------------------------------------------
----20160511 cdong
----QC1822 merge report items for NAD27-generation counts-- inactivate 016 and update description for 015

update z_benchmark
   set description = 'North American wells requiring location conversion to NAD27. DataFinder well layer is based on NAD27, therefore all wells in North America required a NAD27 location.'
                       || ' Count includes wells requiring new generated-NAD27 location and wells requiring update to generated-NAD27.'
 where r_id = '015'
;

update z_benchmark
   set active_ind = 'N'
 where r_id = '016'
;




-----------------------------------------------------------------------------------------------------------------------
----20160617 cdong
----QC1843/1844 check for well versions with attributes with leading/trailing blank-space
insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('050a'
            , 'Remove leading and/or trailing blank-space character(s) from active well version records.'
               || ' Exclude versions from external sources (IHS and CWS).'
               || ' Update well name.'
            , 'update well version and remove leading and trailing spaces (name) - updated'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('050b'
            , 'Remove leading and/or trailing blank-space character(s) from active well version records.'
               || ' Exclude versions from external sources (IHS and CWS).'
               || ' Update UWI (ipl_uwi_local).'
            , 'update well version and remove leading and trailing spaces (uwi) - updated'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('050c'
            , 'Well versions with leading and/or trailing blank-space character(s).  Well name and/or UWI.'
               || ' CWS well versions only.'
            , 'wim_housekeeping: trim required - number of well version records (cws)'
            , NULL
            , 'logcount'
            , 'Y')
;

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('050d'
            , 'Well versions with leading and/or trailing blank-space character(s).  Well name and/or UWI.'
               || ' All sources other than IHS and CWS.'
            , 'wim_housekeeping: trim required - number of well version records (not ihs or cws)'
            , NULL
            , 'logcount'
            , 'Y')
;





-----------------------------------------------------------------------------------------------------------------------
/* --template

insert into z_benchmark (r_id, description, pattern, remarks, r_type, active_ind)
  values ('0xx'
            , ''
            , ''
            , NULL
            , 'logcount'
            , 'Y')
;
*/


grant select, insert, update, delete    on z_benchmark         to rpeters, kxedward, cdong;
grant select, insert, update, delete    on z_benchmark_stats   to rpeters, kxedward, cdong;

grant select                            on z_benchmark         to birt_appl;
grant select                            on z_benchmark_stats   to birt_appl;
grant select                            on z_benchmark         to wim_ro;


/* --debugging

select *
  from z_benchmark
 order by r_id
;

select *
  from z_benchmark_stats
 where row_created_date > sysdate - 5
 order by batch, r_id
;

*/
