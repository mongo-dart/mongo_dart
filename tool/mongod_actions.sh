#!/bin/bash

RS_NUM=3
DATA_PATH=/tmp/mongo_dart-unit_test
DATA_CFG=$DATA_PATH/configure.js

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
    mongod --fork --logpath $DATA_PATH/$i.log --pidfilepath $DATA_PATH/$i.pid --smallfiles --oplogSize 50 --port $((27000 + $i)) --dbpath $DATA_PATH/db/$i --replSet rs
  done
  
  script_init
  script_configure_rs
  script_wait_rs
  
  mongo localhost:27001 $DATA_CFG
  
  script_init
  script_wait_rs

  for i in $(seq 2 $RS_NUM); do
    mongo localhost:$((27000 + $i)) $DATA_CFG
  done
}

stop() {
  for i in $(seq 1 $RS_NUM); do
    if [ -f $DATA_PATH/$i.pid ]; then
      PID=$(cat $DATA_PATH/$i.pid)
      ps -p $PID &> /dev/null
      if [ $? == 0 ]; then
        echo "### Stop mongod $i instance"
        kill $PID
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
      ps -p $PID &> /dev/null
      if [ $? == 0 ]; then
        echo "### mongod $i instance is running (PID=$PID)"
        mongo localhost:$((27000 + $i)) $DATA_CFG
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