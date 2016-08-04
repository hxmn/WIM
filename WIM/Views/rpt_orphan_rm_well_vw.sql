/**********************************************************************************************************************
  View returning Records Management information for each item associated to a well that does not exist (in ppdm.well)

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

--drop view rpt_orphan_rm_well_vw;


create or replace force view rpt_orphan_rm_well_vw
as

select iic.information_item_id
       , iic.info_item_type
       , iic.content_obs_no
       , iic.uwi
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
       and iic.uwi is not null
       and not exists 
           (select 1
              from ppdm.well w
             where iic.uwi = w.uwi
                   and w.active_ind = 'Y'
           )
       ----exclude any rm iic record associated to an Asia Pacific well. this is temporary until the AP rm records can be inactivated.
       and iic.uwi not in 
           (----73,976
            select distinct iic.uwi
                   --count(1)
              from ppdm.rm_info_item_content iic
                   --find records related to any Asia Pacific well
                   inner join (--return tlm-id of all wells in Asia Pacific, which should be inactive in North America
                               select distinct uwi 
                                 from ppdm.well_version wv
                                      inner join ppdm_admin.r_country_ap a on wv.country = a.country
                              ) t on iic.uwi = t.uwi
             where --exclude any active composite well.  If an AP well is somehow active, it would have a composite well.  We want to exclude it in the query results.
                   not exists (select 1
                                 from ppdm.well w
                                where iic.uwi = w.uwi
                              )
           )
;

grant select on rpt_orphan_rm_well_vw  to ppdm_ro;
grant select on rpt_orphan_rm_well_vw  to birt_appl;
