# Copyright 2023 Pixar

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

  # A timestamp as used in the Jamf Pro API JSON data
  #
  # Instantiate with any of:
  #   - A string parsable by Time.parse. Timestamps from the API are always
  #     strings in iso6801 format
  #   - a Time or Jamf::Timestamp instance
  #   - an Integer, or Stringified Integer, a unix epoch value. If it is
  #     1_000_000_000_000 or higher, it is treated as a Jamf-stype epoch,
  #     meaning the last 3 digits are milliseconds.
  #   - nil or an empty string, which will 'unset' a time value with an empty
  #     string when sent back to the API
  #
  # To unset a timestamp value in the API, instantiate one of these with
  # nil or an empty string. The Time value will be '1970-01-01 00:00:00 -0000',
  # the unix epoch, and the to_jamf method will return an empty string, which
  # is what will be sent to the API
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
  # Use #to_jamf to get the formated string to use in JSON for sending to the
  # API - it *should* always be in ISO8601 format, or an empty string.
  #
  class Timestamp < ::Time

    # When we are unsetting a timestamp by intializing with nil,
    # we still have to have a time object - so use the unix epoch
    NIL_TIMESTAMP = Time.at 0

    # Integers with this value or higher are a jamf-style epoch,
    # meaning the first 10 digits are a unix epoch, and the last 3
    # are milliseconds. Integers below this shouldn't appear, but
    # will be treated as a regular unix epoch.
    # (999_999_999_999 = 33658-09-27 01:46:39 UTC)
    J_EPOCH_INT_START = 1_000_000_000_000

    # Stings containing integers of this length are a jamf-style epoch,
    # meaning the first 10 digits are a unix epoch, and the last 3
    # are milliseconds. This length-test will be valid until the year 2286.
    J_EPOCH_STR_LEN = 13

    # @param tstamp[String,Integer,Time] A representation of a timestampe
    #
    def initialize(tstamp)
      # use a Time object to parse the input and generate our own
      # object
      time = parse_init_tstamp(tstamp)

      super(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        (time.sec + (time.usec / 1_000_000.0)).round(3),
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

    # Private Instance Methods
    ################################
    private

    # @param tstamp @see #initialize
    # @return [Time]
    def parse_init_tstamp(tstamp)
      case tstamp
      when Time
        tstamp

      when Integer
        Time.at real_epoch_from_j_epoch(tstamp)

      when /^\d+$/
        Time.at real_epoch_from_j_epoch(tstamp.to_i)

      when Jamf::BLANK, nil
        @empty_timestamp = true
        NIL_TIMESTAMP

      else
        Time.parse tstamp.to_s
      end # case
    end

    # convert an integer into a float if needed for parsing
    # @param j_epoch [Integer]
    # @return [Integer, Float]
    def real_epoch_from_j_epoch(j_epoch)
      j_epoch >= J_EPOCH_INT_START ? (j_epoch / 1000.0) : j_epoch
    end

  end # class  Timestamp

end # module
