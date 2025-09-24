# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: ComputerContentCaching
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.9.2-t1726753918
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
    #  - Jamf::OAPISchemas::ComputerInventory
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ComputerContentCachingParent
    #  - Jamf::OAPISchemas::ComputerContentCachingAlert
    #  - Jamf::OAPISchemas::ComputerContentCachingCacheDetail
    #  - Jamf::OAPISchemas::ComputerContentCachingDataMigrationError
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerContentCaching < Jamf::OAPIObject

      # Enums used by this class or others

      REGISTRATION_STATUS_OPTIONS = %w[
        CONTENT_CACHING_FAILED
        CONTENT_CACHING_PENDING
        CONTENT_CACHING_SUCCEEDED
      ]

      TETHERATOR_STATUS_OPTIONS = %w[
        CONTENT_CACHING_UNKNOWN
        CONTENT_CACHING_DISABLED
        CONTENT_CACHING_ENABLED
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] computerContentCachingInformationId
        #   @return [String]
        computerContentCachingInformationId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] parents
        #   @return [Array<Jamf::OAPISchemas::ComputerContentCachingParent>]
        parents: {
          class: Jamf::OAPISchemas::ComputerContentCachingParent,
          readonly: true,
          multi: true
        },

        # @!attribute [r] alerts
        #   @return [Array<Jamf::OAPISchemas::ComputerContentCachingAlert>]
        alerts: {
          class: Jamf::OAPISchemas::ComputerContentCachingAlert,
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
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] cacheDetails
        #   @return [Array<Jamf::OAPISchemas::ComputerContentCachingCacheDetail>]
        cacheDetails: {
          class: Jamf::OAPISchemas::ComputerContentCachingCacheDetail,
          readonly: true,
          multi: true
        },

        # @!attribute [r] cacheBytesFree
        #   @return [Integer]
        cacheBytesFree: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] cacheBytesLimit
        #   @return [Integer]
        cacheBytesLimit: {
          class: :integer,
          format: 'int64',
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
          format: 'int64',
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
        #   @return [Jamf::OAPISchemas::ComputerContentCachingDataMigrationError]
        dataMigrationError: {
          class: Jamf::OAPISchemas::ComputerContentCachingDataMigrationError
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
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] personalCacheBytesLimit
        #   @return [Integer]
        personalCacheBytesLimit: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] personalCacheBytesUsed
        #   @return [Integer]
        personalCacheBytesUsed: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] port
        #   @return [Integer]
        port: {
          class: :integer,
          format: 'int64',
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
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] registrationStarted
        #   @return [Jamf::Timestamp]
        registrationStarted: {
          class: Jamf::Timestamp,
          format: 'date-time',
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
          format: 'date-time',
          readonly: true
        },

        # @!attribute [r] totalBytesDropped
        #   @return [Integer]
        totalBytesDropped: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesImported
        #   @return [Integer]
        totalBytesImported: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToChildren
        #   @return [Integer]
        totalBytesReturnedToChildren: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToClients
        #   @return [Integer]
        totalBytesReturnedToClients: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesReturnedToPeers
        #   @return [Integer]
        totalBytesReturnedToPeers: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromOrigin
        #   @return [Integer]
        totalBytesStoredFromOrigin: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromParents
        #   @return [Integer]
        totalBytesStoredFromParents: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] totalBytesStoredFromPeers
        #   @return [Integer]
        totalBytesStoredFromPeers: {
          class: :integer,
          format: 'int64',
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerContentCaching

  end # module OAPISchemas

end # module Jamf
