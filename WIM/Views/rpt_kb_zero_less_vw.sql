/**********************************************************************************************************************
 View to return wells with KB elevation equal-or-less-than zero.  This is unusual.
 The data steward(s) should review these wells and confirm their validity/relevance.

 Usage:
 This view will be used by the WIM Housekeeping procedure to track the number of wells with this particular condition.
 Additionaly, a summary of the data will be included in a BIRT report.

 Run this script in the WIM schema.

 History
  20150806 cdong    QC1686  Wells with KB Elev of zero or less
  20160316 cdong    QC1791  Allow filter by country/province-state
                            extra: add list of licenses for each well and iWIM hyperlink components.
                            This view is DEPENDENT on new view rpt_well_all_licenses_vw.
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by well-id (uwi).

 **********************************************************************************************************************/

--revoke select on wim.rpt_kb_zero_less_vw    from wim_ro ;
--drop view wim.rpt_kb_zero_less_vw ;

create or replace force view wim.rpt_kb_zero_less_vw
as
select w.uwi                                                as tlm_id
       , w.well_name
       , w.kb_elev
       , w.country
       , c.long_name                                        as country_name
       , w.province_state
       , wl.license_list
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || w.uwi       as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from ppdm.well w
       left join wim.rpt_well_all_licenses_vw wl on w.uwi = wl.uwi
       left join ppdm.r_country c on w.country = c.country
 where w.active_ind = 'Y'
       and nvl(w.kb_elev, 9999) <= 0
       ----QC1797 exclude specific records that have been checked----
       and w.uwi not in (select val_1
                           from wim.exclude_from_housekeeping
                          where lower(r_id) = '037'
                                and lower(attr_1) = 'uwi'
                                and active_ind = 'Y'
                        )
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.uwi

;


----the wim_ro role is granted to BIRT_APPL
grant select on wim.rpt_kb_zero_less_vw    to wim_ro ;


----select * from wim.rpt_kb_zero_less_vw  where province_state = 'AR';
