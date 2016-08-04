create or replace procedure add_ihs_status (
    p_status            in varchar2
    , p_link            in varchar2
    , p_vendor_r_tbl    in varchar2 := 'r_well_status'
    , p_local_r_tbl     in varchar2 := 'ppdm.r_well_status'
    , p_source          in varchar2 := 'IHSE'
)
is
    v_dynQ  varchar2(2000);
    v_conn  varchar2(500);
    v_link  varchar2(100);
begin
    v_link := case p_link
        when 'US' then 'C_TALISMAN_US_IHSDATAQ'
        else 'C_TALISMAN_IHSDATA'
    end;
    
    v_conn := p_vendor_r_tbl || '@' || v_link;
        
    v_dynQ := '
        insert into ' || p_local_r_tbl || ' (
            status_type, status, abbreviation, active_ind, effective_date
            , expiry_date, long_name, ppdm_guid, remark, short_name, source
            , status_group, row_changed_by, row_changed_date, row_created_by
            , row_created_date, row_quality 
        )    
        select
            status_type, status, abbreviation, active_ind, effective_date
            , expiry_date, long_name, ppdm_guid, remark, short_name, source
            , status_group, row_changed_by, row_changed_date, row_created_by
            , row_created_date, row_quality
        from ' || v_conn || ' 
        where status in (
            select status
            from ' || v_conn || ' 
            -- specify the status(es) to look for 
            where status in (' || p_status || ') 
            -- use the MINUS to confirm the status does not already exist. 
            minus 
            select status
            from ' || p_local_r_tbl || '
            where source = ''' || p_source || '''
        )    
    '; 
    execute immediate v_dynQ;
    commit;
end add_ihs_status;