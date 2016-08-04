/*******************************************************************************************
 ihs_us_r_well_test_type  (view)

 20150812   cdong       task 1164 add ihs-us data to combo views

 *******************************************************************************************/

--drop view ppdm.ihs_us_r_well_test_type;


create or replace force view ppdm.ihs_us_r_well_test_type
(
   well_test_type,
   abbreviation,
   active_ind,
   effective_date,
   expiry_date,
   long_name,
   ppdm_guid,
   remark,
   short_name,
   source,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality
)
as
   select wtt.well_test_type,
          wtt.abbreviation,
          wtt.active_ind,
          wtt.effective_date,
          wtt.expiry_date,
          wtt.long_name,
          wtt.ppdm_guid,
          wtt.remark,
          wtt.short_name,
          wtt.source,
          wtt.row_changed_by,
          wtt.row_changed_date,
          wtt.row_created_by,
          wtt.row_created_date,
          wtt.row_quality
     from r_well_test_type@c_talisman_us_ihsdataq wtt
;


grant select on ppdm.ihs_us_r_well_test_type to ppdm_ro;
