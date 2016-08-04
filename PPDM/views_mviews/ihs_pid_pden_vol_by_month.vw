/***************************************************************************************************
 ihs_pid_pden_vol_by_month  (view)

 20150813 script creation, adapted code by vrajpoot  (task 1164)
          did not include the hint use_nl, used in the ihs canadian pden, as it seems faster without 
 20150903 cdong
          Modified view to use well_inventory materialized view, as data at IHS is refreshed once-a-week
            and we are getting the data anyways, as part of the well inventory job.  
            This change will "save" the view from having to use a db-link to IHS.

 **************************************************************************************************/

--drop view ppdm.ihs_pid_pden_vol_by_month;


create or replace force view ppdm.ihs_pid_pden_vol_by_month
(
   entity,
   pden_type,
   source,
   active_ind,
   fluid,
   year,
   cum_prior,
   jan,
   feb,
   mar,
   apr,
   may,
   jun,
   jul,
   aug,
   sep,
   oct,
   nov,
   dec,
   year_to_date,
   pi_volume_unit,
   pi_volume_ouom,
   row_changed_by,
   pi_rec_upd_date,
   pi_user_id,
   pi_row_add_date
)
as
   select pmp.uwi as entity,
          'PDEN_WELL'                   as pden_type,
          pmp.source                    as source,
          'Y'                           as active_ind,
          --pmp.prod_zone,
          pmp.fluid,
          pmp.year,
          pmp.cum_prior,
          pmp.jan,
          pmp.feb,
          pmp.mar,
          pmp.apr,
          pmp.may,
          pmp.jun,
          pmp.jul,
          pmp.aug,
          pmp.sep,
          pmp.oct,
          pmp.nov,
          pmp.dec,
          pmp.year_to_date,
          pmp.pi_volume_unit,
          pmp.pi_volume_ouom,
          pmp.pi_user_id,
          pmp.pi_rec_upd_date,
          pmp.pi_user_id,
          pmp.pi_row_add_date
     from well_inventory.ihs_pid_pden_vol_by_month_mv pmp
    where pmp.entity_type = 'WELL'
;


grant select on ppdm.ihs_pid_pden_vol_by_month to ppdm_ro;
