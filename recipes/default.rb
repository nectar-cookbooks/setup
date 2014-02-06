#
# Cookbook Name:: setup
# Recipe:: default
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

require 'ipaddr'

if node['setup']['tz'] then
  node.normal['tz'] = node['setup']['tz']
  include_recipe 'timezone-ii::default'
end

if node['setup']['set_fqdn'] then
  include_recipe 'setup::set_hostname'
end

# Workaround for issue #13 ... until I can get the offending recipe fixed.
if platform_family?('rhel', 'debian') then
  include_recipe 'locale'
end

if node['setup']['accounts'] &&
   (node['setup']['accounts']['create_users'] || 
    node['setup']['accounts']['generate_sudoers']) then
  include_recipe 'setup::accounts'
end

if node['setup']['root_email'] then
  include_recipe 'setup::rootmail'
end

if node['setup']['logwatch'] then
  include_recipe 'setup::logwatch'
end

if node['setup']['mail_relay'] then
  include_recipe 'setup::mail_relay'
end

if node['setup']['apply_patches'] then
  include_recipe 'setup::autopatching'
end

if node['setup']['antivirus'] then
  include_recipe 'setup::clamav'
end

if node['setup']['openstack_clients'] then
  include_recipe 'setup::openstack-clients'
end
