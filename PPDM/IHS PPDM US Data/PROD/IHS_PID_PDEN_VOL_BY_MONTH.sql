DROP VIEW PPDM.IHS_PID_PDEN_VOL_BY_MONTH;

/* Formatted on 4/2/2013 7:37:41 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_PID_PDEN_VOL_BY_MONTH
(
   ENTITY,
   PDEN_TYPE,
   SOURCE,
   ACTIVE_IND,
   FLUID,
   YEAR,
   CUM_PRIOR,
   JAN,
   FEB,
   MAR,
   APR,
   MAY,
   JUN,
   JUL,
   AUG,
   SEP,
   OCT,
   NOV,
   DEC,
   YEAR_TO_DATE,
   PI_VOLUME_UNIT,
   PI_VOLUME_OUOM,
   ROW_CHANGED_BY,
   PI_REC_UPD_DATE,
   PI_USER_ID,
   PI_ROW_ADD_DATE
)
AS
   SELECT 
         WV.uwi AS "ENTITY",
          P.ENTITY_TYPE,
          '450PID' AS SOURCE,
          'Y' AS ACTIVE_IND,
          --        pmp.prod_zone,
          pmp.fluid,
          pmp.year,
          pmp.cum_prior,
          pmp.jan,
          pmp.feb,
          pmp.mar,
          pmp.apr,
          pmp.may,
          pmp.jun,
          pmp.jul,
          pmp.aug,
          pmp.sep,
          pmp.oct,
          pmp.nov,
          pmp.dec,
          pmp.year_to_date,
          pmp.pi_volume_unit,
          pmp.pi_volume_ouom,
          pmp.pi_user_id,
          pmp.pi_rec_upd_date,
          pmp.pi_user_id,
          pmp.pi_row_add_date
     FROM PDEN_MONTHLY_PROD@C_TALISMAN_PID_STG_IHSDATAQ pmp,
          PDEN@C_TALISMAN_PID_STG_IHSDATAQ P,
          PI_PDEN_WELL@C_TALISMAN_PID_STG_IHSDATAQ PpW,
          WELL_VERSION WV
    WHERE     P.ENTITY_TYPE = 'WELL'
          AND P.ENTITY = PPW.ENTITY
          AND PPW.ENTITY = PMP.ENTITY
          AND PPW.WELL_IDENTIFIER = WV.WELL_NUM
          AND WV.SOURCE ='450PID'
          and WV.ACTIVE_IND ='Y';


GRANT SELECT ON PPDM.IHS_PID_PDEN_VOL_BY_MONTH TO PPDM_RO;
