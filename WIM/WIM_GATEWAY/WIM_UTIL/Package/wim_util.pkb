create or replace PACKAGE BODY     wim_util
IS

-- HISTORY:
-- 1.0.0                    Initial Creation
-- 1.0.1        VRajpoot    Added another replace for apostrophe char.
--                          Added replace for '(000', '(00', '(0'
-- 1.0.2        VRajpoot    Added a new function remove spacial chars from well_name
--                          Added a new function to get uwi_Sort. It is specially used by wim_loader for CWS wells.
--                          This is part of WIM_GATEWAY 2.0.0 version
-- 1.0.3        KXEDWARD    Added a new function is_last_version to test if the lst version of a well is an override
-- 1.0.4        cdong       Added function 'format_us_api', which returns a re-formatted string that complies with the US Well Number (API) syntax.
--                              see http://info.drillinginfo.com/api-number-dead-long-live-us-well-number/ for background
--                          QC1741
-- 1.0.5        KXEDWARD    Added function 'cleanup_non_printable_chars', which returns a varchar2 that has been cleaned of non-printable characters

   FUNCTION uom_conversion (
      p_uom_from   VARCHAR2,
      p_uom_to     VARCHAR2,
      p_value      NUMBER
   )
      RETURN NUMBER
   IS
      v_result     NUMBER;
      v_uom_from   VARCHAR2 (20);
   BEGIN
      v_uom_from := NVL (p_uom_from, 'M');

      IF p_value IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF p_uom_to = v_uom_from
      THEN
         v_result := p_value;
      ELSE
         SELECT   p_value * factor_numerator / factor_denominator
             INTO v_result
             FROM ppdm_unit_conversion
            WHERE UPPER (from_uom_id) = UPPER (v_uom_from)
              AND UPPER (to_uom_id) = UPPER (p_uom_to)
              AND effective_date <= SYSDATE
              AND active_ind = 'Y'
              AND ROWNUM = 1
         ORDER BY effective_date DESC;

         IF v_result IS NULL
         THEN
            raise_application_error
               (-20001,
                   v_uom_from
                || ' -> '
                || p_uom_to
                || ' conversion rule is missing in PPDM.PPDM_UNIT_CONVERSION table.'
               );
         END IF;
      END IF;

      RETURN ROUND (v_result, 5);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error
            (-20002,
                v_uom_from
             || ' -> '
             || p_uom_to
             || ' conversion rule is missing in PPDM.PPDM_UNIT_CONVERSION table.'
            );
   END;

   FUNCTION get_sys_number_parameter (p_param_name VARCHAR2)
      RETURN NUMBER
   IS
      v_param_value   NUMBER;
   BEGIN
      SELECT numeric_value
        INTO v_param_value
        FROM sys_parameter
       WHERE parameter_nm = p_param_name;

      RETURN v_param_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_sys_number_parameter;

   FUNCTION get_sys_string_parameter (p_param_name VARCHAR2)
      RETURN VARCHAR2
   IS
      v_param_value   VARCHAR2 (4000);
   BEGIN
      SELECT text_value
        INTO v_param_value
        FROM sys_parameter
       WHERE parameter_nm = p_param_name;

      RETURN v_param_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_sys_string_parameter;

   PROCEDURE cleanup_stg_tables
   IS
      v_days_interval   NUMBER;
   BEGIN
      v_days_interval := get_sys_number_parameter ('STG_CLEANUP_INERVAL');

      IF v_days_interval IS NULL
      THEN
         raise_application_error
            (-20000,
             'Please specify STG_CLEANUP_INERVAL parameter in SYS_PARAMETER table.',
             TRUE
            );
      END IF;

                       
      DELETE FROM wim_stg_well_license
            WHERE wim_stg_id IN (
                     SELECT wim_stg_id
                       FROM wim_stg_request
                      WHERE row_created_date < (SYSDATE - v_days_interval)
                        AND status_cd IN ('C'));

          DELETE FROM wim_stg_well_node_version
            WHERE wim_stg_id IN (
                     SELECT wim_stg_id
                       FROM wim_stg_request
                      WHERE row_created_date < (SYSDATE - v_days_interval)
                        AND status_cd IN ('C'));

    
      DELETE FROM wim_stg_well_node_m_b
            WHERE wim_stg_id IN (
                     SELECT wim_stg_id
                       FROM wim_stg_request
                      WHERE row_created_date < (SYSDATE - v_days_interval)
                        AND status_cd IN ('C'));


                         
      DELETE FROM wim_stg_well_status
            WHERE wim_stg_id IN (
                     SELECT wim_stg_id
                       FROM wim_stg_request
                      WHERE row_created_date < (SYSDATE - v_days_interval)
                        AND status_cd IN ('C'));
     DELETE FROM wim_stg_well_version
            WHERE wim_stg_id IN (
                     SELECT wim_stg_id
                       FROM wim_stg_request
                      WHERE row_created_date < (SYSDATE - v_days_interval)
                        AND status_cd IN ('C'));
     DELETE FROM wim_stg_request
            WHERE row_created_date < (SYSDATE - v_days_interval)
              AND status_cd IN ('C');



   END cleanup_stg_tables;

   PROCEDURE cleanup_audit_log
   IS
      v_days_interval   NUMBER;
   BEGIN
      v_days_interval := get_sys_number_parameter ('AUDIT_CLEANUP_INTERVAL');

      IF v_days_interval IS NULL
      THEN
         raise_application_error
            (-20000,
             'Please specify AUDIT_CLEANUP_INTERVAL parameter in SYS_PARAMETER table.',
             TRUE
            );
      END IF;

       
      DELETE FROM wim_audit_log
            WHERE row_created_date < (SYSDATE - v_days_interval);
   END cleanup_audit_log;

   FUNCTION compress_well_name (p_well_name IN VARCHAR2)
      RETURN VARCHAR2
      deterministic 
   IS
      well_compressed_name   VARCHAR2 (256) := p_well_name;
   BEGIN
      well_compressed_name := REPLACE (well_compressed_name, ' 000', '');
      well_compressed_name := REPLACE (well_compressed_name, ' 00', '');
      well_compressed_name := REPLACE (well_compressed_name, ' 0', '');
      well_compressed_name := REPLACE (well_compressed_name, '-000', '');
      well_compressed_name := REPLACE (well_compressed_name, '-00', '');
      well_compressed_name := REPLACE (well_compressed_name, '-0', '');
      well_compressed_name := REPLACE (well_compressed_name, '(000', '');
      well_compressed_name := REPLACE (well_compressed_name, '(00', '');
      well_compressed_name := REPLACE (well_compressed_name, '(0', '');
      well_compressed_name := REPLACE (well_compressed_name, ' - ', '');
      well_compressed_name := REPLACE (well_compressed_name, '-', '');
      well_compressed_name := REPLACE (well_compressed_name, '_', '');
      well_compressed_name := REPLACE (well_compressed_name, '/000', '');
      well_compressed_name := REPLACE (well_compressed_name, '/00', '');
      well_compressed_name := REPLACE (well_compressed_name, '/0', '');
      well_compressed_name := REPLACE (well_compressed_name, ' #000', '');
      well_compressed_name := REPLACE (well_compressed_name, ' #00', '');
      well_compressed_name := REPLACE (well_compressed_name, ' #0', '');
      well_compressed_name := REPLACE (well_compressed_name, ' #', '');
      well_compressed_name := REPLACE (well_compressed_name, ' ', '');
      well_compressed_name := REPLACE (well_compressed_name, '/', '');
      well_compressed_name := REPLACE (well_compressed_name, '#', '');
      well_compressed_name := REPLACE (well_compressed_name, '(', '');
      well_compressed_name := REPLACE (well_compressed_name, ')', '');
      well_compressed_name := REPLACE (well_compressed_name, '.', '');
      well_compressed_name := REPLACE (well_compressed_name, '?', '');
      well_compressed_name := REPLACE (well_compressed_name, '!', '');
      well_compressed_name := REPLACE (well_compressed_name, '&', '');
      well_compressed_name := REPLACE (well_compressed_name, ':', '');
      well_compressed_name := REPLACE (well_compressed_name, ',', '');
      well_compressed_name := REPLACE (well_compressed_name, ';', '');
      well_compressed_name := REPLACE (well_compressed_name, '+', '');
      well_compressed_name := REPLACE (well_compressed_name, '"', '');
      well_compressed_name := REPLACE (well_compressed_name, '~', '');
      well_compressed_name := REPLACE (well_compressed_name, '`', '');
      well_compressed_name := REPLACE (well_compressed_name, '@', '');
      well_compressed_name := REPLACE (well_compressed_name, '$', '');
      well_compressed_name := REPLACE (well_compressed_name, '%', '');
      well_compressed_name := REPLACE (well_compressed_name, '^', '');
      well_compressed_name := REPLACE (well_compressed_name, '*', '');
      well_compressed_name := REPLACE (well_compressed_name, ':=', '');
      well_compressed_name := REPLACE (well_compressed_name, '{', '');
      well_compressed_name := REPLACE (well_compressed_name, '}', '');
      well_compressed_name := REPLACE (well_compressed_name, '[', '');
      well_compressed_name := REPLACE (well_compressed_name, ']', '');
      well_compressed_name := REPLACE (well_compressed_name, '\', '');
      well_compressed_name := REPLACE (well_compressed_name, '<', '');
      well_compressed_name := REPLACE (well_compressed_name, '>', '');
      well_compressed_name := REPLACE (well_compressed_name, CHR(39), ''); --apostrophe 
      well_compressed_name := UPPER (well_compressed_name);
      RETURN well_compressed_name;
   END compress_well_name;


 FUNCTION cleanup_Special_Chars (p_value IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_result   VARCHAR2 (256) := p_value;
   BEGIN
      
      v_result := REPLACE (v_result, '-', ' ');
      v_result := REPLACE (v_result, '#', ' ');
      v_result := REPLACE (v_result, '_', ' ');
      v_result := REPLACE (v_result, '/', ' ');
      v_result := REPLACE (v_result, '\', ' ');
      v_result := REPLACE (v_result, '(', ' ');
      v_result := REPLACE (v_result, ')', ' ');
      v_result := REPLACE (v_result, '.', ' ');
      v_result := REPLACE (v_result, '?', ' ');
      v_result := REPLACE (v_result, '!', ' ');
      v_result := REPLACE (v_result, '&', ' ');
      v_result := REPLACE (v_result, ':', ' ');
      v_result := REPLACE (v_result, ',', ' ');
      v_result := REPLACE (v_result, ';', ' ');
      v_result := REPLACE (v_result, '+', ' ');
      v_result := REPLACE (v_result, '"', ' ');
      v_result := REPLACE (v_result, '~', ' ');
      v_result := REPLACE (v_result, '`', ' ');
      v_result := REPLACE (v_result, '@', ' ');
      v_result := REPLACE (v_result, '$', ' ');
      v_result := REPLACE (v_result, '%', ' ');
      v_result := REPLACE (v_result, '^', ' ');
      v_result := REPLACE (v_result, '*', ' ');
      v_result := REPLACE (v_result, ':=', ' ');
      v_result := REPLACE (v_result, '=', ' ');
      v_result := REPLACE (v_result, '{', ' ');
      v_result := REPLACE (v_result, '}', ' ');
      v_result := REPLACE (v_result, '[', ' ');
      v_result := REPLACE (v_result, ']', ' ');
      v_result := REPLACE (v_result, '<', ' ');
      v_result := REPLACE (v_result, '>', ' ');
      v_result := REPLACE (v_result, '|', ' ');
      v_result := REPLACE (v_result, CHR(39), ' '); --apostrophe 
      v_result := REPLACE (v_result, '    ', ' ');
      v_result := REPLACE (v_result, '   ', ' ');
      v_result := REPLACE (v_result, '  ', ' ');
      
      v_result := UPPER (v_result);
      
      
      RETURN v_result;
      
      
   END cleanup_Special_Chars;
/*----------------------------------------------------------------------------------------------------------
Function: GET_UWI_SORT
Detail:   Function to read IPL_UWI_LOCAL and create and return UWI_SORT. 
          This function is used for CWS wells in WIM_LOADER     

Created On: Feb. 2013
History of Change:
------------------------------------------------------------------------------------------------------------*/
Function GET_UWI_SORT(P_UWI well_Version.ipl_uwi_local%Type)
RETURN VARCHAR2
Is
   
    --DLS
    v_MeridianDir       Varchar2(1);
    v_Meridian          Varchar2(2);
    v_Township          varchar2(3);
    v_Range             varchar(2);    
    v_Legal_Subdiv      varchar(2);
    
    --NTS
    v_prim_quad         varchar2(3);
    v_letter_quad       varchar2(1);
    v_sixteenth         varchar2(2);
    v_block             varchar2(1);    
    v_quarter_unit      varchar2(1);
    
    --FPS    
    v_Lat_Deg           varchar2(2);
    v_Lat_Min           varchar2(2);
    v_long_deg          varchar2(3);
    v_long_min          varchar2(2);
         
    --common
    v_locType           Varchar2(1);
    v_unit              varchar2(3);
    v_Section           varchar(2);
    v_Loc_Exception     varchar(2);
    v_Event_sequence    varchar(2);
       
    v_UWI_Sort          well_version.ipl_uwi_sort%type;
    
Begin

    v_UWI_Sort:=NULL;
    IF Substr(P_UWI,1,1) = '1' --DLS 
    THEN
    
        v_LocType       :=  Substr(P_UWI,1,1);
        v_MeridianDir   :=  Substr( P_UWI, 13, 1 );
        v_Meridian      :=  Substr( P_UWI, 14, 1 );
        v_Township      :=  Substr( P_UWI, 8, 3 );
        v_Range         :=  Substr( P_UWI, 11, 2 );
        v_Section       :=  Substr( P_UWI, 6, 2 );       
        v_Legal_Subdiv  :=  Substr( P_UWI, 4, 2 );
        v_Loc_Exception :=  Substr( P_UWI, 2, 2 );
        v_Event_sequence:=  '0'||Substr( P_UWI, 16, 1 );
        
        v_UWI_Sort := v_LocType||v_MeridianDir||v_Meridian||v_township||v_Range||v_Section||v_Legal_Subdiv||v_Loc_Exception||v_Event_Sequence; 
        
    END IF;
   
    
    IF Substr(P_UWI,1,1) = '2' --NTS 
    THEN
      v_LocType       :=  Substr(P_UWI,1,1);  
      v_prim_quad       := Substr( P_UWI, 9, 3 );
      v_letter_quad     := Substr( P_UWI, 12, 1 );   
      v_sixteenth       := Substr( P_UWI, 13, 2 );
      v_Block           := Substr( P_UWI, 8, 1 );
      v_unit            := Substr( P_UWI, 5, 3 ); 
      v_quarter_unit    := Substr( P_UWI, 4, 1 );
      V_loc_exception   := Substr( P_UWI, 2, 2 );
      v_event_sequence  := '0'||Substr( P_UWI, 16, 1 );
    
      v_UWI_Sort := v_LocType||v_prim_quad||v_letter_quad||v_sixteenth||v_Block||v_unit||v_quarter_unit||V_loc_exception||v_event_sequence;
    
    END IF;
    
    IF Substr(P_UWI,1,1) = '3' --FPS 
    THEN
      v_LocType         := Substr(P_UWI,1,1);      
      v_Lat_Deg         := Substr( P_UWI, 7, 2 );
      v_Lat_Min         := Substr( P_UWI, 9, 2 );
      v_long_deg        := Substr( P_UWI, 11, 3 );
      v_long_min        := Substr( P_UWI, 14, 2 );
      v_section         := Substr( P_UWI, 5, 2 );
      v_unit            := Substr( P_UWI, 4, 1 );
      v_loc_exception   := Substr( P_UWI, 2, 2 );
      v_event_sequence  := Substr( P_UWI, 16, 1);  
        
      v_UWI_Sort := v_LocType||v_Lat_Deg||v_Lat_Min||v_Long_deg||v_Long_min||v_section||v_unit||v_loc_exception||v_event_sequence;
    END IF;
    
    return v_UWI_Sort;
End;


function is_last_version(
    p_uwi       well_version.uwi%type
    , p_source  well_version.source%type
) return number
is
    is_last_version   number;
begin
     /*is there any other ACTIVE versions of this well*/
    select case
    when count(1) > 0 then 0 else 1 end into is_last_version
    from ppdm.well_version wv
    join wim.r_rollup r on wv.source = r.source and wv.active_ind = r.active_ind and override_ind = 'N'
    where wv.uwi = p_uwi
        and wv.active_ind = 'Y'
        and wv.source <> p_source
    ;        
    return is_last_version;
exception
    when others then
        return 0;
end is_last_version;

----------------------------------------------------------------------------------------------------
-- Reformat the US Well Number (API)
---- history: 20151113  cdong   QC1741

function format_us_api ( p_value  varchar2 )
  return varchar2
is
    v_result    varchar2(256)   := upper(p_value);
begin
    v_result    := rpad(translate(v_result, 'xABCDEFGHKIJKLMNOPQRSTUVWXYZ- ', 'x'), 14, '0'); 

    return v_result;

end format_us_api;

---------------------------------------------------------------------------------------------------
    function cleanup_non_printable_chars(
        p_value in varchar2
    ) return varchar2
    is 
        v_result varchar2(2000);
    begin
        v_result := regexp_replace(p_value, '([^[:print:]])', '');

        
        return v_result;
     end cleanup_non_printable_chars;

END;
/


GRANT EXECUTE ON WIM_UTIL TO PPDM WITH GRANT OPTION;
GRANT EXECUTE ON WIM_UTIL TO WIM_LOADER WITH GRANT OPTION;


