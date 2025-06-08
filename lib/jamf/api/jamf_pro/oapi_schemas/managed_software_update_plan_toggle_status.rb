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
#


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: ManagedSoftwareUpdatePlanToggleStatus
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.14.1-t1740408745756
    #
    # This class may be used directly, e.g instances of other classes may
    # use instances of this class as one of their own properties/attributes.
    #
    # It may also be used as a superclass when implementing Jamf Pro API
    # Resources in ruby-jss. The subclasses include appropriate mixins, and
    # should expand on the basic functionality provided here.
    #
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdatePlanToggleStatusWrapper
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdatePlanToggleStatusWrapper
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ManagedSoftwareUpdatePlanToggleStatus < Jamf::OAPIObject

      # Enums used by this class or others

      STATE_OPTIONS = [
        'NOT_RUNNING',
        'RUNNING',
        'NEVER_RAN'
      ]

      EXIT_STATE_OPTIONS = [
        'UNKNOWN',
        'EXECUTING',
        'COMPLETED',
        'NOOP',
        'FAILED',
        'STOPPED'
      ]

      OAPI_PROPERTIES = {

        # The local server time when the toggle was initiated. Null if state is NEVER_RAN
        # @!attribute startTime
        #   @return [String]
        startTime: {
          class: Jamf::Timestamp,
          nil_ok: true
        },

        # The local server time when the toggle was completed. Null if state is NEVER_RAN
        # @!attribute endTime
        #   @return [String]
        endTime: {
          class: Jamf::Timestamp,
          nil_ok: true
        },

        # Duration in seconds between the start time and end time. "Now" is used when end time is null. Null if state is NEVER_RAN
        # @!attribute elapsedTime
        #   @return [Integer]
        elapsedTime: {
          class: :integer,
          nil_ok: true
        },

        # The current state of the toggle
        # @!attribute state
        #   @return [String]
        state: {
          class: :string,
          enum: STATE_OPTIONS
        },

        # The total number of records that will be deleted
        # @!attribute totalRecords
        #   @return [Integer]
        totalRecords: {
          class: :integer,
          format: 'int64'
        },

        # The total number of records that have been deleted
        # @!attribute processedRecords
        #   @return [Integer]
        processedRecords: {
          class: :integer,
          format: 'int64'
        },

        # The percentage between total and completed records.
        # @!attribute percentComplete
        #   @return [Float]
        percentComplete: {
          class: :number,
          format: 'double'
        },

        # Pretty print of total, processed, and percentage complete
        # @!attribute formattedPercentComplete
        #   @return [String]
        formattedPercentComplete: {
          class: :string
        },

        # Troubleshooting - The exit status code from the toggle processing job. "Unknown" will return when the toggle is running.
        # @!attribute exitState
        #   @return [String]
        exitState: {
          class: :string,
          enum: EXIT_STATE_OPTIONS
        },

        # Troubleshooting - The exit message of the toggle job if it encounters an exception while running. Nominal return is an empty string
        # @!attribute exitMessage
        #   @return [String]
        exitMessage: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # class ManagedSoftwareUpdatePlanToggleStatus

  end # module OAPISchemas

end # module Jamf
