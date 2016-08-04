ALTER TABLE PPDM.TLM_WELL_LOG_CURVE
 DROP PRIMARY KEY CASCADE;

DROP TABLE PPDM.TLM_WELL_LOG_CURVE CASCADE CONSTRAINTS;

CREATE TABLE PPDM.TLM_WELL_LOG_CURVE
(
  UWI                     VARCHAR2(20 BYTE)     NOT NULL,
  CURVE_ID                VARCHAR2(20 BYTE)     NOT NULL,
  ACQUIRED_FOR_BA_ID      VARCHAR2(20 BYTE),
  ACTIVE_IND              VARCHAR2(1 BYTE),
  API_CODE_SYSTEM         VARCHAR2(20 BYTE),
  API_CURVE_CLASS         NUMBER(2),
  API_CURVE_CODE          NUMBER(3),
  API_CURVE_MODIFIER      NUMBER(1),
  API_LOG_CODE            NUMBER(2),
  BASE_CURVE_IND          VARCHAR2(1 BYTE),
  BYPASS_IND              VARCHAR2(1 BYTE),
  CASED_HOLE_IND          VARCHAR2(1 BYTE),
  COMPOSITE_IND           VARCHAR2(1 BYTE),
  CURVE_OUOM              VARCHAR2(20 BYTE),
  CURVE_QUALITY           VARCHAR2(20 BYTE),
  DICTIONARY_ID           VARCHAR2(20 BYTE),
  DICT_CURVE_ID           VARCHAR2(20 BYTE),
  EFFECTIVE_DATE          DATE,
  EXPIRY_DATE             DATE,
  EXPLICIT_INDEX_IND      VARCHAR2(1 BYTE),
  FIRST_GOOD_VALUE        NUMBER,
  FIRST_GOOD_VALUE_INDEX  NUMBER,
  FRAME_ID                VARCHAR2(20 BYTE),
  GOOD_VALUE_TYPE         VARCHAR2(20 BYTE),
  INDEX_CURVE_ID          VARCHAR2(20 BYTE),
  INDEX_OUOM              VARCHAR2(20 BYTE),
  INDEX_UOM               VARCHAR2(20 BYTE),
  JOB_ID                  VARCHAR2(20 BYTE),
  LAST_GOOD_VALUE         NUMBER,
  LAST_GOOD_VALUE_INDEX   NUMBER,
  LOG_TOOL_PASS_NO        NUMBER(2),
  LOG_TOOL_TYPE           VARCHAR2(20 BYTE),
  MAX_INDEX               NUMBER,
  MAX_VALUE               NUMBER,
  MAX_VALUE_INDEX         NUMBER,
  MEAN_VALUE              NUMBER,
  MEAN_VALUE_STD_DEV      NUMBER,
  MIN_INDEX               NUMBER,
  MIN_VALUE               NUMBER,
  MIN_VALUE_INDEX         NUMBER,
  MULTIPLE_INDEX_IND      VARCHAR2(1 BYTE),
  MWD_IND                 VARCHAR2(1 BYTE),
  NULL_COUNT              NUMBER,
  NULL_REPRESENTATION     VARCHAR2(20 BYTE),
  PPDM_GUID               VARCHAR2(38 BYTE),
  PRIMARY_INDEX_TYPE      VARCHAR2(20 BYTE),
  REMARK                  VARCHAR2(2000 BYTE),
  REPORTED_MNEMONIC       VARCHAR2(255 BYTE),
  REPORTED_UNIT_MNEMONIC  VARCHAR2(255 BYTE),
  SOURCE                  VARCHAR2(20 BYTE),
  TRIP_OBS_NO             NUMBER(8),
  VALUE_COUNT             NUMBER,
  WELL_LOG_ID             VARCHAR2(20 BYTE),
  WELL_LOG_JOB_SOURCE     VARCHAR2(20 BYTE),
  WELL_LOG_SOURCE         VARCHAR2(20 BYTE),
  ROW_CHANGED_BY          VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE        DATE,
  ROW_CREATED_BY          VARCHAR2(30 BYTE),
  ROW_CREATED_DATE        DATE,
  ROW_QUALITY             VARCHAR2(20 BYTE),
  CURVE_SEQ_NO            NUMBER,
  CURVE_OUTPUT            VARCHAR2(30 BYTE),
  REPORTED_DESC           VARCHAR2(1024 BYTE)
)
TABLESPACE PPDM_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             10M
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

