CREATE OR REPLACE PACKAGE TALISMAN37.wm_validator AUTHID CURRENT_USER
IS
    --
    -- See package body for change log.
    --
    FUNCTION ready
        RETURN VARCHAR2;

    PROCEDURE set_max_error_count (
        p_max_error_count   IN   NUMBER
    );

    FUNCTION validate_well_version (
        a_row   IN OUT   well_version%ROWTYPE
      , a_msg   IN       VARCHAR2 DEFAULT NULL
    )
        RETURN NUMBER;

    FUNCTION validate_well_node_version (
        a_row   IN OUT   well_node_version%ROWTYPE
      , a_msg   IN       VARCHAR2 DEFAULT NULL
    )
        RETURN NUMBER;

    PROCEDURE test_well_version;

    PROCEDURE test_well_version (
        p_source   IN   VARCHAR2
    );

    PROCEDURE test_well_version (
        p_source   IN   VARCHAR2
      , p_uwi      IN   VARCHAR2
    );

    PROCEDURE test_well_node_version;

    PROCEDURE test_well_node_version (
        p_source   IN   VARCHAR2
    );

    PROCEDURE test_well_node_version (
        p_source    IN   VARCHAR2
      , p_node_id   IN   VARCHAR2
    );
END wm_validator;
/
