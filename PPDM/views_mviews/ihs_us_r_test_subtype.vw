/*******************************************************************************************
 ihs_us_r_test_subtype  (view)

 20150812   cdong       task 1164 add ihs-us data to combo views

 *******************************************************************************************/

--drop view ppdm.ihs_us_r_test_subtype;


create or replace force view ppdm.ihs_us_r_test_subtype
(
   test_subtype,
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
   select tst.test_subtype,
          tst.abbreviation,
          tst.active_ind,
          tst.effective_date,
          tst.expiry_date,
          tst.long_name,
          tst.ppdm_guid,
          tst.remark,
          tst.short_name,
          tst.source,
          tst.row_changed_by,
          tst.row_changed_date,
          tst.row_created_by,
          tst.row_created_date,
          tst.row_quality
     from r_test_subtype@c_talisman_us_ihsdataq tst
;


grant select on ppdm.ihs_us_r_test_subtype to ppdm_ro;
