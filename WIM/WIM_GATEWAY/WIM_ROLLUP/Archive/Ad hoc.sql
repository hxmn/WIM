select node_id, source, node_position, geog_coord_system_id, location_qualifier, node_obs_no, latitude, longitude
  from ppdm.well_node_version
 where ipl_uwi = '100002'
   and source = '300IPL'
   and node_position = 'B'
order by geog_coord_system_id DESC, location_qualifier, node_obs_no desc;


select *
  from ppdm.well_node_version
 where ipl_uwi = '1000039681'
--   and source = '300IPL'
--   and node_position = 'B'
order by geog_coord_system_id, location_qualifier, node_obs_no desc;




select uwi from ppdm.well_version where surface_latitude is null;
-- 900010002

select ipl_uwi, source, count(1)
  from ppdm.well_node_version
group by ipl_uwi, source
having count(1) >2;

-- 1000026719 - 8 
-- 1000061437 - 5??
-- 1000000301 - 6


--100002, 1000039681, 100020, 1000080555
