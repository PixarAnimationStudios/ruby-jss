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

module Jamf

  # A Collection Resource in Jamf Pro
  #
  # See {Jamf::Resource} for general info about API resources.
  #
  # Collection resources have more than one resource within them, and those
  # can (usually) be created and deleted as well as fetched and updated.
  # The entire collection (or a part of it) can also be retrieved as an Array.
  # When the whole collection is retrieved, the result may be cached for future
  # use.
  #
  # # Subclassing
  #
  # ## Creatability, & Deletability
  #
  # Sometimes the API doesn't support creation of new members of the collection.
  # If that's the case, just extend the subclass with Jamf::Uncreatable
  # and the '.create' class method will raise an error.
  #
  # Similarly for deletion of members: if the API doesn't have a way to delete
  # them, extend the subclass with Jamf::Undeletable
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
  ######################################
  module CollectionResource

    include Jamf::JPAPIResource

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including Jamf::CollectionResource"
      includer.extend(ClassMethods)
    end

    # Class Methods
    #####################################
    module ClassMethods

      # 'include' all of these, so their methods become defined in this
      # module, and will become Class Methods when this module
      # is extended.
      # since this module will be extended into a class

      # It seems that all current collections are pageable and sortable
      #
      # Filterable must be extended as needed in Colection Resources

      include Jamf::JPAPIResource::ClassMethods

      # when this module is included, also extend our 'parent' class methods
      ######################################
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::CollectionResource::ClassMethods"
      end

      # All Classes including CollectionResource MUST define 'LIST_PATH', which
      # is the URL path for GETting the list of all objects in the collection,
      # possibly filtered, sorted, and/or paged

      # The path for GETting a single object. The desired object id will be appended
      # to the end, e.g. if this value is 'v1/buildings' and you want to GET the
      # record for building id 23, then we will GET from 'v1/buildings/23'
      #
      # Classes including CollectionResource really need to define GET_PATH if it
      # is not the same as the LIST_PATH.
      ######################################
      def get_path
        @get_path ||= defined?(self::GET_PATH) ? self::GET_PATH : self::LIST_PATH
      end

      # The path for PUTting (replacing) a single object. The desired object id will
      # be appended to the end, e.g. if this value is 'v1/buildings' and you want
      # to PUT the record for building id 23, then we will PUT to 'v1/buildings/23'
      #
      # Classes including CollectionResource really need to define PUT_PATH if it
      # is not the same as the LIST_PATH.
      ######################################
      def put_path
        @put_path ||= defined?(self::PUT_PATH) ? self::PUT_PATH : self::LIST_PATH
      end

      # The path for PATCHing (updating in-place) a single object. The desired
      # object id will be appended to the end, e.g. if this value is 'v1/buildings'
      # and you want to PATCH the record for building id 23, then we will PATCH to
      # 'v1/buildings/23'
      #
      # Classes including CollectionResource really need to define PATCH_PATH if it
      # is not the same as the LIST_PATH.
      ######################################
      def patch_path
        @patch_path ||= defined?(self::PATCH_PATH) ? self::PATCH_PATH : self::LIST_PATH
      end

      # The path for POSTing to create a single object in the collection.
      #
      # Classes including CollectionResource really need to define POST_PATH if it
      # is not the same as the LIST_PATH.
      ######################################
      def post_path
        @post_path ||= defined?(self::POST_PATH) ? self::POST_PATH : self::LIST_PATH
      end

      # The path for DELETEing a single object from the collection.
      #
      # Classes including CollectionResource really need to define DELETE_PATH if it
      # is not the same as the LIST_PATH.
      ######################################
      def delete_path
        @delete_path ||= defined?(self::DELETE_PATH) ? self::DELETE_PATH : self::LIST_PATH
      end

      # @return [Array<Symbol>] the attribute names that are marked as identifiers
      #
      ######################################
      def identifiers
        idents = self::OAPI_PROPERTIES.select { |_attr, deets| deets[:identifier] }.keys
        idents += self::ALT_IDENTIFIERS if defined? self::ALT_IDENTIFIERS
        idents += self::NON_UNIQUE_IDENTIFIERS if defined? self::NON_UNIQUE_IDENTIFIERS
        idents.delete_if { |i| !self::OAPI_PROPERTIES.key?(i) }
        idents
      end

      # Get all instances of a CollectionResource, possibly sorted or limited by
      # a filter.
      #
      # By default, this method will return a single Array data about all items
      # in the CollectionResouce, in the server's default sort order, or a sort
      # order you specify.
      #
      # If you specify a filter, the Array returned by the server will contain
      # only matching objects, and it will not be cached.
      #
      # #### Server-side Sorting
      #
      # Sorting criteria can be provided using the 'sort:' parameter, which is
      # a String of the format 'property:direction',
      # where direction is 'asc' or 'desc' E.g.
      #   "username:asc"
      #
      # Multiple properties are supported, either as separate strings in an Array,
      # or a single string, comma separated. E.g.
      #
      #    "username:asc,timestamp:desc"
      # is the same as
      #    ["username:asc", "timestamp:desc"]
      #
      # which will sort by username alphabetically, and within each username,
      # sort by timestamp newest first.
      #
      # Please see the JamfPro API documentation for the resource for details
      # about available sorting properties and default sorting criteria
      #
      # #### Filtering
      #
      # Some CollectionResouces support RSQL filters to limit which objects
      # are returned by the server. These filters can be applied using the filter:
      # parameter, in which case this `all` method will return "all that match
      # the filter".
      #
      # The filter parameter is a string, as it would be provided in the API URL
      # manually, e.g. 'categoryName=="Category"' (be careful about inner quoting)
      #
      # If the resource doesn't support filters, the filter parameter is ignored.
      #
      # Please see the JamfPro API documentation for the resource to see if
      # filters are supported, and a list of available fields.
      # See also https://developer.jamf.com/jamf-pro/docs/filtering-with-rsql
      #
      # #### Instantiation
      #
      # All data from the API comes from the server in JSON format, mostly as
      # JSON 'objects', which are the equivalent of ruby Hashes.
      # When fetching an individual instance of an object from the API, ruby-jss
      # uses the JSON Hash to create the ruby object, i.e. to 'instantiate' it as
      # an instance of its ruby class. Doing this for many objects can slow
      # things down.
      #
      # Because of this, the 'all' method defaults to returning an Array of the
      # minimally-processed JSON Hashes it gets from the API. If you can get your
      # desired data from these Hashes, it may be more efficient to do so.
      #
      # However sometimes you really need the fully instantiated ruby objects for
      # all items returned - especially if you're using filters and not actually
      #  processing all items of the class.  In such cases you can pass a truthy
      # value to the instantiate: parameter, and the Array will contain fully
      # instantiated ruby objects, not Hashes of API data.
      #
      # #### Caching - none for Jamf Pro API objects.
      #
      # Unlike the Classic APIObjects, Objects from the Jamf Pro API
      # are not cached and any call to 'all' or methods that use it, will
      # always query the API. If you need to use the resulting array for multiple
      # tasks, save it into a variable and use that.
      #
      #######
      #
      # @param sort [String, Array<String>] Server-side sorting criteria in the
      #   format: property:direction, where direction is 'asc' or 'desc'. Multiple
      #   properties are supported, either as separate strings in an Array, or
      #   a single string, comma separated.
      #
      # @param filter [String] An RSQL filter string. Not all collection resources
      #   currently support filters, and if they don't, this will be ignored.
      #
      # @param instantiate [Boolean] Defaults to false. Should the items in the
      #   returned Array be ruby instances of the CollectionObject subclass, or
      #   plain Hashes of data as returned by the API?
      #
      # @param cnx [Jamf::Connection] The API connection to use, default: Jamf.cnx
      #
      # @return [Array<Hash, Jamf::CollectionResource>] The objects in the collection
      #
      ######################################
      def all(sort: nil, filter: nil, instantiate: false, cnx: Jamf.cnx, refresh: nil)
        # if we are here, we need to query for all items, possibly filtered and
        # sorted
        sort = Jamf::Sortable.parse_url_sort_param(sort)
        filter = filterable? ? Jamf::Filterable.parse_url_filter_param(filter) : nil
        instantiate &&= self

        # always use a pager to get all pages, because even if you don't ask for
        # paged data, it comes in pages or 2000
        Jamf::Pager.all_pages(
          list_path: self::LIST_PATH,
          sort: sort,
          filter: filter,
          instantiate: instantiate,
          cnx: cnx
        )
      end

      # Return a Jamf::Pager object for retrieving all collection items in smaller
      # groups.
      #
      # For other parameters, see CollectionResource.all
      #
      # @param page_size [Integer] The pager object returns results in groups of
      #   this many items. Minimum is 1, maximum is 2000, default is 100
      #   Note: the final page of data may contain fewer items than the page_size
      #
      # @return [Jamf::Pager] An object from which you can retrieve sequential or
      #   arbitrary pages from the collection.
      #
      def pager(page_size: Jamf::Pager::DEFAULT_PAGE_SIZE, sort: nil, filter: nil, instantiate: false, cnx: Jamf.cnx)
        sort = Jamf::Sortable.parse_url_sort_param(sort)
        filter = filterable? ? Jamf::Filterable.parse_url_filter_param(filter) : nil
        instantiate &&= self

        Jamf::Pager.new(
          page_size: page_size,
          list_path: self::LIST_PATH,
          sort: sort,
          filter: filter,
          instantiate: instantiate,
          cnx: cnx
        )
      end

      # A Hash of all members of this collection where the keys are some
      # identifier and values are any other attribute.
      #
      # @param ident [Symbol] An identifier of this Class, used as the key
      #   for the mapping Hash. Aliases are acceptable, e.g. :sn for :serialNumber
      #
      # @param to [Symbol] The attribute to which the ident will be mapped.
      #   Aliases are acceptable, e.g. :name for :displayName
      #
      # @param cached_list [Array<Hash>] The result of a previous call to .all
      #   can be passed in here, to prevent calling .all again to generate a
      #   fresh list.
      #
      # @param cnx (see .all)
      #
      # @return [Hash {Symbol: Object}] A Hash of identifier mapped to attribute
      #
      ######################################
      def map_all(ident, to:, cnx: Jamf.cnx, cached_list: nil, refresh: nil)
        raise Jamf::InvalidDataError, "No identifier :#{ident} for class #{self}" unless
        identifiers.include? ident

        raise Jamf::NoSuchItemError, "No attribute :#{to} for class #{self}" unless self::OAPI_PROPERTIES.key? to

        list = cached_list || all(cnx: cnx)
        to_class = self::OAPI_PROPERTIES[to][:class]
        to_multi = self::OAPI_PROPERTIES[to][:multi]
        mapped = list.map do |i|
          mapped_val =
            if to_class.is_a?(Symbol)
              i[to]
            elsif to_multi
              i[to].map { |sub_i| to_class.new(sub_i) }
            else
              to_class.new(i[to])
            end

          [i[ident], mapped_val]
        end # do i
        mapped.to_h
      end

      # Given a key (identifier) and value for this collection, return the raw data
      # Hash (the JSON object) for the matching API object or nil if there's no
      # match for the given value.
      #
      # In general you should use this if the form:
      #
      #    raw_data identifier: value
      #
      # where identifier is one of the available identifiers for this class
      # like id:, name:, serialNumber: etc.
      #
      # In the unlikely event that you dont know which identifier a value is for
      # or want to be able to take any of them without specifying, then
      # you can use
      #
      #   raw_data some_value
      #
      # If some_value is an integer or a string containing an integer, it
      # is assumed to be an :id, otherwise all the available identifers
      # are searched, in the order you see them when you call <class>.identifiers
      #
      # If no matching object is found, nil is returned.
      #
      # Everything except :id is treated as a case-insensitive String
      #
      # @param value [String, Integer] The identifier value to search fors
      #
      # @param key: [Symbol] The identifier being used for the search.
      #  E.g. if :serialNumber, then the value must be a known serial number, it
      #  is not checked against other identifiers. Defaults to :id
      #
      # @param cnx: (see .all)
      #
      # @return [Hash, nil] the basic dataset of the matching object,
      #   or nil if it doesn't exist
      #
      ######################################
      def raw_data(searchterm = nil, ident: nil, value: nil, cnx: Jamf.cnx)
        # given a value with no ident key
        return raw_data_by_searchterm_only(searchterm, cnx: cnx) if searchterm

        # if we're here, we should know our ident key and value
        raise ArgumentError, 'Required parameter "identifier: value", where identifier is id:, name: etc.' unless ident && value

        # if the ident is :name, and there's a constant for the name attr, use that
        ident = self::OBJECT_NAME_ATTR if defined?(self::OBJECT_NAME_ATTR) && ident == :name

        return raw_data_by_id(value, cnx: cnx) if ident == :id
        return unless identifiers.include? ident

        raw_data_by_other_identifier(ident, value, cnx: cnx)
      end

      # Match the given value in all possibly identifiers
      def raw_data_by_searchterm_only(searchterm, cnx: Jamf.cnx)
        # if this is an integer or j_integer, assume its an ID
        return raw_data_by_id(searchterm, cnx: cnx) if searchterm.to_s.j_integer?

        identifiers.each do |ident|
          next if ident == :id

          data = raw_data_by_other_identifier(ident, searchterm, cnx: cnx)
          return data if data
        end # identifiers.each

        nil
      end

      # get the basic dataset by id, with optional
      # request params to get more than basic data
      ######################################
      def raw_data_by_id(id, cnx: Jamf.cnx)
        cnx.jp_get "#{get_path}/#{id}"
      rescue Jamf::Connection::JamfProAPIError => e
        return nil if e.errors.any? { |err| err.code == 'INVALID_ID' }

        raise e
      end

      # Given an indentier attr. key, and a value,
      # return the raw data where that ident has that value, or nil
      #
      ######################################
      def raw_data_by_other_identifier(identifier, value, cnx: Jamf.cnx)
        # if the API supports filtering by this identifier, just use that
        return pager(filter: "#{identifier}==\"#{value}\"", page_size: 1, cnx: cnx).page(:first).first if filterable? && filter_keys.include?(identifier)

        # otherwise we have to loop thru all the objects looking for the value
        # which can be slow if there are lots of objects.
        cmp_val = value.to_s
        all(cnx: cnx).each do |data|
          return data if data[identifier].to_s.casecmp? cmp_val
        end

        nil
      end

      # Look up the valid ID for any arbitrary identifier.
      # In general you should use this if the form:
      #
      #    valid_id identifier: value
      #
      # where identifier is one of the available identifiers for this class
      # like id:, name:, serialNumber: etc.
      #
      # In the unlikely event that you dont know which identifier a value is for
      # or want to be able to take any of them without specifying, then
      # you can use
      #
      #   valid_id some_value
      #
      # If some_value is an integer or a string containing an integer, it
      # is assumed to be an id: otherwise all the available identifers
      # are searched, in the order you see them when you call <class>.identifiers
      #
      # If no matching object is found, nil is returned.
      #
      # WARNING: Do not use this to look up ids for getting the
      # raw API data for an object. Since this calls .raw_data
      # itself, it is redundant to use .valid_id to get an id
      # to then pass on to .raw_data
      # Use raw_data directly like this:
      #    data = raw_data(ident: val)
      #
      #
      # @param value [String,Integer] A value for an arbitrary identifier
      #
      # @param cnx [Jamf::Connection] The connection to use. default: Jamf.cnx
      #
      # @param ident_and_val [Hash{Symbol: String}] The identifier key and the value
      #   to look for in that key, e.g. name: 'foo' or serialNumber: 'ASDFGH'
      #
      # @return [String, nil] The id (integer-in-string) of the object, or nil
      #    if no match found
      #
      ######################################
      def valid_id(searchterm = nil, cnx: Jamf.cnx, **ident_and_val)
        data =
          if ident_and_val.empty?
            raw_data(searchterm, cnx: cnx)
          else
            ident = ident_and_val.keys.first
            value = ident_and_val.values.first
            raw_data(cnx: cnx, ident: ident, value: value)
          end

        data&.dig(:id)
      end

      # By default, Collection Resources are creatable,
      # i.e. new instances can be created
      # with .create, and added to the JSS with .save
      # If a subclass is NOT creatble for any reason, just add
      #   extend Jamf::Uncreatable
      # and this method will return false
      #
      # @return [Boolean]
      ######################################
      def creatable?
        true
      end

      # Make a new thing to be added to the API
      ######################################
      def create(**params)
        # no such animal when .creating
        params.delete :id

        # Which connection to use
        params[:cnx] ||= Jamf.cnx

        # So the super constructor knows we are instantiating an object that
        # isn't from the API, and will do validation on all params.
        params[:creating_from_create] = true

        new(**params)
      end

      # Retrieve a member of a CollectionResource from the API
      #
      # To create new members to be added to the JSS, use
      # {Jamf::CollectionResource.create}
      #
      # You must know the specific identifier attribute you're looking up, e.g.
      # :id or :name or :udid, (or an aliase thereof) then you can specify it like
      # `.fetch name: 'somename'`, or `.fetch udid: 'someudid'`
      #
      # @param cnx[Jamf::Connection] the connection to use to fetch the object
      #
      # @param ident_and_val[Hash] an identifier attribute key and a search value
      #
      # @return [CollectionResource] The ruby-instance of a Jamf object
      #
      ######################################
      def fetch(searchterm = nil, random: false, cnx: Jamf.cnx, **ident_and_val)
        if searchterm == :random
          random = true
          searchterm = nil
        end

        data =
          if searchterm
            raw_data searchterm, cnx: cnx
          elsif random
            all.sample
          else
            ident, value = ident_and_val.first
            ident && value ? raw_data(ident: ident, value: value, cnx: cnx) : nil
          end

        raise Jamf::NoSuchItemError, "No matching #{self}" unless data

        data[:cnx] = cnx
        new(**data)
      end # fetch

      # By default, CollectionResource instances are deletable.
      # If not, just extend the subclass with Jamf::Undeletable, and this
      # will return false, and .delete & #delete will raise errors
      ######################################
      def deletable?
        true
      end

      def filterable?
        singleton_class.ancestors.include? Jamf::Filterable
      end

      def bulk_deletable?
        singleton_class.ancestors.include? Jamf::BulkDeletable
      end

      # Delete one or more objects by id
      # TODO: fix this return value, no more ErrorInfo
      #
      # @param ids [Array<String,Integer>] The ids to delete
      #
      # @param cnx [Jamf::Connection] The connection to use, default: Jamf.cnx
      #
      #
      # @return [Array<Jamf::Connection::JamfProAPIError::ErrorInfo] Info about any ids
      #   that failed to be deleted.
      #
      ######################################
      def delete(*ids, cnx: Jamf.cnx)
        raise Jamf::UnsupportedError, "Deleting #{self} objects is not currently supported" unless deletable?

        return bulk_delete(ids, cnx: Jamf.cnx) if bulk_deletable?

        errs = []
        ids.each do |id_to_delete|
          cnx.jp_delete "#{delete_path}/#{id_to_delete}"
        rescue Jamf::Connection::JamfProAPIError => e
          raise e unless e.http_response.status == 404

          errs += e.errors
        end # ids.each
        errs
      end

      # Dynamically create_identifier_list_methods
      # when one is called.
      ######################################
      def method_missing(method, *args, &block)
        if available_list_methods.key? method.to_s
          attr_name = available_list_methods[method.to_s]
          create_identifier_list_method attr_name.to_sym, method
          send method, *args
        elsif method.to_s == 'all_names' && defined?(self::OBJECT_NAME_ATTR)
          define_singleton_method(:all_names) do |_refresh = nil, cnx: Jamf.cnx, cached_list: nil|
            send "all_#{self::OBJECT_NAME_ATTR}s", *args
          end
          send method, *args
        else
          super
        end
      end

      # this is needed to prevent problems with method_missing!
      ######################################
      def respond_to_missing?(method, *)
        available_list_methods.key?(method.to_s) || method.to_s == 'all_names' || super
      end

      # @return [Hash{String: Symbol}] Method name to matching attribute name for
      #   all identifiers
      ######################################
      def available_list_methods
        return @available_list_methods if @available_list_methods

        @available_list_methods = {}
        identifiers.each do |i|
          meth_name = i.to_s.end_with?('s') ? "all_#{i}es" : "all_#{i}s"
          @available_list_methods[meth_name] = i
        end
        @available_list_methods
      end

      # called from method_missing to create
      # identifier lists on the fly. No filtering or sorting of these lists.
      ######################################
      def create_identifier_list_method(attr_name, list_method_name)
        # only if the attr_name exists in the OAPI_PROPERTIES _and_
        # is listed as an identifier for this class.
        if defined?(self::OAPI_PROPERTIES) && self::OAPI_PROPERTIES.key?(attr_name) && identifiers.include?(attr_name)
          attr_def = self::OAPI_PROPERTIES[attr_name]

          define_singleton_method(list_method_name) do |_refresh = nil, cnx: Jamf.cnx, cached_list: nil|
            all_list = cached_list || all(cnx: cnx)
            if attr_def[:class].is_a? Symbol
              all_list.map { |i| i[attr_name] }
            else
              all_list.map { |i| attr_def[:class].new i[attr_name] }
            end
          end # define_singleton_method
          Jamf.load_msg "Defined method #{self}##{list_method_name}"
        else

          define_singleton_method(list_method_name) do |*|
            raise NoMethodError, "no method '#{list_method_name}': '#{attr_name}' is not an indentifier for #{self}"
          end
        end
      end # create_identifier_list_method
      private :create_identifier_list_method

    end # Module ClassMethods

    # Attributes
    #####################################

    # @return [String] The path for creating a new item in the collection
    #   in the JPAPI
    #
    attr_reader :post_path

    # @return [String] The path for deleting a this item from the collection
    #   in the JPAPI
    #
    attr_reader :delete_path

    # Constructor
    #####################################
    def initialize(**data)
      super
      set_api_paths
    end

    # Instance Methods
    #####################################

    #####################################
    def exist?
      !@id.nil?
    end

    #####################################
    def delete
      raise Jamf::UnsupportedError, "Deleting #{self} objects is not currently supported" unless self.class.deletable?

      @cnx.jp_delete delete_path
    end

    # A meaningful string representation of this object
    #
    # @return [String]
    #
    def to_s
      "#{self.class}@#{cnx.host}, id: #{@id}"
    end

    # Private Instance Methods
    ############################################
    private

    ############################################
    def set_api_paths
      if exist?
        @get_path = "#{self.class.get_path}/#{id}"

        @update_path =
          if defined?(self.class::PUT_PATH)
            "#{self.class::PUT_PATH}/#{id}"
          elsif defined?(self.class::PATCH_PATH)
            "#{self.class::PATCH_PATH}/#{id}"
          else
            "#{self.class::LIST_PATH}/#{id}"
          end

        @delete_path = defined?(self.class::DELETE_PATH) ? "#{self.class::DELETE_PATH}/#{id}" : "#{self.class::LIST_PATH}/#{id}"

        @post_path = nil

      else
        @post_path = defined?(self.class::POST_PATH) ? self.class::POST_PATH : self.class::LIST_PATH
      end
    end

    ############################################
    def create_in_jamf
      unless defined?(self.class::POST_OBJECT)
        raise Jamf::MissingDataError,
              "Class #{self.class} has not defined a POST_OBJECT"
      end

      validate_for_create

      post_object = self.class::POST_OBJECT.new(to_jamf)

      result = @cnx.jp_post post_path, post_object.to_jamf

      @id = result[:id]

      # reset the API  paths now that we exist
      set_api_paths

      # return the id
      @id
    end

    # make sure that required values are not nil
    ############################################
    def validate_for_create
      self.class::POST_OBJECT::OAPI_PROPERTIES.each do |attr_name, attr_def|
        next unless attr_def[:required]
        next unless send(attr_name).nil?

        raise Jamf::MissingDataError, "Attribute '#{attr_name}' cannot be nil, must be a #{attr_def[:class]}"
      end
    end

  end # class CollectionResource

end # module JAMF
