/***********************************************************************************************************************
 IHS maintains dir srvy data for Canada and the US (no international).
 Identify the "best"/preferred directional survey from multiple sources, for each well in WIM.

 --> This mview is for IHS-US directional survey data

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

truncate table ppdm.ihs_cdn_dir_srvy_quality_mv ;
drop index ppdm.wdsq_ic_uwi_idx ;
drop materialized view ppdm.ihs_cdn_dir_srvy_quality_mv ;

create materialized view ppdm.ihs_cdn_dir_srvy_quality_mv
as

select w.uwi
       , wds.survey_id
       , '300IPL' as source
       , b.geog_coord_system_id
       , wds.survey_quality
       , wds.azimuth_north_type
       , b.location_qualifier
       , wds.active_ind
       , wds.uwi as ipl_uwi_local
       , row_number() over (partition by wds.uwi
                               order by decode(upper(wds.active_ind), 'Y', 1, 'N', 3, 2) asc
                                          , decode(upper(nvl(b.geog_coord_system_id, 'BAR')), 'WGS84', 1, 'NAD83', 2, 'NAD27', 3, 'BAR', 4, 5) asc
                                          --QC1820: modify location qualifier ordering to be consistent with well-node precedence (as defined by IHS, and implemented in the Gateway)
                                          , case
                                              when lq.node_lq_order is not null then to_char(lq.node_lq_order)
                                              else b.location_qualifier
                                            end asc
                                          --survey_quality: not used at ihs-canada like at TLM: G or null
                                          --at ihs, survey_id is all the same (001)
                          ) as dir_srvy_precedence
       , 'IHS_CANADA' as origin
  from --at IHS, only one header for each uwi-source-survey_id, even if multiple surveys (distinguished by coord sys and location qualifier)
       well_dir_srvy@c_talisman_ihsdata wds
       inner join
       (--get subset of data from station, in order to determine precedence
        select distinct
               wdss.uwi
               , wdss.source
               , wdss.survey_id
               , wdss.geog_coord_system_id
               , wdss.location_qualifier
               , active_ind
         --ihs canada
          from well_dir_srvy_station@c_talisman_ihsdata wdss
         where wdss.depth_obs_no = 1
       ) b on wds.uwi = b.uwi
              and wds.source = b.source
              and wds.survey_id = b.survey_id
       --join with WIM database, to match to TLM-id (use well_version)
       inner join ppdm.well_version w on wds.uwi = w.ipl_uwi_local
                                         and w.source = '300IPL'
                                         and w.active_ind = 'Y'
       --QC1820: modify location qualifier ordering to be consistent with well-node precedence (as defined by IHS, and implemented in the Gateway)
       left join wim.r_rollup_node_lq lq on b.location_qualifier = lq.location_qualifier
                                            and lq.country = '7CN'
                                            and nvl(w.province_state, 'FOO') = nvl(lq.province_state, 'BAR')
                                            and b.active_ind = 'Y'
                                            and lq.active_ind = 'Y'
 where wds.active_ind = 'Y'
       --ihs canada: only value is TRUE, for azimuth north type
       --and wds.azimuth_north_type = 'TRUE'

;

/


----comment
comment on materialized view ppdm.ihs_cdn_dir_srvy_quality_mv is 'snapshot of well directional survey precedence for IHS Canada dir srvys';

----indexes: created for future joins
create index ppdm.wdsq_ic_uwi_idx on ppdm.ihs_cdn_dir_srvy_quality_mv
(uwi)
;


----grants
----for general ppdm ro
grant select on ppdm.ihs_cdn_dir_srvy_quality_mv to ppdm_ro;
----for monitoring, mview-refresh
grant select on ppdm.ihs_cdn_dir_srvy_quality_mv to ppdm_admin;

