create or replace force view wim.wim_nad27_conv_stage_vw
as
select wn.ipl_uwi, wn.node_id, wn.source, wn.geog_coord_system_id, wn.location_qualifier, wn.node_obs_no, wn.node_position, wn.country, wn.province_state
    , wn.latitude, wn.longitude
    , '4267' as target_geog_coord_system_id, wn.row_changed_by, wn.row_changed_date, wn.row_created_date, wn.remark
    , 'NEW' as nad_type
from ppdm.well w
join ppdm.well_node wn on (
    (w.base_node_id = wn.node_id or w.surface_node_id = wn.node_id)
    and nvl(wn.geog_coord_system_id, '9999') not in ('4267', '9999')
)
where w.country in ('7CN', '7US')
union
select wnv.ipl_uwi, wnv.node_id, wnv.source, wnv.geog_coord_system_id, wnv.location_qualifier, wnv.node_obs_no, wnv.node_position, wnv.country, wnv.province_state
    , wnv_source.latitude, wnv_source.longitude
    , '4267' as target_geog_coord_system_id, wnv.row_changed_by, wnv.row_changed_date, wnv.row_created_date
    , wnv.remark, 'DATE CHANGE' as nad_type
from ppdm.well_node_version wnv
join ppdm.well_node_version wnv_source on wnv_source.node_id = wnv.node_id and wnv_source.source = wnv.source and wnv_source.geog_coord_system_id <> '4267'
    and wnv_source.location_qualifier = wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier) and wnv_source.node_obs_no = wnv.node_obs_no
    and wnv_source.row_changed_date > wnv.row_created_date
where wnv.location_qualifier like 'zTIS:%'
    and wnv.country in ('7US', '7CN')
    and wnv.active_ind = 'Y'
union
select wnv.ipl_uwi, wnv.node_id, wnv.source, wnv.geog_coord_system_id, wnv.location_qualifier, wnv.node_obs_no, wnv.node_position, wnv.country, wnv.province_state
    , wnv_source.latitude, wnv_source.longitude
    , '4267' as target_geog_coord_system_id, wnv.row_changed_by, wnv.row_changed_date, wnv.row_created_date, wnv.remark
    , 'LOCATION QUALIFIER CHANGE' as nad_type
from ppdm.well_node_version wnv
join r_rollup_node_lq lq on wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier) = lq.location_qualifier and wnv.province_state = lq.province_state and wnv.country = lq.country and wnv.active_ind = lq.active_ind
join ppdm.well_node_version wnv_source on wnv_source.node_id = wnv.node_id and wnv_source.source = wnv.source and wnv_source.geog_coord_system_id <> '4267'
    and wnv_source.location_qualifier <> wim.nad27_generator.get_ztis_lq_ref(wnv.location_qualifier) and wnv_source.node_obs_no = wnv.node_obs_no
join r_rollup_node_lq source_lq on wim.nad27_generator.get_ztis_lq_ref(wnv_source.location_qualifier) = source_lq.location_qualifier and wnv_source.province_state = source_lq.province_state and wnv_source.country = source_lq.country and wnv.active_ind = source_lq.active_ind
where wnv.location_qualifier like 'zTIS:%'
    and wnv.country in ('7US', '7CN')
    and wnv.active_ind = 'Y'
    and lq.node_lq_order > source_lq.node_lq_order
;

grant select on wim.wim_nad27_conv_stage_vw to wim_ro;
grant select on wim.wim_nad27_conv_stage_vw to fme;