### Copyright 2022 Pixar

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


### The Classic API can take incoming timestamp data in three formats:
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

module JamfRubyExtensions

  module Time

    module Utils

      ### @return [Integer] the milliseconds of the Time
      def j_msec
        strftime('%L').to_i
      end
      alias jss_msec j_msec

      ### @return [Integer] The Time as a unix epoch with milliseconds appended
      def to_j_epoch
        msec = strftime('%L').rjust(3, "0")
        epoch = strftime('%s')
        "#{epoch}#{msec}".to_i
      end
      alias to_jss_epoch to_j_epoch

      ### @return [String] the Time formatted for a plain JSS XML date element
      def to_j_date
        strftime '%Y-%m-%d %H:%M:%S'
      end
      alias to_jss_date to_j_date

      ### @return [String] the Time formatted for a JSS UTC XML date element
      def to_j_utc
        strftime("%Y-%m-%dT%H:%M:%S.#{j_msec}%z")
      end
      alias to_jss_utc to_j_utc

    end

  end

end
