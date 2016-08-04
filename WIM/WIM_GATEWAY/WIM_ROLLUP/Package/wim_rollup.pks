create or replace PACKAGE wim.WIM_Rollup
IS
--
-- This package contains functions and procedures to implement the
-- Talisman Well Identity Master rollup of multiple rows for each well
-- in WELL_VERSION to a single row in WELL and multiple rows for each node
-- in WELL_NODE_VERSION to a single row in WELL_NODE for each node.
--
--
-- Call Version to return the package version number
--
-- Call WELL_Rollup to rollup multiple well versions for a single well into
-- a single well row.
--
-- Call SOURCE_Rollup to rollup all multiple well version rows for the
-- specified source. This is a convenience function that uses WELL_ROLLUP
-- procesdure for every well which has a well version row from the specified
-- source.
--
-- ========== ===============================================================
-- See package body for change log
--
    FUNCTION Version RETURN VARCHAR2;
    PROCEDURE Well_Rollup (input_uwi IN VARCHAR2); 
    PROCEDURE Source_Rollup (input_source IN VARCHAR2);   
END WIM_Rollup;