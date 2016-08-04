/**************************************************************************************************
 rpt_cws_unmatched_vw

 List of CWS well versions with indicator of whether a public well version is matched to the CWS wv
  - includes CWS well version with no public version sharing the same well-id (TLM-ID)
  - includes CWS well version where ipl_uwi_local is different than the public well version that shares the same well-id
    if the wv's have the same well-id, but the ipl_uwi_local is different, then CWS wv is unmatched

 The scope of this view is limited to Canada and the US.  CWS no longer manages non-CA/US wells.
 This view is intended for use by the WIM Housekeeping process (report item 020 and 021)
 
 Pre-requisite: the well_version table must include the grant-option to the WIM schema,
    to allow WIM to grant select on this view to the wim_ro role

 Indicators:
  public_wv_ind: [Y/N] - does a public well version exist for the CWS well version, with the SAME well-id ?
  matched_uwi_ind: [Y/N] - for the SAME well-id, does the public wv have the same ipl_uwi_local as the CWS wv ?

 History
  20160408  kedwards  QC1807 script creation
  20160413  cdong     removed join-clause comparing ipl_uwi_local between well versions,
                        as it is already done in the select-portion.
                      added null-value (nvl) check when comparing the ipl_uwi_local

 **************************************************************************************************/

--drop view wim.rpt_cws_unmatched_vw ;

create or replace view wim.rpt_cws_unmatched_vw
as
select cws.uwi              as tlm_id
       , cws.ipl_uwi_local
       , cws.country
       , cws.province_state
       , cws.active_ind
       , case cws.country
           when '7US' then
             case
               when ihs_us.source = '450PID' then 'Y'
               else 'N'
             end
           when '7CN' then
             case
               when ihs_cn.source = '300IPL' then 'Y'
               else 'N'
             end
           else 'N'
         end                as public_wv_ind
       , case cws.country
           when '7US' then
             case
               when nvl(wim.wim_util.format_us_api(cws.ipl_uwi_local), 'foo') = nvl(ihs_us.ipl_uwi_local, 'bar') then 'Y'
               else 'N'
             end
           when '7CN' then
             case
               when nvl(cws.ipl_uwi_local, 'foo') = nvl(ihs_cn.ipl_uwi_local, 'bar') then 'Y'
               else 'N'
             end
           else 'N'
         end                as matched_uwi_ind
  from ppdm.well_version cws
       left join ppdm.well_version ihs_cn on cws.uwi = ihs_cn.uwi
                 and ihs_cn.source = '300IPL'
                 and cws.active_ind = ihs_cn.active_ind
                 ----cdong: not necessary here, if performing check above to set 'matched' attribute
                 --and cws.ipl_uwi_local = ihs_cn.ipl_uwi_local
       left join ppdm.well_version ihs_us on cws.uwi = ihs_us.uwi
                 and ihs_us.source = '450PID'
                 and cws.active_ind = ihs_us.active_ind
                 ----cdong: not necessary here, if performing check above to set 'matched' attribute
                 --and wim.wim_util.format_us_api(cws.ipl_uwi_local) = ihs_us.ipl_uwi_local
 where cws.source = '100TLM'
       and cws.active_ind = 'Y'
       and cws.country in ('7CN', '7US')
;


-- permissions
grant select on wim.rpt_cws_unmatched_vw  to wim_ro ;
