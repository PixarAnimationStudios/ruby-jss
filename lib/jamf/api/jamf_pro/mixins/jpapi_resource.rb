# Copyright 2020 Pixar

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

  # @see_also Jamf::OAPIObject
  #
  module JPAPIResource

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      # TODO: only allow being directly mixed in to CollectionResource and
      # SingletonResource modules.
      # puts "JPAPIResource is being included by #{includer}, now extending JPAPIResource::ClassMethods"

      includer.extend(ClassMethods)
    end

    # Constants
    #####################################
    # These methods are allowed to call .new
    NEW_CALLERS = ['fetch', 'create', 'all', 'cached_all', 'block in all', 'block in cached_all'].freeze

    # The resource version for previewing new features
    RSRC_PREVIEW_VERSION = 'preview'.freeze

    #  Class Methods
    #####################################
    module ClassMethods

      # Disallow direct use of ruby's .new class method for creating instances.
      # Require use of .fetch or .create, or 'all'
      #
      def new(**data)
        stop_if_base_class
        calling_method = caller_locations(1..1).first.label
        unless NEW_CALLERS.include? calling_method
          raise Jamf::UnsupportedError, 'Use .fetch, .create, or .all(instantiate:true) to instantiate Jamf::JPAPIResource objects'
        end

        super(**data)
      end

    end # module class methods

    # attributes
    #####################################

    # @return [Jamf::Connection] the API connection thru which we deal with
    #   this resource.
    attr_reader :cnx

    # @return [String] The path for fetching this thing from the JPAPI
    #
    #   this gets set in the constructor in the CollectionResource or
    #   SingletonResource mixins
    attr_reader :get_path

    # @return [String] The path for updating this thing from the JPAPI
    #
    #   this gets set in the constructor in the CollectionResource or
    #   SingletonResource mixins
    #
    #   We use 'update_path' because some items are updated via a
    #   PUT_PATH and others via a PATCH_PATH.
    #   When this gets set, it will contain the appropriate one.
    attr_reader :update_path


    # constructor
    #####################################
    def initialize(**data)
      @cnx = data.delete :cnx
      super(**data)
    end

    # Instance Methods
    #####################################

    # Remove large cached items from
    # the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = super.sort
      vars.delete :@cnx
      vars
    end

    # TODO: error handling
    def save
      raise Jamf::UnsupportedError, "#{self.class} objects cannot be changed" unless self.class.mutable?

      if exist?
        return unless unsaved_changes?

        update_in_jamf
      else
        create_in_jamf
      end

      clear_unsaved_changes

      @id || :saved
    end

    # Private Instance Methods
    #####################################
    private

    ##############################
    def update_in_jamf
      if defined? self.class::PUT_OBJECT
        put_object = self.class::PUT_OBJECT.new(to_jamf)
        cnx.jp_put(update_path, put_object.to_jamf)

      elsif defined? self.class::PATCH_OBJECT
        patch_object = self.class::PATCH_OBJECT.new(to_jamf)
        cnx.jp_patch(update_path, patch_object.to_jamf)

      else
        raise Jamf::MissingDataError, "Class #{self.class} has not defined a PUT_OBJECT or PATCH_OBJECT"
      end
    end # update_in_jamf

  end # class APIObject

end # module JAMF
