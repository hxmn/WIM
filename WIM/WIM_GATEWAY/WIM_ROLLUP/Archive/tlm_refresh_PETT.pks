CREATE OR REPLACE PACKAGE PPDM.tlm_refresh
IS
--
-- This package contains functions and procedures to implement the
-- PPDM 3.7 Talisman Well Master rollup of multiple rows for each well
-- in WELL_VERSION to a single row in WELL and multiple rows for each node
-- in WELL_NODE_VERSION to a single row in WELL_NODE for each node.
--
-- Call the READY function to make sure that this package is compiled and
-- ready to use. For example:
--   select tlm_refresh.ready from dual;
--
-- Call the Set_Active_Ind function to set the active_ind flag to Y for wells 
-- which have at least one active version or to N for wells which only have 
-- inactive versions.
--
-- Call WELL_REFRESH to rollup multiple well versions for a single well into
-- a single well row.
--
-- Call NODE_REFRESH to rollup multiple well node versions for a single node
-- into a single well node row.
--
-- Call GROUP_WELL_REFRESH to rollup all multiple well version rows with the
-- specified source. This is a convenience function that uses WELL_REFRESH
-- for every well which has a well version row from the specified source.
--
-- Call GROUP_NODE_REFRESH to rollup all multiple well node version rows with
-- the specified source. This is a convenience function that uses NODE_REFRESH
-- for every well node which has a well node version row from the specified
-- source.
--
-- Call WELL_AND_NODES to rollup multiple well version for a single well into
-- a single well row and to rollup multiple well node version for the surface
-- and base nodes of the well into single well node rows. This is a convenience
-- function which used WELL_REFRESH and NODE_REFRESH to rollup both the well
-- and its nodes.
--
-- ========== ===============================================================
-- See package body for change log
--
    FUNCTION ready
        RETURN VARCHAR2;

    FUNCTION geog2epsg (geog_coord_system_id IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE well_refresh (input_uwi IN VARCHAR2);

    PROCEDURE node_refresh (input_node_id IN VARCHAR2);

    PROCEDURE group_well_refresh (input_source IN VARCHAR2);

    PROCEDURE group_node_refresh (input_source IN VARCHAR2);

    PROCEDURE well_and_nodes (input_uwi IN VARCHAR2);
    
    FUNCTION Get_Active_Ind (input_uwi IN VARCHAR2)
        RETURN VARCHAR2;
        
    FUNCTION last_chg_date (input_uwi in VARCHAR2)
        RETURN DATE;
        
FUNCTION last_chg_by (input_uwi in VARCHAR2, input_max_date in DATE)
        RETURN VARCHAR2;
END tlm_refresh;
/
