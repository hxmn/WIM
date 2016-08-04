/**********************************************************************************************************************
 View returning a list of wells with only a single node-- either the surface or bottom-hole, without the other node position
 Petrel (Canada) is interested in the surface location. It is important that western-Canada wells have a surface node.
 These wells should be reviewed by the GDM team to find location information for hte missing node.

 Pre-requisite: the well_node table must include the grant-option to the WIM schema,
    to allow WIM to grant select on this view to the wim_ro role
        --revoke select on ppdm.well_node from  wim;
        --grant  select on ppdm.well_node to    wim with grant option;
 
 History
  20160322  cdong   QC1781 Wells with only a single node
  20160405  cdong   QC1797 Modify queries to check data in the Exclude-table.
                    Exclude by well-id (uwi).

 **********************************************************************************************************************/

--revoke select on wim.rpt_wells_single_node_vw    from wim_ro ;
--drop view wim.rpt_wells_single_node_vw ;

create or replace force view wim.rpt_wells_single_node_vw
as
select w.country
       , w.province_state
       , w.uwi
       , w.well_name
       , w.ipl_uwi_local
       , wn.node_position
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || w.uwi       as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME') as instancename from dual)    as env
  from (select ipl_uwi, count(1) as node_count
          from ppdm.well_node wn
         where wn.active_ind = 'Y'
               ----QC1797 exclude specific records that have been checked----
               and wn.ipl_uwi not in (select val_1
                                        from wim.exclude_from_housekeeping
                                       where lower(r_id) = '047'
                                             and lower(attr_1) = 'uwi'
                                             and active_ind = 'Y'
                                     )
         group by ipl_uwi
       ) t
       inner join ppdm.well w on t.ipl_uwi = w.uwi
       inner join ppdm.well_node wn on wn.ipl_uwi = w.uwi
 where node_count = 1
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.province_state
          , w.uwi
;


grant select on rpt_wells_single_node_vw  to wim_ro ;

--select * from rpt_wells_single_node_vw ;



/*----to get count by country, province, and node_position
select w.country, w.province_state
       , wn.node_position, count(*)
  from (select ipl_uwi, count(1) as node_count
          from ppdm.well_node wn
         where wn.active_ind = 'Y'
         group by ipl_uwi
       ) t
       inner join ppdm.well w on t.ipl_uwi = w.uwi
       inner join ppdm.well_node wn on wn.ipl_uwi = w.uwi
 where node_count = 1
 group by w.country, w.province_state, wn.node_position
 order by case when w.country = '7CN' then '01' when w.country = '7US' then '02' else '03' || w.country end
          , w.province_state
          , wn.node_position
;
*/
