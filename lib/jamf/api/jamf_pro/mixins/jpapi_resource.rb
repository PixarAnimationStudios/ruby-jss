# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
      Jamf.load_msg "--> #{includer} is including Jamf::JPAPIResource"
      includer.extend(ClassMethods)
    end

    # Constants
    #####################################

    # which API do APIObjects come from?
    # The classic equivalent is in Jamf::APIObject
    API_SOURCE = :jamf_pro

    # These methods are allowed to call .new
    NEW_CALLERS = [
      'fetch',
      'create',
      'all',
      'cached_all',
      'block in all',
      'block in cached_all',
      'block in page'
    ].freeze

    # The resource version for previewing new features
    RSRC_PREVIEW_VERSION = 'preview'.freeze

    #  Class Methods
    #####################################
    module ClassMethods

      ######################################
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::JPAPIResource::ClassMethods"
      end

      # Indicate that this class comes from the Jamf Pro API.
      # The same method exists in APIObject to indicate coming from Classic
      def which_api
        :jamf_pro
      end

      # Disallow direct use of ruby's .new class method for creating instances.
      # Require use of a method in NEW_CALLERS, or the data must include
      # :instantiate_me
      #
      # WARNING: do not abuse :instantiate_me, it exists so we don't constantly
      # have to update NEW_CALLERS
      #
      def new(**data)
        calling_method = caller_locations(1..1).first.label
        unless NEW_CALLERS.include? calling_method || data[:instantiate_me]
          raise Jamf::UnsupportedError, 'Use .fetch, .create, or .all(instantiate:true) to instantiate Jamf::JPAPIResource objects'
        end

        data.delete :instantiate_me

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
