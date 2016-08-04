/*-------------------------------------------------------------------------
    Installer:  well_spatial_mv (ADD CWS columns)
    version:    0.0.0.1
    Detail:     spatial_appl schema install
    Created:    May 23, 2014 - kxedward
    Updated:
    History:
                0.0.0.1 - Initial code
---------------------------------------------------------------------------*/
create or replace synonym spatial_appl.well_header_mv for spatial.well_header_mv
/