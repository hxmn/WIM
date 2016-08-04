/**********************************************************************************************************************
 View to return wells where the KB elevation is equivalent to the Ground elevation.
 Wells should not have the same KB and ground elevation.

 Usage:
 This view will be used by the WIM Housekeeping procedure to track the number of wells with this particular condition.
 Additionaly, a summary of the data will be included in a BIRT report.

 Run this script in the WIM schema.

 History
  20160120 cdong    QC1760
  20160316 cdong    QC1793  Allow filter by country/province-state
                    extra: add list of licenses for each well and iWIM hyperlink components.
                    This view is DEPENDENT on new view rpt_well_all_licenses_vw.
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by well-id (uwi).

 **********************************************************************************************************************/

--revoke select on wim.rpt_dupe_kb_ground_elev_vw    from wim_ro ;
--drop view wim.rpt_dupe_kb_ground_elev_vw ;

create or replace force view wim.rpt_dupe_kb_ground_elev_vw
as
select w.uwi
       , w.ipl_uwi_local
       , w.primary_source
       , w.well_name
       , w.kb_elev
       , w.ground_elev
       , w.country
       , c.long_name                                        as country_name
       , w.province_state
       , wl.license_list
       , w.surface_latitude
       , w.surface_longitude
       , w.bottom_hole_latitude
       , w.bottom_hole_longitude
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || w.uwi       as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from ppdm.well w
       left join ppdm.r_country c on w.country = c.country
       left join wim.rpt_well_all_licenses_vw wl on w.uwi = wl.uwi
 where w.kb_elev is not null and w.ground_elev is not null
       and nvl(w.kb_elev, -999) = nvl(w.ground_elev, -999)
       ----QC1797 exclude specific records that have been checked----
       and w.uwi not in (select val_1
                           from wim.exclude_from_housekeeping
                          where lower(r_id) = '043'
                                and lower(attr_1) = 'uwi'
                                and active_ind = 'Y'
                        )
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.primary_source, w.uwi

;


----the wim_ro role is granted to BIRT_APPL
grant select on wim.rpt_dupe_kb_ground_elev_vw    to wim_ro ;


----select * from wim.rpt_dupe_kb_ground_elev_vw  where province_state = 'SK';
