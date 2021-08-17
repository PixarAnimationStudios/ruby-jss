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

  # Classes
  #####################################

  # # Jamf::JSONObject
  #
  # In JSON & Javascript, an 'object' is a data structure equivalent to a
  # Hash in Ruby. Much of the JSON data exchaged with the API is formatted as
  # these JSON objects.
  #
  # Jamf::JSONObject is a meta class that provides a way to convert those JSON
  # 'objects' into not just Hashes (that's done by the Jamf::Connection) but
  # into full-fledged ruby Classes. Once implemented in ruby-jss, all JSON
  # objects (Hashes) used anywhere in the Jamf Pro API have a matching Class in
  # ruby-jss which is a subclass of Jamf::JSONObject
  #
  # The Jamf::JSONObject class is a base class, and cannot be instantiated or used
  # directly. It merely provides the common functionality needed for dealing
  # with all JSON objects in the API.
  #
  #
  # ## Subclassing
  #
  # When implementing a JSON object in the API as a class in ruby-jss,
  # you will make a subclass of either Jamf::JSONObject, Jamf::SingletonResource
  # or Jamf::CollectionResource.
  #
  # Here's the relationship between these base classes:
  #
  #                      Jamf::JSONObject
  #                         (abstract)
  #                             |
  #                             |
  #                   -----------------------
  #                  |                       |
  #            Jamf::Resource                |
  #              (abstract)                  |
  #                  |                       |
  #                  |                       |
  #                  |            Jamf::Computer::Reference
  #                  |                  Jamf::Location
  #                  |              Jamf::ChangeLog::Entry
  #                  |        (more non-resource JSON object classes)
  #                  |
  #                  |----------------------------------------
  #                  |                                        |
  #                  |                                        |
  #         Jamf::SingletonResource                Jamf::CollectionResource
  #              (abstract)                               (abstract)
  #                  |                                        |
  #                  |                                        |
  #       Jamf::Settings::ReEnrollment                  Jamf::Computer
  #       Jamf::Settings::SelfService                   Jamf::Building
  #            Jamf::SystemInfo                       Jamf::PatchPolicy
  #     (more singleton resource classes)     (more collection resource classes)
  #
  #
  # Direct descendents of Jamf::JSONObject are arbitrary JSON objects that
  # appear inside other objects, e.g. the Location data for a computer,
  # or a reference to a building.
  #
  # {Jamf::Resource} classes represent direct resources of the API, i.e. items
  # accessible with a URL. The ability to interact with those URLs is defined in
  # the metaclass Jamf::Resource, and all resources must define a RSRC_VERSION
  # and a RSRC_PATH.  See {Jamf::Resource} for more info.
  #
  # There are two kinds of resources in the API:
  #
  # {Jamf::SingletonResource} classes represent objects in the API that have
  # only one instance, such as various settings, or server-wide state. These
  # objects cannot be created or deleted, only fetched and updated.
  #
  # {Jamf::CollectionResource} classes represent collections of objects in the
  # API. These resources can list all of their members, and individual members
  # can be retrieved, updated, created and deleted.
  #
  # Subclasses need to meet the requirements for all of their ancestors,
  # so once you decide which one you're subclassing, be sure to read the docs
  # for each one. E.g. to implement Jamf::Package, it will be a
  # {Jamf::CollectionResource}, which is a {Jamf::Resource}, which is a
  # {Jamf::JSONObject}, and the requirements for all must be met.
  #
  # The remainder of this page documents the requirements and details of
  # Jamf::JSONObject.
  #
  #
  # NOTES:
  #
  # - subclasses may define more methods, include mix-ins, and if
  #   needed can override methods defined in metaclasses. Please read the
  #   docs before overriding.
  #
  # - Throughout the documentation 'parsed JSON object' means the result of running
  #   a raw JSON string thru `JSON.parse raw_json, symbolize_names: true`. This
  #   is performed in the {Jamf::Connection} methods which interact with the API:
  #   {Jamf::Connection#get}, {Jamf::Connection#post}, {Jamf::Connection#put}
  #   {Jamf::Connection#patch} and {Jamf::Connection#delete}.
  #
  # - Related to the above, the {Jamf::Connection} methods
  #   {Jamf::Connection#post} and {Jamf::Connection#put} call `#to_json` on the
  #   data passed to them, before sending it to the API.  Subclasses and
  #   application code should never call #to_json anywhere.  The data passed
  #   to put and post should be the output of `#to_jamf` on a Jamf::JSONObject,
  #   which is handled by the the #update and #create methods as needed.
  #
  #
  # ###
  #
  # ### Required Constant: OBJECT_MODEL  & call to parse_object_model
  #
  # Each descendent of JSONObject must define the constant OBJECT_MODEL, which
  # is a Hash of Hashes that collectively define the top-level keys of the JSON
  # object as attributes of the matching ruby class.
  #
  # Immediately after the definition of OBJECT_MODEL, the subclass *MUST* call
  # `self.parse_object_model` to convert the model into actual ruby attributes
  # with getters and setters.
  #
  # The OBJECT_MODEL Hash directly implements the matching JSON object model
  # defined at https://developer.jamf.com/apis/jamf-pro-api/index and is used
  # to automatically create attributes & accessor methods mirroring those
  # in the API.
  #
  # The keys of the main hash are the symbolized names of the attributes as they
  # come from the JSON fetched from the API.
  #
  # _ATTRIBUTE NAMES:_
  #
  # The attribute names in the Jamf Pro API JSON data are in 'lowerCamelCase'
  # (https://en.wikipedia.org/wiki/Camel_case), and are used that way
  # throughout the Jamf module in order to maintain consistency with the API
  #  itself. This differs from the ruby standard of using 'snake_case'
  # (https://en.wikipedia.org/wiki/Snake_case) for attributes,
  # methods, & local variables. I believe that maintaining consistency with the
  # API we are mirroring is more important (and simpler) than conforming with
  # ruby's community standards. I also believe that doing so is in-line with the
  # ruby community's larger philosophy.
  #
  # "There's more than one way to do it" - because context matters.
  # If that weren't true, I'd be writing Python.
  #
  # Each attribute key has a Hash of details defining how the attribute is
  # used in the class. Getters and setters are created from these details, and
  # they are used to parse incoming, and generate outgoing JSON data
  #
  # The possible keys of the details Hash for each attribute are:
  #
  # - class:
  # - identfier:
  # - required:
  # - readonly:
  # - multi:
  # - enum:
  # - validator:
  # - aliases:
  # - filter_key:
  #
  # For an example of an OBJECT_MODEL hash, see {Jamf::MobileDeviceDetails::OBJECT_MODEL}
  #
  # The details for each key's value are as follows. Note that omitting a
  # boolean key is the same as setting it to false.
  #
  # class: \[Symbol or Class]
  # -----------------
  # This is the only required key for all attributes.
  #
  # ---
  # Symbol is one of :string, :integer, :float, :boolean, or :j_id
  #
  # The first four are the JSON data types that don't need parsing into ruby
  # beyond that done by `JSON.parse`. When processing an attribute with one of
  # these symbols as the `class:`, the JSON value is used as-is.
  #
  # The ':j_id' symbol means this value is an id used to reference an object in
  # a collection resource of the API - all such objects have an 'id' attribute
  # which is a String containing an Integer.
  #
  # These ids are used not only as the id attribute of the object itself, but
  # if an object contains references to one or more other objects, those
  # references are also ':j_id' values.
  # In setters and .create, :j_id values can take either an integer or an
  # integer-in-a-string, and are stored as integer-in-a-string/
  #
  # When 'class:' is not a Symbol, it must be an actual class, such as
  # Jamf::Timestamp or Jamf::PurchasingData.
  #
  # Actual classes used this way _must_:
  #
  # - Have an #initialize method that takes two parameters and performs
  #   validation on them:
  #
  #   A first positional parameter, the value used to create the instance,
  #   which accepts, at the very least, the Parsed JSON data for the attribute.
  #   This can be a single value (e.g. a string for Jamf::Timestamp), or a Hash
  #   (e.g. for Jamf::Location), or whatever. Other values are
  #   allowed if your initialize method handles them properly.
  #
  #   A keyword parameter `cnx:`. This can be ignored if not needed, but
  #   #initialize must accept it. If used, it will contain a Jamf::Connection
  #   object, either the one from which the first param came, or the one
  #   to which we'll be validating or creating a new object
  #
  # - Define a #to_jamf method that returns a value that can be used
  #   in the data sent back to the API. Subclasses of JSONObject already
  #   have this requirement, and the value is a Hash.
  #
  #
  # Classes used in the class: value of an attribute definition are often
  # also subclasses of JSONObject (e.g. Jamf::Location) but do not have to be
  # as long as they conform to the standards above, e.g. Jamf::Timestamp.
  #
  # See also: [Data Validation](#data_validation) below.
  #
  #
  # identifier: \[Boolean or Symbol :primary]
  # -----------------
  # Only applicable to descendents of Jamf::CollectionResource
  #
  # If true, this value must be unique among all members of the class in
  # the JAMF, and can be used to look up objects.
  #
  # If the symbol :primary, this is the primary identifier, used in API
  # resource paths for this particular object. Usually its the :id attribute,
  # but for some objects may be some other attribute, e.g. for config-
  # profiles, it would be a uuid.
  #
  #
  # required: \[Boolean]
  # -----------------
  # If true, this attribute must be provided when creating a new local instance
  # and cannot be set to nil or empty
  #
  #
  # readonly: \[Boolean]
  # -----------------
  # If true, no setter method(s) will be created, and the value is not
  # sent to the API with #create or #update
  #
  #
  # multi: \[Boolean]
  # -----------------
  # When true, this value comes as a JSON array and its items are defined by
  # the 'class:' setting described above. The JSON array is used
  # to contstruct an attribute array of the correct kind of item.
  #
  # Example:
  # > When `class:` is Jamf::Computer::Reference the incoming JSON array
  # > of Hashes (computer references) will become an array of
  # > Jamf::Computer::Reference instances.
  #
  # The stored array is not directly accessible, the getter will return a
  # frozen duplicate of it.
  #
  # If not readonly, several setters are created:
  #
  # - a direct setter which takes an Array of 'class:', replacing the original
  # - a <attrname>\_append method, appends a new value to the array,
  #   aliased as `<<`
  # - a <attrname>\_prepend method, prepends a new value to the array
  # - a <attrname>\_insert method, inserts a new value to the array
  #   at the given index
  # - a <attrname>\_delete\_at method, deletes a value at the given index
  #
  # This protection of the underlying array is needed for two reasons:
  #
  # 1. so ruby-jss knows when changes are made and need to be saved
  # 2. so that validation can be performed on values added to the array.
  #
  #
  # enum: \[Constant -> Array ]
  # -----------------
  # This is a constant defined somewhere in the Jamf module. The constant
  # must contain an Array of values, usually Strings. You may or may not choose
  # to define the array members as constants themselves.
  #
  # Example:
  # > Attribute `:type` has enum: Jamf::ExtentionAttribute::DATA_TYPES
  # >
  # > The constant Jamf::ExtentionAttribute::DATA_TYPES is defined thus:
  # >
  # >      DATA_TYPE_STRING = 'STRING'.freeze
  # >      DATA_TYPE_INTEGER = 'INTEGER'.freeze
  # >      DATA_TYPE_DATE = 'DATE'.freeze
  # >
  # >      DATA_TYPES = [
  # >        DATA_TYPE_STRING,
  # >        DATA_TYPE_INTEGER,
  # >        DATA_TYPE_DATE,
  # >      ]
  # >
  # > When setting the type attribute via `#type = newval`,
  # > `Jamf::ExtentionAttribute::DATA_TYPES.include? newval` must be true
  # >
  #
  # Setters for attributes with an enum require that the new value is
  # a member of the array as seen above. When using such setters, If you defined
  # the array members as constants themselves, it is wise to use those rather
  # than a different but identical string, however either will work.
  # In other words, this:
  #
  #   my_ea.dataType = Jamf::ExtentionAttribute::DATA_TYPE_INTEGER
  #
  # is preferred over:
  #
  #   my_ea.dataType = 'INTEGER'
  #
  # since the second version creates a new string in memory, but the first uses
  # the one already stored in a constant.
  #
  # See also: [Data Validation](#data_validation) below.
  #
  # validator: \[Symbol]
  # -----------------
  # (ignored if readonly: is true, or if enum: is set)
  #
  # The symbol is the name of a Jamf::Validators class method used in the
  # setter to validate new values for this attribute. It only is used when
  # class: is :string, :integer, :boolean, and :float
  #
  # If omitted, the setter will take any value passed to it, which is
  # generally unwise.
  #
  # When the class: is an actual class, the setter will instantiate a new one
  # with the value to be set, and validation is handled by the class itself.
  #
  # Example:
  # > If the `class:` for an attrib named ':releaseDate' is class: Jamf::Timestamp
  # > then the setter method will look like this:
  # >
  # >      def releaseDate=(newval)
  # >        newval = Jamf::Timestamp.new newval unless newval.is_a? Jamf::Timestamp
  # >        # ^^^ This will validate newval
  # >        return if newval == @releaseDate
  # >        @releaseDate = newval
  # >        @need_to_update = true
  # >      end
  #
  # see also: [Data Validation](#data_validation) below.
  #
  #
  # aliases: \[Array of Symbols]
  # -----------------
  # Other names for this attribute. If provided, getters, and setters will
  # be made for all aliases. Should be used very sparingly.
  #
  # Attributes of class :boolean automatically have a getter alias ending with a '?'.
  #
  # filter_key: \[Boolean]
  # -----------------
  # For subclasses of CollectionResource, GETting the main endpoint will return
  # the entire collection. Some of these endpoints support RSQL filters to return
  # only those objects that match the filter. If this attribute can be used as
  # a field for filtering, set filter_key: to true, and filters will be used
  # where possible to optimize GET requests.
  #
  # Documenting your code
  # ---------------------
  # For documenting attributes with YARD, put this above each
  # attribute name key:
  #
  # ```
  #       # @!attribute <attrname>
  #       #   @param [Class] <Describe setter value if needed>
  #       #   @return [Class] <Describe value if needed>
  # ```
  #
  # If the value is readonly, remove the @param line, and add \[r], like this:
  #
  # ```
  #       # @!attribute [r] <attrname
  # ```
  #
  # for more info see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attribute
  #
  #
  # #### Sub-subclassing
  #
  # If you need to subclass a subclass of JSONObject, and the new subclass needs
  # to expand on the OBJECT_MODEL in its parent, then you must use Hash#merge
  # to combine them in the subclass. Here's an example of ComputerPrestage
  # which inherits from Prestage:
  #
  #       class ComputerPrestage < Jamf::Prestage
  #
  #          OBJECT_MODEL = superclass::OBJECT_MODEL.merge(
  #
  #                newAttr: {
  #                  [attr details]
  #                }
  #
  #            ).freeze
  #
  #
  # #### Data Validation \{#data_validation}
  #
  # Attributes that are not readonly are subject to data validation when values are
  # assigned. How that validation happens depends on the definition of the
  # attribute as described above. Validation failure will raise an exception,
  # usually Jamf::InvalidDataError.
  #
  # Only one value-validation is applied, depending on the attribute definition:
  #
  # - If the attribute is defined with a specific validator, the value is passed
  #   to that validator, and other validators are ignored
  #
  # - If the attribute is defined with an enum, the value must be
  #   a value of the enum.
  #
  # - If the attribute is defined as a :string, :integer, :float or :bool
  #   without an enum or validator, it is confirmed to be the correct type
  #
  # - If the attribute is defined to hold a :j_id, the Validate.j_id method
  #   is used, it must be an integer or integer-in-string
  #
  # - If the attribute is defined to hold a JAMF class, (e.g. Jamf::Timestamp)
  #   the class itself performs validation on the value when instantiated
  #   with the value.
  #
  # - Otherwise, the value is used unchanged with no validation
  #
  # Additionally:
  #
  # - If an attribute is an identifier, it must be unique in its class and
  #   API connection.
  #
  # - If an attribute is required, it may not be nil or empty
  #
  # - If an attribute is :multi, the value must be an array and each member
  #   value is validated individually
  #
  # ### Constructor / Instantiation {#constructor}
  #
  # The .new method should rarely (never?) be called directly for any JSONObject
  # class.
  #
  # The Resource classes are instantiated via the .fetch and .create methods.
  #
  # Other JSONObject classes are embedded inside the Resource classes
  # and are instantiated while parsing data from the API or by the setters for
  # the attributes holding them.
  #
  # When subclassing JSONObject, you can often just use the #initialize defined
  # here. You may want to override #initialize to accept different kinds of data
  # and if you do, you _must_:
  #
  # - Have an #initialize method that takes two parameters and performs
  #   validation using them:
  #
  #   1. A positional first parameter: the value used to create the instance
  #      Your method may accept any kind of value, as long as it can use it
  #      to create a valid object. At the very least it _must_ accept a Hash
  #      that comes from the API for this object. If you call `super` then
  #      that Hash must be passed.
  #
  #      For example, Jamf::GenericReference, which defines references to
  #      other resources, such as Buildings, can take a Hash containing the
  #      name: and id: of the building (as provided by the API), or can take
  #      just a name or id, or can take a Jamf::Building object.
  #
  #      The initialize method must perform validation as necessary and raise
  #      an exception if the data provided is not acceptable.
  #
  #   2. A keyword parameter `cnx:` containing a Jamf::Connection instance.
  #      This is the API connection through which this JSON object interacts
  #      with the appropriate Jamf Pro server. Usually this is used to validate
  #      the data recieved in the first positional parameter.
  #
  # ### Required Instance Methods
  #
  # Subclasses of JSONObject must have a #to_jamf method.
  # For most simple objects, the one defined in JSONObject will work as is.
  #
  # If you need to override it, it _must_
  #
  # - Return a Hash that can be used in the data sent back to the API.
  # - Not call #.to_json. All conversion to and from JSON happens in the
  #   Jamf::Connection class.
  #
  # @abstract
  #
  class JSONObject

    extend Jamf::BaseClass

    # Constants
    #####################################

    # These classes are used from JSON in the raw
    JSON_TYPE_CLASSES = %i[string integer float boolean].freeze

    # Public Class Methods
    #####################################

    # By default, JSONObjects (as a whole) are mutable,
    # although some attributes may not be (see OBJECT_MODEL in the JSONObject
    # docs)
    #
    # When an entire sublcass of JSONObject is read-only/immutable,
    # `extend Jamf::Immutable`, which will override this to return false.
    # Doing so will prevent any setters from being created for the subclass
    # and will cause Jamf::Resource.save to raise an error
    #
    def self.mutable?
      true
    end

    # An array of attribute names that are required when
    # making new instances
    # See the OBJECT_MODEL documentation in {Jamf::JSONObject}
    def self.required_attributes
      self::OBJECT_MODEL.select { |_attr, deets| deets[:required] }.keys
    end

    # Given a Symbol that might be an alias of a key fron OBJECT_MODEL
    # return the real key
    #
    # e.g. if OBJECT_MODEL has an entry like this:
    #   displayName: { aliases: [:name, :display_name] }
    # Then
    #   attr_key_for_alias(:name) and attr_key_for_alias(:display_name)
    # will return :displayName
    #
    # Returns nil if no such alias exists.
    #
    # @param als [Symbol] the alias to look up
    #
    # @return [Symbol, nil] The real object model key for the alias
    #
    def self.attr_key_for_alias(als)
      stop_if_base_class
      self::OBJECT_MODEL.each { |k, deets| return k if k == als || deets[:aliases].to_a.include?(als) }
      nil
    end

    # Private Class Methods
    #####################################

    # create getters and setters for subclasses of APIObject
    # based on their OBJECT_MODEL Hash.
    #
    ##############################
    def self.parse_object_model
      return if @object_model_parsed

      got_primary = false
      need_list_methods = ancestors.include?(Jamf::CollectionResource)

      self::OBJECT_MODEL.each do |attr_name, attr_def|

        # don't make one for :id, that one's hard-coded into CollectionResource
        create_list_methods(attr_name, attr_def) if need_list_methods && attr_def[:identifier] && attr_name != :id

        # there can be only one (primary ident)
        if attr_def[:identifier] == :primary
          raise Jamf::UnsupportedError, 'Two identifiers marked as :primary' if got_primary

          got_primary = true
        end

        create_getters attr_name, attr_def
        next if attr_def[:readonly]

        create_setters attr_name, attr_def if mutable?
      end #  do |attr_name, attr_def|

      @object_model_parsed = true
    end # parse_object_model
    private_class_method :parse_object_model

    # create a getter for an attribute, and any aliases needed
    ##############################
    def self.create_getters(attr_name, attr_def)
      # multi_value - only return a frozen dup, no direct editing of Array
      if attr_def[:multi]
        define_method(attr_name) do
          instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
          instance_variable_get("@#{attr_name}").dup.freeze
        end

      # single value
      else
        define_method(attr_name) { instance_variable_get("@#{attr_name}") }

      end

      # all booleans get predicate aliases
      define_predicates(attr_name) if attr_def[:class] == :boolean

      return unless attr_def[:aliases]

      # aliases
      attr_def[:aliases].each { |a| alias_method a, attr_name }
    end # create getters
    private_class_method :create_getters

    # create the default aliases for booleans
    ##############################
    def self.define_predicates(attr_name)
      alias_method("#{attr_name}?", attr_name)
    end

    # create setter(s) for an attribute, and any aliases needed
    ##############################
    def self.create_setters(attr_name, attr_def)
      # multi_value
      if attr_def[:multi]
        create_array_setters(attr_name, attr_def)
        return
      end

      # single value
      define_method("#{attr_name}=") do |new_value|
        new_value = validate_attr attr_name, new_value
        old_value = instance_variable_get("@#{attr_name}")
        return if new_value == old_value

        instance_variable_set("@#{attr_name}", new_value)
        note_unsaved_change attr_name, old_value
      end # define method

      return unless attr_def[:aliases]

      # setter aliases
      attr_def[:aliases].each { |a| alias_method "#{a}=", "#{attr_name}=" }
    end # create_setters
    private_class_method :create_setters

    ##############################
    def self.create_array_setters(attr_name, attr_def)
      create_full_array_setters(attr_name, attr_def)
      create_append_setters(attr_name, attr_def)
      create_prepend_setters(attr_name, attr_def)
      create_insert_setters(attr_name, attr_def)
      create_delete_at_setters(attr_name, attr_def)
      create_delete_if_setters(attr_name, attr_def)
    end # def create_multi_setters
    private_class_method :create_array_setters

    # The  attr=(newval) setter method for array values
    ##############################
    def self.create_full_array_setters(attr_name, attr_def)
      define_method("#{attr_name}=") do |new_value|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        raise Jamf::InvalidDataError, 'Value must be an Array' unless new_value.is_a? Array

        new_value.map! { |item| validate_attr attr_name, item }
        old_value = instance_variable_get("@#{attr_name}")
        return if new_value == old_value

        instance_variable_set("@#{attr_name}", new_value)
        note_unsaved_change attr_name, old_value
      end # define method

      return unless attr_def[:aliases]

      attr_def[:aliases].each { |al| alias_method "#{al}=", "#{attr_name}=" }
    end # create_full_array_setter
    private_class_method :create_full_array_setters

    # The  attr_append(newval) setter method for array values
    ##############################
    def self.create_append_setters(attr_name, attr_def)
      define_method("#{attr_name}_append") do |new_value|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        new_value = validate_attr attr_name, new_value
        old_array = instance_variable_get("@#{attr_name}").dup
        instance_variable_get("@#{attr_name}") << new_value
        note_unsaved_change attr_name, old_array
      end # define method

      # always have a << alias
      alias_method "#{attr_name}<<", "#{attr_name}_append"

      return unless attr_def[:aliases]

      attr_def[:aliases].each do |al|
        alias_method "#{al}_append", "#{attr_name}_append"
        alias_method "#{al}<<", "#{attr_name}_append"
      end
    end # create_append_setters
    private_class_method :create_append_setters

    # The  attr_prepend(newval) setter method for array values
    ##############################
    def self.create_prepend_setters(attr_name, attr_def)
      define_method("#{attr_name}_prepend") do |new_value|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        new_value = validate_attr attr_name, new_value
        old_array = instance_variable_get("@#{attr_name}").dup
        instance_variable_get("@#{attr_name}").unshift new_value
        note_unsaved_change attr_name, old_array
      end # define method

      return unless attr_def[:aliases]

      attr_def[:aliases].each { |al| alias_method "#{al}_prepend", "#{attr_name}_prepend" }
    end # create_prepend_setters
    private_class_method :create_prepend_setters

    # The  attr_insert(index, newval) setter method for array values
    def self.create_insert_setters(attr_name, attr_def)
      define_method("#{attr_name}_insert") do |index, new_value|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        new_value = validate_attr attr_name, new_value
        old_array = instance_variable_get("@#{attr_name}").dup
        instance_variable_get("@#{attr_name}").insert index, new_value
        note_unsaved_change attr_name, old_array
      end # define method

      return unless attr_def[:aliases]

      attr_def[:aliases].each { |al| alias_method "#{al}_insert", "#{attr_name}_insert" }
    end # create_insert_setters
    private_class_method :create_insert_setters

    # The  attr_delete_at(index) setter method for array values
    ##############################
    def self.create_delete_at_setters(attr_name, attr_def)
      define_method("#{attr_name}_delete_at") do |index|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        old_array = instance_variable_get("@#{attr_name}").dup
        deleted = instance_variable_get("@#{attr_name}").delete_at index
        note_unsaved_change attr_name, old_array if deleted
      end # define method

      return unless attr_def[:aliases]

      attr_def[:aliases].each { |al| alias_method "#{al}_delete_at", "#{attr_name}_delete_at" }
    end # create_insert_setters
    private_class_method :create_delete_at_setters

    # The  attr_delete_at(index) setter method for array values
    ##############################
    def self.create_delete_if_setters(attr_name, attr_def)
      define_method("#{attr_name}_delete_if") do |index, &block|
        instance_variable_set("@#{attr_name}", []) unless instance_variable_get("@#{attr_name}").is_a?(Array)
        old_array = instance_variable_get("@#{attr_name}").dup
        instance_variable_get("@#{attr_name}").delete_if &block
        note_unsaved_change attr_name, old_array if old_array != instance_variable_get("@#{attr_name}")
      end # define method

      return unless attr_def[:aliases]

      attr_def[:aliases].each { |al| alias_method "#{al}_delete_if", "#{attr_name}_delete_if" }
    end # create_insert_setters
    private_class_method :create_delete_if_setters

    # Used by auto-generated setters and .create to validate new values.
    #
    # returns a valid value or raises an exception
    #
    # This method only validates single values. When called from multi-value
    # setters, it is used for each value individually.
    #
    # @param attr_name[Symbol], a top-level key from OBJECT_MODEL for this class
    #
    # @param value [Object] the value to validate for that attribute.
    #
    # @return [Object] The validated, possibly converted, value.
    #
    def self.validate_attr(attr_name, value, cnx: Jamf.cnx)
      attr_def = self::OBJECT_MODEL[attr_name]
      raise ArgumentError, "Unknown attribute: #{attr_name} for #{self} objects" unless attr_def

      # validate our value, which will raise an error or
      # convert the value to the required type.
      value = validate_attr_value(attr_def, value, cnx: Jamf.cnx)

      # if this is required, it can't be nil or empty
      if attr_def[:required]
        raise Jamf::MissingDataError, "Required attribute '#{attr_name}:' may not be nil or empty" if value.to_s.empty?
      end

      # if this is an identifier, it must be unique
      Jamf::Validate.doesnt_exist(value, self, attr_name, cnx: cnx) if attr_def[:identifier] && superclass == Jamf::CollectionResource

      value
    end # validate_attr(attr_name, value)
    private_class_method :validate_attr

    # Validate an attribute value itself, as part of validating the attribute
    # as a whole. Only one validation is applied, which one is
    # determined in the order described in the #### Data Validation section
    # of the JSONObject class comments
    #
    # See .validate_attr, which calls this
    def self.validate_attr_value(attr_def, value, cnx: Jamf.cnx)
      # by specified Validate method
      if attr_def[:validator]
        Jamf::Validate.send attr_def[:validator], value

      # by enum, must be a value of the enum
      elsif attr_def[:enum]
        Jamf::Validate.in_enum(value, attr_def[:enum])

      # By json primative type - pass to the matching validate method
      elsif JSON_TYPE_CLASSES.include? attr_def[:class]
        Jamf::Validate.send attr_def[:class], value

      # a JPAPI id?
      elsif attr_def[:class] == :j_id
        Jamf::Validate.j_id value

      # by Class, the class validates the value passed with .new
      elsif attr_def[:class].is_a? Class
        klass = attr_def[:class]
        value.is_a?(klass) ? value : klass.new(value, cnx: cnx)

      # raw, no validation, should be rare
      else
        value
      end # if
    end
    private_class_method :validate_attr_value

    # Constructor
    #####################################

    # Make an instance. Data comes from the API
    #
    # @param data[Hash] the data for constructing a new object.
    # @param cnx[Jamf::Connection] the API connection for the object
    #
    def initialize(data, cnx: Jamf.cnx)
      raise Jamf::InvalidDataError, 'Invalid JSONObject data - must be a Hash' unless data.is_a? Hash

      @cnx = cnx
      @unsaved_changes = {} if self.class.mutable?

      creating = data.delete :creating_from_create

      if creating
        self.class::OBJECT_MODEL.keys.each do |attr_name|
          next unless data.key? attr_name
          # use our setters for each value so that they are in the unsaved changes
          send "#{attr_name}=", data[attr_name]
        end
        return
      end

      parse_init_data data
    end # init

    # Instance Methods
    #####################################

    # a hash of all unsaved changes, including embedded JSONObjects
    #
    def unsaved_changes
      return {} unless self.class.mutable?

      changes = @unsaved_changes.dup

      self.class::OBJECT_MODEL.each do |attr_name, attr_def|
        # skip non-Class attrs
        next unless attr_def[:class].is_a? Class

        # the current value of the thing, e.g. a Location
        # which may have unsaved changes
        value = instance_variable_get "@#{attr_name}"

        # skip those that don't have any changes
        next unless value.respond_to? :unsaved_changes?
        attr_changes = value.unsaved_changes
        next if attr_changes.empty?

        # add the sub-changes to ours
        changes[attr_name] = attr_changes
      end
      changes[:ext_attrs] = ext_attrs_unsaved_changes if self.class.include? Jamf::Extendable
      changes
    end

    # return true if we or any of our attributes have unsaved changes
    #
    def unsaved_changes?
      return false unless self.class.mutable?

      !unsaved_changes.empty?
    end

    def clear_unsaved_changes
      return unless self.class.mutable?

      unsaved_changes.keys.each do |attr_name|
        attrib_val = instance_variable_get "@#{attr_name}"
        if self.class::OBJECT_MODEL[attr_name][:multi]
          attrib_val.each { |item| item.send :clear_unsaved_changes if item.respond_to? :clear_unsaved_changes }
        elsif attrib_val.respond_to? :clear_unsaved_changes
          attrib_val.send :clear_unsaved_changes
        end
      end
      ext_attrs_clear_unsaved_changes if self.class.include? Jamf::Extendable
      @unsaved_changes = {}
    end

    # @return [Hash] The data to be sent to the API, as a Hash
    #  to be converted to JSON by the Jamf::Connection
    #
    def to_jamf
      data = {}
      self.class::OBJECT_MODEL.each do |attr_name, attr_def|

        raw_value = instance_variable_get "@#{attr_name}"

        # If its a multi-value attribute, process it and  go on
        if attr_def[:multi]
          data[attr_name] = multi_to_jamf(raw_value, attr_def)
          next
        end

        # if its a single-value object, process it and go on.
        cooked_value = single_to_jamf(raw_value, attr_def)
        # next if cooked_value.nil? # ignore nil
        data[attr_name] = cooked_value
      end # unsaved_changes.each
      data
    end

    # Only works for PATCH endpoints.
    #
    # @return [Hash] The changes that need to be sent to the API, as a Hash
    #  to be converted to JSON by the Jamf::Connection
    #
    def to_jamf_changes_only
      return unless self.class.mutable?

      data = {}
      unsaved_changes.each do |attr_name, changes|
        attr_def = self.class::OBJECT_MODEL[attr_name]

        # readonly attributes can't be changed
        next if attr_def[:readonly]

        # here's the new value for this attribute
        raw_value = changes[:new]

        # If its a multi-value attribute, process it and  go on
        if attr_def[:multi]
          data[attr_name] = multi_to_jamf(raw_value, attr_def)
          next
        end

        # if its a single-value object, process it and go on.
        cooked_value = single_to_jamf(raw_value, attr_def)
        next if cooked_value.nil? # ignore nil

        data[attr_name] = cooked_value
      end # unsaved_changes.each
      data
    end

    # Print the JSON version of the to_jamf outout
    # mostly for debugging/troubleshooting
    def pretty_jamf_json
      puts JSON.pretty_generate(to_jamf)
    end

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

    # Private Instance Methods
    #####################################
    private

    def note_unsaved_change(attr_name, old_value)
      return unless self.class.mutable?

      new_val = instance_variable_get "@#{attr_name}"
      if @unsaved_changes[attr_name]
        @unsaved_changes[attr_name][:new] = new_val
      else
        @unsaved_changes[attr_name] = { old: old_value, new: new_val }
      end
    end

    # take data from the API and populate an our instance attributes
    #
    # @param data[Hash] The parsed API JSON data for this instance
    #
    # @return [void]
    #
    def parse_init_data(data)
      self.class::OBJECT_MODEL.each do |attr_name, attr_def|
        value =
          if attr_def[:multi]
            raw_array = data[attr_name]&.dup
            raw_array ||= []
            raw_array.map! { |v| parse_single_init_value v, attr_name, attr_def }
          else
            parse_single_init_value data[attr_name], attr_name, attr_def
          end
        instance_variable_set "@#{attr_name}", value
      end # OBJECT_MODEL.each
    end # parse_init_data(data)

    # Parse an individual value from the API into an
    # attribute or a member of a multi attribute
    # Description of #parse_single_init_value
    #
    # @param api_value [Object] The parsed JSON value from the API
    # @param attr_name [Symbol] The attribute we're processing
    # @param attr_def [Hash] The attribute definition
    #
    # @return [Object] The storable value.
    #
    def parse_single_init_value(api_value, attr_name, attr_def)
      # we do get nils from the API, and they should stay nil
      return nil if api_value.nil?

      # an enum value
      if attr_def[:enum]
        parse_enum_value(api_value, attr_name, attr_def)

      # a Class value
      elsif attr_def[:class].class == Class
        attr_def[:class].new api_value, cnx: @cnx

      # a :j_id value. See the docs for OBJECT_MODEL in Jamf::JSONObject
      elsif attr_def[:class] == :j_id
        api_value.to_s

      # a JSON value
      else
        api_value
      end # if attr_def[:class].class
    end

    # Parse an api value into an attribute with an enum
    #
    # @param (see parse_single_init_value)
    # @return (see parse_single_init_value)
    #
    def parse_enum_value(api_value, attr_name, attr_def)
      raise Jamf::InvalidDataError, "#{api_value} is not in the enum for attribute #{attr_name}" unless attr_def[:enum].include? api_value

      api_value
    end

    # call to_jamf on a single value
    #
    def single_to_jamf(raw_value, attr_def)
      # if the attrib class is a  Class,
      # call its changes_to_jamf or to_jamf method
      if attr_def[:class].is_a? Class
        data = raw_value.to_jamf
        data.is_a?(Hash) && data.empty? ? nil : data

      # otherwise, use the value as-is
      else
        raw_value
      end
    end

    # Call to_jamf on an array value
    #
    def multi_to_jamf(raw_array, attr_def)
      raw_array ||= []
      raw_array.map { |raw_value| single_to_jamf(raw_value, attr_def) }.compact
    end

    # wrapper for class method
    def validate_attr(attr_name, value)
      self.class.send :validate_attr, attr_name, value, cnx: @cnx
    end

  end # class JSONObject

end # module JAMF
