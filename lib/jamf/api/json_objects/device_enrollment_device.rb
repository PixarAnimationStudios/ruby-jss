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

# The Module
module Jamf

  # Classes
  #####################################

  # A decvice enrollment defined in the JSS
  # This is a connection to Apple's Device Enrollment Program.
  # A single Jamf server may have many of them, and they can belong to
  # different sites.
  #
  # These objects can be used to find the details of all the devices
  # connected to them, including the device serial numbers.
  # To see how or if those devices are assigned to prestages, see
  # Jamf::Prestage and its subclasses ComputerPrestage and MobileDevicePrestage
  #
  class DeviceEnrollmentDevice < Jamf::JSONObject

    # Mix-Ins
    #####################################

    extend Jamf::Immutable

    # Constants
    #####################################

    PROFILE_STATUS_EMPTY = 'EMPTY'.freeze
    PROFILE_STATUS_ASSIGNED = 'ASSIGNED'.freeze
    PROFILE_STATUS_PUSHED = 'PUSHED'.freeze
    PROFILE_STATUS_REMOVED = 'REMOVED'.freeze

    PROFILE_STATUSES = [
      PROFILE_STATUS_EMPTY,
      PROFILE_STATUS_ASSIGNED,
      PROFILE_STATUS_PUSHED,
      PROFILE_STATUS_REMOVED
    ].freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute id
      #   @return [String]
      id: {
        class: :j_id,
        identifier: true
      },

      # @!attribute deviceEnrollmentProgramInstanceId
      #   @return [String]
      deviceEnrollmentProgramInstanceId: {
        class: :j_id,
        aliases: %i[instanceId]
      },

      # @!attribute prestageId
      #   The most recent prestage this device was assigned to, even if
      #   currently unassigned to any prestage.
      #   @return [String]
      prestageId: {
        class: :j_id
      },

      # @!attribute serialNumber
      #   @return [String]
      serialNumber: {
        class: :string
      },

      # @!attribute description
      #   @return [String]
      description: {
        class: :string
      },

      # @!attribute model
      #   @return [String]
      model: {
        class: :string
      },

      # @!attribute color
      #   @return [String]
      color: {
        class: :string
      },

      # @!attribute assetTag
      #   @return [String]
      assetTag: {
        class: :string
      },

      # @!attribute profileStatus
      #   @return [String]
      profileStatus: {
        class: :string,
        enum: PROFILE_STATUSES
      },

      # @!attribute syncState
      #   @return [DeviceEnrollmentDeviceSyncState]
      syncState: {
        class: Jamf::DeviceEnrollmentDeviceSyncState
      },

      # @!attribute profileAssignTime
      #   @return [Jamf::Timestamp]
      profileAssignTime: {
        class: Jamf::Timestamp
      },

      # @!attribute profilePushTime
      #   @return [Jamf::Timestamp]
      profilePushTime: {
        class: Jamf::Timestamp
      },

      # @!attribute deviceAssignedDate
      #   When Apple assigned this device to this DevEnrollment instance
      #   @return [Jamf::Timestamp]
      deviceAssignedDate: {
        class: Jamf::Timestamp
      }
    }.freeze

    parse_object_model

    # Class Methods
    #########################################

    # Instance Methods
    #########################################

  end # class

end # module
