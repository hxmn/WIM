CREATE OR REPLACE PACKAGE WIM.external_dependencies
is

/*--------------------------------------------------------------------------------------------------------------------

 PURPOSE:
  Invoke the appropriate API's (packages) to move dependent/associated well-data
  from one well to another. Basically, update the well-id in the associated records.

  Procedure does NOT COMMIT the change to allow caller to apply as part of wider transaction.

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   Typically, this is invoked by WIM.WIM_WELL_ACTION.WELL_MOVE, when the last active well version is moved
     pfrom_tlm_id - tlm_id of the well_version to be moved
     pfrom_source - source of the well_version to be moved
     pto_tlm_id   - tlm_id of the receiving well
     puserapi     - the user issuing the move request

 HISTORY:
   0.1    xx-xxx-xxx  -unknown- Initial version
          2015-11-05  kxedward  QC555/QC1480 - update External Dependencies and related move API's


 --------------------------------------------------------------------------------------------------------------------*/

    procedure well_move (
        pfrom_tlm_id    in  ppdm.well_version.uwi%type,
        pfrom_source    in  ppdm.well_version.source%type,
        pto_tlm_id      in  ppdm.well_version.uwi%type,
        puser           in  ppdm.well_version.row_created_by%type default user
    );
end;
/