/**********************************************************************************************************************
 Each well in Canada and USA should have NAD27 location information. 
 There is a regular process that will create NAD27 coordinates (node-versions) for each well in Canada and the US.
 The NAD27-generation process changed (2016-Apr).  The override well version is no longer used.
   The NAD83 node version that would roll-up to the composite well is identified.  This node-version is used to compute
   the nad27 location. 
   The new nad27 node-version shares the same source and node_obs_no. The location qualifier is a concatenation 
   of 'zTIS' and the nad83-source's location qualifier.
 
 This view returns a list of well-nodes where the generated NAD27 location information requires updating due to some 
   location change in a node-version record.
   e.g. the nad83 upon which the generated nad27 is based has changed
   e.g. a higher-precedence nad83 node-version has been added for the well, thereby affecting the location information

 The view is used by the NAD27-generation process and WIM Housekeeping.

 History
  20160426  cdong   QC1806  
    Replace the hard-coded query in WIM Housekeeping with a view that can be used by the NAD27-generation process and
      the WIM Housekeeping.
    Note: this view is incomplete. However, as-is, it provides a good base from which to start. View will be updated later.
  20160504  cdong   changed syntax, query should be a little faster now, and look better in an explain-plan
  20160601  cdong   Kevin removed this view. It has been replaced with a modified view wim.wim_nad27_conv_stage_vw,
                     as part of the WIM-NAD27 process.

 **********************************************************************************************************************/

revoke select on wim.wim_nad27_conv_stage_updt_vw from wim_ro ;
drop view wim.wim_nad27_conv_stage_updt_vw ;

--create or replace force view wim.wim_nad27_conv_stage_updt_vw
--as
--select wnv.node_id
--       , wnv.source
--       , wnv.node_obs_no
--       , wnv.location_qualifier
--       , wnv.geog_coord_system_id
--       , wnv.row_changed_date
--       , wnv.row_created_date
--       , wnv.ipl_uwi
--       , wnv.province_state
--       , z.row_created_date             as nad27_row_created_date
--       , z.remark                       as nad27_remark
--  from ppdm.well_node_version wnv
--       inner join ppdm.well_node_version z
--                  on wnv.node_id = z.node_id
--                         and wnv.source = z.source
--                         and wnv.node_obs_no = z.node_obs_no
--                         and wnv.location_qualifier = substr(z.location_qualifier, 6)
--                         and nvl(wnv.row_changed_date, wnv.row_created_date) > z.row_created_date 
-- where upper(z.location_qualifier) like 'ZTIS:%' and upper(z.row_created_by) = 'WIM_NAD27'
--       and z.geog_coord_system_id = '4267'
--       and z.active_ind = 'Y'
--       and z.country in ('7CN', '7US')
--       and wnv.geog_coord_system_id <> '4267'
--       
--;


--grant select on wim.wim_nad27_conv_stage_updt_vw to wim_ro ;

----select *  from  wim_nad27_conv_stage_updt_vw ;