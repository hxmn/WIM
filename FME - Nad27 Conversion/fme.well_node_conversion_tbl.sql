create table fme.well_node_conversion(
	ipl_uwi							varchar2(20 byte)
	, node_id						varchar2(20 byte)
	, source						varchar2(20 byte)
	, geog_coord_system_id 			varchar2(20 byte)
	, location_qualifier			varchar2(20 byte)
	, node_obs_no					number 
	, node_position					varchar2(1 byte)
	, country						varchar2(20 byte)
	, province_state				varchar2(20 byte)
	, latitude						number(12,7) 
	, longitude						number(12,7) 
	, target_geog_coord_system_id	varchar2(20 byte) default '4267' 
	, target_latitude				number(12,7)
	, target_longitude				number(12,7) 
	, row_changed_by				varchar2(20 byte) 
	, row_changed_date				date 
	, row_created_by				varchar2(20 byte) 
	, row_created_date				date
	, constraint wnc_pk primary key (node_id)
);

grant select, update, insert, delete on fme.well_node_conversion to wim with grant option;