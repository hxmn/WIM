/*******************************************************************************************
 ihs_us_strat_name_set  (view)

 20150812   Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.ihs_us_strat_name_set;


create or replace force view ppdm.ihs_us_strat_name_set
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
     from strat_name_set@c_talisman_us_ihsdataq
;


grant select on ppdm.ihs_us_strat_name_set to ppdm_ro;
