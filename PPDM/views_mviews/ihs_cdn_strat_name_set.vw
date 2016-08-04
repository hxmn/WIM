/*******************************************************************************************
 IHS_CDN_STRAT_NAME_SET  (View)

 20150817 copied from ihs_strat_name_set, adapted code by vrajpoot  (task 1164)

 *******************************************************************************************/

--drop view PPDM.IHS_CDN_STRAT_NAME_SET;


create or replace force view ppdm.ihs_cdn_strat_name_set
(
   strat_name_set_id,
   active_ind,
   area_id,
   area_type,
   business_associate,
   certified_ind,
   effective_date,
   expiry_date,
   ppdm_guid,
   preferred_ind,
   remark,
   source,
   strat_name_set_name,
   strat_name_set_type,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality
)
as
   select strat_name_set_id,
          active_ind,
          area_id,
          area_type,
          business_associate,
          certified_ind,
          effective_date,
          expiry_date,
          ppdm_guid,
          preferred_ind,
          remark,
          source,
          strat_name_set_name,
          strat_name_set_type,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality
     from strat_name_set@c_talisman_ihsdata
;


grant select on ppdm.ihs_cdn_strat_name_set to ppdm_ro;
