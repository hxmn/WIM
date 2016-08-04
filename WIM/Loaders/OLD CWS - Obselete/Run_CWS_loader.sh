#!/bin/csh

# Run_CWS_Loader.sh

source /etc/csh.login
source ~/.login

cd ~/scripts/CWS_Loader
sqlplus Talisman37/voodoo@IHSDATA @CWS_Loader.sql 

exit 0
