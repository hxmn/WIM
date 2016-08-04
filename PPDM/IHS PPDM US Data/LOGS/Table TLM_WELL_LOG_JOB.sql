ALTER TABLE PPDM.TLM_WELL_LOG_JOB
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_LOG_JOB CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_LOG_JOB
(
  UWI                     VARCHAR2(20 BYTE)     NOT NULL,
  SOURCE                  VARCHAR2(20 BYTE)     NOT NULL,
  JOB_ID                  VARCHAR2(20 BYTE)     NOT NULL,
  ACTIVE_IND              VARCHAR2(1 BYTE),
  CASING_SHOE_DEPTH       NUMBER(10,5),
  CASING_SHOE_DEPTH_OUOM  VARCHAR2(20 BYTE),
  DRILLING_MD             NUMBER(10,5),
  DRILLING_MD_OUOM        VARCHAR2(20 BYTE),
  EFFECTIVE_DATE          DATE,
  END_DATE                DATE,
  ENGINEER                VARCHAR2(20 BYTE),
  EXPIRY_DATE             DATE,
  LOGGING_COMPANY         VARCHAR2(20 BYTE),
  LOGGING_UNIT            VARCHAR2(20 BYTE),
  LOGGING_UNIT_BASE       VARCHAR2(20 BYTE),
  OBSERVER                VARCHAR2(60 BYTE),
  PPDM_GUID               VARCHAR2(38 BYTE),
  REMARK                  VARCHAR2(2000 BYTE),
  START_DATE              DATE,
  ROW_CHANGED_BY          VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE        DATE,
  ROW_CREATED_BY          VARCHAR2(30 BYTE),
  ROW_CREATED_DATE        DATE,
  ROW_QUALITY             VARCHAR2(20 BYTE)
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

COMMENT ON TABLE PPDM.TLM_WELL_LOG_JOB IS 'WELL LOG JOB: A Job encompasses all of the activities performed by a Business Entity (generally a Service Company), while it is engaged by the Operator of the Well to perform services.  The scope of services for the Job is generally specified under the terms of a contract or service order.  The Job begins when the Service Company arrives at the Well and ends when it leaves.  As an example, for a land based well, a Job begins when the Logging Crew arrives in the truck at the well site and it ends when they drive away.
    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.JOB_ID IS 'JOB IDENTIFIER: Unique identifier assigned to the wireline log job.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y/N flag indicating whether this row of data is currently active or valid.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.CASING_SHOE_DEPTH IS 'CASING SHOE DEPTH: Depth measurement of the logger"s deepest casing shoe.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.CASING_SHOE_DEPTH_OUOM IS 'CASING SHOE DEPTH OUOM: Casing shoe depth original unit of measure.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.DRILLING_MD IS 'DRILLING MEASURED DEPTH: The current total drilling depth of the wellbore at the time of the wireline operations.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.DRILLING_MD_OUOM IS 'DRILLING MEASURED DEPTH OUOM: The original unit of measure for drilling measured depth.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  The date that the data in this row first came into effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.END_DATE IS 'END DATE: Date the wireline logging operation ended.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ENGINEER IS 'ENGINEER:  the identifier for the business associate (person) from the logging company who performedthe logging operation';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.EXPIRY_DATE IS 'EXPIRY DATE:  The date that the data in this row was no longer active or in effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.LOGGING_COMPANY IS 'BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.LOGGING_UNIT IS 'LOGGING UNIT:  Name or identifier of the unit that performed the logging';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.LOGGING_UNIT_BASE IS 'LOGGING UNIT BASE:  the home base city of the logging unit that was used.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.OBSERVER IS 'OBSERVER: Code identifying the person who witnessed the wireline operations.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.REMARK IS 'REMARK: Remarks or comments pertaining to the wireline logging job.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.START_DATE IS 'START DATE: Date the wireline logging operation began.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_JOB.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TOI_WLJ_ED_IDX ON PPDM.TLM_WELL_LOG_JOB
(END_DATE)
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


CREATE INDEX PPDM.TOI_WLJ_SD_IDX ON PPDM.TLM_WELL_LOG_JOB
(START_DATE)
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


CREATE INDEX PPDM.TWLJ_BA_IDX ON PPDM.TLM_WELL_LOG_JOB
(LOGGING_COMPANY)
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


CREATE INDEX PPDM.TWLJ_BA_IDX2 ON PPDM.TLM_WELL_LOG_JOB
(ENGINEER)
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


CREATE INDEX PPDM.TWLJ_OUOM_IDX ON PPDM.TLM_WELL_LOG_JOB
(CASING_SHOE_DEPTH_OUOM)
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


CREATE INDEX PPDM.TWLJ_OUOM_IDX1 ON PPDM.TLM_WELL_LOG_JOB
(DRILLING_MD_OUOM)
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


CREATE UNIQUE INDEX PPDM.TWLJ_PK ON PPDM.TLM_WELL_LOG_JOB
(UWI, SOURCE, JOB_ID)
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


CREATE INDEX PPDM.TWLJ_R_C_IDX ON PPDM.TLM_WELL_LOG_JOB
(LOGGING_UNIT_BASE)
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


CREATE INDEX PPDM.TWLJ_R_S_IDX ON PPDM.TLM_WELL_LOG_JOB
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


CREATE INDEX PPDM.TWLJ_W_IDX ON PPDM.TLM_WELL_LOG_JOB
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


CREATE OR REPLACE TRIGGER PPDM.TT_WELL_LOG_JOB 
  BEFORE INSERT OR UPDATE ON PPDM.TLM_WELL_LOG_JOB
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

END TT_WELL_LOG_JOB;
/


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


DROP SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


DROP SYNONYM EZ_TOOLS.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM EZ_TOOLS.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


DROP SYNONYM SDP.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM SDP.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


DROP SYNONYM SDP_APPL.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM SDP_APPL.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


DROP SYNONYM DATA_FINDER.TLM_WELL_LOG_JOB;

CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_WELL_LOG_JOB FOR PPDM.TLM_WELL_LOG_JOB;


ALTER TABLE PPDM.TLM_WELL_LOG_JOB ADD (
  CONSTRAINT TWLJ_PK
  PRIMARY KEY
  (UWI, SOURCE, JOB_ID)
  USING INDEX PPDM.TWLJ_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_LOG_JOB ADD (
  CONSTRAINT TWLJ_BA_FK 
  FOREIGN KEY (LOGGING_COMPANY) 
  REFERENCES PPDM.BUSINESS_ASSOCIATE (BUSINESS_ASSOCIATE)
  ENABLE VALIDATE,
  CONSTRAINT TWLJ_BA_FK2 
  FOREIGN KEY (ENGINEER) 
  REFERENCES PPDM.BUSINESS_ASSOCIATE (BUSINESS_ASSOCIATE)
  ENABLE VALIDATE,
  CONSTRAINT TWLJ_OUOM_FK 
  FOREIGN KEY (CASING_SHOE_DEPTH_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLJ_OUOM_FK1 
  FOREIGN KEY (DRILLING_MD_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLJ_R_C_FK 
  FOREIGN KEY (LOGGING_UNIT_BASE) 
  REFERENCES PPDM.R_CITY (CITY_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLJ_R_S_FK 
  FOREIGN KEY (SOURCE) 
  REFERENCES PPDM.R_SOURCE (SOURCE)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_JOB TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_JOB TO EZ_TOOLS;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO EZ_TOOLS_APPL;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO GEOFRAME;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO GEOWIZ;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO NGREWAL;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_JOB TO PPDM_RW;

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_JOB TO SDP;

GRANT SELECT ON PPDM.TLM_WELL_LOG_JOB TO WELL_LOG_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_JOB TO WELL_LOG_RW;
