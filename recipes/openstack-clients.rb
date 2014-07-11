#
# Cookbook Name:: setup
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

try_distro = node['setup']['openstack_try_distro']
try_pip = node['setup']['openstack_try_pip']
use_rdo = node['setup']['openstack_use_rdo']

if try_distro && use_rdo && platform_family?('rhel', 'fedora') then
  base = 'http://repos.fedorapeople.org/repos/openstack' 
  release = node['setup']['openstack_release']
  if platform_family?('fedora')
    platform = "fedora-#{node['platform_version']}"
    name = "Fedora-#{node['platform_version']}"
  else
    version = /(\d+)\.\d+/.match(node['platform_version'])[1]
    platform = "epel-#{version}"
    name = "EPEL #{version}"
  end

  baseurl = "#{base}/openstack-#{release}/#{platform}/"
  # Test to see if the intuited RDO repo URL is viable.
  begin
    redirects = 0
    url_string = baseurl
    while true do
      raise "Redirection loop for #{url}" if redirects >= 20
      url = URI.parse(url_string)
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = (url.scheme == 'https')
      res = req.request_head(url.path || "/")
      if (! res.kind_of?(Net::HTTPRedirection) ) then
        status = res.code.to_i
        case status
        when 404
          raise "There is no RDO repo for #{release} on #{platform}"
        when 400..499, 500..599
          raise "HTTP Request failed: #{status} #{res.message}: for #{url}"
        when 200..299
          break;
        when true
          raise "Unexpected HTTP response: #{status} #{res.message}: for #{url}"
        end
      end
      url_string = res['location']
    end
  rescue Errno::ENOENT
    raise "Unexpected problem with url #{url_string}"
  end
  yum_repository "openstack-#{release}" do
    description "Openstack #{release} - RDO (#{name})"
    baseurl baseurl
    enabled true
    gpgcheck false
    priority '98'
  end
end

# Build dependencies for the python clients ... in case we need them.
if try_pip then
  if platform_family?('debian') then
    deps = ['python-pip', 'build-essential',
            'libssl-dev', 'libffi-dev', 'python-dev']
  else
    deps = ['python-pip', 'gcc', 'openssl-devel', 'libffi-devel', 
            'python-devel']
  end
  
  deps.each do |pkg|
    package pkg do
      action :install
    end
  end
end

clients = [['keystone', 'python-keystoneclient'],
           ['swift', 'python-swiftclient'], 
           ['nova', 'python-novaclient'], 
           ['glance', 'python-glanceclient'],
           ['cinder', 'python-cinderclient'],
           ['heat', 'python-heatclient']]

clients.each do |client|
  if try_distro then
    package client[1] do
      action :install
      ignore_failure try_pip
      not_if "which #{client[0]}"
    end
  end

  # If the package install failed, try Pip.
  if try_pip then
    python_pip client[1] do
      not_if "which #{client[0]}"
    end
  end
end

os_tenant_name = node['setup']['openstack_tenant_name']
os_tenant_id = node['setup']['openstack_tenant_id']
os_auth_url = node['setup']['openstack_auth_url']
os_username = node['setup']['openstack_username']
os_password = node['setup']['openstack_password']
os_rc_path = node['setup']['openstack_rc_path']
os_rc_user = node['setup']['openstack_rc_user'] || 'root'
os_rc_group = node['setup']['openstack_rc_group'] || 'root'

if os_tenant_name then
  # If we are use the default rc path, automatically create the parent dir 
  if (File.dirname(os_rc_path) == '/etc/openstack') then
    directory '/etc/openstack' do
      owner 'root'
      mode  0755
    end
  end
  template os_rc_path do
    owner os_rc_user
    group os_rc_group
    mode  0440
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

