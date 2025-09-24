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

    # OAPI Object Model and Enums for: ManagedSoftwareUpdateStatuses
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
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdateStatus
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/managed-software-updates/update-statuses:GET' needs permissions:
    #    - Read Computers
    #    - Read Mobile Devices
    #  - '/v1/managed-software-updates/update-statuses/computer-groups/{id}:GET' needs permissions:
    #    - Read Computers
    #    - Read Smart Computer Groups
    #    - Read Static Computer Groups
    #  - '/v1/managed-software-updates/update-statuses/computers/{id}:GET' needs permissions:
    #    - Read Computers
    #  - '/v1/managed-software-updates/update-statuses/mobile-device-groups/{id}:GET' needs permissions:
    #    - Read Mobile Devices
    #    - Read Smart Mobile Device Groups
    #    - Read Static Mobile Device Groups
    #  - '/v1/managed-software-updates/update-statuses/mobile-devices/{id}:GET' needs permissions:
    #    - Read Mobile Devices
    #
    #
    class ManagedSoftwareUpdateStatuses < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute totalCount
        #   @return [Integer]
        totalCount: {
          class: :integer
        },

        # @!attribute results
        #   @return [Array<Jamf::OAPISchemas::ManagedSoftwareUpdateStatus>]
        results: {
          class: Jamf::OAPISchemas::ManagedSoftwareUpdateStatus,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ManagedSoftwareUpdateStatuses

  end # module OAPISchemas

end # module Jamf
