--  Roll up tests

-- Tests
--             1) Removed 075 caveat which stopped it rolling up the 075 in the source attribute 
--                075 only Well : 1001456409
--                075 plus other versions : 1000000625
--             2) Removed references to the test VALIDATOR function as the Gateway will validate now before roll up
--             3) Switched to use common TLM_PROCESS_LOG package
--             4) Removed redundant error_count variables
--             5) Removed COMMIT to allow caller to determine success of overall transaction
--             6) Stopped Nodes rolling up when inactive
--                  Active Inactive Mix : 1000000005
--                  All Inactive :  21000000063
--             7) Node roll up assumes IPL_UWI attribute is filled correctly - which it should be from now on 
--             8) Nodes now roll up the EARLIEST create date and the LATEST update date - ignoring precedence
--                 Dual source, B and S nodes, lower source is latest : 1000000043
--             9) Same approach to create date/update date applied to WELL roll for consistency & speed
--             10) Added the update to WELL_VERSION of lat/long information when nodes rolled up
--                  Multiple node records : 1000026719, 1000061437, 1000000301
--                  Multiple node records / source: 100002, 1000039681, 100020, 1000080555
--                  No Node records :  900010002
--             11) Remove Well and Well_Node record if no underlying version records exist
--             12) Remove Option to call WELL and NODE rollup separately - now only whole well or source rollups
--             13) Renamed to WIM_Rollup package and renamed procedures to clean up terminology
--             14) Added Version Function

--  Pre-roll up
select WIM_Rollup.Version from dual;


-- WELL_NODE_VERSION
select rowid, node_id, active_ind, source, node_position, latitude, longitude, geog_coord_system_id, location_qualifier, node_obs_no, ipl_uwi
 from ppdm.well_node_version wnv where ipl_uwi = '100002' or ipl_uwi = 'X' order by node_id, source, geog_coord_system_id desc, location_qualifier, node_obs_no desc;

-- WELL_NODES
select ACTIVE_IND, node_id, source, node_position, latitude, longitude, geog_coord_system_id, ipl_uwi
 from ppdm.well_node wn where ipl_uwi = '100002';
 
-- WELL_VERSION
select rowid, uwi, active_ind, source, base_node_id, bottom_hole_latitude, bottom_hole_longitude, surface_node_id, surface_latitude, surface_longitude
 from ppdm.well_version wv where uwi = '100002';

-- WELL
select rowid, uwi, ACTIVE_IND, primary_source, base_node_id, bottom_hole_latitude, bottom_hole_longitude, surface_node_id, surface_latitude, surface_longitude
 from ppdm.well where uwi = '100002';
 
--  Roll up
exec wim.wim_rollup.well_rollup('100002');

--  Post roll up
-- Re-run above checks

--  Check log
select * from ppdm.tlm_process_log where row_created_on > sysdate - 1 order by row_created_on desc;  



--  Reset
rollback;


--  SOURCE LEVEL TEST:
exec wim.wim_rollup.SOURCE_rollup('850TLML');





-- Check surface nodes mismatches
select w.uwi, w.primary_source, w.well_name, surface_latitude, surface_longitude, latitude, longitude
  from ppdm.well w, ppdm.well_node wn
 where w.surface_node_id = wn.node_id
   and w.primary_source = wn.source
   and (surface_latitude != latitude
        or surface_longitude != longitude)
order by uwi;

select count(uwi)
from ppdm.well_version
where base_node_id = surface_node_id;

SELECT ROWID, WV.* FROM PPDM.WELL_VERSION WV WHERE UWI = '1001456409';
