# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

module JamfRubyExtensions

  module String

    module Conversions

      # Convert the strings "true" and "false"
      # (after stripping whitespace and downcasing)
      # to TrueClass and FalseClass respectively
      #
      # Return nil if any other string.
      #
      # @return [Boolean,nil] the boolean value
      #
      def j_to_bool
        case strip.downcase
        when 'true' then true
        when 'false' then false
        end # case
      end # to bool
      alias jss_to_bool j_to_bool

      # Convert a string to a Jamf::Timestamp object
      #
      # @return [Time] the time represented by the string.
      #
      def j_to_timestamp
        Jamf::Timestamp.new self
      end

      # Convert a string to a Time object
      #
      # @see Jamf.parse_time
      #
      # @return [Time] the time represented by the string, or nil
      #
      def j_to_time
        Jamf.parse_time self
      rescue
        nil
      end
      alias jss_to_time j_to_time

      # Convert a String to a Pathname object
      #
      # @return [Pathname]
      #
      def j_to_pathname
        Pathname.new self
      end
      alias jss_to_pathname j_to_pathname

    end # module

  end # module

end # module
