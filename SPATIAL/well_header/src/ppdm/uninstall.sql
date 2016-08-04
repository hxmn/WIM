/*-------------------------------------------------------------------------
    Installer:  well_spatial
    version:    0.0.0.1
    Detail:     Creates the required tables
    Created:    May 23, 2014 - kxedward
    Updated:
    History:
                0.0.0.1 - Initial code
   ---------------------------------------------------------------------------*/
--
-- DO NOT REMOVE, OTHER SPATIAL OBJECTS REQUIRE THESE GRANTS
--

--drop table ppdm.r_xref_well_symbol
--/

--revoke select on ppdm.well_node from wim 
--/

--revoke select on ppdm.cs_coordinate_system from spatial 
--/

--revoke select on ppdm.well from spatial
--/

--revoke select on ppdm.r_well_status from spatial
--/ 

--revoke select on ppdm.business_associate from spatial
--/ 

--revoke select on ppdm.r_county from spatial
--/

--revoke select on ppdm.r_country from spatial
--/

--revoke select on ppdm.well_version from spatial
--/

--revoke select on ppdm.well_license from spatial
--/

--revoke select on ppdm.r_xref_well_symbol from spatial
--/