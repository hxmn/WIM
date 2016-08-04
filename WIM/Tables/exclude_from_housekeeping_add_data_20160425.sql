/**********************************************************************************************************************
 Exclusion list for WIM Housekeeping report items.
 Identify wells that should be excluded from particular report item checks.

 In some cases, the people working to resolve issues can only pass along information to other teams, and have to wait for
   work to be completed in another system. In the interim, the well will continue to appear in the report-item count and/or detailed report.
   In other cases, the problem is a false-positive and there is no actual issue. So, the particular record should be excluded.

 The queries in the WIM Houskeeping and various (BIRT) reports should reference this new table to exclude particular items
   from the result-set.

 History
  20160425 cdong    add more data to exclude

 **********************************************************************************************************************/


------------------------------------------------------------------------------------------------------------------------
---- 044 wells with multiple license numbers
---- Ideally, the exclusion of licenses would be based on the combination of Well-ID and License Number.

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0098D055'
          , 'uwi'
          , '111405'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [111405: S0098D055 [100TLM], 098D055 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0098B222'
          , 'uwi'
          , '111406'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [111406: S0098B222 [100TLM], 098B222 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0099K046'
          , 'uwi'
          , '122222'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [122222: S0099K046 [100TLM], 099K046 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0096A164'
          , 'uwi'
          , '129563'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [129563: S0096A164 [100TLM], 096A164 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0095L145'
          , 'uwi'
          , '131442'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [131442: S0095L145 [100TLM], 095L145 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0095L145'
          , 'uwi'
          , '134542'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [134542: S0095L145 [100TLM], 095L145 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005D130'
          , 'uwi'
          , '134568'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [134568: S0005D130 [100TLM], 005D130 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0096J378'
          , 'uwi'
          , '112974'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [112974: S0096J378 [100TLM], 096J378 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0094C077'
          , 'uwi'
          , '119549'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [119549: S0094C077 [100TLM], 094C077 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0095B141'
          , 'uwi'
          , '119565'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [119565: S0095B141 [100TLM], 095B141 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0094J203'
          , 'uwi'
          , '119567'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [119567: S0094J203 [100TLM], 094J203 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0096G292'
          , 'uwi'
          , '119581'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [119581: S0096G292 [100TLM], 096G292 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0099I173'
          , 'uwi'
          , '122160'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [122160: S0099I173 [100TLM], 099I173 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0099I261'
          , 'uwi'
          , '122163'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [122163: S0099I261 [100TLM], 099I261 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0095I148'
          , 'uwi'
          , '123098'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [123098: S0095I148 [100TLM], 095I148 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0000C200'
          , 'uwi'
          , '123424'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [123424: S0000C200 [100TLM], 000C200 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0096L141'
          , 'uwi'
          , '127842'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [127842: S0096L141 [100TLM], 096L141 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0001I167'
          , 'uwi'
          , '128273'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [128273: S0001I167 [100TLM], 001I167 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0002A078'
          , 'uwi'
          , '128750'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [128750: S0002A078 [100TLM], 002A078 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0002H285'
          , 'uwi'
          , '129856'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [129856: S0002H285 [100TLM], 002H285 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0003I314'
          , 'uwi'
          , '130957'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [130957: S0003I314 [100TLM], 003I314 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0004K013'
          , 'uwi'
          , '133607'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [133607: S0004K013 [100TLM], 004K013 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0004K013'
          , 'uwi'
          , '133608'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [133608: S0004K013 [100TLM], 004K013 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0093C039'
          , 'uwi'
          , '133609'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [133609: S0093C039 [100TLM], 093C039 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0093C039'
          , 'uwi'
          , '133610'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [133610: S0093C039 [100TLM], 093C039 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005A129'
          , 'uwi'
          , '134249'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [134249: S0005A129 [100TLM], 005A129 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005C003'
          , 'uwi'
          , '134276'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [134276: S0005C003 [100TLM], 005C003 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005C003'
          , 'uwi'
          , '134478'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [134478: S0005C003 [100TLM], 005C003 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005J159'
          , 'uwi'
          , '136168'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [136168: S0005J159 [100TLM], 005J159 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005K304'
          , 'uwi'
          , '137056'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [137056: S0005K304 [100TLM], 005K304 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0005L322'
          , 'uwi'
          , '137064'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [137064: S0005L322 [100TLM], 005L322 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006F237'
          , 'uwi'
          , '137066'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [137066: S0006F237 [100TLM], 006F237 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006D018'
          , 'uwi'
          , '137895'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [137895: S0006D018 [100TLM], 006D018 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0004H203'
          , 'uwi'
          , '138470'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138470: S0004H203 [100TLM], 004H203 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0004H203'
          , 'uwi'
          , '138471'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138471: S0004H203 [100TLM], 004H203 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006G313'
          , 'uwi'
          , '138535'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138535: S0006G313 [100TLM], 006G313 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006G313'
          , 'uwi'
          , '138536'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138536: S0006G313 [100TLM], 006G313 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006I157'
          , 'uwi'
          , '138543'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138543: S0006I157 [100TLM], 006I157 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006I157'
          , 'uwi'
          , '138545'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138545: S0006I157 [100TLM], 006I157 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num'
          , 'S0006G343'
          , 'uwi'
          , '138558'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-25 [138558: S0006G343 [100TLM], 006G343 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;


/*

select *
----delete
  from wim.exclude_from_housekeeping
 order by r_id, active_ind, attr_1, val_1
;


----sample use of exclude table

select *
  from wim.rpt_well_all_licenses_vw
 where uwi = '149178'
       and uwi not in (select val
                         from wim.exclude_from_housekeeping
                        where r_id = '044'
                              and active_ind = 'Y'
                              and lower(attr) = 'uwi'
                      )
;

*/

