CREATE OR REPLACE PACKAGE BODY WIM.SEISMIC_API
IS
/*------------------------------------------------------------------------------------------------------
 PURPOSE:
    Provide an API for the EXTERNAL_DEPENDENCIES package to
    request a change in the seismic data management database as
    the result of a change occurring in WIM.

 DEPENDENCIES
    WIM.SEISMIC_DATA_MGMT           DB Link
    GEOLOGIC_API@SEISMIC_DATA_MGMT  Package at target of above DB Link

 HISTORY:
   1.0    2015-08-27  RPeters   Initial version
   1.1    2015-10-14  RPeters   Update counts in DATA_ACCESS_COAT_CHECK.WELL_INVENTORY
   1.2    2015-10-30  RPeters   Comment out 1.1 (done by trigger in seismic DB)

------------------------------------------------------------------------------------------------------*/
/*****************************************************************************
  TLM_ID_CHANGE procedure
 *****************************************************************************
 Implement changes required when moving all attachements on well pold_tlm_id
 to well pnew_tlm_id, typically in preparation for deleting pold_tlm_id.

 Forwards the request to GEOLOGIC_API.TLM_ID_CHANGE@SEISMIC_DATA_MGMT.

   Parameters:
    pold_tlm_id      TLM_ID moving From
    pnew_tlm_id      TLM_ID moving To
-----------------------------------------------------------------------------------*/
  PROCEDURE TLM_ID_CHANGE (
    pOld_TLM_ID  IN   VARCHAR2,
    pNew_TLM_ID  IN   VARCHAR2
  )
  IS
    vDetail           VARCHAR2(2000);
--    vVsp_Count        INTEGER := 0;
--    vMicro_Seis_Count INTEGER := 0;
  BEGIN

    GEOLOGIC_API.TLM_ID_CHANGE@SEISMIC_DATA_MGMT(pOld_TLM_ID,pNew_TLM_ID);
    vDetail := chr(10) || 'Successfully updated seismic database.';

--    -- Update counts in DATA_ACCESS_COAT_CHECK.WELL_INVENTORY
--
--    select  WI.VSP_COUNT, WI.MICRO_SEIS_COUNT
--    into    vVsp_Count,   vMicro_Seis_Count
--    from    DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
--    where   WI.UWI = pOld_TLM_ID;
--
--    if vVsp_Count + vMicro_Seis_Count < 1
--    then
--      vDetail := vDetail || chr(10) ||
--                 'No WELL_INVENTORY seismic counts for TLM_ID ' || pOld_TLM_ID || ' to move.';
--    else
--      update  DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
--      set     WI.VSP_COUNT        = 0,
--              WI.MICRO_SEIS_COUNT = 0
--      where   WI.UWI = pOld_TLM_ID;
--      vDetail := vDetail || chr(10) ||
--                 'Cleared WELL_INVENTORY VSP_COUNT and MICRO_SEIS_COUNT for TLM_ID ' || pOld_TLM_ID || '.';
--
--      update  DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
--      set     WI.VSP_COUNT        = WI.VSP_COUNT        + vVsp_Count,
--              WI.MICRO_SEIS_COUNT = WI.MICRO_SEIS_COUNT + vMicro_Seis_Count
--      where   WI.UWI = pNew_TLM_ID;
--      if SQL%ROWCOUNT > 1
--      then
--        vDetail := vDetail || chr(10) ||
--                   'Updated WELL_INVENTORY seismic counts for TLM_ID ' || pNew_TLM_ID ||
--                   '. Added ' || vVsp_Count || ' to VSP_COUNT and added ' || vMicro_Seis_Count || ' to MICRO_SEIS_COUNT.';
--      else
--        insert
--        into  DATA_ACCESS_COAT_CHECK.WELL_INVENTORY WI
--              (WI.UWI,      WI.VSP_COUNT, WI.MICRO_SEIS_COUNT )
--        values
--              (pNew_TLM_ID, vVsp_Count,   vMicro_Seis_Count);
--          vDetail := vDetail || chr(10) ||
--                   'Created WELL_INVENTORY for TLM_ID ' || pNew_TLM_ID ||
--                   ' with VSP_COUNT = ' || vVsp_Count || ' and MICRO_SEIS_COUNT = ' || vMicro_Seis_Count || '.';
--      end if;
--    end if;

    ppdm_admin.tlm_process_logger.info('WIM.SEISMIC_API: ' ||  vDetail);

  END TLM_ID_CHANGE;

END SEISMIC_API;
/