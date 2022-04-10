# Copyright 2022 Pixar

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

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  # Constants used at the top-level of the Jamf module.
  # This should be included into the Jamf module
  #####################################
  module Constants

    # The minimum Ruby version that works with this gem
    MINIMUM_RUBY_VERSION = '2.7.0'.freeze

    # The minimum JSS version that works with this module, as returned by the API
    # in the deprecated 'jssuser' resource
    MINIMUM_SERVER_VERSION = '10.4.0'.freeze

    # The current local UTC offset as a fraction of a day  (Time.now.utc_offset is the offset in seconds,
    # 60*60*24 is the seconds in a day)
    TIME_ZONE_OFFSET =  Rational(Time.now.utc_offset, 60 * 60 * 24)

    # These are handy for testing values without making new arrays, strings, etc every time.
    TRUE_FALSE = [true, false].freeze

    # When parsing a date/time data into a Time object, these will return nil
    NIL_DATES = [0, nil, '', '0'].freeze

    # Empty strings are used in various places
    BLANK = ''.freeze

  end # module constants

end # module Jamf
