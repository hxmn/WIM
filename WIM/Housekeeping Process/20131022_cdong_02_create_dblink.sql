-- create database link to DM (EDXP) database under WIM schema
-- the dblink is used by the view WIM.WIM_DM_MISSING_WELLS_VW

DROP DATABASE LINK DM;

CREATE DATABASE LINK DM
 CONNECT TO DOCSADM
 IDENTIFIED BY docsadm
 USING 'EDXP';

