#
# Cookbook Name:: qcloud
# Recipe:: chef-server
#
# Copyright (c) 2012, 2014, The University of Queensland
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# * Neither the name of the The University of Queensland nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF QUEENSLAND BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

include_recipe "chef-server"

directory "/var/chef/couchdb" do
  owner "chef"
  group "chef"
end

cookbook_file "/var/chef/couchdb/couchdb_daily.sh" do
  owner "chef"
  group "chef"
  mode 0500
end

directory "/var/chef/backup/state/chef_server_backup" do
  owner "chef"
  group "chef"
  mode 0700
  action :create
  recursive true
end

cookbook_file "/var/chef/backup/state/chef-backup.sh" do
  action :create
  owner "chef"
  group "chef"
  mode 0500
end

cookbook_file "/var/chef/backup/state/chef_server_backup.rb" do
  action :create
  owner "chef"
  group "chef"
  mode 0400
end

cron "chef_server_backup" do
  hour "12"
  minute "30"
  user "chef"
  mailto "root"
  home "/var/chef"
  command "/var/chef/backup/state/chef-backup.sh"
end

cron "chef_couchdb_daily" do
  hour "13"
  minute "30"
  user "chef"
  mailto "root"
  home "/var/chef"
  command "/var/chef/couchdb/couchdb_daily.sh"
end

include_recipe "git"
