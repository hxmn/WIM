select rowid, wv.* from ppdm.well_version wv where uwi = '1000';
select rowid, w.* from ppdm.well w where uwi = '1000';
select rowid, wnv.* from ppdm.well_node_version wnv where ipl_uwi = '1000';
select rowid, wn.* from ppdm.well_node wn where ipl_uwi = '1000';

exec wim_rollup.well_rollup('1000');

select * from wim_audit_log where row_created_date > sysdate - 1 order by row_created_date desc ;
select * from ppdm.tlm_process_log where row_created_on > sysdate - 1 order by row_created_on desc;