### Copyright 2018 Pixar

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
module JSS

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # This class is the parent to all JSS API objects. It provides standard methods and structures
  # that apply to all API resouces.
  #
  # See the README.md file for general info about using subclasses of JSS::APIObject
  #
  # == Subclassing
  #
  # === Constructor
  #
  # In general, subclasses should do any class-specific argument checking before
  # calling super, and then afterwards, use the contents of @init_data to populate
  # any class-specific attributes. @id, @name, @rest_rsrc, and @in_jss are handled here.
  #
  # If a subclass can be looked up by some key other than :name or :id, the subclass must
  # pass the keys as an Array in the second argument when calling super from #initialize.
  # See {JSS::Computer#initialize} for an example of how to implement this feature.
  #
  # === Object Creation
  #
  # If a subclass should be able to be created in the JSS be sure to include {JSS::Creatable}
  #
  # The constructor should verify any extra required data (aside from :name) in the args before or after
  # calling super.
  #
  # See {JSS::Creatable} for more details.
  #
  # === Object Modification
  #
  # If a subclass should be modifiable in the JSS, include {JSS::Updatable}, q.v. for details.
  #
  # === Object Deletion
  #
  # All subclasses can be deleted in the JSS.
  #
  # === Required Constants
  #
  # Subclasses *must* provide certain Constants in order to correctly interpret API data and
  # communicate with the API.
  #
  # ==== RSRC_BASE = [String],  The base for REST resources of this class
  #
  # e.g. 'computergroups' in  "https://casper.mycompany.com:8443/JSSResource/computergroups/id/12"
  #
  # ==== RSRC_LIST_KEY = [Symbol] The Hash key for the JSON list output of all objects of this class in the JSS.
  #
  # e.g. the JSON output of resource "JSSResource/computergroups" is a hash
  # with one item (an Array of computergroups). That item's key is the Symbol :computer_groups
  #
  # ==== RSRC_OBJECT_KEY = [Symbol] The Hash key used for individual JSON object output.
  # It's also used in various error messages
  #
  # e.g. the JSON output of the resource "JSSResource/computergroups/id/436" is
  # a hash with one item (another hash with details of one computergroup).
  # That item's key is the Symbol :computer_group
  #
  # ==== VALID_DATA_KEYS = [Array<Symbol>] The Hash keys used to verify validity of :data
  # When instantiating a subclass using :data => somehash, some minimal checks are performed
  # to ensure the data is valid for the subclass
  #
  # The Symbols in this Array are compared to the keys of the hash provided.
  # If any of these don't exist in the hash's keys, then the :data is
  # not valid and an exception is raised.
  #
  # The keys :id and :name must always exist in the hash.
  # If only :id and :name are valid, VALID_DATA_KEYS should be an empty array.
  #
  # e.g. for a department, only :id and :name are valid, so VALID_DATA_KEYS is an empty Array ([])
  # but for a computer group, the keys :computers and :is_smart must be present as well.
  # so VALID_DATA_KEYS will be [:computers, :is_smart]
  #
  # *NOTE* Some API objects have data broken into subsections, in which case the
  # VALID_DATA_KEYS are expected in the section :general.
  #
  #
  # === Optional Constants
  #
  # ==== OTHER_LOOKUP_KEYS = [Hash{Symbol=>Hash}] Every object can be looked up by
  # :id and :name, but some have other uniq identifiers that can also be used,
  # e.g. :serial_number, :mac_address, and so on. This Hash, if defined,
  # speficies those other keys for the subclass
  # For more details about this hash, see {APIObject::DEFAULT_LOOKUP_KEYS},
  # {APIObject.fetch}, and {APIObject#lookup_object_data}
  #
  class APIObject

    # Class Methods
    #####################################

    # Return an Array of Hashes for all objects of this subclass in the JSS.
    #
    # This method is only valid in subclasses of JSS::APIObject, and is
    # the parsed JSON output of an API query for the resource defined in the subclass's RSRC_BASE,
    # e.g. for JSS::Computer, with the RSRC_BASE of :computers,
    # This method retuens the output of the 'JSSResource/computers' resource,
    # which is a list of all computers in the JSS.
    #
    # Each item in the Array is a Hash with at least two keys, :id and :name.
    # The class methods .all_ids and .all_names provide easier access to those data
    # as mapped Arrays.
    #
    # Some API classes provide other data in each Hash, e.g. :udid (for computers
    # and mobile devices) or :is_smart (for groups).
    #
    # Subclasses implementing those API classes should provide .all_xxx
    # class methods for accessing those other values as mapped Arrays,
    # e.g. JSS::Computer.all_udids
    #
    # The results of the first query for each subclass is stored in the .object_list_cache
    # of the given JSS::APIConnection and returned at every future call, so as
    # to not requery the server every time.
    #
    # To force requerying to get updated data, provided a non-false argument.
    # I usually use :refresh, so that it's obvious what I'm doing, but true, 1,
    # or anything besides false or nil will work.
    #
    # To query an APIConnection other than the currently active one,
    # provide one via the api: named parameter.
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<Hash{:name=>String, :id=> Integer}>]
    #
    def self.all(refresh = false, api: JSS.api)
      raise JSS::UnsupportedError, '.all can only be called on subclasses of JSS::APIObject' if self == JSS::APIObject
      api.object_list_cache[self::RSRC_LIST_KEY] = nil if refresh
      return api.object_list_cache[self::RSRC_LIST_KEY] if api.object_list_cache[self::RSRC_LIST_KEY]
      api.object_list_cache[self::RSRC_LIST_KEY] = api.get_rsrc(self::RSRC_BASE)[self::RSRC_LIST_KEY]
    end

    # Returns an Array of the JSS id numbers of all the members
    # of the subclass.
    #
    # e.g. When called from subclass JSS::Computer,
    # returns the id's of all computers in the JSS
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<Integer>] the ids of all it1ems of this subclass in the JSS
    #
    def self.all_ids(refresh = false, api: JSS.api)
      all(refresh, api: api).map { |i| i[:id] }
    end

    # Returns an Array of the JSS names of all the members
    # of the subclass.
    #
    # e.g. When called from subclass JSS::Computer,
    # returns the names of all computers in the JSS
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<String>] the names of all item of this subclass in the JSS
    #
    def self.all_names(refresh = false, api: JSS.api)
      all(refresh, api: api).map { |i| i[:name] }
    end

    # Return a hash of all objects of this subclass
    # in the JSS where the key is the id, and the value
    # is some other key in the data items returned by the JSS::APIObject.all.
    #
    # If the other key doesn't exist in the API
    # data, (eg :udid for JSS::Department) the values will be nil.
    #
    # Use this method to map ID numbers to other identifiers returned
    # by the API list resources. Invert its result to map the other
    # identfier to ids.
    #
    # @example
    #   JSS::Computer.map_all_ids_to(:name)
    #
    #   # Returns, eg {2 => "kimchi", 5 => "mantis"}
    #
    #   JSS::Computer.map_all_ids_to(:name).invert
    #
    #   # Returns, eg {"kimchi" => 2, "mantis" => 5}
    #
    # @param other_key[Symbol] the other data key with which to associate each id
    #
    # @param refresh[Boolean] should the data  re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Hash{Integer => Oject}] the associated ids and data
    #
    def self.map_all_ids_to(other_key, refresh = false, api: JSS.api)
      h = {}
      all(refresh, api: api).each { |i| h[i[:id]] = i[other_key] }
      h
    end

    # Return an Array of JSS::APIObject subclass instances
    # e.g when called on JSS::Package, return all JSS::Package
    # objects in the JSS.
    #
    # NOTE: This may be slow as it has to look up each object individually!
    # use it wisely.
    #
    # @param refresh[Boolean] should the data  re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Hash{Integer => Object}] the objects requested
    #
    def self.all_objects(refresh = false, api: JSS.api)
      objects_key = "#{self::RSRC_LIST_KEY}_objects".to_sym
      return api.object_list_cache[objects_key] unless refresh || api.object_list_cache[objects_key].nil?
      api.object_list_cache[objects_key] = all(refresh, api: api).map { |o| fetch id: o[:id], api: api }
    end

    # Return true or false if an object of this subclass
    # with the given Identifier exists on the server
    #
    # @param identfier [String,Integer] An identifier for an object, a value for
    # one of the available lookup_keys
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Boolean] does an object with the given identifier exist?
    #
    def self.exist?(identifier, refresh = false, api: JSS.api)
      !valid_id(identifier, refresh, api: api).nil?
    end

    # Return an id or nil if an object of this subclass
    # with the given name or id exists on the server
    #
    # @param identfier [String,Integer] An identifier for an object, a value for
    # one of the available lookup_keys
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Integer, nil] the id of the matching object, or nil if it doesn't exist
    #
    def self.valid_id(identifier, refresh = false, api: JSS.api)
      return identifier if all_ids(refresh, api: api).include? identifier
      all_lookup_keys.keys.each do |key|
        next if key == :id
        id = map_all_ids_to(key).invert[identifier]
        return id if id
      end # do key
      nil
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
    #   # for class JSS::Computer
    #   some_comps = [{:id=>2, :name=>"kimchi"},{:id=>5, :name=>"mantis"}]
    #   xml_names = JSS::Computer.xml_list some_comps
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
    #   xml_ids = JSS::Computer.xml_list some_comps, :id
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

    # What are all the lookup keys available for this class?
    #
    # @return [Array<Symbol>] the DEFAULT_LOOKUP_KEYS plus any OTHER_LOOKUP_KEYS
    #   defined for this class
    #
    def self.lookup_keys
      return DEFAULT_LOOKUP_KEYS.keys unless defined? self::OTHER_LOOKUP_KEYS
      DEFAULT_LOOKUP_KEYS.keys + self::OTHER_LOOKUP_KEYS.keys
    end

    # @return [Hash] the available lookup keys mapped to the appropriate
    #  resource key for building a REST url to retrieve an object.
    #
    def self.rsrc_keys
      hash = {}
      all_lookup_keys.each { |key, deets| hash[key] = deets[:rsrc_key] }
      hash
    end

    # the available list methods for an APIObject sublcass
    #
    # @return [Array<Symbol>] The list methods (e.g. .all_serial_numbers) for
    # this APIObject subclass
    #

    # The combined DEFAULT_LOOKUP_KEYS and OTHER_LOOKUP_KEYS
    # (which may be defined in subclasses)
    #
    # @return [Hash] See DEFAULT_LOOKUP_KEYS constant
    #
    def self.all_lookup_keys
      return DEFAULT_LOOKUP_KEYS.merge(self::OTHER_LOOKUP_KEYS) if defined? self::OTHER_LOOKUP_KEYS
      DEFAULT_LOOKUP_KEYS
    end

    # @return [Hash] the available lookup keys mapped to the appropriate
    #  list class method (e.g. id: :all_ids )
    #
    def self.lookup_key_list_methods
      hash = {}
      all_lookup_keys.each { |key, deets| hash[key] = deets[:list] }
      hash
    end

    # Retrieve an object from the API.
    #
    # This is the preferred way to retrieve existing objects from the JSS.
    # It's a wrapper for using APIObject.new and avoids the confusion of using
    # ruby's .new class method when you're not creating a new object in the JSS
    #
    # For creating new objects in the JSS, use {APIObject.make}
    #
    # @param args[Hash] The data for fetching an object, such as id: or name:
    #  Each APIObject subclass can define additional lookup keys for fetching.
    #
    # @return [APIObject] The ruby-instance of a JSS object
    #
    def self.fetch(arg, api: JSS.api)
      raise JSS::UnsupportedError, 'JSS::APIObject cannot be instantiated' if self.class == JSS::APIObject

      # if given a hash (or a colletion of named params)
      # pass to .new
      if arg.is_a? Hash
        raise ArgumentError, 'Use .make to create new JSS objects' if arg[:id] == :new
        arg[:api] ||= api
        return new arg
      end

      # loop thru the lookup_key list methods for this class
      # and if it's result includes the desired value,
      # the pass they key and arg to .new
      lookup_key_list_methods.each do |key, method_name|
        return new(key => arg, :api => api) if method_name && send(method_name).include?(arg)
      end # each key

      # if we're here, we couldn't find a matching object
      raise NoSuchItemError, "No #{self::RSRC_OBJECT_KEY} found matching '#{arg}'"
    end # fetch

    # Make a ruby instance of a not-yet-existing APIObject.
    #
    # This is the preferred way to create new objects in the JSS.
    # It's a wrapper for using APIObject.new with the 'id: :new' parameter.
    # and helps avoid the confusion of using ruby's .new class method for making
    # ruby instances.
    #
    # For retrieving existing objects in the JSS, use {APIObject.fetch}
    #
    # For actually creating the object in the JSS, see {APIObject#create}
    #
    # @param args[Hash] The data for creating an object, such as name:
    #  See {APIObject#initialize}
    #
    # @return [APIObject] The un-created ruby-instance of a JSS object
    #
    def self.make(**args)
      args[:api] ||= JSS.api
      raise JSS::UnsupportedError, 'JSS::APIObject cannot be instantiated' if self.class == JSS::APIObject
      raise ArgumentError, "Use '#{self.class}.fetch id: xx' to retrieve existing JSS objects" if args[:id]
      args[:id] = :new
      new args
    end

    # Delete one or more API objects by jss_id without instantiating them.
    # Non-existent id's are skipped and an array of skipped ids is returned.
    #
    # If an Array is provided, it is passed through #uniq! before being processed.
    #
    # @param victims[Integer,Array<Integer>] An object id or an array of them
    #   to be deleted
    #
    # @param api[JSS::APIConnection] the API connection to use.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<Integer>] The id's that didn't exist when we tried to
    #   delete them.
    #
    def self.delete(victims, api: JSS.api)
      raise JSS::UnsupportedError, '.delete can only be called on subclasses of JSS::APIObject' if self == JSS::APIObject
      raise JSS::InvalidDataError, 'Parameter must be an Integer ID or an Array of them' unless victims.is_a?(Integer) || victims.is_a?(Array)

      case victims
      when Integer
        victims = [victims]
      when Integer
        victims = [victims]
      when Array
        victims.uniq!
      end

      skipped = []
      current_ids = all_ids :refresh, api: api
      victims.each do |vid|
        if current_ids.include? vid
          api.delete_rsrc "#{self::RSRC_BASE}/id/#{vid}"
        else
          skipped << vid
        end # if current_ids include v
      end # each victim

      skipped
    end # self.delete

    ### Class Constants
    #####################################

    # These Symbols are added to VALID_DATA_KEYS for performing the
    # :data validity test described above.
    #
    REQUIRED_DATA_KEYS = %i[id name].freeze

    # All API objects have an id and a name. As such By these keys are available
    # for object lookups.
    #
    # Others can be defined by subclasses in their OTHER_LOOKUP_KEYS constant
    # which has the same format, described here:
    #
    # The merged Hashes DEFAULT_LOOKUP_KEYS and OTHER_LOOKUP_KEYS
    # (as provided by the .all_lookup_keys Class method)
    # define what unique identifiers can be passed as parameters to the
    # fetch method for retrieving an object from the API.
    # They also define the class methods that return a list (Array) of all such
    # identifiers for the class (e.g. the :all_ids class method returns an array
    # of all id's for an APIObject subclass)
    #
    # Since there's often a discrepency between the name of the identifier as
    # an attribute (e.g. serial_number) and the REST resource key for
    # retrieving that object (e.g. ../computers/serialnumber/xxxxx) this hash
    # also explicitly provides the REST resource key for a given lookup key, so
    # e.g. both serialnumber and serial_number can be used, and both will have
    # the resource key 'serialnumber' and the list method ':all_serial_numbers'
    #
    # Here's how the Hash is structured, using serialnumber as an example:
    #
    # LOOKUP_KEYS = {
    #      serialnumber: {rsrc_key: :serialnumber, list: :all_serial_numbers},
    #      serial_number: {rsrc_key: :serialnumber, list: :all_serial_numbers}
    # }
    #
    DEFAULT_LOOKUP_KEYS = {
      id: { rsrc_key: :id, list: :all_ids },
      name: { rsrc_key: :name, list: :all_names }
    }.freeze

    # This table holds the object history for JSS objects.
    # Object history is not available via the API,
    # only MySQL.
    OBJECT_HISTORY_TABLE = 'object_history'.freeze

    # Attributes
    #####################################

    # @return [JSS::APIConnection] the API connection thru which we deal with
    #   this object.
    attr_reader :api

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

    # Constructor
    #####################################

    # The args hash must include :id, :name, or :data.
    # * :id or :name will be looked up via the API
    # * * if the subclass includes JSS::Creatable, :id can be :new, to create a new object in the JSS.
    #     and :name is required
    # * :data must be the JSON output of a separate {JSS::APIConnection} query (a Hash of valid object data)
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
    def initialize(args = {})
      args[:api] ||= JSS.api
      @api = args[:api]
      raise JSS::UnsupportedError, 'JSS::APIObject cannot be instantiated' if self.class == JSS::APIObject

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

    # Either Create or Update this object in the JSS
    #
    # If this item is creatable or updatable, then
    # create it if needed, or update it if it already exists.
    #
    # @return [Integer] the id of the item created or updated
    #
    def save
      if @in_jss
        raise JSS::UnsupportedError, 'Updating this object in the JSS is currently not supported by ruby-jss' unless updatable?
        update
      else
        raise JSS::UnsupportedError, 'Creating this object in the JSS is currently not supported by ruby-jss' unless creatable?
        create
      end
    end

    # Mix-in Modules.
    # Each module made for mixing in to APIObject subclasses
    # sets an appropriate constant to true.
    # These methods provide a simple way to programattically determine
    # if an object has one of the mixed-in modules available.

    # @return [Boolean] See {JSS::Creatable}
    def creatable?
      defined? self.class::CREATABLE
    end

    # @return [Boolean] See {JSS::Updatable}
    def updatable?
      defined? self.class::UPDATABLE
    end

    # @return [Boolean] See {JSS::Categorizable}
    def categorizable?
      defined? self.class::CATEGORIZABLE
    end

    # @return [Boolean] See {JSS::VPPable}
    def vppable?
      defined? self.class::VPPABLE
    end

    # @return [Boolean] See {JSS::SelfServable}
    def self_servable?
      defined? self.class::SELF_SERVABLE
    end

    # @return [Boolean] See {JSS::Criteriable}
    def criterable?
      defined? self.class::CRITERIABLE
    end

    # @return [Boolean] See {JSS::Sitable}
    def sitable?
      defined? self.class::SITABLE
    end

    # @return [Boolean] See {JSS::extendable}
    def extendable?
      defined? self.class::EXTENDABLE
    end

    # @return [Boolean] See {JSS::Matchable}
    def matchable?
      defined? self.class::MATCHABLE
    end

    # @return [Boolean] See {JSS::Locatable}
    def locatable?
      defined? self.class::LOCATABLE
    end

    # @return [Boolean] See {JSS::Purchasable}
    def purchasable?
      defined? self.class::PURCHASABLE
    end

    # @return [Boolean] See {JSS::Scopable}
    def scopable?
      defined? self.class::SCOPABLE
    end

    # @return [Boolean] See {JSS::Uploadable}
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
      return nil unless @in_jss
      @api.delete_rsrc @rest_rsrc
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name}"
      @id = nil
      @in_jss = false
      @need_to_update = false
      :deleted
    end # delete

    # A meaningful string representation of this object
    #
    # @return [String]
    #
    def to_s
      "#{self.class}, name: #{@name}, id: #{@id}"
    end

    # Remove the init_data and api object from
    # the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = instance_variables.sort
      vars.delete :@api
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
    # NOTE: Object history is not available via the API,
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

      raise JSS::MissingDataError, 'A user: must be provided to make the entry' unless user

      raise JSS::MissingDataError, 'Either notes: must be provided to make the entry' unless notes

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

      JSS::DB_CNX.db.query q
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

      result = JSS::DB_CNX.db.query q
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
      REXML::Document.new(rest_xml).write $stdout, 2
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
      raise JSS::NoSuchItemError, 'Object not yet created' unless @id && @in_jss

      raise JSS::InvalidConnectionError, 'Not connected to MySQL' unless JSS::DB_CNX.connected?

      raise JSS::UnsupportedError, "Object History access is not supported for #{self.class} objects at this time" unless defined? self.class::OBJECT_HISTORY_OBJECT_TYPE
    end

    # If we were passed pre-lookedup API data, validate it,
    # raising exceptions if not valid.
    #
    # DEPRECATED: pre-lookedup data is never used
    # and support for it will be going away.
    #
    # TODO: delete this and all defined VALID_DATA_KEYS
    #
    # @return [void]
    #
    def validate_external_init_data
      # data must include all they keys in REQUIRED_DATA_KEYS + VALID_DATA_KEYS
      # in either the main hash keys or the :general sub-hash, if it exists
      hash_to_check = @init_data[:general] ? @init_data[:general] : @init_data
      combined_valid_keys = self.class::REQUIRED_DATA_KEYS + self.class::VALID_DATA_KEYS
      keys_ok = (hash_to_check.keys & combined_valid_keys).count == combined_valid_keys.count
      unless keys_ok
        raise(
          JSS::InvalidDataError,
          ":data is not valid JSON for a #{self.class::RSRC_OBJECT_KEY} from the API. It needs at least the keys :#{combined_valid_keys.join ', :'}"
        )
      end
      # and the id must be in the jss
      raise NoSuchItemError, "No #{self.class::RSRC_OBJECT_KEY} with JSS id: #{@init_data[:id]}" unless \
        self.class.all_ids(api: @api).include? hash_to_check[:id]
    end # validate_init_data

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
      raise JSS::UnsupportedError, "Creating #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless creatable?

      raise JSS::MissingDataError, "You must provide a :name to create a #{self.class::RSRC_OBJECT_KEY}." unless args[:name]

      raise JSS::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} already exists with the name '#{args[:name]}'" if self.class.all_names(api: @api).include? args[:name]
    end

    # Given initialization args, perform an API lookup for an object.
    #
    # @param args[Hash] The args passed to #initialize
    #
    # @return [Hash] The parsed JSON data for the object from the API
    #
    def look_up_object_data(args)
      rsrc =
        if args[:fetch_rsrc]
          args[:fetch_rsrc]
        else
          # what lookup key are we using?
          rsrc_key, lookup_value = find_rsrc_keys(args)
          "#{self.class::RSRC_BASE}/#{rsrc_key}/#{lookup_value}"
        end

      # if needed, a non-standard object key can be passed by a subclass.
      # e.g. User when loookup is by email.
      rsrc_object_key = args[:rsrc_object_key] ? args[:rsrc_object_key] : self.class::RSRC_OBJECT_KEY

      return @api.get_rsrc(rsrc)[rsrc_object_key]
    rescue RestClient::ResourceNotFound
      raise NoSuchItemError, "No #{self.class::RSRC_OBJECT_KEY} found matching: #{rsrc_key}/#{args[lookup_key]}"
    end

    # Given initialization args, determine the rsrc key and
    # lookup value to be used in building the GET resource.
    # E.g. for looking up something with id 345,
    # return the rsrc_key :id, and the value 345, which
    # can be used to create the resrouce
    # '/things/id/345'
    #
    # @param args[Hash] The args passed to #initialize
    #
    # @return [Array] Two item array: [ rsrc_key, lookup_value]
    #
    def find_rsrc_keys(args)
      lookup_keys = self.class.lookup_keys
      lookup_key = (self.class.lookup_keys & args.keys)[0]
      raise JSS::MissingDataError, "Args must include a lookup key, one of: :#{lookup_keys.join(', :')}" unless lookup_key
      rsrc_key = self.class.rsrc_keys[lookup_key]
      [rsrc_key, args[lookup_key]]
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
        @id = @main_subset[:id]
        @in_jss = true
      end

      @rest_rsrc = "#{self.class::RSRC_BASE}/id/#{@id}"

      # many things have  a :site
      # TODO: Implement a Sitable mixin module
      #
      # @site = JSS::APIObject.get_name(@main_subset[:site]) if @main_subset[:site]

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
      parse_category if categorizable?
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
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name}"
      @need_to_update = true
    end

    # Return a String with the XML Resource
    # for submitting creation or changes to the JSS via
    # the API via the Creatable or Updatable modules
    #
    # Most classes will redefine this method.
    #
    def rest_xml
      doc = REXML::Document.new JSS::APIConnection::XML_HEADER
      tmpl = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      tmpl.add_element('name').text = @name
      doc.to_s
    end

    # Aliases

    alias in_jss? in_jss

  end # class APIObject

