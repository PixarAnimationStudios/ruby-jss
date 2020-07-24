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

# The module
module Jamf

  # A 'location' for a computer prestage in Jamf Pro
  class PrestageLocation < Jamf::JSONObject

    include Jamf::Lockable

    OBJECT_MODEL = {

      # @!attribute id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary
      },

      # @!attribute username
      #   @param [String]
      #   @return [String]
      username: {
        class: :string
      },

      # @!attribute realName
      #   @param [String]
      #   @return [String]
      realname: {
        class: :string
      },

      # @!attribute emailAddress
      #   @param [String]
      #   @return [String]
      email: {
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
      phone: {
        class: :string
      },

      # @!attribute department
      #   @param [integer]
      #   @return [integer]
      departmentId: {
        class: :integer
      },

      # @!attribute building
      #   @param [integer]
      #   @return [integer]
      buildingId: {
        class: :integer
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
