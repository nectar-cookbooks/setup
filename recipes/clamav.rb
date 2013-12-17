#
# Cookbook Name:: qcloud
# Recipe:: clamav
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

include_recipe "clamav"

clamav = node['qcloud']['clamav'] || {}

scans = clamav['scans'] || {'/' => {'action' => 'notify',
                                    'exclude_dir' => '^/sys|^/proc|^/dev' }}
schedule = clamav['schedule'] || ['10', '2', '*', '*', '*']
if !schedule.kind_of?(Array) || schedule.length != 5 
  raise 'Cron schedule must be an array with 5 components'
end
common_args = clamav['args'] || ''
commands = []

scans.each() do |dir, attrs|
  action = attrs['action'] || 'notify'

  case action 
  when 'notify'
    args = '-i'
  when 'move'
    move_to = attrs['move_to']
    if ! move_to || move_to == ' ' then
      raise "The 'move' action requires a move_to attribute"
    end
    directory move_to do
      owner 'root'
      mode 0700
    end
    args = "--move=#{move_to}"
  when 'remove'
    args = "--remove"
  else
    raise "Unrecognized action '#{action}'"
  end
  if attrs['exclude_dir'] 
    args = "#{args} --exclude-dir=#{attrs['exclude_dir']}"
  end
  commands << "clamscan --quiet -r #{common_args} #{args} #{dir}"
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

