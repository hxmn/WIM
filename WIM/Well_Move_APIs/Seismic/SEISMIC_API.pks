CREATE OR REPLACE PACKAGE WIM.SEISMIC_API
IS
/*----------------------------------------------------------------------------------------------------
 PURPOSE:
    Provide an API for the EXTERNAL_DEPENDENCIES package to
    request a change in the seismic data management database as
    the result of a change occurring in WIM.

 DEPENDENCIES
    WIM.SEISMIC_DATA_MGMT           DB Link
    GEOLOGIC_API@SEISMIC_DATA_MGMT  Package at target of above DB Link

 HISTORY:
   1.0    2015-08-27  RPeters   Initial version
   1.1    2015-10-14  RPeters   No pkg header change
   1.2    2015-10-30  RPeters   No pkg header change

------------------------------------------------------------------------------------------------------*/
/*****************************************************************************
  TLM_ID_CHANGE procedure
 *****************************************************************************
 Implement changes required when moving all attachements on well pold_tlm_id
 to well pnew_tlm_id, typically in preparation for deleting pold_tlm_id.

   Parameters:
    pold_tlm_id      TLM_ID moving From
    pnew_tlm_id      TLM_ID moving To
-----------------------------------------------------------------------------------*/
  procedure tlm_id_change (
      pold_tlm_id  in   varchar2,
      pnew_tlm_id  in   varchar2
  );

end seismic_api;
/