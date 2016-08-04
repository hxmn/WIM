/**********************************************************************************************************************
 Exclusion list for WIM Housekeeping report items.
 Identify wells that should be excluded from particular report item checks.

 In some cases, the people working to resolve issues can only pass along information to other teams, and have to wait for
   work to be completed in another system. In the interim, the well will continue to appear in the report-item count and/or detailed report.
   In other cases, the problem is a false-positive and there is no actual issue. So, the particular record should be excluded.

 The queries in the WIM Houskeeping and various (BIRT) reports should reference this new table to exclude particular items
   from the result-set.

 History
  20160428 cdong    add more data to exclude, from merges completed 2016-04-27 (at direction of aetaiwo)

 select *  from wim.exclude_from_housekeeping where row_created_date > sysdate - 1/24;

 **********************************************************************************************************************/

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S097I246' 
           , 'uwi' 
           , '101550' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [101550: S097I246 [100TLM], 097I246 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S097E279' 
           , 'uwi' 
           , '101561' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [101561: S097E279 [100TLM], 097E279 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S097F039' 
           , 'uwi' 
           , '102122' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [102122: S097F039 [100TLM], 097F039 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S091L008' 
           , 'uwi' 
           , '105013' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105013: S091L008 [100TLM], 091L008 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S093B039' 
           , 'uwi' 
           , '105027' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105027: S093B039 [100TLM], 093B039 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092A045' 
           , 'uwi' 
           , '105029' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105029: S092A045 [100TLM], 092A045 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092G037' 
           , 'uwi' 
           , '105109' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105109: S092G037 [100TLM], 092G037 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094E149' 
           , 'uwi' 
           , '105111' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105111: S094E149 [100TLM], 094E149 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S093F259' 
           , 'uwi' 
           , '105112' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105112: S093F259 [100TLM], 093F259 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094K075' 
           , 'uwi' 
           , '105124' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105124: S094K075 [100TLM], 094K075 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S097B017' 
           , 'uwi' 
           , '105126' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105126: S097B017 [100TLM], 097B017 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094E150' 
           , 'uwi' 
           , '105440' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [105440: S094E150 [100TLM], 094E150 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S098A124' 
           , 'uwi' 
           , '111079' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [111079: S098A124 [100TLM], 098A124 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S098E013' 
           , 'uwi' 
           , '111134' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [111134: S098E013 [100TLM], 098E013 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S096J378' 
           , 'uwi' 
           , '112975' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [112975: S096J378 [100TLM], 096J378 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S097A192' 
           , 'uwi' 
           , '115161' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [115161: S097A192 [100TLM], 097A192 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S096J114' 
           , 'uwi' 
           , '117404' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117404: S096J114 [100TLM], 096J114 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S098A252' 
           , 'uwi' 
           , '117420' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117420: S098A252 [100TLM], 098A252 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094E169' 
           , 'uwi' 
           , '117424' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117424: S094E169 [100TLM], 094E169 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094E123' 
           , 'uwi' 
           , '117428' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117428: S094E123 [100TLM], 094E123 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094H182' 
           , 'uwi' 
           , '117436' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117436: S094H182 [100TLM], 094H182 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S093E255' 
           , 'uwi' 
           , '117478' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117478: S093E255 [100TLM], 093E255 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S096I097' 
           , 'uwi' 
           , '117480' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117480: S096I097 [100TLM], 096I097 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094J058' 
           , 'uwi' 
           , '117505' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117505: S094J058 [100TLM], 094J058 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094H184' 
           , 'uwi' 
           , '117534' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117534: S094H184 [100TLM], 094H184 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094H185' 
           , 'uwi' 
           , '117538' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [117538: S094H185 [100TLM], 094H185 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S005L169' 
           , 'uwi' 
           , '137075' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [137075: S005L169 [100TLM], 005L169 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S007H351' 
           , 'uwi' 
           , '140298' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [140298: S007H351 [100TLM], 007H351 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S008B401' 
           , 'uwi' 
           , '142485' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [142485: S008B401 [100TLM], 008B401 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S091A006' 
           , 'uwi' 
           , '85875' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85875: S091A006 [100TLM], 091A006 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092K088' 
           , 'uwi' 
           , '85876' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85876: S092K088 [100TLM], 092K088 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S091K071' 
           , 'uwi' 
           , '85882' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85882: S091K071 [100TLM], 091K071 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092K067' 
           , 'uwi' 
           , '85883' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85883: S092K067 [100TLM], 092K067 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S091L006' 
           , 'uwi' 
           , '85885' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85885: S091L006 [100TLM], 091L006 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092F050' 
           , 'uwi' 
           , '85887' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85887: S092F050 [100TLM], 092F050 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S092K087' 
           , 'uwi' 
           , '85888' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [85888: S092K087 [100TLM], 092K087 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S091L051' 
           , 'uwi' 
           , '86168' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [86168: S091L051 [100TLM], 091L051 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S085G112' 
           , 'uwi' 
           , '92734' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [92734: S085G112 [100TLM], 085G112 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 

insert into wim.exclude_from_housekeeping (r_id, attr_1, val_1, attr_2, val_2, remark, row_created_by, row_changed_by) 
  values ( '044' 
           , 'license_num' 
           , 'S094G121' 
           , 'uwi' 
           , '98099' 
           , 'After review, AETAIWO requested license number be added to exclude list. The CWS license number, with prefix, is the same as the IHS license number. 2016-04-28 [98099: S094G121 [100TLM], 094G121 [300IPL]]' 
           , 'CDONG' 
           , 'CDONG' 
         ) 
; 