COMMENT ON TABLE PPDM.TLM_WELL_LOG_CURVE IS 'WELL LOG CURVE: The Well Log Curve table contains information about the types of log curves or traces associated with a logging pass. Each pass of a logging tool string may produce many log curves since there are many logging tools on the   tool string.     Also know as a Channel, a Curve is a set of values with a corresponding index (e.g. depth or time) for each value.  In digital well log interchange formats, a Curve may be associated with only one Frame.  The simplest of curves contains one value for each index value of depth or time.  Curves can, however, be very complex
entities, containing multi-dimensional arrays of data values in each Frame.
';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.UWI IS 'UNIQUE WELL IDENTIFIER: A unique name, code or number designated as the primary key for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.CURVE_ID IS 'CURVE IDENTIFIER: Unique identification number assigned to the curve or trace.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ACQUIRED_FOR_BA_ID IS 'ACQUIRED FOR BUSINESS ASSOCIATE ID:  Unique identifier for the business associate who ordered the acquisition of the well log.  Usually the operator of the well.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ACTIVE_IND IS 'ACTIVE INDICATOR:  A Y/N flag indicating that this row of data is presently active. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.API_CODE_SYSTEM IS 'API LOG CODE SYSTEM:  A system devised by the American Petroleum Institude published in API bulletin D9 (1973)and D9a (1981) used to classify curves. Often found on historic logs, but rarely used in current operations.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.API_CURVE_CLASS IS 'API LOG CODE SYSTEM:  A system devised by the American Petroleum Institude published in API bulletin D9 (1973)and D9a (1981) used to classify curves. Often found on historic logs, but rarely used in current operations.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.API_CURVE_CODE IS 'API LOG CODE SYSTEM:  A system devised by the American Petroleum Institude published in API bulletin D9 (1973)and D9a (1981) used to classify curves. Often found on historic logs, but rarely used in current operations.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.API_CURVE_MODIFIER IS 'API LOG CODE SYSTEM:  A system devised by the American Petroleum Institude published in API bulletin D9 (1973)and D9a (1981) used to classify curves. Often found on historic logs, but rarely used in current operations.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.API_LOG_CODE IS 'API LOG CODE SYSTEM:  A system devised by the American Petroleum Institude published in API bulletin D9 (1973)and D9a (1981) used to classify curves. Often found on historic logs, but rarely used in current operations.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.BASE_CURVE_IND IS 'BASE CURVE INDICATOR:  a Y/N flag that indicates when a curve is a base curve.  These curves, generated during a particular logging pass, are used as a depth benchmark for all other curves.
';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.BYPASS_IND IS 'BYPASS INDICATOR:  A Y/N flag indicating that this well log was acquired during a bypass operation.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.CASED_HOLE_IND IS 'CASED HOLE INDICATOR:  A Y/N flag indicating that this log was acquired in a cased hole environment. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.COMPOSITE_IND IS 'COMPOSITE INDICATOR: a Y/N flag indicating that this curve is a composite of curves taken during multiple passes or combined through other types of processing. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.CURVE_OUOM IS 'CURVE OUOM:  Identifies the original unit of measure associated with the log curve. For example, resistivity curves are measured in ohms/meters    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.CURVE_QUALITY IS 'CURVE QUALITY:  the overall quality of the log curve, such as good, verification passed, poor etc. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.DICTIONARY_ID IS 'WELL LOG DICTIONARY:  The dictionary contains a set of curve names, property names and parameters that are used by a well logging contracter during a specified period of time.  At any given time, a contractor may have one or more dictionaries in use. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.DICT_CURVE_ID IS 'DICTIONARY CURVE IDENTIFIER; unique identifier for a curve that is shown in a dictionary; provides a standard list of curve names. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.EFFECTIVE_DATE IS 'EFFECTIVE DATE:  The date that the data in this row first came into effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.EXPIRY_DATE IS 'EXPIRY DATE:  The date that the data in this row was no longer active or in effect.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.EXPLICIT_INDEX_IND IS 'EXPLICIT INDEX INDICATOR:  A Y/N flag for which  Y means that the index is included with the curve,  N means the index is implicit and must be calculated or collected from an index curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.FIRST_GOOD_VALUE IS 'FIRST GOOD VALUE:  the first good value recorded on the curve.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.FIRST_GOOD_VALUE_INDEX IS 'FIRST GOOD VALUE INDEX:  the index at which the first good value was recorded on the curve.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.FRAME_ID IS 'INDEX IDENTIFIER:  Unique identifier for the occurrance of the well log index or frame. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.GOOD_VALUE_TYPE IS ' GOOD VALUE TYPE:   A list of valid types of good values that are used to indicate the top and base of useful data gathered during logging operations.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.INDEX_CURVE_ID IS 'INDEX CURVE IDENTIFIER:  Use this column to identify the curve that contains the index values for this curve, used when the index is implicit. If the index is explicit, the index values are included with the curve (the curve consists of Index - value pairs).  If the index is implicit, the index values must be calculated with the interval information in the header as the curve only contains the values.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.INDEX_OUOM IS 'ORIGINAL UNIT OF MEASURE';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.INDEX_UOM IS 'INDEX UNIT OF MEASURE: the unit of measure nominally used for the well log curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.JOB_ID IS 'JOB IDENTIFIER: Unique identifier assigned to the wireline log job.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.LAST_GOOD_VALUE IS 'LAST GOOD VALUE:  the last good value recorded during logging. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.LAST_GOOD_VALUE_INDEX IS 'LAST GOOD VALUE INDEX:  the index at which the last good value was recorded on the curve.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.LOG_TOOL_PASS_NO IS 'LOG TOOL PASS NUMBER:  the pass number assigned to the well logging pass. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.LOG_TOOL_TYPE IS 'LOG TOOLTYPE: A unique identifier for the type of logging tool.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MAX_INDEX IS 'MAX INDEX:  the maximum index at which values were measured for the curve,  In many cases the index will be the last measured depth; could also be time.      ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MAX_VALUE IS 'MAXIMUM VALUE:  the value of the maximum reading on this curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MAX_VALUE_INDEX IS 'MAXIMUM VALUE INDEX The index of the first good value in the curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MEAN_VALUE IS 'MEAN VALUE:  the mean average of the values on the curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MEAN_VALUE_STD_DEV IS 'MEAN VALUE STANDARD DEVIATION:  The standard deviation of the mean value.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MIN_INDEX IS 'MIN INDEX: the minimum index at which values were measured for the curve,  In many cases the index will be the first measured depth; could also be time.  ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MIN_VALUE IS 'MINIMUM VALUE: the value of the minimum reading on this curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MIN_VALUE_INDEX IS 'MINIMUM  VALUE INDEX : the index of the minimum  value on the curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MULTIPLE_INDEX_IND IS 'MULTIPLE INDEXES INDICATOR:  a Y/N flag indicating that this curve contains multiply indexed values. In this case, each index is stored in an axis (WELL LOG CURVE AXIS)
';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.MWD_IND IS 'MEASURED WHILE DRILLING INDICATOR:  A Y/N flag indicating that this log was acquired during active drilling operations. Acquired while the bit was in the hole. Could be logged while drilling (LWD) or measured while drilling (MWD).';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.NULL_COUNT IS 'NULL COUNT:  The number of nulls found on this curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.NULL_REPRESENTATION IS 'NULL VALUE REPRESENTATION:  the value in the curve that is used to represent NULL readings on the curve. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.PPDM_GUID IS 'PPDM GUID:  This value may be used to provide a global unique identifier for this row of data.  If used, optional PPDM NOT NULL constraints should be created.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.PRIMARY_INDEX_TYPE IS ' LOG INDEX TYPE:  The type of measurement index for the log, such as measured depth  or time.  In this case, the index as reported on the log curve header. Use this column in the case where the WELL LOG CURVE INDEX table is not used. In this case, the primary index is the index used in the well curve digit information. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.REMARK IS 'REMARK: Narrative remarks about this row of data.    ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.REPORTED_MNEMONIC IS 'REPORTED MNEMONIC: the log curve mnemonic as reported in the log curve data; this value is unvalidated and reported as is.  Validated version of the curve is found through the CURVE ID. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.REPORTED_UNIT_MNEMONIC IS 'REPORTED UNIT MNEMONIC:  The reported units that the curve was captured in. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.TRIP_OBS_NO IS 'TRIP OBSERVATION NUMBER:  a unique number assigned to the data related to a well log trip.  If unique run numbers exist, they may be used if desired.  If not, a surrogate component is created. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.VALUE_COUNT IS 'VALUE COUNT:  the total number of values found on the well log curve including NULL values. the count of NULL values is stored in NULL_COUNT.   Use the value count to calculate the sample spacing as (BASE MD - TOP MD) / (VALUE COUNT - 1). ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.WELL_LOG_ID IS 'WELL LOG IDENTIFIER:  Unique identifier for the well log. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.WELL_LOG_JOB_SOURCE IS 'SOURCE: The individual, company, state, or government agency designated as the source of information for this row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.WELL_LOG_SOURCE IS 'WELL LOG SOURCE:  the source of the well log that has been referenced. ';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ROW_CHANGED_BY IS 'ROW CHANGED BY: Application login id of the user who last changed the row.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ROW_CHANGED_DATE IS 'ROW CHANGED DATE: System date of the last time the row was changed.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ROW_CREATED_BY IS 'ROW CREATED BY:  System user who created this row of data.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ROW_CREATED_DATE IS 'ROW CREATED DATE: Date that the row was created on.';

