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

  # A Collection Resource in Jamf Pro
  #
  # See {Jamf::Resource} for general info about API resources.
  #
  # Collection resources have more than one resource within them, and those
  # can (usually) be created and deleted as well as fetched and updated.
  # The entire collection (or a part of it) can also be fetched as an Array.
  # When the whole collection is fetched, the result is cached for future use.
  #
  # # Subclassing
  #
  # ## Creatability & Deletability
  #
  # Sometimes the API doesn't support creation of new members of the collection.
  # If that's the case, just set the constant NOT_CREATABLE to true (or any
  # truthy value, but just use true :)
  # and the '.create' class method will raise an error.
  #
  # Similarly for deletion of members: if the API doesn't have a way to delete
  # them, set NOT_DELETABLE
  #
  # ## Bulk Deletion
  #
  # Some collection resources have a resource for bulk deletion, passing in
  # a JSON array of ids to delete.
  #
  # If so, just define a BULK_DELETE_RSRC, and the .delete class method
  # will use it, rather than making multiple calls to delete individual
  # items. See Jamf::Category::BULK_DELETE_RSRC for an example
  #
  # @abstract
  #
  class CollectionResource < Jamf::Resource

    extend Jamf::Abstract
    include Comparable

    # Public Class Methods
    #####################################

    # @return [Array<Symbol>] the attribute names that are marked as identifiers
    #
    def self.identifier_attributes
      self::OBJECT_MODEL.select { |_attr, deets| deets[:identifier] }.keys
    end

    # @return [Symbol] the attribute name of the primary identifier for this subclass
    #
    def self.primary_identifier_attribute
      self::OBJECT_MODEL.select { |_attr, deets| deets[:identifier] == :primary }.keys.first
    end

    # An array of attribute names that are required when
    # making new CollectionResources
    # See the OBJECT_MODEL documentation in {Jamf::JSONObject}
    def self.required_attributes
      self::OBJECT_MODEL.select { |_attr, deets| deets[:required] }.keys
    end

    # The Collection members Array for this class, retrieved from
    # the RSRC_PATH as Parsed JSON, but not instantiated into instances
    # unless instantiate: is truthy.
    #
    # E.g. for {Jamf::Settings::Building}, this would be the Array of Hashes
    # returned by GETing the resource .../settings/obj/building
    #
    # This Array is cached in the {Jamf::Connection} instance used to
    # retrieve it, and future calls to .all will return the cached Array
    # unless refresh is truthy.
    #
    # TODO: Investigate https://www.rubydoc.info/github/mloughran/api_cache
    #
    # @param refresh[Boolean] re-read the data from the API?
    #
    # @param cnx[Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active connection. See {Jamf::Connection}
    #
    # @param instantiate[Boolean] The Array contains instances of this class
    #   rather than the JSON Hashes from the API.
    #
    # @return  [Array<Object>] An Array of all objects of this class in the JSS.
    #
    def self.all(refresh = false, cnx: Jamf.cnx, instantiate: false)
      validate_not_abstract
      cnx.collection_cache[self] = nil if refresh
      return cnx.collection_cache[self] if cnx.collection_cache[self]

      raw = cnx.get rsrc_path
      cnx.collection_cache[self] =
        if raw.is_a?(Hash) && raw[:results]
          raw[:results]
        else
          raw
        end

      return cnx.collection_cache[self] unless instantiate

      cnx.collection_cache[self].map { |m| new m }
    end

    # An array of the primary_identifiers for collection members
    # regardless of the name of the primary_identifier_attribute.
    #
    # If the primary_identifier_attribute is `:udid`, then this
    # is identical to calling  `.all_udids`.
    #
    # @param refresh (see .all)
    #
    # @param cnx (see .all)
    #
    # @return [Array]
    #
    def self.all_primary_identifiers(refresh = false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).map { |m|  m[primary_identifier_attribute] }
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName

    # A Hash of all members of this collection where the keys are some
    # identifier and values are any other attribute.
    #
    # @param ident [Symbol] An identifier of this Class, used as the key
    #   for the mapping Hash.
    #
    # @param to [Symbol] The attribute to which the ident will be mapped
    #
    # @param refresh (see .all)
    #
    # @param cnx (see .all)
    #
    # @return [Hash {Symbol: Object}] A Hash of identifier mapped to attribute
    #
    def self.map_all(ident, to:, cnx: Jamf.cnx, refresh: false)
      raise Jamf::InvalidDataError, "No identifier #{ident} for class #{self}" unless
      identifier_attributes.include? ident

      raise Jamf::NoSuchItemError, "No attribute #{to} for class #{self}" unless self::OBJECT_MODEL.key? to

      list = all refresh, cnx: cnx
      to_class = self::OBJECT_MODEL[to][:class]
      mapped = list.map do |i|
        [
          i[ident],
          to_class.is_a?(Symbol) ? i[to] : to_class.new(i[to])
        ]
      end # do i
      mapped.to_h
    end
    # rubocop:enable Naming/UncommunicativeMethodParamName

    # Given any identfier value for this collection, return the valid
    # primary identifier, or nil if there's no match for the given value.
    #
    # E.g. if the primary identfier is :id, and others are :name and :serialnumber
    # then the given value is checked to see if it matches an existing :id, or
    # :name or :serialnumber. If so, the :id for the matching object is returned.
    #
    # If no match is found, nil is returned.
    #
    # @param possible_ident [Object] A value to search for as an identifier.
    #
    # @param cnx (see .all)
    #
    # @return [Object, nil] the primary identifier of the matching object,
    #   or nil if it doesn't exist
    #
    def self.valid_id(possible_ident, cnx: Jamf.cnx)
      # check the primary id first, and refresh
      return possible_ident if all_primary_identifiers(:refresh, cnx: cnx).include? possible_ident

      identifier_attributes.each do |ident|
        # we already checked the primary
        next if primary_identifier_attribute == ident

        match = all(cnx: cnx).select { |m| m[ident] == possible_ident }.first

        return match[primary_identifier_attribute] if match
      end # identifier_attributes.each do |ident|

      nil
    end

    # Make a new thing to be added to the API
    def self.create(params, cnx: Jamf.cnx)
      raise Jamf::UnsupportedError, "#{self}'s are not currently creatable via the API" if defined? self::NOT_CREATABLE
      validate_not_abstract
      validate_required_attributes params
      params.delete primary_identifier_attribute # no such animal when .making
      params[:creating_from_create] = true
      new params, cnx: cnx
    end

    # Retrieve a member of a CollectionResource from the API
    #
    # To create new members to be added to the JSS, use
    # {Jamf::CollectionResource.create}
    #
    # If you know the specific identifier attribute you're looking up, e.g.
    # :id or :name or :udid, (or an aliase thereof) then you can specify it like
    # `.fetch name: 'somename'`, or `.fetch udid: 'someudid'`
    #
    # If you don't know if (or don't want to type it) you can just use
    # `.fetch 'somename'`, or `.fetch 'someudid'` and all identifiers will be
    # searched for a match.
    #
    # @param ident_value[Object] A value for any identifier for this subclass.
    #  All identifier attributes will be searched for a match.
    #
    # @param version[String] the API resource version to use.
    #   Defaults to the RSRC_VERSION for the class.
    #
    # @param cnx[Jamf::Connection] the connection to use to fetch the object
    #
    # @param ident_hash[Hash] an identifier attribute key and a search value
    #
    # @return [CollectionResource] The ruby-instance of a Jamf object
    #
    def self.fetch(ident_value = nil, version: nil, cnx: Jamf.cnx, **ident_hash)
      validate_not_abstract
      version ||= self::RSRC_VERSION

      if ident_hash.empty?
        lookup_value = ident_value
      else
        ident, lookup_value = ident_hash.first
        identifier_to_search = attr_key_for_alias(ident)
        raise ArgumentError, "Unknown Identifier for #{self}: #{ident}" unless identifier_to_search
      end

      raise Jamf::MissingDataError, 'No search value specified' unless lookup_value

      data = fetch_data identifier_to_search, lookup_value, version, cnx
      raise Jamf::NoSuchItemError, "No matching #{self}" unless data

      new data, cnx: cnx
    end # fetch

    # Delete one or more objects by identifier
    # Any valid identifier for the class can be used (id, name, udid, etc)
    # Identifiers can be provided as an array or as separate parameters
    #
    # e.g. .delete [1,3, 34, 4]  or .delete 'myComputer', 'that-computer', 'OtherComputer'
    #
    # @param idents[Array<integer>, Integer]
    #
    # @param cnx[Jamf::Connection]
    #
    # @return [Array] the identifiers that were not found, so couldn't be deleted
    #
    def self.delete(*idents, cnx: Jamf.cnx)
      raise Jamf::UnsupportedError, "#{self}'s are not currently deletable via the API" if defined? self::NOT_DELETABLE

      idents.flatten!
      no_valid_ids = []

      idents.map do |ident|
        id = valid_id ident
        no_valid_ids << ident unless id
        id
      end
      idents.compact!

      if defined? self::BULK_DELETE_RSRC
        cnx.post self::BULK_DELETE_RSRC idents
      else
        idents.each { |id| cnx.delete "#{rsrc_path}/#{id}" }
      end

      skipped
    end


    # Private Class Methods
    #####################################

    # TODO: better pluralizing?
    #
    def self.create_list_methods(attr_name, attr_def)
      list_method_name = "all_#{attr_name}s"

      define_singleton_method(list_method_name) do |refresh = false, cnx: Jamf.cnx|
        all_list = all(refresh, cnx: cnx)
        if attr_def[:class].is_a? Symbol
          all_list.map { |i| i[attr_name] }.uniq
        else
          all_list.map { |i| attr_def[:class].new i[attr_name] }
        end
      end # define_singleton_method

      return unless attr_def[:aliases]

      # aliases - TODO: is there a more elegant way?
      attr_def[:aliases].each do |a|
        define_singleton_method("all_#{a}s") do |refresh = false, cnx: Jamf.cnx|
          send list_method_name, refresh, cnx: cnx
        end # define_singleton_method
      end # each alias

    end # create_list_methods
    private_class_method :create_list_methods

    # validate that our .create data has the required attribute values.
    # They can't be nil or empty.
    #
    def self.validate_required_attributes(data)
      required_attributes.each do |atr|
        raise Jamf::MissingDataError, "Required attribute '#{atr}:' may not be nil or empty" if data[atr].to_s.empty?
      end
    end
    private_class_method :validate_required_attributes

    # used by fetch
    def self.fetch_data(identifier_to_search, lookup_value, version, cnx)
      #### Search by known primary ident
      if identifier_to_search == primary_identifier_attribute
        fetch_data_by_primary_ident lookup_value, version, cnx

      ### Search by known ident other than primary
      elsif identifier_to_search
        fetch_data_by_known_ident_search identifier_to_search, lookup_value, cnx

      # Search by arbitrary ident using Searchable
      elsif include? Jamf::Searchable
        fetch_data_by_arbitrary_ident_api_search lookup_value, cnx

      # Search by arbitrary ident using Collection Cache
      else
        fetch_data_by_arbitrary_ident_collection_search lookup_value, cnx

      end # if ...
    end
    private_class_method :fetch_data

    # used by fetch
    def self.fetch_data_by_primary_ident(ident, version, cnx)
      cnx.get "#{rsrc_path}/#{ident}"
    rescue RestClient::NotFound, RestClient::BadRequest
      nil
    end
    private_class_method :fetch_data_by_primary_ident

    # used by fetch
    def self.fetch_data_by_known_ident_search(ident, value, cnx)
      if include? Jamf::Searchable
        matches = search key: ident, value: value, cnx: cnx
        raise 'Ambiguous Search' if matches.size > 1
        matches.first
      else
        all(:refresh, cnx: cnx).select { |m| m[ident] == value }.first
      end # if searchable?
    end
    private_class_method :fetch_data_by_known_ident_search

    # used by fetch
    def self.fetch_data_by_arbitrary_ident_api_search(value, cnx)
      # the value might be the primary identifier, which isn't in the
      # searchablekeys, so we have to look it up directly
      data = fetch_data_by_primary_ident value, cnx
      return data if data

      # now loop thru the other identifiers
      identifier_attributes.each do |search_key|
        matches = search key: search_key, value: value, cnx: cnx
        data = matches.first
        return data if data
      end
      nil
    end
    private_class_method :fetch_data_by_arbitrary_ident_api_search

    # used by fetch
    def self.fetch_data_by_arbitrary_ident_collection_search(value, cnx)
      list = all(:refresh, cnx: cnx)
      identifier_attributes.each do |iden_to_search|
        data = list.select { |m| m[iden_to_search] == value }.first
        return data if data
      end

      nil
    end
    private_class_method :fetch_data_by_arbitrary_ident_collection_search

    # Instance Methods
    #####################################

    def primary_identifier
      send self.class.primary_identifier_attribute
    end

    def exist?
      !primary_identifier.nil?
    end


    def rsrc_path
      "#{self.class.rsrc_path}/#{primary_identifier}"
    end

    def delete
      self.class.delete @id, cnx: @cnx
    end

    # Two collection resource objects are the same if their primary
    # identifiers (usually 'id') are the same.
    def <=>(other)
      primary_identifier <=> other.primary_identifier
    end

    # Private Instance Methods
    ############################################
    private

    def create_in_jamf
      return unless defined? self.class::CREATABLE
      return unless is_a? Jamf::CollectionResource

      result = @cnx.post self.class::RSRC_PATH, to_jamf

      id_attr = self.class.primary_identifier_attribute
      instance_variable_set "@#{id_attr}", result[id_attr]
    end

  end # class CollectionResource

end # module JAMF
