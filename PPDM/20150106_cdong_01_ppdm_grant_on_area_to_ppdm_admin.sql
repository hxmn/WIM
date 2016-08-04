/***************************************************************************************************
 Grant explicit permissions on ppdm.area to ppdm_admin schema.
 This is necessary for new procedure to update ppdm.rm_info_item_content with missing area_type.
 
 Run from the PPDM schema.
 
 History
  2015-01-06  cdong   TIS Task 1564.  Creation of procedure.
 
 ***************************************************************************************************/

grant select, insert, update, delete on ppdm.area to ppdm_admin;

commit;
