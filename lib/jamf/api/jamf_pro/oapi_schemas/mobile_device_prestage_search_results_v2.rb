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

    # OAPI Object Model and Enums for: MobileDevicePrestageSearchResultsV2
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
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::GetMobileDevicePrestageV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/mobile-device-prestages:GET' needs permissions:
    #    - Read Mobile Device PreStage Enrollments
    #
    #
    class MobileDevicePrestageSearchResultsV2 < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute totalCount
        #   @return [Integer]
        totalCount: {
          class: :integer,
          minimum: 0
        },

        # @!attribute results
        #   @return [Array<Jamf::OAPISchemas::GetMobileDevicePrestageV2>]
        results: {
          class: Jamf::OAPISchemas::GetMobileDevicePrestageV2,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class MobileDevicePrestageSearchResultsV2

  end # module OAPISchemas

end # module Jamf
