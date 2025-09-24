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

    # OAPI Object Model and Enums for: AccountPreferencesV1
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
    #  - Jamf::OAPISchemas::AuthAccountV1
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
    class AccountPreferencesV1 < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute language
        #   @return [String]
        language: {
          class: :string
        },

        # @!attribute dateFormat
        #   @return [String]
        dateFormat: {
          class: :string
        },

        # @!attribute region
        #   @return [String]
        region: {
          class: :string
        },

        # @!attribute timezone
        #   @return [String]
        timezone: {
          class: :string
        },

        # @!attribute disableRelativeDates
        #   @return [Boolean]
        disableRelativeDates: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # class AccountPreferencesV1

  end # module OAPISchemas

end # module Jamf
