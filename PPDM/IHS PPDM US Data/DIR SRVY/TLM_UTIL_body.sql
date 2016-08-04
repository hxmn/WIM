CREATE OR REPLACE PACKAGE BODY PPDM_ADMIN.TLM_util
IS

/*------------------------------------------------------------------------------------------
 2008.06.09   Doug Henderson,  add materialized view procedures
 2008.10.13   Doug Henderson,  add function, package, procedure, type procedures
 2013.02.20   June Fung       Added new functions Get_Coord_System_ID and PREFIX_ZEROS  
---------------------------------------------------------------------------------------------*/
    no_constraint   EXCEPTION;
    no_db_link      EXCEPTION;
    no_index        EXCEPTION;
    no_mview        EXCEPTION;
    no_mview_log    EXCEPTION;
    no_object       EXCEPTION;
    no_synonym      EXCEPTION;
    no_table        EXCEPTION;
    no_trigger      EXCEPTION;
    PRAGMA EXCEPTION_INIT (no_constraint, -2443);
    PRAGMA EXCEPTION_INIT (no_db_link, -2024);
    PRAGMA EXCEPTION_INIT (no_index, -1418);
    PRAGMA EXCEPTION_INIT (no_mview, -12003);
    PRAGMA EXCEPTION_INIT (no_mview_log, -12002);
    PRAGMA EXCEPTION_INIT (no_object, -4043);
    PRAGMA EXCEPTION_INIT (no_synonym, -1434);
    PRAGMA EXCEPTION_INIT (no_table, -942);
    PRAGMA EXCEPTION_INIT (no_trigger, -4080);

    FUNCTION ready
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Yes';
    END ready;

    PROCEDURE drop_db_link (p_db_link IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop database link ' || p_db_link;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_db_link
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_db_link;

    PROCEDURE drop_synonym (p_synonym_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop synonym ' || p_synonym_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_synonym
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_synonym;

    PROCEDURE drop_table (p_table_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop table ' || p_table_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_table
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_table;

    PROCEDURE drop_index (p_index_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop index ' || p_index_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_index
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_index;

    PROCEDURE drop_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'alter table ' || p_table_name || ' drop constraint ' || p_constraint_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_table
        THEN
            NULL;
        WHEN no_constraint
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_constraint;

    PROCEDURE drop_view (p_view_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop view ' || p_view_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_table
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_view;

    PROCEDURE drop_mview (p_mat_view_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop materialized view ' || p_mat_view_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_mview
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_mview;

    PROCEDURE drop_mview_log (p_table_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop materialized view log on ' || p_table_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_table
        THEN
            NULL;
        WHEN no_mview_log
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_mview_log;

    PROCEDURE drop_trigger (p_trigger_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop trigger ' || p_trigger_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_trigger
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_trigger;

    PROCEDURE drop_object (p_object_type IN VARCHAR2, p_type_name IN VARCHAR2)
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    := 'drop ' || p_object_type || ' ' || p_type_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    EXCEPTION
        WHEN no_object
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END drop_object;

    PROCEDURE drop_type (p_type_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('type', p_type_name);
    END drop_type;

    PROCEDURE drop_type_body (p_type_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('type body', p_type_name);
    END drop_type_body;

    PROCEDURE drop_function (p_function_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('function', p_function_name);
    END drop_function;

    PROCEDURE drop_procedure (p_procedure_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('procedure', p_procedure_name);
    END drop_procedure;

    PROCEDURE drop_package (p_package_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('package', p_package_name);
    END drop_package;

    PROCEDURE drop_package_body (p_package_name IN VARCHAR2)
    IS
    BEGIN
        drop_object ('package body', p_package_name);
    END drop_package_body;

/*
drop a group of things
*/
    PROCEDURE drop_foreign_keys (p_table_name IN VARCHAR2)
    IS
        CURSOR cur1
        IS
            SELECT table_name
                 , constraint_name
            FROM   user_constraints
            WHERE  table_name = UPPER (p_table_name) AND constraint_type = 'R';
    BEGIN
        FOR row1 IN cur1
        LOOP
            drop_constraint (row1.table_name, row1.constraint_name);
        END LOOP;
    END drop_foreign_keys;

    PROCEDURE drop_foreign_keys_to (p_table_name IN VARCHAR2)
    IS
        CURSOR cur1
        IS
            SELECT   *
            FROM     user_constraints
            WHERE    constraint_type = 'R'
            AND      (r_owner, r_constraint_name) IN (
                           SELECT owner
                                , constraint_name
                           FROM   user_constraints
                           WHERE  constraint_type IN ('U', 'P')
                           AND    table_name = UPPER (p_table_name))
            ORDER BY owner, constraint_name;
    BEGIN
        FOR row1 IN cur1
        LOOP
            drop_constraint (row1.owner || '.' || row1.table_name, row1.constraint_name);
        END LOOP;
    END drop_foreign_keys_to;

    PROCEDURE drop_triggers (p_table_name IN VARCHAR2)
    IS
        CURSOR cur1
        IS
            SELECT trigger_name
            FROM   user_triggers
            WHERE  table_name = UPPER (p_table_name);
    BEGIN
        FOR row1 IN cur1
        LOOP
            drop_trigger (row1.trigger_name);
        END LOOP;
    END drop_triggers;

/*
drop all of a thing
*/
    PROCEDURE drop_foreign_keys
    IS
        CURSOR cur1
        IS
            SELECT table_name
                 , constraint_name
            FROM   user_constraints
            WHERE  constraint_type = 'R';
    BEGIN
        FOR row1 IN cur1
        LOOP
            drop_constraint (row1.table_name, row1.constraint_name);
        END LOOP;
    END drop_foreign_keys;

/*
manage constraints
*/
    PROCEDURE alter_constraint (
        p_action            IN   VARCHAR2
      , p_table_name        IN   VARCHAR2
      , p_constraint_name   IN   VARCHAR2
    )
    IS
        l_stmt   VARCHAR2 (256);
    BEGIN
        l_stmt    :=
            'alter table ' || p_table_name || ' ' || p_action || ' constraint '
            || p_constraint_name;
        DBMS_OUTPUT.put_line (l_stmt);

        EXECUTE IMMEDIATE l_stmt;
    END alter_constraint;

    PROCEDURE alter_constraint (p_action IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
        CURSOR cur1
        IS
            SELECT table_name
                 , constraint_name
            FROM   user_constraints
            WHERE  table_name = UPPER (p_table_name);
    BEGIN
        FOR row1 IN cur1
        LOOP
            alter_constraint (p_action, row1.table_name, row1.constraint_name);
        END LOOP;
    END alter_constraint;

    PROCEDURE alter_constraint (p_action IN VARCHAR2)
    IS
        CURSOR cur1
        IS
            SELECT table_name
                 , constraint_name
            FROM   user_constraints;
    BEGIN
        FOR row1 IN cur1
        LOOP
            alter_constraint (p_action, row1.table_name, row1.constraint_name);
        END LOOP;
    END alter_constraint;

    PROCEDURE disable_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2)
    IS
    BEGIN
        alter_constraint ('disable', p_table_name, p_constraint_name);
    END disable_constraint;

    PROCEDURE disable_constraint (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_constraint ('disable', p_table_name);
    END disable_constraint;

    PROCEDURE disable_constraint
    IS
    BEGIN
        alter_constraint ('disable');
    END disable_constraint;

    PROCEDURE enable_constraint (p_table_name IN VARCHAR2, p_constraint_name IN VARCHAR2)
    IS
    BEGIN
        alter_constraint ('enable', p_table_name, p_constraint_name);
    END enable_constraint;

    PROCEDURE enable_constraint (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_constraint ('enable', p_table_name);
    END enable_constraint;

    PROCEDURE enable_constraint
    IS
    BEGIN
        alter_constraint ('enable');
    END enable_constraint;

    PROCEDURE alter_foreign_keys (
        p_action       IN   VARCHAR2
      , p_owner        IN   VARCHAR2
      , p_table_name   IN   VARCHAR2
    )
    IS
        CURSOR cur1
        IS
            SELECT owner
                 , table_name
                 , constraint_name
            FROM   user_constraints
            WHERE  owner = UPPER (p_owner)
            AND    table_name = UPPER (p_table_name)
            AND    constraint_type = 'R';
    BEGIN
        FOR row1 IN cur1
        LOOP
            alter_constraint (p_action, row1.owner || '.' || row1.table_name
                            , row1.constraint_name);
        END LOOP;
    END alter_foreign_keys;

    PROCEDURE alter_foreign_keys (p_action IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys (p_action, USER, p_table_name);
    END alter_foreign_keys;

    PROCEDURE enable_foreign_keys (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys ('ENABLE', p_table_name);
    END enable_foreign_keys;

    PROCEDURE disable_foreign_keys (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys ('DISABLE', p_table_name);
    END disable_foreign_keys;

    PROCEDURE enable_foreign_keys (p_owner IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys ('ENABLE', p_owner, p_table_name);
    END enable_foreign_keys;

    PROCEDURE disable_foreign_keys (p_owner IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys ('DISABLE', p_owner, p_table_name);
    END disable_foreign_keys;

    PROCEDURE alter_foreign_keys_to (
        p_action       IN   VARCHAR2
      , p_owner        IN   VARCHAR2
      , p_table_name   IN   VARCHAR2
    )
    IS
        CURSOR cur1
        IS
            SELECT   owner
                   , table_name
                   , constraint_name
            FROM     user_constraints
            WHERE    constraint_type = 'R'
            AND      (r_owner, r_constraint_name) IN (
                         SELECT owner
                              , constraint_name
                         FROM   user_constraints
                         WHERE  constraint_type IN ('U', 'P')
                         AND    owner = UPPER (p_owner)
                         AND    table_name = UPPER (p_table_name))
            ORDER BY owner, constraint_name;
    BEGIN
        FOR row1 IN cur1
        LOOP
            alter_constraint (p_action, row1.owner || '.' || row1.table_name
                            , row1.constraint_name);
        END LOOP;
    END alter_foreign_keys_to;

    PROCEDURE alter_foreign_keys_to (p_action IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys_to (p_action, USER, p_table_name);
    END alter_foreign_keys_to;

    PROCEDURE enable_foreign_keys_to (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys_to ('ENABLE', p_table_name);
    END enable_foreign_keys_to;

    PROCEDURE disable_foreign_keys_to (p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys_to ('DISABLE', p_table_name);
    END disable_foreign_keys_to;

    PROCEDURE enable_foreign_keys_to (p_owner IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys_to ('ENABLE', p_owner, p_table_name);
    END enable_foreign_keys_to;

    PROCEDURE disable_foreign_keys_to (p_owner IN VARCHAR2, p_table_name IN VARCHAR2)
    IS
    BEGIN
        alter_foreign_keys_to ('DISABLE', p_owner, p_table_name);
    END disable_foreign_keys_to;

-- 
--------------------------------------------------------------------------------------------   
-- JFUNG - Feb. 20, 2013
-- This function is to convert Geog_Coord_system_id from alpha (eg, NAD27) to Numerical (eg. 4267) 
--
    FUNCTION Get_Coord_System_ID(p_Geog_Coord_System_ID varchar2)
    RETURN varchar2
    IS

        V_GEOG_COORD_SYS_ID  ppdm.cs_coordinate_system.coord_system_id%type;

    BEGIN

      if p_geog_coord_system_id is not null then
           SELECT coord_system_id into V_GEOG_COORD_SYS_ID 
             FROM
                (SELECT coord_system_id, ROW_NUMBER() over (order by coord_system_id) as row_number
                   FROM PPDM.CS_COORDINATE_SYSTEM
                  WHERE ACTIVE_IND = 'Y'
                    AND ( COORD_SYSTEM_NAME = replace(p_Geog_Coord_System_ID,' ', '')
                    OR COORD_SYSTEM_ID = replace(p_Geog_Coord_System_ID,' ', ''))
                   AND upper(coorD_system_name) != 'UNDEFINED'     
                    order by coord_system_id)
            WHERE row_number =1;
  
            IF V_GEOG_COORD_SYS_ID is NULL THEN
               V_GEOG_COORD_SYS_ID := '9999';
            END IF;
      end if;    
    
      RETURN V_GEOG_COORD_SYS_ID;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       RETURN '9999';
       
      WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20002,'An error was encountered in ppdm_admin.tlm_util.Get_Coord_System_ID function '  || SQLERRM);

    END;

-------------------------------------------------------------------------------------------------------------
-- JFUNG - Feb. 20, 2013
-- This function is to prefix the survey ID with '00' because IHS US PPDM's srvy_id is in '1' fomrat and 
-- IHS CDN and TLM_* srvy_id is in '001' format.
--
    FUNCTION PREFIX_ZEROS (p_value VARCHAR2)
    Return VARCHAR2

    Is

        v_result VARCHAR2(20);
        v_Msg    VARCHAR2(100);

    BEGIN

        IF p_value is not NULL THEN
            IF length(p_value) = 1 THEN
                v_result :=  '00'||p_value;
                RETURN v_result;
            ELSIF length(p_value) = 2 THEN
                v_result := '0' || p_value;
                RETURN v_result;
            ELSE
                -- length(p_value) >= 3, return as is
                v_result := p_value; 
                return v_result;
            END IF;
        END IF;

        Exception
          WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20002,
                                  'An error was encountered in Prefixing Zeros function - '
                                  || SQLCODE
                                  || ' - ERROR - '
                                  || SQLERRM );
    END;
    
    
BEGIN
    NULL;
--DBMS_OUTPUT.ENABLE (200000);
END TLM_util;
/
GRANT EXECUTE on TLM_util to WIM_LOADER;
grant select on PPDM.CS_COORDINATE_SYSTEM to wim_loader;
GRANT EXECUTE on TLM_util to PPDM with grant option;
GRANT EXECUTE on TLM_util to SPATIAL;