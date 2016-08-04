--
-- sqlldr userid=ppdm_admin/<PASSWORD>@petdev control=loader.ctl log=loader.log
-- sqlldr userid=ppdm_admin/<PASSWORD>@petdev control=loader.ctl log=loader.log bad=loader.bad discard=loader.dsc
--
load data
infile *
badfile loader.bad
discardfile loader.dsc
append into table mdsys.sdo_coord_op_param_vals fields terminated by ',' trailing nullcols (
    coord_op_id,
    coord_op_method_id,
    parameter_id,
    parameter_value,
    param_value_file_ref,
    clob_filename filler char,
    param_value_file lobfile(clob_filename) terminated by eof,
    param_value_xml,
    uom_id
)
begindata
1313,9615,8656,,NTv2_0.gsb,NTV2_0_NRCAN.gsa,,,
1693,9615,8656,,NTv2_0.gsb,NTV2_0_NRCAN.gsa,,,
1319,9615,8656,,NTv2_0.gsb,NTV2_0_NRCAN.gsa,,,