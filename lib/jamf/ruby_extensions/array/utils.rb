# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

module JamfRubyExtensions

  module Array

    # Useful monkey patches for Array
    module Utils

      # Fetch a string from an Array case-insensitively,
      # e.g. if my_array contains 'thrasher',
      #    my_array.j_ci_fetch('ThRashEr')
      # will return 'thrasher'
      #
      # returns nil if no match
      #
      # @param somestring [String] the String to search for
      #
      # @return [String, nil] The matching string as it exists in the Array,
      #   nil if it doesn't exist
      #
      def j_ci_fetch(somestring)
        each { |s| return s if s.respond_to?(:casecmp?) && s.casecmp?(somestring) }
        nil
      end
      alias jss_ci_fetch_string j_ci_fetch

    end # module

  end # module

end # module
