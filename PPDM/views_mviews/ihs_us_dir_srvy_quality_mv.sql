/***********************************************************************************************************************
 IHS maintains dir srvy data for Canada and the US (no international).
 Identify the "best"/preferred directional survey from multiple sources, for each well in WIM.

 --> This mview is for IHS-US directional survey data

 Note: MUST create new index on table ppdm.well_inventory to facilitate join by well_num (QC1722)
   create index tlm_wv_idx01_wnum on well_version (well_num);

 Each set of data has its own way of sorting the dir srvy data, to determine precedence.
   - only active dir srvy
   - coordinate system: wgs84, nad83, then nad27
   - location qualifer (IHS canada only): based on new rollup table wim.r_rollup_node_lq
   - azimuth north type: true/truenorth  (not grid/gridnorth)

 Method
  1. Identify multiple versions of dir srvys for each well, at IHS-Canada and IHS-US and set a precedence-order. (1 is best)
       Use the precedence/hierarchy order outlined above.
  2. For each dataset/source, return only the best version of the dir srvy.
  3. Use "UNION ALL" to join all the results from each source and do not attempt to remove duplicates.
     Note: the assumption is that IHS dir srvys will never overlap between Canada and the US; a dir srvy can only exist in one IHS db.

 History
   20160517 cdong   QC1669 Change structure of row-quality to be more responsive.  Script creation.
                    Create new materialized view for the external (IHS) directional survey data.
                    Then use this new mv in existing object ppdm.tlm_well_dir_srvy_quality_mv.

 **********************************************************************************************************************/

truncate table ppdm.ihs_us_dir_srvy_quality_mv ;
drop index ppdm.wdsq_iu_uwi_idx ;
drop materialized view ppdm.ihs_us_dir_srvy_quality_mv ;

create materialized view ppdm.ihs_us_dir_srvy_quality_mv
as

select w.uwi
       -- need to prefix with leading zeros, to be consistent with ppdm.well_dir_srvy* views
       , lpad(wds.survey_id, 3, '0') as survey_id
       , '450PID' as source
       , b.geog_coord_system_id
       , wds.survey_quality
       , wds.azimuth_north_type
       , b.location_qualifier
       , wds.active_ind
       , wds.uwi as ipl_uwi_local
       , row_number() over (partition by wds.uwi
                               order by decode(upper(wds.active_ind), 'Y', 1, 'N', 3, 2) asc
                                          , decode(upper(nvl(b.geog_coord_system_id, 'BAR')), 'WGS84', 1, 'NAD83', 2, 'NAD27', 3, 'BAR', 4, 5) asc
                                          --location qualifier is all 'IH' at ihs-us
                                          --survey_quality: not used at ihs-us like at TLM: P, G, F, and E
                          ) as dir_srvy_precedence
       , 'IHS_USA' as origin
  from --at IHS, only one header for each uwi-source-survey_id, even if multiple surveys (distinguished by coord sys and location qualifier)
       well_dir_srvy@C_TALISMAN_US_IHSDATAQ wds
       inner join
       (--get subset of data from station, in order to determine precedence
        select distinct
               wdss.uwi
               , wdss.source
               , wdss.survey_id
               , wdss.geog_coord_system_id
               , wdss.location_qualifier
               , active_ind
          from well_dir_srvy_station@C_TALISMAN_US_IHSDATAQ  wdss
         where wdss.depth_obs_no = 1
       ) b on wds.uwi = b.uwi and wds.source = b .source and wds.survey_id = b.survey_id
       --join with WIM database, to match to TLM-id (use well_version)
       inner join ppdm.well_version w on wds.uwi = w.well_num
                                         and w.source = '450PID'
                                         and w.active_ind = 'Y'
 where wds.active_ind = 'Y'
       --and wds.azimuth_north_type = 'TRUENORTH'
                                    --'GRIDNORTH'

;

/


----comment
comment on materialized view ppdm.ihs_us_dir_srvy_quality_mv is 'snapshot of well directional survey precedence for IHS US dir srvys';

----indexes: created for future joins
create index ppdm.wdsq_iu_uwi_idx on ppdm.ihs_us_dir_srvy_quality_mv
(uwi)
;


----grants
----for general ppdm ro
grant select on ppdm.ihs_us_dir_srvy_quality_mv to ppdm_ro;
----for monitoring, mview-refresh
grant select on ppdm.ihs_us_dir_srvy_quality_mv to ppdm_admin;

