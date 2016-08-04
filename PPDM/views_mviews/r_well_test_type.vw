/*******************************************************************************************
  R_WELL_TEST_TYPE  (View)

  20150818  cdong   include IHS US data (tis task 1164)
                    use 'union' instead of 'union all' to remove duplicates for reference data

 *******************************************************************************************/

--drop view ppdm.r_well_test_type;


create or replace force view ppdm.r_well_test_type
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
   select well_test_type,
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
     from tlm_r_well_test_type
   union
   select well_test_type,
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
     from ihs_cdn_r_well_test_type
   union
   select well_test_type,
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
     from ihs_us_r_well_test_type
;



grant select on ppdm.r_well_test_type to ppdm_ro;


--create or replace synonym data_finder.r_well_test_type for ppdm.r_well_test_type;
--create or replace synonym ppdm.r_wtt for ppdm.r_well_test_type;
