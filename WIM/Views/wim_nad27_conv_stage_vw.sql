/**********************************************************************************************************************
 Each well in Canada and USA should have NAD27 location information.
 This view will return a list of wells where the composite (rolled-up) location information is NOT NAD27.

 The view is used by the NAD27-generation process:  WIM.NAD27_GENERATOR package
 Additionally, it is referenced by the WIM Housekeeping process:  WIM.WIM_HOUSEKEEPING procedure

 History
  20160426  cdong   Originally created by Kevin Edwards. Adding script to Vault.
  20160601  cdong   Updated script to reflect the version currently in PETPROD.WIM, for the WIM-NAD27 conversion process.
                    View updated by Kevin Edwards, to capture the following scenarios where a nad27 location conversion is required
                     - well without any nad27
                     - well with generated-nad27
                       - the date of the original well node version, upon which the generated-nad27 was created, has since changed
                       - there is a new well node version with higher precedence location qualifier,
                           for the same source (e.g. 300IPL) as the original node version upon which the gen-nad27 was created

 **********************************************************************************************************************/

----revoke select on wim.wim_nad27_conv_stage_vw from wim_ro ;
----drop view wim.wim_nad27_conv_stage_vw ;

create or replace force view wim_nad27_conv_stage_vw
(
    ipl_uwi
  , node_id
  , source
  , geog_coord_system_id
  , location_qualifier
  , node_obs_no
  , node_position
  , country
  , province_state
  , latitude
  , longitude
  , target_geog_coord_system_id
  , row_changed_by
  , row_changed_date
  , row_created_date
  , remark
  , nad_type
)
as
   select wn.ipl_uwi
          , wn.node_id
          , wn.source
          , wn.geog_coord_system_id
          , wn.location_qualifier
          , wn.node_obs_no
          , wn.node_position
          , wn.country
          , wn.province_state
          , wn.latitude
          , wn.longitude
          , '4267' as target_geog_coord_system_id
          , wn.row_changed_by
          , wn.row_changed_date
          , wn.row_created_date
          , wn.remark
          , 'NEW' as nad_type
     from ppdm.well w
          join ppdm.well_node wn
             on (    (   w.base_node_id = wn.node_id
                      or w.surface_node_id = wn.node_id)
                 and nvl (wn.geog_coord_system_id, '9999') not in ('4267', '9999')
                )
    where w.country in ('7CN', '7US')
   union
   select wnv.ipl_uwi
          , wnv.node_id
          , wnv.source
          , wnv.geog_coord_system_id
          , wnv.location_qualifier
          , wnv.node_obs_no
          , wnv.node_position
          , wnv.country
          , wnv.province_state
          , wnv_source.latitude
          , wnv_source.longitude
          , '4267' as target_geog_coord_system_id
          , wnv.row_changed_by
          , wnv.row_changed_date
          , wnv.row_created_date
          , wnv.remark
          , 'DATE CHANGE' as nad_type
     from ppdm.well_node_version wnv
          join ppdm.well_node_version wnv_source
             on     wnv_source.node_id = wnv.node_id
                and wnv_source.source = wnv.source
                and wnv_source.geog_coord_system_id <> '4267'
                and wnv_source.location_qualifier = wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier)
                and wnv_source.node_obs_no = wnv.node_obs_no
                and wnv_source.row_changed_date > wnv.row_created_date
    where     wnv.location_qualifier like 'zTIS:%'
          and wnv.country in ('7US', '7CN')
          and wnv.active_ind = 'Y'
   union
   select wnv.ipl_uwi
          , wnv.node_id
          , wnv.source
          , wnv.geog_coord_system_id
          , wnv.location_qualifier
          , wnv.node_obs_no
          , wnv.node_position
          , wnv.country
          , wnv.province_state
          , wnv_source.latitude
          , wnv_source.longitude
          , '4267' as target_geog_coord_system_id
          , wnv.row_changed_by
          , wnv.row_changed_date
          , wnv.row_created_date
          , wnv.remark
          , 'LOCATION QUALIFIER CHANGE' as nad_type
     from ppdm.well_node_version wnv
          join r_rollup_node_lq lq
             on     wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier) = lq.location_qualifier
                and wnv.province_state = lq.province_state
                and wnv.country = lq.country
                and wnv.active_ind = lq.active_ind
          join ppdm.well_node_version wnv_source
             on     wnv_source.node_id = wnv.node_id
                and wnv_source.source = wnv.source
                and wnv_source.geog_coord_system_id <> '4267'
                and wnv_source.location_qualifier <> wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier)
                and wnv_source.node_obs_no = wnv.node_obs_no
          join r_rollup_node_lq source_lq
             on     wim.nad27_generator.get_ztis_lq_ref(wnv_source.location_qualifier) = source_lq.location_qualifier
                and wnv_source.province_state = source_lq.province_state
                and wnv_source.country = source_lq.country
                and wnv.active_ind = source_lq.active_ind
    where     wnv.location_qualifier like 'zTIS:%'
          and wnv.country in ('7US', '7CN')
          and wnv.active_ind = 'Y'
          and lq.node_lq_order > source_lq.node_lq_order

;


grant select on wim.wim_nad27_conv_stage_vw to wim_ro ;

----the following grant is required for the FME process to identify the node version records that require
----  the generation of nad27 latitude and longitude
grant select on wim.wim_nad27_conv_stage_vw to fme ;