COMMENT ON COLUMN PPDM.TLM_WELL_LOG_CURVE.ROW_QUALITY IS 'PPDM ROW QUALILTY:  A set of values indicating the quality of data in this row, usually with reference to the method or procedures used to load the data, although other types of quality reference are permitted.';



CREATE INDEX PPDM.TWLC_BA_IDX ON PPDM.TLM_WELL_LOG_CURVE
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


CREATE INDEX PPDM.TWLC_OUOM_IDX ON PPDM.TLM_WELL_LOG_CURVE
(CURVE_OUOM)
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


CREATE INDEX PPDM.TWLC_OUOM_IDX1 ON PPDM.TLM_WELL_LOG_CURVE
(INDEX_OUOM)
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


CREATE UNIQUE INDEX PPDM.TWLC_PK ON PPDM.TLM_WELL_LOG_CURVE
(UWI, CURVE_ID)
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


CREATE INDEX PPDM.TWLC_R_ALS_IDX ON PPDM.TLM_WELL_LOG_CURVE
(API_CODE_SYSTEM)
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


CREATE INDEX PPDM.TWLC_R_LGVT_IDX ON PPDM.TLM_WELL_LOG_CURVE
(GOOD_VALUE_TYPE)
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


CREATE INDEX PPDM.TWLC_R_LIX_IDX ON PPDM.TLM_WELL_LOG_CURVE
(PRIMARY_INDEX_TYPE)
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


