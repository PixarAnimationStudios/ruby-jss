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

    # OAPI Object Model and Enums for: ApiRole
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.6.1-t1718634702
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
    #  - Jamf::OAPISchemas::ApiRoleResult
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/api-roles:POST' needs permissions:
    #    - Create API Roles
    #  - '/v1/api-roles/{id}:GET' needs permissions:
    #    - Read API Roles
    #  - '/v1/api-roles/{id}:PUT' needs permissions:
    #    - Update API Roles
    #
    #
    class ApiRole < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          required: true,
          identifier: :primary,
          readonly: true
        },

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string,
          required: true
        },

        # @!attribute privileges
        #   @return [Array<String>]
        privileges: {
          class: :string,
          required: true,
          multi: true,
          min_items: 0
        }

      } # end OAPI_PROPERTIES

    end # class ApiRole

  end # module OAPISchemas

end # module Jamf
