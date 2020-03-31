# Copyright 2019 Pixar

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
  # ## Creatability, & Deletability
  #
  # Sometimes the API doesn't support creation of new members of the collection.
  # If that's the case, just extend the subclass with Jamf::UnCreatable
  # and the '.create' class method will raise an error.
  #
  # Similarly for deletion of members: if the API doesn't have a way to delete
  # them, extend the subclass with Jamf::UnDeletable
  #
  # See also Jamf::JSONObject, which talks about extending subclasses
  # with Jamf::Immutable
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
    def self.identifiers
      self::OBJECT_MODEL.select { |_attr, deets| deets[:identifier] }.keys
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
      if cnx.collection_cache[self]
        return cnx.collection_cache[self] unless instantiate

        return cnx.collection_cache[self].map { |m| new m }
      end

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

    # An array of the ids for all collection members. According to the
    # specs ALL collection resources must have an ID, which is used in the
    # resource path.
    #
    # @param refresh (see .all)
    #
    # @param cnx (see .all)
    #
    # @return [Array<Integer>]
    #
    def self.all_ids(refresh = false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).map { |m|  m[:id] }
    end

    # rubocop:disable Naming/UncommunicativeMethodParamName

    # A Hash of all members of this collection where the keys are some
    # identifier and values are any other attribute.
    #
    # @param ident [Symbol] An identifier of this Class, used as the key
    #   for the mapping Hash. Aliases are acceptable, e.g. :sn for :serialNumber
    #
    # @param to [Symbol] The attribute to which the ident will be mapped.
    #   Aliases are acceptable, e.g. :name for :displayName
    #
    # @param refresh (see .all)
    #
    # @param cnx (see .all)
    #
    # @return [Hash {Symbol: Object}] A Hash of identifier mapped to attribute
    #
    def self.map_all(ident, to:, cnx: Jamf.cnx, refresh: false)
      real_ident = attr_key_for_alias ident
      raise Jamf::InvalidDataError, "No identifier #{ident} for class #{self}" unless
      identifiers.include? real_ident

      real_to = attr_key_for_alias to
      raise Jamf::NoSuchItemError, "No attribute #{to} for class #{self}" unless self::OBJECT_MODEL.key? real_to

      ident = real_ident
      to = real_to
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

    # Given any identfier value for this collection, return the id of the
    # object that has such an identifier.
    #
    # Return nil if there's no match for the given value.
    #
    # If you know the value is a certain identifier, e.g. a serialNumber,
    # then you can specify the identifier for a faster search:
    #
    #   valid_id serialNumber: 'AB12DE34' # => Int or nil
    #
    # If you don't know wich identifier you have, just pass the value and
    # all identifiers are searched
    #
    #   valid_id 'AB12DE34' # => Int or nil
    #   valid_id 'SomeComputerName' # => Int or nil
    #
    # When the value is a string, the seach is case-insensitive
    #
    # TODO: When 'Searchability' is more dialed in via the searchable
    # mixin, which implements enpoints like 'POST /v1/search-mobile-devices'
    # then use that before using the 'all' list.
    #
    # @param value [Object] A value to search for as an identifier.
    #
    # @param refresh[Boolean] Reload the list data from the API
    #
    # @param ident: [Symbol] Restrict the search to this identifier.
    #  E.g. if :serialNumber, then the value must be
    #  a known serial number, it is not checked against other identifiers
    #
    # @param cnx: (see .all)
    #
    # @return [Object, nil] the primary identifier of the matching object,
    #   or nil if it doesn't exist
    #
    def self.valid_id(value = nil, refresh: true, cnx: Jamf.cnx, **ident_hash)
      unless ident_hash.empty?
        ident, value = ident_hash.first
        return id_from_other_ident ident, value, refresh, cnx: cnx
      end

      # check the id itself first
      return value if all_ids(refresh, cnx: cnx).include? value

      idents = identifiers - [:id]
      val_is_str = value.is_a? String

      idents.each do |ident|
        match = all(refresh, cnx: cnx).select do |m|
          val_is_str ? m[ident].to_s.casecmp?(value) : m[ident] == value
        end.first
        return match[:id] if match
      end # identifiers.each do |ident|

      nil
    end

    # Bu default, subclasses are creatable, i.e. new instances can be created
    # with .create, and added to the JSS with .save
    # If a subclass is NOT creatble for any reason, just add
    #   extend Jamf::UnCreatable
    # and this method will return false
    #
    # @return [Boolean]
    def self.creatable?
      true
    end

    # Make a new thing to be added to the API
    def self.create(**params)
      validate_not_abstract
      raise Jamf::UnsupportedError, "#{self}'s are not currently creatable via the API" unless creatable?

      cnx = params.delete :cnx
      cnx ||= Jamf.cnx

      params.delete :id # no such animal when .creating

      params.keys.each do |param|
        raise ArgumentError, "Unknown parameter: #{param}" unless self::OBJECT_MODEL.key? param

        params[param] = validate_attr param, params[param], cnx: cnx
      end

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
    # @param cnx[Jamf::Connection] the connection to use to fetch the object
    #
    # @param ident_hash[Hash] an identifier attribute key and a search value
    #
    # @return [CollectionResource] The ruby-instance of a Jamf object
    #
    def self.fetch(ident_value = nil, cnx: Jamf.cnx, **ident_hash)
      validate_not_abstract

      id =
        if ident_value == :random
          all_ids.sample
        elsif ident_value
          valid_id ident_value, cnx: cnx
        elsif ident_hash.empty?
          nil
        else
          ident, lookup_value = ident_hash.first
          valid_id ident => lookup_value, cnx: cnx
        end

      raise Jamf::NoSuchItemError, "No matching #{self}" unless id

      data = cnx.get "#{rsrc_path}/#{id}"
      new data, cnx: cnx
    end # fetch

    # By default, CollectionResource subclass instances are deletable.
    # If not, just extend the subclass with Jamf::UnDeletable, and this
    # will return false, and .delete & #delete will raise errors
    def self.deletable?
      true
    end

    # Delete one or more objects by identifier
    # Any valid identifier for the class can be used (id, name, udid, etc)
    # Identifiers can be provided as an array or as separate parameters
    #
    # e.g. .delete [1,3, 34, 4]
    # or .delete 'myComputer', 'that-computer', 'OtherComputer'
    #
    # @param idents[Array<integer>, Integer]
    #
    # @param cnx[Jamf::Connection]
    #
    # @return [Array] the identifiers that were not found, so couldn't be deleted
    #
    def self.delete(*idents, cnx: Jamf.cnx)
      raise Jamf::UnsupportedError, "Deleting #{self} objects is not currently supported" unless deletable?

      idents.flatten!
      no_valid_ids = []

      idents.map do |ident|
        id = valid_id ident
        no_valid_ids << ident unless id
        id
      end
      idents.compact!

      # TODO: some rsrcs have a 'bulk delete' version...
      idents.each { |id| cnx.delete "#{rsrc_path}/#{id}" }

      no_valid_ids
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

    # Given an indentier attr. key, and a value,
    # return the id where that ident has that value, or nil
    #
    def self.id_from_other_ident(ident, value, refresh = true, cnx: Jamf.cnx)
      raise ArgumentError, "Unknown identifier '#{ident}' for #{self}" unless identifiers.include? ident

      # check the id itself first
      return value if ident == :id && all_ids(refresh, cnx: cnx).include?(value)

      # all ident values => ids
      ident_map = map_all(ident, to: :id, cnx: cnx, refresh: refresh)

      # case-insensitivity for string values
      value = ident_map.keys.j_ci_fetch(value) if value.is_a? String

      ident_map[value]
    end
    private_class_method :id_from_other_ident

    # Instance Methods
    #####################################

    def exist?
      !@id.nil?
    end

    def rsrc_path
      return unless exist?
      "#{self.class.rsrc_path}/#{@id}"
    end

    def delete
      raise Jamf::UnsupportedError, "Deleting #{self} objects is not currently supported" unless self.class.deletable?
      @cnx.delete rsrc_path
    end

    # Two collection resource objects are the same if their id's are the same
    def <=>(other)
      id <=> other.id
    end

    # Private Instance Methods
    ############################################
    private

    def create_in_jamf
      result = @cnx.post self.class.rsrc_path, to_jamf
      @id = result[:id]
    end

  end # class CollectionResource

end # module JAMF
