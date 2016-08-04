CREATE OR REPLACE PACKAGE BODY TALISMAN37.wm_validator
IS
    -- validate well master well version and well node version rows
    --
    -- In order to simply the rollup of well node versions from different well
    -- versions, the node ids are calculated from the uwi by appending a 0 to
    -- the uwi to form the node_id of the base node, and appending a 1 to from
    -- the uwi to form the node_id of the surface node.
    -- this ensures that the node_ids for all node versions are the same across
    -- all sources.
    -- While this scheme should not be used to retrieve data, it is used by the
    -- node rollup procedures (in the TLM_REFRESH package) to simplify the
    -- the merging of node data.
    --
    -- Change log
    -- ========== ===============================================================
    -- 2008.06.18 Doug Henderson, Talisman Energy Inc.
    --            add ready function
    -- 2008.07.23 Doug Henderson, Talisman Energy Inc.
    --            update ready function
    -- 2008.07.24 Doug Henderson, Talisman Energy Inc.
    --            add message parameter to validation functions
    --            document the validation checks
    -- 2008.11.17 Doug Henderson, Talisman Energy Inc.
    --            add some more comments
    --
    max_error_count   BINARY_INTEGER := 100;

    FUNCTION ready
        RETURN VARCHAR2
    IS
        is_ready   VARCHAR2 (20);
    BEGIN
        SELECT tlm_proc_log.ready
          INTO is_ready
          FROM DUAL;
        RETURN 'Yes';
    END ready;

    PROCEDURE set_max_error_count (
        p_max_error_count   IN   NUMBER
    )
    IS
    BEGIN
        max_error_count := p_max_error_count;
    END set_max_error_count;

    FUNCTION validate_well_version (
        a_row   IN OUT   well_version%ROWTYPE
      , a_msg   IN       VARCHAR2
    )
        RETURN NUMBER
    IS
        -- validate a well_version row
        -- 1. base node and surface node must be different
        -- 2. base node is required when bottom hole coordinates are present
        -- 3. surface node is required when surface coordinates are present
        --
        error_count   BINARY_INTEGER := 0;

        PROCEDURE well_error (
            p_msg   IN   VARCHAR2
        )
        IS
            l_msg   VARCHAR2 (200);
        BEGIN
            IF a_msg IS NOT NULL
            THEN
                l_msg := '[' || a_msg || '] ';
            ELSE
                l_msg := '';
            END IF;

            tlm_proc_log.error ('validate_well_version(' || a_row.uwi || ',' || a_row.SOURCE || '): ' || l_msg || p_msg);
            error_count := error_count + 1;
        END well_error;
    BEGIN
        IF     a_row.base_node_id IS NOT NULL
           AND a_row.surface_node_id IS NOT NULL
           AND a_row.base_node_id = a_row.surface_node_id
        THEN
            well_error ('same node for surface and base');
        END IF;

        IF     a_row.base_node_id IS NULL
           AND (   a_row.bottom_hole_latitude IS NOT NULL
                OR a_row.bottom_hole_longitude IS NOT NULL)
        THEN
            well_error ('bottom hole coordinates but no base node id');
        END IF;

        IF     a_row.surface_node_id IS NULL
           AND (   a_row.surface_latitude IS NOT NULL
                OR a_row.surface_longitude IS NOT NULL)
        THEN
            well_error ('surface coordinates but no surface node id');
        END IF;

        RETURN error_count;
    END validate_well_version;

    FUNCTION validate_well_node_version (
        a_row   IN OUT   well_node_version%ROWTYPE
      , a_msg   IN       VARCHAR2
    )
        RETURN NUMBER
    IS
        -- validate a well_node_version row
        -- 1. node position must be provided
        -- 2. node position and node id must be consistent
        -- 3. ipl_uwi must be provided
        -- 4. ipl_uwi and node_id must be consistent
        --
        calc_uwi      VARCHAR2 (20);
        calc_bn       VARCHAR2 (1);
        error_count   BINARY_INTEGER := 0;

        PROCEDURE node_error (
            p_msg   IN   VARCHAR2
        )
        IS
            l_msg   VARCHAR2 (200);
        BEGIN
            IF a_msg IS NOT NULL
            THEN
                l_msg := '[' || a_msg || '] ';
            ELSE
                l_msg := '';
            END IF;

            tlm_proc_log.error (   'validate_well_node_version('
                                || a_row.node_id
                                || ','
                                || a_row.SOURCE
                                || ','
                                || TO_CHAR (a_row.node_obs_no)
                                || '): '
                                || l_msg
                                || p_msg
                               );
            error_count := error_count + 1;
        END node_error;
    BEGIN
        calc_uwi := SUBSTR (a_row.node_id, 1, LENGTH (a_row.node_id) - 1);
        calc_bn := SUBSTR (a_row.node_id, LENGTH (a_row.node_id), 1);

        IF a_row.node_position IS NOT NULL
        THEN
            IF SUBSTR (a_row.node_position, 1, 1) != SUBSTR ('BS', TO_NUMBER (calc_bn) + 1, 1)
            THEN
                node_error ('node_id and node_position mismatch');
            END IF;
        ELSE
            node_error ('node_position is null');
        END IF;

        IF a_row.ipl_uwi IS NOT NULL
        THEN
            IF calc_uwi != a_row.ipl_uwi
            THEN
                node_error ('node_id and ipl_uwi mismatch');
            END IF;
        ELSE
            node_error ('ipl_uwi is null');
        END IF;

        RETURN error_count;
    END validate_well_node_version;

    PROCEDURE test_well_version
    IS
        -- validate all well_version rows.
        --
        error_count      NUMBER;
        total_errors     NUMBER := 0;
        total_versions   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_version;
    BEGIN
        FOR wv IN cur1
        LOOP
            total_versions := total_versions + 1;
            error_count := validate_well_version (wv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;

        tlm_proc_log.info (   'test_well_version: validated '
                           || TO_CHAR (total_versions)
                           || ' well versions with '
                           || TO_CHAR (total_errors)
                           || ' errors.'
                          );
    END test_well_version;

    PROCEDURE test_well_version (
        p_source   IN   VARCHAR2
    )
    IS
        -- validate all well_version rows with a specified source.
        --
        error_count      NUMBER;
        total_errors     NUMBER := 0;
        total_versions   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_version
             WHERE SOURCE = p_source;
    BEGIN
        FOR wv IN cur1
        LOOP
            total_versions := total_versions + 1;
            error_count := validate_well_version (wv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;

        tlm_proc_log.info (   'test_well_version: validated '
                           || TO_CHAR (total_versions)
                           || ' well versions for "'
                           || p_source
                           || '" with '
                           || TO_CHAR (total_errors)
                           || ' errors.'
                          );
    END test_well_version;

    PROCEDURE test_well_version (
        p_source   IN   VARCHAR2
      , p_uwi      IN   VARCHAR2
    )
    IS
        -- validate all well version row given source and uwi.
        -- this should be a single row, due to primary key.
        --
        error_count    NUMBER;
        total_errors   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_version
             WHERE SOURCE = p_source
               AND uwi = p_uwi;
    BEGIN
        FOR wv IN cur1
        LOOP
            error_count := validate_well_version (wv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;
    END test_well_version;

    PROCEDURE test_well_node_version
    IS
        -- validate all well node version rows.
        --
        error_count    NUMBER;
        total_errors   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_node_version;
    BEGIN
        FOR wnv IN cur1
        LOOP
            error_count := validate_well_node_version (wnv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_node_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;
    END test_well_node_version;

    PROCEDURE test_well_node_version (
        p_source   IN   VARCHAR2
    )
    IS
        -- validate all well node version rows for a source
        --
        error_count    NUMBER;
        total_errors   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_node_version
             WHERE SOURCE = p_source;
    BEGIN
        FOR wnv IN cur1
        LOOP
            error_count := validate_well_node_version (wnv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_node_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;
    END test_well_node_version;

    PROCEDURE test_well_node_version (
        p_source    IN   VARCHAR2
      , p_node_id   IN   VARCHAR2
    )
    IS
        -- validate all single well node version rows for a source and uwi.
        --
        error_count    NUMBER;
        total_errors   NUMBER := 0;

        CURSOR cur1
        IS
            SELECT *
              FROM well_node_version
             WHERE SOURCE = p_source
               AND node_id = p_node_id;
    BEGIN
        FOR wnv IN cur1
        LOOP
            error_count := validate_well_node_version (wnv);
            total_errors := total_errors + error_count;

            IF total_errors >= max_error_count
            THEN
                tlm_proc_log.warning ('test_well_node_version: too many errors.');
                EXIT;
            END IF;
        END LOOP;
    END test_well_node_version;
END wm_validator;
/
