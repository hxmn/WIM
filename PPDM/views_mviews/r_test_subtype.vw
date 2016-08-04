/*******************************************************************************************
  R_TEST_SUBTYPE  (View)

  20150818  cdong   include IHS US data (tis task 1164)

 *******************************************************************************************/

--drop view ppdm.r_test_subtype;


create or replace force view ppdm.r_test_subtype
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
   select test_subtype,
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
     from tlm_r_test_subtype
   union
   select test_subtype,
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
     from ihs_cdn_r_test_subtype
   union
   select test_subtype,
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
     from ihs_us_r_test_subtype
;


grant select on ppdm.r_test_subtype to ppdm_ro;


--create or replace synonym data_finder.r_test_subtype for ppdm.r_test_subtype;
--create or replace synonym ppdm.r_ts for ppdm.r_test_subtype;
