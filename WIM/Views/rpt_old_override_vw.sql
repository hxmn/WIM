/**********************************************************************************************************************
 View to return TLM Override well versions that are older than a specified period of time (365 days).
 The data steward(s) should review these versions and confirm their validity/relevance.

 Usage:
 This view will be used by the WIM Housekeeping procedure to track the number of wells with this particular condition.
 Additionaly, a summary of the data will be included in a BIRT report.

 Run this script in the WIM schema.

 History
  20160120 cdong    QC1758
  20160316 cdong    QC1792  Allow filter by country/province-state
                    Changed code to get province from composite well, not well version (where it is usually missing)

 **********************************************************************************************************************/

--revoke select on wim.rpt_old_override_vw    from wim_ro ;
--drop view wim.rpt_old_override_vw ;

create or replace force view wim.rpt_old_override_vw
as
select wv.uwi
       , wv.ipl_uwi_local
       , wv.well_name
       , wv.country
       , c.long_name                                        as country_name
       , w.province_state
       , wv.remark
       , wv.surface_latitude
       , wv.surface_longitude
       , wv.bottom_hole_latitude
       , wv.bottom_hole_longitude
       , wv.kb_elev
       , wv.ground_elev
       , wv.row_created_date
       , wv.row_created_by
       , wv.row_changed_date
       , wv.row_changed_by
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || wv.uwi      as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from ppdm.well_version wv
       inner join ppdm.well w on wv.uwi = w.uwi
       left join ppdm.r_country c on wv.country = c.country
 where wv.source = '075TLMO'
       and wv.active_ind = 'Y'
       and nvl(wv.row_changed_date, wv.row_created_date) < sysdate - 365
 order by case when wv.country = '7CN' then '01' when wv.country = '7US' then '02' else '03' || wv.country end
          , province_state, uwi

;

----the wim_ro role is granted to BIRT_APPL
grant select on wim.rpt_old_override_vw    to wim_ro ;


----select * from rpt_old_override_vw  where province_state = 'AB';
