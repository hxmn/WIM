 /*-------------------------------------------------------------------------
    Installer:  well_spatial
    version:    0.0.0.1
    Detail:     Creates the required tables
    Created:    May 23, 2014 - kxedward
    Updated:
    History:
                0.0.0.1 - Initial code
---------------------------------------------------------------------------*/
create database link cws
connect to corpload
identified by corpload
using 'cwsp'
/

create database link edxp
connect to docsadm
identified by docsadm
using 'edxp'
/

create table spatial.well_header_changes (
    tlm_id                    varchar2(20)
    , action_flag             varchar2(1)
    , row_created_by          varchar2(30) default user
    , row_created_date        date default sysdate
    , bh_row_processed        char(1) default 'N'
    , bh_row_processed_date   date default null
    , surf_row_processed      char(1) default 'N'
    , surf_row_processed_date date default null
    , etl_op                  varchar2(1)
    generated always as (
      case
        when action_flag = '0' then 'A'
        when action_flag = '1' then 'U'
        when action_flag = '2' then 'D'
          end
    ) virtual
)
/

create index well_header_changes_tlm_id_idx on spatial.well_header_changes(tlm_id)
/

create table spatial.well_header (
    tlm_id                          varchar2(20)      -- 01
    , talisman_interest_fg          varchar2(1)       -- 34
    , location_population           varchar2(30)      -- 35
    , base_node_id                  varchar2(20)      -- 09
    , bottom_hole_latitude          number(12,7)      -- 18
    , bottom_hole_longitude         number(12,7)      -- 19
    , country                       varchar2(20)      -- 31
    , country_name                  varchar2(60)      -- 20
    , base_coord_system_id          varchar2(20)      -- 36    
    , surface_coord_system_id       varchar2(20)      -- 37
    , status_type                   varchar2(20)      -- 11
    , current_status                varchar2(20)      -- 12
    , status_name                   varchar2(30)      -- 13
    , drill_td                      number(10,5)      -- 22
    , ground_elev                   number(10,5)      -- 23
    , kb_elev                       number(10,5)      -- 24
    , operator                      varchar2(20)      -- 25
    , operator_name                 varchar2(300)     -- 06
    , licensee                      varchar2(20)      -- 26
    , licensee_name                 varchar2(300)     -- 07
    , parent_uwi                    varchar2(20)      -- 03
    , plot_name                     varchar2(80)      -- 05
    , primary_source                varchar2(20)      -- 27
    , province_state                varchar2(20)      -- 28
    , rig_release_date              date              -- 14
    , spud_date                     date              -- 15
    , surface_latitude              number(12,7)      -- 16
    , surface_longitude             number(12,7)      -- 17
    , surface_node_id               varchar2(20)      -- 29    
    , well_name                     varchar2(80)      -- 04
    , ipl_offshore_ind              varchar2(15)      -- 30    
    , uwi_api                       varchar2(20)      -- 02
    , well_num                      varchar2(20)      -- 38
    , td_strat_age                  varchar2(20)      -- 39
    , td_strat_name_set_age         varchar2(20)      -- 40
    , td_strat_name_set_id          varchar2(20)      -- 41
    , td_strat_unit_id              varchar2(20)      -- 42
    , county                        varchar2(20)      -- 43
    , county_name                   varchar2(60)      -- 44
    , surface_location_accuracy     number            -- 45
    , bottom_hole_location_accuracy number            -- 33
    , location_qa_document          integer           -- 32
    , tlm_symbol                    varchar2(100)     -- 21
    , gov_well_license_cd           varchar2(20)      -- 08
    , cws_primary_fluid_type        varchar2(20)      -- 10
    , cws_operating_area_cd         varchar2(30)      -- 47
    , cws_co_operated_flag          varchar2(1)       -- 48
    , cws_co_contract_operated_flag varchar2(1)       -- 49
    , cws_county_district_cd        varchar2(15)      -- 50
    , cws_company_interest_percent  number            -- 46
    , cws_facility_no               varchar2(30)      -- 51
    , cws_formation_name            varchar2(20)      -- 52
    , cws_producing_formation_cd    varchar2(20)      -- 53
    , cws_well_license_eff_dt       date              -- 54
    , cws_gov_well_license_cd       varchar2(20)      -- 55
    , constraint well_header_pk primary key (tlm_id)
)
/

