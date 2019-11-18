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

# The module
module Jamf

  # A 'location' for a managed object in Jamf Pro
  class Location < Jamf::JSONObject

    OBJECT_MODEL = {

      # @!attribute username
      #   @param [String]
      #   @return [String]
      username: {
        class: :string
      },

      # @!attribute realName
      #   @param [String]
      #   @return [String]
      realName: {
        class: :string
      },

      # @!attribute emailAddress
      #   @param [String]
      #   @return [String]
      emailAddress: {
        class: :string
      },

      # @!attribute position
      #   @param [String]
      #   @return [String]
      position: {
        class: :string
      },

      # @!attribute phoneNumber
      #   @param [String]
      #   @return [String]
      phoneNumber: {
        class: :string
      },

      # @!attribute department
      #   @param [String]
      #   @return [String]
      department: {
        class: Jamf::Department::Reference
      },

      # @!attribute building
      #   @param [String]
      #   @return [String]
      building: {
        class: Jamf::Building::Reference
      },

      # @!attribute room
      #   @param [String]
      #   @return [String]
      room: {
        class: :string
      }
    }.freeze

    parse_object_model

  end # class location

end # module
