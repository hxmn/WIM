--new table

ALTER TABLE PPDM.TLM_PDEN
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_PDEN CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_PDEN
(
  PDEN_ID                  VARCHAR2(40 BYTE)    NOT NULL,
  PDEN_TYPE                VARCHAR2(24 BYTE)    NOT NULL,
  SOURCE                   VARCHAR2(20 BYTE)    NOT NULL,
  ACTIVE_IND               VARCHAR2(1 BYTE),
  COUNTRY                  VARCHAR2(20 BYTE),
  CURRENT_OPERATOR         VARCHAR2(20 BYTE),
  CURRENT_PROD_STR_NAME    VARCHAR2(60 BYTE),
  CURRENT_STATUS_DATE      DATE,
  CURRENT_WELL_STR_NUMBER  VARCHAR2(20 BYTE),
  DISTRICT                 VARCHAR2(20 BYTE),
  EFFECTIVE_DATE           DATE,
  ENHANCED_RECOVERY_TYPE   VARCHAR2(20 BYTE),
  EXPIRY_DATE              DATE,
  FIELD_ID                 VARCHAR2(20 BYTE),
  GEOGRAPHIC_REGION        VARCHAR2(20 BYTE),
  GEOLOGIC_PROVINCE        VARCHAR2(20 BYTE),
  LAST_INJECTION_DATE      DATE,
  LAST_PRODUCTION_DATE     DATE,
  LAST_REPORTED_DATE       DATE,
  LOCATION_DESC            VARCHAR2(40 BYTE),
  LOCATION_DESC_TYPE       VARCHAR2(20 BYTE),
  ON_INJECTION_DATE        DATE,
  ON_PRODUCTION_DATE       DATE,
  PDEN_NAME                VARCHAR2(60 BYTE),
  PDEN_SHORT_NAME          VARCHAR2(30 BYTE),
  PDEN_STATUS              VARCHAR2(20 BYTE),
  PLOT_NAME                VARCHAR2(20 BYTE),
  PLOT_SYMBOL              VARCHAR2(20 BYTE),
  POOL_ID                  VARCHAR2(20 BYTE),
  PPDM_GUID                VARCHAR2(38 BYTE),
  PRIMARY_PRODUCT          VARCHAR2(20 BYTE),
  PRODUCTION_METHOD        VARCHAR2(20 BYTE),
  PROPRIETARY_IND          VARCHAR2(1 BYTE),
  PROVINCE_STATE           VARCHAR2(20 BYTE),
  REMARK                   VARCHAR2(2000 BYTE),
  STATE_OR_FEDERAL_WATERS  VARCHAR2(20 BYTE),
  STRAT_NAME_SET_ID        VARCHAR2(20 BYTE),
  STRAT_UNIT_ID            VARCHAR2(20 BYTE),
  STRING_SERIAL_NUMBER     VARCHAR2(20 BYTE),
  ROW_CHANGED_BY           VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE         DATE,
  ROW_CREATED_BY           VARCHAR2(30 BYTE),
  ROW_CREATED_DATE         DATE,
  ROW_QUALITY              VARCHAR2(20 BYTE)
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

COMMENT ON TABLE PPDM.TLM_PDEN IS 'PRODUCTION ENTITY:  This table represents any entity for which product  ion could be reported against.  This entity could be physical  installations such as a production well string, a spatial construct  such as lease or reservoir or it could be an organizational concept  such as business unit.      ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PDEN_ID IS 'PRODUCTION ENTITY IDENTIFIER: An identifier that is unique within a  specific production entity source and type.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PDEN_TYPE IS 'PRODUCTION ENTITY TYPE:  the type of production entity may be equal to one of the table names of the PDEN subtype tables, such as PDEN_WELL, PDEN_COUNTY or PDEN_FIELD. Validated by check constraint.';

COMMENT ON COLUMN PPDM.TLM_PDEN.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ACTIVE_IND IS 'ACTIVE INDICATOR:  a Y / N flag indicating whether the row of data is currently active. ';

COMMENT ON COLUMN PPDM.TLM_PDEN.COUNTRY IS 'REFERENCE COUNTRY: A reference table identifying a division of land, political nation or territory.  For example Austria, Canada, United Kingdom, USA, Venezula.';

COMMENT ON COLUMN PPDM.TLM_PDEN.CURRENT_OPERATOR IS 'BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. ';

COMMENT ON COLUMN PPDM.TLM_PDEN.CURRENT_PROD_STR_NAME IS 'CURRENT PROD STRING NAME: Name assigned to the production  string:  e.g., a special name or  one derived from the name of the property  with which the production  string is associated.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.CURRENT_STATUS_DATE IS 'CURRENT STATUS DATE: Date of the current status for the production  entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.CURRENT_WELL_STR_NUMBER IS 'CURRENT WELL STR NUMBER:   A modifying designator assigned  to a well production string and may  be associated with the  string name; e.g., Jones # 1; B-1.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.DISTRICT IS 'DISTRICT: The area designated as a district by a regulatory agency.  For example RR District 8A designated by the Texas Railroad Commission.';

COMMENT ON COLUMN PPDM.TLM_PDEN.EFFECTIVE_DATE IS 'EFFECTIVE DATE: The date on which a production entity becomes valid.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.ENHANCED_RECOVERY_TYPE IS 'ENHANCED RECOVERY TYPE: Type of method used for enhanced recovery of petroleum substances.';

COMMENT ON COLUMN PPDM.TLM_PDEN.EXPIRY_DATE IS 'EXPIRY DATE: The date that a production entity ceases to be valid.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.FIELD_ID IS 'FIELD IDENTIFIER: Unique identifier for the field.';

COMMENT ON COLUMN PPDM.TLM_PDEN.GEOGRAPHIC_REGION IS 'GEOGRAPHIC REGION: The unique identifier for the reference table.';

COMMENT ON COLUMN PPDM.TLM_PDEN.GEOLOGIC_PROVINCE IS 'GEOLOGIC PROVINCE: The unique identifier for the reference table.';

COMMENT ON COLUMN PPDM.TLM_PDEN.LAST_INJECTION_DATE IS 'LAST INJECTION DATE:  The date that injection volumes were last  reported for this entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.LAST_PRODUCTION_DATE IS 'LAST PRODUCTION DATE:  The date that production was last reported for   this entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.LAST_REPORTED_DATE IS 'LAST REPORTED DATE:  The date that a production report was last  submitted for this entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.LOCATION_DESC IS 'LOCATION DESCRIPTION:  The reported location of a production   reporting entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.LOCATION_DESC_TYPE IS 'LOCATION DESCRIPTION TYPE: The type of location description.  For example -  Dominion Land Survey (DLS), Congressional, or NTS.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ON_INJECTION_DATE IS 'ON INJECTION DATE:  The date that injection was first reported for  this entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.ON_PRODUCTION_DATE IS 'ON PRODUCTION DATE:  The date that production was first reported for  this entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PDEN_NAME IS 'PDEN NAME: Name assigned to the production entity. This may be the  legal or registered name as it appears on a permit or a given name  assigned by the operator.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PDEN_SHORT_NAME IS 'PDEN SHORT NAME: Common short name used for the production entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PDEN_STATUS IS 'PDEN STATUS: The operational state of the production entity.';

COMMENT ON COLUMN PPDM.TLM_PDEN.PLOT_NAME IS 'PLOT NAME: Name alias used when plotting the production entity on a  map.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PLOT_SYMBOL IS 'ID: The unique identifier for the reference table.';

COMMENT ON COLUMN PPDM.TLM_PDEN.POOL_ID IS 'POOL IDENTIFIER:  Number or code uniquely identifying the pool.';

COMMENT ON COLUMN PPDM.TLM_PDEN.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_PDEN.PRIMARY_PRODUCT IS 'PRODUCT TYPE:  A reference table identifying the type of product (fluid) such as GAS, OIL, WATER, NGL, etc. Includes the less common products like STEAM, METHANE, BUTANE, HELIUM, etc.';

COMMENT ON COLUMN PPDM.TLM_PDEN.PRODUCTION_METHOD IS 'PRODUCTION_METHOD: REFERENCE PRODUCTION METHOD:  The method of product ion.  For example swabbing, flowing, pumping or gas lift.';

COMMENT ON COLUMN PPDM.TLM_PDEN.PROPRIETARY_IND IS 'PROPRIETARY INDICATOR: Indicates whether data is avaiable for public  distribution or viewing.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.PROVINCE_STATE IS 'PROVINCE STATE:  A reference table identifying valid states, provinces or other political subdivisions of countries.  For example, Colorado, Texas in the US, Alberta in Canada';

COMMENT ON COLUMN PPDM.TLM_PDEN.REMARK IS 'REMARK:  Comments about the production entity.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.STATE_OR_FEDERAL_WATERS IS 'STATE OR FEDERAL WATERS:   Code indicating if the well is  producing in state or federal  waters.    ';

COMMENT ON COLUMN PPDM.TLM_PDEN.STRAT_NAME_SET_ID IS 'STRAT NAME SET IDENTIFIER:  Unique identifier for the stratigraphic name set.  A stratigraphic name set is an unordered  collection of   stratigraphic units, that may be in use for a Lexicon,  a geographic area, a project, a company etc.';

COMMENT ON COLUMN PPDM.TLM_PDEN.STRAT_UNIT_ID IS 'STRATIGRAPHIC UNIT IDENTIFIER:  unique identifier for the stratigraphic unit.';

COMMENT ON COLUMN PPDM.TLM_PDEN.STRING_SERIAL_NUMBER IS 'STRING SERIAL NUMBER:   Number assigned by a regulatory   agency (usually) to identify a producing string.     ';

COMMENT ON COLUMN PPDM.TLM_PDEN.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_PDEN.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TLM_PDEN_BA_IDX ON PPDM.TLM_PDEN
(CURRENT_OPERATOR)
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


CREATE INDEX PPDM.TLM_PDEN_FLD_IDX ON PPDM.TLM_PDEN
(FIELD_ID)
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


CREATE UNIQUE INDEX PPDM.TLM_PDEN_PK ON PPDM.TLM_PDEN
(PDEN_ID, PDEN_TYPE, SOURCE)
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


CREATE INDEX PPDM.TLM_PDEN_PL_IDX ON PPDM.TLM_PDEN
(POOL_ID)
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


CREATE INDEX PPDM.TLM_PDEN_PROD_IDX ON PPDM.TLM_PDEN
(PRIMARY_PRODUCT)
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


CREATE INDEX PPDM.TLM_PDEN_R_C1_IDX ON PPDM.TLM_PDEN
(COUNTRY)
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


CREATE INDEX PPDM.TLM_PDEN_R_D_IDX ON PPDM.TLM_PDEN
(DISTRICT)
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


CREATE INDEX PPDM.TLM_PDEN_R_ERT_IDX ON PPDM.TLM_PDEN
(ENHANCED_RECOVERY_TYPE)
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


CREATE INDEX PPDM.TLM_PDEN_R_GP_IDX ON PPDM.TLM_PDEN
(GEOLOGIC_PROVINCE)
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


CREATE INDEX PPDM.TLM_PDEN_R_GR_IDX ON PPDM.TLM_PDEN
(GEOGRAPHIC_REGION)
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


CREATE INDEX PPDM.TLM_PDEN_R_LDT_IDX ON PPDM.TLM_PDEN
(LOCATION_DESC_TYPE)
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


CREATE INDEX PPDM.TLM_PDEN_R_PM1_IDX ON PPDM.TLM_PDEN
(PRODUCTION_METHOD)
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


CREATE INDEX PPDM.TLM_PDEN_R_PS1_IDX ON PPDM.TLM_PDEN
(PLOT_SYMBOL)
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


CREATE INDEX PPDM.TLM_PDEN_R_PS3_IDX ON PPDM.TLM_PDEN
(COUNTRY, PROVINCE_STATE)
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


CREATE INDEX PPDM.TLM_PDEN_R_PS_IDX ON PPDM.TLM_PDEN
(PDEN_STATUS)
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


CREATE INDEX PPDM.TLM_PDEN_R_S_IDX ON PPDM.TLM_PDEN
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


CREATE INDEX PPDM.TLM_PDEN_STU_IDX ON PPDM.TLM_PDEN
(STRAT_NAME_SET_ID, STRAT_UNIT_ID)
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

ALTER TABLE PPDM.TLM_PDEN ADD (
  CONSTRAINT TLM_PDEN_PK
  PRIMARY KEY
  (PDEN_ID, PDEN_TYPE, SOURCE)
  USING INDEX PPDM.TLM_PDEN_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_PDEN ADD (
  CONSTRAINT TLM_PDEN_BA_FK 
  FOREIGN KEY (CURRENT_OPERATOR) 
  REFERENCES PPDM.BUSINESS_ASSOCIATE (BUSINESS_ASSOCIATE)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_FLD_FK 
  FOREIGN KEY (FIELD_ID) 
  REFERENCES PPDM.FIELD (FIELD_ID)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_PROD_FK 
  FOREIGN KEY (PRIMARY_PRODUCT) 
  REFERENCES PPDM.PRODUCT (PRODUCT_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_ERT_FK 
  FOREIGN KEY (ENHANCED_RECOVERY_TYPE) 
  REFERENCES PPDM.R_ENHANCED_REC_TYPE (ENHANCED_RECOVERY_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_GR_FK 
  FOREIGN KEY (GEOGRAPHIC_REGION) 
  REFERENCES PPDM.R_GEOGRAPHIC_REGION (GEOGRAPHIC_REGION)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_LDT_FK 
  FOREIGN KEY (LOCATION_DESC_TYPE) 
  REFERENCES PPDM.R_LOCATION_DESC_TYPE (LOCATION_DESC_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_PM1_FK 
  FOREIGN KEY (PRODUCTION_METHOD) 
  REFERENCES PPDM.R_PRODUCTION_METHOD (PRODUCTION_METHOD)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_PS_FK 
  FOREIGN KEY (PDEN_STATUS) 
  REFERENCES PPDM.R_PDEN_STATUS (PDEN_STATUS)
  ENABLE VALIDATE,
  CONSTRAINT TLM_PDEN_R_S_FK 
  FOREIGN KEY (SOURCE) 
  REFERENCES PPDM.R_SOURCE (SOURCE)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_PDEN TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_PDEN TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_PDEN TO PPDM_ADMIN;

GRANT SELECT ON PPDM.TLM_PDEN TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_PDEN TO PPDM_RW;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_PDEN TO WIM;


--synonyms
DROP SYNONYM DATA_FINDER.TLM_PDEN;
CREATE OR REPLACE SYNONYM DATA_FINDER.TLM_PDEN FOR PPDM.TLM_PDEN;


DROP SYNONYM EDIOS_ADMIN.TLM_PDEN;
CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_PDEN FOR PPDM.TLM_PDEN;


DROP SYNONYM PPDM_ADMIN.TLM_PDEN;
CREATE OR REPLACE SYNONYM PPDM_ADMIN.TLM_PDEN FOR PPDM.TLM_PDEN;

DROP SYNONYM WIM.TLM_PDEN;
CREATE OR REPLACE SYNONYM WIM.TLM_PDEN FOR PPDM.TLM_PDEN;

