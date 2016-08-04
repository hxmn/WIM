/**************************************************************************************************
 Data quality checks of Directional Survey data
 This script will add GRANT OPTION on the pre-existing SELECT privileges for WIM
   on tables ppdm.tlm_well_dir_srvy and ppdm.tlm_well_dir_srvy_station
   Run this script BEFORE the view creation scripts.

 See TIS Task 1666, QC1727,  and WIM Housekeeping wiki page for background
 http://explweb1.na.tlm.com/wiki/WIM_Housekeeping#Fixes_and_Checks

 Run in the PPDM schema

 History
  20151116 cdong    QC1727  views used in WIM Housekeeping procedure

 **************************************************************************************************/

grant select    on ppdm.tlm_well_dir_srvy           to wim  with grant option;
grant select    on ppdm.tlm_well_dir_srvy_station   to wim  with grant option;


----commands to restore the original select privs WITHOUT grant option...
--revoke select    on ppdm.tlm_well_dir_srvy           from wim;
--grant select    on ppdm.tlm_well_dir_srvy           to wim;
--revoke select    on ppdm.tlm_well_dir_srvy_station   from wim; 
--grant select    on ppdm.tlm_well_dir_srvy_station   to wim;
