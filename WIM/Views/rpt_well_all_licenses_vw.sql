/**********************************************************************************************************************
 View returning list of wells with their active license numbers

 Assumption: If a license is active, then the associated well version is active.
   The active well version rolls up to a composite well.  Therefore, it is not necessary to join to
     the WELL table to confirm a composite well exists.

 Usage:
 This view will be used by other views to include a list of license numbers in their resultset.
 The other views may be used in providing data for BIRT reports.

 Run this script in the WIM schema.

 History
  20160316 cdong    QC1784 Initial creation
                    This view can be used by other views QC1765,QC1791,QC1793
  20160321 cdong    Replaced table with sub-select that re-formats CWS license numbers to
                      remove the leading character. This leads to the second count column,
                      formatted_license_count, which counts the unique re-formatted licenses.
                      e.g. well 1000, with licenses A0102367 (cws) and 0102367 (ihs-ca).
                           reformatted would result in formatted-count of 1
                           while "real" license count is 2
                    This view can be used for QC1784 (well with multiple licenses)
  20160323 cdong    Some CWS license numbers have an exta zero after the province-specific prefix character
                    Per CWS (Bonnie), for BC and SK, prefix with letter (for province) and extra zero.
                    However, DO NOT modify view to adjust the substr for BC and SK, as the VAST majority
                      of CWS license number for BC and SK do not have the extra leading zero.
                      For example, the count of AB/SK wells increased from 186 to 14,847 with the new substr
  20160404  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by combination of license_num and uwi.

 **********************************************************************************************************************/

--revoke select on wim.rpt_well_all_licenses_vw    from wim_ro ;
--revoke select on wim.rpt_well_all_licenses_vw    from ppdm_ro ;
--drop view wim.rpt_well_all_licenses_vw ;

create or replace force view wim.rpt_well_all_licenses_vw
as
select wl.uwi
       , listagg (wl.license_num || ' [' || wl.source || ']', ', ')
           within group (order by wl.uwi, wl.source)                as license_list
       , count(distinct wl.license_num)                             as license_count
       , count(distinct wl.formatted_license)                       as formatted_license_count
  from (select wl.uwi
               , wl.license_num
               , case when wl.source = '100TLM' then substr(license_num, 2, 120)
                      else license_num
                   end                                              as formatted_license
               , wl.source
               , wl.active_ind
          from ppdm.well_license wl
               inner join ppdm.well_version wv on wl.uwi = wv.uwi and wl.source = wv.source
         where wl.license_num is not null
               ----QC1797 exclude specific records that have been checked----
               and (wl.license_num, wl.uwi) not in (select val_1, val_2
                                                      from wim.exclude_from_housekeeping
                                                     where lower(r_id) = '044'
                                                           and lower(attr_1) = 'license_num'
                                                           and lower(attr_2) = 'uwi'
                                                           and active_ind = 'Y'
                                                   )
               ----testing
               ----and wl.uwi in ('100001', '100002', '1000374300', '100135', '100136')
               ----and wl.uwi in ('137181', '138415', '105189', '105217', '143034')
       ) wl
 where wl.active_ind = 'Y'
       and wl.license_num is not null
 group by wl.uwi
 ------use the following to restrict view to only return wells with more than one formatted license
 ------having count(distinct formatted_license) > 1

;


grant select on wim.rpt_well_all_licenses_vw  to wim_ro ;
grant select on wim.rpt_well_all_licenses_vw  to ppdm_ro ;

--select * from wim.rpt_well_all_licenses_vw;
