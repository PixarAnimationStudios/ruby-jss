### Copyright 2025 Pixar
###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

# THe main module
module Jamf

  # The connection class
  class Connection

    # This module defines attributes and methods related to the caching of certain
    # data from the API.
    # TODO: Remove this when we no longer support caching from either API
    module Cache

      # These classes are extendable, their Extension Attributes in the
      # classic API are cached locally in the connection object..
      # NOTE: These are strings, not references to the actual classes.
      # Otherwise, they and all the classes they reference get loaded
      # when ruby-jss is required
      EXTENDABLE_CLASSES = %w[Jamf::Computer Jamf::MobileDevice Jamf::User].freeze

      # @return [Concurrent::Map] This Hash-like object caches the results of
      #   C-API queries for an APIObject
      #   subclass's .all summary list, keyed by the subclass's RSRC_LIST_KEY.
      #   See the APIObject.all class method.
      #
      #   It also caches related data items for speedier processing:
      #
      #   - The Hashes created by APIObject.map_all_ids_to(other_key), keyed by
      #     "#{RSRC_LIST_KEY}_map_#{other_key}".to_sym
      #
      #   - This hash also holds a cache of the rarely-used APIObject.all_objects
      #     hash, keyed by "#{RSRC_LIST_KEY}_objects".to_sym
      #
      #
      #   When APIObject.all, and related methods are called without an argument,
      #   and this hash has a matching value, the value is returned, rather than
      #   requerying the API. The first time a class calls .all, or whenever refresh
      #   is not false, the API is queried and the value in this hash is updated.
      def c_object_list_cache
        @c_object_list_cache ||= Concurrent::Map.new
      end

      # @return [Hash{Class: Hash{String => Jamf::ExtensionAttribute}}]
      #   This Hash caches the C-API Extension Attribute
      #   definition objects for the three types of ext. attribs:
      #   ComputerExtensionAttribute, MobileDeviceExtensionAttribute, and
      #   UserExtensionAttribute, whenever they are fetched for parsing or
      #   validating extention attribute data.
      #
      #   The top-level keys are the EA classes themselves:
      #   - ComputerExtensionAttribute
      #   - MobileDeviceExtensionAttribute
      #   - UserExtensionAttribute
      #
      #   These each point to a Hash of their instances, keyed by name, e.g.
      #     {
      #      "A Computer EA" => <Jamf::ComputerExtensionAttribute...>,
      #      "A different Computer EA" => <Jamf::ComputerExtensionAttribute...>,
      #      ...
      #     }
      #
      def c_ext_attr_definition_cache
        @c_ext_attr_definition_cache ||= Concurrent::Map.new
      end

      # Empty cached lists from this connection
      # then run garbage collection to clear any available memory
      #
      # See the getters for
      # - c_object_list_cache
      # - c_ext_attr_definition_cache
      #
      # NOTE since all ruby variables are references to objects in memory,
      # if you've referenced objects in these caches, those objects
      # won't be removed from memory by garbage collection but all cached data
      # will be recached as needed.
      #
      # e.g.
      #  my_ref = Jamf::SomeClass.all
      #  # my_ref now points to the same cached hash that Jamf::SomeClass.all does
      #
      #  my_connection.flushcache
      #  # Jamf::SomeClass.all now points to an empty hash in the cache, but the one
      #  # that my_ref points to still exists, full of the original data. Because
      #  # my_ref still points to it, garbage collection doesn't remove it from
      #  # memory
      #
      #  Jamf::SomeClass.all
      #  # Jamf::SomeClass.all re-reads the data from the API and populates the
      #  # Hash in the cache with new data, potentially different from that you're
      #  # still seeing in my_ref
      #
      #
      # @param key_or_klass[Symbol, Class] Flush only the caches for the given
      #   RSRC_LIST_KEY. or the EAdef cache for the given extendable class.
      #   If nil (the default), flushes all caches
      #
      # @return [void]
      #
      def flushcache(key_or_klass = nil)
        # EA defs for just one extendable class?
        if EXTENDABLE_CLASSES.include? key_or_klass.to_s
          @c_ext_attr_definition_cache[key_or_klass] = Concurrent::Map.new

        # one API object class?
        elsif key_or_klass
          map_key_pfx = "#{key_or_klass}_map_"
          @c_object_list_cache.each_key do |cache_key|
            next unless cache_key == key_or_klass || cache_key.to_s.start_with?(map_key_pfx)

            @c_object_list_cache.delete cache_key
          end

        # flush everything
        else
          @c_object_list_cache = Concurrent::Map.new
          @c_ext_attr_definition_cache = Concurrent::Map.new
        end

        GC.start
      end

    end # module

  end # class

end # module Jamf
