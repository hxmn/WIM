/**********************************************************************************************************************
 Exclusion list for WIM Housekeeping report items.
 Identify wells that should be excluded from particular report item checks.
 
 In some cases, the people working to resolve issues can only pass along information to other teams, and have to wait for
   work to be completed in another system. In the interim, the well will continue to appear in the report-item count and/or detailed report.
   In other cases, the problem is a false-positive and there is no actual issue. So, the particular record should be excluded.

 The queries in the WIM Houskeeping and various (BIRT) reports should reference this new table to exclude particular items
   from the result-set.

 History
  20160404 cdong    QC1797 
                    Initial population of data to exclude.

 **********************************************************************************************************************/

------------------------------------------------------------------------------------------------------------------------
---- 049 UWI with multiple wells (USA)

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '136569'
          , 'ipl_uwi_local'
          , 'NY31-107-23185-00-00'
          , 'CWS says well is part of group of wells with common UWI, but well is a separate event and has a separate AFE. See email btw CWS, AETAIWO, and cdong 2016-03-01 08:59 re US well. 2016-04-04 [NY31-107-23185-00-00: 133643,136569,136570]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '136570'
          , 'ipl_uwi_local'
          , 'NY31-107-23185-00-00'
          , 'CWS says well is part of group of wells with common UWI, but well is a separate event and has a separate AFE. See email btw CWS, AETAIWO, and cdong 2016-03-01 08:59 re US well. 2016-04-04 [NY31-107-23185-00-00: 133643,136569,136570]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '136572'
          , 'ipl_uwi_local'
          , 'NY31-101-23187-01-00'
          , 'CWS says well is part of group of wells with common UWI, but well is a separate event and has a separate AFE. See email btw CWS, AETAIWO, and cdong 2016-03-01 08:59 re US well. 2016-04-04 [NY31-101-23187-01-00: 136571,136572,137159]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '137159'
          , 'ipl_uwi_local'
          , 'NY31-101-23187-01-00'
          , 'CWS says well is part of group of wells with common UWI, but well is a separate event and has a separate AFE. See email btw CWS, AETAIWO, and cdong 2016-03-01 08:59 re US well. 2016-04-04 [NY31-101-23187-01-00: 136571,136572,137159]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '141967'
          , 'ipl_uwi_local'
          , 'WY49-023-22263-00-00'
          , 'CWS says well is part of group of wells with common UWI, but well is a separate event and has a separate AFE. See email btw CWS, AETAIWO, and cdong 2016-03-01 08:59 re US well. 2016-04-04 [WY49-023-22263-00-00: 139350, 141967]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '129574'
          , 'ipl_uwi_local'
          , 'NY31-097-23008-00-00'
          , 'AETAIWO requested well to be excluded, 2016-04-04 [NY31-097-23008-00-00: 129574, 136567]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '136567'
          , 'ipl_uwi_local'
          , 'NY31-097-23008-00-00'
          , 'AETAIWO requested well to be excluded, 2016-04-04 [NY31-097-23008-00-00: 129574, 136567]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '049b'
          , 'uwi' 
          , '138494'
          , 'ipl_uwi_local'
          , 'NY31-015-23912-00-00'
          , 'AETAIWO requested well to be excluded, 2016-04-04 [NY31-015-23912-00-00: 138494, 139211]'
          , 'cdong'
          , 'cdong'
         )
;



