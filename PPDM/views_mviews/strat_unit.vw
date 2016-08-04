/*******************************************************************************************
  STRAT_UNIT  (View)

  20150817  cdong   include IHS US data (tis task 1164)
  20150922  cdong   fix for DataFinder, which is now returning "duplicates" because
                    this combo view has the "same" strat data from IHS-Canada as IHS-US
                    (if you ignore the hardcoded "sources" of 300IPL and 450PID)

 *******************************************************************************************/

--drop view ppdm.strat_unit;


create or replace force view ppdm.strat_unit
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
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   x_strat_unit_id_num,
   base_strat_age,
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
          source,
          strat_interpret_method,
          strat_status,
          strat_type,
          strat_unit_type,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --  IHS Extensions
          null as x_strat_unit_id_num,
          null as base_strat_age,
          null as x_lithology,
          null as x_resource
     from tlm_strat_unit
   union-- all
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
          source,
          strat_interpret_method,
          strat_status,
          strat_type,
          strat_unit_type,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --  IHS Extensions
          x_strat_unit_id_num,
          base_strat_age,
          x_lithology,
          x_resource
     from ihs_cdn_strat_unit
--   union all
--   select strat_name_set_id,
--          strat_unit_id,
--          abbreviation,
--          active_ind,
--          area_id,
--          area_type,
--          business_associate,
--          confidence_id,
--          current_status_date,
--          description,
--          effective_date,
--          expiry_date,
--          fault_type,
--          form_code,
--          group_code,
--          long_name,
--          ordinal_age_code,
--          ppdm_guid,
--          preferred_ind,
--          remark,
--          short_name,
--          source,
--          strat_interpret_method,
--          strat_status,
--          strat_type,
--          strat_unit_type,
--          row_changed_by,
--          row_changed_date,
--          row_created_by,
--          row_created_date,
--          row_quality,
--          x_strat_unit_id_num,
--          base_strat_age,
--          x_lithology,
--          x_resource
--     from ihs_us_strat_unit
;


grant select         on ppdm.strat_unit to ppdm_ro;
grant select         on ppdm.strat_unit to wim_ro;
grant select, insert on ppdm.strat_unit to datman_geo_admin;


--create or replace synonym data_finder.strat_unit for ppdm.strat_unit;
--create or replace synonym dm_appl.strat_unit for ppdm.strat_unit;
--create or replace synonym geoframe_appl.strat_unit for ppdm.strat_unit;
--create or replace synonym geowiz_appl.strat_unit for ppdm.strat_unit;
--create or replace synonym iwim_appl.strat_unit for ppdm.strat_unit;
--create or replace synonym ppdm.stu for ppdm.strat_unit;
--create or replace synonym spatial_appl.strat_unit for ppdm.strat_unit;

