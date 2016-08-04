/*******************************************************************************************
  STRAT_NAME_SET  (View)

  20150817  cdong   include IHS US data (tis task 1164)
                    use 'union' to remove duplicates

  *******************************************************************************************/

--drop view PPDM.STRAT_NAME_SET;


create or replace force view ppdm.strat_name_set
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
     from tlm_strat_name_set
   union
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
     from ihs_cdn_strat_name_set
   union
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
     from ihs_us_strat_name_set
;


grant select on ppdm.strat_name_set to ppdm_ro;


--create or replace synonym data_finder.strat_name_set for ppdm.strat_name_set;
--create or replace synonym ppdm.stns for ppdm.strat_name_set;
