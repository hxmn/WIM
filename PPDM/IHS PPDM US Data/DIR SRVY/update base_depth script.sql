select * from PPDM.TLM_WELL_DIR_SRVY;

select * from PPDM.TLM_WELL_DIR_SRVY where uwi = '1000000097';
select uwi, survey_id, depth_obs_no, station_md from PPDM.TLM_WELL_DIR_SRVY_STATION where uwi = '1000000097' and survey_id = '001';
select uwi, survey_id, max(station_md) from PPDM.TLM_WELL_DIR_SRVY_STATION where uwi = '1000000097' --and survey_id = '001'
group by uwi, survey_id;

------------------------------------
update PPDM.TLM_WELL_DIR_SRVY wds
   set WDS.BASE_DEPTH = (select max(WDSS.STATION_MD) 
                           from ppdm.tlm_well_dir_srvy_station wdss
                          where WDSS.UWI = wds.uwi 
                            and wdss.survey_id = wds.survey_id  
                       group by wdss.uwi, wdss.uwi)
      , WDS.ROW_CHANGED_BY = 'JFUNG'
      , WDS.ROW_CHANGED_DATE = sysdate;
                       
