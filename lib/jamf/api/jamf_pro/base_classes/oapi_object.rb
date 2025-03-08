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

# The module
module Jamf

  # Classes
  #####################################

  # The parent class for all objects auto-generated in the Jamf::OAPISchemas
  # module
  # more docs to come
  class OAPIObject

    include Comparable

    # Public Class Methods
    #####################################

    # By default,OAPIObjects (as a whole) are mutable,
    # although some attributes may not be (see OAPI_PROPERTIES in the JSONObject
    # docs)
    #
    # When an entire sublcass of OAPIObject is read-only/immutable,
    # `extend Jamf::Immutable`, which will override this to return false.
    # Doing so will prevent any setters from being created for the subclass
    # and will cause Jamf::Resource.save to raise an error
    #
    def self.mutable?
      !singleton_class.ancestors.include? Jamf::Immutable
    end

    # An array of attribute names that are required when
    # making new instances - they cannot be nil, but may be empty.
    #
    # See the OAPI_PROPERTIES documentation in {Jamf::OAPIObject}
    def self.required_attributes
      self::OAPI_PROPERTIES.select { |_attr, deets| deets[:required] }.keys
    end

    # have we already parsed our OAPI_PROPERTIES? If so,
    # we shoudn't do it again, an this can be used to check
    def self.oapi_properties_parsed?
      @oapi_properties_parsed
    end

    # create getters and setters for subclasses of APIObject
    # based on their OAPI_PROPERTIES Hash.
    #
    # This method can't be private, cuz we want to call it from a
    # Zeitwerk callback when subclasses are loaded.
    ##############################
    def self.parse_oapi_properties
      # only do this once
      return if @oapi_properties_parsed

      # only if this constant is defined
      return unless defined? self::OAPI_PROPERTIES

      # TODO: is the concept of 'primary' needed anymore?
      got_primary = false

      self::OAPI_PROPERTIES.each do |attr_name, attr_def|
        Jamf.load_msg "Creating getters and setters for attribute '#{attr_name}' of #{self}"

        # see above comment
        # don't make one for :id, that one's hard-coded into CollectionResource
        # create_list_methods(attr_name, attr_def) if need_list_methods && attr_def[:identifier] && attr_name != :id

        # there can be only one (primary ident)
        if attr_def[:identifier] == :primary
          raise Jamf::UnsupportedError, 'Two identifiers marked as :primary' if got_primary

          got_primary = true
        end

        # create getter unless the attr is write only
        create_getters attr_name, attr_def unless attr_def[:writeonly]

        # Don't crete setters for readonly attrs, or immutable objects
        next if attr_def[:readonly] || !mutable?

        create_setters attr_name, attr_def
      end #  do |attr_name, attr_def|

      if defined? self::OBJECT_NAME_ATTR
        alias_method(:name, self::OBJECT_NAME_ATTR)
        alias_method('name=', "#{self::OBJECT_NAME_ATTR}=")
      end

      @oapi_properties_parsed = true
    end # parse_object_model

    # Private Class Methods
    #####################################

    # create a getter for an attribute, and any aliases needed
    ##############################
    def self.create_getters(attr_name, attr_def)
      # multi_value - only return a frozen dup, no direct editing of the Array
      if attr_def[:multi]
        define_method(attr_name) do
          initialize_multi_value_attr_array attr_name

          instance_variable_get("@#{attr_name}").dup.freeze
        end

      # single value
      else
        define_method(attr_name) { instance_variable_get("@#{attr_name}") }
      end

      # all booleans get predicate ? aliases
      alias_method("#{attr_name}?", attr_name) if attr_def[:class] == :boolean
    end # create getters
    private_class_method :create_getters

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
    end # create_setters
    private_class_method :create_setters

    ##############################
    def self.create_array_setters(attr_name, attr_def)
      create_full_array_setters(attr_name, attr_def)
      create_append_setters(attr_name, attr_def)
      create_prepend_setters(attr_name, attr_def)
      create_insert_setters(attr_name, attr_def)
      create_delete_setters(attr_name, attr_def)
      create_delete_at_setters(attr_name, attr_def)
      create_delete_if_setters(attr_name, attr_def)
    end # def create_multi_setters
    private_class_method :create_array_setters

    # The  attr=(newval) setter method for array values
    ##############################
    def self.create_full_array_setters(attr_name, attr_def)
      define_method("#{attr_name}=") do |new_value|
        initialize_multi_value_attr_array attr_name

        raise Jamf::InvalidDataError, "Value for '#{attr_name}=' must be an Array" unless new_value.is_a? Array

        # validate each item of the new array
        new_value.map! { |item| validate_attr attr_name, item }

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_value, attr_def: attr_def, attr_name: attr_name)

        old_value = instance_variable_get("@#{attr_name}")
        return if new_value == old_value

        instance_variable_set("@#{attr_name}", new_value)
        note_unsaved_change attr_name, old_value
      end # define method

      nil unless attr_def[:aliases]
    end # create_full_array_setter
    private_class_method :create_full_array_setters

    # The  attr_append(newval) setter method for array values
    ##############################
    def self.create_append_setters(attr_name, attr_def)
      define_method("#{attr_name}_append") do |new_value|
        initialize_multi_value_attr_array attr_name

        new_value = validate_attr attr_name, new_value

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        new_array << new_value

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method

      # always have a << alias
      alias_method "#{attr_name}<<", "#{attr_name}_append"
    end # create_append_setters
    private_class_method :create_append_setters

    # The  attr_prepend(newval) setter method for array values
    ##############################
    def self.create_prepend_setters(attr_name, attr_def)
      define_method("#{attr_name}_prepend") do |new_value|
        initialize_multi_value_attr_array attr_name

        new_value = validate_attr attr_name, new_value

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        new_array.unshift new_value

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method
    end # create_prepend_setters
    private_class_method :create_prepend_setters

    # The  attr_insert(index, newval) setter method for array values
    def self.create_insert_setters(attr_name, attr_def)
      define_method("#{attr_name}_insert") do |index, new_value|
        initialize_multi_value_attr_array attr_name

        new_value = validate_attr attr_name, new_value

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        new_array.insert index, new_value

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method
    end # create_insert_setters
    private_class_method :create_insert_setters

    # The  attr_delete(val) setter method for array values
    ##############################
    def self.create_delete_setters(attr_name, attr_def)
      define_method("#{attr_name}_delete") do |val|
        initialize_multi_value_attr_array attr_name

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        new_array.delete val
        return if old_array == new_array

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method
    end # create_insert_setters
    private_class_method :create_delete_setters

    # The  attr_delete_at(index) setter method for array values
    ##############################
    def self.create_delete_at_setters(attr_name, attr_def)
      define_method("#{attr_name}_delete_at") do |index|
        initialize_multi_value_attr_array attr_name

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        deleted = new_array.delete_at index
        return unless deleted

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method
    end # create_insert_setters
    private_class_method :create_delete_at_setters

    # The  attr_delete_if(block) setter method for array values
    ##############################
    def self.create_delete_if_setters(attr_name, attr_def)
      define_method("#{attr_name}_delete_if") do |&block|
        initialize_multi_value_attr_array attr_name

        new_array = instance_variable_get("@#{attr_name}")
        old_array = new_array.dup
        new_array.delete_if(&block)
        return if old_array == new_array

        # now validate the array as a whole for oapi constraints
        Jamf::Validate.validate_array_constraints(new_array, attr_def: attr_def, attr_name: attr_name)

        note_unsaved_change attr_name, old_array
      end # define method
    end # create_insert_setters
    private_class_method :create_delete_if_setters

    # Used by auto-generated setters and .create to validate new values.
    #
    # returns a valid value or raises an exception
    #
    # This method only validates single values. When called from multi-value
    # setters, it is used for each value individually.
    #
    # @param attr_name[Symbol], a top-level key from OAPI_PROPERTIES for this class
    #
    # @param value [Object] the value to validate for that attribute.
    #
    # @return [Object] The validated, possibly converted, value.
    #
    def self.validate_attr(attr_name, value)
      attr_def = self::OAPI_PROPERTIES[attr_name]
      raise ArgumentError, "Unknown attribute: #{attr_name} for #{self} objects" unless attr_def

      # validate the value based on the OAPI definition.
      Jamf::Validate.oapi_attr value, attr_def: attr_def, attr_name: attr_name

      # if this is an identifier, it must be unique
      # TODO: move this to colloection resouce code
      # Jamf::Validate.doesnt_exist(value, self, attr_name, cnx: cnx) if attr_def[:identifier] && superclass == Jamf::CollectionResource
    end # validate_attr(attr_name, value)

    # Attributes
    #####################################

    # the raw hash from which this object was constructed
    # @return [Hash]
    attr_reader :init_data

    # Constructor
    #####################################

    # Make an instance. Data comes from the API
    #
    # @param data[Hash] the data for constructing a new object.
    #
    def initialize(data)
      @init_data = data

      # creating a new one via ruby-jss, not fetching one from the API
      creating = data.delete :creating_from_create if data.is_a?(Hash)

      if creating
        self.class::OAPI_PROPERTIES.each_key do |attr_name|
          # we'll enforce required values when we save
          next unless data.key? attr_name

          # use our setters for each value so that they are validated, and
          # in the unsaved changes list
          send "#{attr_name}=", data[attr_name]
        end
        return
      end

      parse_init_data data
    end # init

    # Instance Methods
    #####################################

    # Are objects of this class mutable?
    # @see the class method in OAPIObject
    def mutable?
      self.class.mutable?
    end

    # a hash of all unsaved changes
    #
    def unsaved_changes
      return {} unless self.class.mutable?

      @unsaved_changes ||= {}

      changes = @unsaved_changes.dup

      self.class::OAPI_PROPERTIES.each do |attr_name, attr_def|
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
        if self.class::OAPI_PROPERTIES[attr_name][:multi]
          attrib_val.each { |item| item.send :clear_unsaved_changes if item.respond_to? :clear_unsaved_changes }
        elsif attrib_val.respond_to? :clear_unsaved_changes
          attrib_val.send :clear_unsaved_changes
        end
      end
      ext_attrs_clear_unsaved_changes if self.class.include? Jamf::Extendable
      @unsaved_changes = {}
    end

    # @return [Hash] The data to be sent to the API, as a Hash
    #  to be converted to JSON before sending to the JPAPI
    #
    def to_jamf
      jamf_data = {}
      self.class::OAPI_PROPERTIES.each do |attr_name, attr_def|
        raw_value = instance_variable_get "@#{attr_name}"
        jamf_data[attr_name] = attr_def[:multi] ? multi_to_jamf(raw_value, attr_def) : single_to_jamf(raw_value, attr_def)
      end
      jamf_data
    end

    # @return [String] the JSON to be sent to the API for this
    #   object
    #
    def to_json(*_args)
      to_jamf.to_json
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
      vars.delete :@init_data
      vars
    end

    # Comparable by the sha1 hash of our properties.
    # Subclasses or mixins may override this in ways that make
    # sense for them
    # TODO: Using this may not make sense for most objects, esp
    # when comparing objects instantiated from Create vs those
    # from Fetch.
    def <=>(other)
      sha1_hash <=> other.sha1_hash
    end

    # The SHA1 hash of all the values of our properties as defined in the
    # OAPI schema
    def sha1_hash
      Digest::SHA1.hexdigest(to_jamf.to_s)
    end

    # Private Instance Methods
    #####################################
    private

    # Initialize a multi-values attribute as an empty array
    # if it hasn't been created yet
    def initialize_multi_value_attr_array(attr_name)
      return if instance_variable_get("@#{attr_name}").is_a? Array

      instance_variable_set("@#{attr_name}", [])
    end

    def note_unsaved_change(attr_name, old_value)
      return unless self.class.mutable?

      @unsaved_changes ||= {}
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
      self.class::OAPI_PROPERTIES.each do |attr_name, attr_def|
        if data.is_a? Hash
          unless data.key? attr_name
            raise Jamf::InvalidDataError, "Initialization must include the key '#{attr_name}:'" if attr_def[:required]

            next
          end

          value =
            if attr_def[:multi]
              raw_array = data[attr_name] || []
              raw_array.map { |v| parse_single_init_value v, attr_name, attr_def }
            else
              parse_single_init_value data[attr_name], attr_name, attr_def
            end
        else # not a Hash, this is a single-value object, so the data is the value
          value = data
        end

        instance_variable_set "@#{attr_name}", value
      end # OAPI_PROPERTIES.each
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
      elsif attr_def[:class].instance_of? Class
        attr_def[:class].new api_value

      # a :j_id value. See the docs for OAPI_PROPERTIES in Jamf::OAPIObject
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
      Jamf::Validate.in_enum api_value, enum: attr_def[:enum],
                                        msg: "#{api_value} is not in the allowed values for attribute #{attr_name}. Must be one of: #{attr_def[:enum].join ', '}"
    end

    # call to_jamf on a single value if it knows that method
    #
    def single_to_jamf(raw_value, _attr_def)
      raw_value.respond_to?(:to_jamf) ? raw_value.to_jamf : raw_value
    end

    # Call to_jamf on an array value
    #
    def multi_to_jamf(raw_array, attr_def)
      raw_array ||= []
      raw_array.map { |raw_value| single_to_jamf(raw_value, attr_def) }.compact
    end

    # wrapper for class method
    def validate_attr(attr_name, value)
      self.class.validate_attr attr_name, value
    end

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

    # A meaningful string representation of this object
    #
    # @return [String]
    #
    def to_s
      inspect
    end

  end # class JSONObject

end # module JAMF
