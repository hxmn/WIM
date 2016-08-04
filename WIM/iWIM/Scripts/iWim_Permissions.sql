
ALTER TABLE IWIM.WELL_MANAGER_ROLES
MODIFY(ROLE VARCHAR2(40 BYTE));
commit;

--PETT
ALTER TABLE well_manager_roles
DROP CONSTRAINT SYS_C00261151 ;
commit;

--PETDEV
ALTER TABLE well_manager_roles
DROP CONSTRAINT SYS_C0029822 ;
commit;

--PETP
ALTER TABLE well_manager_roles
DROP CONSTRAINT SYS_C0029563 ;
commit;

ALTER TABLE well_manager_roles
add CONSTRAINT MWR_PK PRIMARY KEY (ROLE, USERID);
COMMIT;

--Set up permissions
 
insert into well_manager_roles
values('lchin', 'Well_Directional_Survey_Data_Steward');

insert into well_manager_roles
values('smiller', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('tdumka', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('vrajpoot', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('rpeters', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('rmasterm', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('ngrewal', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('sdixit', 'Well_Directional_Survey_Data_Steward');
COMMIT;

insert into well_manager_roles
values('rgarcia', 'Well_Directional_Survey_Data_Steward');
COMMIT;


ALTER TABLE IWIM.WELL_MANAGER_PERMISSIONS
MODIFY(ROLE VARCHAR2(40 BYTE));

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'A', '090DSS');

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'C', '090DSS');

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'D', '090DSS');

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'U', '090DSS');

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'I', '090DSS');

insert into well_manager_permissions
values('Well_Directional_Survey_Data_Steward', 'M', '090DSS');

COMMIT;

