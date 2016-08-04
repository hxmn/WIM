-- SCRIPT: COmmon_load_checks.sql
--
-- PURPOSE:
--   This is a sub-script of the Pre_load_checks and the Post_load_checks.
--   It is NOT INTENDED TO BE RUN DIRECTLY as it assumes a number of 
--   variables and setting have already been defined by the master script.
--
-- HISTORY:
--   31-Aug-09  R. Masterman  Factored out of the main scripts to make maintenance easier
--

--  ... From main script

--------------------------------------------------------------
--  Check for incomplete records in the load data
--------------------------------------------------------------

-- List wells with a NULL well name - Expect None
Select uwi as "Null Well Name"
 from &&load_schema..well_version
where well_name is null
  and source = '&&source';

--  List wells to be loaded with NULL IPL_UWI_Local - Expect None
Select uwi as "Null IPL_UWI_local"
 from &&load_schema..well_version
where ipl_uwi_local is null
  and source = '&&source';

--  Count wells to be loaded with NULL Operator - Preferably ZERO, but often quite a few
Select count (1) as "Null Operator"
 from &&load_schema..well_version
where operator is null
  and source = '&&source';

--  Count wells to be loaded with NULL Current_Status - Preferably ZERO, but often quite a few
Select count (1) as "Null Status"
 from &&load_schema..well_version
where current_status is null
  and source = '&&source';

--  Count wells with no surface node - Preferably ZERO, but there may be some
select count (1) as "Null Surface Node"
 from &&load_schema..well_version
where surface_node_id is null
  and source = '&&source';

--  Count wells with no base node - Preferably ZERO, but probably quite a few
select count (1) as "Null Base Node"
  from &&load_schema..well_version
 where base_node_id is null
  and source = '&&source';


------------------------------------------------------------------
--  Check integrity and conventions within the load data
------------------------------------------------------------------

-- List any wells that are to be deleted without leaving an alias entry - Expect NONE
select uwi as "Missing alias entries"
  from (select uwi
  	  from well_version
	 where source = '&&source'
           and uwi not in (select uwi from &&load_schema..well_version)) Deleted_Wells
 where Deleted_Wells.uwi not in (select uwi
                                   from well_alias
				  where source = '&&source');

--  Count wells that don't follow the base node id numbering convention - Expect ZERO
select count(1) as "Invalid Base Node ids"
  from &&load_schema..well_version
 where base_node_id != concat(UWI,'0')
   and source = '&&source';

--  Count wells that don't follow the surface node id numbering convention - Expect ZERO
--  NOTE: Extended to allow surface nodes to point to the base node too, as this seems to be allowed.
select count(1) as "Invalid Surface Node ids"
  from &&load_schema..well_version
 where surface_node_id != concat(UWI,'1')
   and surface_node_id != concat(UWI,'0')
   and source = '&&source';
    
-- Count base nodes that are referenced by a well but don't exist as a node version - expect ZERO
select count(1) as "Missing Base Nodes"
  from (select base_node_id as "node_id"
          from &&load_schema..well_version
         where source = '&&source'
        minus
        select node_id
          from &&load_schema..well_node_version
         where node_position = 'B'
           and source = '&&source'
        );

-- Count surface nodes that are referenced by a well but don't exist as a node version - expect ZERO
-- NOTE: Extended to allow for surface nodes that reference the base node instead as this seems to be allowed
select count(1) as "Missing Surface Nodes"
  from (select surface_node_id as "node_id"
          from &&load_schema..well_version
         where source = '&&source'
        minus
        select node_id
          from &&load_schema..well_node_version
         where source = '&&source'
--         and node_position = 'S'       -- REMOVED to allow base nodes to be reused as surface nodes.
       );

-- List wells that don't have a corresponding license entry - Expect NONE
select uwi as "Wells with no license"
 from &&load_schema..well_version
where source = '&&source'
  and uwi not in (select uwi from &&load_schema..well_license);

-- List old wells that have been merged - Expect ZERO
select uwi as "Merged wells"
  from well_alias
 where alias_type = 'UWI_PRIOR'
   and source = '&&source'
   and well_alias in (select uwi
                        from &&load_schema..well_version
                       where source = '&&source');
  
--------------------------------------------------------------------
--  Look for any references that are not in the IHS ref. tables
--  These should have been resolved in the test stage. If you still
--  find any, get them corrected or add them to the TLM versions of
--  the tables in PET*
--------------------------------------------------------------------
  
--  New Current Status reference values - Expect None
select current_status
  from &&load_schema..well_version
 where source = '&&source'
 minus
select status
  from r_well_status;

--  New Operator reference values - Expect NONE
select operator
  from &&load_schema..well_version
 where source = '&&source'
 minus
select business_associate
  from business_associate;

--  New Licensee reference values - Expect NONE
select licensee
  from &&load_schema..well_license
 where source =  '&&source'
minus
select business_associate
  from business_associate;

--------------------------------------------------------------------------------
-- Check for bad characters in the reference attributes
-- Find any trailing spaces, leading spaces, double spaces, special characters etc.
--------------------------------------------------------------------------------

-- List wells with special characters in the Well Name - Expect NONE
select count(uwi) 
  from &&load_schema..well_version
 where source = '&&source'
   and instr(well_name,'  ') > 0
    or instr(well_name,'@') > 0
    or instr(well_name,'!') > 0
    or instr(well_name,'"') > 0
    or instr(well_name,'?') > 0
    or instr(well_name,'#') > 0
    or instr(well_name,'(') > 0
    or instr(well_name,')') > 0
;


--------------------------------------------------------------
--  Load specific checks
--------------------------------------------------------------

prompt *******************************************************************************
prompt 
prompt     Running load source specific checks
prompt
prompt *******************************************************************************


-------------------------
--  PID ONLY
-------------------------
declare
  Invalid_countries integer;
  Non_US_wells      integer;

begin
  if '&&source' = '450PID' then

    dbms_output.put_line(Running 450PID specific checks ...');

    --  Count PID wells that are in the wrong country - Expect ZERO
    Select count(uwi) into Invalid_Countries
      from &&load_schema..well_version
     where '&&source' = '450PID'
       and (country is null
         or country != '7US');

    dbms_output.put_line(Invalid_countries || ' of the PID wells not in the US'); 

    --  List any wells that will be updated as part of this load but are not currently
    --  identified as US wells in production  - Expect NONE
    select count(uwi) into Non_US_wells
      from &&load_schema..well_version
     where UWI in (select UWI
                     from well_version
                    where '&&source' = '450PID'
                      and country != '7US');

    dbms_output.put_line(Non_US_wells || ' existing non US wells will be updated as PID wells'); 

  end if;
end;
/



-------------------------------------
--  Only relevant for IHS incremental - need to make this conditional
-------------------------------------


    --  List a breakdown of Canadian wells by province to verify coverage
    select rps.province_state, count(uwi) as Wells
      from r_province_state rps left outer join well_version wv
        on rps.province_state = wv.province_state
       and wv.source = '&&source'
     where rps.country = '7CN'
       and rps.active_ind = 'Y'
     group by rps.province_state
     order by rps.province_state;



----------------
--  Staged ONLY   - need to make this conditional before using it
----------------

--  List any well versions in the staging area that have the wrong source - Expect NONE
--    select uwi as "Invalid source wells"
--      from &&load_schema..well_version
--     where source != '&&source';


--  Return to main script ...