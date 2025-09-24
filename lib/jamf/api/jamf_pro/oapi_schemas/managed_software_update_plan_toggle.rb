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

    # OAPI Object Model and Enums for: ManagedSoftwareUpdatePlanToggle
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
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/managed-software-updates/plans/feature-toggle:GET' needs permissions:
    #    - Read Managed Software Updates
    #  - '/v1/managed-software-updates/plans/feature-toggle:PUT' needs permissions:
    #    - Read Managed Software Updates
    #    - Create Managed Software Updates
    #    - Update Managed Software Updates
    #
    #
    class ManagedSoftwareUpdatePlanToggle < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute toggle
        #   @return [Boolean]
        toggle: {
          class: :boolean,
          required: true
        },

        # @!attribute [r] forceInstallLocalDateEnabled
        #   @return [Boolean]
        forceInstallLocalDateEnabled: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] customVersionEnabled
        #   @return [Boolean]
        customVersionEnabled: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] dssEnabled
        #   @return [Boolean]
        dssEnabled: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] recipeEnabled
        #   @return [Boolean]
        recipeEnabled: {
          class: :boolean,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ManagedSoftwareUpdatePlanToggle

  end # module OAPISchemas

end # module Jamf
