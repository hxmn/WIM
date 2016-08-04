
--  Test the opld FIND_WELL for DM use

--  Find some examples to search by UWI
select uwi from well_version;  -- No alias
select uwi, well_alias from well_alias where alias_type = 'TLM_ID' order by uwi;  -- Basic alias
select uwi, count(well_alias)
  from well_alias
 where alias_type = 'TLM_ID'
group by uwi
having count(well_alias) > 1;  -- Multiple aliases
select count(1) from well_alias;


--  Valid well with no aliases
select tlm_find_well.find_well_by_uwi('1000') from dual;  -- 1000
select tlm_find_well.find_well_by_uwi('123456') from dual;  -- 123456

-- Old style alias
select tlm_find_well.find_well_by_uwi('50066167000') from dual;  -- NULL - has an alias but the well doesn't exist

-- new style aliases
select tlm_find_well.find_well_by_uwi('50000198030') from dual;  -- 141606
select tlm_find_well.find_well_by_uwi('50000186276') from dual;  -- 143052

-- Has multiple aliases
select tlm_find_well.find_well_by_uwi('2000790314') from dual;  -- 1000014076
select tlm_find_well.find_well_by_uwi('1000285216') from dual;  -- 112021
select tlm_find_well.find_well_by_uwi('0000112021') from dual;  --  112021
select tlm_find_well.find_well_by_uwi('50000247897') from dual;  -- 138528
select tlm_find_well.find_well_by_uwi('1000341505') from dual;  -- 50480102000

--  Has version but inactive, alias points to new well
select tlm_find_well.find_well_by_uwi('142860') from dual;  -- 138528
select tlm_find_well.find_well_by_uwi('1001008330') from dual;  -- 50480102000

-- UWI PRIOR
select tlm_find_well.find_well_by_uwi_prior('1000') from dual;  -- 1000
select tlm_find_well.find_well_by_uwi_prior('2000790314') from dual;  -- 1000014076
select tlm_find_well.find_well_by_uwi_prior('142860') from dual;  -- 138528

-- API
select tlm_find_well.find_well_by_api('15167033900000') from dual;  -- 1004591804
select tlm_find_well.find_well_by_api('A0248450') from dual;  -- 2000813428

-- UWI_LOCAL
select tlm_find_well.find_well_by_uwi_local('15167033900000') from dual;  -- 1004591804
select tlm_find_well.find_well_by_uwi_local('100151607818W600') from dual;  -- 50000267042 

-- WELL_NAME
select tlm_find_well.find_well_by_well_name('KARST15167033900000') from dual;  -- 1004591804
select tlm_find_well.find_well_by_well_name('TEUSA MCCLURE (03-053-03) R 3H') from dual;  -- 144049

-- PLOT_NAME
select tlm_find_well.find_well_by_plot_name('PALMITAS 1') from dual;  -- 1000000005
select tlm_find_well.find_well_by_plot_name('KARST15167033900000') from dual;  -- 1004591804

