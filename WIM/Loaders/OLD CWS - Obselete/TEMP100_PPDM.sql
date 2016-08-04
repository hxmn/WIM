

--*************************************************
--VRajpoot - Added some data cleanup steps

--Current loader puts PPDM36_NULL as Location Qualifier, New Loader will put "N/A"
--Need to replace PPDM36_NULL with "N/A" before starting load,otherwise new loader
-- will create a new row in node version table.

UPDATE well_node_version
SET LOCATION_QUALIFIER = 'N/A'
WHERE SOURCE = '100TLM';

COMMIT;


DELETE FROM ppdm.well_license where source = '100TLM';

commit;


Insert into ppdm.well_license(UWI, SOURCE, ACTIVE_IND, EFFECTIVE_DATE, EXPIRY_DATE, LICENSE_ID, LICENSE_NUM, PROJECTED_DEPTH, REMARK, ROW_CHANGED_BY, ROW_CHANGED_DATE, ROW_CREATED_BY, ROW_CREATED_DATE)
Select well_id, '100TLM', 'Y', WELL_LICENSE_EFF_DT, L.WELL_LICENSE_EXP_DT, well_id,    
       (Select GOV_WELL_LICENSE_CD from well_license@cws.world where well_license_id= W.well_license_id and length(GOV_WELL_LICENSE_CD) <10),     
       L.PROJECTED_DEPTH,
        (Select GOV_WELL_LICENSE_CD from well_license@cws.world where well_license_id= W.well_license_id and length(GOV_WELL_LICENSE_CD) > 9),
       L.LAST_UPDATE_USERID, L.LAST_UPDATE_DT, L.CREATE_USERID, L.CREATE_DT      
from   well@cws.world w , well_license@cws.world l
where w.well_license_id = L.well_license_id;

commit;



--Insert into well_STATUS

--Cleanup old data, doesnt match with CWS 
DELETE FROM well_status where source = '100TLM';

Insert into ppdm.well_status(UWI, SOURCE, ACTIVE_IND, ROW_CHANGED_BY, ROW_CHANGED_DATE, ROW_CREATED_BY, ROW_CREATED_DATE, STATUS,
                              STATUS_DATE, STATUS_ID)
Select WELL_ID, '100TLM', 'Y',  
       C.LAST_UPDATE_USERID, C.LAST_UPDATE_DT, C.CREATE_USERID, C.CREATE_DT, 
       WELL_STATUS_CD, C.WELL_STATUS_DT,  '001'  
From   well_current_data@cws.world c 
WHERE WELL_STATUS_CD is not null; 

COMMIT;



--Updating well_Version's Current_Status and Current_Status_Date

UPDATE  ( SELECT WV.UWI, WV.CURRENT_STATUS, WV.CURRENT_STATUS_DATE, C.well_Status_cd, c.well_status_dt
         FROM PPDM.WELL_VERSION WV, well_current_data@CWS.WORLD C
         where c.well_id = wv.uwi
         and wv.source = '100TLM' and  C.well_Status_cd is not null)
 SET CURRENT_STATUS = WELL_STATUS_CD,
    CURRENT_STATUS_DATE = well_status_dt;

commit;


-- Update Well_Versions tables  Create, update dates

UPDATE (  Select W.UWI,W.ROW_CREATED_DATE,W.ROW_CREATED_BY,W.ROW_CHANGED_DATE,W.ROW_CHANGED_BY,
            C.Create_dt CWS_Created_Date, c.create_UserId CWS_CREATED_BY,
                c.last_update_dt CWS_UPDATED_DATE,
                c.Last_Update_UserId CWS_UPDATED_BY
                from PPDM.WELL_VERSION W , well_current_data@CWS.WORLD C
                where w.uwi = c.well_id
            and w.source = '100TLM')
 SET  ROW_CREATED_DATE = CWS_Created_Date,
 ROW_CREATED_BY = CWS_CREATED_BY,
 ROW_CHANGED_DATE = CWS_UPDATED_DATE,
ROW_CHANGED_BY = CWS_UPDATED_BY;

COMMIT;
