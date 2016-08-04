CREATE OR REPLACE PACKAGE PPDM.tlm_find_well AUTHID CURRENT_USER
IS
   -- This package contains functions to find the UWI (TLM_WELL_ID)
   -- that corresponds to a well alias
   --
   -- See package body for change log.
   --
   FUNCTION ready
      RETURN VARCHAR2;

   FUNCTION find_well_by_uwi (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--   PRAGMA RESTRICT_REFERENCES (find_well_by_uwi, WNDS);

   FUNCTION find_well_by_uwi_prior (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--   PRAGMA RESTRICT_REFERENCES (find_well_by_uwi_prior, WNDS);

   FUNCTION find_well_by_api (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--   PRAGMA RESTRICT_REFERENCES (find_well_by_api, WNDS);

   FUNCTION find_well_by_uwi_local (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--   PRAGMA RESTRICT_REFERENCES (find_well_by_uwi_local, WNDS);

   FUNCTION find_well_by_well_name (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--   PRAGMA RESTRICT_REFERENCES (find_well_by_well_name, WNDS);

   FUNCTION find_well_by_plot_name (p_alias IN VARCHAR2)
      RETURN VARCHAR2;

--  PRAGMA RESTRICT_REFERENCES (find_well_by_plot_name, WNDS);
END tlm_find_well; 
/

