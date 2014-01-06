#!/bin/sh

LOG=/var/log/chef/couchdb.log

date >> $LOG
curl -s http://localhost:5984/chef >> $LOG
curl -s -H "Content-Type: application/json" -X POST http://localhost:5984/chef/_compact > /var/tmp/couchdb.out
if grep < /var/tmp/couchdb.out '{"ok":true}' > /dev/null ; then
    echo Compaction start succeeded >> $LOG
    rm /var/tmp/couchdb.out
    # Give it some time to finish ...
    sleep 60
else
    echo Compaction start failed >> $LOG
    cat /var/tmp/couchdb.out >> $LOG
    echo Couchdb compaction start failed: see $LOG
fi
curl -s http://localhost:5984/chef >> $LOG
