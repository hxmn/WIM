create or replace package body nad27_generator
is
    function get_ztis_lq_ref(p_location_qualifier varchar2) return varchar2
    is
        v_lq_prefix varchar2(5) := substr(p_location_qualifier, 0, instr(p_location_qualifier, ':') - 1);
        v_return    varchar2(20);
    begin
        if lower(v_lq_prefix) <> 'ztis' then
            v_return := '';
        end if;
        
        v_return := substr(p_location_qualifier, instr(p_location_qualifier, ':') + 1);        
        return v_return;
    end get_ztis_lq_ref;
    
    procedure fme_cleanup
    is
        cursor cur_nodes_to_delete is
            select ipl_uwi, node_id, source, geog_coord_system_id, location_qualifier, node_obs_no, node_position
            from wim.wim_nad27_conv_stage_vw
            where nad_type <> 'NEW'
        ;
        type t_nd is table of cur_nodes_to_delete%rowtype index by binary_integer;
        v_nodes_to_delete t_nd;
        
        v_done    boolean;
        
        bulk_errors exception;
        pragma exception_init(bulk_errors, -24381);
    begin
        ppdm_admin.tlm_process_logger.info ('WIM_NAD27 - FME Cleanup Started');
        
        fme.do_truncate(); 
        
        open cur_nodes_to_delete;
        loop
            fetch cur_nodes_to_delete bulk collect into v_nodes_to_delete limit 25;
            v_done := cur_nodes_to_delete%notfound;

            begin
                forall i in  1 .. v_nodes_to_delete.count
                save exceptions
                    delete from ppdm.well_node_version
                    where node_id = v_nodes_to_delete(i).node_id
                        and source = v_nodes_to_delete(i).source
                        and node_obs_no = v_nodes_to_delete(i).node_obs_no
                        and geog_coord_system_id = v_nodes_to_delete(i).geog_coord_system_id
                        and location_qualifier = v_nodes_to_delete(i).location_qualifier
                    ;  
            
                for i in  1 .. v_nodes_to_delete.count
                loop
                    wim.wim_rollup.node_rollup(v_nodes_to_delete(i).ipl_uwi, v_nodes_to_delete(i).node_id, v_nodes_to_delete(i).node_position);
                end loop;
            exception
                when bulk_errors then
                    for indx in 1 .. sql%bulk_exceptions.count
                    loop
                        ppdm_admin.tlm_process_logger.error('WIM_NAD27 - FME Cleanup Error: '
                            || v_nodes_to_delete(sql%bulk_exceptions(indx).error_index).node_id
                            || ', ' || v_nodes_to_delete(sql%bulk_exceptions(indx).error_index).source
                            || ', ' || v_nodes_to_delete(sql%bulk_exceptions(indx).error_index).geog_coord_system_id
                            || ', ' || v_nodes_to_delete(sql%bulk_exceptions(indx).error_index).location_qualifier
                            || ', ' || v_nodes_to_delete(sql%bulk_exceptions(indx).error_index).node_obs_no
                            || ' could not be deleted.'
                        );
                    end loop;
            end;
            exit when v_done;
        end loop;
        commit;
        ppdm_admin.tlm_process_logger.info('WIM_NAD27 - FME Cleanup Completed.');
    end fme_cleanup;
    
    procedure locator_populate
    is
        cursor cur_nodes_to_convert is
            select ipl_uwi, node_id, source, geog_coord_system_id, location_qualifier, node_obs_no, node_position, country, province_state
                , latitude, longitude
                , '4267' as target_geog_coord_system_id, row_changed_by, row_changed_date, user as row_created_by, sysdate as row_created_date, remark
                , null as target_latitude, null as target_longitude
            from wim.wim_nad27_conv_stage_vw
            where nad_type = 'NEW'
        ;
        type t_nc is table of cur_nodes_to_convert%rowtype index by binary_integer;
        v_nodes_to_convert  t_nc;
        
        v_done    boolean;
        v_geom    mdsys.sdo_geometry;
        
        bulk_errors exception;
        pragma exception_init(bulk_errors, -24381);
    begin
        open cur_nodes_to_convert;
        loop
            fetch cur_nodes_to_convert bulk collect into v_nodes_to_convert limit 25;
            v_done := cur_nodes_to_convert%notfound;
            
            begin
                for i in 1 .. v_nodes_to_convert.count
                loop
                    if v_nodes_to_convert(i).country = '7US' then
                        v_geom := mdsys.sdo_cs.transform(mdsys.sdo_geometry(2001, 4269, mdsys.sdo_point_type(v_nodes_to_convert(i).longitude, v_nodes_to_convert(i).latitude, null), null, null), 'NADCON_83_27', 4267);
                    elsif v_nodes_to_convert(i).country = '7CN' then
                        if v_nodes_to_convert(i).geog_coord_system_id = '4269' then
                            v_geom := mdsys.sdo_cs.transform(mdsys.sdo_geometry(2001, 4269, mdsys.sdo_point_type(v_nodes_to_convert(i).longitude, v_nodes_to_convert(i).latitude, null), null, null), 'NTV2_83_27', 4267);
                        elsif v_nodes_to_convert(i).geog_coord_system_id = '4326' then
                            v_geom := mdsys.sdo_cs.transform(mdsys.sdo_geometry(2001, 4326, mdsys.sdo_point_type(v_nodes_to_convert(i).longitude, v_nodes_to_convert(i).latitude, null), null, null), 'NTV2_84_27', 4267);
                        end if;
                    end if;    
                    
                    v_nodes_to_convert(i).target_longitude := v_geom.sdo_point.x;
                    v_nodes_to_convert(i).target_latitude := v_geom.sdo_point.y;          
                end loop;
                
                forall i in 1 .. v_nodes_to_convert.count
                save exceptions
                    insert into fme.well_node_conversion(ipl_uwi, node_id, source, geog_coord_system_id, location_qualifier, node_obs_no, node_position, country, province_state
                        , latitude, longitude, target_geog_coord_system_id, target_latitude, target_longitude, row_changed_by, row_changed_date, row_created_by, row_created_date 
                    )       
                    values (v_nodes_to_convert(i).ipl_uwi, v_nodes_to_convert(i).node_id, v_nodes_to_convert(i).source, v_nodes_to_convert(i).geog_coord_system_id, v_nodes_to_convert(i).location_qualifier, v_nodes_to_convert(i).node_obs_no, v_nodes_to_convert(i).node_position, v_nodes_to_convert(i).country, v_nodes_to_convert(i).province_state
                        , v_nodes_to_convert(i).latitude, v_nodes_to_convert(i).longitude, '4267', v_nodes_to_convert(i).target_latitude, v_nodes_to_convert(i).target_longitude, v_nodes_to_convert(i).row_changed_by, v_nodes_to_convert(i).row_changed_date, 'WIM_NAD27', sysdate
                    );
            exception
                when bulk_errors then
                    for indx in 1 .. sql%bulk_exceptions.count
                    loop
                        ppdm_admin.tlm_process_logger.error('WIM_NAD27 - NAD27 zTIS Locator Create Error: '
                            || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).node_id
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).source
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).geog_coord_system_id
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).location_qualifier
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).node_obs_no
                            || ' cannot be inserted in to well_node_conversion table.'
                        );
                    end loop;
            end;
            exit when v_done;
        end loop;
        close cur_nodes_to_convert;
        commit;  
    end locator_populate;
    
    procedure load_fme_converted(
        p_use_locator_to_convert varchar2 default 'N'
    )
    is
        cursor cur_nodes_to_convert is
            select ipl_uwi, node_id, source, geog_coord_system_id, location_qualifier, node_obs_no, node_position
                , country, province_state, latitude, longitude, target_geog_coord_system_id, target_latitude
                , target_longitude, row_changed_by, row_changed_date, row_created_by, row_created_date
            from fme.well_node_conversion
        ;
        type t_nc is table of cur_nodes_to_convert%rowtype index by binary_integer;
        v_nodes_to_convert  t_nc;
        
        v_done    boolean;
        v_remark  constant ppdm.well_node_version.remark%type := to_char(sysdate, 'yyyy-mm-dd') || ' : AUTO GENERATED NAD27';        

        bulk_errors exception;
        pragma exception_init(bulk_errors, -24381);
    begin
        ppdm_admin.tlm_process_logger.info ('WIM_NAD27 - NAD27 Create Started');
        
        if p_use_locator_to_convert = 'Y' then
            locator_populate;
        end if;
        
        open cur_nodes_to_convert;
        loop
            fetch cur_nodes_to_convert bulk collect into v_nodes_to_convert limit 25;
            v_done := cur_nodes_to_convert%notfound;
            
            begin
                forall i in 1 .. v_nodes_to_convert.count
                save exceptions
                    insert into ppdm.well_node_version (node_id, source, node_obs_no, active_ind, country, geog_coord_system_id, latitude, location_qualifier, longitude
                        , node_position, province_state, remark, row_changed_by, row_changed_date, row_created_by, row_created_date, ipl_uwi
                    )       
                    values (v_nodes_to_convert(i).node_id, v_nodes_to_convert(i).source, v_nodes_to_convert(i).node_obs_no, 'Y', v_nodes_to_convert(i).country, '4267', v_nodes_to_convert(i).target_latitude, 'zTIS:' || v_nodes_to_convert(i).location_qualifier, v_nodes_to_convert(i).target_longitude
                        , v_nodes_to_convert(i).node_position, v_nodes_to_convert(i).province_state, v_remark, v_nodes_to_convert(i).row_changed_by, v_nodes_to_convert(i).row_changed_date, 'WIM_NAD27', sysdate, v_nodes_to_convert(i).ipl_uwi
                    );
                
                for i in  1 .. v_nodes_to_convert.count
                loop
                    wim.wim_rollup.node_rollup(v_nodes_to_convert(i).ipl_uwi, v_nodes_to_convert(i).node_id, v_nodes_to_convert(i).node_position);
                end loop;
            exception
                when bulk_errors then
                    for indx in 1 .. sql%bulk_exceptions.count
                    loop
                        ppdm_admin.tlm_process_logger.error('WIM_NAD27 - NAD27 zTIS Create Error: '
                            || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).node_id
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).source
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).geog_coord_system_id
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).location_qualifier
                            || ', ' || v_nodes_to_convert(sql%bulk_exceptions(indx).error_index).node_obs_no
                            || ' cannot be inserted into ppdm.well_node_version table.'
                        );
                    end loop;
            end;  
            exit when v_done;
        end loop;
        close cur_nodes_to_convert;
        commit;    
    end load_fme_converted;
end nad27_generator;