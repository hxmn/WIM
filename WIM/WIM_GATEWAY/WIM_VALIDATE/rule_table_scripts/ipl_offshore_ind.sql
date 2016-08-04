insert into wim.validate_rule (rule_id, rule_type_cd, rule_short_nm, rule_desc, active_ind
    , failure_level_cd, priority_level_cd, body_code, action_cd
)
values ('655', 'CUSTOM_RULE', 'IPL Offshore Indicator', 'Change the IPL_OFFSHORE_IND value from a Y/N to OFFSHORE/ONSHORE'
    , 'N', 'W', 1, 'wim_validate.ipl_offshore_ind_trnf', 'CAU'
);

insert all
    into validate_rule_attribute (rule_id, rule_attribute_type_cd, attribute_value)
    values ('655', 'IF_CONDITION', 'upper(ipl_offshore_ind) in (''Y'', ''N'')')
    
    into validate_rule_attribute (rule_id, rule_attribute_type_cd, attribute_value)
    values ('655', 'TABLE_NAME', 'WIM_STG_WELL_VERSION')
select *
from dual
;


select vr.rule_id, vr.rule_type_cd, vr.action_cd, nvl(vr.body_code, vrt.body_code) as body_code, vra.attribute_value, vra.rule_attribute_type_cd
from wim.validate_rule vr
join wim.validate_rule_type vrt on vr.rule_type_cd = vrt.rule_type_cd
join wim.validate_rule_attribute vra on vr.rule_id = vra.rule_id
    and vra.rule_attribute_type_cd in (
        'TABLE_NAME',   --- 
        'IF_CONDITION', -- validate_rule_generic
        'REQ_FIELD_NAME',
        'REF_TABLE_NAME',
        'REF_PK_FIELD_NAME',
        'THEN_CONDITION',
        'CONDITION',          -- condition_check
        'ERR_FIELD_NAME'      -- condition_check
    )
    --    and vra.rule_type_cd = 'CUSTOM_RULE'
    --    and upper (vra.attribute_value) like 'WIM_STG_WELL_VERSION'
where vr.active_ind = 'Y'
    and vr.body_code like '%ipl_offshore_ind_trnf%'
    and vr.priority_level_cd <= 10
;

-- IF_CONDITION
--v_codeblock := 'SELECT COUNT(1) FROM ' || v_table || ' WHERE ' || v_if_condition || ' AND WIM_STG_ID = :pSTG_ID ';
-- if PSEQ is not null then
--v_codeblock := v_codeblock || ' AND WIM_SEQ = ' || pseq;
v_codeblock := 'SELECT COUNT(1) FROM WIM_STG_WELL_VERSION WHERE upper(ipl_offshore_ind) in (''Y'', ''N'') AND WIM_STG_ID = :pSTG_ID AND WIM_SEQ = :pseq';
 
-- if null or v_count = 0 then
/* if this condition is not true there is no reason to process with actual rule*/
v_codeblock := 'CALL ' || pbody_code || '(:p1, :p2, :p3, :p4) INTO :p5';
execute immediate v_codeblock using pstg_id, pseq, prule_id, paudit_id, out v_retvalue;
