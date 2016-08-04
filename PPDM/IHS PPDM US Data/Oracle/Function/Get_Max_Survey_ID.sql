CREATE OR REPLACE FUNCTION PPDM_ADMIN.Get_Max_Survey_ID(p_uwi varchar2, p_Survey_ID varchar2) --, p_table_name varchar2)
RETURN varchar2
IS

V_Survey_ID  ppdm.cs_coordinate_system.coord_system_id%type;
V_Srvy_id_exist  number;
v_temp number;
v_temp_table varchar2(100);

BEGIN

--  v_temp_table := p_table_name;
  
  if p_Survey_id is not null then
       SELECT count(survey_id) into V_Srvy_id_exist 
         FROM ppdm.tlm_well_dir_srvy --v_temp_table
        WHERE uwi = p_uwi;
         
       IF (V_Srvy_id_exist >= 1) THEN
           SELECT to_number(max(survey_id)) into v_temp 
             FROM ppdm.tlm_well_dir_srvy --v_temp_table
            WHERE uwi = p_uwi;

           v_temp := v_temp + 1;
           
           V_Survey_ID := ppdm_admin.prefix_zeros (to_char(v_temp));
           
       Else
           V_Survey_ID := p_Survey_ID;
         
       END IF;
  end if;    
    
    RETURN V_Survey_ID;

    EXCEPTION

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'An error was encountered in ppdm_admin.Get_Max_Survey_ID function '  || SQLERRM);

END;
/