CREATE INDEX PPDM.TWLC_R_LTT_IDX ON PPDM.TLM_WELL_LOG_CURVE
(LOG_TOOL_TYPE)
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


CREATE INDEX PPDM.TWLC_R_Q_IDX ON PPDM.TLM_WELL_LOG_CURVE
(CURVE_QUALITY)
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


CREATE INDEX PPDM.TWLC_UOM_IDX ON PPDM.TLM_WELL_LOG_CURVE
(INDEX_UOM)
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


CREATE INDEX PPDM.TWLC_WLCF_IDX ON PPDM.TLM_WELL_LOG_CURVE
(UWI, WELL_LOG_ID, WELL_LOG_SOURCE, FRAME_ID)
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


CREATE INDEX PPDM.TWLC_WLC_IDX ON PPDM.TLM_WELL_LOG_CURVE
(UWI, INDEX_CURVE_ID)
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


CREATE INDEX PPDM.TWLC_WLDCV_IDX ON PPDM.TLM_WELL_LOG_CURVE
(DICTIONARY_ID, DICT_CURVE_ID)
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


CREATE INDEX PPDM.TWLC_WLPS_IDX ON PPDM.TLM_WELL_LOG_CURVE
(UWI, WELL_LOG_JOB_SOURCE, JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO)
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


CREATE INDEX PPDM.TWLC_WLT_IDX ON PPDM.TLM_WELL_LOG_CURVE
(UWI, WELL_LOG_JOB_SOURCE, JOB_ID, TRIP_OBS_NO)
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


CREATE INDEX PPDM.TWLC_WL_IDX ON PPDM.TLM_WELL_LOG_CURVE
(UWI, WELL_LOG_ID, WELL_LOG_SOURCE)
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


CREATE INDEX PPDM.TWLC_W_IDX ON PPDM.TLM_WELL_LOG_CURVE
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


CREATE OR REPLACE TRIGGER PPDM.TT_WELL_LOG_CURVE 
  BEFORE INSERT OR UPDATE ON PPDM.TLM_WELL_LOG_CURVE
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

END T_WELL_LOG_CURVE;
/


DROP SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.TLM_WELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


DROP SYNONYM EZ_TOOLS.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM EZ_TOOLS.TLM_WELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


DROP SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM EZ_TOOLS_APPL.TLM_WELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


DROP SYNONYM SDP.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM SDP.TLM_WELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


DROP SYNONYM SDP_APPL.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM SDP_APPL.TLM_WELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


