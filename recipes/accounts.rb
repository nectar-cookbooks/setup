#
# Cookbook Name:: setup
# Recipe:: accounts
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

if node['setup']['accounts']['generate_sudoers'] then
  admin_group = (node['setup']['accounts']['admin_group'] || 'wheel').strip
  admin_user = (node['setup']['accounts']['admin_user'] || '').strip
  if admin_user.empty? then
    # Heuristic based on the (known) history of admin account names used
    # in NeCTAR standard images.
    if platform_family?('rhel', 'fedora') then
      admin_users = ['ec2-user', 'centos']
    elsif platform('ubuntu') then
      admin_users = ['ubuntu']
    elsif platform('debian') then
      admin_users = ['debian']
    else
      # Please let me know if this happens ...
      raise "Cannot deduce an admin account name for this" +
            "system - platform #{node.platform} not supported (yet)" 
    end
    admin_users.each do | candidate | 
      # Test if account exists ...
      cmd = Mixlib::ShellOut("id -u #{candidate}").run_command
      if cmd.exitstatus == 0 then
        admin_user = candidate
        break
      end
    end
    if admin_user.empty? then
      # Please let me know if this happens ...
      raise "Cannot deduce the admin account name for this system: " +
            "tried #{admin_users.join(', ')}"
    end
  end
  passwordless = node['setup']['accounts']['passwordless_sudo'] || false  

  if ! admin_group.empty? then
    node.default['authorization']['sudo']['groups'] = [admin_group]
  end
  if admin_user != 'none' then
    node.default['authorization']['sudo']['include_sudoers_d'] = true
  end
  node.default['authorization']['sudo']['passwordless'] = passwordless
  
  include_recipe "sudo::default"
  
  if admin_user != 'none' then
    # Create the passwordless sudoers entry for the admin account.
    sudo 'admin_ac' do
      nopasswd true
      user admin_user
    end
  end
end

if node['setup']['accounts']['create_users'] then
  include_recipe "users"
  users_manage "admin" do
    data_bag "users"
    group_name "wheel"
  end
end

