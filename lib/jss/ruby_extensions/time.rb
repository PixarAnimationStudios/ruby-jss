### Copyright 2014 Pixar
###  
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###  
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###  
###    You may obtain a copy of the Apache License at
###  
###        http://www.apache.org/licenses/LICENSE-2.0
###  
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
### 
###

############################################
### The JSS API can take incoming timestamp data in three formats:
### - plain date: YYYY-mm-dd HH:MM:SS, which is assumed to be in the local timezone
### - UTC date: YYYY-mm-ddTHH:MM:SS.mmm [+-]zzzz, the local time with milliseconds and the timezone offset
### - Unix epoch with milliseconds, nnnnnnnnnnnnn,  which like all epoch times, is UTC
###
### Here we extend Time to return the three formats for use in XML data to pass
### back to the API. The API xml works with any of the formats, in appropriate elements.
###
### Generally this gem uses the epoch format for passing values back to the API, just to help avoid
### timezone weirdness, but any should work.
###
### When reading from the API, all three formats are returned in different xml elements,
### and the APIObjects in the gem will use the epoch format and the JSS.epoch_to_time method (q.v.) to store
### the data as a Ruby Time.
###
class Time

  ### @return [Integer] the milliseconds of the Time
  def jss_msec
    (self.usec/1000.0).round
  end

  ### @return [Integer] The Time as a unix epoch with milliseconds appended
  def to_jss_epoch
    (self.strftime('%s') + self.jss_msec.to_s.ljust(3,'0')).to_i
  end

  ### @return [String] the Time formatted for a plain JSS XML date element
  def to_jss_date
    self.strftime '%Y-%m-%d %H:%M:%S'
  end

  ### @return [String] the Time formatted for a JSS UTC XML date element
  def to_jss_utc
    self.strftime("%Y-%m-%dT%H:%M:%S.#{self.jss_msec}%z")
  end

end
