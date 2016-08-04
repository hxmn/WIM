ALTER TABLE PPDM.TLM_WELL_LOG_TRIP
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_LOG_TRIP CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_LOG_TRIP
(
  UWI                          VARCHAR2(20 BYTE) NOT NULL,
  SOURCE                       VARCHAR2(20 BYTE) NOT NULL,
  JOB_ID                       VARCHAR2(20 BYTE) NOT NULL,
  TRIP_OBS_NO                  NUMBER(8)        NOT NULL,
  ACTIVE_IND                   VARCHAR2(1 BYTE),
  BASE_DEPTH                   NUMBER(10,5),
  BASE_DEPTH_OUOM              VARCHAR2(20 BYTE),
  BASE_STRAT_UNIT_ID           VARCHAR2(20 BYTE),
  EFFECTIVE_DATE               DATE,
  EXPIRY_DATE                  DATE,
  LOGGING_SERVICE_TYPE         VARCHAR2(20 BYTE),
  MAX_DEPTH                    NUMBER(10,5),
  MAX_DEPTH_OUOM               VARCHAR2(20 BYTE),
  MAX_TEMPERATURE              NUMBER(5,2),
  MAX_TEMPERATURE_OUOM         VARCHAR2(20 BYTE),
  MUD_SAMPLE_ID                VARCHAR2(20 BYTE),
  MUD_SAMPLE_TYPE              VARCHAR2(20 BYTE),
  MUD_SOURCE                   VARCHAR2(20 BYTE),
  OBSERVER                     VARCHAR2(60 BYTE),
  ON_BOTTOM_DATE               DATE,
  ON_BOTTOM_TIME               VARCHAR2(20 BYTE),
  PPDM_GUID                    VARCHAR2(38 BYTE),
  REMARK                       VARCHAR2(2000 BYTE),
  REPORTED_TVD                 NUMBER(10,5),
  REPORTED_TVD_OUOM            VARCHAR2(20 BYTE),
  REPORT_APD                   NUMBER(10,5),
  REPORT_LOG_DATUM             VARCHAR2(20 BYTE),
  REPORT_LOG_DATUM_ELEV        NUMBER(10,5),
  REPORT_LOG_DATUM_ELEV_OUOM   VARCHAR2(20 BYTE),
  REPORT_LOG_RUN               VARCHAR2(5 BYTE),
  REPORT_PERM_DATUM            VARCHAR2(20 BYTE),
  REPORT_PERM_DATUM_ELEV       NUMBER(10,5),
  REPORT_PERM_DATUM_ELEV_OUOM  VARCHAR2(20 BYTE),
  STRAT_NAME_SET_ID            VARCHAR2(20 BYTE),
  TOP_DEPTH                    NUMBER(10,5),
  TOP_DEPTH_OUOM               VARCHAR2(20 BYTE),
  TOP_STRAT_UNIT_ID            VARCHAR2(20 BYTE),
  TRIP_DATE                    DATE,
  TUBING_BOTTOM_DEPTH          NUMBER(10,5),
  TUBING_BOTTOM_DEPTH_OUOM     VARCHAR2(20 BYTE),
  ROW_CHANGED_BY               VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE             DATE,
  ROW_CREATED_BY               VARCHAR2(30 BYTE),
  ROW_CREATED_DATE             DATE,
  ROW_QUALITY                  VARCHAR2(20 BYTE)
)
TABLESPACE PPDM_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          80K
            NEXT             80K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE PPDM.TLM_WELL_LOG_TRIP IS 'WELL LOG TRIP:    A Trip encompasses all of the activities performed by a Business Entity (generally a Service Company), while a particular Logging Tool String is in the Well borehole.  The Trip begins when the tool is inserted into the hole and end when it is pulled out.  Trips exist within the context of a Run and there may be 0, 1, or more Trips per Run.
