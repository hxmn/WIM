/**********************************************************************************************************************
 Exclusion list for WIM Housekeeping report items.
 Identify wells that should be excluded from particular report item checks.
 
 In some cases, the people working to resolve issues can only pass along information to other teams, and have to wait for
   work to be completed in another system. In the interim, the well will continue to appear in the report-item count and/or detailed report.
   In other cases, the problem is a false-positive and there is no actual issue. So, the particular record should be excluded.

 The queries in the WIM Houskeeping and various (BIRT) reports should reference this new table to exclude particular items
   from the result-set.

 Table description
  - R_ID: report-item id. this is a foreign-key to wim.z_benchmark.r_id. Use the "parent" r_id if there are "sub" report items 
        e.g. use 044 (well with multiple license) instead of 044a (AB+SK only) or 044b (other).
        e.g. use 002, not 002a or 002b
  - ATTR_1: name of the column-attribute containing the identifier used to exclude a particular record
        e.g. 'UWI' or 'IPL_UWI_LOCAL'
  - VAL_1: actual value of the attribute
        e.g. '111267', '100160407111W600', '50370134009', '111022304923W300', '300000639556', '111022505020W302'
  - ATTR_2: name of the column-attribute containing a secondary identifier used to exclude a particular record
        e.g. 'UWI' or 'IPL_UWI_LOCAL'
  - VAL_2: actual value of the attribute
        e.g. '111267', '100160407111W600', '50370134009', '111022304923W300', '300000639556', '111022505020W302'
  - REMARK: ideally used to explain why a record should be excluded
  - EXPIRY_DATE: not used, but defaulted for future use.  

 History
  20160331  cdong   QC1797 
  20160404  cdong   add new attributes attr_2 and val_2, plus change name of original attr/val columns and change primary key
                      in some cases, it makes sense to have a second attr to qualify records to exclude
                      eg. well license: license_num is not good enough because it can be used for multiple wells and 
                            violates the three-column-PK. cannot use only uwi, since it would be too broad and allow 
                            license nums to escape scrutiny. therefore, better to use license_num and uwi and be 
                            specific about the record to exclude. this requires the PK be changed to five columns.
                      with new columns and PK, records that only need one attribute can set the same values for attr_2/val_2 
  20160405  cdong   add expiry date

 **********************************************************************************************************************/

/*
  revoke select                               on wim.exclude_from_housekeeping       from wim_ro ;
  revoke select, insert, update, delete       on wim.exclude_from_housekeeping       from wim_rw;
  drop index efh_ix_01 ;
  drop index efh_ix_02 ;
  truncate table wim.exclude_from_housekeeping ;
  drop table wim.exclude_from_housekeeping cascade constraints ;
*/

create table wim.exclude_from_housekeeping (
    r_id                varchar2(50)    not null
  , attr_1              varchar2(20)    not null
  , val_1               varchar2(20)    not null
  , attr_2              varchar2(20)    not null
  , val_2               varchar2(20)    not null
  , active_ind          varchar2(1)     default 'Y'
  , remark              varchar2(4000)
  , expiry_date         date            default trunc(sysdate)+366
  , row_changed_by      varchar2(30)    default user
  , row_changed_date    date            default sysdate
  , row_created_by      varchar2(30)    default user
  , row_created_date    date            default sysdate
)
;


alter table wim.exclude_from_housekeeping
  add constraint efh_pk
  primary key (r_id, attr_1, val_1, attr_2, val_2) enable
;

alter table wim.exclude_from_housekeeping
  add constraint efh_fk_01
  foreign key (r_id)
    references wim.z_benchmark (r_id)
;

create index efh_ix_01
  on wim.exclude_from_housekeeping (r_id, attr_1, val_1)
;

create index efh_ix_02
  on wim.exclude_from_housekeeping (r_id, attr_2, val_2)
;


grant select                            on wim.exclude_from_housekeeping    to wim_ro;
----for TIS to edit this table
grant select, insert, update, delete    on wim.exclude_from_housekeeping    to wim_rw; 




/*------------------------------------------------------------------------------------------------------------------------
---- check/remove contents of table

  select *
  ----delete
    from wim.exclude_from_housekeeping
   order by r_id, active_ind, attr_1, val_1
  ;


---- example for adding records to exclusion table

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


----sample use of exclude table

  select *
    from wim.rpt_well_all_licenses_vw
   where uwi = '149178'
         and uwi not in (select val_1
                           from wim.exclude_from_housekeeping
                          where r_id = '044'
                                and active_ind = 'Y'
                                and lower(attr_1) = 'uwi'
                        )
  ;

*/

