/***************************************************************************************************
 ihs_us_pden_vol_by_month  (view)

 20150813 script creation, adapted code by vrajpoot  (task 1164)
 20150903 cdong
          Changed to use well_inventory mview for ihs-us pden data. 
          Note: the ihs-pid view also references a well_inventory mview for the ihs-pid pden data.
 20150909 cdong
          Hard-code 'UNKNOWN' for x_strat_unit_id if null

          Run this script AFTER view ihs_pid_pden_vol_by_month has been created.

 **************************************************************************************************/

--drop view ppdm.ihs_us_pden_vol_by_month;


create or replace force view ppdm.ihs_us_pden_vol_by_month
(
  pden_id,
  pden_type,
  pden_source,
  volume_method,
  activity_type,
  product_type,
  year,
  amendment_seq_no,
  active_ind,
  amend_reason,
  apr_volume,
  apr_volume_qual,
  aug_volume,
  aug_volume_qual,
  cum_volume,
  dec_volume,
  dec_volume_qual,
  effective_date,
  expiry_date,
  feb_volume,
  feb_volume_qual,
  jan_volume,
  jan_volume_qual,
  jul_volume,
  jul_volume_qual,
  jun_volume,
  jun_volume_qual,
  mar_volume,
  mar_volume_qual,
  may_volume,
  may_volume_qual,
  nov_volume,
  nov_volume_qual,
  oct_volume,
  oct_volume_qual,
  posted_date,
  ppdm_guid,
  remark,
  sep_volume,
  sep_volume_qual,
  volume_end_date,
  volume_ouom,
  volume_quality_ouom,
  volume_start_date,
  volume_uom,
  ytd_volume,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state,
  pool_id,
  x_strat_unit_id,
  top_strat_age,
  base_strat_age,
  strat_name_set_id
)
as
   select pvbm.uwi                              as pden_id
          , pvbm.pden_type
          , pvbm.source                         as pden_source
          , pvbm.volume_method
          , pvbm.activity_type
          , pvbm.product_type
          , pvbm.year
          , pvbm.amendment_seq_no
          , pvbm.active_ind
          , cast (null as varchar2 (20))        as amend_reason         -- does not exist at source
          , pvbm.apr_volume
          , cast (null as number (7, 2))        as apr_volume_qual      -- does not exist at source
          , pvbm.aug_volume
          , cast (null as number (7, 2))        as aug_volume_qual      -- does not exist at source
          , pvbm.cum_volume
          , pvbm.dec_volume
          , cast (null as number (7, 2))        as dec_volume_qual      -- does not exist at source
          , cast (null as date)                 as effective_date       -- does not exist at source
          , cast (null as date)                 as expiry_date          -- does not exist at source
          , pvbm.feb_volume
          , cast (null as number (7, 2))        as feb_volume_qual      -- does not exist at source
          , pvbm.jan_volume
          , cast (null as number (7, 2))        as jan_volume_qual      -- does not exist at source
          , pvbm.jul_volume
          , cast (null as number (7, 2))        as jul_volume_qual      -- does not exist at source
          , pvbm.jun_volume
          , cast (null as number (7, 2))        as jun_volume_qual      -- does not exist at source
          , pvbm.mar_volume
          , cast (null as number (7, 2))        as mar_volume_qual      -- does not exist at source
          , pvbm.may_volume
          , cast (null as number (7, 2))        as may_volume_qual      -- does not exist at source
          , pvbm.nov_volume
          , cast (null as number (7, 2))        as nov_volume_qual      -- does not exist at source
          , pvbm.oct_volume
          , cast (null as number (7, 2))        as oct_volume_qual      -- does not exist at source
          , pvbm.posted_date
          , cast (null as varchar2 (38))        as ppdm_guid            -- does not exist at source
          , cast (null as varchar2 (2000))      as remark               -- does not exist at source
          , pvbm.sep_volume
          , cast (null as number (7, 2))        as sep_volume_qual      -- does not exist at source
          , cast (null as date)                 as volume_end_date      -- does not exist at source
          , cast (null as varchar2 (20))        as volume_ouom          -- does not exist at source
          , cast (null as varchar2 (20))        as volume_quality_ouom  -- does not exist at source
          , cast (null as date)                 as volume_start_date    -- does not exist at source
          , cast (null as varchar2 (20))        as volume_uom           -- does not exist at source
          , pvbm.ytd_volume
          , pvbm.row_changed_by
          , pvbm.row_changed_date
          , pvbm.row_created_by
          , pvbm.row_created_date
          , cast (null as varchar2 (20))     as row_quality          -- does not exist at source
          --IHS Extended Attributes
          , pvbm.province_state
          , pvbm.pool_id
          , nvl(pvbm.x_strat_unit_id, 'UNKNOWN')
          , pvbm.top_strat_age
          , pvbm.base_strat_age
          , pvbm.strat_name_set_id
     from well_inventory.ihs_us_pden_vol_by_month_mv pvbm
    where pvbm.pden_type = 'PDEN_WELL'

   ----get pden data from ihs us-pid database via another view
   union all

   select entity
          , pden_type
          , source
          , null as volume_method
          , null as activity_type
          , fluid
          , year
          , null as amendment_seq_no
          , active_ind
          , null as amend_reason
          , apr
          , null as apr_volume_qual
          , aug
          , null as aug_volume_qual
          , cum_prior
          , dec
          , null as dec_volume_qual
          , null as effective_date
          , null as expiry_date
          , feb
          , null as feb_volume_qual
          , jan
          , null as jan_volume_qual
          , jul
          , null as jul_volume_qual
          , jun
          , null as jun_volume_qual
          , mar
          , null as mar_volume_qual
          , may
          , null as may_volume_qual
          , nov
          , null as nov_volume_qual
          , oct
          , null as oct_volume_qual
          , null as posted_date
          , null as ppdm_guid
          , null as remark
          , sep
          , null as sep_volume_qual
          , null as volume_end_date
          , pi_volume_ouom
          , null as volume_quality_ouom
          , null as volume_start_date
          , pi_volume_unit
          , year_to_date
          , pi_user_id
          , pi_rec_upd_date
          , pi_user_id
          , pi_row_add_date
          , null as row_quality
          , null as province_state
          , null as pool_id
          , 'UNKNOWN' as x_strat_unit_id
          , null as top_strat_age
          , null as base_strat_age
          , null as strat_name_set_id
     from ihs_pid_pden_vol_by_month
;


grant select on ppdm.ihs_us_pden_vol_by_month to ppdm_ro;
