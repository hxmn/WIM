/*-------------------------------------------------------------------------
    Installer:  well_header
    version:    0.0.0.1
    Detail:     Removes the required permissions
    Created:    May 23, 2014 - kxedward
    Updated:
    Hisfromry:
                0.0.0.1 - Initial code
---------------------------------------------------------------------------*/
revoke select on spatial.well_header_mv from ppdm_admin
/

revoke select on spatial.well_header_mv from r_spatial
/

drop materialized view spatial.well_header_mv
/

drop table spatial.well_header
/

drop table spatial.well_header_changes
/

drop database link cws
/

drop database link edxp
/

exec dbms_job.remove(189)