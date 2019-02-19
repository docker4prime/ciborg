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


# run goss tests
DOCKER_IMAGE="docker4prime/ciborg"
GOSSFILE_PATH=${scriptFullDir}/goss.yml
if docker version >/dev/null 2>&1;then
  echo "[>] running goss test defined in ${GOSSFILE_PATH} (via docker image ${DOCKER_IMAGE})"
  docker run --rm -it -v ${GOSSFILE_PATH}:/tmp/goss.yml ${DOCKER_IMAGE} goss --gossfile /tmp/goss.yml validate -f documentation
else
  echo "[>] running goss test defined in ${GOSSFILE_PATH}"
  goss --gossfile ${GOSSFILE_PATH} validate -f documentation
fi


# eof
