#
# Cookbook Name:: qcloud
# Recipe:: openstack-clients
#
# Copyright (c) 2014, The University of Queensland
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

# Simply install the distro-supplied version for now.  (Some sources imply
# that there are version compatibility issues, and recommend building and
# installing from source.  I'm not convinced ...)
package 'python-swiftclient' do
  action :install
end

package 'python-novaclient' do
  action :install
end

package 'python-keystoneclient' do
  action :install
end

os_tenant_name = node['qcloud']['openstack_tenant_name']
os_tenant_id = node['qcloud']['openstack_tenant_id']
os_auth_url = node['qcloud']['openstack_auth_url']
os_username = node['qcloud']['openstack_username']
os_password = node['qcloud']['openstack_password']
os_rc_path = node['qcloud']['openstack_rc_path']

if os_tenant_name then
  # If we are use the default rc path, automatically create the parent dir 
  if (Pathname.new(os_rc_path).dirname == '/etc/openstack') then
    directory '/etc/openstack' do
      owner 'root'
      mode  0755
    end
  end
  template os_rc_path do
    owner 'root'
    mode  0600
    source 'openrc-sh.erb'
    variables({
                :os_auth_url => os_auth_url,
                :os_username => os_username,
                :os_password => os_password,
                :os_tenant_name => os_tenant_name,
                :os_tenant_id => os_tenant_id
              })
  end
end

