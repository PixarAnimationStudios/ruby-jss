# Copyright 2025 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# frozen_string_literal: true

# The main Module
module Jamf

  # Classes
  #####################################

  # A Package in the Jamf Pro API
  #
  #################################
  class JPackage < Jamf::OAPISchemas::Package

    # Mix-Ins
    #####################################

    include Jamf::CollectionResource
    extend Jamf::Filterable
    include Jamf::ChangeLog

    # Constants
    #####################################

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::PackageSearchResults

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::Package

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::Package

    # The OAPI object we send with a PATCH request to change an object in
    # Jamf by replacing only some of its values. This is never the same as the
    # parent class, and is usually used when most of the data about an
    # object cannot be changed via the API.
    # PATCH_OBJECT = Jamf::OAPISchemas::Building

    ############# API PATHS
    # TODO: See if these paths can be auto-generated from the
    # OAPI schema and baked into the parent class

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
    LIST_PATH = 'v1/packages'

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only identifies ':id'
    ALT_IDENTIFIERS = %i[packageName].freeze

    # Must define this when extending Filterable
    FILTER_KEYS = %i[
      id fileName packageName categoryId info notes manifestFileName cloudTransferStatus
    ].freeze

    # the suffix for the REST resource for uploading a package
    UPLOAD_ENDPOINT = 'upload'

    # Defaults for some required values
    ############

    DEFAULT_CATEGORY_ID = '-1'
    DEFAULT_PRIORITY = 10
    DEFAULT_FUT = false
    DEFAULT_REBOOT_REQUIRED = false
    DEFAULT_OS_INSTALL = false
    DEFAULT_SUPPRESS_UPDATES = false
    DEFAULT_SUPPRESS_FROM_DOCK = false
    DEFAULT_SUPPRESS_EULA = false
    DEFAULT_SUPPRESS_REGISTRATION = false

    # Attribute Aliases for backards compatibility
    #####################################

    alias name packageName
    alias filename fileName

    # Constructor
    #####################################

    # Make an instance. Data comes from the API
    #
    # @param data[Hash] the data for constructing a new object.
    #
    def initialize(data)
      super

      self.categoryId ||= DEFAULT_CATEGORY_ID
      self.priority ||= DEFAULT_PRIORITY
      self.fillUserTemplate ||= DEFAULT_FUT
      self.rebootRequired ||= DEFAULT_REBOOT_REQUIRED
      self.osInstall ||= DEFAULT_OS_INSTALL
      self.suppressUpdates ||= DEFAULT_SUPPRESS_UPDATES
      self.suppressFromDock ||= DEFAULT_SUPPRESS_FROM_DOCK
      self.suppressEula ||= DEFAULT_SUPPRESS_EULA
      self.suppressRegistration ||= DEFAULT_SUPPRESS_REGISTRATION
    end # init

  end # class

end # module
