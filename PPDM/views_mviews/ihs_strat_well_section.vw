/***************************************************************************************************
 ihs_strat_well_section  (view)

 20140808 remove hint for cost-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140828 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_strat_well_section;


create or replace force view ppdm.ihs_strat_well_section
(
   UWI,
   STRAT_NAME_SET_ID,
   STRAT_UNIT_ID,
   INTERP_ID,
   ACTIVE_IND,
   APPLICATION_NAME,
   AREA_ID,
   AREA_TYPE,
   CERTIFIED_IND,
   CONFORMITY_RELATIONSHIP,
   DOMINANT_LITHOLOGY,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   INTERPRETER,
   ORDINAL_SEQ_NO,
   OVERTURNED_IND,
   PICK_DATE,
   PICK_DEPTH,
   PICK_DEPTH_OUOM,
   PICK_LOCATION,
   PICK_QUALIFIER,
   PICK_QUALIF_REASON,
   PICK_QUALITY,
   PICK_TVD,
   PICK_VERSION_TYPE,
   PPDM_GUID,
   PREFERRED_PICK_IND,
   REMARK,
   REPEAT_STRAT_OCCUR_NO,
   REPEAT_STRAT_TYPE,
   SOURCE,
   SOURCE_DOCUMENT,
   STRAT_INTERPRET_METHOD,
   TVD_METHOD,
   VERSION_OBS_NO,
   X_BASE_STRAT_UNIT_ID,
   X_BASE_DEPTH,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   X_STRAT_UNIT_ID_NUM
)
AS
   SELECT /*+ use_nl(sws wv) */
         wv."UWI",
          sws."STRAT_NAME_SET_ID",
          sws."STRAT_UNIT_ID",
          sws."INTERP_ID",
          sws."ACTIVE_IND",
          sws."APPLICATION_NAME",
          sws."AREA_ID",
          sws."AREA_TYPE",
          sws."CERTIFIED_IND",
          sws."CONFORMITY_RELATIONSHIP",
          sws."DOMINANT_LITHOLOGY",
          sws."EFFECTIVE_DATE",
          sws."EXPIRY_DATE",
          sws."INTERPRETER",
          sws."ORDINAL_SEQ_NO",
          sws."OVERTURNED_IND",
          sws."PICK_DATE",
          sws."PICK_DEPTH",
          sws."PICK_DEPTH_OUOM",
          sws."PICK_LOCATION",
          sws."PICK_QUALIFIER",
          sws."PICK_QUALIF_REASON",
          sws."PICK_QUALITY",
          sws."PICK_TVD",
          sws."PICK_VERSION_TYPE",
          sws."PPDM_GUID",
          sws."PREFERRED_PICK_IND",
          sws."REMARK",
          sws."REPEAT_STRAT_OCCUR_NO",
          sws."REPEAT_STRAT_TYPE",
          sws."SOURCE",
          sws."SOURCE_DOCUMENT",
          sws."STRAT_INTERPRET_METHOD",
          sws."TVD_METHOD",
          sws."VERSION_OBS_NO",
          sws."X_BASE_STRAT_UNIT_ID",
          sws."X_BASE_DEPTH",
          sws."ROW_CHANGED_BY",
          sws."ROW_CHANGED_DATE",
          sws."ROW_CREATED_BY",
          sws."ROW_CREATED_DATE",
          sws."ROW_QUALITY",
          sws."PROVINCE_STATE",
          sws."X_STRAT_UNIT_ID_NUM"
     FROM strat_well_section@c_talisman_ihsdata sws, well_version wv
    WHERE     sws.uwi = wv.ipl_uwi_local
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y'
;


grant select on ppdm.ihs_strat_well_section to ppdm_ro;