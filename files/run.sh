#!/bin/sh
# PURPOSE: simple wrapper script as docker entrypoint

# -- auto: path variables
scriptSelf=$0;
scriptName=$(basename $scriptSelf)
scriptCallDir=$(dirname $scriptSelf)
scriptFullDir=$(cd $scriptCallDir;echo $PWD)
scriptFullPath=$scriptFullDir/$scriptName;
scriptParentDir=$(dirname $scriptFullDir)
# -- /auto: path variables


# -- setup signal handling
# initialisation tasks
set -e
pid=0
pids=""

# HUP/USR1 actions
handler_usr1(){
  echo "[i] --- TOP of USR HANDLER ---"
  echo "[i] --- END of USR STATUS ---"
}

# TERM/QUIT/INT actions
handler_term(){
  echo "[i] --- TOP of SHUTDOWN HANDLER ---"
  if [[ ${pid} -ne 0 ]]; then
    for daemon_pid in ${pids}
    do
      pidname=$(pgrep -als0|grep "^${daemon_pid}"|awk '{print $2}')
      echo "[>] killing process [${pidname}] with pid ${daemon_pid}"
      kill -SIGTERM "${daemon_pid}"
      wait "${daemon_pid}"
    done
  fi
  echo "[i] --- END of SHUTDOWN HANDLER ---"
  exit 143; # 128 + 15 -- SIGTERM
}
# register handlers
trap 'kill ${!}; handler_usr1' SIGUSR1 SIGHUP
trap 'kill ${!}; handler_term' SIGTERM SIGQUIT SIGINT

# starting daemons
start_daemon(){
  # start in background
  exec "$@" &
  # get command pid
  pid="$!"
  pids="${pids} ${pid}"
  # show info
  echo "[>] command [${1}] started with pid ${pid}"
  echo "[>] running command pids: ${pids}"
}


# starting services
# echo "[>] starting services"


# if ran with arguments
if [ -n "${1}" ];then
  # pass all commands through
  exec "$@"
# if ran without arguments (DEFAULT)
else
  # wait forever
  echo "[>] starting endless loop"
  while true
  do
    tail -f /dev/null & wait ${!}
  done
fi


# eof
