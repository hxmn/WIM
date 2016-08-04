/***********************************************************************************************************************

 TLM has its own dir srvy data and IHS maintains dir srvy data for Canada and the US (no international).
 Identify the "best"/preferred directional survey from multiple sources, for each well in WIM.

 Each set of data has its own way of sorting the dir srvy data, to determine precedence.
   - as-drilled. for TLM, survey_quality is NOT 'proposed'; for IHS, no way to know, so treat every as as-drilled
   - only active dir srvy
   - coordinate system: wgs84, nad83, then nad27
   - survey quality (TLM-only): ok, fixed, raw
   - location qualifer (IHS canada only): ats26, bcts20, ..., hist22
   - azimuth north type: true/truenorth  (not grid/gridnorth)

 Method
  1. Identify multiple versions of dir srvys for each well, at TLM, IHS-Canada, and IHS-US and set a precedence-order. (1 is best)
       Use the precedence/hierarchy order outlined above.
  2. For each dataset/source, return only the best version of the dir srvy.
  3. Use "UNION ALL" to join all the results from each source and do not attempt to remove duplicates.
     Note: the assumption is that IHS dir srvys will never overlap between Canada and the US; a dir srvy can only exist in one IHS db.

 Test data: use tlm-id: ('1004690603', '132188', '142598', '148496', '300000112363', '139752', '143123', '143280', '147357', '147685', '1004727066', '1005284611', '137636', '142548')
   This group of wells have dir srvys from TLM and IHS

 History
   20140929 cdong   TIS Task 1527
                    Created original script
   20141008 cdong   Adapted script to create materialized view to store the "best"/preferred dir srvy from each source.
                      Do not roll-up the dir srvys from TLM and IHS into one dir srvy, since DataFinder spatial
                        has layers for each of TLM, IHS Canada, and IHS US well paths (dir srvy).  DF needs to know
                        which is the best dir srvy for each.
                      Note: we can still do the roll-up outside this mview, for DF relational and the DF Petrel export,
                        and the well inventory count.
   20141009 cdong   Changed to NOT return the best from each source; return all.  Then set precedence/row_quality against
                      ALL dir srvys from ALL sources/origins.
                    Requirements clarification: Cindy Guenard wants the ranking to be written to a row_quality column for dir srvys.
                      DF Spatial and Relational will continue to count/display ALL dir srvys from all sources.
                      However, the Petrel Export will return the "best" (highest ranked) dir srvy.
                    Changed precedence algorithm to exclude the filter on azimuth_north_type, per Cindy Guenard.
   20141015 cdong   Okay to return best IHS dir srvy 
   20141204 cdong   Modify for KL, where there is no IHS dir srvy data
                      Get data from COMBO-VIEWS that return dir srvy data from ALL Asia Pacific databases.

 **********************************************************************************************************************/

truncate table ppdm.tlm_well_dir_srvy_quality_mv ;
drop materialized view ppdm.tlm_well_dir_srvy_quality_mv ;

create materialized view ppdm.tlm_well_dir_srvy_quality_mv
( uwi
  , survey_id
  , source
  , geog_coord_system_id
  , survey_quality
  , azimuth_north_type
  , location_qualifier
  , active_ind
  , ipl_uwi_local
  , origin
  , origin_rank
  , row_quality
)
NOCACHE
NOLOGGING
NOCOMPRESS
BUILD IMMEDIATE


--create table tmp_dir_srvy_rank
as

  select uwi
         , survey_id
         , source
         , geog_coord_system_id
         , survey_quality
         , azimuth_north_type
         --cannot have NULL value in an mview (ora-01723)
         , location_qualifier
         , active_ind
         , ipl_uwi_local
         , origin
         , dir_srvy_precedence as origin_rank
         , row_number() over (partition by uwi
                                 order by --to set precedence based on origin
                                          case origin
                                            when 'TLM' then 1
                                            --when 'IHS_CANADA' then 2
                                            --when 'IHS_USA' then 3
                                            else 4
                                          end asc
                                          --to re-rank based on origin precedence
                                          , dir_srvy_precedence asc
                            ) as row_quality

    from (--identify the tlm dir srvy that with the highest precedence
          select wds.uwi
                 , wds.survey_id
                 , wds.source
                 , decode(upper(nvl(wdss.geog_coord_system_id, 'BAR')), '4326', 'WGS84', '4269', 'NAD83', '4267', 'NAD27', wdss.geog_coord_system_id) as geog_coord_system_id
                 , wds.survey_quality
                 , wds.azimuth_north_type
                 , wdss.location_qualifier
                 , wds.active_ind
                 , wds.uwi as ipl_uwi_local
                 , row_number() over (partition by wds.uwi
                                         order by decode(upper(nvl(wds.coord_system_id, 'BAR')), '4326', 1, '4269', 2, '4267', 4, 5) asc
                                                  , decode(upper(nvl(wds.survey_quality, 'FOO')), 'OK', 1, 'FIXED', 2, 'RAW', 3, 'FOO', 4, 5) asc
                                                  , wds.survey_id desc
                                    ) as dir_srvy_precedence
                 , 'TLM' as origin
            from ppdm.well_dir_srvy wds
                 --specific for PDMS implementation of this mview
                 inner join (select distinct uwi, survey_id, geog_coord_system_id, location_qualifier
                               from ppdm.well_dir_srvy_station
                            ) wdss on wds.uwi = wdss.uwi and wds.survey_id = wdss.survey_id
                 inner join ppdm.well w on wds.uwi = w.uwi
           where wds.active_ind = 'Y'
                 and wds.survey_quality <> 'PROPOSED'
          order by wds.uwi, dir_srvy_precedence
          ) alldirsrvy


;

----comment
comment on materialized view ppdm.tlm_well_dir_srvy_quality_mv is 'snapshot of well directional survey precedence for TLM dir srvys';

----indexes
---- created for future joins

create index ppdm.wdshmv1_uwi_idx on ppdm.tlm_well_dir_srvy_quality_mv
(uwi)
;

create index ppdm.wdshmv1_origin_idx on ppdm.tlm_well_dir_srvy_quality_mv
(origin)
;

create index ppdm.wdshmv1_ipluwilocal_idx on ppdm.tlm_well_dir_srvy_quality_mv
(ipl_uwi_local)
;

create index ppdm.wdshmv1_coordid_idx on ppdm.tlm_well_dir_srvy_quality_mv
(geog_coord_system_id)
;

create index ppdm.wdshmv1_locid_idx on ppdm.tlm_well_dir_srvy_quality_mv
(location_qualifier)
;

create index ppdm.wdshmv1_rquality_idx on ppdm.tlm_well_dir_srvy_quality_mv
(row_quality)
;

----grants
----for general ppdm ro
grant select on ppdm.tlm_well_dir_srvy_quality_mv to ppdm_ro;
----for monitoring, mview-refresh
grant select on ppdm.tlm_well_dir_srvy_quality_mv to ppdm_admin;
----for DataFinder
grant select on ppdm.tlm_well_dir_srvy_quality_mv to data_finder;
----for inventory counts
--grant select on ppdm.tlm_well_dir_srvy_quality_mv to well_inventory;
----for spatial (GIS)
grant select on ppdm.tlm_well_dir_srvy_quality_mv to r_spatial;