';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.JOB_ID IS 'JOB IDENTIFIER: Unique identifier assigned to the wireline log job.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TRIP_OBS_NO IS 'TRIP OBSERVATION NUMBER:  a unique number assigned to the data related to a well log trip.  If unique run numbers exist, they may be used if desired.  If not, a surrogate component is created. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y/N flag indicating whether this row of data is currently active or valid.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.BASE_DEPTH IS 'BASE DEPTH: Measured depth from the surface to the bottom of the logged interval.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.BASE_DEPTH_OUOM IS 'BASE DEPTH OUOM: Base depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.BASE_STRAT_UNIT_ID IS 'STRATIGRAPHIC UNIT IDENTIFIER:  unique identifier for the stratigraphic unit.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  The date that the data in this row first came into effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.EXPIRY_DATE IS 'EXPIRY DATE:  The date that the data in this row was no longer active or in effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.LOGGING_SERVICE_TYPE IS 'LOG CURVE TYPE: This reference table identifies the type of wireline log curve recorded during the logging operation. For example, caliper, gamma ray.      ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MAX_DEPTH IS 'MAXIMUM DEPTH: Maximum depth reached by the survey or test tool during the log run.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MAX_DEPTH_OUOM IS 'MAXIMUM DEPTH OUOM: Maximum depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MAX_TEMPERATURE IS 'MAXIMUM TEMPERATURE: Value for the maximum temperature in the borehole during this trip.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MAX_TEMPERATURE_OUOM IS 'MAXIMUM TEMPERATURE OUOM: Maximum temperature original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MUD_SAMPLE_ID IS 'MUD SAMPLE IDENTIFIER: Unique identifier assigned to each mud sample in the well.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MUD_SAMPLE_TYPE IS 'MUD SAMPLE TYPE: The unique identifier for the reference table.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.MUD_SOURCE IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.OBSERVER IS 'OBSERVER:  the person who witnessed the wireline  operations.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ON_BOTTOM_DATE IS 'ON BOTTOM DATE: Date the logging tool reached the bottom of the wellbore.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ON_BOTTOM_TIME IS 'ON BOTTOM TIME: Time of day the logging tool reached the bottom of the wellbore.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REMARK IS 'REMARK: Remarks or comments pertaining to wireline log tripping data.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORTED_TVD IS 'REPORTED TRUE VERTICAL DEPTH:  The reported depth of a well measured  vertically from the surface to the  point of interest in the well  bore.  These reported values may not  represent the actual TVD as  derivable from the directional survey and may consequently be in  error.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORTED_TVD_OUOM IS 'REPORTED TRUE VERTICAL DEPTH ORIGINAL UNITS OF MEASURE:    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_APD IS 'REPORTED APD: The height of the log datum above the reported permanent datum, as reported by the source of this row.  Reference APD in LAS format.  To adjust a reported depth to the reported permanent datum, compute e.g. LOG DATUM ELEV - PERMANENT DATUM ELEV.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_LOG_DATUM IS 'REPORTED LOG DATUM:  The datum from which the log depths are measured.  The point at which log depth equals zero, e.g.  elly bushing.  Reference DREF in LAS format.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_LOG_DATUM_ELEV IS 'REPORTED LOG DATUM ELEV): The elevation of the LOG_DATUM, as reported by the source of this row.  Reference EREF in LAS format.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_LOG_DATUM_ELEV_OUOM IS 'REPORTED LOG DATUM ELEVATION ORIGINAL UNITS OF MEASURE:';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_LOG_RUN IS 'REPORTED LOG RUN: Reported value indicating the run number of the log job trip . A sequence number usually assigned by the contractor indicating a particular set of log operations run in a wellbore on or about the same date. The log run for a well may not be known or  unique, so this column was removed from the PK in PPDM 3.7.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_PERM_DATUM IS 'REPORT_PERM_DATUM: The permanent datum as reported by the source of this row.  Reference PDAT in LAS format.  Generally, this value should be the same as WELL.WELL_DEPTH_DATUM, but in rare cases it may be different.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_PERM_DATUM_ELEV IS 'REPORT_PERM_DATUM_ELEV:  The reported elevation of the permanent datum.  This should be the same as WELL.DEPTH_DATUM_ELEV, but in rare cases it may be different. Reference EPD in LAS.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.REPORT_PERM_DATUM_ELEV_OUOM IS 'REPORTED PERMANENT DATUM ELEVATION ORIGINAL UNITS OF MEASURE: ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.STRAT_NAME_SET_ID IS 'STRAT NAME SET IDENTIFIER:  Unique identifier for the stratigraphic name set.  A stratigraphic name set is an unordered  collection of   stratigraphic units, that may be in use for a Lexicon,  a geographic area, a project, a company etc.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TOP_DEPTH IS 'TOP DEPTH: Measured depth from the surface datum to the top of the logged interval.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TOP_DEPTH_OUOM IS 'TOP DEPTH OUOM: Top depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TOP_STRAT_UNIT_ID IS 'STRATIGRAPHIC UNIT IDENTIFIER:  unique identifier for the stratigraphic unit.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TRIP_DATE IS 'TRIP DATE: Date the logging tools entered the borehole for this trip.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TUBING_BOTTOM_DEPTH IS 'TUBING BOTTOM DEPTH: Depth measured at the bottom of the tubing by the logger.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.TUBING_BOTTOM_DEPTH_OUOM IS 'TUBING BOTTOM DEPTH OUOM: Tubing bottom depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_TRIP.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TWLT_OUOM_IDX ON PPDM.TLM_WELL_LOG_TRIP
(REPORTED_TVD_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX1 ON PPDM.TLM_WELL_LOG_TRIP
(REPORT_LOG_DATUM_ELEV_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX2 ON PPDM.TLM_WELL_LOG_TRIP
(REPORT_PERM_DATUM_ELEV_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX3 ON PPDM.TLM_WELL_LOG_TRIP
(TOP_DEPTH_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX4 ON PPDM.TLM_WELL_LOG_TRIP
(TUBING_BOTTOM_DEPTH_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX5 ON PPDM.TLM_WELL_LOG_TRIP
(BASE_DEPTH_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX6 ON PPDM.TLM_WELL_LOG_TRIP
(MAX_DEPTH_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_OUOM_IDX7 ON PPDM.TLM_WELL_LOG_TRIP
(MAX_TEMPERATURE_OUOM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE UNIQUE INDEX PPDM.TWLT_PK ON PPDM.TLM_WELL_LOG_TRIP
(UWI, SOURCE, JOB_ID, TRIP_OBS_NO)
LOGGING
TABLESPACE PPDM_DATA
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_R_CT6_IDX ON PPDM.TLM_WELL_LOG_TRIP
(LOGGING_SERVICE_TYPE)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_R_MST_IDX ON PPDM.TLM_WELL_LOG_TRIP
(MUD_SAMPLE_TYPE)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_R_WDT_IDX ON PPDM.TLM_WELL_LOG_TRIP
(REPORT_LOG_DATUM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_R_WDT_IDX2 ON PPDM.TLM_WELL_LOG_TRIP
(REPORT_PERM_DATUM)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_STU_IDX ON PPDM.TLM_WELL_LOG_TRIP
(STRAT_NAME_SET_ID, BASE_STRAT_UNIT_ID)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_STU_IDX2 ON PPDM.TLM_WELL_LOG_TRIP
(STRAT_NAME_SET_ID, TOP_STRAT_UNIT_ID)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_WLJ_IDX ON PPDM.TLM_WELL_LOG_TRIP
(UWI, SOURCE, JOB_ID)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE INDEX PPDM.TWLT_WMS_IDX ON PPDM.TLM_WELL_LOG_TRIP
(UWI, MUD_SOURCE, MUD_SAMPLE_ID)
LOGGING
TABLESPACE PPDM_INDEXES
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
NOPARALLEL;


CREATE OR REPLACE TRIGGER PPDM.TT_WELL_LOG_TRIP 
  BEFORE INSERT OR UPDATE ON PPDM.TLM_WELL_LOG_TRIP
  FOR EACH ROW
BEGIN

  IF INSERTING THEN
    IF :new.effective_date IS NULL THEN       -- effective_date
      :new.effective_date := SYSDATE;
    END IF;
    IF :new.row_created_date IS NULL THEN     -- row_created_date
      :new.row_created_date := SYSDATE;
    END IF;
    IF :new.row_created_by IS NULL THEN       -- row_created_by
      IF USER = 'PPDM37' THEN
        :new.row_created_by := 'OILWARE';
      ELSE
        :new.row_created_by := USER;
      END IF;
    END IF;
    IF :new.active_ind IS NULL THEN           -- active_ind
      :new.active_ind := 'Y';
    END IF;

  ELSE

-- Do the following only if UPDATING.

    :new.row_changed_date := SYSDATE;         -- row_changed_date
    IF USER = 'PPDM37' THEN                   -- row_changed_by
      :new.row_changed_by := 'OILWARE';
    ELSE
      :new.row_changed_by := USER;
    END IF;
  END IF;

END TT_WELL_LOG_TRIP;
/


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


DROP SYNONYM SDP.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM SDP.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


DROP SYNONYM EZ_TOOLS.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM EZ_TOOLS.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


DROP SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


DROP SYNONYM SDP_APPL.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM SDP_APPL.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


DROP SYNONYM DATA_FINDER.TLM_WELL_LOG_TRIP;

CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_WELL_LOG_TRIP FOR PPDM.TLM_WELL_LOG_TRIP;


ALTER TABLE PPDM.TLM_WELL_LOG_TRIP ADD (
  CONSTRAINT TWLT_PK
  PRIMARY KEY
  (UWI, SOURCE, JOB_ID, TRIP_OBS_NO)
  USING INDEX PPDM.TWLT_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_LOG_TRIP ADD (
  CONSTRAINT TWLT_OUOM_FK 
  FOREIGN KEY (REPORTED_TVD_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK1 
  FOREIGN KEY (REPORT_LOG_DATUM_ELEV_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK2 
  FOREIGN KEY (REPORT_PERM_DATUM_ELEV_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK3 
  FOREIGN KEY (TOP_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK4 
  FOREIGN KEY (TUBING_BOTTOM_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK5 
  FOREIGN KEY (BASE_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK6 
  FOREIGN KEY (MAX_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_OUOM_FK7 
  FOREIGN KEY (MAX_TEMPERATURE_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_R_CT6_FK 
  FOREIGN KEY (LOGGING_SERVICE_TYPE) 
  REFERENCES PPDM.R_CURVE_TYPE (CURVE_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_R_MST_FK 
  FOREIGN KEY (MUD_SAMPLE_TYPE) 
  REFERENCES PPDM.R_MUD_SAMPLE_TYPE (MUD_SAMPLE_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_R_WDT_FK 
  FOREIGN KEY (REPORT_LOG_DATUM) 
  REFERENCES PPDM.R_WELL_DATUM_TYPE (WELL_DATUM_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_R_WDT_FK2 
  FOREIGN KEY (REPORT_PERM_DATUM) 
  REFERENCES PPDM.R_WELL_DATUM_TYPE (WELL_DATUM_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_WLJ_FK 
  FOREIGN KEY (UWI, SOURCE, JOB_ID) 
  REFERENCES PPDM.WELL_LOG_JOB (UWI,SOURCE,JOB_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLT_WMS_FK 
  FOREIGN KEY (UWI, MUD_SOURCE, MUD_SAMPLE_ID) 
  REFERENCES PPDM.WELL_MUD_SAMPLE (UWI,SOURCE,SAMPLE_ID)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_TRIP TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_LOG_TRIP TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_TRIP TO EZ_TOOLS;

GRANT SELECT ON PPDM.TLM_WELL_LOG_TRIP TO EZ_TOOLS_APPL;

GRANT SELECT ON PPDM.TLM_WELL_LOG_TRIP TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_TRIP TO PPDM_RW;

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_TRIP TO SDP;

GRANT SELECT ON PPDM.TLM_WELL_LOG_TRIP TO WELL_LOG_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_TRIP TO WELL_LOG_RW;
