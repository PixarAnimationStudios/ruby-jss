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

module JamfRubyExtensions

  module String

    module BackPorts

      # Ruby 2.5 + has these handy delete_* methods
      unless Jamf::BLANK.respond_to? :delete_prefix

        def delete_prefix(pfx)
          sub /\A#{pfx}/, Jamf::BLANK
        end

        def delete_prefix!(pfx)
          sub! /\A#{pfx}/, Jamf::BLANK
        end

        def delete_suffix(sfx)
          sub /#{sfx}\z/, Jamf::BLANK
        end

        def delete_suffix!(sfx)
          sub! /#{sfx}\z/, Jamf::BLANK
        end

      end # unless

      # String#casecmp? - its in Ruby 2.4+
      unless Jamf::BLANK.respond_to? :casecmp?

        def casecmp?(other)
          return nil unless other.is_a? String

          casecmp(other).zero?
        end

      end # unless

    end # module

  end # module

end # module
