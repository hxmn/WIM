/**********************************************************************************************************************
  Additional grants on some ppdm Records Management tables to the WIM schema, to support WIM Housekeeping and BIRT reports.
 
  History
    20150806    cdong       initial creation QC1713 - identify how many RM items without an active well or area 

 **********************************************************************************************************************/

grant select on ppdm.rm_information_item   to wim with grant option;
grant select on ppdm.rm_data_content       to wim with grant option;
grant select on ppdm.rm_physical_item      to wim with grant option;
grant select on ppdm.rm_data_store         to wim with grant option;
-- add 'with grant option' to rm_info_item_content
grant select on ppdm.rm_info_item_content  to wim with grant option;

/
