#
# Cookbook Name:: qcloud
# Recipe:: set_hostname
#
# Copyright (c) 2013, The University of Queensland
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

require 'resolv'

ip = node['ipaddress']
ip_fqdns = Resolv::DNS.new.getnames(ip)

fqdn = node['qcloud']['set_fqdn']
if fqdn == '*' then
  if !ip_fqdns || ip_fqdns.empty?() then
    raise 'Resolv::DNS cannot tell us what our hostnames are!?!'
  end
  fqdn = ip_fqdns[0].to_s()
end

/^([^.]+)/ =~ fqdn
hostname = $1

if !hostname || hostname == '' then
  raise "The supplied or inferrred FQDN is invalid ('#{fqdn'})"
end

file '/etc/hostname' do
  content "#{hostname}\n"
  mode "0644"
  notifies :reload, "ohai[reload]"
end

execute "hostname #{hostname}" do
  only_if { node['hostname'] != hostname }
  notifies :reload, "ohai[reload]"
end

aliases = [ hostname ]
ip_fqdns.each() do |ip_fqdn|
  f = ip_fqdn.to_s()
  if fqdn != f then
    aliases << f
    match = /^([^.]+)\..+$/.match(f)
    if match then
      aliases << match[1]
    end
  end
end

hostsfile_entry "set hostnames" do
  ip_address ip
  hostname fqdn
  aliases aliases
  action :create
  notifies :reload, "ohai[reload]"
end

# 
# For some reason, 'create_if_missing' below is treated as 'create' which
# results in an unnecessary update which is potentially harmful for some
# platforms; e.g. when the out-of-the-box "/etc/hosts" has aliases for 
# localhost that other applications / services depend on.
#
# hostsfile_entry "set localhost" do
#   ip_address "127.0.0.1"
#   hostname "localhost"
#   action :create_if_missing
#   notifies :reload, "ohai[reload]"
# end

ohai "reload" do
  action :nothing
end



