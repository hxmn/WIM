/**********************************************************************************************************************
 Views to return list of UWI's (ipl_uwi_local) with multiple composite wells per UWI, for Canada and the USA.

 The original queries existed only in the WIM Duplicate Wells report. Due to QC1678, the queries included code to
  ignore wells that had a 075TLMO wv that overrode the 100TLM CWS well (with status 'CANCEL').
  Since that time, WIM no longer has any active 100TLM with status 'CANCEL'. The CWS WIM Loader excludes any 'CANCEL' wells.
  It is unlikely that WIM will bring in CWS 'CANCEL' wells because a lot of them still have 199* UWI's for Alberta,
  which is undesired by the business (as they are incorrect).

 Unable to combine Canada and US into a single view. While highly unlikely, it is possible a UWI could be shared by
  wells in multiple countries and/or provinces-states. So, if the queries grouped by country/province-state, they may
  no longer recognized that a UWI is shared by multiple wells (since the country/prov-state is diff).
  So, the queries are eparate and do not include country/province-state.

 History
  20160331  cdong   QC1798 Create report item in Housekeeping for UWI's with multiple (composite) wells.
                      This also aids in QC1797, to create an process whereby wells can be excluded from certain checks.
                      The exclude table requires a report-id as part of its key and for the exclusion process to work.
  20160404  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by well-id (uwi).
  20160428  cdong   QC1816 Include list of license-numbers for wells
                    More than one license number may appear in either the CWS or IHS License column, if both (more-than-one)
                      of the wells have a CWS and/or IHS well version.
                    The list of license numbers for the wells displays the text “none or excluded”. This means the well either
                      has no license numbers or one-or-more of its license numbers have been added to the exclusion table
  20160504  cdong   Revert Canadian view to its prior state, where there are NO license-number columns.
                    The use of several new LISTAGG columns to get CWS, IHS, and ALL license numbers is an issue for
                      the eclipse IDE for BIRT reports. So, I cannot edit the WIM Duplicate UWI/Wells report.
                      Create new view rpt_uwi_multi_well_ca_WL_vw to include the license fields, to be used as a supplement
                      to the Canadian view.
  20160504  cdong   Add CWS and IHS License number fields. Don't add a fourth attribute using LISTAGG.
                    Remove the extra top-level "select" because it causes a problem for the eclipse ide.
                    Remove the iwimlink attribute. In the report definition, join iwimprefix to well_list.
                    Note: MUST update the WIM Duplicate UWI/Well report to use the new columns.
  20160525  cdong   QC1827  Update the view to use DISTINCT in the sub-select.
                    Due to change in WIM_Loader, to pull-in the actual license-id instead of using the tlm-well-id,
                      there are over 100,000 instances of wells with more than one active well-license for a single source.
                      Even after the loader is fixed, the DISTINCT will serve to mitigate the risk of "dupe" license rows.

 **********************************************************************************************************************/

--revoke select on wim.rpt_uwi_multi_well_ca_vw from wim_ro ;
--drop view wim.rpt_uwi_multi_well_ca_vw ;

create or replace force view wim.rpt_uwi_multi_well_ca_vw
as
select w2.ipl_uwi_local
       , listagg(w2.uwi, ',') within group (order by w2.ipl_uwi_local, w2.primary_source, w2.uwi)               as well_list
       , listagg(w2.license_num_cws, ',') within group (order by w2.ipl_uwi_local, w2.primary_source, w2.uwi)   as license_list_cws
       , listagg(w2.license_num_ihs, ',') within group (order by w2.ipl_uwi_local, w2.primary_source, w2.uwi)   as license_list_ihs
       , 'http://iwimca.na.tlm.com/Default.aspx?HiddenTLMIdsForWIM='                                            as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com/Default.aspx?HiddenTLMIdsForWIM='                                           as iwimprefix_naotest
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)                            as env
  from (select distinct w.uwi
               , w.ipl_uwi_local
               , w.country
               , w.province_state
               , wlc.license_num as license_num_cws
               , wli.license_num as license_num_ihs
               , w.primary_source
          from ppdm.well w
               left join ppdm.well_license wlc on w.uwi = wlc.uwi and wlc.source = '100TLM' and wlc.active_ind = 'Y' and wlc.license_num is not null
               left join ppdm.well_license wli on w.uwi = wli.uwi and wli.source = '300IPL' and wli.active_ind = 'Y' and wli.license_num is not null
       ) w2
 where w2.country in ('7CN')
       and w2.ipl_uwi_local is not null
       ----QC1797 exclude specific records that have been checked----
       and w2.uwi not in (select val_1
                            from wim.exclude_from_housekeeping
                           where lower(r_id) = '049a'
                                 and lower(attr_1) = 'uwi'
                                 and active_ind = 'Y'
                         )
 group by w2.ipl_uwi_local
 having count(w2.uwi) > 1

;

grant select on wim.rpt_uwi_multi_well_ca_vw       to wim_ro;

/


--revoke select on wim.rpt_uwi_multi_well_us_vw from wim_ro ;
--drop view wim.rpt_uwi_multi_well_us_vw ;

create or replace force view wim.rpt_uwi_multi_well_us_vw
as
select t.ipl_uwi_local
       ,  well_list
       , 'http://iwimca.na.tlm.com'                                                                 as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                                                                as iwimprefix_naotest
       , '/Default.aspx?HiddenTLMIdsForWIM=' || t.well_list                                         as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)                as env
  from ( select w2.ipl_uwi_local
                , listagg(w2.uwi, ',') within group (order by w2.ipl_uwi_local, w2.uwi) as well_list
           from ppdm.well w2
          where w2.country in ('7US')
                and w2.ipl_uwi_local is not null
                ----QC1797 exclude specific records that have been checked----
                and uwi not in (select val_1
                                  from wim.exclude_from_housekeeping
                                 where lower(r_id) = '049b'
                                       and lower(attr_1) = 'uwi'
                                       and active_ind = 'Y'
                               )
          group by w2.ipl_uwi_local
          having count(w2.uwi) > 1
       ) t
;

grant select on wim.rpt_uwi_multi_well_us_vw       to wim_ro;

/

/*
select *  from wim.rpt_uwi_multi_well_ca_vw ;
select *  from wim.rpt_uwi_multi_well_us_vw ;

*/