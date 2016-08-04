create or replace procedure ba_sync(p_loader varchar2)
as
    v_sql         varchar2(32767);
    v_link        varchar2(100);
    v_source      varchar2(50);
    v_ipl_xaction varchar2(50);
    v_active_ind  varchar2(50);
begin
    ppdm_admin.tlm_process_logger.info('BA_SYNC: START - ' || p_loader);
    
    if p_loader = 'WIM_LOADER_IHS_CDN' then
        v_link := 'c_talisman_ihsdata';
        v_source := 'source';
        v_ipl_xaction := 'ba_group as ipl_xaction_code';
        v_active_ind := 'active_ind';
    elsif p_loader = 'WIM_LOADER_IHS_US' then
        v_link := 'c_talisman_us_ihsdataq';
        v_source := 'source';
        v_ipl_xaction := 'ba_group as ipl_xaction_code';
        v_active_ind := 'active_ind';
    elsif p_loader = 'WIM_LOADER_IHS_INT' then
        v_link := 'c_tlm_probe';
        v_source := q'['500PRB']';
        v_ipl_xaction := 'ipl_xaction_code';
        v_active_ind := q'['Y']';
    end if;
    
    if p_loader <> 'WIM_LOADER_IHS_INT' then
        v_sql := '
            merge into ppdm.r_ba_category o using (
                select ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality, action_flag
                from (
                    select ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                        , count(*) over(partition by ba_category) - sum(s_cnt) + sum(t_cnt) as action_flag
                        , row_number() over(partition by ba_category order by sum(t_cnt)) as rn
                    from (
                        select ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                            , 1 t_cnt, 0 s_cnt
                        from ppdm.r_ba_category o
                        union all
                        select ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                            , 0 t_cnt, 1 s_cnt
                        from r_ba_category@' || v_link || ' n
                    )
                    group by ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                    having sum(t_cnt) <> sum(s_cnt)
                )
                where rn = 1 and action_flag <> 2
            ) n on (o.ba_category = n.ba_category and n.action_flag > 0)
            when matched then
                update set abbreviation=n.abbreviation, effective_date=n.effective_date, expiry_date=n.expiry_date, long_name=n.long_name, ppdm_guid=n.ppdm_guid, remark=n.remark, short_name=n.short_name, source=n.source, row_changed_by=n.row_changed_by, row_changed_date=n.row_changed_date, row_created_by=n.row_created_by, row_created_date=n.row_created_date, row_quality = n.row_quality
                --delete where n.action_flag = 2
                when not matched then
                insert (ba_category, abbreviation, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality)
                values (n.ba_category, n.abbreviation, n.effective_date, n.expiry_date, n.long_name, n.ppdm_guid, n.remark, n.short_name, n.source, n.row_changed_by, n.row_changed_date, n.row_created_by, n.row_created_date, n.row_quality)
        ';
        
        execute immediate v_sql;
        
        ppdm_admin.tlm_process_logger.info('BA_SYNC: ' || p_loader || ', ' || to_char(sql%rowcount) || ' records merged into ba_category');
    
        v_sql := '
            merge into ppdm.r_ba_status o using (
                select ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  action_flag
                from (
                    select ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                        ,  count(*) over(partition by ba_status)
                        - sum(s_cnt) + sum(t_cnt) action_flag
                        ,  row_number() over(partition by ba_status order by sum(t_cnt)) as rn
                    from (
                        select ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  1 t_cnt,  0 s_cnt
                        from ppdm.r_ba_status o
                        union all
                        select ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  0 t_cnt,  1 s_cnt
                        from r_ba_status@' || v_link || ' n
                    )
                    group by ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                    having sum(t_cnt) <> sum(s_cnt)
                )
                where rn = 1 and action_flag <> 2
            ) n on (o.ba_status=n.ba_status and n.action_flag > 0)
            when matched then
                update set abbreviation = n.abbreviation, active_ind = n.active_ind, effective_date = n.effective_date, expiry_date = n.expiry_date, long_name = n.long_name, ppdm_guid = n.ppdm_guid, remark = n.remark, short_name = n.short_name, source = n.source, row_changed_by = n.row_changed_by, row_changed_date = n.row_changed_date, row_created_by = n.row_created_by, row_created_date = n.row_created_date, row_quality = n.row_quality
                --delete where n.action_flag = 2
                when not matched then
                    insert (ba_status, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality)
                    values (n.ba_status, n.abbreviation, n.active_ind, n.effective_date, n.expiry_date, n.long_name, n.ppdm_guid, n.remark, n.short_name, n.source, n.row_changed_by, n.row_changed_date, n.row_created_by, n.row_created_date, n.row_quality)
        ';
    
        execute immediate v_sql;
    
        ppdm_admin.tlm_process_logger.info('BA_SYNC: ' || p_loader || ', ' || to_char(sql%rowcount) || ' records merged into ba_status');
    
        v_sql := '
            merge into ppdm.r_ba_type o using (
                select ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  action_flag
                from (
                    select ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                        ,  count(*) over(partition by ba_type)
                        - sum(s_cnt) + sum(t_cnt) action_flag
                        ,  row_number() over(partition by ba_type order by sum(t_cnt)) as rn
                    from (
                        select ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  1 t_cnt,  0 s_cnt
                        from ppdm.r_ba_type o
                        union all
                        select ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  0 t_cnt,  1 s_cnt
                        from r_ba_type@' || v_link || ' n
                    )
                    group by ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                    having sum(t_cnt) <> sum(s_cnt)
                )
                where rn = 1 and action_flag <> 2
            ) n on (o.ba_type=n.ba_type and n.action_flag > 0)
            when matched then
                update set abbreviation = n.abbreviation, active_ind = n.active_ind, effective_date = n.effective_date, expiry_date = n.expiry_date, long_name = n.long_name, ppdm_guid = n.ppdm_guid, remark = n.remark, short_name = n.short_name, source = n.source, row_changed_by = n.row_changed_by, row_changed_date = n.row_changed_date, row_created_by = n.row_created_by, row_created_date = n.row_created_date, row_quality = n.row_quality
                --delete where n.action_flag = 2
                when not matched then
                    insert (ba_type, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, short_name, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality)
                    values (n.ba_type, n.abbreviation, n.active_ind, n.effective_date, n.expiry_date, n.long_name, n.ppdm_guid, n.remark, n.short_name, n.source, n.row_changed_by, n.row_changed_date, n.row_created_by, n.row_created_date, n.row_quality)
        ';
        
        execute immediate v_sql;
        
        ppdm_admin.tlm_process_logger.info('BA_SYNC: ' || p_loader || ',  ' || to_char(sql%rowcount) || ' records merged into ba_type');
    end if;
    
    v_sql := '
        merge into ppdm.r_source o using (
            select source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  action_flag
            from (
                select source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                    ,  count(*) over(partition by source)
                    - sum(s_cnt) + sum(t_cnt) action_flag
                    ,  row_number() over(partition by source order by sum(t_cnt)) as rn
                from (
                    select source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  1 t_cnt,  0 s_cnt
                    from ppdm.r_source o
                    union all
                    select source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality,  0 t_cnt,  1 s_cnt
                    from r_source@' || v_link || ' n
                )
                group by source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
                having sum(t_cnt) <> sum(s_cnt)
            ) where rn = 1 and action_flag <> 2
        ) n
        on (o.source=n.source and n.action_flag > 0)
        when matched then
            update set abbreviation = n.abbreviation, active_ind = n.active_ind, effective_date = n.effective_date, expiry_date = n.expiry_date, long_name = n.long_name, ppdm_guid = n.ppdm_guid, remark = n.remark, row_source = n.row_source, short_name = n.short_name, row_changed_by = n.row_changed_by, row_changed_date = n.row_changed_date, row_created_by = n.row_created_by, row_created_date = n.row_created_date, row_quality = n.row_quality
            --delete where n.action_flag = 2
            when not matched then
                insert (source, abbreviation, active_ind, effective_date, expiry_date, long_name, ppdm_guid, remark, row_source, short_name, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality)
                values (n.source, n.abbreviation, n.active_ind, n.effective_date, n.expiry_date, n.long_name, n.ppdm_guid, n.remark, n.row_source, n.short_name, n.row_changed_by, n.row_changed_date, n.row_created_by, n.row_created_date, n.row_quality)
    ';
    
    execute immediate v_sql;

    ppdm_admin.tlm_process_logger.info('BA_SYNC: ' || p_loader || ', ' || to_char(sql%rowcount) || ' records merged into r_source');
    
    -- No table @ihs for ba_contact_info, it is part of the foreign key BA_BACI_FK	refrences PPDM	BA_CONTACT_INFO
    
    execute immediate 'alter trigger T_BUSINESS_ASSOCIATE disable';
    
    v_sql := '
        merge into ppdm.business_associate o using (
            select business_associate, active_ind, ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source
                , current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, source, row_changed_by
                , row_changed_date, row_created_by, row_created_date, row_quality, ipl_xaction_code
                , action_flag
            from (
                select business_associate, active_ind, ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source
                    , current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, source, row_changed_by
                    , row_changed_date, row_created_by, row_created_date, row_quality, ipl_xaction_code
                    , count(*) over(partition by business_associate) - sum(s_cnt) + sum(t_cnt) as action_flag
                    , row_number() over(partition by business_associate order by sum(t_cnt)) as rn
                from (
                    select business_associate, active_ind, ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source
                        , current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, source, row_changed_by
                        , row_changed_date, row_created_by, row_created_date, row_quality, ipl_xaction_code
                        , 1 t_cnt, 0 s_cnt
                    from  ppdm.business_associate
                    union all
                    select business_associate, ' || v_active_ind || ', ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source
                        , current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, ' || v_source || ', row_changed_by
                        , row_changed_date, row_created_by, row_created_date, row_quality, ' || v_ipl_xaction || '
                        , 0 t_cnt, 1 s_cnt
                    from business_associate@' || v_link || ' n
                )
                group by business_associate, active_ind, ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source
                    , current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, source, row_changed_by
                    , row_changed_date, row_created_by, row_created_date, row_quality, ipl_xaction_code
                having sum(t_cnt) <> sum(s_cnt)
            )
            where rn = 1 and action_flag <> 2
        ) n on (o.business_associate=n.business_associate and n.action_flag > 0)
        when matched then update set active_ind=n.active_ind, ba_abbreviation=n.ba_abbreviation, ba_category=n.ba_category, ba_code=n.ba_code, ba_name=n.ba_name, ba_short_name=n.ba_short_name, ba_type=n.ba_type, credit_check_date=n.credit_check_date, credit_check_ind=n.credit_check_ind, credit_check_source=n.credit_check_source, credit_rating=n.credit_rating, credit_rating_source=n.credit_rating_source, current_status=n.current_status, effective_date=n.effective_date, expiry_date=n.expiry_date, first_name=n.first_name, last_name=n.last_name, main_email_address=n.main_email_address, main_fax_num=n.main_fax_num, main_phone_num=n.main_phone_num, main_web_url=n.main_web_url, middle_initial=n.middle_initial, ppdm_guid=n.ppdm_guid, remark=n.remark, source=n.source, row_changed_by=n.row_changed_by, row_changed_date=n.row_changed_date, row_created_by=n.row_created_by, row_created_date=n.row_created_date, row_quality=n.row_quality, ipl_xaction_code=n.ipl_xaction_code
        --delete where n.action_flag = 2
        when not matched then insert (business_associate, active_ind, ba_abbreviation, ba_category, ba_code, ba_name, ba_short_name, ba_type, credit_check_date, credit_check_ind, credit_check_source, credit_rating, credit_rating_source, current_status, effective_date, expiry_date, first_name, last_name, main_email_address, main_fax_num, main_phone_num, main_web_url, middle_initial, ppdm_guid, remark, source, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality, ipl_xaction_code)
            values(n.business_associate, n.active_ind, n.ba_abbreviation, n.ba_category, n.ba_code, n.ba_name, n.ba_short_name, n.ba_type, n.credit_check_date, n.credit_check_ind, n.credit_check_source, n.credit_rating, n.credit_rating_source, n.current_status, n.effective_date, n.expiry_date, n.first_name, n.last_name, n.main_email_address, n.main_fax_num, n.main_phone_num, n.main_web_url, n.middle_initial, n.ppdm_guid, n.remark, n.source, n.row_changed_by, n.row_changed_date, n.row_created_by, n.row_created_date, n.row_quality, n.ipl_xaction_code)
    ';
    
    execute immediate v_sql;
    
    ppdm_admin.tlm_process_logger.info('BA_SYNC: ' || p_loader || ', ' || to_char(sql%rowcount) || ' records merged into business_associate');
    
    execute immediate 'alter trigger T_BUSINESS_ASSOCIATE enable';
    
    ppdm_admin.tlm_process_logger.info('BA_SYNC: FINISH - ' || p_loader);
exception
    when others then
        ppdm_admin.tlm_process_logger.fatal('BA_SYNC - Merge Failed, Error #: ' || sqlcode || ' - ' || dbms_utility.format_error_stack);
        ppdm_admin.tlm_process_logger.info('BA_SYNC: FINISH - ' || p_loader);
end;
/