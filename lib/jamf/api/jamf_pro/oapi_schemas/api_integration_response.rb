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

    # OAPI Object Model and Enums for: ApiIntegrationResponse
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
    #  - Jamf::OAPISchemas::ApiIntegrationSearchResult
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/api-integrations:POST' needs permissions:
    #    - Create API Integrations
    #  - '/v1/api-integrations/{id}:GET' needs permissions:
    #    - Read API Integrations
    #  - '/v1/api-integrations/{id}:PUT' needs permissions:
    #    - Update API Integrations
    #
    #
    class ApiIntegrationResponse < Jamf::OAPIObject

      # Enums used by this class or others

      APP_TYPE_OPTIONS = %w[
        CLIENT_CREDENTIALS
        NATIVE_APP_OAUTH
        NONE
      ]

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [Integer]
        id: {
          class: :j_id,
          required: true,
          identifier: :primary
        },

        # @!attribute authorizationScopes
        #   @return [Array<String>]
        authorizationScopes: {
          class: :string,
          required: true,
          multi: true
        },

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string,
          required: true
        },

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean,
          required: true
        },

        # @!attribute accessTokenLifetimeSeconds
        #   @return [Integer]
        accessTokenLifetimeSeconds: {
          class: :integer
        },

        # Type of API Client:
        #     * `CLIENT_CREDENTIALS` - A client ID and secret have been generated for this integration.
        #     * `NATIVE_APP_OAUTH` - A native app (i.e., Jamf Reset) has been linked to this integration for auth code grant type via Managed App Config.
        #     * `NONE` - No client is currently associated with this integration.
        # @!attribute [r] appType
        #   @return [String]
        appType: {
          class: :string,
          required: true,
          readonly: true,
          enum: APP_TYPE_OPTIONS
        },

        # @!attribute [r] clientId
        #   @return [String]
        clientId: {
          class: :string,
          required: true,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ApiIntegrationResponse

  end # module OAPISchemas

end # module Jamf
