#
# Cookbook Name:: qcloud
# Recipe:: setup
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

require 'ipaddr'

if node['qcloud']['tz'] then
  node.normal['tz'] = node['qcloud']['tz']
  include_recipe 'timezone-ii::default'
end

if node['qcloud']['set_fqdn'] then
  include_recipe 'qcloud::set_hostname'
end

if node['qcloud']['root_email'] then
  include_recipe 'qcloud::rootmail'
end

if node['qcloud']['logwatch'] then
  # Temporary workaround for a change in logwatch between 7.3.6 and 7.4.0 
  # which makes the logwatch recipe's default 'output' attribute invalid.
  if platform_family?("rhel")
    node.override['logwatch']['output'] = 'unformatted'
  end
  include_recipe 'logwatch::default'
end

if node['qcloud']['mail_relay'] then
  include_recipe 'qcloud::mail_relay'
end

if node['qcloud']['apply_patches'] then
  include_recipe 'qcloud::autopatching'
end

if node['qcloud']['antivirus'] then
  include_recipe 'qcloud::clamav'
end
