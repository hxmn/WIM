ALTER TABLE PPDM.TLM_WELL_LOG
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_LOG CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_LOG
(
  UWI                 VARCHAR2(20 BYTE)         NOT NULL,
  WELL_LOG_ID         VARCHAR2(20 BYTE)         NOT NULL,
  SOURCE              VARCHAR2(20 BYTE)         NOT NULL,
  ACQUIRED_FOR_BA_ID  VARCHAR2(20 BYTE),
  ACTIVE_IND          VARCHAR2(1 BYTE),
  BASE_DEPTH          NUMBER(10,5),
  BASE_DEPTH_OUOM     VARCHAR2(20 BYTE),
  BYPASS_IND          VARCHAR2(1 BYTE),
  CASED_HOLE_IND      VARCHAR2(1 BYTE),
  COMPOSITE_IND       VARCHAR2(1 BYTE),
  DEPTH_TYPE          VARCHAR2(20 BYTE),
  DICTIONARY_ID       VARCHAR2(20 BYTE),
  EFFECTIVE_DATE      DATE,
  EXPIRY_DATE         DATE,
  LOG_JOB_ID          VARCHAR2(20 BYTE),
  LOG_JOB_SOURCE      VARCHAR2(20 BYTE),
  LOG_REF_NUM         VARCHAR2(60 BYTE),
  LOG_TITLE           VARCHAR2(240 BYTE),
  LOG_TOOL_PASS_NO    NUMBER(2),
  MWD_IND             VARCHAR2(1 BYTE),
  PPDM_GUID           VARCHAR2(38 BYTE),
  REMARK              VARCHAR2(2000 BYTE),
  TOP_DEPTH           NUMBER(10,5),
  TOP_DEPTH_OUOM      VARCHAR2(20 BYTE),
  TRIP_OBS_NO         NUMBER(8),
  ROW_CHANGED_BY      VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE    DATE,
  ROW_CREATED_BY      VARCHAR2(30 BYTE),
  ROW_CREATED_DATE    DATE,
  ROW_QUALITY         VARCHAR2(20 BYTE)
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

COMMENT ON TABLE PPDM.TLM_WELL_LOG IS 'WELL LOG: A group of one or more curves.  These curves, when taken together, are often assigned a name, such as Induction/Sonic, or FDC/CNL. When dealing with digitally delivered well log data, a log is generally synonymous with Pass or File.  A File is the basic unit of digital well log data interchange. DLIS, LIS, and BIT are multi-file tape formats which can be encapsulated and created on, or copied to disk as a single physical file.  Each logical file within this physical disk file is roughly comparable to the information contained in one LAS file.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.WELL_LOG_ID IS 'WELL LOG IDENTIFIER:  Unique identifier for the well log. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ACQUIRED_FOR_BA_ID IS 'ACQUIRED FOR BUSINESS ASSOCIATE ID:  Unique identifier for the business associate who ordered the acquisition of the well log.  Usually the operator of the well.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y / N flag indicating whether this row of data  is currently active. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.BASE_DEPTH IS 'BASE  DEPTH: the base depth of the log.  Can often be calculated by determining the depth of the last index on the cuves associated with the log. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.BASE_DEPTH_OUOM IS 'ORIGINAL UNIT OF MEASURE';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.BYPASS_IND IS 'BYPASS INDICATOR:  A Y/N flag indicating that this well log was acquired during a bypass operation.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.CASED_HOLE_IND IS 'CASED HOLE INDICATOR:  A Y/N flag indicating that this log was acquired in a cased hole environment. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.COMPOSITE_IND IS 'COMPOSITE INDICATOR: a Y/N flag indicating that this curve is a composite of curves taken during multiple passes or combined through other types of processing. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.DEPTH_TYPE IS 'LOG DEPTH TYPE:  the type of depth measurements provided in the log, such as Measured (MD) or True Vertical (TVD)';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.DICTIONARY_ID IS 'WELL LOG DICTIONARY:  The dictionary contains a set of curve names, property names and parameters that are used by a well logging contracter during a specified period of time.  At any given time, a contractor may have one or more dictionaries in use. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  date on which the data in this row came into effect.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.EXPIRY_DATE IS 'EXPIRY DATE:  Date on which the data in this row of data was no longer in effect. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.LOG_JOB_ID IS 'JOB IDENTIFIER: Unique identifier assigned to the wireline log job.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.LOG_JOB_SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.LOG_REF_NUM IS 'LOG REFERENCE NUMBER:  A reference number assigned to this log, such as a file number. These numbers may be used to assist in identifying logs. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.LOG_TITLE IS 'WELL LOG TITLE:  a textual name assigned to a log by a vendor or other company.  This information is not validated.  Validated classification information (such as INDUCTION, DENSITY etc) should be stored in WELL_LOG_CLASS.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.LOG_TOOL_PASS_NO IS 'PASS NUMBER: Number identifying each recorded pass of the logging tool string as it passes a section of the borehole.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.MWD_IND IS 'MEASURED WHILE DRILLING INDICATOR:  A Y/N flag indicating that this log was acquired during active drilling operations. Acquired while the bit was in the hole. Could be logged while drilling (LWD) or measured while drilling (MWD).';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.REMARK IS 'REMARK: Narrative remarks about this row of data.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.TOP_DEPTH IS 'TOP DEPTH: the top depth of the log.  Can often be calculated by determining the depth of the first  index on the cuves associated with the log. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.TOP_DEPTH_OUOM IS 'ORIGINAL UNIT OF MEASURE';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.TRIP_OBS_NO IS 'TRIP OBSERVATION NUMBER:  a unique number assigned to the data related to a well log trip.  If unique run numbers exist, they may be used if desired.  If not, a surrogate component is created. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TOI_WL_CHD_IDX ON PPDM.TLM_WELL_LOG
(ROW_CHANGED_DATE)
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


CREATE INDEX PPDM.TOI_WL_CRD_IDX ON PPDM.TLM_WELL_LOG
(ROW_CREATED_DATE)
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


CREATE INDEX PPDM.TWL_BA_IDX ON PPDM.TLM_WELL_LOG
(ACQUIRED_FOR_BA_ID)
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


CREATE INDEX PPDM.TWL_OUOM_IDX ON PPDM.TLM_WELL_LOG
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


CREATE INDEX PPDM.TWL_OUOM_IDX1 ON PPDM.TLM_WELL_LOG
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


CREATE UNIQUE INDEX PPDM.TWL_PK ON PPDM.TLM_WELL_LOG
(UWI, WELL_LOG_ID, SOURCE)
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


CREATE INDEX PPDM.TWL_R_LDT1_IDX ON PPDM.TLM_WELL_LOG
(DEPTH_TYPE)
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


CREATE INDEX PPDM.TWL_R_S_IDX ON PPDM.TLM_WELL_LOG
(SOURCE)
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


CREATE INDEX PPDM.TWL_WLD_IDX ON PPDM.TLM_WELL_LOG
(DICTIONARY_ID)
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


CREATE INDEX PPDM.TWL_WLPS_IDX ON PPDM.TLM_WELL_LOG
(UWI, LOG_JOB_SOURCE, LOG_JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO)
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


CREATE INDEX PPDM.TWL_WLT_IDX ON PPDM.TLM_WELL_LOG
(UWI, LOG_JOB_SOURCE, LOG_JOB_ID, TRIP_OBS_NO)
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


CREATE INDEX PPDM.TWL_W_IDX ON PPDM.TLM_WELL_LOG
(UWI)
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


CREATE OR REPLACE TRIGGER PPDM.TT_WELL_LOG 
  BEFORE INSERT OR UPDATE ON PPDM.WELL_LOG
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

END TT_WELL_LOG;
/


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM EZ_TOOLS.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM EZ_TOOLS.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM SDP.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM SDP.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM SDP_APPL.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM SDP_APPL.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM DATA_FINDER.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_WELL_LOG FOR PPDM.TLM_WELL_LOG;


DROP SYNONYM INT_VIEWER_APPL.TLM_WELL_LOG;

CREATE OR REPLACE SYNONYM INT_VIEWER_APPL.TLM_WELL_LOG FOR PPDM.WTLM_ELL_LOG;


ALTER TABLE PPDM.TLM_WELL_LOG ADD (
  CONSTRAINT TWL_PK
  PRIMARY KEY
  (UWI, WELL_LOG_ID, SOURCE)
  USING INDEX PPDM.TWL_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_LOG ADD (
  CONSTRAINT TWL_BA_FK 
  FOREIGN KEY (ACQUIRED_FOR_BA_ID) 
  REFERENCES PPDM.BUSINESS_ASSOCIATE (BUSINESS_ASSOCIATE)
  ENABLE VALIDATE,
  CONSTRAINT TWL_OUOM_FK 
  FOREIGN KEY (BASE_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWL_OUOM_FK1 
  FOREIGN KEY (TOP_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWL_R_LDT1_FK 
  FOREIGN KEY (DEPTH_TYPE) 
  REFERENCES PPDM.R_LOG_DEPTH_TYPE (DEPTH_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWL_R_S_FK 
  FOREIGN KEY (SOURCE) 
  REFERENCES PPDM.R_SOURCE (SOURCE)
  ENABLE VALIDATE,
  CONSTRAINT TWL_WLD_FK 
  FOREIGN KEY (DICTIONARY_ID) 
  REFERENCES PPDM.WELL_LOG_DICTIONARY (DICTIONARY_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWL_WLPS_FK 
  FOREIGN KEY (UWI, LOG_JOB_SOURCE, LOG_JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO) 
  REFERENCES PPDM.WELL_LOG_PASS (UWI,SOURCE,JOB_ID,TRIP_OBS_NO,LOG_TOOL_PASS_NO)
  ENABLE VALIDATE,
  CONSTRAINT TWL_WLT_FK 
  FOREIGN KEY (UWI, LOG_JOB_SOURCE, LOG_JOB_ID, TRIP_OBS_NO) 
  REFERENCES PPDM.WELL_LOG_TRIP (UWI,SOURCE,JOB_ID,TRIP_OBS_NO)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_LOG TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG TO EZ_TOOLS;

GRANT SELECT ON PPDM.TLM_WELL_LOG TO EZ_TOOLS_APPL;

GRANT SELECT ON PPDM.TLM_WELL_LOG TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG TO PPDM_RW;

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG TO SDP;

GRANT SELECT ON PPDM.TLM_WELL_LOG TO WELL_LOG_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG TO WELL_LOG_RW;

GRANT SELECT ON PPDM.TLM_WELL_LOG TO WIM;
