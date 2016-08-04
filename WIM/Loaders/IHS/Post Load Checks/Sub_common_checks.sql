	-- SCRIPT: Sub_common_checks.sql
--
-- PURPOSE:
--   This is a sub-script of the Load_check_* scripts.
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and settings have already been defined by the master script.
--
-- HISTORY:
--   31-Aug-09  R. Masterman  Factored out of the main scripts to make maintenance easier
--    8-Sep-09  R. Masterman  Restructured for use with database specific load checks
--   18-Sep-09  R. Masterman  Changed reference checks to use LOAD schema rather than prod.
--                            Added counts for BAs and well states to compare test and prod
--   29-Sep-09  R. Masterman  Improved queries as taking too long with PROBE checks
--   04-Mar-10  R. Masterman  Extended status check to include both load and target schema data
--   13-May-11  R. Masterman  Removed check for special characters - doesn't matter now iWIM in service


--  ... From main script

-------------------------------------------------
--  Collect some basic stats on the loaded data
--    Simple counts for reference
-------------------------------------------------

Select count (1) as "Total Business Associates"
  from &&load_schema..business_associate&&load_link;

Select count (1) as "Total Well States"
  from &&load_schema..R_well_status&&load_link;

-- Source summaries - can compare to see only this source has changed
select count (1) cnt, source
  from &&load_schema..well_version&&load_link
 group by rollup(source)
 order by source;

--------------------------------------------------------------
--  Check for incomplete records in the load data
--------------------------------------------------------------

-- List wells with a NULL well name - Expect None
Select uwi as "Null Well Name"
 from &&load_schema..well_version&&load_link
where well_name is null
  and source = '&&source';

--  List wells to be loaded with NULL IPL_UWI_Local - Expect None
Select uwi as "Null IPL_UWI_local"
 from &&load_schema..well_version&&load_link
where ipl_uwi_local is null
  and source = '&&source';

--  Count wells to be loaded with NULL Operator - Will be quite a few for older wells
--                                                Normally around 79K
Select count (1) as "Null Operators"
 from &&load_schema..well_version&&load_link
where operator is null
  and source = '&&source';

--  Count wells to be loaded with NULL Current_Status - Preferably ZERO, but sometimes a few
--                                                      Normally around 10
Select count (1) as "Null Status"
 from &&load_schema..well_version&&load_link
where current_status is null
  and source = '&&source';

--  Count wells with no surface node - Preferably ZERO, but there may be a a few hundred
select count (1) as "Null Surface Node"
 from &&load_schema..well_version&&load_link
where surface_node_id is null
  and source = '&&source';

--  Count wells with no base node - Preferably ZERO, sometimes there can be quite a few
select count (1) as "Null Base Node"
  from &&load_schema..well_version&&load_link
 where base_node_id is null
  and source = '&&source';


------------------------------------------------------------------
--  Check integrity and conventions within the load data
------------------------------------------------------------------

-- List any wells that are to be deleted without leaving an alias entry - Expect NONE
select uwi as "Missing alias entries"
  from (select uwi
  	  from &&control_schema..well_version&&control_link
	 where source = '&&source'
         minus
        select uwi
          from &&load_schema..well_version&&load_link
	 where source = '&&source'
       ) Deleted_Wells
 minus
select well_alias
  from &&control_schema..well_alias&&control_link
 where source = '&&source'
   and (alias_type = 'UWI'
     or alias_type = 'UWI_PRIOR');

--  Count wells that don't follow the base node id numbering convention - Expect ZERO
select count(1) as "Invalid Base Node ids"
  from &&load_schema..well_version&&load_link
 where base_node_id != concat(UWI,'0')
   and source = '&&source';

--  Count wells that don't follow the surface node id numbering convention - Expect ZERO
--  NOTE: Extended to allow surface nodes to point to the base node too, as this seems to be allowed.
select count(1) as "Invalid Surface Node ids"
  from &&load_schema..well_version&&load_link
 where surface_node_id != concat(UWI,'1')
   and surface_node_id != concat(UWI,'0')
   and source = '&&source';
    
