/***************************************************************************************************
 SCRIPT: WIM_Housekeeping_procedure.sql

 PURPOSE:
   Install a housekeeping procedure that runs overnight to fix problems
   in the WIM dataset. Once long term solutions are added then fixes can be removed.

 DEPENDENCIES
   WIM_HOUSEKEEPING_INSTALL.SQL - Must have been run once on the target database

 EXECUTION:
   Run in TOAD or SQL*PLUS in WIM schema

   Syntax:
    N/A

 HISTORY:
    1-Dec-2009  R. Masterman  Initial version
   19-Mar-2010  R. Masterman  Added Floy's inactive well and emptynester code
   23-Mar-2010  R. Masterman  Added a full roll up check
   08-Jun-2010  R. Masterman  Added WELL_ALIAS to the active IND checks
   15-Oct-2010  R. Masterman  Extended Rollup check to Nodes too
   03-Dec-2010  R. Masterman  Added checks for recursive aliases
   10-Jan-2011  R. Masterman  Added checks on WIM Audit log
   17-Jan-2011  R. Masterman  Added Rollup to fix CWS loader problems as it uses IHS rollup
   05-Aug-2011  N.Grewal    Added Country Consistency Check
   2 sept 2011  V.Rajpoot    Commented out 100TLM rollup
   6-Sept-2011  V.RAjpoot    Added a call to WIM.UPDATE_300IPL_SUR_NODE_ID procedure to update
                Surface Node Id in case it is null in PPDM
                and ( well is pointing to same node)
   8-May-2012   N.Grewal    Added Wells with Duplicate IPL_UWI_LOCAL Check
   11-May-2012  N.Grewal    Added wells with wrong coord system (NAD27 and NAD83)
   18-May-2012  N.Grewal    Added WIM INCONSISTENT NODE AND WELL ACTIVE INDICATORS CHECK
   27-Aug-2012  V.Rajpoot    Added Wells with Duplicate WELL_NUM Check
   30-Aug-2012  v.Rajpoot    Wells with wrong coord system (NAD27) check AND
                              Wells with wrong coord system (NAD27) check
                              Modified  both these checks to filterout Inactive Nodes
   6-Feb-2013   N.Grewal      Added Undefined geog_coordinate_system_id Check
  22-Feb-2013   N.Grewal      Added Node Versions with NO COUNTRY check
  22-Feb-2013   N.Grewal      Added Node Versions with NO NODE_POSITION check
  11-Mar-2013   V.Rajpoot     Added a check for Null Well_Names
  15-Mar-2013   V.Rajpoot     Added a check for Override Version, if they are only one left
                              Added a check for incorrect Base_Node_ID, SUrface_Node_Ids
  19-Apr-2013   V.Rajpoot     Added a check for non-standard country codes.
  22-OCT-2013   C.Dong        Added a check for wells in WIM but not in DM
                                Depends on new grants, new dblink to DM, and new view
  23-DEC-2013   C.Dong
    Added housekeeping checks for
    1. North America wells without nad27 coordinates
       --> use scripts from TIS TASK 1198 to identify these wells, for creation/addition/update of 075TLMO version
           with converted nad27 location
    2. North America 075TLMO override wells, with nad27, where another version (without nad27) has changed
       --> identify wells, then convert other coordinates to nad27, update 075TLMO version
    3. 075TLMO override wells, with nad27, where another version, also with nad27, exists
       --> identify wells, decide if 075TLMO version should be inactivated/deleted

  14-JAN-2014  C.Dong
   Updated housekeeping task for undefined geog_coord_system_id
     1.check for '9999',, where the new value is set as 'undefined' in the ppdm.cs_coordinate_system table
     2. return a count of records
   Update check for wells requiring a nad27. Change logic to target any well_node where coord is not nad27
   Update checks for countries incorrectly using nad27 or nad83: use geog_coord_system_id not just text
   Adding counts to some of the checks, to provide a summary number of affected items

  4-FEB-2014 C.Dong
   Add check of well versions with same tlm_id (uwi) but different IPL_UWI_LOCAL
    This could be the result of incorrect merging of well versions, or simply inaccurate data
   Add check of well_area records with no link to a well_version record
    This could result in problems moving a well, where a version cannot be moved to a target,
      since a target well_area record already exists.   Task 1374

  6-MAY-2014 K.Edwards
   Added check for CWS wells that do not have a public version

  2014-05-22  C.Dong
   Updated well node version unknown coord system check to only look for ACTIVE node versions
   kxedward had inactivated thousands of node versions in a task; however, wim housekeeping not acknowledging the inactivations

  2014-05-23   cdong
    Well Area check: Only include active well-areas
    Only display individual wells if 15 or fewer wells--reduces rows in tlm-process-log
      Duplicate well_num check
      Duplicate ipl_uwi_local check
      Node version with no country check
      Node version with no node position check
      Inconsistent well-version and well-node-version active indicator for same uwi-and-source check
    Updated formatting/spacing

  2014-06-06  cdong
    Add check where dir srvy header active_ind does not match dir srvy station active_ind
      1. TLM dir srvy
      2. IHS dir srvy Canada
      3. IHS dir srvy US
      Note: this requires that db-links to IHSDATA and IHSDATAQ be created.
        Also required are explicit grants to the tables tlm_well_dir_srvy and tlm_well_dir_srvy_station.

  2014-06-09  cdong
    Add step to set coord_system_id value in ppdm.tlm_well_dir_srvy, based on value in station table.
    This is something Cindy Guenard had me do in-bulk a month ago, and will need to be done on an on-going
      basis, until GeoWiz is updated.
    Added an exception handler to majority of fixes and checks.
    Formatting changes.

  2014-07-17  kedwards
    Add fix for well nodes that had a null value for the coord_system_id attribute
    - found wells will have the coord_system_id value sourced from the geog_coord_system_id attribute.

  2014-11-26  cdong   TIS Task 1550
    Check for carriage return, line feed, and tab character in well name.

  2014-12-03  cdong   TIS Task 1554
    Update checks
    1. Node versions with no country
    2. Wells with wrong coordinate system (nad27)
    3. Wells with wrong coordinate system (nad83)

  2015-01-06  cdong   TIS Task 1563  dir srvy header and coord_system_id
  2015-01-06  cdong   TIS Task 1564  rm_info_item_content fix null area_type (until QC1152 is implemented to fix DatMan-Geo)

  2015-05-04  cdong   TIS Task 1628 - multiple QC tickets
    QC1651: fix null coord system fix
    QC1674: add new checks
    QC1666: override check to include 075tlmo, 080nad27, and 900tlmu
    Added report item id to existing checks, to match with TIS report and WIM Housekeeping WIKI
       http://explweb1.na.tlm.com/wiki/WIM_Housekeeping

  2015-08-06  cdong
    QC1686  new check for kb elevation zero or less
    QC1713  new check for records management records with no composite well or associated area
    Changed some logging to output zero count.  This is mainly helpful with the BIRT report and graphing.

  2015-11-13  cdong
    QC1653 - run procedure to check the last updated date for the IHS datasets
    QC1742 - modify underlying view for check 031 (US well(s) with multiple ipl_uwi_local)
      note: checks 029, 030, and 032 use the same view; however, the change should not affect these checks
    QC1738 - automatically delete the orphaned records in table well_area
    QC1727 - directional survey checks

  2016-01-20  cdong
    QC1758 report on wells where override version is old
    QC1760 report on wells where KB elevation is equal to Ground elevation (GLE)

  2016-02-24  cdong
    QC1770/1771 - add Saskatchewan to filtered regions

  2016-03-18  cdong
    QC1790/1791/1792/1793 - separate counts by region (AB,SK vs et-al/other)
      Note: this is DEPENDENT on changes to the wim.z_benchmark report-items table

  2016-03-21  cdong
    QC1784 add check for wells with multiple license numbers

  2016-03-21  cdong
    QC1783 inactive well version with active license, node version, or status

  2016-03-24  cdong
    QC1764 Wells with only an active GDM (700TLME) well version and no inventory.
    QC1781 Wells with only a surface or bottom-hole location and not the other.
    QC1740 Failed inactivations due to inventory

  2016-03-31  cdong
    QC1798 UWI's with multiple composite wells

  2016-04-13  cdong
    QC1805 Report Item 015 (wells requiring nad27 conversion) - use new view
    QC1807 Report Items 020, 021, and 022 (CWS wells without public well version)

  2016-04-19 cdong
    QC1811 Report Item 018 - remove check, it is redundant and covered by checks 029 through 032

  2016-04-20  cdong
    QC1810 Report Items 019 and 045 (data clean-up)

  2016-04-26  cdong
    QC1806 Report Item 06 (check if nad27 generated node version may require updating)
       Use new view. See report-item for more details

  2016-05-09 cdong
    QC1819 Expand checks in WIM Duplicate UWI-Well report to include British Columbia (002a, 029, 044a, and 049a)
    Note: no change to 029 as it is already set to include BC
    Note: no change to 049a as it covers all of Canada

  2016-05-11 cdong
    QC1822 Merge NAD27-generation counts (report items 015 and 016) together, as Kevin is updating the
      view wim.wim_nad27_conv_stage_vw to include both net-new and update generation and removing the
      view wim.wim_nad27_conv_stage_updt_vw.

  2016-06-09 cdong
    QC1833  for reporting purposes, output count even if no issue found
            note: not all checks require this, just the ones CDU/GDM is mainly interested in
            e.g. yes: wells with multiple uwi, kb elevation issues, uwi's for multiple wells
                 no: wim wells not in dm, missing country, node-id inconsistency
  20160616 cdong
    QC1841 Report Items 020 and 021 - Change attribute from 'matched_uwi_ind' to 'public_wv_ind'.
           The public_wv_ind attribute is more appropriate.

  20160617 cdong
    QC1843 Automate the removal of leading/trailing blank-space characters from well_version
           attributes well_name and ipl_uwi_local, for all sources OTHER than IHS and CWS.
           IHS/CWS loaders will overwrite any changes.
    QC1844 Check for well versions with leading/trailing blank-space characters in well_name and ipl_uwi_local
           Exclude IHS-source well versions.  This check will run AFTER the auto-trim (qc1843).
           Any well version detected by the check --should-- be from CWS.
            - count of CWS well versions
            - count of non-CWS well versions. This is just-in-case.
           The Data Steward Housekeeping report will include a list of wells, or at least a summary (by source).
  20160621 cdong
           Report items 050a, 050b, 050c, and 050d
           Reconsidered only logging when count > 0. It is more consistent to log a cound at all times,
           similar to other report items.


 *****************************************************************************
  The WIM_HOUSKEEPING procedure

  Set of ad hoc fixes and clean ups for the WIM database.

  To Add a fix:
   1) Insert a full width comment, including the task # of the task and a
       description of the fix.
   2) Compile the procedure in WIM on TEST-db and unit test
   3) If OK compile in the WIM schema in Production

  To Remove a fix:
   1) Confirm the tasks the fix refers to are complete and in production
   2) Delete the fix section
   3) Compile the procedure in WIM on TEST-db and unit test
   4) If OK compile in WIM schema in Production

   In both cases the job will automatically run the new procedure overnight

 *****************************************************************************

*/

CREATE OR REPLACE PROCEDURE WIM.WIM_HOUSEKEEPING
/*
 Group of data-integrity checks and clean-up activities

 See Vault for the "master" copy of this proedure, where the history is documented in the script
   to create/alter this procedure.

 Updated: 20160621 cdong

 */

IS

  --local variable to specify the maximum number of affected rows to display.
  --  if more than this, then only show a count; otherwise, display all rows
  v_MaxRowsToDisplay                number(5);

  -- Local procedure to check for and set null active indicators
  PROCEDURE NULL_ACTIVE_INDICATORS (TABLE_NAME VARCHAR2) IS
    Nulls                           NUMBER(10) := 0;
    SQL_Text                        VARCHAR2(1000);
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ' || TABLE_NAME || ' WHERE ACTIVE_IND IS NULL' INTO NULLS;
    IF Nulls > 0 THEN
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: NULL active indicators in ' || TABLE_NAME || ': ' || NULLS);
      execute immediate 'update ' || TABLE_NAME || ' set active_ind = ''Y'' where active_ind is null';
      commit;
    END IF;
  END;



