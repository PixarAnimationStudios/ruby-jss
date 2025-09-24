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

    # OAPI Object Model and Enums for: ComputerConfigurationProfile
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
    class ComputerConfigurationProfile < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute [r] username
        #   @return [String]
        username: {
          class: :string,
          readonly: true
        },

        # @!attribute lastInstalled
        #   @return [Jamf::Timestamp]
        lastInstalled: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute [r] removable
        #   @return [Boolean]
        removable: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] displayName
        #   @return [String]
        displayName: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] profileIdentifier
        #   @return [String]
        profileIdentifier: {
          class: :string,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerConfigurationProfile

  end # module OAPISchemas

end # module Jamf
