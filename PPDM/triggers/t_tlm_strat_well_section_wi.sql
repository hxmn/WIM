/***********************************************************************************************************************
 TIS Task 1426 Triggers for Well Inventory
 Change how well inventory is updated when well related data is changed. For example, on creation of
  directional survey data or well log data, or a move of same when well versions are moved.

 Use Advanced Queuing to enqueue a message indicating inventory has to be updated.  Then dequeue and
  update all inventory counts for each well.

 Create new trigger(s) to enqueue an Advanced Queuing message, to prompt the system to update well inventory

 Run this script from PPDM schema

 History
  20151110  cdong     script creation

 **********************************************************************************************************************/

------------------------------------------------------------------------------------------------------------------------
----drop trigger t_tlm_strat_well_section_wi;

create or replace trigger t_tlm_strat_well_section_wi
  after update or insert or delete
  on ppdm.TLM_STRAT_WELL_SECTION for each row

declare

begin

  /*
  -------------------------------------------------------------------------------------
  Trigger:    t_tlm_strat_well_section_wi
  Purpose:    This trigger is for table TLM_STRAT_WELL_SECTION
              Well inventory type: Stratigraphy/Tops
              When inserting, updating, or deleting, enqueue a message to Advanced Queuing to update inventory
  History:
    20151110    cdong   TIS Task 1426 - modify inventory update process for data insert/update/delete

  --------------------------------------------------------------------------------------
  */

  if inserting or updating then
    aq_well_inventory.aq_enqueue_wi_uwi(:new.uwi, 'STRAT');
    --ppdm_admin.tlm_process_logger.info('--STRATIGRAPHY trigger for advanced queuing - insert or update ' || :new.uwi);
  end if;
  
  if updating or deleting then
    aq_well_inventory.aq_enqueue_wi_uwi(:old.uwi, 'STRAT');
    --ppdm_admin.tlm_process_logger.info('--STRATIGRAPHY trigger for advanced queuing - update or delete ' || :old.uwi);
  end if;

end;
/

----disable old well inventory triggers
alter trigger T_TLM_STRAT_WELL_SECTION_AIUD2 disable;
alter trigger T_TLM_STRAT_WELL_SECTION_AIUD1 disable;
/

commit;
