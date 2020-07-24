# Copyright 2020 Pixar

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

# The Module
module Jamf

  # Classes
  #####################################

  # A building defined in the JSS
  class TimeZone < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    extend Jamf::Immutable
    extend Jamf::UnCreatable
    extend Jamf::UnDeletable

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'time-zones'.freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] zoneId
      #   @return [String]
      zoneId: {
        class: :string,
        identifier: :primary,
        aliases: [:id]
      },

      # @!attribute displayName
      #   @return [String]
      displayName: {
        class: :string,
        identifier: true,
        aliases: [:name]
      },

      # @!attribute [r] region
      #   @return [String]
      region: {
        class: :string
      }
    }.freeze
    parse_object_model

    # The offset from UTC, as a string.
    #
    # This is as it would appear at the end of an ISO8601 formatted time,
    # e.g. -0945 or +1200
    #
    # Note that ISO8601 accepts the formats: +/-hh:mm, +/-hhmm, or +/-hh
    #
    # @return [Integer] The offset from UTC, as a string
    #
    def utc_offset_str
      return @utc_offset_str if @utc_offset_str

      displayName =~ /\(([+-]\d{4})\)/
      @utc_offset_str = Regexp.last_match[1]
    end

    # @return [Integer] The offset from UTC, in seconds
    #
    def utc_offset
      return @utc_offset if @utc_offset

      sign = utc_offset_str[0]
      secs = utc_offset_str[1..2].to_i * 3600
      secs += utc_offset_str[3..4].to_i * 60
      # negate if needed
      @utc_offset =  sign == '+' ? secs : -secs
    end

    # Give a Time object, whats the matching local time in this TimeZone?
    #
    # @param othertime[Time] a Time or Jamf::Timestamp object
    #
    # @return [Time] othertime, in the local time in this time zone
    #
    def localtime(othertime)
      othertime.getlocal utc_offset
    end

  end # class

end # module
