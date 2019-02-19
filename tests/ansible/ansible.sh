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


# run test playbook
PLAYBOOK_PATH=${scriptFullDir}/ansible.yml
echo "[>] running test playbook ${PLAYBOOK_PATH}"
ansible-playbook ${PLAYBOOK_PATH} $*


# eof
