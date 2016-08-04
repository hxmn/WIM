ALTER TABLE PPDM.TLM_WELL_CORE_REMARK
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_CORE_REMARK CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_CORE_REMARK
(
  UWI               VARCHAR2(20 BYTE)           NOT NULL,
  SOURCE            VARCHAR2(20 BYTE)           NOT NULL,
  CORE_ID           VARCHAR2(20 BYTE)           NOT NULL,
  REMARK_OBS_NO     NUMBER(8)                   NOT NULL,
  ACTIVE_IND        VARCHAR2(1 BYTE),
  EFFECTIVE_DATE    DATE,
  EXPIRY_DATE       DATE,
  PPDM_GUID         VARCHAR2(38 BYTE),
  REMARK            VARCHAR2(2000 BYTE),
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

COMMENT ON TABLE PPDM.TLM_WELL_CORE_REMARK IS 'WELL CORE REMARK: The Well Core Remark table contains narrative remarks pertaining to a core.  Comments could include a narrative describing the conventional and/or sidewall coring operations.      ';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.CORE_ID IS 'CORE ID:  Unique identifier for a well core';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.REMARK_OBS_NO IS 'REMARK OBSERVATION NUMBER: Observation number defining the uniqueness for each remark.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y/N flag indicating whether this row of data is currently active or valid.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  The date that the data in this row first came into effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.EXPIRY_DATE IS 'EXPIRY DATE:  The date that the data in this row was no longer active or in effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.REMARK IS 'REMARK: Narrative describing the conventional and/or sidewall coring operations.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_CORE_REMARK.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE UNIQUE INDEX PPDM.TWCRM_PK ON PPDM.TLM_WELL_CORE_REMARK
(UWI, SOURCE, CORE_ID, REMARK_OBS_NO)
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


CREATE INDEX PPDM.TWCRM_WCR_IDX ON PPDM.TLM_WELL_CORE_REMARK
(UWI, SOURCE, CORE_ID)
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


DROP SYNONYM DATA_FINDER.TLM_WELL_CORE_REMARK;

CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_WELL_CORE_REMARK FOR PPDM.TLM_WELL_CORE_REMARK;


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_CORE_REMARK;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_CORE_REMARK FOR PPDM.TLM_WELL_CORE_REMARK;


ALTER TABLE PPDM.TLM_WELL_CORE_REMARK ADD (
  CONSTRAINT TWCRM_PK
  PRIMARY KEY
  (UWI, SOURCE, CORE_ID, REMARK_OBS_NO)
  USING INDEX PPDM.TWCRM_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_CORE_REMARK ADD (
  CONSTRAINT TWCRM_WCR_FK 
  FOREIGN KEY (UWI, SOURCE, CORE_ID) 
  REFERENCES PPDM.TLM_WELL_CORE (UWI,SOURCE,CORE_ID)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_CORE_REMARK TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_CORE_REMARK TO EDIOS_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_CORE_REMARK TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_CORE_REMARK TO PPDM_RW;
