# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# Manually require Jamf::OAPISchemas::ApiRole ....
######################################
# because this file defining Jamf::APIRole is at
#      lib/jamf/api/jamf_pro/api_objects/api_role.rb
# has the same filename as the file defining Jamf::OAPISchemas::ApiRole
#      lib/jamf/api/jamf_pro/oapi_schemas/api_role.rb
# telling zeitwerk to use the file 'api_role.rb' to load Jamf::APIRole
# confuses it because it also finds the other one.
#
# So instead we'll tell it to ignore lib/jamf/api/jamf_pro/oapi_schemas/api_role.rb
# and we'll load that manually here, since its needed below
#
# TODO: Stop using auto-generated Jamf::OAPISchemas as we have, use them
# as starting points for bespoke classes to help avoid problems like this.
#
# See Also: lib/jamf/api/jamf_pro/api_objects/api_role.rb
require 'jamf/api/jamf_pro/oapi_schemas/api_role'

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: ApiRoleResult
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
    #  - Jamf::OAPISchemas::ApiRole
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/api-roles:GET' needs permissions:
    #    - Read API Roles
    #
    #
    class ApiRoleResult < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] totalCount
        #   @return [Integer]
        totalCount: {
          class: :integer,
          required: true,
          readonly: true,
          minimum: 0
        },

        # @!attribute results
        #   @return [Array<Jamf::OAPISchemas::ApiRole>]
        results: {
          class: Jamf::OAPISchemas::ApiRole,
          required: true,
          multi: true,
          min_items: 0
        }

      } # end OAPI_PROPERTIES

    end # class ApiRoleResult

  end # module OAPISchemas

end # module Jamf
