#
# Cookbook Name:: qcloud
# Recipe:: security_patches
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

case node['platform_family'] 
when 'debian'
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
  ruby_block 'yum-cron-configure' do
    block do
      u = 'Unattended-Upgrade::'
      file = Chef::Util::FileEdit.new('/etc/yum/yum-cron.conf')
      file.search_file_replace_line(/::MinimalSteps/, 
                                    u + 'MinimalSteps "true";')
      file.search_file_replace_line(/::Mail/, 
                                    u + 'Mail "root";')
      file.search_file_replace_line(/::Automatic-Reboot/, 
                                    u + 'Automatic-Reboot "true";')
      file.write_file
    end
  end
when 'fedora'
  package 'yum-cron' do
    action :install
  end
  ruby-block 'yum-cron-configure' do
    block do
      file = Chef::Util::FileEdit.new('/etc/yum/yum-cron.conf')
      file.search_file_replace_line(/^update_cmd =/, 'update = security')
      file.search_file_replace_line(/^emit_via =/, 'emit_via = email')
      file.write_file
    end
  end
end