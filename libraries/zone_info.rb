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

module ZoneInfo
  # These are the known production and preproduction NeCTAR zones 
  # as of 26/5/2014
  ZONE_RANGES = 
    [
     { 'node' => 'QCIF',
       'zone' => 'qld',
       'start' => '130.102.154.0',
       'end' => '130.102.155.255'},
     { 'node' => 'QCIF',
       'zone' => 'qriscloud',
       'start' => '203.101.224.0',
       'end' => '203.101.239.255'},
     { 'node' => 'eRSA',
       'zone' => 'SA',
       'start' => '130.220.208.0',
       'end' => '130.220.223.255'},
     { 'node' => 'University of Melbourne',
       'zone' => 'melbourne-np',
       'start' => '115.146.92.0',
       'end' => '115.146.95.255'},
     { 'node' => 'University of Melbourne',
       'zone' => 'melbourne-qh2',
       'start' => '115.146.84.0',
       'end' => '115.146.87.255'},
     { 'node' => 'Monash',
       'zone' => 'monash',
       'start' => '118.138.240.0',
       'end' => '118.138.247.255'},
     { 'node' => 'NCI',
       'zone' => 'NCI',
       'start' => '130.56.248.0',
       'end' => '130.56.255.255'}
    ]

  # Lookup and return the zone_range for the address range that contains
  # an IP address.  Return nil if the IP is not in a known NeCTAR zone.
  def ip2ZoneRange(ip) 
    ZONE_RANGES.each() do |zi|
      puts "ip = #{ip}, start = #{zi['start']}, end = #{zi['end']}/n"
      if zi['start'] <=> ip >= 0 and zi['end'] <=> ip <= 0
        return zi
      end
    end
    return nil
  end
end
