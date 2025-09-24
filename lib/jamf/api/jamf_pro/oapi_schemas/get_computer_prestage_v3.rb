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

    # OAPI Object Model and Enums for: GetComputerPrestageV3
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
    #  - Jamf::OAPISchemas::ComputerPrestageSearchResultsV3
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v3/computer-prestages/{id}:GET' needs permissions:
    #    - Read Computer PreStage Enrollments
    #  - '/v3/computer-prestages/{id}:PUT' needs permissions:
    #    - Update Computer PreStage Enrollments
    #
    #
    class GetComputerPrestageV3 < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true,
          min_length: 1
        },

        # @!attribute profileUuid
        #   @return [String]
        profileUuid: {
          class: :string
        },

        # @!attribute siteId
        #   @return [String]
        siteId: {
          class: :string
        },

        # @!attribute versionLock
        #   @return [Integer]
        versionLock: {
          class: :integer,
          minimum: 0
        },

        # @!attribute accountSettings
        #   @return [Jamf::OAPISchemas::AccountSettingsResponse]
        accountSettings: {
          class: Jamf::OAPISchemas::AccountSettingsResponse
        }
      }.merge(Jamf::OAPISchemas::ComputerPrestageV3::OAPI_PROPERTIES) # end OAPI_PROPERTIES

    end # class GetComputerPrestageV3

  end # module OAPISchemas

end # module Jamf
