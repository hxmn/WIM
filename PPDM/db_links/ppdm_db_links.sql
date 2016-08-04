/**************************************************************************************************
 Database Links


 **************************************************************************************************/

------------------------------------------
-- IHS-Canada
DROP DATABASE LINK C_TALISMAN_IHSDATA;

CREATE DATABASE LINK C_TALISMAN_IHSDATA
 CONNECT TO C_TALISMAN
 IDENTIFIED BY &Password
 USING 'IHSDATA'
;
/


------------------------------------------
-- IHS-US PID database (PDEN)
DROP DATABASE LINK C_TALISMAN_PID_STG_IHSDATAQ;

CREATE DATABASE LINK C_TALISMAN_PID_STG_IHSDATAQ
 CONNECT TO C_TLM_PID_STG
 IDENTIFIED BY &Password
 USING 'IHSDATAQ'
;
/

------------------------------------------
-- IHS-US (ppdm)
DROP DATABASE LINK C_TALISMAN_US_IHSDATAQ;

CREATE DATABASE LINK C_TALISMAN_US_IHSDATAQ
 CONNECT TO C_TALISMAN_US
 IDENTIFIED BY &Password
 USING 'IHSDATAQ'
;
/


------------------------------------------
-- IHS-International
DROP DATABASE LINK C_TLM_PROBE;

CREATE DATABASE LINK C_TLM_PROBE
 CONNECT TO C_TLM_PROBE_STG
 IDENTIFIED BY &Password
 USING 'ihsdataq'
;
/