BEGIN

  -- Log the start of housekeeping
   ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Housekeeping .......... ');

   --set the max number of records to display
   v_MaxRowsToDisplay   := 15;

  -- *****************************************************************************
  --  FIX : ACTIVE INDICATOR NOT SET  (Task #334, #34)
  --   Some loaders and the Well Master application don't set the ACTIVE_IND field
  --   These steps clean that up in the primary tables.
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Set null active indicators');
  NULL_ACTIVE_INDICATORS('WELL');
  NULL_ACTIVE_INDICATORS('WELL_VERSION');
  NULL_ACTIVE_INDICATORS('WELL_NODE');
  NULL_ACTIVE_INDICATORS('WELL_NODE_VERSION');
  NULL_ACTIVE_INDICATORS('WELL_STATUS');
  NULL_ACTIVE_INDICATORS('WELL_LICENSE');
  NULL_ACTIVE_INDICATORS('WELL_ALIAS');
  NULL_ACTIVE_INDICATORS('POOL');
  NULL_ACTIVE_INDICATORS('WELL_NODE_M_B');
  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Set null active indicators');




  -- *****************************************************************************
  --  FIX : INACTIVE WELLS
  --   Find and inactivate WELLS with no active versions
  -- *****************************************************************************

  declare
    cursor remove_inactive_well_cursor is
        select uwi from  well where active_ind = 'Y'
         minus
        select uwi from  well_version where active_ind = 'Y';

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Inactivate Wells');

    for riwc in remove_inactive_well_cursor loop
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Well '||riwc.uwi || ' inactivated - it has no active versions');
      update  well set active_ind = 'N' where uwi=riwc.uwi;
      update  well_status set active_ind ='N' where uwi=riwc.uwi;
      update  well_license set active_ind ='N' where uwi=riwc.uwi;
      -- Can't do the following yet as they may be used by other wells at the moment.
        --update well_node set active_ind ='N' where surface_node_id=riwc.surface_node_id (*)
        --update well_node set active_ind ='N' where base_node_id=riwc.base_node_id (*)
        --update well_node_version set active_ind ='N' where node_id=riwc.surface_node_id (*)
        --update well_node_version set active_ind ='N' where node_id=riwc.base_node_id  (*)
    end loop;
    commit;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Inactivate Wells');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Inactivate Wells *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  FIX : Empty Nesters
  --   Find any WELLS with no versions and deactivate (soft delete) them
  -- *****************************************************************************

  declare
    cursor remove_emptynester_well_cursor is
        select uwi from  well where active_ind = 'Y'
      minus
        select uwi from  well_version;

    emptynester_row  well%rowtype;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : De-activate Empty Nesters');

    for rewc in remove_emptynester_well_cursor loop
      select * into emptynester_row from  well where uwi=rewc.uwi;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Empty Nester Inactivated: UWI='||rewc.uwi||', Source='||emptynester_row.primary_source||', Country='||emptynester_row.country);
      update  well set active_ind = 'N' where uwi=rewc.uwi;
      update  well_alias set active_ind = 'N' where uwi=rewc.uwi;
      update  well_status set active_ind = 'N' where uwi=rewc.uwi;
      update  well_license set active_ind = 'N' where uwi=rewc.uwi;
    end loop;
    commit;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Deactivate Empty Nesters');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Deactivate Empty Nesters *** Ended with Errors');
  end;



