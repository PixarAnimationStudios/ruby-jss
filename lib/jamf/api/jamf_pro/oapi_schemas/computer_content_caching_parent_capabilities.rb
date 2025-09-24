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

    # OAPI Object Model and Enums for: ComputerContentCachingParentCapabilities
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
    #  - Jamf::OAPISchemas::ComputerContentCachingParentDetails
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
    class ComputerContentCachingParentCapabilities < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] contentCachingParentCapabilitiesId
        #   @return [String]
        contentCachingParentCapabilitiesId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] imports
        #   @return [Boolean]
        imports: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] namespaces
        #   @return [Boolean]
        namespaces: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] personalContent
        #   @return [Boolean]
        personalContent: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] queryParameters
        #   @return [Boolean]
        queryParameters: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] sharedContent
        #   @return [Boolean]
        sharedContent: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] prioritization
        #   @return [Boolean]
        prioritization: {
          class: :boolean,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerContentCachingParentCapabilities

  end # module OAPISchemas

end # module Jamf
