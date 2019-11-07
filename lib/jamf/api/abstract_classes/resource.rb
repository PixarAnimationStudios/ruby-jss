# Copyright 2018 Pixar

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

# The module
module Jamf

  # Classes
  #####################################

  # @see_also Jamf::JSONObject
  #
  # Jamf::Resource represents a thing directly accessible in the API. It
  # will contain one or more API endpoints.
  #
  # A resource has a base URI path in the API used for
  # interacting with the resource and directly-related sub-resources.
  #
  # For example, the device-reenrollment settings are a resource at the url path
  #
  # >  .../uapi/v1/reenrollment
  #
  # and the related sub-resource for the change history of the reenrollment
  # settings is at
  #
  # > .../uapi/v1/reenrollment/history
  #
  # All resources based at .../uapi/v1/reenrollment are encapsulated
  # in the class {Jamf::ReEnrollmentSettings}, a descendent of Jamf::Resource
  #
  # There are two types of resources: Singletons and Collections.
  #
  # **Singleton resources** have only one instance available in the API, and they
  # cannot be create or deleted, only fetched and usually updated, tho some cant
  # be updated either, e.g. Jamf::AppStoreCountryCodes. The device-reenrollment
  # settings mentioned above are an example of a Singleton resource.
  # When the resource is fetched from the API, it is cached, and (usually) future
  # fetching will return the same instance. See {Jamf::SingletonResource} for
  # details.
  #
  # **Collection resources** have more than one resource within them, and those
  # can (usually) be created and deleted as well as fetched and updated.
  # The entire collection (or a part of it) can also be fetched as an Array.
  # When the whole collection is fetched, the result is cached for future use.
  # See {Jamf::CollectionResource} for details.
  #
  # # Instantiating Resources
  #
  # For all subclasses of Jamf::Resource, using the ruby standard .new class
  # method to instantiate an object will raise an exception. We do this to avoid
  # the ambiguity of the word 'new' in this context.
  #
  # Normally in ruby, .new means 'make a new instance of this class in memory'.
  # But with Jamf Resoureces, when making a new instance in memory, we might be
  # making an instance of a resource that already exists in Jamf Pro, or perhaps
  # making an instance of a 'new' thing that we want to create in Jamf Pro,
  # but doesn't exist there at the moment.
  #
  # While we could look at the parameters passed to decide which of those two
  # things we're doing, (and require specific parameters for each action), that
  # doesn't change the fact that a human _reading_ the line:
  #
  #   a_building = Jamf::Building.new name: 'Main Building'
  #
  # sounds like we want to create a new building in the JSS, when in fact we're
  # just retrieving one that's already there.
  #
  # To make the code more readable and totally clear, .new is not allowed for
  # making instances of Jamf::Resources. Instead, use the class method .fetch
  # to retrieve existing resources, like so:
  #
  #   a_building = Jamf::Building.fetch name: 'Main Building'
  #
  # This makes it clear what the code is doing, and when you get the error that
  # there's no building with that name, the error makes sense, which it
  # wouldn't if you were creating a new building in the JSS.
  #
  # Likewise, to make a new one in Jamf Pro, use .create, as in:
  #
  #   a_building = Jamf::Building.create name: 'Main Building'
  #
  # This makes it obvious that we're creating a new building in the JSS
  #
  # In both cases, the instance method #save is used to send your changes to the
  # API. If the resource already exists, the changes will be applied to the
  # server with #save.  If it doesn't yet exist, it will be created by #save.
  #
  #
  # # Subclassing
  #
  #
  # ### Required Constant: RSRC_VERSION
  #
  # The version of the resource model supported by ruby-jss for this class.
  #
  # Every resource in the Jamf Pro API has a version as part of its URL path.
  # For example, in the full resource URL:
  #
  #    https://your.jamf.server:port/uapi/v1/reenrollment
  #
  # the resource version is `v1`.  At any given time, the API may have many
  # versions of a resource available - v2 might be released with new values
  # available or deprecated values removed, but v1 remains and is unchanged.
  #
  # Each subclass of Jamf::Resource must define RSRC_VERSION as a
  # String, e.g. 'v1', which defines the version supported by the subclass.
  #
  # As new versions are released by Jamf, when the changes are implemented
  # in ruby-jss, the RSRC_VERSION is updated.
  #
  # ## Required Constant: OBJECT_MODEL
  #
  # This is required of all {Jamf::JSONObject} subclasses. Refer to that
  # documentation for full details about implementing the OBJECT_MODEL constant.
  #
  # ## Required Constant: RSRC_PATH
  #
  # This is the URI path to the resource, relative to the API base and version
  # ('uapi/vX/').
  #
  # Examples:
  #
  #   1. For SingletonResource class {Jamf::Settings::ReEnrollment}, the URL to
  #      the resource is:
  #
  #         https://your.jamf.server:port/uapi/v1/reenrollment
  #
  #      and that URL is used to GET and PUT data, and as a base for the change
  #      log data.
  #
  #      The constant {Jamf::Settings::ReEnrollment::RSRC_PATH} must be
  #      `'reenrollment'`
  #
  #   2. For CollectionResource class {Jamf::MobileDevice}, the URL to the
  #      collection Array is:
  #
  #         https://your.jamf.server:port/uapi/v1/mobile-devices
  #
  #      and that URL is used to GET lists of mobileDevice data. It is also the
  #      base URL for GET, POST, PUT and DELETE for individual mobileDevices,
  #      and their details and change log data.
  #
  #      The constant {Jamf::MobileDevice::RSRC_PATH} must be
  #      `'mobile-devices'`
  #
  # @abstract
  #
  class Resource < Jamf::JSONObject

    extend Jamf::Abstract

    # Constants
    #####################################

    # These methods are allowed to call .new
    NEW_CALLERS = ['fetch', 'create', 'all', 'block in all'].freeze

    # The resource version for previewing new features
    RSRC_PREVIEW_VERSION = 'preview'.freeze

    # Public Class Methods
    #####################################

    # the resource path for this resource
    # @return [String]
    def self.rsrc_path
      "#{self::RSRC_VERSION}/#{self::RSRC_PATH}"
    end

    def self.preview_path
      "#{RSRC_PREVIEW_VERSION}/#{self::RSRC_PATH}"
    end

    # Disallow direct use of ruby's .new class method for creating instances.
    # Require use of .fetch or .create.
    #
    def self.new(data, cnx: Jamf.cnx)
      calling_method = caller_locations(1..1).first.label
      raise Jamf::UnsupportedError, "Use .fetch or .create to instantiate Jamf::Resource's" unless NEW_CALLERS.include? calling_method

      super
    end

    # Attributes
    #####################################

    # @return [String] the resouce path for this object
    attr_reader :rsrc_path


    # Instance Methods
    #####################################

    # TODO: error handling
    def save
      return unless unsaved_changes?

      exist? ? update_in_jamf : create_in_jamf

      clear_unsaved_changes
    end

    # Private Instance Methods
    #####################################
    private

    def update_in_jamf
      return unless defined? self.class::UPDATABLE

      @cnx.put rsrc_path, to_jamf

      meth = :put
      path = rsrc_path
      if defined? self.class::UPDATE_RESOURCE
        meth = self.class::UPDATE_RESOURCE[:method]
        path = "#{rsrc_path}/#{self.class::UPDATE_RESOURCE[:path_suffix]}"
      end

      @cnx.send meth, path, to_jamf
    end

  end # class APIObject

end # module JAMF
