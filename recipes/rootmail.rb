#
# Cookbook Name:: setup
# Recipe:: rootmail
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


root_email = node['setup']['root_email'] || []
if root_email.is_a? String then
  root_email = [ root_email ]
end

# Check and clean up the email list.  Emails must be in 'user' or
# 'user@domain' form.  
cleaned_root_email = []
root_email.each do |email|
  email = email.strip
  parts = email.split('@')
  if parts.length > 2 then
    raise "Invalid root_email address: '#{email}' - bad syntax"
  elsif parts.length == 1 then
    cleaned_root_email << email
  elsif parts.length == 2 then
    user = parts[0].strip
    domain = parts[1].strip
    if user.length == 0 then
      raise "Invalid root_email address: '#{email}' - empty username"
    end
    if domain.length == 0 then 
      raise "Invalid root_email address: '#{email}' - empty domain"
    end
    # If the 'domain' is not recognizable as "this host", then we must
    # have a 'mail_relay' set up
    if node['setup']['mail_relay'] then
      domain = domain.downcase
      if ! ['localhost', node['hostname'].downcase, 
            node['fqdn'].downcase].contains(domain) then
        raise "'mail_relay' must be set for an off-host 'root_mail'"
      end
    end
    cleaned_root_email << "#{user}@#{domain}"
  end
end

bash "newaliases" do
  command "/usr/bin/newaliases"
  action :nothing
end

ruby_block "update_root_alias" do
  block do
    file = Chef::Util::FileEdit.new('/etc/aliases')
    if cleaned_root_email.length > 0 then
      root_alias = "root:\t\t#{cleaned_root_email.join(', ')}"
      file.search_file_replace_line(/^\s*root\s*:/, root_alias)
      file.insert_line_if_no_match(/^\s*root\s*:/, root_alias)
    else
      file.search_file_delete_line(/^\s*root\s*:/)
    end
    file.write_file
  end
  only_if { File.exists?('/etc/aliases') }
  notifies :run, "bash[newaliases]"
end
