ALTER TABLE PPDM.TLM_WELL_LOG_PASS
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_LOG_PASS CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_LOG_PASS
(
  UWI               VARCHAR2(20 BYTE)           NOT NULL,
  SOURCE            VARCHAR2(20 BYTE)           NOT NULL,
  JOB_ID            VARCHAR2(20 BYTE)           NOT NULL,
  TRIP_OBS_NO       NUMBER(8)                   NOT NULL,
  LOG_TOOL_PASS_NO  NUMBER(2)                   NOT NULL,
  ACTIVE_IND        VARCHAR2(1 BYTE),
  BASE_DEPTH        NUMBER(10,5),
  BASE_DEPTH_OUOM   VARCHAR2(20 BYTE),
  BASE_LOG_IND      VARCHAR2(1 BYTE),
  EFFECTIVE_DATE    DATE,
  END_TIME          DATE,
  EXPIRY_DATE       DATE,
  PPDM_GUID         VARCHAR2(38 BYTE),
  REMARK            VARCHAR2(2000 BYTE),
  START_TIME        DATE,
  TOP_DEPTH         NUMBER(10,5),
  TOP_DEPTH_OUOM    VARCHAR2(20 BYTE),
  ROW_CHANGED_BY    VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE  DATE,
  ROW_CREATED_BY    VARCHAR2(30 BYTE),
  ROW_CREATED_DATE  DATE,
  ROW_QUALITY       VARCHAR2(20 BYTE)
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

COMMENT ON TABLE PPDM.TLM_WELL_LOG_PASS IS 'WELL LOG PASS:  Pass - A Pass is any continuous recording of sensor readings for the logging instruments within a Trip. A Pass begins when data recording is started and ends when data recording is stopped.  For depth based data acquisition, the Tool String is generally moving up or down the Well borehole during a Pass, whereas it may be stationary for time based data acquisition.  Passes exist within the context of a Trip and there may be 0, 1, or more Passes per Trip.
      ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.JOB_ID IS 'JOB IDENTIFIER: Unique identifier assigned to the wireline log job.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.TRIP_OBS_NO IS 'TRIP OBSERVATION NUMBER:  a unique number assigned to the data related to a well log trip.  If unique run numbers exist, they may be used if desired.  If not, a surrogate component is created. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.LOG_TOOL_PASS_NO IS 'PASS NUMBER: Number identifying each recorded pass of the logging tool string as it passes a section of the borehole.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y/N flag indicating whether this row of data is currently active or valid.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.BASE_DEPTH IS 'BASE DEPTH: Depth of the curve data at the bottom of the logging pass.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.BASE_DEPTH_OUOM IS 'BASE DEPTH OUOM: Base depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.BASE_LOG_IND IS 'BASE LOG INDICATOR:  a Y/N flag to indicate when a curve is a base curve.  These curves, generated during a particular logging pass, are used as a benchmark for all other curves. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  The date that the data in this row first came into effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.END_TIME IS 'END TIME: time that the logging pass ended. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.EXPIRY_DATE IS 'EXPIRY DATE:  The date that the data in this row was no longer active or in effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.REMARK IS 'REMARK: Remarks or comments pertaining to curve intervals.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.START_TIME IS 'START TIME:  time that the logging pass started. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.TOP_DEPTH IS 'TOP DEPTH: Depth of the curve data at the beginning of the logging pass.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.TOP_DEPTH_OUOM IS 'TOP DEPTH OUOM: Top depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_PASS.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TWLPS_OUOM_IDX ON PPDM.TLM_WELL_LOG_PASS
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


CREATE INDEX PPDM.TWLPS_OUOM_IDX1 ON PPDM.TLM_WELL_LOG_PASS
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


CREATE UNIQUE INDEX PPDM.TWLPS_PK ON PPDM.TLM_WELL_LOG_PASS
(UWI, SOURCE, JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO)
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


CREATE INDEX PPDM.TWLPS_WLT_IDX ON PPDM.TLM_WELL_LOG_PASS
(UWI, SOURCE, JOB_ID, TRIP_OBS_NO)
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


CREATE OR REPLACE TRIGGER PPDM.TT_WELL_LOG_PASS 
  BEFORE INSERT OR UPDATE ON PPDM.TLM_WELL_LOG_PASS
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

END TT_WELL_LOG_PASS;
/


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


DROP SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


DROP SYNONYM EZ_TOOLS.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM EZ_TOOLS.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


DROP SYNONYM SDP.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM SDP.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


DROP SYNONYM SDP_APPL.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM SDP_APPL.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


DROP SYNONYM DATA_FINDER.TLM_WELL_LOG_PASS;

CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_WELL_LOG_PASS FOR PPDM.TLM_WELL_LOG_PASS;


ALTER TABLE PPDM.TLM_WELL_LOG_PASS ADD (
  CONSTRAINT TWLPS_PK
  PRIMARY KEY
  (UWI, SOURCE, JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO)
  USING INDEX PPDM.TWLPS_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_LOG_PASS ADD (
  CONSTRAINT TWLPS_OUOM_FK 
  FOREIGN KEY (TOP_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLPS_OUOM_FK1 
  FOREIGN KEY (BASE_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLPS_WLT_FK 
  FOREIGN KEY (UWI, SOURCE, JOB_ID, TRIP_OBS_NO) 
  REFERENCES PPDM.WELL_LOG_TRIP (UWI,SOURCE,JOB_ID,TRIP_OBS_NO)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_PASS TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_LOG_PASS TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_PASS TO EZ_TOOLS;

GRANT SELECT ON PPDM.TLM_WELL_LOG_PASS TO EZ_TOOLS_APPL;

GRANT SELECT ON PPDM.TLM_WELL_LOG_PASS TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_PASS TO PPDM_RW;

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_PASS TO SDP;

GRANT SELECT ON PPDM.TLM_WELL_LOG_PASS TO WELL_LOG_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_PASS TO WELL_LOG_RW;
