

DROP MATERIALIZED VIEW PPDM.WELL_LICENSE;
CREATE MATERIALIZED VIEW PPDM.WELL_LICENSE 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOCACHE
NOLOGGING
NOPARALLEL
BUILD IMMEDIATE
USING INDEX
            TABLESPACE PPDMINDEX
            PCTFREE    10
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          1M
                        NEXT             1040K
                        MINEXTENTS       1
                        MAXEXTENTS       UNLIMITED
                        PCTINCREASE      0
                        FREELISTS        1
                        FREELIST GROUPS  1
                        BUFFER_POOL      DEFAULT
                       )
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2010/05/29 15:15 (Formatter Plus v4.8.8) */
SELECT w.uwi, w.license_id, w.SOURCE, w.active_ind, w.AGENT, w.application_id,
       w.authorized_strat_unit_id, w.bidding_round_num, w.contractor,
       w.direction_to_loc, w.direction_to_loc_ouom, w.distance_ref_point,
       w.distance_to_loc, w.distance_to_loc_ouom, w.drill_rig_num,
       w.drill_slot_no, w.drill_tool, w.effective_date, w.exception_granted,
       w.exception_requested, w.expired_ind, w.expiry_date, w.fees_paid_ind,
       w.licensee, w.licensee_contact_id, w.license_date, w.license_num,
       w.no_of_wells, w.offshore_completion_type, w.permit_reference_num,
       w.permit_reissue_date, w.permit_type, w.platform_name, w.ppdm_guid,
       w.projected_depth, w.projected_depth_ouom, w.projected_strat_unit_id,
       w.projected_tvd, w.projected_tvd_ouom, w.proposed_spud_date, w.purpose,
       w.rate_schedule_id, w.regulation, w.regulatory_agency,
       w.regulatory_contact_id, w.remark, w.rig_code, w.rig_substr_height,
       w.rig_substr_height_ouom, w.rig_type, w.section_of_regulation,
       w.strat_name_set_id, w.surveyor, w.target_objective_fluid,
       w.ipl_projected_strat_age, w.ipl_alt_source, w.ipl_xaction_code,
       w.row_changed_by, w.row_changed_date, w.row_created_by,
       w.row_created_date, w.ipl_well_objective, w.row_quality
  FROM well_license@"TLM37.WORLD" w;

COMMENT ON TABLE PPDM.WELL_LICENSE IS 'snapshot table for snapshot PPDM.WELL_LICENSE';

CREATE UNIQUE INDEX PPDM.WLIC_PK ON PPDM.WELL_LICENSE
(UWI, LICENSE_ID, SOURCE)
NOLOGGING
TABLESPACE PPDMINDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1040K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

GRANT SELECT ON PPDM.WELL_LICENSE TO AMT_READ;

GRANT SELECT ON PPDM.WELL_LICENSE TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.WELL_LICENSE TO PPDM_BROWSE;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_LICENSE TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_LICENSE TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_LICENSE TO PPDM_READ;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_LICENSE TO PPDM_WRITE;

GRANT INSERT, SELECT ON PPDM.WELL_LICENSE TO SDP;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_LICENSE TO SDP_PPDM;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_LICENSE TO UPDATE_OBJECTS;
