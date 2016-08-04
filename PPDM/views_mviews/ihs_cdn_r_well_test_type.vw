/*******************************************************************************************
  ihs_cdn_r_well_test_type  (view)

  20150818 copied from ihs_r_well_test_type  (task 1164)

 *******************************************************************************************/

--drop view ppdm.ihs_cdn_r_well_test_type;


create or replace force view ppdm.ihs_cdn_r_well_test_type
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
     from r_well_test_type@c_talisman_ihsdata wtt
;


grant select on ppdm.ihs_cdn_r_well_test_type to ppdm_ro;
