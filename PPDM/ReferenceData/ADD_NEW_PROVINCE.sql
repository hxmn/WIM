--CREATE OR REPLACE procedure ADD_IPL_PROVINCES_VR
--IS

--This script is for loading statuses from IHSDATA (Canadian)
--@c_talisman_us is dblink reading from IHSDATA as user c_talisman/Chauvin

DECLARE
    v_changed_Date date;
    v_created_date date;
    v_num number;
Begin
    select max(row_changed_date), max(row_created_date) into v_changed_date, v_created_DAte
        from ppdm.r_province_State;

      for v_rec in ((   select * from r_province_State@c_talisman_ihsdata where 
                        province_State in (Select province_State from ( select provincE_State, country from r_province_State@c_talisman_ihsdata
                                                where activE_ind = 'Y'
                                                minus
                                                Select province_State, country from ppdm.r_province_State
                                                where activE_ind = 'Y'))
                )
                UNION
                Select * from r_province_State@c_talisman_ihsdata 
                    where ( row_created_date > v_Created_Date or row_changed_Date > v_changed_Date))
   loop
    
        
        select count(1) into v_num
        from ppdm.r_province_State
        where province_State = v_rec.province_State
        and country = v_rec.country 
        and active_ind = 'Y';
        
        if v_num = 0 then
         dbms_output.put_line ( v_rec.province_State);

             INSERT INTO PPDM.R_province_State
        (COUNTRY, PROVINCE_STATE, ABBREVIATION, ACTIVE_IND, EFFECTIVE_dATE,EXPIRY_DATE, LONG_NAME,PPDM_GUID,REMARK, SHORT_NAME, SOURCE,
        IPL_XACTION_CODE, ROW_CHANGED_BY, ROW_CHANGEd_DATE, ROW_CREATED_BY,ROW_CREATED_DATE, ROW_QUALITY)
            values (v_rec.COUNTRY, v_rec.PROVINCE_STATE, v_rec.ABBREVIATION, v_rec.ACTIVE_IND, v_rec.EFFECTIVE_dATE,v_rec.EXPIRY_DATE, v_rec.LONG_NAME,
                    v_rec.PPDM_GUID,v_rec.REMARK, v_rec.SHORT_NAME, v_rec.SOURCE,
                    null, v_rec.ROW_CHANGED_BY, v_rec.ROW_CHANGEd_DATE, v_rec.ROW_CREATED_BY,v_rec.ROW_CREATED_DATE, v_rec.ROW_QUALITY);
         commit;
       end if;           
    end loop;


End;
