#
# Cookbook Name:: setup
# Recipe:: autopatching
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

target = node['setup']['apply_patches'] || 'none'
if target == 'none' || target == '' then
  return
end

case node['platform_family'] 
when 'debian'
  package 'apt-utils' do
    action :install
  end
  package 'unattended-upgrades' do
    action :install
  end
  package 'mailutils' do
    action :install
  end
  cookbook_file '/etc/apt/apt.conf.d/20auto-upgrades' do
    source 'apt-20auto-upgrades'
    mode 0644
  end
  ruby_block 'ubuntu-unattended-upgrade-configure' do
    block do
      u = 'Unattended-Upgrade::'
      p = '^(//)?' + u
      all_origins = ['updates', 'security', 'stable']
      case target
      when 'all'
        origins = all_origins
      when 'security'
        origins = ['security']
      else
        origins = []
      end

      file = Chef::Util::FileEdit.new('/etc/apt/apt.conf.d/' +
                                      '50unattended-upgrades')
      file.search_file_replace_line(p + 'MinimalSteps ', 
                                    u + 'MinimalSteps "true";')
      file.search_file_replace_line(p + 'Mail ', 
                                    u + 'Mail "root";')
      file.search_file_replace_line(p + 'Automatic-Reboot ', 
                                    u + 'Automatic-Reboot "true";')
      # Since it is not entirely clear what origins will be available,
      # we manage them by toggling the "comment" on relevant lines in
      # the existing files Allowed-Origins list.
      if ! origins.empty? then
        sig = "(\\$\\{distro_id}|Ubuntu)"
        origins.each() do |o|
          # Uncomment line
          pat = "^(//)?(\\s*\"#{sig}.*#{o}\";)$"
          file.search_file_replace_line(pat, '\2')
        end
        all_origins.each() do |o|
          if origins.index(o) == nil then
            # Comment out line
            pat = "^(//)?(\\s*\"#{sig}.*#{o}\";)$"
            file.search_file_replace_line(pat, '//\2')
          end
        end
      end
      file.write_file
    end
  end
  bash 'unattended upgraded tidyup' do
    code 'rm -f /etc/apt/apt.conf.d/50unattended-upgrades.old'
  end
when 'fedora'
  package 'yum-cron' do
    action :install
  end
  ruby_block 'yum-cron-configure' do
    block do
      if target == 'all' then
        cmd = 'default'
      else
        cmd = target
      end
      file = Chef::Util::FileEdit.new('/etc/yum/yum-cron.conf')
      file.search_file_replace_line(/^update_cmd =/, 
                                    "update_cmd = #{cmd}")
      file.search_file_replace_line(/^emit_via =/, 'emit_via = email')
      file.write_file
    end
  end
when 'rhel'
  if target != 'all' then
    # Technically, it is possible to do security on some variants, but
    # it depends on the provider's insfrastructure and / or whether you
    # have an RHN subscription.
    raise "Selective auto-patching is not supported on RHEL-based distros"
  end
  # I'm not sure if this will work for older distros ...
  package 'yum-cron' do
    action :install
  end
  ruby_block 'yum-cron-configure' do
    block do
      file = Chef::Util::FileEdit.new('/etc/sysconfig/yum-cron')
      file.search_file_replace_line(/^update_cmd =/, 'update = security')
      file.search_file_replace_line(/^MAILTO=/, 'MAILTO=root')
      file.search_file_replace_line(/^CHECK_ONLY=/, 'CHECK_ONLY=no')
      file.search_file_replace_line(/^DOWNLOAD_ONLY=/, 'DOWNLOAD_ONLY=no')
      file.write_file
    end
  end
  service 'yum-cron' do
    action :enable
  end
end
