-- rename ihs_well_test_contaminant view

rename ihs_well_test_contaminant to ihs_cdn_well_test_contaminant;
alter view  ihs_cdn_well_test_contaminant compile;