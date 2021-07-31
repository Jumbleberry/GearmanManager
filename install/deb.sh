#!/bin/sh

# Gearman worker manager

### BEGIN INIT INFO
# Provides:          gearman-manager
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable gearman manager daemon
### END INIT INFO

##PATH##
DAEMON=/usr/local/bin/gearman-manager
PIDDIR=/run/gearman
PIDFILE=${PIDDIR}/manager.pid
LOGFILE=/var/log/gearman-manager.log
CONFIGDIR=/etc/gearman-manager
GEARMANUSER="www-data"
PARAMS="-c ${CONFIGDIR}/config.ini"

test -x ${DAEMON} || exit 0

. /lib/lsb/init-functions
. /etc/gearman-manager/environment

start()
{
  log_daemon_msg "Starting Gearman Manager"
  if ! test -d ${PIDDIR}
  then
    mkdir ${PIDDIR}
    chown ${GEARMANUSER} ${PIDDIR}
  fi
  if start-stop-daemon \
    --start \
    --startas $DAEMON \
    --user $GEARMANUSER \
    --pidfile $PIDFILE \
    -- -P $PIDFILE \
       -l $LOGFILE \
       -u $GEARMANUSER \
       -e $ENV
       -d \
       $PARAMS 
  then
    log_end_msg 0
  else
    log_end_msg 1
    log_warning_msg "Please take a look at the syslog"
    exit 1
  fi
}

stop()
{
  log_daemon_msg "Stopping Gearman Manager"
  if start-stop-daemon \
    --stop \
    --oknodo \
    --retry INT/60/TERM/1 \
    --user $GEARMANUSER \
    --pidfile $PIDFILE
  then
    log_end_msg 0
  else
    log_end_msg 1
    exit 1
  fi
}

case "$1" in

  start)
    start
  ;;

  stop)
    stop
  ;;

  restart|force-reload)
    stop
    start
  ;;

  status)
    status_of_proc -p $PIDFILE $DAEMON "Gearman Manager"
  ;;

  *)
    echo "Usage: $0 {start|stop|restart|force-reload|status|help}"
  ;;

esac