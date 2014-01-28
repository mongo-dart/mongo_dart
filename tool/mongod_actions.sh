#!/bin/bash

RS_NUM=3
DATA_PATH=/tmp/mongo_dart-unit_test

# OS Detection
echo $PATH | grep -q /cygdrive
if [ $? == 0 ]; then
  UNAME="Cygwin"
else
  UNAME=$(uname -s)
fi

DATA_CFG=$DATA_PATH/configure.js
case "$UNAME" in
  "Cygwin")
    DATA_CFG_MONGO=$(cygpath -w $DATA_CFG)
    ;;
  *)
    DATA_CFG_MONGO=$DATA_CFG
esac

make_env() {
  for i in $(seq 1 $RS_NUM); do
    mkdir -p $DATA_PATH/db/$i
  done
}

remove_env() {
  rm -rf $DATA_PATH
}

script_init() {
  echo -n > $DATA_CFG
}

script_configure_rs() {
  echo 'var x = rs.initiate({' >> $DATA_CFG
  echo '"_id": "rs",' >> $DATA_CFG
  echo '  "version": 1,' >> $DATA_CFG
  echo '  "members": [' >> $DATA_CFG
  for i in $(seq 1 $RS_NUM); do
    echo '    {' >> $DATA_CFG
    echo '      "_id": '$i',' >> $DATA_CFG
    echo '      "host": "localhost:'$((27000 + $i))'"' >> $DATA_CFG
    echo '    },' >> $DATA_CFG
  done
  echo '  ]' >> $DATA_CFG
  echo '});' >> $DATA_CFG
#  echo 'printjson(x);' >> $DATA_CFG
}

script_wait_rs() {
  echo 'print("Waiting for instance to initiate");' >> $DATA_CFG
  echo 'while(1) {' >> $DATA_CFG
  echo '  sleep(2000);' >> $DATA_CFG
  echo '  x = db.isMaster();' >> $DATA_CFG
#  echo '  printjson(x);' >> $DATA_CFG
  echo '  if (x.ismaster || x.secondary) {' >> $DATA_CFG
  echo '    print("Instance is online now");' >> $DATA_CFG
  echo '    break;' >> $DATA_CFG
  echo '  }' >> $DATA_CFG
  echo '}' >> $DATA_CFG
}

script_db_ismaster() {
  echo 'x = db.isMaster();' >> $DATA_CFG
  echo '  printjson(x);' >> $DATA_CFG
}

start() {
  make_env
  
  for i in $(seq 1 $RS_NUM); do
    echo "### Start mongod $i instance"
    case "$UNAME" in
      "Cygwin")
        cygstart mongod --smallfiles --oplogSize 50 --replSet rs \
          --logpath $(cygpath -w $DATA_PATH/$i.log) \
          --pidfilepath $(cygpath -w $DATA_PATH/$i.pid) \
          --dbpath $(cygpath -w $DATA_PATH/db/$i) \
          --port $((27000 + $i))
        ;;
      *)
        mongod --fork --smallfiles --oplogSize 50 --replSet rs \
          --logpath $DATA_PATH/$i.log \
          --pidfilepath $DATA_PATH/$i.pid \
          --dbpath $DATA_PATH/db/$i \
          --port $((27000 + $i))
    esac
  done
  
  script_init
  script_configure_rs
  script_wait_rs
  
  mongo localhost:27001 $DATA_CFG_MONGO
  
  script_init
  script_wait_rs

  for i in $(seq 2 $RS_NUM); do
    mongo localhost:$((27000 + $i)) $DATA_CFG_MONGO
  done
}

check_pid() {
  PID=$( echo $1 | tr -d "\r")
  case "$UNAME" in
    "Cygwin")
      FILTER="PID eq $PID"
      tasklist.exe /FI "$FILTER" | grep -q $PID
      ;;
    *)
      ps -p $PID &> /dev/null
  esac
}

kill_pid() {
  PID=$( echo $1 | tr -d "\r")
  case "$UNAME" in
    "Cygwin")
      taskkill.exe /PID $PID
      ;;
    *)
      kill $PID
  esac
}

stop() {
  for i in $(seq 1 $RS_NUM); do
    if [ -f $DATA_PATH/$i.pid ]; then
      PID=$(cat $DATA_PATH/$i.pid)
      check_pid $PID
      if [ $? == 0 ]; then
        echo "### Stop mongod $i instance"
        kill_pid $PID
      fi
    fi
  done
}

status() {
  script_init
  script_db_ismaster

  for i in $(seq 1 $RS_NUM); do
    if [ -f $DATA_PATH/$i.pid ]; then
      PID=$(cat $DATA_PATH/$i.pid)
      check_pid $PID
      if [ $? == 0 ]; then
        echo "### mongod $i instance is running (PID=$PID)"
        mongo localhost:$((27000 + $i)) $DATA_CFG_MONGO
      else
        echo "### mongod $i instance is stopped"
      fi
    fi
  done
}

case "$1" in
  start)
    stop
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  clean)
    remove_env
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    RETVAL=1
esac

exit $RETVAL