DROP SYNONYM DATA_FINDER.TLM_WELL_LOG_CURVE;

CREATE OR REPLACE SYNONYM DATA_FINDER.VWELL_LOG_CURVE FOR PPDM.TLM_WELL_LOG_CURVE;


ALTER TABLE PPDM.TLM_WELL_LOG_CURVE ADD (
  CONSTRAINT TWLC_PK
  PRIMARY KEY
  (UWI, CURVE_ID)
  USING INDEX PPDM.TWLC_PK
  ENABLE VALIDATE);

ALTER TABLE PPDM.TLM_WELL_LOG_CURVE ADD (
  CONSTRAINT TWLC_BA_FK 
  FOREIGN KEY (ACQUIRED_FOR_BA_ID) 
  REFERENCES PPDM.BUSINESS_ASSOCIATE (BUSINESS_ASSOCIATE)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_OUOM_FK 
  FOREIGN KEY (CURVE_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_OUOM_FK1 
  FOREIGN KEY (INDEX_OUOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_R_ALS_FK 
  FOREIGN KEY (API_CODE_SYSTEM) 
  REFERENCES PPDM.R_API_LOG_SYSTEM (API_CODE_SYSTEM)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_R_LGVT_FK 
  FOREIGN KEY (GOOD_VALUE_TYPE) 
  REFERENCES PPDM.R_LOG_GOOD_VALUE_TYPE (GOOD_VALUE_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_R_LIX_FK 
  FOREIGN KEY (PRIMARY_INDEX_TYPE) 
  REFERENCES PPDM.R_LOG_INDEX_TYPE (INDEX_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_R_LTT_FK 
  FOREIGN KEY (LOG_TOOL_TYPE) 
  REFERENCES PPDM.R_LOG_TOOL_TYPE (LOG_TOOL_TYPE)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_R_Q_FK 
  FOREIGN KEY (CURVE_QUALITY) 
  REFERENCES PPDM.R_QUALITY (QUALITY)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_UOM_FK 
  FOREIGN KEY (INDEX_UOM) 
  REFERENCES PPDM.PPDM_UNIT_OF_MEASURE (UOM_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WLCF_FK 
  FOREIGN KEY (UWI, WELL_LOG_ID, WELL_LOG_SOURCE, FRAME_ID) 
  REFERENCES PPDM.WELL_LOG_CURVE_FRAME (UWI,WELL_LOG_ID,WELL_LOG_SOURCE,FRAME_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WLC_FK 
  FOREIGN KEY (UWI, INDEX_CURVE_ID) 
  REFERENCES PPDM.WELL_LOG_CURVE (UWI,CURVE_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WLDCV_FK 
  FOREIGN KEY (DICTIONARY_ID, DICT_CURVE_ID) 
  REFERENCES PPDM.WELL_LOG_DICT_CURVE (DICTIONARY_ID,DICT_CURVE_ID)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WLPS_FK 
  FOREIGN KEY (UWI, WELL_LOG_JOB_SOURCE, JOB_ID, TRIP_OBS_NO, LOG_TOOL_PASS_NO) 
  REFERENCES PPDM.WELL_LOG_PASS (UWI,SOURCE,JOB_ID,TRIP_OBS_NO,LOG_TOOL_PASS_NO)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WLT_FK 
  FOREIGN KEY (UWI, WELL_LOG_JOB_SOURCE, JOB_ID, TRIP_OBS_NO) 
  REFERENCES PPDM.WELL_LOG_TRIP (UWI,SOURCE,JOB_ID,TRIP_OBS_NO)
  ENABLE VALIDATE,
  CONSTRAINT TWLC_WL_FK 
  FOREIGN KEY (UWI, WELL_LOG_ID, WELL_LOG_SOURCE) 
  REFERENCES PPDM.WELL_LOG (UWI,WELL_LOG_ID,SOURCE)
  ENABLE VALIDATE);

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_CURVE TO DATMANGEO_ADMIN;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO EDIOS_ADMIN;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_CURVE TO EZ_TOOLS;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO EZ_TOOLS_APPL;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO GEOFRAME;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO GEOWIZ;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO GEOWIZ_SURVEY;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_CURVE TO PPDM_RW;

GRANT INSERT, SELECT ON PPDM.TLM_WELL_LOG_CURVE TO SDP;

GRANT SELECT ON PPDM.TLM_WELL_LOG_CURVE TO WELL_LOG_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.TLM_WELL_LOG_CURVE TO WELL_LOG_RW;
