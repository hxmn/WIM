-- rename ihs_well_analysis view

rename ihs_well_test_analysis to ihs_cdn_well_test_analysis;
alter view  ihs_cdn_well_test_analysis compile;