end # module JSS

### Mix-in Sub Modules
require 'jss/api_object/creatable'
require 'jss/api_object/uploadable'
require 'jss/api_object/locatable'
require 'jss/api_object/matchable'
require 'jss/api_object/purchasable'
require 'jss/api_object/updatable'
require 'jss/api_object/extendable'
require 'jss/api_object/self_servable'
require 'jss/api_object/categorizable'
require 'jss/api_object/vppable'
require 'jss/api_object/sitable'
require 'jss/api_object/mdm'
require 'jss/api_object/management_history'

### Mix-in Sub Modules with Classes
require 'jss/api_object/criteriable'
require 'jss/api_object/scopable'

### APIObject SubClasses with SubClasses
require 'jss/api_object/advanced_search'
require 'jss/api_object/extension_attribute'
require 'jss/api_object/group'

### APIObject SubClasses without SubClasses
require 'jss/api_object/account'
require 'jss/api_object/building'
require 'jss/api_object/category'
require 'jss/api_object/computer'
require 'jss/api_object/computer_invitation'
require 'jss/api_object/department'
require 'jss/api_object/distribution_point'
require 'jss/api_object/ebook'
require 'jss/api_object/ldap_server'
require 'jss/api_object/mac_application'
require 'jss/api_object/mobile_device'
require 'jss/api_object/mobile_device_application'
require 'jss/api_object/mobile_device_configuration_profile'
require 'jss/api_object/netboot_server'
require 'jss/api_object/network_segment'
require 'jss/api_object/osx_configuration_profile'
require 'jss/api_object/package'
require 'jss/api_object/patch_version'
require 'jss/api_object/patch_title'
require 'jss/api_object/patch_policy'
require 'jss/api_object/peripheral_type'
require 'jss/api_object/peripheral'
require 'jss/api_object/policy'
require 'jss/api_object/removable_macaddr'
require 'jss/api_object/restricted_software'
require 'jss/api_object/script'
require 'jss/api_object/site'
require 'jss/api_object/software_update_server'
require 'jss/api_object/user'
require 'jss/api_object/webhook'
