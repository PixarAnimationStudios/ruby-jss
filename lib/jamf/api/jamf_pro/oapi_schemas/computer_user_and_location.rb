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

    # OAPI Object Model and Enums for: ComputerUserAndLocation
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
    #  - Jamf::OAPISchemas::ComputerInventoryUpdateRequest
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ComputerExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerUserAndLocation < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute realname
        #   @return [String]
        realname: {
          class: :string
        },

        # @!attribute email
        #   @return [String]
        email: {
          class: :string
        },

        # @!attribute position
        #   @return [String]
        position: {
          class: :string
        },

        # @!attribute phone
        #   @return [String]
        phone: {
          class: :string
        },

        # @!attribute departmentId
        #   @return [String]
        departmentId: {
          class: :string
        },

        # @!attribute buildingId
        #   @return [String]
        buildingId: {
          class: :string
        },

        # @!attribute room
        #   @return [String]
        room: {
          class: :string
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerUserAndLocation

  end # module OAPISchemas

end # module Jamf
