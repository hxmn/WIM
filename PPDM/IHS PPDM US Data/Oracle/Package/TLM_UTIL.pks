CREATE OR REPLACE PACKAGE PPDM_ADMIN.TLM_util AUTHID CURRENT_USER
IS
--
-- ========== ===============================================================
-- see package body for change log
--
    FUNCTION ready
        RETURN VARCHAR2;

    PROCEDURE drop_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2);

    PROCEDURE drop_db_link (p_db_link IN VARCHAR2);

    PROCEDURE drop_function (p_function_name IN VARCHAR2);

    PROCEDURE drop_index (p_index_name IN VARCHAR2);

    PROCEDURE drop_mview (p_mat_view_name IN VARCHAR2);

    PROCEDURE drop_mview_log (p_table_name IN VARCHAR2);

    PROCEDURE drop_package (p_package_name IN VARCHAR2);

    PROCEDURE drop_package_body (p_package_name IN VARCHAR2);

    PROCEDURE drop_procedure (p_procedure_name IN VARCHAR2);

    PROCEDURE drop_synonym (p_synonym_name IN VARCHAR2);

    PROCEDURE drop_table (p_table_name IN VARCHAR2);

    PROCEDURE drop_trigger (p_trigger_name IN VARCHAR2);

    PROCEDURE drop_type (p_type_name IN VARCHAR2);

    PROCEDURE drop_type_body (p_type_name IN VARCHAR2);

    PROCEDURE drop_view (p_view_name IN VARCHAR2);

    -- drop a group of things
    PROCEDURE drop_foreign_keys (p_table_name IN VARCHAR2);

    PROCEDURE drop_foreign_keys_to (p_table_name IN VARCHAR2);

    PROCEDURE drop_triggers (p_table_name IN VARCHAR2);

    -- drop all of a thing
    PROCEDURE drop_foreign_keys;

    -- manage constraints
    PROCEDURE disable_constraint (p_table_name IN VARCHAR2);

    PROCEDURE disable_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2);

    PROCEDURE disable_constraint;

    PROCEDURE enable_constraint (p_table_name IN VARCHAR2);

    PROCEDURE enable_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2);

    PROCEDURE enable_constraint;

    PROCEDURE enable_foreign_keys (p_table_name IN VARCHAR2);

    PROCEDURE disable_foreign_keys (p_table_name IN VARCHAR2);

    PROCEDURE enable_foreign_keys_to (p_table_name IN VARCHAR2);

    PROCEDURE disable_foreign_keys_to (p_table_name IN VARCHAR2);

    PROCEDURE enable_foreign_keys (p_owner IN VARCHAR2, p_table_name IN VARCHAR2);

    PROCEDURE disable_foreign_keys (p_owner IN VARCHAR2, p_table_name IN VARCHAR2);

    PROCEDURE enable_foreign_keys_to (p_owner IN VARCHAR2, p_table_name IN VARCHAR2);

    PROCEDURE disable_foreign_keys_to (p_owner IN VARCHAR2, p_table_name IN VARCHAR2);
    
    FUNCTION Get_Coord_System_ID(p_Geog_Coord_System_ID varchar2) return varchar2;
    
    FUNCTION PREFIX_ZEROS (p_value  VARCHAR2) return varchar2;
END TLM_util;
/

