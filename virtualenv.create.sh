#!/bin/bash
PURPOSE="build a custom python virtualenv using pip"

# -- auto: path variables
scriptSelf=$0;
scriptName=${scriptSelf##*/}; scriptCallDir=${scriptSelf%/*};
cd $scriptCallDir; scriptFullDir=$PWD; scriptFullPath=$scriptFullDir/$scriptName;
scriptTopDir=${scriptFullDir%/*}
# -- /auto: path variables

# -- helper functions
# - default output functions
function printVersion { echo -e "\033[1m# ${scriptName} version ${VERSION}\033[0m\n"; [[ -n "${1}" ]] && exit ${1}; }
function printTitle   { echo; msg="$*";linesno=$(( ${#msg} + 4 ));msglines=$(for i in `seq ${linesno}`;do echo -n "=";done);echo -e "${msglines}\n# ${msg} #\n${msglines}"; }
function printOut     { echo -en "$@"; }
function printOk      { echo -en "\033[32m$*\033[0m"; }
function printInfo    { echo -en "\033[34m$*\033[0m"; }
function printError   { echo -en "\033[31m$*\033[0m"; }
# - default exit functions
function exitError    { echo -e "\n\033[31m[${HOSTNAME}] ERROR: ${1:-"Unknown Error"}. Exiting...\033[0m" 1>&2; exit ${2:-1}; }
function exitInfo     { echo -e "\n\033[34m[${HOSTNAME}] INFO: ${1:-"Thank you for using ${scriptName}"}.\033[0m" 1>&2; exit ${2:-1}; }
# -- /helper functions


# -- work variables
[[ -z "${APP_NAME}" ]] && APP_NAME="${1:-virtualenv}"
[[ -z "${APP_PATH}" ]] && APP_PATH="/opt/${APP_NAME}"
[[ -z "${TMP_PATH}" ]] && TMP_PATH="/opt/build"


# -- script usage
# get help
if [[ "${1}" = "-h" || "${1}" = "--help" ]];then
  printInfo "\n# ${PURPOSE}\n"
  printInfo "  Usage: ${scriptName} [virtualenv-name (DEFAULT:virtualenv)]\n\n"
  exit 0
fi


# -- optional user prompt
printTitle "BUILDING VIRTUALENV ${APP_NAME} to [${APP_PATH}]"
[[ -z "${1}" ]] && printInfo "(Press ENTER to CONTINUE, CTRL+C to ABORT)" && read none


# -- exit on errors
set -e

# -- switch to script dir
cd ${scriptFullDir}


# -- install package dependencies
if [[ -f requirements.pkg ]];then
  printTitle "INSTALLING PKG DEPENDENCIES"
  apk update
  apk add $(grep -vE "^(#.*|$)" requirements.pkg)
fi


# -- install build pip requirements
printTitle "UPDATING PIP REQUIREMENTS"
PIP_PACKAGES="pip virtualenv"
if which sudo >/dev/null 2>&1;then
  sudo -E pip3 install --upgrade ${PIP_PACKAGES}
else
  pip3 install --upgrade ${PIP_PACKAGES}
fi


# -- setup virtualenv
BUILD_ACTIVATE="${APP_PATH}/bin/activate"
# cleanup venv dir if already exists
[[ -d ${APP_PATH} ]] && rm -rf ${APP_PATH}
# create work dir if not present yet
[[ -d ${APP_PATH} ]] || mkdir -p ${APP_PATH}
# create virtualenv
virtualenv ${APP_PATH}
# activate virtualenv
source ${BUILD_ACTIVATE}

# -- install required pip packages in venv
printTitle "INSTALLING REQUIRED MODULES IN VIRTUALENV"
if which sudo >/dev/null 2>&1;then
  sudo -E pip3 install --upgrade -r $scriptFullDir/requirements.pip
else
  pip3 install --upgrade -r $scriptFullDir/requirements.pip
fi

# -- make virtualenv relocateable
virtualenv --relocatable ${APP_PATH}

# -- create virtualenv config path
mkdir -p ${APP_PATH}/cfg
# copy ansible config
cp -v $scriptFullDir/files/ansible.cfg ${APP_PATH}/cfg/
# copy ansible default environment
cp -v $scriptFullDir/files/ansible.env ${APP_PATH}/cfg/

# -- exit from virtualenv
deactivate


# -- adding external tools
if [[ "${SKIP_EXTERNAL_TOOLS}" == "true" ]];then
  printTitle "SKIPPING DOWNLOAD OF EXTERNAL TOOLS"
  echo "environment variable SKIP_EXETERNAL_TOOLS=true"
else
  printTitle "DOWNLOADING EXTERNAL TOOLS"
  # export needed variables
  export APP_PATH
  # include download script
  for download_script in ${scriptFullDir}/tools.download.*
  do
    bash ${download_script}
    echo
  done
fi


# -- run ansible setup tasks
# add ansible env vars to activate script
${APP_PATH}/bin/ansible-playbook -e "APP_PATH=${APP_PATH}" -e "activate_file_path=${BUILD_ACTIVATE}" ${scriptFullDir}/virtualenv.create.yml 2>/dev/null
printOk "\n--\n* virtualenv [${APP_PATH}] set up successfully\n--\n"

# -- create tgz release
RELEASE_FILENAME="${TMP_PATH}/${APP_NAME}.tgz"
tar -czf ${RELEASE_FILENAME} -C ${APP_PATH} .
printOk "\n--\n* archiv ${RELEASE_FILENAME} created successfully\n--\n"

# --upload tgz release
if [[ -n "${FTP_UPLOAD_URL}" ]];then
  curl -s -T ${RELEASE_FILENAME} "${FTP_UPLOAD_URL}/"
  printOk "\n--\n* archiv ${RELEASE_FILENAME} successfully uploaded\n--\n"
fi


# eof
