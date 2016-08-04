CREATE OR REPLACE PACKAGE WIM.manage_source
is
  type r_source_rec is record (
    source                  ppdm.r_source.source%type
    , abbreviation          ppdm.r_source.abbreviation%type
    , active_ind            ppdm.r_source.active_ind%type
    , effective_date        ppdm.r_source.effective_date%type
    , expiry_date           ppdm.r_source.expiry_date%type
    , long_name             ppdm.r_source.long_name%type
    , ppdm_guid             ppdm.r_source.ppdm_guid%type
    , remark                ppdm.r_source.remark%type
    , row_source            ppdm.r_source.row_source%type
    , short_name            ppdm.r_source.short_name%type
    , row_changed_by        ppdm.r_source.row_changed_by%type
    , row_changed_date      ppdm.r_source.row_changed_date%type
    , row_created_by        ppdm.r_source.row_created_by%type
    , row_created_date      ppdm.r_source.row_created_date%type
    , row_quality           ppdm.r_source.row_quality%type
    , source_table_name     ppdm.r_source.source_table_name%type
  );
  type r_source_tab is table of r_source_rec;

  -- insert
  procedure ins (
    p_source                in ppdm.r_source.source%type
    , p_abbreviation        in ppdm.r_source.abbreviation%type
    , p_active_ind          in ppdm.r_source.active_ind%type
    , p_effective_date      in ppdm.r_source.effective_date%type
    , p_expiry_date         in ppdm.r_source.expiry_date%type
    , p_long_name           in ppdm.r_source.long_name%type
    , p_ppdm_guid           in ppdm.r_source.ppdm_guid%type
    , p_remark              in ppdm.r_source.remark%type
    , p_row_source          in ppdm.r_source.row_source%type
    , p_short_name          in ppdm.r_source.short_name%type
    , p_row_changed_by      in ppdm.r_source.row_changed_by%type
    , p_row_changed_date    in ppdm.r_source.row_changed_date%type
    , p_row_created_by      in ppdm.r_source.row_created_by%type
    , p_row_created_date    in ppdm.r_source.row_created_date%type
    , p_row_quality         in ppdm.r_source.row_quality%type
    , p_source_table_name   in ppdm.r_source.source_table_name%type
  );
  -- update
  procedure upd(
    p_source                in ppdm.r_source.source%type
    , p_abbreviation        in ppdm.r_source.abbreviation%type
    , p_active_ind          in ppdm.r_source.active_ind%type
    , p_effective_date      in ppdm.r_source.effective_date%type
    , p_expiry_date         in ppdm.r_source.expiry_date%type
    , p_long_name           in ppdm.r_source.long_name%type
    , p_ppdm_guid           in ppdm.r_source.ppdm_guid%type
    , p_remark              in ppdm.r_source.remark%type
    , p_row_source          in ppdm.r_source.row_source%type
    , p_short_name          in ppdm.r_source.short_name%type
    , p_row_changed_by      in ppdm.r_source.row_changed_by%type
    , p_row_changed_date    in ppdm.r_source.row_changed_date%type
    , p_row_created_by      in ppdm.r_source.row_created_by%type
    , p_row_created_date    in ppdm.r_source.row_created_date%type
    , p_row_quality         in ppdm.r_source.row_quality%type
    , p_source_table_name   in ppdm.r_source.source_table_name%type
  );

  -- delete
  procedure del(
    p_source in r_source.source%type
  );
end manage_source;
/