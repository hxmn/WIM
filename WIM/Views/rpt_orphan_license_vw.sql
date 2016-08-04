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

--drop view wim.rpt_orphan_license_vw ;


create or replace force view wim.rpt_orphan_license_vw
as
select uwi
       , source
       , license_num
       , license_id
       , active_ind
       , remark
       , row_created_by
       , row_created_date
       , row_changed_by
       , row_changed_date
  from ppdm.well_license
 where (uwi, source) in     (   select uwi, source
                                  from ppdm.well_license
                                minus
                                select uwi, source
                                  from ppdm.well_version
                            )
 order by uwi, source
;

/

grant select on wim.rpt_orphan_license_vw       to wim_ro ;
/
