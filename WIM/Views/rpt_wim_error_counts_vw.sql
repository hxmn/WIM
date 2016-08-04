/**********************************************************************************************************************
  View returning counts of particular errors in the WIM Audit Log
  This view will be used/referenced by a BIRT report

  Note: the view is set to return counts from the prior day (trunc(sysdate)-2)

  Dependencies:
    -- grant select on ppdm_admin.tlm_process_log to wim with grant option;

  History
    20150807    cdong   initial creation QC1655 - track and report on WIM Audit Log errors
    20160421    cdong   QC1813 - add 'well version%already exists'. The WIM Loader is trying to Create/Add a version
                          when it already exists (usually as inactive).
    20160512    cdong   QC1823 - add new warning regarding automatic addition/removal of public wells to/from blacklist
    20160602    cdong   QC1828 - add new check errors during the auto-NAD27-generation process
    20160629    cdong   QC1848 - track CWS Loader Auto-merge warnings
    20160704    cdong   QC1851 - remove duplicate check for warning message in wim_audit_log regarding automatic
                                 addition/removal of public wells to/from blacklist

 **********************************************************************************************************************/

----drop view rpt_wim_error_counts_vw;


create or replace force view rpt_wim_error_counts_vw
as

select t.error_cond
       , t.error_type
       , t.error_msg
       , t.rule_id
       , count(distinct wal.audit_id) as error_cnt
  from (select rule_short_nm       as error_cond
                          , failure_level_cd  as error_type
                          , msg_text          as error_msg
                          , rule_id
                     from wim.validate_rule
                    where msg_text is not null
                          and active_ind = 'Y'
                          and msg_text not like '{FIELD_NAME}%'
                          and rule_short_nm <> 'Action check'
                  ) t
        left join wim.wim_audit_log wal on wal.text = t.error_msg
                  and wal.row_created_date > trunc(sysdate)-2
                  and upper(audit_type) in ('E' , 'F', 'W')
 group by t.error_cond, t.error_type, t.error_msg, t.rule_id

union

select 'invalid operator' as error_cond
       , 'W' as error_type
       , 'operator is invalid' as error_msg
       , null
       , count(1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper(audit_type) in ('E' , 'F', 'W')
       and upper(text) like 'OPERATOR%IS INVALID'

union

select 'invalid licensee' as error_cond
        , 'W' as error_type
        , 'licensee is invalid' as error_msg
        , null
        , count(1) as error_cnt
  from wim.wim_audit_log where row_created_date > trunc(sysdate)-2
       and upper(audit_type) in ('E' , 'F', 'W')
       and upper(text) like 'LICENSEE%IS INVALID'

union

select 'well_status pk violation' as error_cond
       , 'E' as error_type
       , 'well_status pk violated' as error_msg
       , null
       , count(1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper(audit_type) in ('E' , 'F', 'W')
       and upper(text) = 'ORACLE ERROR :  IN WELL_STATUS_PROCCESS - ORA-00001: UNIQUE CONSTRAINT (PPDM.WST_PK) VIOLATED'

union

select 'invalid status' as error_cond
       , 'E' as error_type
       , 'status is invalid' as error_msg
       , null
       , count(1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper(audit_type) in ('E' , 'F', 'W')
       and upper(text) like 'STATUS%IS INVALID'

union

select 'unable to delete/inactivate due to inventory' as error_cond
       , 'E' as error_type
       , 'cannot be deleted or inactivated. there is inventory associated with this well' as error_msg
       , null
       , count(1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper(audit_type) in ('E' , 'F', 'W')
       and upper(text) like '%CANNOT BE DELETED%THERE IS INVENTORY ASSOCIATED WITH THIS WELL%'

union

select 'Find_Wells returns multiple wells' as error_cond
       , 'W' as error_type
       , 'find_wells - No unique match found. Possible multiple matches.' as error_msg
       , null
       , count (1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper (audit_type) in ('E', 'F', 'W')
       and upper (text) like '%NO UNIQUE MATCH FOUND%POSSIBLE MULTIPLE MATCHES%'

union

select 'Inactive license already exists' as error_cond
       , 'W' as error_type
       , 'Inactive license already exists' as error_msg
       , null
       , count (1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper (audit_type) in ('E', 'F', 'W')
       and upper (text) like '%INACTIVE LICENSE ALREADY EXISTS%'

union

select 'Oracle Error' as error_cond
       , 'E' as error_type
       , 'Oracle Error' as error_msg
       , null
       , count (1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper (audit_type) in ('E', 'F', 'W')
       and upper (text) like '%ORACLE ERROR%'

union

select 'Well version already exists' as error_cond
       , 'E' as error_type
       , 'Well version already exists' as error_msg
       , null
       , count (1) as error_cnt
  from wim.wim_audit_log
 where row_created_date > trunc(sysdate)-2
       and upper (audit_type) in ('E')
       and upper (text) like 'WELL VERSION%ALREADY EXISTS'

union

select 'Error during WIM NAD27-generation process' as error_cond
       , 'E' as error_type
       , 'Error during WIM NAD27-generation process' as error_msg
       , null
       , count (1) as error_cnt
  from ppdm_admin.tlm_process_log
 where text like 'WIM_NAD27%'
       and upper(klass) = 'ERROR'
       and row_created_on > trunc(sysdate)-2

union

select 'CWS WIM Loader automerge warning' as error_cond
       , 'W' as error_type
       , 'CWS Automerge: multiple TLM-IDs found as potential match or potential public-well-match is already associated with another CWS well' as error_msg
       , null
       , count (1) as error_cnt
  from ppdm_admin.tlm_process_log
 where upper(text) like 'WIM_LOADER_CWS - AUTOMERGE%'
       and upper(klass) = 'WARNING'
       and row_created_on > trunc(sysdate)-2


;

grant select on rpt_wim_error_counts_vw  to ppdm_ro;
grant select on rpt_wim_error_counts_vw  to birt_appl;


/*----debugging

select * from rpt_wim_error_counts_vw ;

*/


