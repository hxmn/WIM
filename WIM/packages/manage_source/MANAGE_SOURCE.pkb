CREATE OR REPLACE PACKAGE BODY WIM.manage_source
is
  -- insert
  procedure ins(
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
  )
  is
  begin
    insert into ppdm.r_source (
      source, abbreviation, active_ind, effective_date, expiry_date
      , long_name, ppdm_guid, remark, row_source, short_name
      , row_changed_by, row_changed_date, row_created_by
      , row_created_date, row_quality, source_table_name
    )
    values (
      p_source, p_abbreviation, p_active_ind, p_effective_date
      , p_expiry_date, p_long_name, p_ppdm_guid, p_remark
      , p_row_source, p_short_name, p_row_changed_by
      , p_row_changed_date, p_row_created_by, p_row_created_date
      , p_row_quality, p_source_table_name
    );
  end;

  -- update
  procedure upd (
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
  )
  is
  begin
    update r_source
    set abbreviation        = p_abbreviation
      , active_ind          = p_active_ind
      , effective_date      = p_effective_date
      , expiry_date         = p_expiry_date
      , long_name           = p_long_name
      , ppdm_guid           = p_ppdm_guid
      , remark              = p_remark
      , row_source          = p_row_source
      , short_name          = p_short_name
      , row_changed_by      = p_row_changed_by
      , row_changed_date    = p_row_changed_date
      , row_created_by      = p_row_created_by
      , row_created_date    = p_row_created_date
      , row_quality         = p_row_quality
      , source_table_name   = p_source_table_name
    where source = p_source;
  end;

  -- del
  procedure del(
    p_source in r_source.source%type
  )
  is
  begin
    delete from r_source where source = p_source;
  end;
end manage_source;
/