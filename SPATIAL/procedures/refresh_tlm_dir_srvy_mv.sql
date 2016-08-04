/**********************************************************************************************************************
 Procedure to refresh the (spatial) Talisman directional survey materialized view used by GIS
 This procedure was created "bundle" together the actions necessary to refresh the mview

 TIS Task 1574  AP PDMS Include AP dir srvy data in GIS dir srvy feature classes

 History
    20150127    cdong   created procedure
    20160622    cdong   QC1847 - update exception handling


 **********************************************************************************************************************/

 --drop procedure SPATIAL.refresh_tlm_dir_srvy_mv ;


CREATE OR REPLACE procedure SPATIAL.refresh_tlm_dir_srvy_mv
as
  --pragma autonomous_transaction;
/*
 Procedure to refresh the (spatial) Talisman directional survey materialized view used by GIS
 This procedure was created "bundle" together the actions necessary to refresh the mview

 TIS Task 1574  AP PDMS Include AP dir srvy data in GIS dir srvy feature classes

 History
    20150127  cdong   created procedure
    20160122  cdong   QC1847 add exception handling

*/
begin

    --call procedure to update the AP dir srvy spatial data stored in local table
    spatial.get_ap_dir_srvy_spatial_data;

    --truncate local (spatial) tlm well dir srvy spatial mv
    execute immediate 'truncate table spatial.tlm_well_dir_srvy_spatial_mv';

    --refresh the (spatial) tlm well dir srvy spatial mv
    ppdm_admin.tlm_mview_util.freshen_mview('SPATIAL', 'TLM_WELL_DIR_SRVY_SPATIAL_MV', 'C');

  exception
    when others then ppdm_admin.tlm_process_logger.error('spatial.refresh_tlm_dir_srvy_mv *** error with procedure: ' || sqlerrm);

end;
/
