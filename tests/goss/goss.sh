#!/bin/sh
# PURPOSE: simple wrapper script for running tests


# -- auto: path variables
scriptSelf=$0;
scriptName=$(basename $scriptSelf)
scriptCallDir=$(dirname $scriptSelf)
scriptFullDir=$(cd $scriptCallDir;echo $PWD)
scriptFullPath=$scriptFullDir/$scriptName;
scriptParentDir=$(dirname $scriptFullDir)
# -- /auto: path variables


# setup environment
export ANSIBLE_INVENTORY="${scriptFullDir}/inventory"
export ANSIBLE_ROLES_PATH="$(dirname ${scriptParentDir})"


# run test playbook
GOSSFILE_PATH=${scriptFullDir}/goss.yml
echo "[>] running goss test defined in ${GOSSFILE_PATH}"
goss --gossfile ${GOSSFILE_PATH} validate -f documentation


# eof
