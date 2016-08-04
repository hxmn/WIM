select * from tlm_well_dir_srvy_station;

select * from tlm_well_dir_srvy_station
where Geog_Coord_System_Id = '4267';


--4411
UPDATE tlm_well_dir_srvy_station
set Geog_Coord_System_Id = 'NAD27'
where Geog_Coord_System_Id = '4267';

commit;

select *from tlm_well_dir_srvy_station
where Geog_Coord_System_Id = '4269';
--131077

UPDATE tlm_well_dir_srvy_station
set Geog_Coord_System_Id = 'NAD83'
where Geog_Coord_System_Id = '4269';
commit;

select * from tlm_well_dir_srvy_station
where Geog_Coord_System_Id in ( '4326');
--24240

UPDATE tlm_well_dir_srvy_station
set Geog_Coord_System_Id =  'WGS84'
where Geog_Coord_System_Id ='4326';

COMMIT;


select * from tlm_well_dir_srvy_station
where Geog_Coord_System_Id not in ('NAD83','NAD27','WGS84');



select ppdm_admin.tlm_util.Get_coord_System_ID (replace('WGS 84', ' ','')) from dual;