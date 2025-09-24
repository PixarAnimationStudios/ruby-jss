# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# Manually require our OAPISchema....
######################################
# because this file defining Jamf::APIRole is at
#      lib/jamf/api/jamf_pro/api_objects/api_role.rb
# has the same filename as the file defining Jamf::OAPISchemas::ApiRole
#      lib/jamf/api/jamf_pro/oapi_schemas/api_role.rb
# telling zeitwerk to use the file 'api_role.rb' to load Jamf::APIRole
# confuses it because it also finds the other one.
#
# So instead we'll tell it to ignore lib/jamf/api/jamf_pro/oapi_schemas/api_role.rb
# and we'll load that manually here
#
# TODO: Stop using auto-generated Jamf::OAPISchemas as we have, use them
# as starting points for bespoke classes to help avoid problems like this.
#
# See Also: lib/jamf/api/jamf_pro/api_objects/api_role.rb
require 'jamf/api/jamf_pro/oapi_schemas/api_role'

# The Module
module Jamf

  # Classes
  #####################################

  # An API Role in the Jamf Pro API
  #
  # API Roles are predefined sets of privileges that can be assigned to API Clients, aka API Integrations.
  #
  class APIRole < Jamf::OAPISchemas::ApiRole

    include Jamf::CollectionResource
    extend Jamf::Filterable

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.
    #
    # TODO: See if these constants can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::ApiRoleResult

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::ApiRoleRequest

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::ApiRoleRequest

    # The OAPI object we send with a PATCH request to change an object in
    # Jamf by replacing only some of its values. This is never the same as the
    # parent class, and is usually used when many or most of the data about an
    # object cannot be changed via the API.
    # PATCH_OBJECT = Jamf::OAPISchemas::Building

    ############# API PATHS

    # The path for GETting the list of all objects in the collection, possibly
    # filtered, sorted, and/or paged
    # REQUIRED for all collection resources
    #
    # GET_PATH, POST_PATH, PUT_PATH, PATCH_PATH, and DELETE_PATH are automatically
    # assumed from the LIST_PATH if they follow the standards:
    # - GET_PATH = "#{LIST_PATH}/id"
    #   - fetch an object from the collection
    # - POST_PATH = LIST_PATH
    #   - create a new object in the collection
    # - PUT_PATH = "#{LIST_PATH}/id"
    #   - update an object passing all its values back.
    #     Most objects use this or PATCH but not both
    # - PATCH_PATH = "#{LIST_PATH}/id"
    #   - update an object passing some of its values back
    #     Most objects use this or PUT but not both
    # - DELETE_PATH = "#{LIST_PATH}/id"
    #   - delete an object from the collection
    #
    # If those paths differ from the standards, the constants must be defined
    # here
    #
    LIST_PATH = 'v1/api-roles'.freeze

    # The path that returns a list of all available privs
    AVAILABLE_PRIVS_PATH = 'v1/api-role-privileges'

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only identifies ':id'
    ALT_IDENTIFIERS = %i[displayName].freeze

    # Must define this when extending Filterable
    FILTER_KEYS = %i[
      id displayName
    ].freeze

    # The attribute holding the object's name
    OBJECT_NAME_ATTR = :displayName

    # Class Methods
    ###############################

    # @return [Array<String>] All available privileges that can be granted via an API Role
    #
    def self.available_privs(cnx: Jamf.cnx)
      cnx.jp_get(AVAILABLE_PRIVS_PATH)[:privileges]
    end

    # Instance Attributes and Methods
    ###########################

  end # class

end # module
