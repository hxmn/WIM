--This script is for loading operators from IHSDATA (Canadian)
--@c_talisman_us is dblink reading from IHSDATA as user c_talisman/Chauvin

--CREATE OR REPLACE procedure ADD_IPL_OPERATORS_VR
--IS
declare
    v_changed_Date date;
    v_created_date date;
    v_num number;
Begin
    select max(row_changed_date), max(row_created_date) into v_changed_date, v_created_DAte
        from business_associate;
    
    for v_ba in ((   select * from business_associate@c_talisman_ihsdata where 
                        business_associate in (Select business_associate from business_associate@c_talisman_ihsdata
                                                where activE_ind = 'Y'
                                                minus
                                                Select business_associate from ppdm.business_associate
                                                where activE_ind = 'Y')
                )
                UNION
                Select * from business_associate@c_talisman_ihsdata 
                    where ( row_created_date > v_Created_Date or row_changed_Date > v_changed_Date))
   loop
    
        
        select count(1) into v_num
        from BUSINESS_ASSOCIATE
        where BUSINESS_ASSOCIATE = v_ba.BUSINESS_ASSOCIATE 
        and active_ind = 'Y';
        
        if v_num = 0 then
         dbms_output.put_line ( v_ba.business_associate);

             INSERT INTO PPDM.BUSINESS_ASSOCIATE
        (BUSINESS_ASSOCIATE, ACTIVE_IND, BA_ABbREVIATION, BA_CATEGORY, BA_cODE, BA_NAME, BA_SHORT_NAME, BA_TYPE,CREDIT_CHECK_DATE, CREDIT_CHECK_ind,
        CREDIT_CHECK_SOURCE, CREDIT_RATING, CREDIT_RATING_SOURCE, CURRENT_STATUS, EFFECTIVE_dATE,EXPIRY_DATE, FIRST_NAME, LAST_NAME, MAIN_EMAIL_ADDRESS,
        MAIN_FAX_NUM, MAIN_PHONE_NUM, MAIN_WEB_URL, MIDDLE_INiTIAL,PPDM_GUID, REMARK, SOURCE, ROW_CHANGED_BY, ROW_CHANGEd_DATE, ROW_CREATED_BY, 
        ROW_CREATED_DATE, ROW_QUALITY)
            values (v_ba.BUSINESS_ASSOCIATE, 'Y', v_ba.BA_ABbREVIATION, v_ba.BA_CATEGORY, v_ba.BA_cODE, v_ba.BA_NAME, v_ba.BA_SHORT_NAME, 
             v_ba.BA_TYPE,v_ba.CREDIT_CHECK_DATE, v_ba.CREDIT_CHECK_ind,
            v_ba.CREDIT_CHECK_SOURCE, v_ba.CREDIT_RATING, v_ba.CREDIT_RATING_SOURCE, v_ba.CURRENT_STATUS, v_ba.EFFECTIVE_dATE,v_ba.EXPIRY_DATE, 
            v_ba.FIRST_NAME, v_ba.LAST_NAME, v_ba.MAIN_EMAIL_ADDRESS,
            v_ba.MAIN_FAX_NUM, v_ba.MAIN_PHONE_NUM, v_ba.MAIN_WEB_URL, v_ba.MIDDLE_INiTIAL,v_ba.PPDM_GUID, v_ba.REMARK, v_ba.SOURCE, v_ba.ROW_CHANGED_BY, 
           v_ba.ROW_CHANGEd_DATE, v_ba.ROW_CREATED_BY, v_ba.ROW_CREATED_DATE, v_ba.ROW_QUALITY);
         commit;
       end if;           
    end loop;


End;

