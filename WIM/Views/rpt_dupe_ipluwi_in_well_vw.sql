/**********************************************************************************************************************
 View used to report on WIM wells with multiple UWIs (ipl_uwi_local) among
   its active well versions.

 Usage:
 This view will be used by the WIM Housekeeping procedure to track the number of wells with this particular condition.
 Additionaly, a summary of the data will be included in a BIRT report.

 Run this script in the WIM schema.

 History
  20150427  cdong   Initial creation   (TIS Task 1626)
  20151113  cdong   QC1742  Change query for wells with multiple ipl_uwi_local in well versions
                    Update view to consider formatting of UWI (ipl_uwi_local) for US wells to
                      look for distinct UWI. "having count(distinct f_ipl_uwi_local) > 1"
  20160316  cdong   QC1774 Add license numbers
                    This view could use the license-vw, but it return more licenses than desired.
                      So, using sub-select instead of license-view.
                    Note: there are wells where additional formatting of API (in 725TLI wv)
                      would drop the well out of this view.
                      e.g. well 300000113861, with API's 37123468000000 and US-37-123-00468-00
                           the difference is zeros at position 11 and 12 in the 725TLI API (...-004...)
                      e.g. well 1001415084, with API's 37123432900000 and US-37-123-04329-00
                           the difference is the zero at position 11 in the 725TLI API (...-04...)
                      Unfortunately, checking for these instances and formatting a second time causes more
                        problems than fixing-- i.e. adds other wells to the view
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by combination of uwi and ipl_uwi_local.
  20160615	cdong	QC1839 Modify view to account for NULL current_status

 **********************************************************************************************************************/

--revoke select on wim.rpt_dupe_ipluwi_in_well_vw    from wim_ro ;
--revoke select on wim.rpt_dupe_ipluwi_in_well_vw    from birt_appl ;
--revoke select on wim.rpt_dupe_ipluwi_in_well_vw    from ppdm_ro ;
--drop view wim.rpt_dupe_ipluwi_in_well_vw ;

create or replace view wim.rpt_dupe_ipluwi_in_well_vw
as
select w.uwi as tlm_id
       , w.ipl_uwi_local                                    as uwi
       , w.well_name
       , w.province_state
       , w.country
       , listagg(wv.ipl_uwi_local || ' [' || wv.source || ']', ', ')
             within group (order by wv.uwi, wv.source)      as uwi_list
       , wlcws.license_num                                  as cws_license
       , wlihsca.license_num                                as ihsca_license
       , wl.license_list
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || w.uwi       as iwimlink
       , (select SYS_CONTEXT ('USERENV','INSTANCE_NAME')    as instancename from dual) as env
  from (
        select distinct wv1.uwi, wv1.source
               , wv1.ipl_uwi_local
               --, wv2.uwi, wv2.source, wv2.ipl_uwi_local
          from ppdm.well_version wv1
               inner join ppdm.well_version wv2 on wv1.uwi = wv2.uwi
                                                   and (case when (wv1.country = '7US' and wv1.source in ('100TLM', '725TLI')) then
                                                                  wim.wim_util.format_us_api(wv1.ipl_uwi_local)
                                                             else wv1.ipl_uwi_local
                                                        end
                                                        <>
                                                        case when (wv2.country = '7US' and wv2.source in ('100TLM', '725TLI')) then
                                                                  wim.wim_util.format_us_api(wv2.ipl_uwi_local)
                                                             else wv2.ipl_uwi_local
                                                         end)
                                                   --and wv1.ipl_uwi_local <> wv2.ipl_uwi_local
                                                   and wv1.active_ind = wv2.active_ind
         where wv1.ipl_uwi_local is not null
               and wv2.ipl_uwi_local is not null
               and wv1.active_ind = 'Y'
               and not (wv1.source = '100TLM' and nvl(wv1.current_status, 'foo') = 'CANCEL')
               and not (wv2.source = '100TLM' and nvl(wv2.current_status, 'foo') = 'CANCEL')
               ----QC1797 exclude specific records that have been checked----
               and (wv1.uwi, wv1.ipl_uwi_local) not in (select val_1, val_2
                                                         from wim.exclude_from_housekeeping
                                                        where lower(r_id) in ('029', '030', '031', '032')
                                                              and lower(attr_1) = 'uwi'
                                                              and lower(attr_2) = 'ipl_uwi_local'
                                                              and active_ind = 'Y'
                                                       )
               ----testing
               --and wv1.uwi in ('146118', '147442', '148264', '148265', '148271', '97665' , '1001402240' , '123790' , '127998' , '107764' , '300000159231' , '145825' , '146125', '137139', '2000786661', '146455')
       ) wv
       inner join ppdm.well w on wv.uwi = w.uwi
       left join ppdm.well_license wlcws on w.uwi = wlcws.uwi and wlcws.active_ind = 'Y' and wlcws.source = '100TLM'
       left join ppdm.well_license wlihsca on w.uwi = wlihsca.uwi and wlihsca.active_ind = 'Y' and wlihsca.source = '300IPL'
       left join (  select uwi
                           , listagg (license_num || ' [' || source || ']', ', ')
                               within group (order by uwi, source)                   as license_list
                      from ppdm.well_license
                     where active_ind = 'Y'
                           and license_num is not null
                           and source not in ('100TLM', '300IPL')
                     group by uwi
                 )  wl on wv.uwi = wl.uwi
 group by w.uwi, w.ipl_uwi_local, w.well_name, w.province_state, w.country
          , wlcws.license_num, wlihsca.license_num, wl.license_list
 having count(distinct wv.ipl_uwi_local) > 1
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.uwi

