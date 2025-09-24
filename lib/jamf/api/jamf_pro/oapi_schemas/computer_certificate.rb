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

    # OAPI Object Model and Enums for: ComputerCertificate
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
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerCertificate < Jamf::OAPIObject

      # Enums used by this class or others

      LIFECYCLE_STATUS_OPTIONS = %w[
        ACTIVE
        INACTIVE
      ]

      CERTIFICATE_STATUS_OPTIONS = %w[
        EXPIRING
        EXPIRED
        REVOKED
        PENDING_REVOKE
        ISSUED
      ]

      OAPI_PROPERTIES = {

        # @!attribute commonName
        #   @return [String]
        commonName: {
          class: :string
        },

        # @!attribute identity
        #   @return [Boolean]
        identity: {
          class: :boolean
        },

        # @!attribute expirationDate
        #   @return [Jamf::Timestamp]
        expirationDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute lifecycleStatus
        #   @return [String]
        lifecycleStatus: {
          class: :string,
          enum: LIFECYCLE_STATUS_OPTIONS
        },

        # @!attribute certificateStatus
        #   @return [String]
        certificateStatus: {
          class: :string,
          enum: CERTIFICATE_STATUS_OPTIONS
        },

        # @!attribute subjectName
        #   @return [String]
        subjectName: {
          class: :string
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string
        },

        # @!attribute sha1Fingerprint
        #   @return [String]
        sha1Fingerprint: {
          class: :string
        },

        # @!attribute issuedDate
        #   @return [String]
        issuedDate: {
          class: Jamf::Timestamp
        }

      } # end OAPI_PROPERTIES

    end # class ComputerCertificate

  end # module OAPISchemas

end # module Jamf
