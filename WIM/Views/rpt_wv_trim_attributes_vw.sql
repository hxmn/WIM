/**********************************************************************************************************************
 View of well versions with leading and/or trailing blank space character(s) in the well name or UWI.

 History:
  20160616  cdong   QC1844 - detect well versions requiring TRIM of attributes
                    Formalizing manual activities and queries from TIS Task 1732, where TRIM() applied to well-name.


 **********************************************************************************************************************/

--revoke select on wim.rpt_wv_trim_attributes_vw  from wim_ro ;
--revoke select on wim.rpt_wv_trim_attributes_vw  from ppdm_ro ;
--drop view wim.rpt_wv_trim_attributes_vw ;

create or replace force view  wim.rpt_wv_trim_attributes_vw
as

select uwi
       , source
       , trim_name_ind
       , trim_uwi_ind
       , primary_source_ind
       , 'http://iwimca.na.tlm.com'                         as iwimprefix_nao
       , 'http://iwimtst.na.tlm.com'                        as iwimprefix_naotest
       , 'http://iwimmy.asia.tlm.com'                       as iwimprefix_ap
       , '/Default.aspx?HiddenTLMIdsForWIM=' || uwi         as iwimlink
       , (select sys_context ('USERENV', 'INSTANCE_NAME')   as instancename from dual)    as env
  from (select wv.uwi
               , wv.source
               , case
                   when (substr(wv.well_name,1,1) = chr(32)
                         or substr(wv.well_name, length(wv.well_name), 1) = chr(32)
                        )
                     then 'Y'
                   else 'N'
                 end  as trim_name_ind
               , case
                   when (substr(wv.ipl_uwi_local,1,1) = chr(32)
                         or substr(wv.ipl_uwi_local, length(wv.ipl_uwi_local), 1) = chr(32)
                        )
                     then 'Y'
                   else 'N'
                 end  as trim_uwi_ind
               , case
                   when wv.source = w.primary_source
                     then 'Y'
                   else 'N'
                 end  as primary_source_ind
          from ppdm.well_version wv
               left join ppdm.well w on wv.uwi = w.uwi
         where wv.active_ind = 'Y'
               and wv.source not in ('300IPL', '450PID', '500PRB')
       ) t
where (trim_name_ind <> 'N'
       or trim_uwi_ind <> 'N'
      )
--order by t.source

;

/

grant select on wim.rpt_wv_trim_attributes_vw  to wim_ro ;
grant select on wim.rpt_wv_trim_attributes_vw  to ppdm_ro ;
/
