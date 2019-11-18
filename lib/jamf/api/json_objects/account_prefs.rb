# Copyright 2019 Pixar

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

  # Preferences for an administrator account in the JSS
  class AccountPreferences < Jamf::JSONObject

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] language
      #   @return [String]
      language: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] dateFormat
      #   @return [String]
      dateFormat: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] region
      #   @return [String]
      region: {
        class: :string,
        readonly: true
      },
      # @!attribute [r] timezone
      #   @return [String]
      timezone: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] isDisableRelativeDates
      #   @return [String]
      isDisableRelativeDates: {
        class: :boolean,
        readonly: true
      }
    }.freeze
    parse_object_model

  end # class

end # module
