#
# Cookbook Name:: setup
# Recipe:: clamav
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

# Workaround for a bug in the standard ClamAV recipe.  (If this works,
# it should be turned into a patch and submitted.)
if node.default['clamav']['user'] == 'clamav' then
  if platform_family?('rhel') then
    node.default['clamav']['user'] = 'clam'
  elsif platform_family?('fedora') then
    node.default['clamav']['user'] = 'clamupdate'
  else
    node.default['clamav']['user'] = 'clamav'
  end
end
if node.default['clamav']['group'] == 'clamav' then
  node.default['clamav']['group'] = node.default['clamav']['user']
end

include_recipe "clamav"

clamscan = node['setup']['clamscan']
scans = clamscan['scans'] 
schedule = clamscan['schedule']
if !schedule.kind_of?(Array) || schedule.length != 5 
  raise 'Cron schedule must be an array with 5 components'
end
common_args = clamscan['args']
commands = []

scans.each() do |dir, attrs|
  action = attrs['action'] || 'notify'

  case action 
  when 'notify'
    args = '-i'
  when 'move', 'copy'
    to_dir = attrs['to_dir']
    if ! to_dir || to_dir == '' then
      raise "The 'move' and 'copy' actions require a 'to_dir' attribute"
    end
    directory to_dir do
      owner 'root'
      mode 0700
    end
    args = "--#{action}=#{to_dir}"
  when 'remove'
    args = "--remove"
  else
    raise "Unrecognized action '#{action}'"
  end
  if attrs['exclude_dir'] 
    args = "#{args} --exclude-dir='#{attrs['exclude_dir']}'"
  end
  commands << "clamscan #{common_args} #{args} #{dir}"
end

if ! commands.empty? 
  cron 'clamav scanning' do
    minute schedule[0]
    hour schedule[1]
    day schedule[2]
    month schedule[3]
    weekday schedule[4]
    mailto 'root'
    command commands.join("; ")
  end
end
