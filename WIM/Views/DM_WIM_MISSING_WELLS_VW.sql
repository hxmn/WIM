
DROP VIEW WIM.WIM_DM_MISSING_WELLS_VW;

CREATE OR REPLACE FORCE VIEW WIM.WIM_DM_MISSING_WELLS_VW
(
  UWI
  , WELL_NAME
  , ACTIVE_IND
  , COUNTRY
  , COUNTRY_NAME
  , CURRENT_STATUS
  , IPL_UWI_LOCAL
  , PRIMARY_SOURCE
  , ROW_CHANGED_BY
  , ROW_CHANGED_DATE
  , ROW_CREATED_BY
  , ROW_CREATED_DATE
)
AS

SELECT W.UWI, W.WELL_NAME, W.ACTIVE_IND, W.COUNTRY, C.LONG_NAME
       , W.CURRENT_STATUS, W.IPL_UWI_LOCAL, W.PRIMARY_SOURCE
       , W.ROW_CHANGED_BY, W.ROW_CHANGED_DATE, W.ROW_CREATED_BY, W.ROW_CREATED_DATE
  FROM PPDM.WELL W
       LEFT JOIN PPDM.R_COUNTRY C ON W.COUNTRY = C.COUNTRY
 WHERE UWI IN
         ( SELECT UWI
             FROM PPDM.WELL
           WHERE  -- return all CWS (100tlm) and TLM GDM (700tlme) wells
                  UWI IN ( -- wells with 100 or 700 versions
                           SELECT DISTINCT UWI
                             FROM PPDM.WELL_VERSION
                            WHERE ACTIVE_IND = 'Y'
                                  AND SOURCE IN ('100TLM', '700TLME')

                           UNION

                           -- wells that had a 100/700 version moved to another well
                           -- eg. a 450/500 IHS well that had a 700 version
                           --    with the 700 version move, the roll-up of info has changed the record in the well table
                           --    ... use this to get the well info update to DM
                           SELECT DISTINCT WELL_ALIAS AS UWI
                             FROM PPDM.WELL_ALIAS
                            WHERE UPPER(REASON_TYPE) = UPPER('Move')
                                  AND ACTIVE_IND = 'Y'
                                  AND SOURCE IN ('100TLM', '700TLME')
                                  AND UPPER(ALIAS_TYPE) = UPPER('TLM_ID')
                         )
                  AND ACTIVE_IND = 'Y'

                  MINUS

                  -- wells in DM
                  SELECT TLM_WELL_ID AS UWI
                    FROM DM_WELLS@DM
                   WHERE NVL(DISABLED, 'N') = 'N'
         )
;


GRANT SELECT ON WIM.WIM_DM_MISSING_WELLS_VW TO PPDM_ADMIN_RO;
GRANT SELECT ON WIM.WIM_DM_MISSING_WELLS_VW TO WIM_RO;

