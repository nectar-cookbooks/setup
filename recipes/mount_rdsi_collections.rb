#
# Cookbook Name:: setup
# Recipe:: mount_rdsi_collections
#
# Copyright (c) 2013, 2014, The University of Queensland
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

::Chef::Recipe.send(:include, ZoneInfo)

if platform?("redhat", "centos", "fedora", "scientific") then
  package "nfs-utils" do
  end
elsif platform?("ubuntu") then
  package "nfs-common" do
  end
else
  raise "Platform #{node['platform']} not supported"
end  

package "autofs" do
  not_if { File::exists?("/etc/auto.master") }
end

# Validate the Store ids 
node['setup']['store_ids'].each() do |store_id|
  if ! /Q[0-9][0-9]([0-9][0-9])?/.match(store_id) then
    raise "Invalid store id (#{store_id}) : expected Qnn or Qnnnn"
  end
  num = /Q([0-9]+)/.match(store_id)[1].to_i()
  # There is an inconsistency in the way that early IDs were created ... 
  anomalous = num >= 1 && num <= 5 || num == 16
  if num <= 0 then
    raise "Invalid store id (#{store_id}) : there is no store zero"
  elsif anomalous && ! /Q[0-9][0-9]/.match(store_id) then
    raise "Invalid store id (#{store_id}) : stores 1..5 and 16 have form Qnn"
  elsif ! anomalous && ! /Q[0-9][0-9][0-9][0-9]/.match(store_id) then
    raise "Invalid store id (#{store_id}) : store ids normally have form Qnnnn"
  end
end

# Configure private network.  
if platform?("redhat", "centos", "fedora", "scientific") then
  cookbook_file "/etc/sysconfig/network-scripts/ifcfg-eth1" do
    source "ifcfg-eth1"
    not_if { File::exists?("/etc/sysconfig/network-scripts/ifcfg-eth1") }
    notifies :run, "bash[ifup]", :immediately
  end
  bash "ifup" do
    action :nothing
    code "ifup eth1"
  end
elsif platform?("ubuntu") then
  ruby_block "add-interface" do
    block do
      config = <<-EOS
        # The secondary network interface - added by Chef
        auto eth1
        iface eth1 inet dhcp
        pre-up /sbin/ifconfig eth1 mtu 9000
      EOS
      file = Chef::Util::FileEdit.new("/etc/network/interfaces")
      file.insert_line_if_no_match("iface eth1 ", config)
      file.write_file
    end
    notifies :restart, "service[networking]", :immediately
  end
  service "networking" do
    action :nothing
  end
else
  raise "Platform #{node['platform']} not supported"
end

# Create local users to match the standard uids in the collection filesystems.
if node['setup']['create_users'] then
  group 'webdav' do
    gid 48
    system true
  end
  user 'webdav' do
    uid 48
    gid 'webdav'
    system true
    comment 'WebDAV'
    shell '/sbin/nologin'
  end
  node['setup']['store_ids'].each() do |store_id|
    num = /Q([0-9]+)/.match(store_id)[1].to_i()
    if num > 999 then
      raise "The store_id to uid mapping is not defined for #{store_id}"
    end
    group store_id.downcase() do
      gid 54000 + num
      system false
    end
    user store_id.downcase() do
      uid 54000 + num
      gid store_id.downcase()
      system true
      home "#{node['setup']['mount_dir']}/#{store_id}"
      comment ''
      shell '/sbin/nologin'
    end
  end  
end

# Create / update the autofs mounts
ruby_block "edit_auto_master" do
  block do
    file = Chef::Util::FileEdit.new("/etc/auto.master")
    file.insert_line_if_no_match("auto.qcloud", "/- file:/etc/auto.qcloud")
    file.write_file
  end
end
if platform?("redhat", "centos", "fedora", "scientific") then
  opts = "-rw,nfsvers=3,hard,intr,bg,nosuid,nodev,timeo=15,retrans=5,nolock"
else
  opts = "-rw,nfsvers=3,hard,intr,bg,nosuid,nodev,timeo=15,retrans=5"
end
server_ip = node['setup']['nfs_server']
unless server_ip then
  zr = ip2ZoneRange(node['ipaddress'])
  unless zr then
    raise "Host's IP is not in a known NeCTAR zone"
  end
  case zr['zone']
  when 'qld' then 
    server_ip = '10.255.100.50'        # Prentice dc NFS
  when 'qriscloud' then 
    server_ip = '10.255.120.200'       # Polaris dc NFS
  else 
    raise "Don't know the NFS server IP for zone #{zr['zone']}"
  end
end
    
template "/etc/auto.qcloud" do
  source "autofs_direct_map.erb"
  mode 0444
  variables ({
    :store_ids => node['setup']['store_ids'],
    :nfs_server => server_ip,
    :mount_dir => node['setup']['mount_dir'],
    :opts => opts
  })
  notifies :restart, "service[autofs]", :immediately
end

service "autofs" do
  action :nothing
end
