/**********************************************************************************************************************
 View - list of IPL_UWI_LOCAL (UWI) (regulatory authority / government well ID) associated to more than one well.
 A well can have multiple well versions. Each version can have its own UWI, which may be the same as the UWI 
   of a version from another well.

 Usage:
 This view will be used by the WIM Housekeeping procedure.

 Run this script in the WIM schema.

 History
  20160315  cdong   Documenting code in PETPROD, to ensure a create-script exists in source-control system Vault.
                    This view is used by the WIM Housekeeping procedure.
  20160315  cdong   QC1790 Allow filter by country/province-state
                    Modified query so that list of wells removes duplicate TLM Well ID's.
                      Use sub-select and distinct to address multiple well versions with same ipl_uwi_local for the same well.
                      Otherwise, the combination of uwi-ipl_uwi_local may appear more than once  
                      (bc multi wv for a well has same ipl_uwi_local)
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by combination of uwi and ipl_uwi_local.

 **********************************************************************************************************************/

--revoke select on wim.wv_dup_local_uwi_vw  from wim_ro;
--drop view wim.wv_dup_local_uwi_vw;

create or replace force view wim.wv_dup_local_uwi_vw
as
select t.ipl_uwi_local
       , listagg(t.uwi, ', ') within group (order by t.uwi)             as well_list
       , listagg(t.country_prov, ', ') within group (order by t.uwi)    as country_prov
       , 'http://iwimca.na.tlm.com'                                     as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                                    as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                                   as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM='
         || listagg(t.uwi, ',') within group (order by t.uwi)           as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from (select distinct w1.ipl_uwi_local
               , w.uwi
               , w.country || case when w.province_state is null then '' else ' (' || w.province_state || ')' end as country_prov
          from ppdm.well_version w1, ppdm.well_version w2, ppdm.well w
         where w1.ipl_uwi_local = w2.ipl_uwi_local
               and w1.uwi != w2.uwi
               and w1.active_ind = 'Y'
               and w2.active_ind = 'Y'
               and w1.uwi = w.uwi 
               ----QC1797 exclude specific records that have been checked----
               and (w1.uwi, w1.ipl_uwi_local) not in (select val_1, val_2
                                                      from wim.exclude_from_housekeeping
                                                     where lower(r_id) = '002'
                                                           and lower(attr_1) = 'uwi'
                                                           and lower(attr_2) = 'ipl_uwi_local'
                                                           and active_ind = 'Y'
                                                   )
       ) t
 group by t.ipl_uwi_local
 having count(distinct t.uwi) > 1 
;


----the wim_ro role is granted to BIRT_APPL
grant select on wim.wv_dup_local_uwi_vw    to wim_ro ;


----select * from wim.wv_dup_local_uwi_vw where country_prov like '%AB%';


/* ---- considered this code, but it is slower. leaving in script for reference, as an alternate way to approach query

select t.ipl_uwi_local
       , listagg (t.uwi, ' , ')
                within group (order by t.uwi)                                   as uwi
       , listagg (t.country
                    || case when t.province_state is null then ''
                            else ' (' || t.province_state || ')'
                         end, ' , ')
                within group (order by t.uwi)                                   as country_prov_list
  from (select distinct
               wv.uwi, wv.ipl_uwi_local
               , w.province_state
               , w.country
          from ppdm.well_version wv
               inner join ppdm.well w on wv.uwi = w.uwi
         where wv.active_ind = 'Y'
               and wv.ipl_uwi_local is not null
               ----testing
               --and wv.ipl_uwi_local in ('100021608019W600', '102121808325W600', '102151708120W600', '103042804202W400')
       ) t
 group by t.ipl_uwi_local
 having count(distinct t.uwi) > 1
;

*/
