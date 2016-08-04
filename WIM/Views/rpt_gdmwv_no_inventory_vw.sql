/**********************************************************************************************************************
 View returning a list of GDM (700TLME) well versions without any other active well version and no inventory.
 These wells should be reviewed by the GDM team, to decide whether the well version should remain active or be inactivated.

 Join with the inventory table. If the well doesn't exist in the inventory table (wi.uwi is null), then there is no inventory.
 Alternatively, a record may exist, but with zeros for local-data inventory counts.

 Pre-requisite: the well_inventory table must include the grant-option to the WIM schema,
    to allow WIM to grant select on this view to the wim_ro role
        --revoke select on well_inventory.well_inventory_local from   wim;
        --grant  select on well_inventory.well_inventory_local to     wim with grant option;

 History
  20160322  cdong   QC1764 Create view to use in reports of GDM well versions with no inventory
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by well-id (uwi).

 **********************************************************************************************************************/

--revoke select on wim.rpt_gdmwv_no_inventory_vw    from wim_ro ;
--drop view wim.rpt_gdmwv_no_inventory_vw ;

create or replace force view wim.rpt_gdmwv_no_inventory_vw
as
select t.uwi
       , t.well_name
       , t.country
       , t.province_state
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , '/Default.aspx?HiddenTLMIdsForWIM=' || t.uwi       as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from (select wv.uwi, wv.well_name, wv.country, wv.province_state
          from ppdm.well_version wv
              left join well_inventory.well_inventory_local wi
                        on wv.uwi = wi.uwi
         where wv.source = '700TLME'
               and wv.active_ind = 'Y'
               and wv.uwi not in (select distinct uwi
                                    from ppdm.well_version b
                                   where b.source <> '700TLME'
                                         and b.active_ind = 'Y'
                                 )
               ----confirm local inventory count is zero. could have used function, but that might be too much overhead for a view
               and ( wi.uwi is null
                     or (wi.well_document_count = 0
                            and wi.geochem_count = 0
                            and wi.well_log_count = 0
                            and wi.well_dir_srvy_count = 0
                            and wi.vsp_count = 0
                            and wi.micro_seis_count = 0
                            and wi.well_rm_count = 0
                        )
                   )
               ----QC1797 exclude specific records that have been checked----
               and wv.uwi not in (select val_1
                                    from wim.exclude_from_housekeeping
                                   where lower(r_id) = '046'
                                         and lower(attr_1) = 'uwi'
                                         and active_ind = 'Y'
                                 )
       ) t

order by country desc, province_state
;


grant select on wim.rpt_gdmwv_no_inventory_vw  to wim_ro ;

--select * from wim.rpt_gdmwv_no_inventory_vw ;
