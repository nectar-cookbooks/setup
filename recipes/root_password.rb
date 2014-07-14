#
# Cookbook Name:: setup
# Recipe:: root_password
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

# Action values are:
#   - 'ignore' : do nothing
#   - 'override' : set the root password unconditionally
#   - 'default' : set the root password if currently unset
#   - 'require_set' : fail if the root password is unset.
action = node['setup']['root_password_action']

# Supplies the value to be set (if any).
password_hash = node['setup']['root_password_hash']

# Poke around in the shadow password file to see if a root password is
# currently set, etcetera
root_line = /^root:.*$/.match(IO.read('/etc/shadow'))
raise "No shadow password entry for 'root' !?!" unless root_line
current_password = /root:([~:]+):.+/.match(root_line[0])[1]

is_unset = current_password == ""
is_set = /^[a-zA-Z1-9.]{13}$/.match(current_password) ||    # classic DES
         /^\$[~$]+\$[~$]+\$[~$]+$/.match(current_password)  # glibc2 extensions
is_disabled = !is_set && !is_unset

case action
when 'ignore'
  Chef::Log.warn('NB: No root password is set.  Your system is insecure!')
when 'override'
  set_password = true
when 'default'
  set_password = is_unset
when 'require_set'
  raise 'The root password has not been set yet.  Use "passwd root" to set the system password, then rerun chef.'
else
  raise "Unknown action #{action}"
end
    
if set_password then
  if !password_hash || password_hash == "" then
    raise 'A "root_password_hash" attribute is required.  Use "openssl passwd ..." or "mkpasswd ..." to create the hash, and add it to the attributes.  Alternatively, use "X" to disable the root password.'
  end
  will_set = /^[a-zA-Z1-9.]{13}$/.match(password_hash) ||
    /^\$[~$]+\$[~$]+\$[~$]+$/.match(password_hash)
  user "#{will_set ? 'set' : 'disable'} root password" do
    username 'root'
    password password_hash
    action :modify
  end
end