-- Count base nodes that are referenced by a well but don't exist as a node version - ideally none but usually a few still get loaded
select uwi as "Wells missing base nodes", source, base_node_id
  from &&load_schema..well_version&&load_link
 where source = '&&source'
   and base_node_id in (select base_node_id as "node_id"
                          from &&load_schema..well_version&&load_link
                         where source = '&&source'
                        minus
                        select node_id
                          from &&load_schema..well_node_version&&load_link
                         where source = '&&source'
                           and node_position = 'B'
                        );

-- List surface nodes that are referenced by a well but don't exist as a node version - ideally none but usually a few still get loaded
-- NOTE: Extended to allow for surface nodes that reference the base node instead as this seems to be allowed
select uwi as "Wells missing surface nodes", source, surface_node_id
  from &&load_schema..well_version&&load_link
 where source = '&&source'
   and surface_node_id in (select surface_node_id as "node_id"
                             from &&load_schema..well_version&&load_link
                            where source = '&&source'
                           minus
                           select node_id
                             from &&load_schema..well_node_version&&load_link
                            where source = '&&source'
                           );

-- List wells that don't have a corresponding license entry - Expect NONE
select uwi as "Wells with no license"
 from &&load_schema..well_version&&load_link
where source = '&&source'
minus
select uwi
  from &&load_schema..well_license&&load_link;

-- List wells that have been merged but now appear as active again - Ideally ZERO but ...
--
-- 300 Load - normally none, but may be one or two
--
--
-- FOR 500PRB load - expect the following wells to be identified - 
-- pls ignore as merge candidates
-- Active well                    also merged to       merge date
------------------------------ -------------------- -----------
-- 1000000397                     2000803443           25-MAY-2009
-- 1000026789                     2000813202           18-JUN-2009
-- 1000026076                     2000813209           19-JUN-2009
-- 1000000459                     2000813200           17-JUN-2009
-- 1000000563                     2000813208           19-JUN-2009
-- 1000000589                     2000813206           18-JUN-2009
-- 1000000578                     2000813207           18-JUN-2009
-- 1000000832                     2000813204           18-JUN-2009
-- 1000000545                     2000813201           18-JUN-2009
-- 1000379136                     50480437000          21-MAY-2008
-- 1000346090                     2000813203           18-JUN-2009
-- 1000353639                     50480426000          16-MAY-2008
-- 1000347275                     50480422000          16-MAY-2008
-- 1000361644                     50480428000          16-MAY-2008
-- 1000354776                     50480427000          16-MAY-2008
-- 1000183519                     2000813429           08-MAR-2010

select substr(well_alias,1,30) as "Active well", uwi as "also merged to", row_changed_date as "merge date", reason_type
  from &&load_schema..well_alias&&load_link
 where alias_type = 'UWI_PRIOR'
   and source = '&&source'
   and well_alias in (select uwi
                        from &&load_schema..well_version&&load_link
                       where source = '&&source'
                         and active_ind != 'N');

-- Find any wells from this source that appear to be in more than one country
select wv1.uwi as uwi, wv1.country as Country1, wv2.country as Country2 
  from &&load_schema..well_version&&load_link wv1, &&load_schema..well_version&&load_link wv2
 where wv1.uwi = wv2.uwi
   and wv1.country != wv2.country
   and (wv1.source = '&&source'
        OR wv2.source = '&&source');

--------------------------------------------------------------------
--  Look for any references that are not in the IHS ref. tables
--  These should have been resolved in the test stage. If you still
--  find any, get them corrected or add them to the TLM versions of
--  the tables in PET*
--------------------------------------------------------------------
  
--  New Current Status reference values - Expect None
select current_status as "New Well Status values"
  from &&load_schema..well_version&&load_link
 where source = '&&source'
 minus
(select status
  from &&load_schema..r_well_status&&load_link
 union
 select status
  from &&control_schema..r_well_status&&control_link)
;

--  New Operator reference values - Expect single NULL row
select operator as "New operators"
  from &&load_schema..well_version&&load_link
 where source = '&&source'
 minus
select business_associate
  from &&load_schema..business_associate&&load_link;

--  New Licensee reference values - Expect single NULL row
select licensee as "New licensees"
  from &&load_schema..well_license&&load_link
 where source =  '&&source'
minus
select business_associate
  from &&load_schema..business_associate&&load_link;

--  Return to main script ...

