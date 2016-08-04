/**************************************************************************************************
 Reference table to specify the roll-up order of well node version records.

 History
  201605xx  kxedward  creation

 **************************************************************************************************/

/*
 alter table r_rollup_node_lq drop primary key cascade;
 drop table r_rollup_node_lq cascade constraints;
*/

create table r_rollup_node_lq
(
  location_qualifier    varchar2(20 byte),
  country               varchar2(20 byte),
  province_state        varchar2(20 byte),
  active_ind            varchar2(1 byte),
  node_lq_order         number,
  remark                varchar2(200 byte),
  row_changed_by        varchar2(20 byte),
  row_changed_date      date,
  row_created_by        varchar2(20 byte),
  row_created_date      date
)
;


create unique index rrnl_pk on r_rollup_node_lq
 (location_qualifier, country, province_state)
;

alter table r_rollup_node_lq add (
  constraint rrnl_pk
  primary key (location_qualifier, country, province_state)
  using index rrnl_pk
  enable validate
)
;

/


grant select on r_rollup_node_lq to wim_ro;
grant delete, insert, select, update on r_rollup_node_lq to wim_rw;
----explicit request is required for ppdm materialized view ihs_cdn_dir_srvy_quality_mv
grant select on r_rollup_node_lq to ppdm;
/
