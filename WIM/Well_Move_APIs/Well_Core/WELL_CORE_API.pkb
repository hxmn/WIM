CREATE OR REPLACE PACKAGE BODY WIM.well_core_api
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Move dependent/associated well-data from one well to another. Basically, update the well-id in the associated records.
  Move data in Well Core tables

  Procedure does NOT COMMIT the change to allow caller to apply as part of wider transaction.

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   Typically, this is invoked by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE, when the last active well version is moved
   @param  pold_tlm_id - the original/old id of the well-version to be moved
   @param  pnew_tlm_id - the target/new id of well-version to be moved

 HISTORY:
   0.1    xx-xxx-xxx  -unknown- Initial version
   0.2    2015-11-05  kxedward  QC555/QC1480 - update External Dependencies and related move API's


 --------------------------------------------------------------------------------------------------------------------*/

  procedure tlm_id_change (
    pold_tlm_id   in  varchar2, 
    pnew_tlm_id   in  varchar2
  )
  is
      v_detail    varchar2(2000);
  begin
    -- Add a new record to parent tables first, so child record can be modified
    insert into ppdm.tlm_well_core (
      select pnew_tlm_id, source, core_id, active_ind, analysis_report, base_depth, base_depth_ouom, contractor, core_barrel_size, core_barrel_size_ouom
             , core_diameter,core_diameter_ouom, core_handling_type, core_oriented_ind, core_show_type, core_type, coring_fluid, digit_avail_ind
             , effective_date, expiry_date, gamma_correlation_ind, operation_seq_no, ppdm_guid, primary_core_strat_unit_id
             , recovered_amount, recovered_amount_ouom, recovered_amount_uom, recovery_date
             , remark, reported_core_num, run_num, shot_recovered_count, sidewall_ind, strat_name_set_id, top_depth, top_depth_ouom
             , total_shot_count, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
        from ppdm.tlm_well_core
       where uwi = pold_tlm_id
    );

    v_detail := ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE records moved';

    insert into ppdm.well_core_analysis (
      select pnew_tlm_id, source, core_id, analysis_obs_no, active_ind, analysis_date, analyzing_company, analyzing_company_loc, analyzing_file_num
             , core_analyst_name, effective_date, expiry_date, ppdm_guid, primary_sample_type, remark,  sample_diameter, sample_diameter_ouom, sample_length
             , sample_length_ouom, sample_shape, second_sample_type, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
        from ppdm.well_core_analysis
       where uwi = pold_tlm_id
    );

    v_detail := v_detail || ', ' || chr(10) || SQL%ROWCOUNT || ' WELL_CORE_ANALYSIS records moved.';

    insert into ppdm.tlm_well_core_sample_anal (
      select pnew_tlm_id, source, core_id, analysis_obs_no, sample_num, sample_analysis_obs_no, active_ind, bulk_density, bulk_density_ouom
             , bulk_mass_oil_sat, bulk_mass_oil_sat_ouom, bulk_mass_sand_sat,bulk_mass_sand_sat_ouom, bulk_mass_water_sat, bulk_mass_water_sat_ouom
             , bulk_volume_oil_sat, bulk_volume_water_sat, confine_perm_pressure, confine_perm_pressure_ouom, confine_por_pressure
             , confine_por_pressure_ouom, confine_sat_pressure, confine_sat_pressure_ouom, effective_date, effective_porosity, expiry_date
             , gas_sat_volume, grain_density, grain_density_ouom, grain_mass_oil_sat, grain_mass_oil_sat_ouom, grain_mass_water_sat
             , grain_mass_water_sat_ouom, interval_depth, interval_depth_ouom, interval_length, interval_length_ouom, k90, k90_ouom
             , k90_qualifier, kmax, kmax_ouom, kmax_qualifier, kvert, kvert_ouom, kvert_qualifier, oil_sat, pore_volume_gas_sat
             , pore_volume_oil_sat, pore_volume_water_sat, porosity, ppdm_guid, remark,  top_depth, top_depth_ouom
             , water_sat, row_changed_by, row_changed_date, row_created_by, row_created_date, row_quality
        from ppdm.tlm_well_core_sample_anal
       where uwi = pold_tlm_id
    );

    v_detail := v_detail || ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE_SAMPLE_ANAL records moved.';


    update ppdm.tlm_well_core_sample_desc
       set uwi = pnew_tlm_id
     where uwi = pold_tlm_id;

    v_detail := v_detail || ', ' || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE_SAMPLE_DESC records moved.';

    delete from ppdm.tlm_well_core_sample_anal
     where uwi = pold_tlm_id;

    delete from ppdm.well_core_analysis
     where uwi = pold_tlm_id;

    delete from ppdm.tlm_well_core
     where uwi = pold_tlm_id;

    ppdm_admin.tlm_process_logger.info('WIM.WELL_CORE_API:  Record moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: ' || pnew_tlm_id ||  v_detail);

  end tlm_id_change;

end well_core_api;
/