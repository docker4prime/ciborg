#!/bin/bash
# PURPOSE: simple wrapper script for activating ansible virtualenv

# -- auto: path variables
scriptSelf=$0;
scriptName=$(basename $scriptSelf)
scriptCallDir=$(dirname $scriptSelf)
scriptFullDir=$(cd $scriptCallDir;echo $PWD)
scriptFullPath=$scriptFullDir/$scriptName;
scriptParentDir=$(dirname $scriptFullDir)
# -- /auto: path variables


# activate virtualenv if found
[[ -f ${scriptFullDir}/activate ]] && . ${scriptFullDir}/activate

# pass all other commands through
exec "$@"


# eof
