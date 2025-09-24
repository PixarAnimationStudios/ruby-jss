# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module JamfRubyExtensions

  module Array

    module Predicates

      # A case-insensitive version of #include? for Arrays of Strings.
      #
      # @param somestring [String] the String to search for
      #
      # @return [Boolean] Does the Array contain the String, ignoring case?
      #
      def j_ci_include_string?(somestring)
        any? { |s| s.to_s.casecmp? somestring }
      end
      alias jss_ci_include_string? j_ci_include_string?
      alias j_ci_include? j_ci_include_string?

    end # module

  end # module

end # module
