create or replace PACKAGE     wim_util
IS

/******************************************************************************************************************************
 SCRIPT: WIM.wim_util.pks

 PURPOSE:
   Package spec for the WIM_UTIL functionality .
   THis package contains functions and procedures to:
    Clean WIM_STG tables, wim_Audit_Log table, and compress well name to be used in WIM_SEARCH.
    Converts UOM using ppdm_unit_conversion table.

    Procedure/Function Details
        uom_conversion              Function    Converts UOM using values in ppdm_unit_conversion table.
        get_sys_number_parameter    Function    Returns numeric values from Sys_Parameter for specific parameter_nm
        get_sys_string_parameter    Function    Returns string values from Sys_Parameter for specific parameter_nm
        cleanup_stg_tables          Procedure   Deletes from wim_stg_* tables.
        cleanup_audit_log           Procedure   Deletes from wim_audit_log table.
        compress_well_name          Function    Removes all the special characters from well_name and
                                                Returns compressed well name.
        cleanup_Special_Chars       Function    Removes all the special characters and replaces with space from well_name and
                                                Returns compressed well name.
        Get_Uwi_Sort                Function    Function to read IPL_UWI_LOCAL and create and return UWI_SORT.
        format_us_api               Function    Returns a re-formatted string that complies with the US Well Number (API) syntax.
                                                see http://info.drillinginfo.com/api-number-dead-long-live-us-well-number/ for background

 DEPENDENCIES
   WIM_STG_* tables
   WIM_AUDIT_LOG talbe
   ppdm_unit_conversion table

 EXECUTION:
   See Package Specification

   Syntax:
    N/A

 HISTORY:
  See Package body
---------------------------------------------------------------------------------------------------------------------------------------------*/

   number_data_type   CONSTANT CHAR (6) := 'NUMBER';
   string_data_type   CONSTANT CHAR (6) := 'STRING';

/******************************************************************************************************
  UOM_CONVERSION Function
 *******************************************************************************************************
   This function Converts UOM using values in ppdm_unit_conversion table.

    Parameter notes:
      p_uom_from          Unit of Measure coverting From
      p_uom_to            Unit of Measure converting to
      p_value              Value to be converted.
-------------------------------------------------------------------------------------------------------*/
  FUNCTION uom_conversion (
      p_uom_from   VARCHAR2,
      p_uom_to     VARCHAR2,
      p_value      NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  GET_SYS_NUMBER_PARAMETER Function
 *******************************************************************************************************
   This function returns number values from Sys_Parameter for specific parameter_nm

    Parameter notes:
      p_param_name          Name of the parameter used to get the number value
-------------------------------------------------------------------------------------------------------*/
   FUNCTION get_sys_number_parameter (p_param_name VARCHAR2)
      RETURN NUMBER;

/******************************************************************************************************
  GET_SYS_STRING_PARAMETER Function
 *******************************************************************************************************
   This function returns string values from Sys_Parameter for specific parameter_nm

    Parameter notes:
      p_param_name          Name of the parameter used to get the string value
-------------------------------------------------------------------------------------------------------*/
   FUNCTION get_sys_string_parameter (p_param_name VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************************************
  CLEANUP_STG_TABLES Procedure
 *******************************************************************************************************
   This procedure deletes from wim_stg_* tables.

    Parameter notes:
      None
-------------------------------------------------------------------------------------------------------*/
   PROCEDURE cleanup_stg_tables;

/******************************************************************************************************
  CLEANUP_AUDIT_LOG Procedure
 *******************************************************************************************************
   This procedure deletes from wim_audit_log table.

    Parameter notes:
      None
-------------------------------------------------------------------------------------------------------*/
   PROCEDURE cleanup_audit_log;


/******************************************************************************************************
  COMPRESS_WELL_NAME Function
 *******************************************************************************************************
   This function removes all the special characters from well_name and
   eturns compressed well name.

    Parameter notes:
      p_well_name            well_name to be compressed.
-------------------------------------------------------------------------------------------------------*/
   FUNCTION compress_well_name (p_well_name IN VARCHAR2)
      RETURN VARCHAR2 deterministic ;

/******************************************************************************************************
  cleanup_Special_Chars Function
 *******************************************************************************************************
   This function removes all the special characters and replaces with space from well_name and
   eturns compressed well name.

    Parameter notes:
      p_well_name            well_name to be compressed.
-------------------------------------------------------------------------------------------------------*/

    FUNCTION cleanup_Special_Chars (p_value IN VARCHAR2)
      RETURN VARCHAR2;

/******************************************************************************************************
  GET_UWI_SORT Function
 *******************************************************************************************************
   Function to read IPL_UWI_LOCAL and create and return UWI_SORT.
          This function is used for CWS wells in WIM_LOADER

    Parameter notes:
      p_uwi            ipl_uwi_local to be used to get uwi sort
-------------------------------------------------------------------------------------------------------*/

Function GET_UWI_SORT(P_UWI well_Version.ipl_uwi_local%Type)
RETURN VARCHAR2;



/******************************************************************************************************
  IS_LAST_VERSION Function
 *******************************************************************************************************
   Function to check if any of the remaining source versions are ONLY overrides.

    Parameter notes:
      p_uwi            tlm_id to be used to find well sources
      p_source         active source

      returns number   1 if only overrides are left, the overides will be deleted
                       0 if non-override sources remain, no cleanup is done
-------------------------------------------------------------------------------------------------------*/
Function is_last_version(
    p_uwi       well_version.uwi%type
    , p_source  well_version.source%type
) return number;



/******************************************************************************************************
  FORMAT_US_API Function
 *******************************************************************************************************
   Function to re-format a string to comply with the US Well Number (API) syntax..

    Parameter notes:
      p_value          well number to be formatted

      returns  varchar2, up to 14 characters in length
-------------------------------------------------------------------------------------------------------*/
function format_us_api ( p_value  varchar2 )
  return varchar2 ;

/******************************************************************************************************
  CLEANUP NON-PRINTABLE CHARACTERS Function
 *******************************************************************************************************
    Function to REMOVE NON PRINTABLE CHARACTERS FROM A STRING

    Parameter notes:
        p_value STRING TO BE CLEANED UP

    Return:
        varchar2
-------------------------------------------------------------------------------------------------------*/
function cleanup_non_printable_chars(
        p_value in varchar2
) return varchar2;

END;
/


GRANT EXECUTE ON WIM_UTIL TO PPDM WITH GRANT OPTION;
GRANT EXECUTE ON WIM_UTIL TO WIM_LOADER WITH GRANT OPTION;