------------------------------------------------------------------------------------------------------------------------
---- 044 wells with multiple license numbers
---- Ideally, the exclusion of licenses would be based on the combination of Well-ID and License Number. However,  

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0065I014'
          , 'uwi'
          , '104804'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [104804: S0065I014 [100TLM], 065I014 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0068I076'
          , 'uwi'
          , '104810'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [104810: S0068I076 [100TLM], 068I076 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0065I110'
          , 'uwi'
          , '104835'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [104835: S0065I110 [100TLM], 065I110 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0069I128'
          , 'uwi'
          , '104966'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [104966: S0069I128 [100TLM], 069I128 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0055L011'
          , 'uwi'
          , '104993'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [104993: S0055L011 [100TLM], 055L011 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0055L014'
          , 'uwi'
          , '105004'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [105004: S0055L014 [100TLM], 055L014 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0055H001'
          , 'uwi'
          , '105032'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [105032: S0055H001 [100TLM], 055H001 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0053J024'
          , 'uwi'
          , '110239'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [110239: S0053J024 [100TLM], 053J024 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0065E154'
          , 'uwi'
          , '110241'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [110241: S0065E154 [100TLM], 065E154 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0066A004'
          , 'uwi'
          , '110251'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [110251: S0066A004 [100TLM], 066A004 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0066E029'
          , 'uwi'
          , '110259'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [110259: S0066E029 [100TLM], 066E029 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0098D054'
          , 'uwi'
          , '123691'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123691: S0098D054 [100TLM], 098D054 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D031'
          , 'uwi'
          , '123818'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123818: S000D031 [100TLM], 000D031 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D028'
          , 'uwi'
          , '123820'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123820: S000D028 [100TLM], 000D028 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D030'
          , 'uwi'
          , '123822'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123822: S000D030 [100TLM], 000D030 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D029'
          , 'uwi'
          , '123830'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123830: S000D029 [100TLM], 000D029 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I016'
          , 'uwi'
          , '123950'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [123950: S000I016 [100TLM], 000I016 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I016'
          , 'uwi'
          , '126303'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126303: S000I016 [100TLM], 000I016 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000B262'
          , 'uwi'
          , '124109'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124109: S000B262 [100TLM], 000B262 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S093J105'
          , 'uwi'
          , '124448'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124448: S093J105 [100TLM], 093J105 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I211'
          , 'uwi'
          , '124659'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124659: S000I211 [100TLM], 000I211 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I211'
          , 'uwi'
          , '124661'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124661: S000I211 [100TLM], 000I211 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I211'
          , 'uwi'
          , '124662'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124662: S000I211 [100TLM], 000I211 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S095I167'
          , 'uwi'
          , '124735'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [124735: S095I167 [100TLM], 095I167 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000E174'
          , 'uwi'
          , '126041'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126041: S000E174 [100TLM], 000E174 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I301'
          , 'uwi'
          , '126073'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126073: S000I301 [100TLM], 000I301 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I301'
          , 'uwi'
          , '126074'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126074: S000I301 [100TLM], 000I301 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000I301'
          , 'uwi'
          , '126075'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126075: S000I301 [100TLM], 000I301 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S092L044'
          , 'uwi'
          , '126102'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126102: S092L044 [100TLM], 092L044 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000G289'
          , 'uwi'
          , '126226'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126226: S000G289 [100TLM], 000G289 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D258'
          , 'uwi'
          , '126235'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126235: S000D258 [100TLM], 000D258 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S000D258'
          , 'uwi'
          , '126236'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [126236: S000D258 [100TLM], 000D258 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S001C301'
          , 'uwi'
          , '127020'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [127020: S001C301 [100TLM], 001C301 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0006F509'
          , 'uwi'
          , '138513'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [138513: S0006F509 [100TLM], 006F509 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0006F058'
          , 'uwi'
          , '139127'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [139127: S0006F058 [100TLM], 006F058 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S051529'
          , 'uwi'
          , '149178'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [149178: S051529 [100TLM], 0051529 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0052F009'
          , 'uwi'
          , '74135'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [74135: S0052F009 [100TLM], 052F009 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0050J012'
          , 'uwi'
          , '74146'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [74146: S0050J012 [100TLM], 050J012 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0064K065'
          , 'uwi'
          , '74202'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [74202: S0064K065 [100TLM], 064K065 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0093E086'
          , 'uwi'
          , '74258'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [74258: S0093E086 [100TLM], 093E086 [300IPL]]'
          , 'cdong'
          , 'cdong'
         )
;

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by)
  values ( '044'
          , 'license_num' 
          , 'S0093E244'
          , 'uwi'
          , '74261'
          , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-04 [74261: S0093E244 [100TLM], 093E244 [300IPL]]'
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

