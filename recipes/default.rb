#
# Cookbook Name:: qcloud
# Recipe:: default
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

include_recipe "autofs::default"

# Validate the Store ids
node['qcloud']['stores'].each() do |store_id|
  if ! /Q[0-9][0-9]([0-9][0-9])?/.match(store_id) then
    raise "Invalid store id (#{store_id}) : expected Qnn or Qnnnn"
  end
  num = /Q([0-9]+)/.match(store_id)[1].to_i()
  if num <= 0 then
    raise "Invalid store id (#{store_id}) : there is no store zero"
  elsif num <= 5 and ! /Q[0-9][0-9]/.match(store_id) then
    raise "Invalid store id (#{store_id}) : stores 1 through 5 have form Qnn"
  elsif num > 5 and ! /Q[0-9][0-9][0-9][0-9]/.match(store_id) then
    raise "Invalid store id (#{store_id}) : stores > 5 have form Qnnnn"
  end
end

# Configure private network

# Create local users to match the standard uids in the collection filesystems.
if node['qcloud']['create_users'] then
  user 'webdav' do
    uid 48
    gid 48
    system true
    comment 'WebDAV'
    shell '/sbin/nologin'
  end
  node['qcloud']['stores'].each() do |store_id|
    num = /Q[0-9]+/.match(store_id).to_i()
    if num > 999 then
      raise "The store_id to uid mapping is not defined for #{store_id}"
    end
    user store_id.downcase() do
      uid 54000 + num
      gid 54000 + num
      system false
      home "/data/#{store_id}"
      comment ''
      shell '/sbin/nologin'
    end
  end  
end

# Create autofs mounts

# Restart autofs
