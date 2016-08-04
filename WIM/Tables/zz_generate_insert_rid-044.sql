/*******************************************************************************

 Script to create the insert statement to add records to the exclude-table for license numbers to ignore

 Usually, exclude the CWS license number because they use a prefix.  So, hard-coded for the most common use-case.

 After generating insert scripts, check the output.
 If a CWS license number is missing from the remark, double-check existing records in wim.exclude_from_housekeeping (eg. val_1 equal license-number and val_2 = tlm-id)


 *******************************************************************************/

select w.uwi, w.ipl_uwi_local, wlc.license_num as cws_license, v.license_list
       , 'insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) ' || chr(13)
         || '  values ( ''044'' ' || chr(13)
         || '           , ''license_num'' '  || chr(13)
         || '           , ''' || wlc.license_num || ''' ' || chr(13)
         || '           , ''uwi'' ' || chr(13)
         || '           , ''' || w.uwi || ''' ' || chr(13)
         || '           , ''After review, AETAIWO requested license number be added to exclude list. The CWS license number, with extra prefix, is the same as the IHS license number. ' || to_char(sysdate, 'yyyy-mm-dd') || ' [' || w.uwi || ': ' || v.license_list || ']'' ' || chr(13)
         || '           , ''' || user || ''' ' || chr(13)
         || '           , ''' || user || ''' ' || chr(13)
         || '         ) ' || chr(13) || '; ' || chr(13) as stmt
  from wim.rpt_well_all_licenses_vw v
       inner join ppdm.well w on v.uwi = w.uwi
       left join ppdm.well_license wlc on w.uwi = wlc.uwi and wlc.active_ind = 'Y' and wlc.source = '100TLM'
 where w.ipl_uwi_local in ('191091800610W203', '191120800611W202'
                          )
       --sometimes may also need to use tlm-id, especially if composite well's UWI (ipl_uwi_local) has changed
       or w.uwi in ('138571', '141148'
                   )
 order by w.uwi
;


/* --sample output
insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
           , 'license_num'
           , 'B022073'
           , 'uwi'
           , '138571'
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with extra prefix, is the same as the IHS license number. 2016-06-08 [138571: 022073 [300IPL]]'
           , 'CDONG'
           , 'CDONG'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
           , 'license_num'
           , 'B024106'
           , 'uwi'
           , '141148'
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with extra prefix, is the same as the IHS license number. 2016-06-08 [141148: 024106 [300IPL]]'
           , 'CDONG'
           , 'CDONG'
         )
;




*/
