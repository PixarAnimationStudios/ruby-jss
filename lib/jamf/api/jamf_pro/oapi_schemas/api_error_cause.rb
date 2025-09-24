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

    # OAPI Object Model and Enums for: ApiErrorCause
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
    #  - Jamf::OAPISchemas::ApiError
    #  - Jamf::OAPISchemas::MacOsManagedSoftwareUpdateResponse
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
    class ApiErrorCause < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # Error-specific code that can be used to identify localization string, etc.
        # @!attribute code
        #   @return [String]
        code: {
          class: :string
        },

        # Name of the field that caused the error.
        # @!attribute field
        #   @return [String]
        field: {
          class: :string,
          required: true
        },

        # A general description of error for troubleshooting/debugging. Generally this text should not be displayed to a user; instead refer to errorCode and it's localized text
        # @!attribute description
        #   @return [String]
        description: {
          class: :string
        },

        # id of object with error. Optional.
        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          nil_ok: true,
          identifier: :primary
        }

      } # end OAPI_PROPERTIES

    end # class ApiErrorCause

  end # module OAPISchemas

end # module Jamf
