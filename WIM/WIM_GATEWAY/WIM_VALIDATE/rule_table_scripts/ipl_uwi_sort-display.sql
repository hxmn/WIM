insert into wim.validate_rule (rule_id, rule_type_cd, rule_short_nm, rule_desc, active_ind
    , failure_level_cd, priority_level_cd, body_code, action_cd, msg_text, rule_order
)
values (705, 'CUSTOM_RULE', 'IPL UWI SORT-DISPLAY', 'Populate ipl_uwi_sort and ipl_uwi_display attributes from the ipl_uwi_local (Government API)'
    , 'Y', 'W', 1, 'wim_validate.ipl_sort_display_trnsf', 'CAU', 'Error creating ipl_uwi_sort/ipl_uwi_display from ipl_uwi_local', 9
)
;

insert all
    into validate_rule_attribute (rule_id, rule_attribute_type_cd, attribute_value)
    values ('705', 'IF_CONDITION', 'country = ''7CN'' and regexp_like(ipl_uwi_local, ''1\d{11}W\d{3}'')')
    
    into validate_rule_attribute (rule_id, rule_attribute_type_cd, attribute_value)
    values ('705', 'TABLE_NAME', 'WIM_STG_WELL_VERSION')
select *
from dual
;