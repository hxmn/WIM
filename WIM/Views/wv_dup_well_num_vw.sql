/**********************************************************************************************************************
 View - list of Well-Num associated to more than one well.
 A well can have multiple well versions. Each version can have its own well-num, which may be the same as the well-num of a version from another well.

 History
  20160315 cdong  Documenting code in PETPROD, to ensure a create-script exists in source-control system Vault.
                  This view is used by the WIM Housekeeping procedure.

 **********************************************************************************************************************/

drop view wv_dup_well_num_vw;


create or replace force view wv_dup_well_num_vw
as
  select w1.well_num
         , wm_concat (distinct w1.uwi)              as uwi
    from ppdm.well_version w1, ppdm.well_version w2
   where w1.well_num = w2.well_num
         and w1.source = w2.source
         and w1.uwi != w2.uwi
         and w1.active_ind = 'Y'
         and w2.active_ind = 'Y'
   group by w1.well_num
;
