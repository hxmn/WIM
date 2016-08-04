select *
from ppdm.r_Well_Status
where status ='07030400';
--CREATE OR REPLACE procedure ADD_IPL_OPERATORS_VR
--IS

--This script is for loading statuses from IHSDATAQ (US)

--@c_talisman_us is dblink reading from IHSDATAQ as user c_talisman_us/stat3s
declare
    v_changed_Date date;
    v_created_date date;
    v_num number;
Begin
    select max(row_changed_date), max(row_created_date) into v_changed_date, v_created_DAte
        from ppdm.r_Well_Status;

      for rec in ((   select * from r_Well_Status@c_talisman_us where 
                        status in (Select status from r_Well_Status@c_talisman_US
                                                where activE_ind = 'Y'
                                                minus
                                                Select status from ppdm.r_Well_Status
                                                where activE_ind = 'Y')
                )
                UNION
                Select * from r_Well_Status@c_talisman_us_ihsdataq 
                    where ( row_created_date > v_Created_Date or row_changed_Date > v_changed_Date))
   loop
    
        --Check if Status is already there
        select count(1) into v_num
        from ppdm.r_Well_Status
        where status = rec.status 
        and active_ind = 'Y';
        
        
        --if not, then insert it
        if v_num = 0 then
         dbms_output.put_line ( rec.status);

             INSERT INTO PPDM.r_well_status
                 (STATUS_TYPE,STATUS,ABBREVIATION,ACTIVE_IND,EFFECTIVE_DATE,EXPIRY_DATE,LONG_NAME,PPDM_GUID,REMARK,SHORT_NAME,
                 SOURCE,STATUS_GROUP,IPL_XACTION_CODE,ROW_CHANGED_BY,ROW_CHANGED_DATE,ROW_CREATED_BY,ROW_CREATED_DATE,ROW_QUALITY)
            values (rec.status_type,rec.status, rec.ABBREVIATION, 'Y', rec.EFFECTIVE_DATE, rec.EXPIRY_DATE, rec.LONG_NAME, rec.PPDM_GUID, 
             rec.remark,rec.SHORT_NAME, rec.SOURCE,rec.status_group,
            null, rec.ROW_CHANGED_BY, rec.ROW_CHANGED_DATE, rec.ROW_CREATED_BY, rec.ROW_CREATED_DATE,rec.ROW_QUALITY);
         commit;
       end if;           
    end loop;


End;
