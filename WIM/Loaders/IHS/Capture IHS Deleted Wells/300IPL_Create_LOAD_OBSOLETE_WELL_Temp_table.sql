---Create Tables to capture OBSOLETE WELL LIST for 300IPL Loads
---Run in PETP to create comparing Schemas: Load(Test36) to Control(Talisman37) 
---Create temp tables for Well_Version, Well_Alias, Well_License, WEll_Status and Well_Node_Version
---Created:  Oct 21, 2009
---Author:  F. Baird
---Reviewer:
---Run Date:

---****add addition columns to track if there is inventory and why the well is gone (Amended or Deleted)
----Nov 6, 2009

---Well_Version
create table TEMP_WV_300IPL_DELETED as
select * from well_version where rownum<1;
alter table TEMP_WV_300IPL_DELETED add rundate date;
grant select on TEMP_WV_300IPL_DELETED to TEST36;

----Well_Alias
create table TEMP_WA_300IPL_DELETED as
select * from well_alias where rownum<1;
alter table TEMP_WA_300IPL_DELETED add rundate date;
grant select on TEMP_WV_300IPL_DELETED to TEST36;

----Well_Node_Version
create table TEMP_WNV_300IPL_DELETED as 
select * from well_node_version where rownum<1;
alter table TEMP_WNV_300IPL_DELETED add rundate date;
grant select on TEMP_WV_300IPL_DELETED to TEST36;

---Well_License
create table TEMP_WL_300IPL_DELETED as
select * from well_license where rownum<1;
alter table TEMP_WL_300IPL_DELETED add rundate date;
grant select on TEMP_WV_300IPL_DELETED to TEST36;

---Well_Status
create table TEMP_WS_300IPL_DELETED as
select * from well_status where rownum<1;
alter table TEMP_WS_300IPL_DELETED add rundate date;
grant select on TEMP_WV_300IPL_DELETED to TEST36;

-----
Commit;

---****add addition columns to track if there is inventory and why the well is gone (Amended or Deleted)
----Nov 6, 2009
alter table TEMP_WV_300IPL_DELETED add INVENTORY VARCHAR2(20 byte);
alter table TEMP_WA_300IPL_DELETED add INVENTORY VARCHAR2(20 byte);
alter table TEMP_WNV_300IPL_DELETED add INVENTORY VARCHAR2(20 byte);
alter table TEMP_WL_300IPL_DELETED add INVENTORY VARCHAR2(20 byte);
alter table TEMP_WS_300IPL_DELETED add INVENTORY VARCHAR2(20 byte);

alter table TEMP_WV_300IPL_DELETED add REASON VARCHAR2(20 byte);
alter table TEMP_WA_300IPL_DELETED add REASON VARCHAR2(20 byte);
alter table TEMP_WNV_300IPL_DELETED add REASON VARCHAR2(20 byte);
alter table TEMP_WL_300IPL_DELETED add REASON VARCHAR2(20 byte);
alter table TEMP_WS_300IPL_DELETED add REASON VARCHAR2(20 byte);

commit;

---Add constraints
ALTER TABLE TEMP_WV_300IPL_DELETED ADD CONSTRAINT TWV_PK PRIMARY KEY (UWI,SOURCE) 
REFERENCES WELL_VERSION (UWI,SOURCE); 


