# Copyright 2025 Pixar

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
