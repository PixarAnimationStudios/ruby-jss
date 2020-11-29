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

  # An assignment of a device to a prestage, placing that
  # device into the prestage's scope
  class PrestageAssignment < Jamf::JSONObject

    extend Jamf::Immutable

    OBJECT_MODEL = {

      # @!attribute serialNumber
      #   @return [String]
      serialNumber: {
        class: :string
      },

      # @!attribute assignmentEpoch
      #   @return [Integer]
      assignmentDate: {
        class: Jamf::Timestamp
      },

      # @!attribute userAssigned
      #   @return [String]
      userAssigned: {
        class: :string,
        aliases: %i[assignedBy]
      }
    }.freeze

    parse_object_model

    # The assignment epoch as a Jamf::Timestamp object.
    #
    # NOTE: I expct this will go away once Jamf conforms to its own standard
    # of exchanging ALL timestamp data as ISO6801 strings. At that time
    # the assignment epoch won't be a thing anymore.
    #
    # @return [Jamf::Timestamp]
    #
    attr_reader :assignmentTimestamp

    def initialize(*args)
      super
      @assignmentTimestamp = Jamf::Timestamp.new @assignmentEpoch
    end

  end # class Country

end # module
