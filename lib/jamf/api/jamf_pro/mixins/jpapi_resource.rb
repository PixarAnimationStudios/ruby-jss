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

      # the resource path for this resource
      # @return [String]
      def rsrc_path
        @rsrc_path ||= self::RSRC_PATH
      end

      def preview_path
        "#{RSRC_PREVIEW_VERSION}/#{self::RSRC_PATH}"
      end

      # Disallow direct use of ruby's .new class method for creating instances.
      # Require use of .fetch or .create, or 'all'
      #
      def new(**data)
        stop_if_base_class
        calling_method = caller_locations(1..1).first.label
        raise Jamf::UnsupportedError, 'Use .fetch, .create, or .all(instantiate:true) to instantiate Jamf::Resources' unless NEW_CALLERS.include? calling_method

        super **data
      end

    end # module class methods

    #####################################

    # @return [Jamf::Connection] the API connection thru which we deal with
    #   this resource.
    attr_reader :cnx

    # @return [String] the resouce path for this object
    attr_reader :rsrc_path

    # Instance Methods
    #####################################

    # TODO: error handling
    def save
      raise Jamf::UnsupportedError, "#{self.class} objects cannot be changed" unless self.class.mutable?

      return unless unsaved_changes?

      exist? ? update_in_jamf : create_in_jamf
      clear_unsaved_changes

      @id || :saved
    end

    # Private Instance Methods
    #####################################
    private

    # TODO: handle PATCH when it becomes a thing
    def update_in_jamf
      @cnx.jp_put(rsrc_path, to_jamf)
    rescue Jamf::Connection::APIError => e
      if e.status == 409 && self.class.included_modules.include?(Jamf::Lockable)
        raise Jamf::VersionLockError, "The #{self.class} has been modified since it was fetched. Please refetch and try again."
      end

      raise e
    end

  end # class APIObject

end # module JAMF
