/*-------------------------------------------------------------------------
    Installer:  well_spatial
    version:    0.0.0.1
    Detail:     Creates the required tables
    Created:    May 23, 2014 - kxedward
    Updated:
    History:
                0.0.0.1 - Initial code
   ---------------------------------------------------------------------------*/
--create table ppdm.r_xref_well_symbol (
--    status       		varchar2(60)
--	, active_ind		varchar2(1) default 'Y'
--    , tlm_symbol        varchar2(60)
--    , remark            varchar2(4000)
--	, row_created_date	date
--    , row_created_by    varchar2(50) default user
--    , row_changed_date  date
--    , row_changed_by    varchar2(50) default user
--)
--/

--create index r_xref_well_symbol_tlm_symbol on ppdm.r_xref_well_symbol (tlm_symbol)
--/

grant select on ppdm.well_node to spatial 
/

grant select on ppdm.cs_coordinate_system to spatial
/

grant select on ppdm.well to spatial
/

grant select on ppdm.r_well_status to spatial
/ 

grant select on ppdm.business_associate to spatial
/ 

grant select on ppdm.r_county to spatial
/

grant select on ppdm.r_country to spatial
/

grant select on ppdm.well_version to spatial
/

grant select on ppdm.well_license to spatial
/

grant select on ppdm.r_xref_well_symbol to spatial
/