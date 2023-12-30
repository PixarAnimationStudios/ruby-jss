# Copyright 2023 Pixar
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


    # OAPI Object Model and Enums for: ManagedSoftwareUpdateStatus
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.50.0-t1693149930
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
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdateStatuses
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
    class ManagedSoftwareUpdateStatus < Jamf::OAPIObject

      # Enums used by this class or others

      STATUS_OPTIONS = [
        'DOWNLOADING',
        'IDLE',
        'INSTALLING',
        'INSTALLED',
        'ERROR',
        'DOWNLOAD_FAILED',
        'DOWNLOAD_REQUIRES_COMPUTER',
        'DOWNLOAD_INSUFFICIENT_SPACE',
        'DOWNLOAD_INSUFFICIENT_POWER',
        'DOWNLOAD_INSUFFICIENT_NETWORK',
        'INSTALL_INSUFFICIENT_SPACE',
        'INSTALL_INSUFFICIENT_POWER',
        'INSTALL_PHONE_CALL_IN_PROGRESS',
        'INSTALL_FAILED',
        'UNKNOWN'
      ]

      OAPI_PROPERTIES = {

        # @!attribute osUpdatesStatusId
        #   @return [String]
        osUpdatesStatusId: {
          class: :string
        },

        # @!attribute device
        #   @return [Hash{Symbol: Object}]
        device: {
          class: :hash
        },

        # @!attribute downloadPercentComplete
        #   @return [Float]
        downloadPercentComplete: {
          class: :number
        },

        # @!attribute downloaded
        #   @return [Boolean]
        downloaded: {
          class: :boolean
        },

        # @!attribute productKey
        #   @return [String]
        productKey: {
          class: :string
        },

        # @!attribute status
        #   @return [String]
        status: {
          class: :string,
          enum: STATUS_OPTIONS
        },

        # not applicable to all managed software update statuses
        # @!attribute deferralsRemaining
        #   @return [Integer]
        deferralsRemaining: {
          class: :integer
        },

        # not applicable to all managed software update statuses
        # @!attribute maxDeferrals
        #   @return [Integer]
        maxDeferrals: {
          class: :integer
        },

        # not applicable to all managed software update statuses
        # @!attribute nextScheduledInstall
        #   @return [Jamf::Timestamp]
        nextScheduledInstall: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # not applicable to all managed software update statuses
        # @!attribute pastNotifications
        #   @return [Array<Jamf::Timestamp>]
        pastNotifications: {
          class: Jamf::Timestamp,
          multi: true
        },

        # @!attribute created
        #   @return [Jamf::Timestamp]
        created: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute updated
        #   @return [Jamf::Timestamp]
        updated: {
          class: Jamf::Timestamp,
          format: 'date-time'
        }

      } # end OAPI_PROPERTIES

    end # class ManagedSoftwareUpdateStatus

  end # module OAPISchemas

end # module Jamf