/*--------------------------------------------------------------------------------------------------
Script: well_spatial_mv

History: 
	March 8, 2013			Updated to show well_name as plot_name if Plot_name is Null
	2014-01-10	cdong		TIS Tasks 1031, 1273, and 1357  
							Modify materialized view SPATIAL.WELL_SPATIAL_MV to include additional columns
								talisman_interest_fg
								location_population
								base_coord_system_id (replacing coord_system_id_orig)
								surface_coord_system_id (replacing coord_system_id)
								surface_location_accuracy
								bottom_hole_location_accuracy
								location_qa_document
	2014-03-19	kxedward	Cloned gis_attributes.xref_well_symbol table to ppdm.r_xref_well_symbol
                            Added join to ppdm.r_xref_well_symbol table to get tlm_symbol attribute
                            Added required CWS columns:
                                 cws_primary_fluid_type
                                 cws_co_operated_flag
                                 cws_co_contract_operated_flag
                                 cws_county_district_cd
                                 cws_facility_no
                                 cws_formation_name
                                 cws_producing_formation_cd
                                 cws_well_license_eff_dt
                            Removed attributes;
                                active_ind
                                latest_date
----------------------------------------------------------------------------------------------------*/
create materialized view spatial.well_header_mv nologging
as
select
    w.uwi                                                                       as tlm_id
    , case wv.uwi when null then 'N' else 'Y' end                               as talisman_interest_fg
    , case
        when bn.node_id is null and sn.node_id is not null then 'SURFACE'
        when bn.node_id is not null and sn.node_id is null then 'BASE'
        else 'BOTH'
    end                                                                         as location_population
    -- if no bottom hole, get surface node
    , nvl(bn.node_id, sn.node_id)                                               as base_node_id
    , nvl(bn.latitude, sn.latitude)                                             as bottom_hole_latitude
    , nvl(bn.longitude, sn.longitude)                                           as bottom_hole_longitude
    , w.country                                                                 as country
    , c.long_name                                                               as country_name
    -- if no bottom hole, get surface coord sys                            
    , nvl(bn.coord_system_id, sn.coord_system_id)                               as base_coord_system_id
    -- if no surface coord sys, get bottom hole coord sys                    
    , nvl(sn.coord_system_id, bn.coord_system_id)                               as surface_coord_system_id
    , w.status_type                                                             as status_type
    , nvl(w.current_status, '00000000')                                         as current_status
    , nvl(r_ws.short_name, 'UNDEF')                                             as status_name
    , w.drill_td                                                                as drill_td
    , w.ground_elev                                                             as ground_elev
    , w.kb_elev                                                                 as kb_elev
    , w.operator                                                                as operator
    , nvl(ba1.ba_name, w.operator)                                              as operator_name
    , w.ipl_licensee                                                            as licensee
    , nvl(ba2.ba_name, w.ipl_licensee)                                          as licensee_name
    , w.parent_uwi                                                              as parent_uwi
    , nvl(w.plot_name, w.well_name)                                             as plot_name
    , w.primary_source                                                          as primary_source
    , w.province_state                                                          as province_state
    , w.rig_release_date                                                        as rig_release_date
    , w.spud_date                                                               as spud_date
    -- if surface location doesn't exist get bottom hole                    
    , nvl(sn.latitude, bn.latitude)                                             as surface_latitude
    , nvl(sn.longitude, bn.longitude)                                           as surface_longitude
    , nvl(sn.node_id, bn.node_id)                                               as surface_node_id
    , w.well_name                                                               as well_name
    , w.ipl_offshore_ind                                                        as ipl_offshore_ind
    , w.ipl_uwi_local                                                           as uwi_api
    , w.well_num                                                                as well_num
    , w.td_strat_age                                                            as td_strat_age
    , w.td_strat_name_set_age                                                   as td_strat_name_set_age
    , w.td_strat_name_set_id                                                    as td_strat_name_set_id
    , w.td_strat_unit_id                                                        as td_strat_unit_id
    , w.county                                                                  as county
    , rc.long_name                                                              as county_name
    , greatest (
        nvl (
           w.row_changed_date,
           nvl (w.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           sn.row_changed_date,
           nvl (sn.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           bn.row_changed_date,
           nvl (bn.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           c.row_changed_date,
           nvl (c.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           r_ws.row_changed_date,
           nvl (r_ws.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           ba1.row_changed_date,
           nvl (ba1.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           ba2.row_changed_date,
           nvl (ba2.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
        , nvl (
           rc.row_changed_date,
           nvl (rc.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))
        )
    )                                                                           as latest_date
    , w.surface_location_accuracy                                               as surface_location_accuracy
    , w.bottom_hole_location_accuracy                                           as bottom_hole_location_accuracy
    , dm.docnumber                                                              as location_qa_document
    , s.tlm_symbol                                                              as tlm_symbol
    , wl.license_num                                                            as gov_well_license_cd
    , wcd.primary_fluid_type_cd                                                 as cws_primary_fluid_type
    , wcd.operating_area_cd                                                     as cws_operating_area_cd
    , wcd.company_operated_flag                                                 as cws_co_operated_flag
    , wcd.company_contract_operated_flag                                        as cws_co_contract_operated_flag
    , wcd.county_district_cd                                                    as cws_county_district_cd
    , wci.company_interest_percent                                              as cws_company_interest_percent
    , wcd.wbs_code                                                              as cws_facility_no
    , cwl.licensed_formation_cd                                                 as cws_formation_name
    , cw.producing_formation_cd                                                 as cws_producing_formation_cd
    , cwl.well_license_eff_dt                                                   as cws_well_license_eff_dt
    , case w.primary_source
        when '100TLM' then cwl.gov_well_license_cd
        else null
    end                                                                         as cws_gov_well_license_cd
from ppdm.well w
inner join ppdm.r_country c on w.country = c.country
-- ensure that coord sys is not undefined or null
left join ppdm.well_node sn on (
    w.surface_node_id = sn.node_id 
    and nvl(sn.geog_coord_system_id, '9999') <> '9999'
)
left join ppdm.well_node bn on (
    w.base_node_id = bn.node_id 
    and nvl(bn.geog_coord_system_id, '9999') <> '9999'
)
left join ( 
    select status, max(short_name) as short_name
    , max(row_created_date) as row_created_date
    , max(row_changed_date) as row_changed_date
    from ppdm.r_well_status
    group by status
) r_ws on w.current_status = r_ws.status
left join ppdm.business_associate ba1 on w.operator = ba1.business_associate
left join ppdm.business_associate ba2 on w.ipl_licensee = ba2.business_associate
left join ppdm.r_county rc on (
    w.country = rc.country
    and w.province_state = rc.province_state
    and w.county = rc.county
)
-- to determine if well is of talisman interest (set talisman_interest_fg)
left join ppdm.well_version wv on (
    w.uwi = wv.uwi
    and wv.source = '100TLM'
    and wv.active_ind = 'Y'
)
-- to get the QA document number from DM
left join (
    select p.docnumber, p.docname, p.dm_wells_mv as tlm_well_id
    from docsadm.profile@edxp p
    inner join docsadm.documenttypes@edxp dt on p.documenttype = dt.system_id
    inner join docsadm.forms@edxp f on p.form = f.system_id
    where upper(docname) like '%GEODETIC QA REPORT%'
        and upper(dt.type_id) = 'TECHNICAL'
        and f.form_name = 'WELLFILE_P'
) dm on w.uwi = dm.tlm_well_id
-- xref and symbology
left join ppdm.r_xref_well_symbol s on (
    nvl(r_ws.short_name, 'UNDEF') = s.status
    and s.active_ind = 'Y'
)
left join well_current_data@cws.world wcd on w.uwi = wcd.well_id
left join well@cws.world cw on w.uwi = cw.well_id
left join wellbore_company_interest@cws.world wci on (
    wcd.wellbore_id = wci.wellbore_id
    and wci.reporting_well_exp_dt is null
)
left join ( 
    select uwi, license_num, min(source)
    from ppdm.well_license
    where active_ind = 'Y'
        and source <> '100TLM'
        and rownum = 1
    group by uwi, license_num
) wl on w.uwi = wl.uwi
left join well_license@cws.world cwl on cw.well_license_id = cwl.well_license_id
where (
    -- ensure that some kind of location exists
    nvl(bn.latitude, sn.latitude) is not null
    and nvl(sn.longitude, bn.longitude) is not null
)
-- ensure the well is active
    and w.active_ind = 'Y'
/

comment on materialized view spatial.well_header_mv is 'snapshot table for snapshot spatial.well_header_mv'
/

create unique index well_header_mv_pk on well_header_mv(tlm_id)
/

grant select on spatial.well_header_mv to ppdm_admin;
/

grant select on spatial.well_header_mv to r_spatial;
/

create or replace package spatial.well_headers authid current_user
as
    procedure submit_job (
        p_job_id        number
        , p_job_name    varchar2
    );
    
    procedure get_query (
        p_query     out clob
        , p_target  varchar2 := 'well_header'
        , p_source  varchar2 := 'well_header_mv'
        , p_action  varchar2 := 'M'
    );
    
    procedure load_changes(
        p_tbl   varchar2 := 'well_header'
        , p_src varchar2 := 'well_header_mv'
    );
    
    procedure f_refresh (p_src varchar2 := 'well_header_mv');

    function transform (
        p_template          varchar2
        , p_replace_in      sys.odcivarchar2list
        , p_replace_with    sys.odcivarchar2list
    ) return clob;
    
    procedure load_master_changes(
        p_tbl       varchar2 := 'well_header'
        , p_src     varchar2 := 'well_header_mv'
    );

    procedure load_spatial_changes(
        p_tbl       varchar2 := 'well_header'
        , p_src     varchar2 := 'well_header_mv'
    );
end;
/

create or replace package body spatial.well_headers
as
    g_sid           pls_integer;
    g_err_num       pls_integer;
    g_err_msg       varchar2(4000);
    g_rows          varchar2(50);
    g_query         clob;
    g_f_refresh     boolean := false;
    
    procedure reset_glbl_vars
    is
    begin
        g_sid           := null;
        g_err_num       := null;
        g_err_msg       := null;
        g_rows          := null;
        g_query         := null;
        g_f_refresh     := false;
    end reset_glbl_vars;
    
    procedure submit_job(
        p_job_id        number
        , p_job_name    varchar2
    )
    is
        v_job_id    number := p_job_id;
    begin
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): Job request - Job ID: ' || p_job_id || ' - Command: ' || p_job_name);

        dbms_job.isubmit(
            job => v_job_id,
            what => p_job_name || ';',
            next_date => sysdate,
            interval => null
        );
        commit;
    end submit_job;
    
    procedure load_master_changes(
        p_tbl       varchar2 := 'well_header'
        , p_src     varchar2 := 'well_header_mv'
    )
    is
    begin
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): Retrieving spatial master query');
        get_query (
            p_query     => g_query
            , p_target  => p_tbl
            , p_source  => p_src
            , p_action  => 'M'
        );
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): Executing spatial master query');
        execute immediate g_query;
        g_rows := to_char(sql%rowcount);
        commit;
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): '
            || g_rows || ' updates merged into ' || p_tbl
        );
    end load_master_changes;
    
    procedure load_spatial_changes(
        p_tbl       varchar2 := 'well_header'
        , p_src     varchar2 := 'well_header_mv'
    )
    is
    begin
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): Retrieving spatial changes query');
        get_query (
            p_query     => g_query
            , p_target  => p_tbl
            , p_source  => p_src
            , p_action  => 'C'
        );
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): Executing spatial changes query');
        execute immediate g_query;
        g_rows := to_char(sql%rowcount);
        commit;
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): '
            || g_rows || ' changes inserted into ' || p_tbl
        );
    end load_spatial_changes;
    
    procedure load_changes(
        p_tbl   varchar2 := 'well_header'
        , p_src varchar2 := 'well_header_mv'
    )
    is
    begin
        delete
        from well_header_changes
        where bh_row_processed in ('E', 'Y') and surf_row_processed in ('E', 'Y');
        g_rows := to_char(sql%rowcount);
        commit;
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): '
            || g_rows || ' old processed rows deleted from changes table'
        );
        
        if g_f_refresh <> true then
            ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): well_header_mv refresh started.');
            execute immediate 'drop index well_header_mv_pk';
            ppdm_admin.tlm_mview_util.freshen_mview('SPATIAL', p_src, 'C');
            execute immediate 'create index well_header_mv_pk on well_header_mv(tlm_id)';
            ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): well_header_mv refresh completed.');
            
            load_spatial_changes(p_tbl, p_src);
            load_master_changes(p_tbl, p_src);
            ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || ') - END');
        else
            load_spatial_changes(p_tbl, p_src);
            load_master_changes(p_tbl, p_src);
        end if;
    exception
        when others then
            g_err_num := sqlcode;
            g_err_msg := dbms_utility.format_error_stack;
            ppdm_admin.tlm_process_logger.fatal(
                'SPATIAL.WELL_HEADERS (' || g_sid || '): Refresh Failed, Error #: '
                || g_err_num
                || ' - '
                || g_err_msg
            );
            ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || ') - END');
    end load_changes;

    
    procedure refresh_mv (
        p_mv varchar2
    )
    is
    begin
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADER (' || g_sid || '): ' || p_mv || ' refresh started.');
        execute immediate 'drop index well_header_mv_pk';
        ppdm_admin.tlm_mview_util.freshen_mview('SPATIAL', p_mv, 'C');
        execute immediate 'create index well_header_mv_pk on well_header_mv(tlm_id)';
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADER (' || g_sid || '): ' || p_mv || ' refresh completed.');
    end refresh_mv;
    
    function transform (
        p_template          varchar2
        , p_replace_in      sys.odcivarchar2list
        , p_replace_with    sys.odcivarchar2list
    ) return clob
    is
        v_template clob := p_template;
    begin
        for i in 1 .. p_replace_in.count
        loop
            v_template := replace(v_template, p_replace_in(i), p_replace_with(i));
        end loop;

        return v_template;
    end transform;
    
    procedure get_query (
        p_query     out clob
        , p_target  varchar2 := 'well_header'
        , p_source  varchar2 := 'well_header_mv'
        , p_action  varchar2 := 'M'
    )
    is
        p_template  clob;

        v_main      varchar2(2000) := '
            select #all_cols#
                , count(*) over(partition by #pk_cols#)
                - sum(s_cnt) + sum(t_cnt) action_flag
                , row_number() over(partition by #pk_cols# order by sum(t_cnt)) as rn
            from (
                select #all_cols#, 1 t_cnt, 0 s_cnt
                from #t_target# o
                union all
                select #all_cols#, 0 t_cnt, 1 s_cnt
                from #t_source# n
            )
            group by #all_cols#
            having sum(t_cnt) <> sum(s_cnt)
        ';

        v_replace   varchar2(2000)  := q'[
            , sys.odcivarchar2list(
                '#t_target#','#all_cols#','#pk_cols#', '#t_source#'
                ,'#on_cols#','#set_cols#','#insert_cols#'
            )
            , sys.odcivarchar2list(
                t_target,  all_cols, pk_cols, t_source
                , on_cols, set_cols, insert_cols
            )
        ]';
    begin
        case p_action
            when 'C' then
                g_query := '
                    merge into  spatial.well_header_changes o using (
                        select #pk_cols#, action_flag
                        from (' || v_main || ')
                        where rn = 1
                    ) n
                    on (o.#pk_cols# = n.#pk_cols# and o.bh_row_processed = ''''N'''' or o.surf_row_processed = ''''N'''')
                    when matched then
                        update set row_created_by = user, row_created_date = sysdate
                        , action_flag = case
                            -- unseen Add then Update
                            when n.action_flag = 1 and o.action_flag = 0 then 0
                            -- unseen Delete then Add
                            when n.action_flag = 0 and o.action_flag = 2 then 1
                            -- unseen Update then Delete
                            when n.action_flag = 2 and o.action_flag = 1 then 2
                            -- unseen Add then Delete
                            when n.action_flag = 2 and o.action_flag = 0 then 9
                            else n.action_flag
                        end
                    when not matched then
                        insert (#pk_cols#, action_flag, row_created_by, row_created_date, bh_row_processed, bh_row_processed_date, surf_row_processed, surf_row_processed_date)
                        values (n.tlm_id, n.action_flag, user, sysdate, ''''N'''', null, ''''N'''', null)
                    ''' || v_replace || '
                ';
            when 'M' then
                g_query := '
                    merge into #t_target# o using (
                        select #all_cols#, action_flag
                        from (' || v_main || ')
                        where rn = 1
                    ) n
                    on (#on_cols# and n.action_flag > 0)
                    when matched then
                        update set #set_cols#
                    delete where n.action_flag = 2
                    when not matched then
                        insert (#all_cols#)
                        values (#insert_cols#)
                    ''' || v_replace || '
                ';
            else
                g_query := v_main || '''' || v_replace;
        end case;
        
        p_template := '
            begin
                with input as (
                    select upper(user) as t_target_owner
                        , upper(''' || p_target || ''') as t_target_table_name
                        , upper(''' || p_source || ''') as t_source
                        , upper(user || ''.'' || ''' || p_target || ''') as t_target
                    from dual
                )
                , tab_cols as (
                    select column_name, internal_column_id column_id
                    from all_tab_cols, input
                    where (owner, table_name) = ((t_target_owner, t_target_table_name))
                    order by column_id
                )
                , key_cols as (
                    select column_name, column_position
                    from all_ind_columns, input
                    where (index_owner, index_name) = (
                        select owner, constraint_name
                        from all_constraints
                        where (owner, table_name, constraint_type) = ((t_target_owner, t_target_table_name, ''P''))
                    )
                )
                , col_list as (
                    select wm_concat(column_name) as all_cols
                        , wm_concat(''n.'' || column_name) as insert_cols
                    from tab_cols
                    order by column_id
                )
                , pk_list as (
                    select wm_concat(column_name) as pk_cols
                        , replace(wm_concat(''o.'' || column_name || ''=n.'' || column_name), '','', '' and '') as on_cols
                from key_cols
                )
                , set_list as (
                    select wm_concat(column_name || '' = n.'' || column_name) as set_cols
                    from tab_cols
                    where column_name not in (select column_name from key_cols)
                    order by column_id
                )
                select well_headers.transform(''
                    ' || g_query || '
                ) sql_text into :v_sql_text
                from input, col_list, pk_list, set_list;
            end;
        ';
        execute immediate p_template using out p_query;
    exception
        when others then
            g_err_num := sqlcode;
            g_err_msg := dbms_utility.format_error_stack;
            ppdm_admin.tlm_process_logger.error(
                'SPATIAL.WELL_HEADERS (' || g_sid || '): Load changes - get_query(' || p_action || ') Failed, Error #: '
                || g_err_num
                || ' - '
                || g_err_msg
            );
    end get_query;

    procedure f_refresh (
        p_src varchar2 := 'well_header_mv'
    )
    is
    begin
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): well_header_mv refresh started.');
        execute immediate 'drop index well_header_mv_pk';
        ppdm_admin.tlm_mview_util.freshen_mview('SPATIAL', p_src, 'C');
        execute immediate 'create index well_header_mv_pk on well_header_mv(tlm_id)';
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || '): well_header_mv refresh completed.');
                
        execute immediate 'truncate table spatial.well_header';
        g_f_refresh := true;
        load_changes();
        g_f_refresh := false;
        ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || ') - END');
    exception
        when others then
            g_err_num := sqlcode;
            g_err_msg := dbms_utility.format_error_stack;
            ppdm_admin.tlm_process_logger.fatal(
                'SPATIAL.WELL_HEADERS (' || g_sid || '): Refresh failed, Error #: '
                || g_err_num
                || ' - '
                || g_err_msg
            );
            ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || ') - END');
    end f_refresh;
begin
    reset_glbl_vars;
    select sys_context('userenv','sid') into g_sid from dual;
    ppdm_admin.tlm_process_logger.info('SPATIAL.WELL_HEADERS (' || g_sid || ') - START');
end well_headers;
/

declare
	v_job_exists number;
begin
	select count(*) into v_job_exists
	from user_jobs
    where job = 189;

	if v_job_exists = 0 then
		dbms_job.isubmit(
			job         => 189
			, what      => 'execute immediate ''truncate table spatial.well_header_mv''; ppdm_admin.tlm_mview_util.freshen_mview(''SPATIAL'', ''WELL_HEADER_MV'', ''C'');'-- spatial.well_header.load_changes;'
			, next_date => case when to_char(sysdate, 'hh') > '17' then trunc(sysdate + 1) + 17/24 else trunc(sysdate) + 17/24 end
			, interval  => 'trunc(sysdate + 1) + 17/24'
		);
	end if;
end;
/