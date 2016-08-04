select count(*) from PPDM.tlm_well_dir_srvy_station;
select distinct geog_coord_system_id from ppdm.tlm_well_dir_srvy_station;
--8535 count IN dev, 4411 IN TEST
select count(*) from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id = 'NAD27';

update ppdm.tlm_well_dir_srvy_station
   set geog_coord_system_id = '4267',
       ROW_CHANGED_BY = 'JFUNG',
       ROW_CHANGED_DATE = SYSDATE
 where geog_coord_system_id = 'NAD27';
 
 select * from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id = '4267';


 --138140 count IN DEV, 131078 IN TEST
select count(*) from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id = 'NAD83';

update ppdm.tlm_well_dir_srvy_station
   set geog_coord_system_id = '4269',
       ROW_CHANGED_BY = 'JFUNG',
       ROW_CHANGED_DATE = SYSDATE
 where geog_coord_system_id = 'NAD83';

select * from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id = '4269';

 --37122 count IN DEV, 24519 IN TEST
select count(*) from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id IN ( 'WGS84', 'WGS 84');

update ppdm.tlm_well_dir_srvy_station
   set geog_coord_system_id = '4326',
       ROW_CHANGED_BY = 'JFUNG',
       ROW_CHANGED_DATE = SYSDATE
 where geog_coord_system_id IN ( 'WGS84', 'WGS 84');

select * from ppdm.tlm_well_dir_srvy_station where geog_coord_system_id = '4326';

