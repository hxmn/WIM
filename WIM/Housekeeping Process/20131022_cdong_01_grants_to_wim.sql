-- Grant select access to table used in view WIM.WIM_DM_MISSING_WELLS_VW
-- run as PPDM_ADMIN user

-- these may or may not be necessary, depending on the environment
-- check if WIM schema already has SELECT WITH GRANT on each of the tables, before executing
GRANT SELECT ON PPDM.WELL TO WIM WITH GRANT OPTION;
GRANT SELECT ON PPDM.WELL_VERSION TO WIM WITH GRANT OPTION;
GRANT SELECT ON PPDM.WELL_ALIAS TO WIM WITH GRANT OPTION;

-- grant privilege to create database link (this was not necessary in PETTEST or PETDEV)
GRANT CREATE DATABASE LINK TO WIM;






