/*-------------------------------------------------------------------------
    Installer:  Well Spatial
    Detail:     Installs required objects
    Created:    08/01/2014 - kxedward
    Updated:
    History:    0.0.0.1 - Initial code
---------------------------------------------------------------------------*/
set define on
set verify off
set serveroutput on

define db_conn = &1
accept ppdm_admin_schema_password char prompt 'Enter password for ppdm_admin@&db_conn schema: ' hide
accept ppdm_schema_password char prompt 'Enter password for ppdm@&db_conn schema: ' hide
accept spatial_schema_password char prompt 'Enter password for spatial@&db_conn schema: ' hide
accept spatial_appl_schema_password char prompt 'Enter password for spatial_appl@&db_conn schema: ' hide

connect spatial/&spatial_schema_password@&db_conn
@@../src/spatial/uninstall.sql

connect spatial_appl/&spatial_appl_schema_password@&db_conn
@@../src/spatial_appl/uninstall.sql

connect ppdm_admin/&ppdm_admin_schema_password@&db_conn
@@../src/ppdm_admin/uninstall.sql

connect ppdm/&ppdm_schema_password@&db_conn
@@../src/ppdm/uninstall.sql