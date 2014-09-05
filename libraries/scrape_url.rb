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

module ScrapeUrl

  # Fetch a page with a download link or links in it, and scrape the first
  # URL that contains a given pattern.  The *rest arguments are passed 
  # to OpenURI.open_uri.
  def scrapeUrl(regex, page_url, *rest)
    url = scrapeUrls({'url' => regex}, page_url, *rest)['url']
    if url then
      return url
    end
    source = regex.kind_of?(String) ? regex : regex.source
    raise "Can't find a URL matching /#{source}/ in page #{page_url}"
  end

  # Fetch a page with a download link or links in it, and scrape multiple
  # URLs, one for each pattern.  The regexes are supplied as a hash. 
  # The *rest options passed to OpenURI.open_uri.  
  # The result is a ney hash with the same keys as the 'regexes' hash,
  # and urls as values.
  def scrapeUrls(regexes, page_url, *rest)
    # Turn the supplied regexes (for URL substrings) into regexes
    # to match and extract the entire url (in quotes) from the HTML.
    full_regexes = {}
    urls = {}
    regexes.each do |key,regex|
      source = regex.kind_of?(String) ? regex : regex.source
      full_regexes[key] = 
        Regexp.new("(['\"])([^'\"]*#{source}[^'\"]*)\\1")
    end
    OpenURI.open_uri(page_url, *rest) do |f|
      if f.status[0] != '200' then
        raise "Unable to fetch page #{page_url}: status = #{f.status}"
      end
      f.each do |line|
        full_regexes.each do |key,regex|
          unless urls[key] then
            m = regex.match(line)
            if m then
              urls[key] = m[2]
            end
          end
        end
      end
    end
    return urls
  end
end
