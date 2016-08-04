CREATE OR REPLACE PACKAGE BODY PPDM.tlm_find_well
IS
    -- This package contains functions to find the UWI (TLM_WELL_ID)
    -- that corresponds to a well alias
    --
    -- History    By  Description
    -- ========== === =========================================
    -- 2008.02.28 DJH Created initial version
    -- 2008.03.10 DJH Add find by UWI_PRIOR
    --                Search for prior uwi when uwi search fails.
    -- 2008.03.26 DJH Add AUTHID CURRENT_USER
    -- 2008.04.07 DJH add hint to cursor
    -- 2008.06.16 DJH add ready function
    -- 2010.07.22 RM  Allow for INACTIVE aliases too 
    -- 2010.10.28 RM  Converted to call the new WIM FIND_WELL as a temporary fix
    --                for anyone still using the old package
    --
    FUNCTION ready
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Yes';
    END ready;

    FUNCTION find_well_by_uwi (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'TLM_ID');
    END find_well_by_uwi;

    FUNCTION find_well_by_uwi_prior (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'TLM_ID');
    END find_well_by_uwi_prior;

    FUNCTION find_well_by_api (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'WELL_NUM');
    END find_well_by_api;

    FUNCTION find_well_by_uwi_local (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'UWI');
    END find_well_by_uwi_local;

    FUNCTION find_well_by_well_name (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'WELL_NAME');
    END find_well_by_well_name;

    FUNCTION find_well_by_plot_name (
        p_alias   IN   VARCHAR2
    )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN WIM.WIM_SEARCH.FIND_WELL(p_Alias,'PLOT_NAME');
    END find_well_by_plot_name;
END tlm_find_well; 
/
