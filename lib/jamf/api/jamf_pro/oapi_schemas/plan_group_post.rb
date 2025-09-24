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

    # OAPI Object Model and Enums for: PlanGroupPost
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
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdatePlanGroupPost
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
    class PlanGroupPost < Jamf::OAPIObject

      # Enums used by this class or others

      OBJECT_TYPE_OPTIONS = %w[
        COMPUTER_GROUP
        MOBILE_DEVICE_GROUP
      ]

      OAPI_PROPERTIES = {

        # @!attribute groupId
        #   @return [String]
        groupId: {
          class: :string,
          required: true,
          min_length: 1
        },

        # @!attribute objectType
        #   @return [String]
        objectType: {
          class: :string,
          required: true,
          enum: OBJECT_TYPE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class PlanGroupPost

  end # module OAPISchemas

end # module Jamf
