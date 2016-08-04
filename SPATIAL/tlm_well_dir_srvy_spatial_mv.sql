/***************************************************************************************************
 TLM_WELL_DIR_SRVY_SPATIAL_MV
 
 Used in creation of directional survey feature class, for GSS team.
 
 History: 
   20140718 cdong  
     Add filter to only return active and as-drilled dir srvys
     PPDM schema must "grant select on ppdm.tlm_well_dir_srvy to spatial".
                   

 **************************************************************************************************/

TRUNCATE TABLE SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV;
DROP MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV;

CREATE MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV (UWI, LATITUDE, LONGITUDE, STATION_TVD, STATION_MD, DEPTH_DATUM_ELEV, GEOG_COORD_SYSTEM_ID, SURVEY_ID, SOURCE, KB_ELEV, LATEST_DATE)
TABLESPACE APP_DATA
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
select w.uwi,
       wdss.latitude,
       wdss.longitude,
       wdss.station_tvd,
       wdss.station_md,
       w.depth_datum_elev,
       nvl (cs.coord_system_name, geog_coord_system_id) geog_coord_system_id,
       wdss.survey_id,
       wdss.source,
       w.kb_elev,
       greatest (
          nvl (
             w.row_changed_date,
             nvl (w.row_created_date, to_date ('0001-01-01', 'yyyy-mm-dd'))),
          nvl (
             wdss.row_changed_date,
             nvl (wdss.row_created_date,
                  to_date ('0001-01-01', 'yyyy-mm-dd'))))
          as latest_date
  from ppdm.tlm_well_dir_srvy_station wdss
       inner join ppdm.tlm_well_dir_srvy wds on wdss.uwi = wds.uwi and wdss.survey_id = wds.survey_id and WDSS.ACTIVE_IND = wds.active_ind and wdss.source = wds.source
       inner join ppdm.well w on w.uwi = wdss.uwi
       left join  ppdm.cs_coordinate_system cs on wdss.geog_coord_system_id = cs.coord_system_id and cs.active_ind = 'Y'
 where wdss.active_ind = 'Y'
       and nvl(wds.survey_quality, 'RAW') <> 'PROPOSED'

;

COMMENT ON MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV IS 'snapshot table for snapshot SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV';

GRANT SELECT ON SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV TO R_SPATIAL;


---- create synonym from other schema ------------------------------

DROP SYNONYM SPATIAL_APPL.TLM_WELL_DIR_SRVY_SPATIAL_MV;

CREATE SYNONYM SPATIAL_APPL.TLM_WELL_DIR_SRVY_SPATIAL_MV FOR SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV;