;


----the wim_ro role is granted to BIRT_APPL
grant select on wim.rpt_dupe_ipluwi_in_well_vw  to wim_ro ;
--grant select on wim.rpt_dupe_ipluwi_in_well_vw  to birt_appl ;
--grant select on wim.rpt_dupe_ipluwi_in_well_vw  to ppdm_ro ;


----select * from wim.rpt_dupe_ipluwi_in_well_vw  where province_state = 'AB';

/* ---- considered this code, but it is slower. leaving in script for reference, as an alternate way to approach query
   ---- it takes about twice as long to return results as the other query (for approx 4,150+) records
select w.uwi as tlm_id
       , w.ipl_uwi_local                                    as uwi
       , w.well_name
       , w.province_state
       , w.country
       , listagg(wv.ipl_uwi_local || ' [' || wv.source || ']', ', ') within group (order by wv.uwi, wv.source) as uwi_list
       , wlcws.license_num                                  as cws_license
       , wlihsca.license_num                                as ihsca_license
       , wl.license_list
       , 'http://iwimca.na.tlm.com' as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com' as iwimprefix_naotest
       , '/Default.aspx?HiddenTLMIdsForWIM=' || w.uwi       as iwimlink
       , (select SYS_CONTEXT ('USERENV','INSTANCE_NAME')    as instancename from dual) as env
  from (select uwi, source, active_ind, current_status
               , case when (country = '7US' and source in ('100TLM', '725TLI')) then
                            wim.wim_util.format_us_api(ipl_uwi_local)
                      else ipl_uwi_local
                   end          as f_ipl_uwi_local
               , ipl_uwi_local
          from ppdm.well_version
       ) wv
       inner join ppdm.well w on wv.uwi = w.uwi
       left join ppdm.well_license wlcws on w.uwi = wlcws.uwi and wlcws.active_ind = 'Y' and wlcws.source = '100TLM'
       left join ppdm.well_license wlihsca on w.uwi = wlihsca.uwi and wlihsca.active_ind = 'Y' and wlihsca.source = '300IPL'
       left join rpt_well_all_licenses_vw wl on wv.uwi = wl.uwi
 where wv.active_ind = 'Y'
       and wv.ipl_uwi_local is not null
       ----ignoring any "cancelled" CWS wells
       and not (wv.source = '100TLM' and wv.current_status = 'CANCEL')
       ----testing
       --and upper(w.country) in ('7CN' , '7US' )
       --and upper(w.province_state) in ('AB')
       --and wv1.uwi in ( '97665' , '1001402240' , '123790' , '127998' , '107764' , '300000159231' , '145825' , '146125', '137139', '2000786661', '146455')
 group by w.uwi, w.ipl_uwi_local, w.well_name, w.province_state, w.country, wlcws.license_num, wlihsca.license_num, wl.license_list
 ----use of "having" basically checks if the well has more than one distinct uwi, even after reformatting the uwi
 having count(distinct wv.f_ipl_uwi_local) > 1
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.uwi
;
*/

