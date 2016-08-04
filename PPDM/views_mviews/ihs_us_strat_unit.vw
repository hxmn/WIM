/*******************************************************************************************
 ihs_us_STRAT_UNIT  (View)

 20150812   Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.ihs_us_strat_unit;


create or replace force view ppdm.ihs_us_strat_unit
(
   strat_name_set_id,
   strat_unit_id,
   abbreviation,
   active_ind,
   area_id,
   area_type,
   business_associate,
   confidence_id,
   current_status_date,
   description,
   effective_date,
   expiry_date,
   fault_type,
   form_code,
   group_code,
   long_name,
   ordinal_age_code,
   ppdm_guid,
   preferred_ind,
   remark,
   short_name,
   source,
   strat_interpret_method,
   strat_status,
   strat_type,
   strat_unit_type,
   x_strat_unit_id_num,
   base_strat_age,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   x_lithology,
   x_resource
)
as
   select strat_name_set_id,
          strat_unit_id,
          abbreviation,
          active_ind,
          area_id,
          area_type,
          business_associate,
          confidence_id,
          current_status_date,
          description,
          effective_date,
          expiry_date,
          fault_type,
          form_code,
          group_code,
          long_name,
          ordinal_age_code,
          ppdm_guid,
          preferred_ind,
          remark,
          short_name,
          '450PID' as source,
          strat_interpret_method,
          strat_status,
          strat_type,
          strat_unit_type,
          x_strat_unit_id_num,
          base_strat_age,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          x_lithology,
          x_resource
     from strat_unit@c_talisman_us_ihsdataq
    where strat_name_set_id <> 'V80C'
;


grant select on ppdm.ihs_us_strat_unit to ppdm_ro;
