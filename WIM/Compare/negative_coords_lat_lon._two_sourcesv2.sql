--Script written to find wells with negative values in a TLM source in countries 
--where the vendor data is positive.
--Requested by Loriss Duczek for coordinating cleanup efforts with CWS 
--Oct 22, 2010
--Author:  F. Baird
--this could be modified to have user input well names and countries and chosen attributes
select a.uwi as TLMID_SHARED, a.well_name as WELL_NAME_CWS, a.source as SOURCE_CWS,  
a.surface_latitude as SURF_LAT_CWS, a.surface_longitude as SURF_LONG_CWS, 
a.bottom_hole_latitude as BH_LAT_CWS, a.bottom_hole_longitude as BH_LONG_CWS,
b.source as SOURCE_PRB, b.well_name as WELL_NAME_PRB, 
b.surface_latitude as SURF_LAT_CWS, b.surface_longitude as SURF_LONG_CWS, 
b.bottom_hole_latitude as BH_LAT_CWS, b.bottom_hole_longitude as BH_LONG_CWS
from well_version a, well_version b 
where a.country='1AL' 
and a.well_name like 'MENZEL%' 
and a.surface_longitude like '-%' 
and a.source='100TLM'
and a.uwi=b.uwi
and b.source='500PRB'
union all
select a.uwi as TLMID_SHARED, a.well_name as WELL_NAME_CWS, a.source as SOURCE_CWS,  
a.surface_latitude as SURF_LAT_CWS, a.surface_longitude as SURF_LONG_CWS, 
a.bottom_hole_latitude as BH_LAT_CWS, a.bottom_hole_longitude as BH_LONG_CWS,
b.source as SOURCE_PRB, b.well_name as WELL_NAME_PRB, 
b.surface_latitude as SURF_LAT_CWS, b.surface_longitude as SURF_LONG_CWS, 
b.bottom_hole_latitude as BH_LAT_CWS, b.bottom_hole_longitude as BH_LONG_CWS
from well_version a, well_version b 
where a.country='1AL' 
and a.well_name like 'MENZEL%' 
and b.bottom_hole_longitude like '-%' 
and a.source='100TLM'
and a.uwi=b.uwi
and b.source='500PRB';
