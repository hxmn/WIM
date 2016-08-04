/**********************************************************************************************************************
  View returning well data to be removed as part of regular data clean-up / database maintenance.

  The key record for a well is the well_version record. The WIM rollup is based on an active well_version record.
  Well license, node/node-version, status, and well-area are all dependent on the well_version record.
  So, when the well_version record is inactive or does not exist (for a specific combination of uwi and source),
    the dependent data should also be inactive or be removed (not exist).

  The views are used by WIM Housekeeping, as part of Report Items 019 and 045.

  History
    20160420    cdong   QC1810 Housekeeping data clean-up of "orphaned" well data (node, license, status, area)

 **********************************************************************************************************************/

--drop view wim.rpt_orphan_wnv_vw ;


create or replace force view wim.rpt_orphan_wnv_vw
as
select ipl_uwi as uwi
       , source
       , node_id
       , node_obs_no
       , geog_coord_system_id
       , location_qualifier
       , active_ind
       , node_position
       , remark
       , row_created_by
       , row_created_date
       , row_changed_by
       , row_changed_date
  from ppdm.well_node_version
 where (ipl_uwi, source) in (   select ipl_uwi, source
                                  from ppdm.well_node_version
                                minus
                                select uwi, source
                                  from ppdm.well_version
                            )
 order by ipl_uwi, node_id, source
;

/

grant select on wim.rpt_orphan_wnv_vw           to wim_ro ;
/
