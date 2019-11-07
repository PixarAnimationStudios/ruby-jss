# Copyright 2018 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

module Jamf

  # a timestamp as used in the JAMF API JSON data
  #
  # Instantiate with a String in iso6801 format (used in the API JSON for
  # all time/date values), or with a Time or Jamf::Timestamp instance, or with
  # an Integer unix epoch, which is treated Jamf-style if 1_000_000_000_000 or
  # higher
  #
  # To unset a timestamp value, instantiate with nil or an empty string. The
  # Time value will be '1970-01-01 00:00:00 -0000', the unix epoch,
  # and the to_jamf method will return an empty string.
  #
  # NOTE: Passing '1970-01-01 00:00:00 -0000' or the equivalent explicitly
  # will NOT be treated as an empty timestamp, but as that actual value.
  # You must pass nil or an empty string to indicate an empty value
  #
  # TODO: Find out: will an empty string work, e.g. in ext attrs with a DATE
  # value, when used in criteria?
  #
  # This class is a subclass of Time, so all Time methods are available.
  # - use .to_i for a unix epoch in seconds
  # - use .to_f for a unix epoch with fractions
  #
  # Use #to_jamf to get the formated string to use in API JSON.
  #
  class Timestamp < Time

    # When we are unsetting a timestamp by intializing with nil,
    # we still have to have a time object - so use the unix epoch
    NIL_TIMESTAMP = Time.at 0

    # Integers with this value or higher are jamf-style epoch,
    # meaning the first 10 digits are a unix epoch, and the last 3
    # are milliseconds
    EPOCH_WITH_MSECS = 1_000_000_000_000

    # @param stamp[String,Integer,Time]
    #
    # @param _args [void] unused, but required for JSONObject init.
    #
    def initialize(stamp, **_args)
      time =
        case stamp
        when Time
          stamp

        when Integer
          Time.at(stamp >= EPOCH_WITH_MSECS ? (stamp / 1000.0) : stamp)

        when Jamf::BLANK
          @empty_timestamp = true
          NIL_TIMESTAMP

        when /^\d+$/
          Time.at(stamp.length == 13 ? (stamp.to_i / 1000.0) : stamp.to_i)

        else
          Time.parse stamp.to_s
        end # case

      super(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        "#{time.sec}.#{time.usec / 1000}".to_f,
        time.utc_offset
      )
    end

    # @return [Integer] the milliseconds of the Time
    def msec
      return 0 if @empty_timestamp

      (usec / 1000.0).round
    end

    # @return [String] the timestamp formatted for passing to the API as a string.
    def to_jamf
      return Jamf::BLANK if @empty_timestamp

      iso8601
    end

    def to_jamf_epoch
      (to_f.round(3) * 1000).to_i
    end

  end # class  Timestamp

end # module
