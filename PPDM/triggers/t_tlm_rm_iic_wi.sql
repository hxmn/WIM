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
----drop trigger t_tlm_rm_iic_wi;

create or replace trigger t_tlm_rm_iic_wi 
  after update or insert or delete
  on ppdm.RM_INFO_ITEM_CONTENT for each row

declare

begin

  /*
  -------------------------------------------------------------------------------------
  Trigger:    t_tlm_rm_iic_wi
  Purpose:    This trigger is for table RM_INFO_ITEM_CONTENT.
              Well inventory types: Well Logs (Oilware) and Records Management (physical) items
              When inserting, updating, or deleting, enqueue a message to Advanced Queuing to update inventory
  History:
    20151123    cdong   TIS Task 1426 - modify inventory update process for data insert/update/delete

  --------------------------------------------------------------------------------------
  */

  if inserting or updating then
    --ppdm_admin.tlm_process_logger.info('--RM / WELL LOG trigger for advanced queuing - insert or update ' || :new.uwi || ' info_item_type ' || :new.info_item_type
    --                                     || ' source ' || nvl(:new.source, '-no-source-') || ' well_log_id ' || nvl(:new.well_log_id, '-no-well-log-id-')
    --                                   );

    if (:new.info_item_type = 'RM_WELL_LOG'
         and :new.well_log_id IS NOT NULL
         and :new.source = 'OWI-DBLOAD'
         and :new.uwi IS NOT NULL
     ) then
        aq_well_inventory.aq_enqueue_wi_uwi(:new.uwi, 'WELL_LOG');
    elsif (:new.uwi IS NOT NULL) then
        aq_well_inventory.aq_enqueue_wi_uwi(:new.uwi, 'RM');
    end if;
    
  end if;
    
  if updating or deleting then
    --ppdm_admin.tlm_process_logger.info('--RM / WELL LOG trigger for advanced queuing - update or delete ' || :old.uwi || ' info_item_type ' || :old.info_item_type
    --                                     || ' source ' || nvl(:old.source, '-no-source-') || ' well_log_id ' || nvl(:old.well_log_id, '-no-well-log-id-')
    --                                   );

    if (:old.info_item_type = 'RM_WELL_LOG'
            and :old.well_log_id IS NOT NULL
            and :old.source = 'OWI-DBLOAD'
            and :old.uwi IS NOT NULL
     ) then 
        aq_well_inventory.aq_enqueue_wi_uwi(:old.uwi, 'WELL_LOG');
    elsif (:old.uwi IS NOT NULL) then
        aq_well_inventory.aq_enqueue_wi_uwi(:old.uwi, 'RM');
    end if;
  end if;

end;
/

----disable old well inventory triggers
alter trigger T_TLM_WELL_LOG_CURVE_AIUD2 disable;
alter trigger T_TLM_WELL_LOG_CURVE_AIUD1 disable;
/

commit;
