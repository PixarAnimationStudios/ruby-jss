# Copyright 2022 Pixar
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


module Jamf

  # This module contains Object Model and Enum Constants for all JSONObjects
  # defined in the Jamf Pro API.
  #
  # Generated automatically from the OAPI schema available from the
  # 'api/schema' endpoint of any Jamf Pro server.
  #
  # This file was generated from Jamf Pro version 10.36.1
  #
  module OAPIObjectModels

    # API Object Model and Enums for: ComputerContentCaching
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::ComputerInventoryResponse
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::ComputerContentCachingParent
    #  - OAPIObjectModels::ComputerContentCachingAlert
    #  - OAPIObjectModels::ComputerContentCachingCacheDetail
    #  - OAPIObjectModels::ComputerContentCachingDataMigrationError
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::ComputerContentCaching
    #
    module ComputerContentCaching

      # These enums are used in the properties below

      REGISTRATION_STATUS_OPTIONS = [
        'CONTENT_CACHING_FAILED',
        'CONTENT_CACHING_PENDING',
        'CONTENT_CACHING_SUCCEEDED'
      ]

      TETHERATOR_STATUS_OPTIONS = [
        'CONTENT_CACHING_UNKNOWN',
        'CONTENT_CACHING_DISABLED',
        'CONTENT_CACHING_ENABLED'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] computerContentCachingInformationId
        #   @return [String]
        computerContentCachingInformationId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] parents
        #   @return [Array<Jamf::ComputerContentCachingParent>]
        parents: {
          class: Jamf::ComputerContentCachingParent,
          readonly: true,
          multi: true
        },

        # @!attribute [r] alerts
        #   @return [Array<Jamf::ComputerContentCachingAlert>]
        alerts: {
          class: Jamf::ComputerContentCachingAlert,
          readonly: true,
          multi: true
        },

        # @!attribute [r] activated
        #   @return [Boolean]
        activated: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] active
        #   @return [Boolean]
        active: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] actualCacheBytesUsed
        #   @return [Integer]
        actualCacheBytesUsed: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] cacheDetails
        #   @return [Array<Jamf::ComputerContentCachingCacheDetail>]
        cacheDetails: {
          class: Jamf::ComputerContentCachingCacheDetail,
          readonly: true,
          multi: true
        },

        # @!attribute [r] cacheBytesFree
        #   @return [Integer]
        cacheBytesFree: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] cacheBytesLimit
        #   @return [Integer]
        cacheBytesLimit: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] cacheStatus
        #   @return [String]
        cacheStatus: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] cacheBytesUsed
        #   @return [Integer]
        cacheBytesUsed: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] dataMigrationCompleted
        #   @return [Boolean]
        dataMigrationCompleted: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] dataMigrationProgressPercentage
        #   @return [Integer]
        dataMigrationProgressPercentage: {
          class: :integer,
          readonly: true
        },

        # @!attribute dataMigrationError
        #   @return [Jamf::ComputerContentCachingDataMigrationError]
        dataMigrationError: {
          class: Jamf::ComputerContentCachingDataMigrationError
        },

        # @!attribute [r] maxCachePressureLast1HourPercentage
        #   @return [Integer]
        maxCachePressureLast1HourPercentage: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] personalCacheBytesFree
        #   @return [Integer]
        personalCacheBytesFree: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] personalCacheBytesLimit
        #   @return [Integer]
        personalCacheBytesLimit: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] personalCacheBytesUsed
        #   @return [Integer]
        personalCacheBytesUsed: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] port
        #   @return [Integer]
        port: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] publicAddress
        #   @return [String]
        publicAddress: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] registrationError
        #   @return [String]
        registrationError: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] registrationResponseCode
        #   @return [Integer]
        registrationResponseCode: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] registrationStarted
        #   @return [Jamf::Timestamp]
        registrationStarted: {
          class: Jamf::Timestamp,
          readonly: true
        },

        # @!attribute [r] registrationStatus
        #   @return [String]
        registrationStatus: {
          class: :string,
          readonly: true,
          enum: REGISTRATION_STATUS_OPTIONS
        },

        # @!attribute [r] restrictedMedia
        #   @return [Boolean]
        restrictedMedia: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] serverGuid
        #   @return [String]
        serverGuid: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] startupStatus
        #   @return [String]
        startupStatus: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] tetheratorStatus
        #   @return [String]
        tetheratorStatus: {
          class: :string,
          readonly: true,
          enum: TETHERATOR_STATUS_OPTIONS
        },

        # @!attribute [r] totalBytesAreSince
        #   @return [Jamf::Timestamp]
        totalBytesAreSince: {
          class: Jamf::Timestamp,
          readonly: true
        },

        # @!attribute [r] totalBytesDropped
        #   @return [Integer]
        totalBytesDropped: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesImported
        #   @return [Integer]
        totalBytesImported: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToChildren
        #   @return [Integer]
        totalBytesReturnedToChildren: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToClients
        #   @return [Integer]
        totalBytesReturnedToClients: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToPeers
        #   @return [Integer]
        totalBytesReturnedToPeers: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromOrigin
        #   @return [Integer]
        totalBytesStoredFromOrigin: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromParents
        #   @return [Integer]
        totalBytesStoredFromParents: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromPeers
        #   @return [Integer]
        totalBytesStoredFromPeers: {
          class: :integer,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # module ComputerContentCaching

  end # module OAPIObjectModels

end # module Jamf
