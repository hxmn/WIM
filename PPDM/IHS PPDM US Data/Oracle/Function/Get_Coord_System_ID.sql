--
-- To convert Coord_system_id to numerical codes
--
CREATE OR REPLACE FUNCTION Get_Coord_System_ID(p_Geog_Coord_System_ID varchar2)
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
                AND COORD_SYSTEM_NAME = p_Geog_Coord_System_ID
                order by coord_system_id)
         WHERE row_number =1;
  

         
    IF V_GEOG_COORD_SYS_ID is NULL THEN
       V_GEOG_COORD_SYS_ID := '0000';
    END IF;
  end if;    
    
    RETURN V_GEOG_COORD_SYS_ID;

    EXCEPTION

    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'An error was encountered in ppdm_admin.Get_Coord_System_ID function '  || SQLERRM);

END;
/

grant execute on ppdm_admin.get_coord_system_id to ppdm;
/