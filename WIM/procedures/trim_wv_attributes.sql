/**********************************************************************************************************************
 Procedure to trim leading and/or trailing blank space characters from well attributes

 History:
  20160616  cdong   QC1843 TRIM well version attribute values.
                    Formalizing manual activities and queries from TIS Task 1732, where TRIM() applied to well-name.
  20160621  cdong   Reconsidered only logging when count > 0. It is more consistent to log a cound at all times, 
                    similar to other report items.


 **********************************************************************************************************************/

--drop procedure wim.trim_wv_attributes


create or replace procedure wim.trim_wv_attributes
/******************************************************************************
 Procedure to remove leading and/or trailing blank-space characers (chr(32))
 from particular attributes of active well_version records.
 Use Oracle TRIM() function.

 Exclude CWS (100TLM) well versions, as any change needs to be made by CWS.

 Dependency: wim.rpt_wv_trim_attributes_vw. this view excludes IHS well versions.

 History:
  20160616  cdong
    QC1843 creation. Attributes: well-name, ipl_uwi_local

 *****************************************************************************/
as

  v_count       integer :=  0;

begin

  -----------------------------------------------------------------------------
  ---- Well Name
  begin

    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (name)........... START');
    v_count   := 0;

    for i in (select wv.uwi, wv.source, wv.well_name, dump(wv.well_name) as dmp
                from ppdm.well_version wv
                     inner join wim.rpt_wv_trim_attributes_vw t
                           on wv.uwi = t.uwi
                              and wv.source = t.source
                              and t.trim_name_ind = 'Y'
                              and wv.source <> '100TLM'
             )
    loop
      begin

        update ppdm.well_version
           set well_name = trim(i.well_name)
         where uwi = i.uwi
               and source = i.source
        ;

        wim.wim_rollup.well_rollup(i.uwi);
        commit;

        ppdm_admin.tlm_process_logger.info(' ... updated well version ' || i.uwi || ' (' || i.source || ') : old name was ''' || i.well_name || '''');
        v_count   :=  v_count + 1;

        exception
          when others then ppdm_admin.tlm_process_logger.error(' ... ERROR during trim of well version (name)' || i.uwi || '(' || i.source || ')');
      end;

    end loop;

    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (name) - updated: ' || v_count);
    
    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (name)........... END');

  end;


  -----------------------------------------------------------------------------
  ---- UWI
  begin

    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (uwi)........... START');
    v_count   := 0;

    for i in (select wv.uwi, wv.source, wv.ipl_uwi_local, dump(wv.ipl_uwi_local) as dmp
                from ppdm.well_version wv
                     inner join wim.rpt_wv_trim_attributes_vw t
                           on wv.uwi = t.uwi
                              and wv.source = t.source
                              and t.trim_uwi_ind = 'Y'
                              and wv.source <> '100TLM'
             )
    loop
      begin

        update ppdm.well_version
           set ipl_uwi_local = trim(i.ipl_uwi_local)
         where uwi = i.uwi
               and source = i.source
        ;

        wim.wim_rollup.well_rollup(i.uwi);
        commit;

        ppdm_admin.tlm_process_logger.info(' ... updated well version ' || i.uwi || ' (' || i.source || ') : old UWI was ''' || i.ipl_uwi_local || '''');
        v_count   :=  v_count + 1;

        exception
          when others then ppdm_admin.tlm_process_logger.error(' ... ERROR during trim of well version (uwi)' || i.uwi || '(' || i.source || ')');
      end;

    end loop;

    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (uwi) - updated: ' || v_count);

    ppdm_admin.tlm_process_logger.info('Update well version and remove leading and trailing spaces (uwi)........... END');

  end;

end;


/
