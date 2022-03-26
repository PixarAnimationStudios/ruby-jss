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

module Jamf

  # A single entry in a resource's change history.
  # This class is read-only
  #
  class ChangeLogEntry < Jamf::JSONObject

    extend Jamf::Immutable

    OBJECT_MODEL = {

      # @!attribute [r] id
      #  @return [String] The Jamf Pro user who made the change or note.
      id: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] username
      #  @return [String] The Jamf Pro user who made the change or note.
      username: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] date
      #  @return [Jamf::Timestamp] When the change was made
      date: {
        class: Jamf::Timestamp,
        readonly: true
      },

      # @!attribute [r] notes
      #  @return [String] Notes entered manually or via the API.
      note: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] details
      #  @return [String] Details of the change
      details: {
        class: :string,
        readonly: true
      }
    }.freeze

    # Must call parse_object_model to turn the OBJECT_MODEL into
    # attributes

  end # class

end # module
