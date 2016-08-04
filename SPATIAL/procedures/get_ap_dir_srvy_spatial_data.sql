/**********************************************************************************************************************
  Procedure to retrieve the Talisman proprietary directional survey data
    for Asia Pacific countries from the AP hub database.

  History
    20150303    cdong   Initial deployment for PDMS
    20150312    cdong   add exception handling, in case db-link to AP hub is not available
    20160622    cdong   QC1847 - update exception handling, to include error message


 **********************************************************************************************************************/

 --drop procedure SPATIAL.get_ap_dir_srvy_spatial_data;


create or replace procedure spatial.get_ap_dir_srvy_spatial_data
as
    v_count         number;
/*
  Procedure to retrieve the Talisman proprietary directional survey data
    for Asia Pacific countries from the AP hub database.

  History
    20150303    cdong   Initial deployment for PDMS
    20150312    cdong   add exception handling, in case db-link to AP hub is not available

*/
begin

    ppdm_admin.tlm_process_logger.info('SPATIAL: get dir srvy spatial data from asia pacific ... START');

    v_count   :=  0;

    begin
        -- determine if source contains data
        -- if yes, truncate table, populate table ... if no, then do nothing
        select count(1) into v_count
          from spatial.tlm_dir_srvy_spatial_vw@dl_aphub_spatial
        ;

    exception
      when others then ppdm_admin.tlm_process_logger.error(' ... could not connect ...');

    end;

    if v_count > 0 then
        execute immediate 'truncate table spatial.dir_srvy_spatial_ap';

        insert /*+append*/ into spatial.dir_srvy_spatial_ap(uwi, latitude, longitude, station_tvd, station_md
                                                            , depth_datum_elev, geog_coord_system_id, survey_id
                                                            , source, kb_elev, latest_date)
          select uwi, latitude, longitude, station_tvd, station_md
                   , depth_datum_elev, geog_coord_system_id, survey_id
                   , source, kb_elev, latest_date
            from spatial.tlm_dir_srvy_spatial_vw@dl_aphub_spatial
        ;

        commit;

        ppdm_admin.tlm_process_logger.info('  ... retrieved ' || v_count || ' rows');
    else
        ppdm_admin.tlm_process_logger.info('  ... no data to retrieve; do nothing');

    end if;

    ppdm_admin.tlm_process_logger.info('SPATIAL: get dir srvy spatial data from asia pacific ... END');

    exception
      when others then ppdm_admin.tlm_process_logger.error(' *** error with procedure: ' || sqlerrm);

end;
/
