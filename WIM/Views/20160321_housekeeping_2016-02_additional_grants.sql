/**************************************************************************************************
 WIM Housekeeping (and reports) 2016.02 release
 
 This script will add GRANT OPTION on the pre-existing SELECT privileges for WIM.
   QC1781 - well_node
   QC1764 - well_inventory.well_inventory_local

 Run this script BEFORE the view creation scripts, in the PPDM or WELL_INVENTORY schemas

 History
  20160321 cdong    QC1764/QC1781  views used in WIM Housekeeping procedure

 **************************************************************************************************/

----PPDM schema-------------------------------------------------
revoke select   on ppdm.well_node   from    wim;
grant  select   on ppdm.well_node   to      wim with grant option;

----WELL_INVENTORY schema---------------------------------------
revoke select   on well_inventory.well_inventory_local  from    wim;
grant  select   on well_inventory.well_inventory_local  to      wim with grant option;


/*
----commands to restore the original select privs WITHOUT grant option...
revoke select   on ppdm.well_node   from    wim;
grant  select   on ppdm.well_node   to      wim;
revoke select   on well_inventory.well_inventory_local  from    wim;
grant  select   on well_inventory.well_inventory_local  to      wim;
*/
