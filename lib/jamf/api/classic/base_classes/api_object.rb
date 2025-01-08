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

###
module Jamf

  # Classes
  #####################################

  # This class is the parent to all JSS API objects. It provides standard
  # methods and constants that apply to all API resouces.
  #
  # See the README.md file for general info about using subclasses of
  # Jamf::APIObject
  #
  # == Subclassing
  #
  # === Initilize / Constructor
  #
  # All subclasses must call `super` in their initialize method, which will
  # call the method defined here in APIObject. Not only does this retrieve the
  # data from the API, it parses the raw JSON data into a Hash, & stores it in
  # @init_data.
  #
  # In general, subclasses should do any class-specific argument checking before
  # calling super, and then afterwards use the contents of @init_data to
  # populate any class-specific attributes. Populating @id, @name, @rest_rsrc,
  # and @in_jss are handled here.
  #
  # This class also handles parsing @init_data for any mixed-in modules, e.g.
  # Scopable, Categorizable or Extendable. See those modules for any
  # requirements they have when including them.
  #
  # === Object Creation
  #
  # If a subclass should be able to be created in the JSS be sure to include
  # {Jamf::Creatable}
  #
  # The constructor should verify any extra required data in the args
  #
  # See {Jamf::Creatable} for more details.
  #
  # === Object Modification
  #
  # If a subclass should be modifiable in the JSS, include {Jamf::Updatable},
  # q.v. for details.
  #
  # === Object Deletion
  #
  # All subclasses can be deleted in the JSS.
  #
  # === Required Constants
  #
  # Subclasses *must* provide certain constants in order to correctly interpret
  # API data and communicate with the API:
  #
  # ==== RSRC_BASE [String]
  #
  # The base for REST resources of this class
  #
  # e.g. 'computergroups' in
  #   https://casper.mycompany.com:8443/JSSResource/computergroups/id/12
  #
  # ==== RSRC_LIST_KEY [Symbol]
  #
  # When GETting the RSRC_BASE for a subclass, an Array of Hashes is returned
  # with one Hash of basic info for each object of that type in the JSS. All
  # objects have their JSS id and name in that Hash, some have other data as
  # well. This Array is used for a variety of purposes when using ruby-jss,
  # since it gives you basic info about all objects, without having to fetch
  # each one individually.
  #
  # Here's the top of the output from the 'computergroups' RSRC_BASE:
  #
  #   {:computer_groups=>
  #     [{:id=>1020, :name=>"config-no-turnstile", :is_smart=>true},
  #      {:id=>1357, :name=>"10.8 Laptops", :is_smart=>true},
  #      {:id=>1094, :name=>"wifi_cert-expired", :is_smart=>true},
  #      {:id=>1144, :name=>"mytestgroup", :is_smart=>false},
  #      ...
  #
  # Notice that the Array we want is embedded in a one-item Hash, and the
  # key in that Hash for the desired Array is the Symbol :computer_groups.
  #
  # That symbol is the value needed in the RSRC_LIST_KEY constant.
  #
  # The '.all_ids', '.all_names' and other '.all_*' class methods use the
  # list-resource Array to extract other Arrays of the desired values - which
  # can be used to check for existance without retrieving an entire object,
  # among other uses.
  #
  # ==== RSRC_OBJECT_KEY [Symbol]
  #
  # The one-item Hash key used for individual JSON object output.  It's also
  # used in various error messages
  #
  # As with the list-resource output mentioned above, when GETting a specific
  # object resource, there's an extra layer of encapsulation in a one-item Hash.
  # Here's the top of the JSON for a single computer group fetched
  # from '...computergroups/id/1043'
  #
  #   {:computer_group=>
  #     {:id=>1043,
  #      :name=>"tmp-no-d3",
  #      :is_smart=>false,
  #      :site=>{:id=>-1, :name=>"None"},
  #      :criteria=>[],
  #      :computers=>[
  #      ...
  #
  # The data for the group itself is the inner Hash.
  #
  # The RSRC_OBJECT_KEY in this case is set to :computer_group - the key
  # in the top-level, one-item Hash that we need to get the real Hash about the
  # object.
  #
  # === Optional Constants
  #
  # === OTHER_LOOKUP_KEYS
  #
  # Fetching individual objects from the API is usuallly done via the object's
  # unique JSS id, via a resrouce URL like so:
  #
  #   ...JSSResource/<RSRC_BASE>/id/<idnumber>
  #
  # Most objects can also be looked-up by name, because the API also has
  # and endpoint ..JSSResource/<RSRC_BASE>/name/<name>
  # (See {NON_UNIQUE_NAMES} below)
  #
  # Some objects, like Computers and MobileDevices, have other values that
  # serve as unique identifiers and can also be used as 'lookup keys' for
  # fetching individual objects.  When this is the case, those values always
  # appear in the objects list-resource data (See {RSRC_LIST_KEY} above).
  #
  # For example, here's a summary-hash for a single MobileDevice from the
  # list-resource  '...JSSResource/mobiledevices', which you might get in the
  # Array returned by Jamf::MobileDevice.all:
  #
  #   {
  #     :id=>3964,
  #     :name=>"Bear",
  #     :device_name=>"Bear",
  #     :udid=>"XXX",
  #     :serial_number=>"YYY2244MM60",
  #     :phone_number=>"510-555-1212",
  #     :wifi_mac_address=>"00:00:00:00:00:00",
  #     :managed=>true,
  #     :supervised=>false,
  #     :model=>"iPad Pro (9.7-inch Cellular)",
  #     :model_identifier=>"iPad6,4",
  #     :modelDisplay=>"iPad Pro (9.7-inch Cellular)",
  #     :model_display=>"iPad Pro (9.7-inch Cellular)",
  #     :username=>"fred"
  #   }
  #
  # For MobileDevices, serial_number, udid, and wifi_mac_address are also
  # all unique identifiers for an individual device, and can be used to
  # fetch them.
  #
  # To specify other identifiers for an APIObject subclass, create the constant
  # OTHER_LOOKUP_KEYS containing a Hash of Hashes, like so:
  #
  #   OTHER_LOOKUP_KEYS = {
  #      serial_number: {
  #        aliases: [:serialnumber, :sn],
  #        fetch_rsrc_key: :serialnumber
  #      },
  #      udid: {
  #        fetch_rsrc_key: :udid
  #      },
  #      wifi_mac_address: {
  #        aliases: [:macaddress, :macaddr],
  #        fetch_rsrc_key: :macaddress
  #      }
  #   }.freeze
  #
  # The keys in OTHER_LOOKUP_KEYS are the keys in a summary-hash data from .all
  # that hold a unique identifier. Each value is a Hash with one or two keys:
  #
  #   - aliases: [Array<Symbol>]
  #      Aliases for that identifier, i.e. abbreviations or spelling variants.
  #      These aliases can be used in fetching, and they also have
  #      matching `.all_<aliase>s` methods.
  #
  #      If no aliases are needed, don't specify anything, as with the udid:
  #      in the example above
  #
  #   - fetch_rsrc_key: [Symbol]
  #     Often a unique identifier can be used to build a URL for fetching (or
  #     updating or deleteing) an object with that value, rather than with id.
  #     For example, while the MobileDevice in the example data above would
  #     normally be fetched at the resource 'JSSResource/mobiledevices/id/3964'
  #     it can also be fetched at
  #    'JSSResource/mobiledevices/serialnumber/YYY2244MM60'.
  #     Since the URL is built using 'serialnumber', the symbol :serialnumber
  #     is used as the fetch_rsrc_key.
  #
  #     Setting a fetch_rsrc_key: for one of the OTHER_LOOKUP_KEYS tells ruby-jss
  #     that such a URL is available, and fetching by that lookup key will be
  #     faster when using that URL.
  #
  #     If a fetch_rsrc_key is not set, fetching will be slower, since the fetch
  #     method must first refresh the list of all available objects to find the
  #     id to use for building the resource URL.
  #     This is also true when fetching without specifying which lookup key to
  #     use, e.g. `.fetch 'foo'` vs. `.fetch sn: 'foo'`
  #
  # The OTHER_LOOKUP_KEYS, if defined, are merged with the DEFAULT_LOOKUP_KEYS
  # defined below via the {APIObject.lookup_keys} class method, They are used for:
  #
  # - creating list-methods:
  #   For each lookup key, a class method  `.all_<key>s` is created
  #   automatically, e.g. `.all_serial_numbers`. The aliases are used to
  #   make alises of those methods, e.g. `.all_sns`
  #
  # - finding valid ids:
  #   The {APIObject.valid_id} class method looks at the known lookup keys to
  #   find an object's id.
  #
  # - fetching:
  #   When an indentifier is given to `.fetch`, the fetch_rsrc_key is used to
  #   build the resource URL for fetching the object. If there is no
  #   fetch_rsrc_key, the lookup_keys and aliases are used to find the matching
  #   id, which is used to build the URL.
  #
  #   When no identifier is specified, .fetch uses .valid_id, described above.
  #
  # ==== NON_UNIQUE_NAMES
  #
  # Some JSS objects, like Computers and MobileDevices, do not treat names
  # as unique in the JSS, but they can still be used for fetching objects.
  # The API itself will return data for a non-unique name lookup, but there's
  # no way to guarantee which object you get back.
  #
  # In those subclasses, set NON_UNIQUE_NAMES to any value, and a
  # Jamf::AmbiguousError exception will be raised when trying to fetch by name
  # and the name isn't unique.
  #
  # Because of the extra processing, the check for this state will only happen
  # when NON_UNIQUE_NAMES is set. If not set at all, the check  doesn't happen
  # and if multiple objects have the same name, which one is returned is
  # undefined.
  #
  # When that's the case, fetching explicitly by name, or when fetching with a
  # plain search term that matches a non-unique name, will raise a
  # Jamf::AmbiguousError exception,when the name isn't unique. If that happens,
  # you'll have to use some other identifier to fetch the desired object.
  #
  # Note: Fetching, finding valid id, and name collisions are case-insensitive.
  #
  class APIObject

    include Comparable

    # COMPARABLE
    # APIobjects are == if all of their lookup key values are the same
    #
    def <=>(other)
      idents_combined <=> other.idents_combined
    end

    def idents_combined
      my_keys = self.class.lookup_keys.values.uniq
      my_keys.map { |k| send(k).to_s }.sort.join
    end

    # Meta Programming
    ####################################################

    # Loop through the defined lookup keys and make
    # .all_<key>s methods for each one, with alises as needed.
    #
    # This is called automatically when subclasses are loaded by zeitwerk
    #
    def self.define_identifier_list_methods
      Jamf.load_msg "Defining list-methods for APIObject subclass #{self}"

      lookup_keys.each do |als, key|
        meth_name = key.to_s.end_with?('s') ? "all_#{key}es" : "all_#{key}s"
        if als == key
          # the all_ method - skip if defined in the class
          next if singleton_methods.include? meth_name.to_sym

          define_singleton_method meth_name do |refresh = false, cached_list: nil, api: nil, cnx: Jamf.cnx|
            cnx = api if api
            list = cached_list || all(refresh, cnx: cnx)
            list.map { |i| i[key] }
          end
          Jamf.load_msg "Defined method #{self}##{meth_name}"

        else
          # an alias - skip if defined in the class
          als_name = als.to_s.end_with?('s') ? "all_#{als}es" : "all_#{als}s"

          next if singleton_methods.include? als_name.to_sym

          define_singleton_method als_name do |refresh = false, api: nil, cnx: Jamf.cnx|
            cnx = api if api
            send meth_name, refresh, cnx: cnx
          end
          Jamf.load_msg "Defined alias '#{als_name}' of #{self}##{meth_name}"

        end # if
      end # lookup_keys.each

      true
    end # self.define_identifier_list_methods

    # Constants
    ####################################

    # which API do APIObjects come from?
    # The JPAPI equivalent is in Jamf::JPAPIResource
    API_SOURCE = :classic

    # '.new' can only be called from these methods:
    OK_INSTANTIATORS = ['make', 'create', 'fetch', 'block in fetch'].freeze

    # See the discussion of 'Lookup Keys' in the comments/docs
    # for {Jamf::APIObject}
    #
    DEFAULT_LOOKUP_KEYS = {
      id: { fetch_rsrc_key: :id },
      name: { fetch_rsrc_key: :name }
    }.freeze

    # This table holds the object history for JSS objects.
    # Object history is not available via the API,
    # only MySQL.
    OBJECT_HISTORY_TABLE = 'object_history'.freeze

    # Class Methods
    #####################################

    # What are all the lookup keys available for this class, with
    # all their aliases (or optionally not) or with their fetch_rsrc_keys
    #
    # This method combines the DEFAULT_LOOOKUP_KEYS defined above, with the
    # optional OTHER_LOOKUP_KEYS from a subclass (See 'Lookup Keys' in the
    # class comments/docs above)
    #
    # The hash returned flattens and inverts the two source hashes, so that
    # all possible lookup keys (the keys and their aliases) are hash keys
    # and the non-aliased lookup key is the value.
    #
    # For example, when
    #
    #   OTHER_LOOKUP_KEYS = {
    #      serial_number: { aliases: [:serialnumber, :sn], fetch_rsrc_key: :serialnumber },
    #      udid: { fetch_rsrc_key: :udid },
    #      wifi_mac_address: { aliases: [:macaddress, :macaddr], fetch_rsrc_key: :macaddress }
    #   }
    #
    # It is combined with DEFAULT_LOOKUP_KEYS to produce:
    #
    #   {
    #     id: :id,
    #     name: :name,
    #     serial_number: :serial_number,
    #     serialnumber: :serial_number,
    #     sn: :serial_number,
    #     udid: :udid,
    #     wifi_mac_address: :wifi_mac_address,
    #     macaddress: :wifi_mac_address,
    #     macaddr: :wifi_mac_address
    #   }
    #
    # If the optional parameter no_aliases: is truthy, only the real keynames
    # are returned in an array, so the above would become
    #
    #   [:id, :name, :serial_number, :udid, :wifi_mac_address]
    #
    # @param no_aliases [Boolean] Only return the real keys, no aliases.
    #
    # @return [Hash {Symbol: Symbol}] when no_aliases is falsey, the lookup keys
    #   and aliases for this subclass.
    #
    # @return [Array<Symbol>] when no_aliases is truthy, the lookup keys for this
    #   subclass
    #
    def self.lookup_keys(no_aliases: false, fetch_rsrc_keys: false)
      parse_lookup_keys unless @lookup_keys
      no_aliases ? @lookup_keys.values.uniq : @lookup_keys
    end

    # Given a lookup key, or an alias of one, return the matching fetch_rsrc_key
    # for building a fetch/GET resource URL, or nil if no fetch_rsrc_key is defined.
    #
    # See {OTHER_LOOKUP_KEYS} in the APIObject class comments/docs above for details.
    #
    # @param lookup_key [Symbol] A lookup key, or an aliases of one, for this
    #   subclass.
    #
    # @return [Symbol, nil] the fetch_rsrc_key for that lookup key.
    #
    def self.fetch_rsrc_key(lookup_key)
      parse_lookup_keys unless @fetch_rsrc_keys
      @fetch_rsrc_keys[lookup_key]
    end

    # Used by .lookup_keys
    #
    def self.parse_lookup_keys
      @lookup_keys = {}
      @fetch_rsrc_keys = {}

      hsh = DEFAULT_LOOKUP_KEYS.dup
      hsh.merge!(self::OTHER_LOOKUP_KEYS) if defined? self::OTHER_LOOKUP_KEYS

      hsh.each do |key, info|
        @lookup_keys[key] = key
        @fetch_rsrc_keys[key] = info[:fetch_rsrc_key]
        next unless info[:aliases]

        info[:aliases].each do |a|
          @lookup_keys[a] = key
          @fetch_rsrc_keys[a] = info[:fetch_rsrc_key]
        end
      end # self::OTHER_LOOKUP_KEYS.each
    end
    private_class_method :parse_lookup_keys

    # get the real lookup key frm a given alias
    #
    # @param key[Symbol] the key or an aliase of the key
    #
    # @return [Symbol] the real key for the given key
    #
    def self.real_lookup_key(key)
      real_key = lookup_keys[key]
      raise ArgumentError, "Unknown lookup key '#{key}' for #{self}" unless real_key

      real_key
    end

    # Return an Array of Hashes for all objects of this subclass in the JSS.
    #
    # This method is only valid in subclasses of Jamf::APIObject, and is
    # the parsed JSON output of an API query for the resource defined in the
    # subclass's RSRC_BASE
    #
    # e.g. for Jamf::Computer, with the RSRC_BASE of :computers,
    # This method retuens the output of the 'JSSResource/computers' resource,
    # which is a list of all computers in the JSS.
    #
    # Each item in the Array is a Hash with at least two keys, :id and :name.
    # The class methods .all_ids and .all_names provide easier access to those
    # dataas mapped Arrays.
    #
    # Some API classes provide other keys in each Hash, e.g. :udid (for
    # computers and mobile devices) or :is_smart (for groups).
    #
    # For those keys that are listed in a subclass's lookup_keys method,
    # there are matching methods `.all_(key)s` which return an array
    # just of those values, from the values of this hash. For example,
    # `.all_udids` will use the .all array to return an array of just udids,
    # if the subclass defines :udid in its OTHER_LOOKUP_KEYS (See 'Lookup Keys'
    # in the class comments/docs above)
    #
    # Subclasses should provide appropriate .all_xxx class methods for accessing
    # any other other values as Arrays, e.g. Jamf::Computer.all_managed
    #
    # -- Caching
    #
    # The results of the first call to .all for each subclass is cached in the
    # .c_object_list_cache of the given {Jamf::Connection} and that cache is
    # used for all future calls, so as to not requery the server every time.
    #
    # To force requerying to get updated data, provided a truthy argument.
    # I usually use :refresh, so that it's obvious what I'm doing, but true, 1,
    # or anything besides false or nil will work.
    #
    # The various methods that use the output of this method also take the
    # refresh parameter which will be passed here as needed.
    #
    # -- Alternate API connections
    #
    # To query an APIConnection other than the currently active one,
    # provide one via the cnx: named parameter.
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<Hash{:name=>String, :id=> Integer}>]
    #
    def self.all(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      validate_not_metaclass(self)

      cache = cnx.c_object_list_cache
      cache_key = self::RSRC_LIST_KEY
      cnx.flushcache(cache_key) if refresh
      return cache[cache_key] if cache[cache_key]

      cache[cache_key] = cnx.c_get(self::RSRC_BASE)[cache_key]
    end

    # @return [Hash {String => Integer}] name => number of occurances
    #
    def self.duplicate_names(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      return {} unless defined? self::NON_UNIQUE_NAMES

      dups = {}
      all(refresh, cnx: cnx).each do |obj|
        if dups[obj[:name]]
          dups[obj[:name]] += 1
        else
          dups[obj[:name]] = 1
        end # if
      end # all(refresh, cnx: cnx).each
      dups.delete_if { |_k, v| v == 1 }
      dups
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
    # @param refresh [Boolean] Re-read the 'all' data from the API? otherwise
    #   use the cached data if available.
    #
    # @param cnx (see .all)
    #
    # @return [Hash {Symbol: Object}] A Hash of identifier mapped to attribute
    #
    ######################################
    def self.map_all(ident, to:, cnx: Jamf.cnx, refresh: false, cached_list: nil)
      orig_ident = ident
      ident = lookup_keys[ident]
      raise Jamf::InvalidDataError, "No identifier :#{orig_ident} for class #{self}" unless ident

      list = cached_list || all(refresh, cnx: cnx)
      mapped = list.map do |i|
        [
          i[ident],
          i[to]
        ]
      end # do i

      mapped.to_h
    end

    # Return a hash of all objects of this subclass
    # in the JSS where the key is the id, and the value
    # is some other key in the data items returned by the Jamf::APIObject.all.
    #
    # If the other key doesn't exist in the API summary data from .all
    # (eg :udid for Jamf::Department) the values will be nil.
    #
    # Use this method to map ID numbers to other identifiers returned
    # by the API list resources. Invert its result to map the other
    # identfier to ids.
    #
    # @example
    #   Jamf::Computer.map_all_ids_to(:serial_number)
    #
    #   # Returns, eg {2 => "C02YD3U8JHD3", 5 => "VMMz7xgg8lYZ"}
    #
    #   Jamf::Computer.map_all_ids_to(:serial_number).invert
    #
    #   # Returns, eg {"C02YD3U8JHD3" => 2, "VMMz7xgg8lYZ" => 5}
    #
    # These hashes are cached separately from the .all data, and when
    # the refresh parameter is truthy, both will be refreshed.
    #
    # WARNING: Some values in the output of .all are not guaranteed to be unique
    # in Jamf Pro. This is fine in the direct output of this method, each id
    # will be the key for some value and many ids might have the same value.
    # However if you invert that hash, the values become keys, and the ids
    # become the values, and there can be only one id per each new key. Which
    # id becomes associated with a value is undefined, and data about the others
    # is lost. This is especially important if you `.map_all_ids_to :name`,
    # since, for some objects, names are not unique.
    #
    # @param other_key[Symbol] the other data key with which to associate each id
    #
    # @param refresh[Boolean] should the data re-queried from the API?
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash{Integer => Oject}] the associated ids and data
    #
    def self.map_all_ids_to(other_key, refresh = false, cached_list: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      map_all :id, to: other_key, refresh: refresh, cnx: cnx, cached_list: cached_list

      # # we will accept any key, it'll just return nil if not in the
      # # .all hashes. However if we're given an alias of a lookup key
      # # we need to convert it to its real name.
      # other_key = lookup_keys[other_key] if lookup_keys[other_key]
      #
      # cache_key = "#{self::RSRC_LIST_KEY}_map_#{other_key}".to_sym
      # cache = cnx.c_object_list_cache
      # cache[cache_key] = nil if refresh
      # return cache[cache_key] if cache[cache_key]
      #
      # map = {}
      # all(refresh, cnx: cnx).each { |i| map[i[:id]] = i[other_key] }
      # cache[cache_key] = map
    end

    # Return an Array of Jamf::APIObject subclass instances
    # e.g when called on Jamf::Package, return a hash of Jamf::Package instancesa
    # for every package in the JSS.
    #
    # WARNING: This may be slow as it has to look up each object individually!
    # use it wisely.
    #
    # @param refresh[Boolean] should the data  re-queried from the API?
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<APIObject>] the objects requested
    #
    def self.all_objects(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      objects_cache_key ||= "#{self::RSRC_LIST_KEY}_objects".to_sym
      api_cache = cnx.c_object_list_cache
      api_cache[objects_cache_key] = nil if refresh

      return api_cache[objects_cache_key] if api_cache[objects_cache_key]

      all_result = all(refresh, cnx: cnx)
      api_cache[objects_cache_key] = all_result.map do |o|
        fetch id: o[:id], cnx: cnx, refresh: false
      end
    end

    # Return the id of the object of this subclass with the given identifier.
    #
    # Return nil if no object has an identifier that matches.
    #
    # For all objects the 'name' is an identifier. Some objects have more, e.g.
    # udid, mac_address & serial_number. Matches are case-insensitive.
    #
    # NOTE: while name is an identifier, for Computers and MobileDevices, it
    # need not be unique in Jamf. If name is matched, which one gets returned
    # is undefined. In short - dont' use names here unless you know they are
    # unique.
    #
    # NOTE: Integers passed in as strings, e.g. '12345' will be converted to
    # integers and return the matching integer id if it exists.
    #
    # This means that if you have names that might match '12345' and you use
    #    valid_id '12345'
    # you will get back the id 12345, if such an id exists, even if it is not
    # the object with the name '12345'
    #
    # To explicitly look for '12345' as a name, use:
    #      valid_id name: '12345'
    #   See the ident_and_val param below.
    #
    # @param identfier [String,Integer] An identifier for an object, a value for
    #   one of the available lookup_keys. Omit this and use 'identifier: value'
    #   if you want to limit the search to a specific indentifier key, e.g.
    #      name: 'somename'
    #   or
    #      id: 76538
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param ident_and_val [Hash] Do not pass in Hash.
    #   This Hash internally holds the arbitrary identifier key
    #   and desired value when you call ".valid_id ident: 'value'", e.g.
    #   ".valid_id name: 'somename'" or ".valid_id udid: some_udid"
    #   Using explicit identifier keys like this will speed things up, since
    #   the method doesn't have to search through all available identifiers
    #   for the desired value.
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Integer, nil] the id of the matching object, or nil if it doesn't exist
    #
    def self.valid_id(identifier = nil, refresh = false, api: nil, cnx: Jamf.cnx, **ident_and_val)
      cnx = api if api

      # refresh the cache if needed
      all(refresh, cnx: cnx) if refresh

      # Were we given an explict identifier key, like name: or id:?
      # If so, just look for that.
      unless ident_and_val.empty?
        # only the first k/v pair of the ident_and_val hash is used
        key = ident_and_val.keys.first
        val = ident_and_val[key]

        # if we are explicitly looking for an id, ensure we use an integer
        # even if we were given an integer in a string.
        if key == :id
          val = val.to_i if val.is_a?(String) && val.j_integer?
          return all_ids(cnx: cnx).include?(val) ? val : nil
        end

        # map the identifiers to ids, and return the id if there's
        # a case-insensitive matching identifire
        map_all(key, to: :id).each do |ident_val, id|
          return id if ident_val.to_s.casecmp? val.to_s
        end
        nil
      end

      # If we are here, we need to seach all available identifier keys
      # Start by looking for it as an id.

      # it its a valid integer id, return it
      return identifier if all_ids(cnx: cnx).include? identifier

      # if its a valid integer-in-a-string id, return it
      if identifier.is_a?(String) && identifier.j_integer?
        int_id = identifier.to_i
        return int_id if all_ids(cnx: cnx).include? int_id
      end

      # Now go through all the other identifier keys
      keys_to_check = lookup_keys(no_aliases: true)
      keys_to_check.delete :id # we've already checked :id

      # loop thru looking for a match
      keys_to_check.each do |key|
        mapped_ids = map_all_ids_to key, cnx: cnx
        matches = mapped_ids.select { |_id, ident| ident.casecmp? identifier }
        # If exactly one match, return the id
        return matches.keys.first if matches.size == 1
      end

      nil
    end

    # Return the id of the object of this subclass with the given
    # lookup key == a given identifier.
    #
    # Return nil if no object has that value in that key
    #
    # @example
    #   # get the id for the computer with serialnum 'xyxyxyxy'
    #   Jamf::Computer.id_for_identifier :serial_number, 'xyxyxyxy'
    #
    #   # => the Integer id, or nil if no such serial number
    #
    # Raises a Jamf::Ambiguous error if there's more than one matching value
    # for any key, which might be true of names for Computers and Devices
    #
    # This is similar to .valid_id, except only one key is searched
    #
    # @param key [Symbol] they key in which to look for the identifier. Must be
    #   a valid lookup key for this subclass.
    #
    # @param identfier [String,Integer] An identifier for an object, a value for
    #   one of the available lookup_keys
    #
    # @param refresh [Boolean] Should the cached summary data be re-read from
    #   the server first?
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Integer, nil] the id of the matching object, or nil if it
    #   doesn't exist
    #
    def self.id_for_identifier(key, val, refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      # refresh if needed
      all(refresh, cnx: cnx) if refresh

      # get the real key if an alias was used
      key = real_lookup_key key

      # do id's expicitly, they are integers
      return all_ids(cnx: cnx).include?(val) ? val : nil if key == :id

      mapped_ids = map_all_ids_to key, cnx: cnx
      matches = mapped_ids.select { |_id, map_val| val.casecmp? map_val }
      raise Jamf::AmbiguousError, "Key #{key}: value '#{val}' is not unique for #{self}" if matches.size > 1

      return nil if matches.size.zero?

      matches.keys.first
    end

    # Return true or false if an object of this subclass
    # with the given Identifier exists on the server
    #
    # @param identfier [String,Integer] An identifier for an object, a value for
    # one of the available lookup_keys
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Boolean] does an object with the given identifier exist?
    #
    def self.exist?(identifier, refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      !valid_id(identifier, refresh, cnx: cnx).nil?
    end

    # Convert an Array of Hashes of API object data to a
    # REXML element.
    #
    # Given an Array of Hashes of items in the subclass
    # where each Hash has at least an :id  or a :name key,
    # (as what comes from the .all class method)
    # return a REXML <classes> element
    # with one <class> element per Hash member.
    #
    # @example
    #   # for class Jamf::Computer
    #   some_comps = [{:id=>2, :name=>"kimchi"},{:id=>5, :name=>"mantis"}]
    #   xml_names = Jamf::Computer.xml_list some_comps
    #   puts xml_names  # output manually formatted for clarity, xml.to_s has no newlines between elements
    #
    #   <computers>
    #     <computer>
    #       <name>kimchi</name>
    #     </computer>
    #     <computer>
    #       <name>mantis</name>
    #     </computer>
    #   </computers>
    #
    #   xml_ids = Jamf::Computer.xml_list some_comps, :id
    #   puts xml_names  # output manually formatted for clarity, xml.to_s has no newlines between elements
    #
    #   <computers>
    #     <computer>
    #       <id>2</id>
    #     </computer>
    #     <computer>
    #       <id>5</id>
    #     </computer>
    #   </computers>
    #
    # @param array[Array<Hash{:name=>String, :id =>Integer, Symbol=>#to_s}>] the Array of subclass data to convert
    #
    # @param content[Symbol] the Hash key to use as the inner element for each member of the Array
    #
    # @return [REXML::Element] the XML element representing the data
    #
    def self.xml_list(array, content = :name)
      JSS.item_list_to_rexml_list self::RSRC_LIST_KEY, self::RSRC_OBJECT_KEY, array, content
    end

    # Some API objects contain references to other API objects. Usually those
    # references are a Hash containing the :id and :name of the target. Sometimes,
    # however the reference is just the name of the target.
    #
    # A Script has a property :category, which comes from the API as
    # a String, the name of the category for that script. e.g. "GoodStuff"
    #
    # A Policy also has a property :category, but it comes from the API as a Hash
    # with both the name and id, e.g.  !{:id => 8, :name => "GoodStuff"}
    #
    # When that reference is to a single thing (like the category to which something belongs)
    # APIObject subclasses usually store only the name, and use the name when
    # returning data to the API.
    #
    # When an object references a list of related objects
    # (like the computers assigned to a user) that list will be and Array of Hashes
    # as above, with both the :id and :name
    #
    # This method is just a handy way to extract the name regardless of how it comes
    # from the API. Most APIObject subclasses use it in their #initialize method
    #
    # @param a_thing[String,Array] the api data from which we're extracting the name
    #
    # @return [String] the name extracted from a_thing
    #
    def self.get_name(a_thing)
      case a_thing
      when String
        a_thing
      when Hash
        a_thing[:name]
      when nil
        nil
      end
    end

    # Retrieve an object from the API and return an instance of this APIObject
    # subclass.
    #
    # @example
    #   # computer where 'xyxyxyxy'  is in any of the lookup key fields
    #   Jamf::Computer.fetch 'xyxyxyxy'
    #
    #   # computer where 'xyxyxyxy' is the serial number
    #   Jamf::Computer.fetch serial_number: 'xyxyxyxy'
    #
    # Fetching is faster when specifying a lookup key, and that key has a
    # fetch_rsrc_key defined in its OTHER_LOOKUP_KEYS constant, as in the second
    # example above.
    #
    # When no lookup key is given, as in the first example above, or when that
    # key doesn't have a defined fetch_rsrc_key, ruby-jss uses the currently cached
    # list resource data to find the id matching the value given, and that id
    # is used to fetch the object. (see 'List Resources and Lookup Keys' in the
    # APIObject comments/docs above)
    #
    # Since that cached list data may be out of date, you can provide the param
    # `refrsh: true`, to reload the list from the server. This will cause the
    # fetch to be slower still, so use with caution.
    #
    # For creating new objects in the JSS, use {APIObject.make}
    #
    # @param searchterm[String, Integer] An single value to
    #   search for in all the lookup keys for this clsss. This is slower
    #   than specifying a lookup key
    #
    # @param args[Hash] the remaining options for fetching an object.
    #   If no searchterm is provided, one of the args must be a valid
    #   lookup key and value to find in that key, e.g. `serial_number: '1234567'`
    #
    # @option args cnx[Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @option args refresh[Boolean] should the summary list of all objects be
    #   reloaded from the API before being used to look for this object.
    #
    # @return [APIObject] The ruby-instance of a JSS object
    #
    def self.fetch(searchterm = nil, **args)
      validate_not_metaclass(self)

      # which connection?
      cnx = args.delete :cnx
      cnx ||= args.delete :api # backward compatibility, deprecated
      cnx ||= Jamf.cnx

      # refresh the .all list if needed
      if args.delete(:refresh) || searchterm == :random
        all(:refresh, cnx: cnx)
        just_refreshed = true
      else
        just_refreshed = false
      end

      # a random object?
      if searchterm == :random || args[:random]
        rnd_thing = all(cnx: cnx).sample
        raise Jamf::NoSuchItemError, "No #{self::RSRC_LIST_KEY} found" unless rnd_thing

        return new id: rnd_thing[:id], cnx: cnx
      end

      # get the lookup key and value, if given
      fetch_key, fetch_val = args.to_a.first
      fetch_rsrc_key = fetch_rsrc_key(fetch_key)

      # names should raise an error if more than one exists,
      # so we always have to do id_for_identifier, which will do so.
      if fetch_rsrc_key == :name
        id = id_for_identifier fetch_key, fetch_val, !just_refreshed, cnx: cnx
        fetch_rsrc = id ? "#{self::RSRC_BASE}/name/#{CGI.escape fetch_val.to_s}" : nil

      # if the fetch rsrc key exists, it can be used directly in an endpoint path
      # so, use it directly, rather than looking up the id first.
      elsif fetch_rsrc_key
        fetch_rsrc = "#{self::RSRC_BASE}/#{fetch_rsrc_key}/#{CGI.escape fetch_val.to_s}"

      # it has an OTHER_LOOKUP_KEY but that key doesn't have a fetch_rsrc
      # so we look in the .map_all_ids_to_* hash for it.
      elsif fetch_key
        id = id_for_identifier fetch_key, fetch_val, !just_refreshed, cnx: cnx
        fetch_rsrc = id ? "#{self::RSRC_BASE}/id/#{id}" : nil

      # no fetch key was given in the args, so try a search term
      elsif searchterm
        id = valid_id searchterm, cnx: cnx
        fetch_rsrc = id ? "#{self::RSRC_BASE}/id/#{id}" : nil

      else
        raise ArgumentError, 'Missing searchterm or fetch key'
      end

      new fetch_rsrc: fetch_rsrc, cnx: cnx
    end # fetch

    # Fetch the mostly- or fully-raw JSON or XML data for an object of this
    # subclass.
    #
    # By default, returns the JSON data parsed into a Hash.
    #
    # When format: is anything but :json, returns the XML data parsed into
    # a REXML::Document
    #
    # When as_string: is truthy, returns an unparsed JSON String (or XML String
    # if format: is not :json) as it comes directly from the API.
    #
    # When fetching raw JSON, the returned Hash will have its keys symbolized.
    #
    # This can be substantialy faster than instantiating, especially when you don't need
    # all the ruby goodness of a full instance, but just want a few values for
    # an object that aren't available in the `all` data
    #
    # This is really just a wrapper around {APIConnection.c_get} that
    # automatically fills in the RSRC::BASE value for you.
    #
    # @param id [Integer] the id of the object to fetch
    #
    # @param format[Symbol] :json or :xml, defaults to :json
    #
    # @param as_string[Boolean] return the raw JSON or XML string as it comes
    #   from the API, do not parse into a Hash or REXML::Document
    #
    # @param cnx [Jamf::Connection] the connection thru which to fetch this
    #   object. Defaults to the deault API connection in Jamf.cnx
    #
    # @return [Hash, REXML::Document, String] the raw data for the object
    #
    def self.get_raw(id, format: :json, as_string: false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      validate_not_metaclass(self)
      rsrc = "#{self::RSRC_BASE}/id/#{id}"
      data = cnx.c_get rsrc, format, raw_json: as_string
      return data if format == :json || as_string

      REXML::Document.new(**data)
    end

    # PUT some raw XML to the API for a given id in this subclass.
    #
    # WARNING: You must create or acquire the XML to be sent, and no validation
    # will be performed on it. It must be a String, or something that returns
    # an XML string with #to_s, such as a REXML::Document, or
    # a REXML::Element.
    #
    # In some cases, where you're making simple changes to simple XML,
    # this can be faster than fetching a full instance and the re-saving it.
    #
    # This is really just a wrapper around {APIConnection.c_put} that
    # automatically fills in the RSRC::BASE value for you.
    #
    # @param id [Integer] the id of the object to PUT
    #
    # @param xml [String, #to_s] The XML to send
    #
    # @param cnx [Jamf::Connection] the connection thru which to fetch this
    #   object. Defaults to the deault API connection in Jamf.cnx
    #
    # @return [REXML::Document] the XML response from the API
    #
    def self.put_raw(id, xml, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      validate_not_metaclass(self)
      rsrc = "#{self::RSRC_BASE}/id/#{id}"
      REXML::Document.new(cnx.c_put(rsrc, xml.to_s))
    end

    # POST some raw XML to the API for a given id in this subclass.
    #
    # WARNING: You must create or acquire the XML to be sent, and no validation
    # will be performed on it. It must be a String, or something that returns
    # an XML string with #to_s, such as a REXML::Document, or
    # a REXML::Element.
    #
    # This probably isn't as much of a speed gain as get_raw or put_raw, as
    # opposed to instantiating a ruby object, but might still be useful.
    #
    # This is really just a wrapper around {APIConnection.c_post} that
    # automatically fills in the RSRC::BASE value for you.
    #
    # @param xml [String, #to_s] The XML to send
    #
    # @param cnx [Jamf::Connection] the connection thru which to fetch this
    #   object. Defaults to the deault API connection in Jamf.cnx
    #
    # @return [REXML::Document] the XML response from the API
    #
    def self.post_raw(xml, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      validate_not_metaclass(self)
      rsrc = "#{self::RSRC_BASE}/id/-1"
      REXML::Document.new(cnx.c_post(rsrc, xml.to_s))
    end

    # Make a ruby instance of a not-yet-existing APIObject.
    #
    # This is how to create new objects in the JSS. A name: must be provided,
    # and different subclasses can take other named parameters.
    #
    # For retrieving existing objects in the JSS, use {APIObject.fetch}
    #
    # After calling this you'll have a local instance, which will be created
    # in the JSS when you call #create on it. see {APIObject#create}
    #
    # @param name[String] The name of this object, generally must be uniqie
    #
    # @param cnx [Jamf::Connection] the connection thru which to make this
    #   object. Defaults to the deault API connection in Jamf.cnx
    #
    # @param args [Hash] The data for creating an object, such as name:
    #  See {APIObject#initialize}
    #
    # @return [APIObject] The un-created ruby-instance of a JSS object
    #
    def self.create(**args)
      validate_not_metaclass(self)
      unless constants.include?(:CREATABLE)
        raise Jamf::UnsupportedError, "Creating #{self::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows."
      end
      raise ArgumentError, "Use '#{self.class}.fetch id: xx' to retrieve existing JSS objects" if args[:id]

      args[:cnx] ||= args[:api] # deprecated
      args[:cnx] ||= Jamf.cnx
      args[:id] = :new
      new(**args)
    end

    # backward compatability
    # @deprecated use .create instead
    def self.make(**args)
      create(**args)
    end

    # Disallow direct use of ruby's .new class method for creating instances.
    # Require use of .fetch or .make
    def self.new(**args)
      validate_not_metaclass(self)

      calling_method = caller_locations(1..1).first.label
      raise Jamf::UnsupportedError, 'Use .fetch or .create to instantiate APIObject classes' unless OK_INSTANTIATORS.include? calling_method

      super
    end

    # Delete one or more API objects by jss_id without instantiating them.
    # Non-existent id's are skipped and an array of skipped ids is returned.
    #
    # If an Array is provided, it is passed through #uniq! before being processed.
    #
    # @param victims[Integer,Array<Integer>] An object id or an array of them
    #   to be deleted
    #
    # @param cnx [Jamf::Connection] the API connection to use.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<Integer>] The id's that didn't exist when we tried to
    #   delete them.
    #
    def self.delete(victims, refresh = true, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      validate_not_metaclass(self)

      raise Jamf::InvalidDataError, 'Parameter must be an Integer ID or an Array of them' unless victims.is_a?(Integer) || victims.is_a?(Array)

      case victims
      when Integer
        victims = [victims]
      when Array
        victims.uniq!
      end

      skipped = []
      current_ids = all_ids refresh, cnx: cnx
      victims.each do |vid|
        if current_ids.include? vid
          cnx.c_delete "#{self::RSRC_BASE}/id/#{vid}"
        else
          skipped << vid
        end # if current_ids include vid
      end # each victim

      # clear any cached all-lists or id-maps for this class
      # so they'll re-cache as needed
      cnx.flushcache self::RSRC_LIST_KEY
      # all :refresh, cnx: cnx

      skipped
    end # self.delete

    # Can't use APIObject directly.
    def self.validate_not_metaclass(klass)
      raise Jamf::UnsupportedError, 'Jamf::APIObject is a metaclass. Do not use it directly' if klass == Jamf::APIObject
    end

    # Attributes
    #####################################

    # @return [Jamf::Connection] the API connection thru which we deal with
    #   this object.
    attr_reader :cnx
    # @deprecated 'api' to refer to connection objects will be removed eventually
    alias api cnx

    # @return the parsed JSON data retrieved from the API when this object was
    #    fetched
    attr_reader :init_data

    # @return [Integer] the JSS id number
    attr_reader :id

    # @return [String] the name
    attr_reader :name

    # @return [Boolean] is it in the JSS?
    attr_reader :in_jss

    # @return [String] the Rest resource for API access (the part after "JSSResource/" )
    attr_reader :rest_rsrc

    # Attibute Aliases
    #####################################

    alias in_jss? in_jss

    # Constructor
    #####################################

    # The args hash must include :id, :name, or :data.
    # * :id or :name will be looked up via the API
    # * * if the subclass includes Jamf::Creatable, :id can be :new, to create a new object in the JSS.
    #     and :name is required
    # * :data must be the JSON output of a separate {Jamf::Connection} query (a Hash of valid object data)
    #
    # Some subclasses can accept other options, by pasing their keys in a final Array
    #
    # @param args[Hash] the data for looking up, or constructing, a new object.
    #
    # @option args :id[Integer] the jss id to look up
    #
    # @option args :name[String] the name to look up
    #
    # @option args :fetch_rsrc[String] a non-standard resource for fetching
    #   API data e.g. to limit the data returned
    #
    #
    def initialize(**args)
      @cnx = args[:cnx]
      @cnx ||= args[:api]
      @cnx ||= Jamf.cnx

      # we're making a new one in the JSS
      if args[:id] == :new
        validate_init_for_creation(args)
        setup_object_for_creation(args)
        @need_to_update = true

      # we're instantiating an existing one in the jss
      else
        @init_data = look_up_object_data(args)
        @need_to_update = false
      end ## end arg parsing

      parse_init_data
    end # init

    # Public Instance Methods
    #####################################

    # Ruby 3's default behavior when raising exceptions will include the output
    # of #inspect, recursively for all data in an object.
    # For many OAPIObjects, esp JPAPI Resources, this includes the embedded
    # Connection object and all the caches is might hold, which might be
    # thousands of lines.
    # we override that here to prevent that. I've heard rumor this will be
    # fixed in ruby 3.2
    # def inspect
    #   #<Jamf::Policy:0x0000000110138df8
    #   "<#{self.class}:#{object_id}>"
    # end

    # Either Create or Update this object in the JSS
    #
    # If this item is creatable or updatable, then
    # create it if needed, or update it if it already exists.
    #
    # @return [Integer] the id of the item created or updated
    #
    def save
      if @in_jss
        update
      else
        create
      end
    end

    # @deprecated, use #save
    def create
      raise Jamf::UnsupportedError, 'Creating this object in the JSS is currently not supported by ruby-jss' unless creatable?

      create_in_jamf
    end

    # @deprecated, use #save
    def update
      raise Jamf::UnsupportedError, 'Updating this object in the JSS is currently not supported by ruby-jss' unless updatable?

      update_in_jamf
    end

    # Mix-in Modules.
    # Each module made for mixing in to APIObject subclasses
    # sets an appropriate constant to true.
    # These methods provide a simple way to programattically determine
    # if an object has one of the mixed-in modules available.

    # @return [Boolean] See {Jamf::Creatable}
    def creatable?
      defined? self.class::CREATABLE
    end

    # @return [Boolean] See {Jamf::Updatable}
    def updatable?
      defined? self.class::UPDATABLE
    end

    # @return [Boolean] See {Jamf::Categorizable}
    def categorizable?
      defined? self.class::CATEGORIZABLE
    end

    # @return [Boolean] See {Jamf::VPPable}
    def vppable?
      defined? self.class::VPPABLE
    end

    # @return [Boolean] See {Jamf::SelfServable}
    def self_servable?
      defined? self.class::SELF_SERVABLE
    end

    # @return [Boolean] See {Jamf::Criteriable}
    def criterable?
      defined? self.class::CRITERIABLE
    end

    # @return [Boolean] See {Jamf::Sitable}
    def sitable?
      defined? self.class::SITABLE
    end

    # @return [Boolean] See {Jamf::extendable}
    def extendable?
      defined? self.class::EXTENDABLE
    end

    # @return [Boolean] See {Jamf::Matchable}
    def matchable?
      defined? self.class::MATCHABLE
    end

    # @return [Boolean] See {Jamf::Locatable}
    def locatable?
      defined? self.class::LOCATABLE
    end

    # @return [Boolean] See {Jamf::Purchasable}
    def purchasable?
      defined? self.class::PURCHASABLE
    end

    # @return [Boolean] See {Jamf::Scopable}
    def scopable?
      defined? self.class::SCOPABLE
    end

    # @return [Boolean] See {Jamf::Uploadable}
    def uploadable?
      defined? self.class::UPLOADABLE
    end

    # Delete this item from the JSS.
    #
    # @seealso {APIObject.delete} for deleting
    # one or more objects by id without needing to instantiate
    #
    # Subclasses may want to redefine this method,
    # first calling super, then setting other attributes to
    # nil, false, empty, etc..
    #
    # @return [void]
    #
    def delete
      return unless @in_jss

      @cnx.c_delete @rest_rsrc

      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name.to_s}"
      @id = nil
      @in_jss = false
      @need_to_update = false

      # clear any cached all-lists or id-maps for this class
      # so they'll re-cache as needed
      @cnx.flushcache self.class::RSRC_LIST_KEY
      # self.class.all :refresh, cnx: @cnx

      :deleted
    end # delete

    # A meaningful string representation of this object
    #
    # @return [String]
    #
    def to_s
      "#{self.class}@#{cnx.host}, id: #{@id}"
    end

    # Remove the init_data and api object from
    # the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = instance_variables.sort
      vars.delete :@cnx
      vars.delete :@init_data
      vars.delete :@main_subset
      vars
    end

    # Make an entry in this object's Object History.
    # For this to work, the APIObject subclass must define
    # OBJECT_HISTORY_OBJECT_TYPE, an integer indicating the
    # object type in the OBJECT_HISTORY_TABLE in the database
    # (e.g. for computers, the object type is 1)
    #
    # NOTE: Object history is not available via the Classic API,
    #   so access is only available through direct MySQL
    #   connections
    #
    # Also: the 'details' column in the table shows up in the
    #   'notes' column of the Web UI.  and the 'object_description'
    #   column of the table shows up in the 'details' column of
    #   the UI, under the 'details' button.
    #
    #   The params below reflect the UI, not the table.
    #
    # @param user[String] the username creating the entry.
    #
    # @param notes[String] A string that appears as a 'note' in the history
    #
    # @param details[String] A string that appears as the 'details' in the history
    #
    # @return [void]
    #
    def add_object_history_entry(user: nil, notes: nil, details: nil)
      validate_object_history_available

      raise Jamf::MissingDataError, 'A user: must be provided to make the entry' unless user

      raise Jamf::MissingDataError, 'notes: must be provided to make the entry' unless notes

      user = "'#{Mysql.quote user.to_s}'"
      notes =  "'#{Mysql.quote notes.to_s}'"
      obj_type = self.class::OBJECT_HISTORY_OBJECT_TYPE

      field_list = 'object_type, object_id, username, details, timestamp_epoch'
      value_list = "#{obj_type}, #{@id}, #{user}, #{notes}, #{Time.now.to_jss_epoch}"

      if details
        field_list << ', object_description'
        value_list << ", '#{Mysql.quote details.to_s}'"
      end # if details

      q = "INSERT INTO #{OBJECT_HISTORY_TABLE}
        (#{field_list})
      VALUES
        (#{value_list})"

      Jamf::DB_CNX.db.query q
    end

    # the object history for this object, an array of hashes
    # one per history entry, in order of creation.
    # Each hash contains:
    #   user: String, the username that created the entry
    #   notes:  String, the notes for the entry
    #   date: Time, the timestamp for the entry
    #   details: String or nil, any details provided for the entry
    #
    # @return [Array<Hash>] the object history
    #
    def object_history
      validate_object_history_available

      q = "SELECT username, details, timestamp_epoch, object_description
      FROM #{OBJECT_HISTORY_TABLE}
      WHERE object_type = #{self.class::OBJECT_HISTORY_OBJECT_TYPE}
      AND object_id = #{@id}
      ORDER BY object_history_id ASC"

      result = Jamf::DB_CNX.db.query q
      history = []
      result.each do |entry|
        history << {
          user: entry[0],
          notes: entry[1],
          date: JSS.epoch_to_time(entry[2]),
          details: entry[3]
        }
      end # each do entry
      history
    end

    # Print the rest_xml value of the object to stdout,
    # with indentation. Useful for debugging.
    #
    # @return [void]
    #
    def ppx
      return nil unless creatable? || updatable?

      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      formatter.write(REXML::Document.new(rest_xml), $stdout)
      puts
    end

    # Private Instance Methods
    #####################################

    private

    # Raise an exception if object history is not
    # available for this object
    #
    # @return [void]
    #
    def validate_object_history_available
      raise Jamf::NoSuchItemError, 'Object not yet created' unless @id && @in_jss

      raise Jamf::InvalidConnectionError, 'Not connected to MySQL' unless Jamf::DB_CNX.connected?

      return if defined? self.class::OBJECT_HISTORY_OBJECT_TYPE

      raise Jamf::UnsupportedError,
            "Object History access is not supported for #{self.class} objects at this time"
    end

    # If we're making a new object in the JSS, make sure we were given
    # valid data to do so, raise exceptions otherwise.
    #
    # NOTE: some subclasses may do further validation.
    #
    # TODO: support for objects that can have duplicate names.
    #
    # @param args[Hash] The args passed to #initialize
    #
    # @return [void]
    #
    def validate_init_for_creation(args)
      raise Jamf::UnsupportedError, "Creating #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless creatable?

      raise Jamf::MissingDataError, "You must provide a :name to create a #{self.class::RSRC_OBJECT_KEY}." unless args[:name]

      return if defined? self.class::NON_UNIQUE_NAMES

      matches = self.class.all_names(:refresh, cnx: @cnx).select { |n| n.casecmp? args[:name] }

      raise Jamf::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} already exists with the name '#{args[:name]}'" unless matches.empty?
    end

    # Given initialization args, perform an API lookup for an object.
    #
    # @param args[Hash] The args passed to #initialize, which must have either
    #  key :id or key :fetch_rsrc
    #
    # @return [Hash] The parsed JSON data for the object from the API
    #
    def look_up_object_data(args)
      rsrc = args[:fetch_rsrc]
      rsrc ||= "#{self.class::RSRC_BASE}/id/#{args[:id]}"

      # if needed, a non-standard object key can be passed by a subclass.
      # e.g. User when loookup is by email.
      args[:rsrc_object_key] ||= self.class::RSRC_OBJECT_KEY

      raw_json =
        if defined? self.class::USE_XML_WORKAROUND
          # if we're here, the API JSON is borked, so use the XML
          Jamf::XMLWorkaround.data_via_xml rsrc, self.class::USE_XML_WORKAROUND, @cnx
        else
          # otherwise
          @cnx.c_get(rsrc)
        end

      raw_json[args[:rsrc_object_key]]
    end

    # Start examining the @init_data recieved from the API
    #
    # @return [void]
    #
    def parse_init_data
      @init_data ||= {}
      # set empty strings to nil
      @init_data.jss_nillify! '', :recurse

      # Find the "main" subset which contains :id and :name
      @main_subset = find_main_subset
      @name = @main_subset[:name]

      if @main_subset[:id] == :new
        @id = 0
        @in_jss = false
      else
        @id = @main_subset[:id].to_i
        @in_jss = true
      end

      @rest_rsrc = "#{self.class::RSRC_BASE}/id/#{@id}"

      ##### Handle Mix-ins
      initialize_category
      initialize_site
      initialize_location
      initialize_purchasing
      initialize_scope
      initialize_criteria
      initialize_ext_attrs
      initialize_vpp
      initialize_self_service
    end

    # Find which part of the @init_data contains the :id and :name
    #
    # If they aren't at the top-level of the init hash they are in a subset hash,
    # usually :general, but sometimes someething else,
    # like ldap servers, which have them in :connection
    # Whereever both :id and :name are, that's the main subset
    #
    # @return [Hash] The part of the @init_data containg the :id and :name
    #
    def find_main_subset
      return @init_data if @init_data[:id] && @init_data[:name]
      return @init_data[:general] if @init_data[:general] && @init_data[:general][:id] && @init_data[:general][:name]

      @init_data.each do |_key, value|
        next unless value.is_a? Hash
        return value if value.keys.include?(:id) && value.keys.include?(:name)
      end
    end

    # parse category data during initialization
    #
    # @return [void]
    #
    def initialize_category
      parse_category if categorizable? && @in_jss
    end

    # parse site data during initialization
    #
    # @return [void]
    #
    def initialize_site
      parse_site if sitable?
    end

    # parse location data during initialization
    #
    # @return [void]
    #
    def initialize_location
      parse_location if locatable?
    end

    # parse purchasing data during initialization
    #
    # @return [void]
    #
    def initialize_purchasing
      parse_purchasing if purchasable?
    end

    # parse scope data during initialization
    #
    # @return [void]
    #
    def initialize_scope
      parse_scope if scopable?
    end

    # parse criteria data during initialization
    #
    # @return [void]
    #
    def initialize_criteria
      parse_criteria if criterable?
    end

    # parse ext_attrs data during initialization
    #
    # @return [void]
    #
    def initialize_ext_attrs
      parse_ext_attrs if extendable?
    end

    # parse vpp data during initialization
    #
    # @return [void]
    #
    def initialize_vpp
      parse_vpp if vppable?
    end

    # parse self_service data during initialization
    #
    # @return [void]
    #
    def initialize_self_service
      parse_self_service if self_servable?
    end

    # Set the basics for creating a new object in the JSS
    #
    # @param args[Type] describe_args
    #
    # @return [Type] description_of_returned_object
    #
    def setup_object_for_creation(args)
      # NOTE: subclasses may want to pre-populate more keys in @init_data when :id == :new
      # then parse them into attributes later.
      @init_data = args
      @name = args[:name]
      @in_jss = false
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name.to_s}"
      @need_to_update = true
    end

    # Return a String with the XML Resource
    # for submitting creation or changes to the JSS via
    # the API via the Creatable or Updatable modules
    #
    # Most classes will redefine this method.
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      tmpl = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      tmpl.add_element('name').text = @name
      doc.to_s
    end

  end # class APIObject

end # module Jamf
