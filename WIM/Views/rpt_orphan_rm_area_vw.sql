/**********************************************************************************************************************
  View returning Records Management information for each item associated to an area that does not exist (in ppdm.area)

  Requires additional grants on ppdm objects, with grant option (to grant select on this view to other schemas/roles)
    grant select on ppdm.rm_information_item   to wim with grant option;
    grant select on ppdm.rm_data_content       to wim with grant option;
    grant select on ppdm.rm_physical_item      to wim with grant option;
    grant select on ppdm.rm_data_store         to wim with grant option;
    -- add grant option to rm_info_item_content
    grant select on ppdm.rm_info_item_content  to wim with grant option;


  History
    20150806    cdong       initial creation QC1713 - identify how many RM items without an active well or area

 **********************************************************************************************************************/

--drop view rpt_orphan_rm_area_vw;


create or replace force view rpt_orphan_rm_area_vw
as

select iic.information_item_id
       , iic.info_item_type
       , iic.content_obs_no
       , iic.area_id
       , iic.area_type
       --information about the info item
       , ii.title
       , ii.reference_num
       --information about the physical item
       , pi.physical_item_id
       , pi.location_reference
       , pi.description
       , pi.label
       , pi.media_type
       , pi.store_id
       , ds.legacy_name
  from ppdm.rm_info_item_content iic
       inner join ppdm.rm_information_item ii on iic.information_item_id = ii.information_item_id and iic.info_item_type = ii.info_item_type
       left join ppdm.rm_data_content dc on iic.information_item_id = dc.information_item_id and iic.info_item_type = dc.info_item_type  
       left join ppdm.rm_physical_item pi on dc.physical_item_id = pi.physical_item_id 
       left join ppdm.rm_data_store ds on pi.store_id = ds.store_id 
 where iic.active_ind = 'Y'
           and iic.area_id is not null and iic.area_type is not null
           and not exists (select 1
                             from ppdm.area a
                            where iic.area_id = a.area_id
                                  and iic.area_type = a.area_type
                                  and a.active_ind = 'Y'
                          )

;

grant select on rpt_orphan_rm_area_vw  to ppdm_ro;
grant select on rpt_orphan_rm_area_vw  to birt_appl;