#!/bin/sh

cd /var/chef/backup/state
chmod 700 .
knife exec -c /var/chef/.chef/knife.rb chef_server_backup.rb
tar cfz state-`date +%Y%m%d`.tar.gz chef_server_backup