/*
   -- *****************************************************************************
  --  FIX : Force a rollup of the CWS (100TLM) source wells after the daily load
  --        These changes may not be picked up by the standard roll up checker
  -- *****************************************************************************
  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : CWS (100TLM) source Roll Ups');

  WIM.WIM_ROLLUP.SOURCE_ROLLUP('100TLM');

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : CWS (100TLM) source Roll Ups');
*/



  -- *****************************************************************************
  --  FIX : Find any missed roll ups (Task #471)
  --   Checks for wells that are not rolled up and rolls them up
  --   We still need this in case a load or manual DELETE leaves an inconsistent
  --   composite node.
  -- *****************************************************************************

  declare
    -- Finds:
    --  1) Active well versions not appearing as an active composite - active versions should rollup
    --  2) Composite wells that are not in the well version table - should be removed
    --  3) Wells with active nodes that are not in the composite node table  - active versions should rollup
    --  4) Wells with composite nodes that are not in the node version table - nodes should be removed

    cursor wells_to_roll_up is
      (select uwi from  well_version where active_ind = 'Y'
         minus
      select uwi from  well where active_ind = 'Y')
      union
     (select uwi from  well
         minus
      select uwi from  well_version)
      union
     (select ipl_uwi from  well_node_version where active_ind = 'Y'
         minus
      select ipl_uwi from  well_node where active_ind = 'Y')
      union
     (select ipl_uwi from  well_node
         minus
      select ipl_uwi from  well_node_version);

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Missed Roll Ups');

    for tlm_id in wells_to_roll_up loop
      wim.wim_rollup.well_rollup(tlm_id.uwi);
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Rolled up well ' || tlm_id.uwi);
      commit;
    end loop;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Missed Roll Ups');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Missed Roll Ups *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  FIX : Recursive Aliases (Task #773)
  --   Checks for alises that point to themselves - will cause FIND_WELL failure
  -- *****************************************************************************

  --  Check for alias recursion
  declare
    pcount                          number;  -- Recursion counter

    --  Cursor to find TLM_ID aliases
    cursor alias_wells is
       select uwi, source, well_alias
         from  well_alias
        where alias_type = 'TLM_ID'
          and active_ind = 'Y';

    --  Checks for recursion data
    procedure check_alias (pfrom   in     varchar,
                           pto     in     varchar,
                           psource in     varchar,
                           pcount  in out number) is

      cmax_levels number default 20;
      vnew_to      well_version.uwi%type;

    begin
       pcount := pcount + 1;
       if pcount > cmax_levels or pfrom = pto then
          ppdm_admin.tlm_process_logger.error ('WIM_HOUSEKEEPING: Recursive alias ALIAS=' || pfrom || ', TLM_ID=' || pto || ', Source= ' || psource || ' with recursion depth of ' || pcount);
       else
         select max(uwi) into vnew_to   -- Get the next level and use MAX to avoid multiple returns
           from  well_alias
          where well_alias = pto
            and alias_type = 'TLM_ID'
            and source = psource
            and active_ind = 'Y';

         if vnew_to is not null then -- Drill down to next level
           check_alias(pto, vnew_to, psource,pcount);
         end if;

       end if;
    end;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Recursive Alias Check');
    -- For each of the TLM_ID aliases check they don't stick in infinite loops
    for next_well in alias_wells loop
      begin
        pcount := 0;
        check_alias (next_well.well_alias, next_well.uwi, next_well.source, pcount);
      end;
    end loop;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Recursive Alias Check');
  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Recursive Alias Check *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  FIX : Check for fatal errors in the WIM audit log (#790)
  --
  -- *****************************************************************************

  declare
    pcount                          number;        -- Error counter
    pperiod                         number := 7;  -- Days to check (e.g. 7 for the last week)

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : WIM Audit fatal error check');

    select count(1) into pcount
      from wim_audit_log
     where audit_type = 'F'
       and row_created_date > sysdate - pperiod;

    if pcount > 0 then
      ppdm_admin.tlm_process_logger.error ('WIM_HOUSEKEEPING: ' || pcount || ' WIM fatal errors in the last ' || pperiod || ' day(s)');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : WIM Audit fatal error check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : WIM Audit fatal error check *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 001
  --  FIX : Update the directional survey header with the coordinate system id
  --          from the station data.  There should be one and only one geog_coord_system_id
  --          value in the station data, for a matching well dir srvy header.
  --  History:
  --    20140609 cdong  creation
  --                    note: requires explicit GRANT of 'update' to wim, on tlm_well_dir_srvy
  --    20150106 cdong  use new procedure ppdm_admin.tlm_update_dir_srvy_coord_sys  (TIS Task 1563)
  --
  -- *****************************************************************************

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Update dir srvy header with no coord_system_id');

  ppdm_admin.tlm_update_dir_srvy_coord_sys;

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Update dir srvy header with no coord_system_id');




    -- *****************************************************************************
  --  FIX : Update the indexed item record in ppdm.rm_info_item_content
  --          to set the null area_type to the actual value (from ppdm.area)
  --          This is an interim measure until the bug can be fixed in DatMan-Geo (QC1152)
  --  History:
  --    20140609 cdong  TIS Task 1564 creation
  --    20160414 cdong  Issue fixed in DatMan-Geo 1.3.0 (2016-01-15). However, leave this in here, just-in-case.
  --
  -- *****************************************************************************

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Update rm_info_item_content and fix null area_type');

  ppdm_admin.tlm_fix_iic_null_area_type;

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Update rm_info_item_content and fix null area_type');




  -- *****************************************************************************
  --  CHECK : Country Consistency Check
  --  WIM Housekeeping - Country Consistency Check (Task #905)
  -- ***************************************************************************

  declare
    p_wv_uwi                        varchar2(20);
    p_wv_source                     varchar2(20);
    p_wv_country                    varchar2(20);
    p_wv_active_ind                 varchar2(1);
    p_wv_wellname                   varchar2(66);
    p_wnv_nodeid                    varchar2(20);
    p_wnv_source                    varchar2(20);
    p_wnv_country                   varchar2(20);
    p_wnv_ipluwi                    varchar2(20);
    v_count                         number          := 0;

    cursor cursor_country_consistency_chk
    is
     select wv.uwi, wv.source, wv.country, wv.active_ind, wv.well_name, wnv.node_id, wnv.source, wnv.country, wnv.ipl_uwi
       from  well_version wv,  well_node_version wnv
      where wv.active_ind = 'Y'
            and wv.uwi = wnv.ipl_uwi
            and wv.source = wnv.source
            and wv.country != wnv.country;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Country Consistency Check');

    v_count := 0;

    open cursor_country_consistency_chk;

    loop
      fetch cursor_country_consistency_chk
      into p_wv_uwi, p_wv_source, p_wv_country, p_wv_active_ind, p_wv_wellname, p_wnv_nodeid, p_wnv_source, p_wnv_country, p_wnv_ipluwi;

      exit when cursor_country_consistency_chk%notfound;

      ppdm_admin.tlm_process_logger.
      warning (
               'WIM_HOUSEKEEPING: COUNTRY INCONSISTENT FOR UWI ='
                || p_wv_uwi
                || ', SOURCE ='
                || p_wv_source
                || ', WITH COUNTRY IN WELL_VERSION ='
                || p_wv_country
                || ', AND WITH COUNTRY IN WELL_NODE_VERSION ='
                || p_wnv_country);

      v_count := v_count + 1;

    end loop;

    close cursor_country_consistency_chk;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells where well_version country doesn''t match well_node_version country = ' || v_count );
    end if;

  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Country Consistency Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Country Consistency Check *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 002
  --  CHECK : UWI's (ipl_uwi_local) with more than one TLM Well ID
  --  WIM Housekeeping - Well Versions with Duplicate IPL_UWI_LOCAL Check (Task #1093)
  --  20140523  cdong   only output individual well versions if count <= 15.  this is to reduce the volume of information in the process log.
  --  20160318  cdong   QC1790 separate count by region - replace 002 with sub-checks 002A and 002B
  -- ***************************************************************************
 /* ----20160318 QC1790 comment out this item
  declare
    p_local_uwi                     varchar2(20);
    p_uwi                           varchar2(4000);
    p_count                         number;

    cursor cursor_dup_localuwi_chk
    is
    select ipl_uwi_local, well_list
      from wv_dup_local_uwi_vw;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with Duplicate IPL_UWI_LOCAL CHECK');

    select count(*)
      into p_count
      from wv_dup_local_uwi_vw;

    open cursor_dup_localuwi_chk;

    if p_count > 0 then

      --IF p_count <= 15 THEN
      if p_count <= v_maxrowstodisplay then
        loop
          fetch cursor_dup_localuwi_chk into p_local_uwi, p_uwi;
          exit when cursor_dup_localuwi_chk%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL = ' || p_local_uwi
                                                || ', AND UWI IN = ' || p_uwi);

        end loop;
      end if;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL CHECK : Total number of duplicate IPL_UWI_LOCALs found = ' ||p_count);

    end if;

    close cursor_dup_localuwi_chk;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with Duplicate IPL_UWI_LOCAL CHECK');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with Duplicate IPL_UWI_LOCAL CHECK *** Ended with Errors');
  end;
 */



  -- *****************************************************************************
  --  Report Item ID: 002, 002a, and 002b
  --  CHECK : UWI's (ipl_uwi_local) with more than one TLM Well ID
  --  WIM Housekeeping - Well Versions with Duplicate IPL_UWI_LOCAL Check (Task #1093)
  --  20160318 cdong QC1790 take item 002 and separate count by region
  --                 (a) for AB and SK (Canada)
  --                 (b) other
  --  20160509 cdong QC1819 add BC to (a)
  -- ***************************************************************************

  declare
    p_local_uwi                     varchar2(20);
    p_uwi                           varchar2(4000);
    p_count                         number    := 0;
    p_count_a                       number    := 0;
    p_count_b                       number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with Duplicate IPL_UWI_LOCAL CHECK');

    select count(1) into p_count
      from wv_dup_local_uwi_vw
    ;

    select count(1) into p_count_a
      from wv_dup_local_uwi_vw
     where upper(country_prov) like '%7CN (AB)%'
           or upper(country_prov) like '%7CN (SK)%'
           or upper(country_prov) like '%7CN (BC)%'
    ;

    p_count_b   :=  p_count - p_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL CHECK : Total number of duplicate IPL_UWI_LOCALs found: ' || p_count);
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL CHECK : Total number of duplicate IPL_UWI_LOCALs found (AB,SK,BC): ' || p_count_a);
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate IPL_UWI_LOCAL CHECK : Total number of duplicate IPL_UWI_LOCALs found (Other): ' || p_count_b);

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with Duplicate IPL_UWI_LOCAL CHECK');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with Duplicate IPL_UWI_LOCAL CHECK *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 003
  --  CHECK : WELL_NUM values with more than one well (TLM well id)
  --  WIM Housekeeping - Wells with Duplicate WELL_NUM Check
  --  2014-05-23 cdong   only output individual wells if count <= 15.  this is to reduce the volume of information in the process log.
  -- ***************************************************************************

  declare
    p_well_num                      varchar2(20);
    p_uwi                           varchar2(4000);
    p_count                         number;

    cursor cursor_dup_well_num_chk
    is
    select well_num, uwi
      from wv_dup_well_num_vw  ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with Duplicate WELL_NUM CHECK');

    select count(*)
      into p_count
      from wv_dup_well_num_vw;

    open cursor_dup_well_num_chk;

    if p_count > 0 then

      --IF p_count <= 15 THEN
      if p_count <= v_maxrowstodisplay then
        loop
          fetch cursor_dup_well_num_chk into p_well_num, p_uwi;
          exit when cursor_dup_well_num_chk%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate WELL_NUM =' || p_well_num
                                                || ', AND UWI IN =' || p_uwi);
        end loop;
      end if;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with Duplicate WELL_NUM CHECK : Total number of duplicate WELL_NUMs found = ' ||p_count);

    end if;

    close cursor_dup_well_num_chk;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with Duplicate WELL_NUM CHECK');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with Duplicate WELL_NUM CHECK *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 004
  --  CHECK : Wells with wrong coord system (NAD27) check
  --  WIM Housekeeping - Wells with wrong coord system (NAD27) Check (Task #1095)
  --    Only a few countries can use NAD27.  So, any other country using nad27 should be flagged as a problem.
  --  2014-01-14 cdong: include the nad27 code (4267), not just the text
  --     update with new set of countries, per roman abdoullaev
  --  2014-12-03 cdong: Change check to consider well and well_node, instead of well_version and well_node_version. (task 1554)
  -- ***************************************************************************

  declare
    p_wv_country                    varchar2(20);
    p_wnv_geog_coord_system_id      varchar2(20);
    p_wnv_ipl_uwi                   varchar2(20);
    p_rc_long_name                  varchar2(60);
    v_count                         number    := 0;

    cursor cursor_wrong_nad27_chk
    is
    select w.country, wn.geog_coord_system_id, wn.ipl_uwi, rc.long_name
      from ppdm.well w
           inner join ppdm.well_node wn on wn.node_id in (w.base_node_id, w.surface_node_id)
           left join ppdm.r_country rc on w.country = rc.country
     where w.active_ind = 'Y'
           and wn.active_ind = 'Y'
           and upper(nvl(wn.geog_coord_system_id, '9999')) in ('NAD27', '4267')
           and w.country not in ('2AG'       --antingua and barbuda
                                    , '2BA'   --bahamas
                                    , '2BE'   --belize
                                    , '2VI'   --british virgin islands
                                    , '7CN'   --canada
                                    , '2CR'   --costa rica
                                    , '2CU'   --cuba
                                    , '2ES'   --el salvador
                                    , '2GU'   --guatemala
                                    , '2HO'   --honduras
                                    , '2ME'   --mexico
                                    , '2NI'   --nicaragua
                                    , '2PR'   --puerto rico
                                    , 'VI'    --u.s. virgin islands
                                    , '7US'   --united states
                                    --, '5UKAI' --anguilla
                                    --, '2AB'   --aruba
                                    --, '2BR'   --barbados
                                    --, '2BM'   --bermuda
                                    --, '2KY'   --cayman islands
                                    --, '2DR'   --dominican republic
                                    --, '2GE'   --grenada
                                    --, '2HA'   --haiti
                                    --, '2JA'   --jamaica
                                    --, '2MT'   --martinique
                                    --, '2NA'   --netherlands antilles
                                    --, '2KN'   --saint kitts and nevis
                                    --, '2SL'   --saint lucia
                                    --, '7SM'   --saint pierre and miquelon
                                    --, '2TT'   --trinidad and tobago
                                 )
    group by w.country, wn.geog_coord_system_id, wn.ipl_uwi, rc.country, rc.long_name
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With Wrong Coord System (nad27) Check');
    v_count := 0;

    open cursor_wrong_nad27_chk;

    loop
      fetch cursor_wrong_nad27_chk into p_wv_country, p_wnv_geog_coord_system_id, p_wnv_ipl_uwi, p_rc_long_name;
      exit when cursor_wrong_nad27_chk%notfound;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: well with wrong geog_coord_system_id (nad27) for TLMID = '|| p_wnv_ipl_uwi
                                               || ', and country in = '|| p_rc_long_name
                                               || '('|| p_wv_country ||')');

      v_count := v_count + 1;
    end loop;

    close cursor_wrong_nad27_chk;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with incorrect geog_coord_system_id (nad27/4267) = ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With Wrong Coord System (nad27) Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With Wrong Coord System (nad27) Check *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 005
  --  CHECK : Wells with wrong coord system (NAD83) check
  --  WIM Housekeeping - Wells with wrong coord system (NAD83) Check (Task #1095)
  --    Only a few countries can use NAD83.  So, any other country using nad83 should be flagged as a problem.
  --  2014-01-14 cdong: include the nad83 code (4269), not just the text
  --  2014-12-03 cdong: Change check to consider well and well_node, instead of well_version and well_node_version. (task 1554)
  -- ***************************************************************************

  declare
    p_wv_country                    varchar2(20);
    p_wnv_geog_coord_system_id      varchar2(20);
    p_wnv_ipl_uwi                   varchar2(20);
    p_rc_long_name                  varchar2(60);
    v_count                         number    := 0;

    cursor cursor_wrong_nad83_chk
    is
    select w.country, wn.geog_coord_system_id, wn.ipl_uwi, rc.long_name
      from ppdm.well w
           inner join ppdm.well_node wn on wn.node_id in (w.base_node_id, w.surface_node_id)
           left join ppdm.r_country rc on w.country = rc.country
     where w.active_ind = 'Y'
           and wn.active_ind = 'Y'
           and upper(nvl(wn.geog_coord_system_id, '9999')) in ('NAD83', '4269')
           and w.country not in ('2VI'   --british virgin islands
                                    , '7CN'   --canada
                                    , '2ME'   --mexico
                                    , '2PR'   --puerto rico
                                    , 'VI'    --u.s. virgin islands
                                    , '7US'   --united states
                                    --'2BA', '2CU', '2HA', '2DR', '2BE', '2BM', '2KY', '2VI', '5UKAI', '2NA','2PR', '7US', '7CN', '7SM', '2KN', '2AG', '2JA'
                                 )
    group by w.country, wn.geog_coord_system_id, wn.ipl_uwi, rc.country, rc.long_name
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With Wrong Coord System (nad83) Check');
    v_count := 0;

    open cursor_wrong_nad83_chk;

    loop
      fetch cursor_wrong_nad83_chk into p_wv_country, p_wnv_geog_coord_system_id, p_wnv_ipl_uwi, p_rc_long_name;
      exit when cursor_wrong_nad83_chk%notfound;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: well with wrong geog_coord_system_id (nad83) for TLMID = '|| p_wnv_ipl_uwi
                                               || ', and country in = '|| p_rc_long_name
                                               || '('|| p_wv_country ||')');
      v_count := v_count + 1;
    end loop;

    close cursor_wrong_nad83_chk;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with incorrect geog_coord_system_id (nad83/4269) = ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With Wrong Coord System (nad83) Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With Wrong Coord System (nad83) Check *** Ended with Errors');
  end;




  -- *****************************************************************************
  --  Report Item ID: 006
  --  CHECK : WIM Inconsistent node and well active indicators Check
  --  WIM Housekeeping - WIM Inconsistent node and well active indicators Check (Task #1096)
  --  2014-05-23 cdong   only output individual wells if count <= 15.  this is to reduce the volume of information in the process log.
  -- ***************************************************************************

  declare
    p_wv_uwi                        varchar2(20);
    p_wv_source                     varchar2(20);
    p_count                         number;

    cursor cursor_node_inconsistency_chk
    is
    select a.uwi, a.source
      from ppdm.well_version a, ppdm.well_node_version b
     where a.uwi = b.ipl_uwi
           and a.source = b.source
           and a.active_ind = 'N'
           and b.active_ind = 'Y'
     group by a.uwi, a.source
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : WIM Inconsistent Node And Well Active Indicators Check');

    select sum(count(*))
      into p_count
      from ppdm.well_version a, ppdm.well_node_version b
     where a.uwi = b.ipl_uwi
           and a.source = b.source
           and a.active_ind = 'N'
           and b.active_ind = 'Y'
     group by a.uwi, a.source
    ;

    open cursor_node_inconsistency_chk;

    if p_count > 0 then

      --IF p_count <= 15 THEN
      if p_count <= v_maxrowstodisplay then
        loop
          fetch cursor_node_inconsistency_chk into p_wv_uwi, p_wv_source;
          exit when cursor_node_inconsistency_chk%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Node active indicator inconsistent for UWI ='|| p_wv_uwi
                                                   || ', source =' || p_wv_source);
        end loop;
      end if;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of INACTIVE well versions with ACTIVE well node versions: ' || p_count );

    end if;

    close cursor_node_inconsistency_chk;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : WIM Inconsistent Node And Well Active Indicators Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : WIM Inconsistent Node And Well Active Indicators Check *** Ended with Errors');
  end;




  -- ************************************************************************************************************************************
  --  Report Item ID: 007
  --  CHECK : Undefined geog_coordinate_system_id Check
  --  WIM Housekeeping - check to look for wells (nodes) with an undefined geog_coordinate_system_id i.e is set to "0000" (Task #1199)
  --  2014-01-14 cdong: added '9999' to values to check.  Additionally, any null coord system will be picked up by this check.
  --  2014-05-22 cdong: add condition where active_ind = 'Y'
  -- ************************************************************************************************************************************

  declare
    p_ipl_uwi                       varchar2(20);
    p_source                        varchar2(20);
    p_geog_coord_system_id          varchar2(20);
    v_count                         number    := 0;
    cursor cursor_undefined_coord_chk
    is
    select ipl_uwi, source, geog_coord_system_id
      from ppdm.well_node_version
     where nvl(geog_coord_system_id, '9999') in ('0000', '9999')
           and active_ind = 'Y'
     group by ipl_uwi, source, geog_coord_system_id
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Undefined Geog_Coordinate_System_Id Check');
    v_count := 0;

    open cursor_undefined_coord_chk;

    loop
      fetch cursor_undefined_coord_chk into p_ipl_uwi, p_source, p_geog_coord_system_id;
      exit when cursor_undefined_coord_chk%notfound;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: undefined geog_coordinate_system_id = '|| nvl(p_geog_coord_system_id, 'NULL') || ','
                                               || ' UWI = ' || p_ipl_uwi || ','
                                               || ' source = ' || p_source);

      v_count := v_count + 1;
    end loop;

    close cursor_undefined_coord_chk;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with UNDEFINED coordinate system: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Undefined Geog_Coordinate_System_Id Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Undefined Geog_Coordinate_System_Id Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 008
  --  CHECK : Node Versions with no country check
  --  WIM Housekeeping - Node Versions with no country Check (Task #1200)
  --  2014-05-23 cdong   only output individual wells if count <= 15.  this is to reduce the volume of information in the process log.
  --  2014-12-03 cdong   add filter to ensure the node version is active (task 1554)
  -- *************************************************************************************************

  declare
    p_wnv_ipl_uwi                   varchar2(20);
    p_count                         number;

    cursor cursor_node_no_country_chk
    is
    select ipl_uwi
      from ppdm.well_node_version
     where country is null
           and active_ind = 'Y'
     group by ipl_uwi
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Node Versions With No Country Check');

    select count(distinct ipl_uwi)
      into p_count
      from ppdm.well_node_version
     where country is null
           and active_ind = 'Y'
    ;

    open cursor_node_no_country_chk;

    if p_count > 0 then

      --IF p_count <= 15 THEN
      if p_count <= v_maxrowstodisplay then
        loop
          fetch cursor_node_no_country_chk into p_wnv_ipl_uwi;
          exit when cursor_node_no_country_chk%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Node version with NO country for TLMID ='|| p_wnv_ipl_uwi );
        end loop;
      end if;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of node versions with NO country: ' || p_count );

    end if;

    close cursor_node_no_country_chk;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Node Versions With No Country Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Node Versions With No Country Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 009
  --  CHECK : Node Versions with no node position check
  --  WIM Housekeeping - Node Versions with no node position Check (Task #1200)
  --  2014-05-23 cdong   only output individual wells if count <= 15.  this is to reduce the volume of information in the process log.
  -- *************************************************************************************************

  declare
    p_wnv_ipl_uwi                   varchar2(20);
    p_count                         number;

    cursor cursor_node_no_n_position_chk
    is
    select ipl_uwi
      from ppdm.well_node_version
     where node_position is null
     group by ipl_uwi
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Node Versions With No Node_Position Check');

    select count(distinct ipl_uwi)
      into p_count
      from ppdm.well_node_version
     where node_position is null
    ;

    open cursor_node_no_n_position_chk;

    if p_count > 0 then

      --IF p_count <= 15 THEN
      if p_count <= v_maxrowstodisplay then
        loop
          fetch cursor_node_no_n_position_chk into p_wnv_ipl_uwi;
          exit when cursor_node_no_n_position_chk%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Node version with no node_position for TLMID ='|| p_wnv_ipl_uwi );
        end loop;
      end if;

      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of node versions with NO node_position: ' || p_count );

    end if;

    close cursor_node_no_n_position_chk;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Node Versions With No Node_Position Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Node Versions With No Node_Position Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 010
  --  CHECK : Wells with No Well_Name
  --  WIM Housekeeping - Well with no well_name
  -- *************************************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With No Well Name Check');

    select count(1) into v_count
      from well
     where active_ind ='Y'
           and well_name is null;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Number of wells with NO well_name: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with NO well_name: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With No Well Name Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With No Well Name Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 011
  --  CHECK : Wells with only Override version Left
  --  WIM Housekeeping - Check if there any wells with only Override version Left
  --  20150504  cdong   QC1666  Include 075TLMO, 080NAD27, and 900TLMU
  -- *************************************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With Only Override Version Check');

    select count(1) into v_count
      from ppdm.well_version
     where upper(source) in ('075TLMO', '080NAD27', '900TLMU')
           and active_ind = 'Y' --and remark is null
           and uwi not in ( select uwi
                              from ppdm.well_version
                             where active_ind ='Y'
                                   and source <> '075TLMO'
                                   and source <> '080NAD27'
                                   and source <> '900TLMU'
                          )
    ;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with ONLY OVERRIDE version: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with ONLY OVERRIDE version: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With Only Override Version Check');
  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With Only Override Version Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 012
  --  CHECK : Well with Invalid Node IDs
  --  WIM Housekeeping - Check if there any well nodes where the Base_Node_Id or Surface_Node_Id doesnt follow the standard
  -- *************************************************************************************************

  declare
    v_countb                        number;
    v_counts                        number;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With Invalid Node Ids Check');
    v_countb := 0;
    v_counts := 0;

    for rec in (select * from ppdm.well_version where active_ind = 'Y' and uwi || '0' != base_node_id)
    loop
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: well version with INVALID base node_id ='|| rec.uwi || '( ' || rec.source || ' )' );
      v_countb := v_countb + 1;
    end loop;

    for rec in (select * from ppdm.well_version where active_ind = 'Y' and uwi || '1' != surface_node_id)
    loop
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: well version with INVALID surface node_id ='|| rec.uwi || '( ' || rec.source || ' )' );
      v_counts := v_counts + 1;
    end loop;

    if v_countb > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of well versions with INVALID base_node_id: ' || v_countb );
    end if;

    if v_counts > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of well versions with INVALID surface_node_id: ' || v_counts );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With Invalid Node Ids Check');
  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With Invalid Node Ids Check *** Ended with Errors');
  end;




  -- *************************************************************************************************
  --  Report Item ID: 013
  --  CHECK : Well Versions with Invalid Country codes
  --  WIM Housekeeping - Check if there any well versions where country is not valid
  -- *************************************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells With Non-Standard Country Codes Check');
    --20140116 cdong: comment for clarity: r_country.source includes 'DM', 'TLM', 'IPL' (ihs canada)
    --  so, this query (using a double-negative) is looking for any wells that use a DM-sourced country
    select count(1) into v_count
      from well_version
     where country not in ( select country from ppdm.r_country where active_ind ='Y' and source <> 'DM');

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with non-standard country codes: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells With Non-Standard Country Codes Check');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells With Non-Standard Country Codes Check *** Ended with Errors');
  end;





  --********************************************************************************
  --  Check:  Execute BlackList Wells
  --  Wim Housekeeping - runs a process to inactivate wells are in Blacklist_wells tables.
  --  These are the wells that we dont need in our WIM database, but IHS hasn't removed them
  --    from their database.
  --*********************************************************************************

  begin
    ppdm.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Black List Wells Check');

    wim_loader.wim_loader.blacklist_wells(null);

    ppdm.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Black List Wells Check');
  end;




  --********************************************************************************
  --  Report Item ID: 014
  --  Check: Check if there are wells in WIM which are NOT in DM
  --  Wim Housekeeping - gets a count of records from view WIM.WIM_DM_MISSING_WELLS_MV
  --  Log an error if count is greater than zero.
  --  If there are wells missing, then need to trigger some kind of update to the wells
  --    in order for the well to be detected by the WIM-DM interface view
  --  Ideally, the count will be zero.  Users can run the view to see a list of wells.
  --*********************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Check for WIM wells that are NOT in DM');

    select count(1) into v_count
      from wim.wim_dm_missing_wells_vw;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Number of WIM wells that are NOT in DM: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All WIM wells in DM');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Check for WIM wells that are NOT in DM');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Check for WIM wells that are NOT in DM *** Ended with Errors');
  end;





  --********************************************************************************
  --  Report Item ID: 015
  --  Check: North American wells with non-NAD27 locations, without corresponding nad27 coordinates
  --  Log an error if count is greater than zero.
  --  If there are wells (and nodes) that need conversion to nad27, then use appropriate scripts to get a list of nodes. (see TIS Task 1198)
  --    Prepare nodes for conversion.  Use FME to convert.  Stage the nodes with newly-convered NAD27 location information.  Run Gateway and roll-up wells.
  --  Ideally, the count will be zero.
  --  2014-01-14 cdong: changed the logic to target any well_node where the defined coord system id is not nad27
  --  2016-04-13 cdong: QC1805 - use new view created for NAD27-conversion process (kxedward)
  --  2016-05-11 cdong: QC1822 - view wim.wim_nad27_conv_stage_vw now covers both net-new nad27 generation AND
  --                      wells requiring update of generated nad27
  --                      --NO changes here, only change is with report item 016
  --
  --*********************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : North America wells requiring node-location conversion to NAD27');
    --count of all wells with at least one non-nad27 coordinate (surface, bottom, or both)
    --  explicitly target nad83 and wgs84; exclude unknown (9999) and any other coordinate systems
    --remove all wells with a nad27, leaving only active wells without any nad27 whatsoever

    --select count(distinct ipl_uwi)
    --  into v_count
    ----SELECT WN.IPL_UWI, WN.NODE_ID, WN.SOURCE, W.COUNTRY, W.PROVINCE_STATE, WN.GEOG_COORD_SYSTEM_ID
    ----                  , WN.LOCATION_QUALIFIER, WN.NODE_POSITION , WN.LATITUDE, WN.LONGITUDE
    ----                  , WN.EASTING, WN.EASTING_OUOM, WN.MAP_COORD_SYSTEM_ID, WN.NORTHING, WN.NORTHING_OUOM, WN.POLAR_AZIMUTH
    ----                  , WN.NODE_OBS_NO, WN.ACTIVE_IND
    --  from ppdm.well w
    --       --get primary node if coord system not nad27 (4267)
    --       inner join ppdm.well_node wn on wn.node_id in (w.base_node_id, w.surface_node_id) and nvl(wn.geog_coord_system_id, '9999') not in ('4267', '9999')
    -- where nvl(w.active_ind, 'Y') = 'Y'
    --       and nvl(wn.active_ind, 'Y') = 'Y'
    --       and w.country in ('7CN', '7US')
    --;
    select count(distinct ipl_uwi)
           into v_count
      from wim.wim_nad27_conv_stage_vw
    ;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of North America wells requiring location conversion to NAD27: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of North America wells requiring location conversion to NAD27: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : North America wells requiring node-location conversion to NAD27');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : North America wells requiring node-location conversion to NAD27 *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 016
  --  Check: North America wells, with a (075TLMO) nad27 override, where non-nad27 coordinates are changed (for another version of the well).
  --    note: as of 2016-04-09, no longer using 075TLMO for calculated NAD27 location. the 080NAD27 version was never used.
  --  Log an error if count is greater than zero.
  --  For these wells, will have to convert and update the override version of nad27 coordinates to match the updated non-nad27 location coordinates
  --
  --  2016-04-09 : this check is INCORRECT. it has to be fixed.
  --  2016-04-26 : use new view wim_nad27_conv_stage_updt_vw
  --     Note: the view is INCOMPLETE. The auto-nad27 functionality being developed/tested will make this check obsolete.
  --     In the interim, used the view to at least identify instances where the node-version upon which the generated-nad27 wnv is based
  --       has changed, thereby requiring an update of the generated-nad27 wnv and roll-up.
  --     By using a view, it can change without having to recompile this procedure.
  --  2016-05-11 cdong: QC1822 - view wim.wim_nad27_conv_stage_vw now covers both net-new nad27 generation AND
  --                      wells requiring update of generated nad27
  --                      --COMMENT OUT / REMOVE report item 016
  --
  --*********************************************************************************

  ----*** 20160511 cdong  QC1822 comment out code --------------------------------------------------
  ----declare
  ----  v_count                         number    := 0;
  ----
  ----begin
  ----  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : North America wells requiring location update of override version');
  ----
  ----  select count(distinct ipl_uwi)
  ----         into v_count
  ----    from wim.wim_nad27_conv_stage_updt_vw
  ----  ;
  ----
  ----  /*
  ----  --SELECT *
  ----    from ( select distinct wnv.ipl_uwi, wnv.source, decode(max(wnv.row_changed_date), null, max(wnv.row_created_date), max(wnv.row_changed_date)) as row_changed_date--, WNV.ROW_CHANGED_DATE, WNV.ROW_CREATED_DATE
  ----             from ppdm.well_node_version wnv
  ----                  inner join ppdm.well_version wv on wnv.ipl_uwi = wv.uwi  and wv.source = wnv.source
  ----                  inner join ppdm.well w on wv.uwi = w.uwi
  ----            where wnv.source <> '075TLMO'
  ----            --WHERE WNV.SOURCE <> '080NAD27'
  ----                  and nvl(wnv.geog_coord_system_id, '9999') not in ('4267', '9999')
  ----                  and wnv.active_ind = 'Y'
  ----                  and wv.active_ind = 'Y'
  ----                  and w.country in ('7CN', '7US')  --get country from well, because there may not be an accurate country on well_node_version or well_version
  ----                  --AND WNV.IPL_UWI IN ('1000346796', '1000449868', '300000288886', '300000304490', '300000029836', '1004726665' )
  ----           group by wnv.ipl_uwi, wnv.source
  ----         ) tmp83
  ----         inner join
  ----         ( select distinct wnv.ipl_uwi, wnv.source, decode(max(wnv.row_changed_date), null, max(wnv.row_created_date), max(wnv.row_changed_date)) as row_changed_date--, WNV.ROW_CHANGED_DATE, WNV.ROW_CREATED_DATE
  ----              from ppdm.well_node_version wnv
  ----                   inner join ppdm.well_version wv on wnv.ipl_uwi = wv.uwi  and wv.source = wnv.source
  ----                   inner join ppdm.well w on wv.uwi = w.uwi
  ----             where wnv.source = '075TLMO'
  ----             --WHERE WNV.SOURCE = ('080NAD27')
  ----                   and nvl(wnv.geog_coord_system_id, '9999') = '4267'
  ----                   and wnv.active_ind = 'Y'
  ----                   and wv.active_ind = 'Y'
  ----                   and w.country in ('7CN', '7US')  --get country from well, because there may not be an accurate country on well_node_version or well_version
  ----                   --AND WNV.IPL_UWI IN ('1000346796', '1000449868', '300000288886', '300000304490', '300000029836', '1004726665' )
  ----           group by wnv.ipl_uwi, wnv.source
  ----         ) tmp27 on tmp83.ipl_uwi = tmp27.ipl_uwi
  ----   where tmp83.row_changed_date > tmp27.row_changed_date
  ----  ;
  ----  */
  ----
  ----  if v_count > 0 then
  ----    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of North America wells requiring location update of override version: ' || v_count );
  ----  else
  ----    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of North America wells requiring location update of override version: ' || v_count );
  ----  end if;
  ----
  ----  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : North America wells requiring location update of override version');
  ----
  ----exception
  ----  when others
  ----    then
  ----      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : North America wells requiring location update of override version *** Ended with Errors');
  ----end;




  --********************************************************************************
  --  Report Item ID: 017
  --  Check: Wells that have both a 075TLMO override, with nad27 coordinates, and another well version with nad27 coordinates
  --  Log an error if count is greater than zero.
  --  For these wells, see if the override version can be inactivated or deleted, since another version has a nad27 location
  --  Ideally, the count will be zero
  --*********************************************************************************

 /* ---- 20160503 this check is no longer necessary, as the 075TLMO override well version is no longer being used for generated-NAD27 location information
  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : NAD27 075TLMO override well-version with another NAD27 well-version');

    select count(1) into v_count
    --SELECT *
      from ( select distinct wnv.ipl_uwi, wnv.source
               from ppdm.well_node_version wnv
                    inner join ppdm.well_version wv on wnv.ipl_uwi = wv.uwi  and wv.source = wnv.source
              where wnv.source <> '075TLMO'
              --WHERE WNV.SOURCE <> '080NAD27'
                    and nvl(wnv.geog_coord_system_id, '9999') = '4267'
                    and wnv.active_ind = 'Y'
                    and wv.active_ind = 'Y'
                    --AND WNV.IPL_UWI IN ('1000346796', '1000449868', '300000288886', '300000304490', '300000029836', '1004726665', '1004669734' )
             --GROUP BY WNV.IPL_UWI, WNV.SOURCE
           ) tmp
           inner join
           ( select distinct wnv.ipl_uwi, wnv.source
               from ppdm.well_node_version wnv
                    inner join ppdm.well_version wv on wnv.ipl_uwi = wv.uwi  and wv.source = wnv.source
              where wnv.source = '075TLMO'
              --WHERE WNV.SOURCE = '080NAD27'
                    and nvl(wnv.geog_coord_system_id, '9999') = '4267'
                    and wnv.active_ind = 'Y'
                    and wv.active_ind = 'Y'
                    --AND WNV.IPL_UWI IN ('1000346796', '1000449868', '300000288886', '300000304490', '300000029836', '1004726665', '1004669734' )
             --GROUP BY WNV.IPL_UWI, WNV.SOURCE
           ) tmp27 on tmp.ipl_uwi = tmp27.ipl_uwi
    order by 1
    ;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of 075TLMO override well-versions that have another nad27 version: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of 075TLMO override well-versions that have another nad27 version: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : NAD27 075TLMO override well-version with another NAD27 well-version');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : NAD27 075TLMO override well-version with another NAD27 well-version *** Ended with Errors');
  end;
 ----*/



  --********************************************************************************
  --  Report Item ID: 018
  --  Check: Well versions with the same tlm-id (uwi) yet have different ipl_uwi_local values
  --         see checks 29-32 for wells with multiple UWI's (ipl_uwi_local) in associated active well versions
  --  It could be the well versions were incorrectly merged; or someone made a change to a version that should be carried across to other versions; or bad data
  --  Log an error if count is greater than zero.
  --  Ideally, the count will be zero
  --*********************************************************************************
 /* ----20160419 cdong  QC1811 this check is redundant and covered by checks 029 through 032
  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Well Versions with same UWI (TLM-ID) but different IPL_UWI_LOCAL');

    select count(distinct uwi) into v_count
    from (select uwi, count(distinct ipl_uwi_local)
            from ppdm.well_version
           group by uwi
          having count(distinct ipl_uwi_local) > 1

          union all

          select uwi, count(distinct well_num)
            from ppdm.well_version
           group by uwi
          having count(distinct well_num) > 1
         )
         ;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of well-versions with same tlm-id and different IPL_UWI_LOCAL: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of well-versions with same tlm-id and different IPL_UWI_LOCAL: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Well Versions with same UWI (TLM-ID) but different IPL_UWI_LOCAL');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Well Versions with same UWI (TLM-ID) but different IPL_UWI_LOCAL *** Ended with Errors');
  end;
 ----*/




  --********************************************************************************
  --  Report Item ID: 019a, 019b, 019c, 019d, 019e
  --  Check: Orphaned well node-version/node/license/status/well-area records without a matching well_version record
  --
  --  xx       cdong   Task 1374 delete well-area records if the associated well-version is inactive
  --  20140523 cdong   add active ind check to query, as many well_area has been inactivated (by kxedward in a "clean-up" task)
  --  20151113 cdong   QC1738 - delete the orphaned well_area records
  --  20160419 cdong   QC1810 re-purpose 019 for other well data clean-up
  --                     moved original clean-up to 045d (well_version inactive, remove active well_area (task 1374))
  --                     changed clean-up to delete records where there is NO associated well_version record
  --
  --*********************************************************************************

  declare
    v_count_wn                      number    := 0;
    v_count_wnv                     number    := 0;
    v_count_wl                      number    := 0;
    v_count_ws                      number    := 0;
    v_count_wa                      number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Orphaned well records (node, license, status, area)');

    ----get counts------------------------------------------
    ----ppdm.well_node
    select count(1) into v_count_wn
      from wim.rpt_orphan_wn_vw
    ;
    ----ppdm.well_node_version
    select count(1) into v_count_wnv
      from wim.rpt_orphan_wnv_vw
    ;
    ----ppdm.well_license
    select count(1) into v_count_wl
      from wim.rpt_orphan_license_vw
    ;
    ----ppdm.well_status
    select count(1) into v_count_ws
      from wim.rpt_orphan_status_vw
    ;
    ----ppdm.well_area
    select count(1) into v_count_wa
      from wim.rpt_orphan_warea_vw
    ;

    ----delete data-----------------------------------------
    ----ppdm.well_node
    if v_count_wn > 0 then
      delete
      --select node_id, source, node_obs_no, geog_coord_system_id, location_qualifier, ipl_uwi, latitude, longitude, remark, row_created_by, row_created_date
        from ppdm.well_node
       where (node_id, ipl_uwi, source)
               in (select node_id, uwi, source
                     from wim.rpt_orphan_wn_vw
                  )
      ;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ... deleted well_node records where associated well_version record does not exist');
    end if;
    ----ppdm.well_node_version
    if v_count_wnv > 0 then
      delete
      --select node_id, source, node_obs_no, geog_coord_system_id, location_qualifier, ipl_uwi, latitude, longitude, remark, row_created_by, row_created_date
        from ppdm.well_node_version
       where (node_id, source, node_obs_no, geog_coord_system_id, location_qualifier)
               in (select node_id, source, node_obs_no, geog_coord_system_id, location_qualifier
                     from wim.rpt_orphan_wnv_vw
                  )
      ;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ... deleted well_node_version records where associated well_version record does not exist');
    end if;
    ----ppdm.well_license
    if v_count_wl > 0 then
      delete
      --select uwi, source, license_id, license_num, remark, row_created_by, row_created_date
        from ppdm.well_license
       where (uwi, source, license_id)
               in (select uwi, source, license_id
                     from wim.rpt_orphan_license_vw
                  )
      ;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ... deleted well_license records where associated well_version record does not exist');
    end if;
    ----ppdm.well_status
    if v_count_ws > 0 then
      delete
      --select uwi, source, status_id, status, remark, row_created_by, row_created_date
        from ppdm.well_status
       where (uwi, source, status_id)
               in (select uwi, source, status_id
                     from wim.rpt_orphan_status_vw
                  )
      ;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ... deleted well_status records where associated well_version record does not exist');
    end if;
    ----ppdm.well_area
    if v_count_wa > 0 then
      delete
      --select uwi, source, area_id, area_type, remark, row_created_by, row_created_date
        from ppdm.well_area
       where (uwi, source, area_id, area_type)
             in (select uwi, source, area_id, area_type
                   from wim.rpt_orphan_warea_vw
                )
      ;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ... deleted well_area records where associated well_version record does not exist');
    end if;

    commit;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: No well version - number of well node records deleted: ' || v_count_wn );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: No well version - number of well node version records deleted: ' || v_count_wnv );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: No well version - number of well license records deleted: ' || v_count_wl );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: No well version - number of well status records deleted: ' || v_count_ws );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: No well version - number of well area records deleted: ' || v_count_wa );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Orphaned well records (node, license, status, area)');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Orphaned well records (node, license, status, area) *** Ended with Errors');
  end;




  -- ********************************************************************************
  --  Report Item ID: 020, 021, 022
  --  Check: 100TLM source wells that do not have an accompanying public version (300IPL, 450PID, 500PRB)
  --  Log an error if count is greater than zero.
  --  2015-05-04 *** this check needs to be fixed by Kevin Edwards... it is reporting only part of the picture
  --                 Kevin is working on associating CWS wells with IHS-US wells
  --  20160413 cdong  QC1807 use view for Canada and the US
  --                  The criteria for "not have an accompanying public version" has been revised to
  --                    include wells where the CWS wv does have a public wv with the same well-id (TLM-ID)...
  --                    HOWEVER, the public wv has a different UWI (ipl_uwi_local). this is more accurate.
  --                  The international (non Canada/US) CWS wells are in the 880SCWS source, not 100TLM
  --                  CWS only maintains Canada/US wells. the intl data is never updated nor is new data added.
  --                    There is no easy way--like UWI-- to match these int'l CWS versions to public wells.
  --  20160616 cdong  QC1841 change attribute from 'matched_uwi_ind' to 'public_wv_ind'.
  --                    The public_wv_ind attribute is more appropriate.
  --
  -- *********************************************************************************
  declare
    v_cnt_can                       number := 0;
    v_cnt_usa                       number := 0;
    v_cnt_int                       number := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : TLM version without public IHS version');

    select count(*) into v_cnt_can
      from wim.rpt_cws_unmatched_vw
     where country = '7CN'
           and public_wv_ind = 'N'
    ;

    select count(*) into v_cnt_usa
      from wim.rpt_cws_unmatched_vw
     where country = '7US'
           and public_wv_ind = 'N'
    ;

    select count(*) into v_cnt_int
      from (select uwi
              from ppdm.well_version
             where source = '880SCWS'
                   and active_ind = 'Y'
                   and country not in ('7CN', '7US')
            minus
            select uwi
              from ppdm.well_version
             where source = '500PRB'
                   and active_ind = 'Y'
           )
    ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Canadian wells (7CN) without a (300IPL) source: ' || v_cnt_can);
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of US wells (7US) without a (450PID) source: ' || v_cnt_usa);
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of International wells without a (500PRB) source: ' || v_cnt_int);

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : TLM version without public IHS version');

  exception
    when others
    then
      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : TLM version without public IHS version *** Ended with Errors');
  end;




