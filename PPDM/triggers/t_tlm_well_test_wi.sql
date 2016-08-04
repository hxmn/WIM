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
----drop trigger t_tlm_well_test_wi;

create or replace trigger t_tlm_well_test_wi 
  after update or insert or delete
  on ppdm.TLM_WELL_TEST for each row

declare

begin

  /*
  -------------------------------------------------------------------------------------
  Trigger:    t_tlm_well_test_wi
  Purpose:    This trigger is for table TLM_WELL_TEST
              Well inventory type: Well Test
              When inserting, updating, or deleting, enqueue a message to Advanced Queuing to update inventory
  History:
    20151110    cdong   TIS Task 1426 - modify inventory update process for data insert/update/delete

  --------------------------------------------------------------------------------------
  */

  if inserting or updating then
    aq_well_inventory.aq_enqueue_wi_uwi(:new.uwi, 'WELL_TEST');
    --ppdm_admin.tlm_process_logger.info('--WELL TEST trigger for advanced queuing - insert or update ' || :new.uwi);
  end if;
  
  if updating or deleting then
    aq_well_inventory.aq_enqueue_wi_uwi(:old.uwi, 'WELL_TEST');
    --ppdm_admin.tlm_process_logger.info('--WELL TEST trigger for advanced queuing - update or delete ' || :old.uwi);
  end if;

end;
/

----disable old well inventory triggers
alter trigger T_TLM_WELL_TEST_AIUD2 disable;
alter trigger T_TLM_WELL_TEST_AIUD1 disable;
/

commit;
