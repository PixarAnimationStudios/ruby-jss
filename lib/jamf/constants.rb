# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  # Constants useful throughout ruby-jss
  # This should be included into the Jamf module
  #####################################
  module Constants

    # The minimum Ruby version needed for ruby-jss
    MINIMUM_RUBY_VERSION = '2.6.3'.freeze

    # These are handy for testing values without making new arrays, strings, etc every time.
    TRUE_FALSE = [true, false].freeze

    # When parsing a date/time data into a Time object, these will return nil
    NIL_DATES = [0, nil, '', '0'].freeze

    # Empty strings are used in various places
    BLANK = ''.freeze

  end # module constants

end # module Jamf