/*
  -- *****************************************************************************
  --  CHECK : Null Surface Node Ids for 300IPL wells
  --  WIM Housekeeping - Checks and updates Null Surface Node Ids ( only if
  -- surface and base nodes are the same in source)
    -- ***************************************************************************

     ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : 300IPL Surface Node Ids CHECK');

     BEGIN
          WIM.UPDATE_300IPL_SUR_NODE_ID;
     END;
     ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : 300IPL Surface Node Ids CHECK');
*/




  --********************************************************************************
  --  Report Item ID: 023
  --  Check: Directional surveys where header active_ind does not match station active_ind: TLM
  --  This should never happen, at least not programatically (from GeoWiz)
  --  Log an error if count is greater than zero.
  --  Ideally, the count will be zero
  --*********************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Dir Srvy active_ind different between header and stations (TLM)');

    select count(1) into v_count
      from ppdm.tlm_well_dir_srvy ds
     where not exists ( select 1
                          from ppdm.tlm_well_dir_srvy_station dss
                         where ds.uwi = dss.uwi
                               and ds.survey_id = dss.survey_id
                               and ds.active_ind = dss.active_ind
                      )
    ;

    ----to see actual differences----
    --select distinct ds.uwi, ds.survey_id, ds.active_ind as header_active_ind, dss.active_ind as station_active_ind
    --  from ppdm.tlm_well_dir_srvy ds
    --       inner join ppdm.tlm_well_dir_srvy_station dss on ds.uwi = dss.uwi and ds.survey_id = dss.survey_id
    -- where exists ( select null
    --                  from ( --better execution plan and more efficient than using a minus
    --                         select ds.uwi, ds.survey_id, ds.active_ind--, dss.active_ind
    --                           from ppdm.tlm_well_dir_srvy ds
    --                          where not exists ( select 1--null
    --                                               from ppdm.tlm_well_dir_srvy_station dss
    --                                              where ds.uwi = dss.uwi
    --                                                    and ds.survey_id = dss.survey_id
    --                                                    and ds.active_ind = dss.active_ind
    --                                           )
    --
    --                       ) b
    --                 where ds.uwi = b.uwi
    --                       and ds.survey_id = b.survey_id
    --              )
    -- order by ds.uwi, ds.survey_id, ds.active_ind
    --;

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of dir srvy where active_ind is DIFFERENT between header and stations (TLM): ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All dir srvy headers and stations have matching active indictors.');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (TLM)');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (TLM) *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 024
  --  Check: Directional surveys where header active_ind does not match station active_ind: IHS Canada
  --  Log an error if count is greater than zero.
  --  Ideally, the count will be zero.  Although, we have no control over data at IHS
  --    note: must have the db-link for c_talisman on the ihsdata db
  --*********************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Dir Srvy active_ind different between header and stations (IHS Canada)');

    select count(1) into v_count
      from well_dir_srvy@c_talisman ds
     where not exists ( select 1
                          from well_dir_srvy_station@c_talisman dss
                         where ds.uwi = dss.uwi
                               and ds.survey_id = dss.survey_id
                               and ds.active_ind = dss.active_ind
                      )
    ;

    ----to see actual differences----
    --see sample code snippet from TLM check, and modify accordingly

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of dir srvy where active_ind is DIFFERENT between header and stations (IHS Canada): ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All dir srvy headers and stations have matching active indictors.');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (IHS Canada)');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (IHS Canada) *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 025
  --  Check: Directional surveys where header active_ind does not match station active_ind: IHS US
  --  Log an error if count is greater than zero.
  --  Ideally, the count will be zero.  Although, we have no control over data at IHS
  --    note: must have the db-link for c_talisman_us on the ihsdataq db
  --*********************************************************************************

  declare
    v_count                         number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Dir Srvy active_ind different between header and stations (IHS US)');

    select count(1) into v_count
      from well_dir_srvy@c_talisman_us ds
     where not exists ( select 1
                          from well_dir_srvy_station@c_talisman_us dss
                         where ds.uwi = dss.uwi
                               and ds.survey_id = dss.survey_id
                               and ds.active_ind = dss.active_ind
                      )
    ;

    ----to see actual differences----
    --see sample code snippet from TLM check, and modify accordingly

    if v_count > 0 then
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of dir srvy where active_ind is DIFFERENT between header and stations (IHS US): ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All dir srvy headers and stations have matching active indictors.');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (IHS US)');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Dir Srvy active_ind different between header and stations (IHS US) *** Ended with Errors');
  end;




  --************************************************************************************************************************************
  --  Report Item ID: 026
  --  CHECK : Well Node NULL coord_system_id Fix
  --  WIM Housekeeping - check to look for wells (nodes) with an null coordinate_system_id
  --  2014-07-17 kedwards: created
  --  2015-05-05  cdong   QC1651 fix check.  the string variable is too small to concatenate all errors
  --                        there no need to output the change... removed code
  --                        added filter to make sure geog_coord_system_id (source) is not null
  --                        note: there is NO coord_system_id attribute in well_node_version
  --************************************************************************************************************************************

  declare
      cursor v_c is
          select ipl_uwi, node_id, source, node_obs_no, node_position, active_ind, country, geog_coord_system_id, coord_system_id
          from ppdm.well_node
          where coord_system_id is null
                and geog_coord_system_id is not null
      ;
      type t_vc is table of v_c%rowtype index by binary_integer;

      v_tc    t_vc;
      v_done  boolean;
      v_cnt   pls_integer;
  begin
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Null coord_system_id Fix');
      v_cnt := 0;

      open v_c;
      loop
          fetch v_c bulk collect into v_tc limit 50;
          v_done := v_c%notfound;

          v_cnt := v_cnt + v_tc.count;

          forall i in 1 .. v_tc.count
              update ppdm.well_node
              set coord_system_id = v_tc(i).geog_coord_system_id
              where ipl_uwi = v_tc(i).ipl_uwi
                  and node_id = v_tc(i).node_id
                  and source = v_tc(i).source
                  and node_obs_no = v_tc(i).node_obs_no
                  and node_position = v_tc(i).node_position
                  and active_ind = v_tc(i).active_ind
                  and country = v_tc(i).country
              ;
          exit when v_done;
      end loop;
      commit;

      if v_cnt > 0 then
        ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with NULL coord system_id fixed: ' || v_cnt || chr(13) || chr(10));
      end if;
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Null coord_system_id Fix');

  exception
  when others
    then
      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Number of wells with NULL coord system_id Fix *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 027 and 028
  --  Check: Well names with CRLF or tab character
  --  Log an error if count is greater than zero.  Ideally, the count will be zero.
  --    If found for CWS well version, notify Bonnie Pearson or CWS contact
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_wv                      number    := 0;
    v_uwi                           ppdm.well.uwi%type;
    v_well_name                     ppdm.well.well_name%type;
    v_country                       ppdm.well.country%type;
    v_primary_source                ppdm.well.primary_source%type;

    cursor crsr_wells
    is
    select uwi, well_name, country, primary_source
      from ppdm.well
     where active_ind = 'Y'
           and
            (instr(well_name, chr(9)) > 0
             or instr(well_name, chr(10)) > 0
             or instr(well_name, chr(13)) > 0
            )
    ;

    cursor crsr_well_versions
    is
    select uwi, well_name, country, source
      from ppdm.well_version
     where active_ind = 'Y'
           and
            (instr(well_name, chr(9)) > 0
             or instr(well_name, chr(10)) > 0
             or instr(well_name, chr(13)) > 0
            )
    ;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : CRLF or tab in well name');

    select count(1) into v_count
           --uwi, active_ind, well_name, country, primary_source
           --  , dump(well_name) dump_str
           --  , trim(replace(replace(replace(well_name, chr(9), ' '), chr(10), ''), chr(13), '')) as new_str
           --  , dump(replace(replace(replace(well_name, chr(9), ' '), chr(10), ''), chr(13), '')) as dump_new_str
           --  , row_changed_by, row_changed_date
      from ppdm.well
     where active_ind = 'Y'
           and
            (instr(well_name, chr(9)) > 0
             or instr(well_name, chr(10)) > 0
             or instr(well_name, chr(13)) > 0
            )
    ;

    select count(1) into v_count_wv
           --uwi, active_ind, well_name, country, source
           --  , dump(well_name) dump_str
           --  , trim(replace(replace(replace(well_name, chr(9), ' '), chr(10), ''), chr(13), '')) as new_str
           --  , dump(replace(replace(replace(well_name, chr(9), ' '), chr(10), ''), chr(13), '')) as dump_new_str
           --  , row_changed_by, row_changed_date
      from ppdm.well_version
     where active_ind = 'Y'
           and
            (instr(well_name, chr(9)) > 0
             or instr(well_name, chr(10)) > 0
             or instr(well_name, chr(13)) > 0
            )
    ;

    ----to see actual differences----
    --see sample code snippet from TLM check, and modify accordingly

    if v_count > 0 then

      --log error, since this can cause DataFinder Petrel export issues
      ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Number of wells with CRLF or tab in well name: ' || v_count );

      if v_count <= v_maxrowstodisplay then
        open crsr_wells;

        loop
          fetch crsr_wells into v_uwi, v_well_name, v_country, v_primary_source;
          exit when crsr_wells%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Well with CRLF and/or tab in well name: uwi = ' || v_uwi
                                                || ', well_name = ' || v_well_name
                                                || ', country = ' || v_country
                                                || ', primary_source = ' || v_primary_source
                                                );
        end loop;
      end if;

    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All well names okay, no CRLF.');
    end if;

    if v_count_wv > 0 then

      --log warning, since this may or may not roll-up, depending on the source
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of active well_versions with CRLF or tab in well name: ' || v_count_wv);

      if v_count_wv <= v_maxrowstodisplay then
        open crsr_well_versions;

        loop
          fetch crsr_well_versions into v_uwi, v_well_name, v_country, v_primary_source;
          exit when crsr_well_versions%notfound;

          ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Well versions with CRLF and/or tab in well name: uwi = ' || v_uwi
                                                || ', well_name = ' || v_well_name
                                                || ', country = ' || v_country
                                                || ', source = ' || v_primary_source
                                                );

        end loop;
      end if;

    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All well-version well names okay, no CRLF.');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : CRLF or tab in well name');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : CRLF or tab in well name *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 029, 030, 031, 032
  --  Check: Wells with more than one UWI (ipl_uwi_local) in associated active well versions
  --  2015-05-04  cdong   QC1674
  --                      use view wim.rpt_dupe_ipluwi_in_well_vw, which EXCLUDES CWS-CANCEL well versions
  --                      to see list of affected wells, query the view
  --  2016-02-24  cdong   QC1770/1771
  --  2016-06-09  cdong   QC1833 output count even if no issue found, for reporting purposes
  --
  --*********************************************************************************

  declare
    v_count_7cn_abbc                number    := 0;
    v_count_7cn_other               number    := 0;
    v_count_7us                     number    := 0;
    v_count_other                   number    := 0;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with multiple UWIs in well versions');

    --canada, alberta and bc and sk
    select count(1) into v_count_7cn_abbc
      from wim.rpt_dupe_ipluwi_in_well_vw
     where country = '7CN'
           and province_state in ('AB', 'BC', 'SK')
    ;
    --canada, not alberta, bc, or sk
    select count(1) into v_count_7cn_other
      from wim.rpt_dupe_ipluwi_in_well_vw
     where country = '7CN'
           and province_state not in ('AB', 'BC', 'SK')
    ;
    --usa
    select count(1) into v_count_7us
      from wim.rpt_dupe_ipluwi_in_well_vw
     where country = '7US'
    ;
    --not canada or usa
    select count(1) into v_count_other
      from wim.rpt_dupe_ipluwi_in_well_vw
     where country not in ('7CN', '7US')
      ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple UWIs in active well versions (Canada AB, BC, SK): ' || v_count_7cn_abbc );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple UWIs in active well versions (Canada other): ' || v_count_7cn_other );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple UWIs in active well versions (USA): ' || v_count_7us );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple UWIs in active well versions (Other): ' || v_count_other );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with multiple UWIs in well versions');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with multiple UWIs in well versions *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 033
  --  Check: Wells with more than one country in active well versions
  --  2015-05-04  cdong   QC1674
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with multiple countries in well versions');

    select count(distinct uwi) into v_count
      from (select distinct uwi
              from ppdm.well_version
             where active_ind = 'Y'
                   and country is not null
             group by uwi
             having count(distinct country) > 1
           )
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi
                         , listagg(country, ', ') within group (order by source) as country_list
                    from ppdm.well_version
                   where active_ind = 'Y'
                         and country is not null
                   group by uwi
                   having count(distinct country) > 1
                 )
          loop
              ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: wells with multiple countries in well versions: ' || i.uwi || ' -> ' || i.country_list);
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple countries in active well versions: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with multiple countries in active well versions: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with multiple countries in well versions');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with multiple countries in well versions *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 034
  --  Check: Well nodes with more than one country in active well node versions
  --  2015-05-04  cdong   QC1674
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with multiple countries in well node versions');

    select count(distinct ipl_uwi) into v_count
      from (select distinct ipl_uwi
              from ppdm.well_node_version
             where active_ind = 'Y'
                   and country is not null
             group by ipl_uwi
             having count(distinct country) > 1
           )
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select ipl_uwi as uwi
                         , listagg(country, ', ') within group (order by source) as country_list
                    from ppdm.well_node_version
                   where active_ind = 'Y'
                         and country is not null
                   group by ipl_uwi
                   having count(distinct country) > 1
                 )
          loop
              ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: well with multiple countries in node versions: ' || i.uwi || ' -> ' || i.country_list);
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple countries in active well node versions: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with multiple countries in active well node versions: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with multiple countries in well node versions');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with multiple countries in well node versions *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 035
  --  Check: TLM Directional Surveys well version without active dir srvy data
  --  2015-05-04  cdong   QC1674
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with dir srvy well version and no active proprietary dir srvy data');

    select count(distinct uwi) into v_count
      from ppdm.well_version
     where active_ind = 'Y'
           and source = '090DSS'
           and uwi not in (select distinct uwi
                             from ppdm.tlm_well_dir_srvy
                            where active_ind = 'Y'
                           )
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select distinct uwi
                    from ppdm.well_version
                   where active_ind = 'Y'
                         and source = '090DSS'
                         and uwi not in (select distinct uwi
                                           from ppdm.tlm_well_dir_srvy
                                          where active_ind = 'Y'
                                         )
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with dir srvy well version and no active proprietary dir srvy data: ' || i.uwi);
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with a dir srvy well version and no active proprietary dir srvy data: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with a dir srvy well version and no active proprietary dir srvy data: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with dir srvy well version and no active proprietary dir srvy data');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with dir srvy well version and no active proprietary dir srvy data *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 037
  --  Check: Composite wells with zero or negative KL Elevation
  --  20150806  cdong   QC1686
  --  20160318  cdong   QC1791 separate count by region - replace 037 with sub-checks 037A and 037B
  --*********************************************************************************
 /* ----20160318 QC1791 comment out this item
  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with KB Elevation of zero or negative value');

    select count(distinct uwi) into v_count
      from ppdm.well
     where active_ind = 'Y'
           and nvl(kb_elev, 9999) <= 0
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi, well_name, country, kb_elev
                    from ppdm.well
                   where active_ind = 'Y'
                         and nvl(kb_elev, 9999) <= 0
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: wells with KB Elevation of zero or negative value: ' || i.uwi || ' | ' || nvl(i.well_name, 'no-well-name') || ' | ' || nvl(i.country, 'no-country') || ' | ' || nvl(i.kb_elev, 0));
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB Elevation of zero or negative value: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: All wells with non-null KB Elevation have a value greater than zero.');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with KB Elevation of zero or negative value');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with KB Elevation of zero or negative value *** Ended with Errors');
  end;
 */




  --********************************************************************************
  --  Report Item ID: 037, 037a, and 037b
  --  Check: Composite wells with zero or negative KL Elevation
  --  20160318 cdong QC1791 take item 037 and separate count by region
  --                 (a) for AB and SK (Canada)
  --                 (b) other
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with KB Elevation of zero or negative value');

    select count(1) into v_count
      from wim.rpt_kb_zero_less_vw
    ;

    select count(1) into v_count_a
      from wim.rpt_kb_zero_less_vw
     where country = '7CN' and province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB Elevation of zero or negative value: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB Elevation of zero or negative value (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB Elevation of zero or negative value (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with KB Elevation of zero or negative value');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with KB Elevation of zero or negative value *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 038 and 039
  --  Check: Records management records (ppdm.rm_info_item_content) without a composite well (038) or active area (039)
  --  2015-05-04  cdong   QC1713
  --*********************************************************************************

  declare
    v_count_w                       number    := 0;
    v_count_a                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : RM records without an active well or an active area');

    ----count of RM records where associated well does not exist
    select count(1) into v_count_w
      from (select distinct information_item_id, info_item_type, content_obs_no, uwi
              from wim.rpt_orphan_rm_well_vw
           )
    ;

    ----count of RM records where associated area does not exist
    select count(1) into v_count_a
      from (select distinct information_item_id, info_item_type, content_obs_no, area_id, area_type
              from wim.rpt_orphan_rm_area_vw
           )
    ;

    ----well
    if v_count_w > 0 then
      if v_count_w <= v_maxrowstodisplay then
        for i in (select information_item_id, physical_item_id, location_reference, reference_num, legacy_name, uwi
                    from wim.rpt_orphan_rm_well_vw
                   order by uwi, information_item_id
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: RM records without an active well: '
                  || ' loc-ref '        || i.location_reference
                  || ' | legacy-name '  || i.legacy_name
                  || ' | ref-num '      || i.reference_num
                  || ' | info-item-id ' || i.information_item_id
                  || ' | phys-item-id ' || i.physical_item_id
                  || ' | uwi '          || i.uwi
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of RM records without an active well: ' || v_count_w );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of RM records without an active well: ' || v_count_w );
    end if;


    ----area
    if v_count_a > 0 then
      if v_count_a <= v_maxrowstodisplay then
    for i in (select information_item_id, physical_item_id, location_reference, reference_num, legacy_name, area_id, area_type
                    from wim.rpt_orphan_rm_area_vw
                   order by area_id, area_type, information_item_id
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: RM records without an active well: '
                  || ' loc-ref '        || i.location_reference
                  || ' | legacy-name '  || i.legacy_name
                  || ' | ref-num '      || i.reference_num
                  || ' | info-item-id ' || i.information_item_id
                  || ' | phys-item-id ' || i.physical_item_id
                  || ' | area '         || i.area_id
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of RM records without an active area: ' || v_count_a );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of RM records without an active area: ' || v_count_a );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : RM records without an active well or an active area');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : RM records with no active well or active area *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 040
  --  Check: Directional Surveys.
  --         Identify wells with three or more active dir srvy headers. Typically, there should only be two headers-- one for nad27 and one for nad83-- in Canada and the US.
  --         This is per the dir srvy steward's process for loading directional surveys
  --  2015-11-16  cdong   QC1727
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Directional Surveys with multiple headers');

    ----count of wells with "too-many" directional survey headers
    select count(1) into v_count
      from wim.rpt_dirsrvy_too_many_vw
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi, well_name, country, cnt_srvys
                    from wim.rpt_dirsrvy_too_many_vw
                   order by uwi
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Directional Surveys with multiple headers: '
                  || ' uwi '            || i.uwi
                  || ' | well name '    || i.well_name
                  || ' | country '      || i.country
                  || ' | survey count ' || i.cnt_srvys
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Directional Surveys with multiple headers: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of Directional Surveys with multiple headers: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Directional Surveys with multiple headers');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Directional Surveys with multiple headers *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 041
  --  Check: Directional Surveys
  --         Identify directional surveys with "duplicate" measured-depth values in consecutive stations.  Dupe MD's can cause problems for Petrel.
  --         The original data from the vendor can contain duplicates.  The persons loading dir srvys will try to remove the dupes, where possible.
  --         However, sometimes duplicates occur when converting between units and rounding.
  --  2015-11-16  cdong   QC1727
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Directional Surveys with duplicate MD');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_dirsrvy_dupe_md_vw
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi, survey_id, station_md, stations, well_name, country, row_created_by, row_created_date
                    from wim.rpt_dirsrvy_dupe_md_vw
                   order by uwi
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Directional Surveys with duplicate MD: '
                  || ' uwi '            || i.uwi
                  || ' | well name '    || i.well_name
                  || ' | country '      || i.country
                  || ' | survey id '    || i.survey_id
                  || ' | station_md '   || i.station_md
                  || ' | stations '     || i.stations
                  || ' | created by '   || i.row_created_by
                  || ' | created date ' || i.row_created_date
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Directional Surveys with duplicate MD: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of Directional Surveys with duplicate MD: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Directional Surveys with duplicate MD');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Directional Surveys with duplicate MD *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 042
  --  Check: Wells with Override well versions that were last updated or created more than one year ago.
  --         The Data Steward(s) should review these versions and confirm their validity.
  --  20160120  cdong   QC1758
  --  20160318  cdong   QC1792 separate count by region - replace 042 with sub-checks 042A and 042B
  --*********************************************************************************
 /* ----20160318 QC1792 comment out this item
  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with an active Override well version that is old');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_old_override_vw
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi, ipl_uwi_local, well_name, country, province_state, remark
                         , row_created_date, row_created_by, row_changed_date, row_changed_by
                    from wim.rpt_old_override_vw
                   order by uwi
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Wells with an active Override well version that is old: '
                  || ' uwi '              || i.uwi
                  || ' | ipl_uwi_local '  || nvl(i.ipl_uwi_local, '')
                  || ' | well name '      || nvl(i.well_name, '')
                  || ' | country '        || nvl(i.country, '')
                  || ' | province_state ' || nvl(i.province_state, '')
                  || ' | created date '   || i.row_created_date
                  || ' | changed date '   || nvl(i.row_changed_date, '')
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Wells with an active Override well version that is old: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of Wells with an active Override well version that is old: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with an active Override well version that is old');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with an active Override well version that is old *** Ended with Errors');
  end;
 */



  --********************************************************************************
  --  Report Item ID: 042, 042a, and 042b
  --  Check: Wells with Override well versions that were last updated or created more than one year ago.
  --         The Data Steward(s) should review these versions and confirm their validity.
  --  20160318 cdong QC1792 take item 042 and separate count by region
  --                 (a) for AB and SK (Canada)
  --                 (b) other
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Wells with an active Override well version that is old');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_old_override_vw
    ;

    select count(1) into v_count_a
      from wim.rpt_old_override_vw
     where country = '7CN' and province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Wells with an active Override well version that is old: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Wells with an active Override well version that is old (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of Wells with an active Override well version that is old (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Wells with an active Override well version that is old');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Wells with an active Override well version that is old *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 043
  --  Check: Wells where the KB elevation is equivalent to the ground elevation (GLE).
  --         The Data Steward(s) should review these wells and correct the data.
  --  20160120  cdong   QC1760
  --  20160318  cdong   QC1793 separate count by region - replace 043 with sub-checks 043A and 043B
  --*********************************************************************************
 /* ----20160318 QC1791 comment out this item
  declare
    v_count                         number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with KB elevation equal to ground elevation');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_dupe_kb_ground_elev_vw
    ;

    if v_count > 0 then
      if v_count <= v_maxrowstodisplay then
        for i in (select uwi, ipl_uwi_local, well_name, country, province_state
                         , primary_source, kb_elev
                    from wim.rpt_dupe_kb_ground_elev_vw
                   order by uwi
                 )
          loop
            ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: wells with KB elevation equal to ground elevation: '
                  || ' uwi '              || i.uwi
                  || ' | ipl_uwi_local '  || nvl(i.ipl_uwi_local, '')
                  || ' | well name '      || nvl(i.well_name, '')
                  || ' | country '        || nvl(i.country, '')
                  || ' | province_state ' || nvl(i.province_state, '')
                  || ' | elevation '      || nvl(i.kb_elev, '')
                );
          end loop;
      end if;
      ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB elevation equal to ground elevation: ' || v_count );
    else
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of wells with KB elevation equal to ground elevation: ' || v_count );
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : wells with KB elevation equal to ground elevation');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : wells with KB elevation equal to ground elevation *** Ended with Errors');
  end;
 */



  --********************************************************************************
  --  Report Item ID: 043, 043a, and 043b
  --  Check: Wells where the KB elevation is equivalent to the ground elevation (GLE).
  --         The Data Steward(s) should review these wells and correct the data.
  --  20160318 cdong QC1793 take item 043 and separate count by region
  --                 (a) for AB and SK (Canada)
  --                 (b) other
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with KB elevation equal to ground elevation');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_dupe_kb_ground_elev_vw
    ;

    select count(1) into v_count_a
      from wim.rpt_dupe_kb_ground_elev_vw
     where country = '7CN' and province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB elevation equal to ground elevation: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB elevation equal to ground elevation (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with KB elevation equal to ground elevation (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : wells with KB elevation equal to ground elevation');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : wells with KB elevation equal to ground elevation *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 044, 044a and 044b
  --  Check: Wells with multiple active license numbers.
  --         The Data Steward(s) should review these wells and correct the data.
  --         This check is relevant for North America, and does not apply in Asia-Pacific
  --  20160321 cdong QC1784
  --  20160509 cdong QC1819 add BC to (a)
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with multiple active license numbers');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_well_all_licenses_vw wl
     where wl.formatted_license_count > 1
    ;

    select count(1) into v_count_a
      from wim.rpt_well_all_licenses_vw wl
           inner join ppdm.well w on wl.uwi = w.uwi
     where wl.formatted_license_count > 1
           and w.country = '7CN' and w.province_state in ('AB', 'SK', 'BC')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple active license numbers: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple active license numbers (AB,SK,BC): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with multiple active license numbers (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : wells with multiple active license numbers');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : wells with multiple active license numbers *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 045a, 045b, and 045c
  --  Check: Inactive well version with active well licenses, node-versions, or statuses.
  --         This is a automatica data-cleanup activity for WIM Housekeeping.
  --         The Gateway should be inactivating the related records when a well version is inactivated.
  --           Note: as of 2016-03-21, there is a gap with the Gateway, pending a fix.
  --  20160321 cdong QC1783
  --  20160420 cdong QC1810 Moved well-area check from report-item 019 to here, grouping common checks together
  --*********************************************************************************

  declare
    v_count_wl                      number    := 0;
    v_count_wnv                     number    := 0;
    v_count_ws                      number    := 0;
    v_count_wa                      number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : inactive well versions with active license, node, or status');

    ----inactivate records since the associated well version is inactive
    begin
      for wl in (select uwi, source  from wim.rpt_bad_activeind_license_vw)
      loop
        update ppdm.well_license
           set active_ind = 'N'
         where uwi = wl.uwi
               and source = wl.source
               and active_ind = 'Y'
        ;

        v_count_wl  := v_count_wl + 1;
      end loop;

      exception
        when others
          then
            ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Error - inactive well versions with active license, node, or status - unable to inactivate well license');
    end;

    begin
      for wnv in (select uwi, source  from wim.rpt_bad_activeind_wnv_vw)
      loop
        update ppdm.well_node_version
           set active_ind = 'N'
         where ipl_uwi = wnv.uwi
               and source = wnv.source
               and active_ind = 'Y'
        ;

        v_count_wnv := v_count_wnv + 1;
      end loop;

      exception
        when others
          then
            ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Error - inactive well versions with active license, node, or status - unable to inactivate well node version');
    end;

    begin
      for ws in (select uwi, source  from wim.rpt_bad_activeind_status_vw)
      loop
        update ppdm.well_status
           set active_ind = 'N'
         where uwi = ws.uwi
               and source = ws.source
               and active_ind = 'Y'
        ;

        v_count_ws  := v_count_ws + 1;
      end loop;

      exception
        when others
          then
            ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Error - inactive well versions with active license, node, or status - unable to inactivate well status');
    end;


    -----------------------------------------
    ----well_area records: delete instead of inactivating. "extra" well_area records can lead to well-move problems.
    select count(*) into v_count_wa
      from wim.rpt_bad_activeind_warea_vw
    ;

    if v_count_wa > 0 then
      begin
        delete
          --select uwi, source, area_id, area_type, remark, row_created_by, row_created_date
          from ppdm.well_area
         where (uwi, source)
                 in (select uwi, source
                       from wim.rpt_bad_activeind_warea_vw
                    )
        ;
        --ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: ...deleted well area records where associated well_version record is inactive');

        exception
          when others
            then
              ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: Error - inactive well versions with active license, node, or status - unable to delete well area');
      end;
    end if;

    ----commit the changes
    commit;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of inactive well versions with active license(s) fixed: ' || v_count_wl );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of inactive well versions with active node version(s) fixed: ' || v_count_wnv );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of inactive well versions with active status(es) fixed: ' || v_count_ws );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Number of inactive well versions with active well_area(s) fixed: ' || v_count_wa );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : inactive well versions with active license, node, or status');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : inactive well versions with active license, nodes, or statuses *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 046
  --  Check: Wells with only an active GDM (700TLME) well version and no inventory.
  --         The Data Steward(s) should review these wells. It may be possible to remove this well (version).
  --         This check is relevant for North America, and does not apply in Asia-Pacific
  --  20160324 cdong QC1764
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : GDM-version-only wells with no inventory');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_gdmwv_no_inventory_vw w
    ;

    select count(1) into v_count_a
      from wim.rpt_gdmwv_no_inventory_vw w
     where w.country = '7CN' and w.province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of GDM-version-only wells with no inventory: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of GDM-version-only wells with no inventory (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of GDM-version-only wells with no inventory (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Number of GDM-version-only wells with no inventory');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : GDM-version-only wells with no inventory *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 047
  --  Check: Wells with only a surface or bottom-hole location and not the other.
  --         The Data Steward(s) should review these wells. Petrel is focused on surface locations.
  --           Ideally, all wells have a surface and a bottom. At the least, for Petrel, a surface is desired.
  --  20160324 cdong QC1781
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : wells with only one node position');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_wells_single_node_vw w
    ;

    select count(1) into v_count_a
      from wim.rpt_wells_single_node_vw w
     where w.country = '7CN' and w.province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with only one node position: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with only one node position (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of wells with only one node position (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : wells with only one node position');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : wells with only one node position *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 048
  --  Check: Failed inactivations due to inventory
  --         The Gateway will (eventually) check for local inventory count when inactivating.
  --           So, the only failures should be for local well versions (like CWS, or GDM) and (typically) not IHS.
  --         This check is relevant for North America, and does not apply in Asia-Pacific
  --  20160324 cdong QC1740
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : failed well version inactivations due to inventory');

    ----get count(s)
    select count(1) into v_count
      from wim.rpt_fail_inactivate_bc_inv_vw w
    ;

    select count(1) into v_count_a
      from wim.rpt_fail_inactivate_bc_inv_vw w
     where w.country = '7CN' and w.province_state in ('AB', 'SK')
    ;

    v_count_b   :=  v_count - v_count_a ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of failed well version inactivations due to inventory: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of failed well version inactivations due to inventory (AB,SK): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of failed well version inactivations due to inventory (Other): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : failed well version inactivations due to inventory');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : failed well version inactivations due to inventory *** Ended with Errors');
  end;



  --********************************************************************************
  --  Report Item ID: 049, 049a and 049b
  --  Check: UWI's with multiple composite wells
  --         A UWI should be unique and associated with a single (composite) well, in a given country.
  --         This check is very similar to 002; however that check is for a UWI shared between well versions of different wells.
  --         The Data Steward(s) should review the affected wells.
  --         This check is relevant for North America, and does not apply in Asia-Pacific
  --  20160331 cdong QC1798
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : unique well identifiers shared by multiple composite wells');

    ----get count(s)
    select count(1) into v_count_a
      from wim.rpt_uwi_multi_well_ca_vw w
    ;

    select count(1) into v_count_b
      from wim.rpt_uwi_multi_well_us_vw w
    ;

    ----this is different than some other checks, in that the main count is the sum of check-a and check-b
    v_count     :=  v_count_a + v_count_b ;

    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of unique well identifiers shared by multiple composite wells: ' || v_count );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of unique well identifiers shared by multiple composite wells (Canada): ' || v_count_a );
    ppdm_admin.tlm_process_logger.warning('WIM_HOUSEKEEPING: Number of unique well identifiers shared by multiple composite wells (USA): ' || v_count_b );

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : unique well identifiers shared by multiple composite wells');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : unique well identifiers shared by multiple composite wells *** Ended with Errors');
  end;




  --********************************************************************************
  --  Report Item ID: 050a, 050b, 050c, 050d
  --  Check: Review select well_version attributes and remove leading/trailing blank-space chracter(s).
  --         Execute procedure to update select attributes, where TRIM() is necessary.
  --         Check for any CWS well versions with problem-condition and return count.
  --         Finally, do a final check of other sources, in case the procedure failed.
  --
  --  20160617 cdong QC1843 and 1844
  --*********************************************************************************

  declare
    v_count                         number    := 0;
    v_count_a                       number    := 0;
    v_count_b                       number    := 0;
    --v_maxrowstodisplay              number    := 15;

  begin
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Start : Check well version attributes for TRIM()');

    ----execute procedure to trim well version attributes
    begin

      trim_wv_attributes;

      exception
        when others then NULL;

    end;


    ----get count(s) for CWS well versions
    select count(1) into v_count_a
      from wim.rpt_wv_trim_attributes_vw w
     where source = '100TLM'
    ;

    ----get count(s) for non-CWS well versions. note: view already excludes ihs.
    select count(1) into v_count_b
      from wim.rpt_wv_trim_attributes_vw w
     where source <> '100TLM'
    ;

    ----this is different than some other checks, in that the main count is the sum of check-a and check-b
    v_count     :=  v_count_a + v_count_b ;

    ----under normal circumstances, there shouldn't be any well versions requiring trim of well name or uwi
    ---- log count
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Trim required - Number of well version records (cws): ' || v_count_a );
    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Trim required - Number of well version records (not IHS or CWS): ' || v_count_b );

    if v_count = 0 then
      ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: Check well version attributes for TRIM() - attributes okay, no spaces');
    end if;

    ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: End : Check well version attributes for TRIM()');

  exception
    when others
      then
        ppdm_admin.tlm_process_logger.error('WIM_HOUSEKEEPING: End : Check well version attributes for TRIM() *** Ended with Errors');
  end;







  --********************************************************************************
  --  Report Item ID: not-applicable
  --  Check: Run procedure to identify when IHS last updated its data
  --         There is no need to include the output of the procedure in the housekeeping counts; there is nothing to count
  --         However, the TIS Housekeeping report can display the output from this procedue
  --  2015-11-13  cdong   QC1653
  --*********************************************************************************

  begin
    ----wim.check_ihs_refresh_date;

    --create a single-run database job to execute the procedure. this way, wim housekeeping doesn't have to wait for the procedure to finish.
    sys.dbms_job.isubmit
    (  job       => 876
     , what      => 'WIM.CHECK_IHS_REFRESH_DATE;'
     , next_date => sysdate+1/1440
    );

    commit;

  end;



  ------------------------------------------------------------------------------
  --END housekeeping procedure
  ppdm_admin.tlm_process_logger.info('WIM_HOUSEKEEPING: .......... END Housekeeping');

END;

