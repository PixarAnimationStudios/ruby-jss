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

    # OAPI Object Model and Enums for: ComputerPartition
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
    #  - Jamf::OAPISchemas::ComputerDisk
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ComputerPartitionFileVault2State
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerPartition < Jamf::OAPIObject

      # Enums used by this class or others

      PARTITION_TYPE_OPTIONS = %w[
        BOOT
        RECOVERY
        OTHER
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] name
        #   @return [String]
        name: {
          class: :string,
          readonly: true
        },

        # Partition Size in MB.
        # @!attribute [r] sizeMegabytes
        #   @return [Integer]
        sizeMegabytes: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # Available space in MB.
        # @!attribute [r] availableMegabytes
        #   @return [Integer]
        availableMegabytes: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute [r] partitionType
        #   @return [String]
        partitionType: {
          class: :string,
          readonly: true,
          enum: PARTITION_TYPE_OPTIONS
        },

        # Percentage of space used.
        # @!attribute [r] percentUsed
        #   @return [Integer]
        percentUsed: {
          class: :integer,
          readonly: true,
          minimum: 0,
          maximum: 100
        },

        # @!attribute fileVault2State
        #   @return [Jamf::OAPISchemas::ComputerPartitionFileVault2State]
        fileVault2State: {
          class: Jamf::OAPISchemas::ComputerPartitionFileVault2State
        },

        # Percentage progress of current FileVault 2 operation.
        # @!attribute fileVault2ProgressPercent
        #   @return [Integer]
        fileVault2ProgressPercent: {
          class: :integer,
          nil_ok: true
        },

        # @!attribute [r] lvmManaged
        #   @return [Boolean]
        lvmManaged: {
          class: :boolean,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerPartition

  end # module OAPISchemas

end # module Jamf
