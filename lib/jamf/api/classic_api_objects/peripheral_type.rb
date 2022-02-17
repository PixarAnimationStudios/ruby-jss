### Copyright 2020 Pixar

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

  #####################################
  ### Classes
  #####################################

  ###
  ### A peripheral_type in the JSS.
  ###
  ### A PeripheralType (as opposed to an individual {Jamf::Peripheral}) is just an id, a name, and an Array of
  ### Hashes describing the fields of data to be stored for peripherals of this type.
  ###
  ### See {#fields} for a desciption of how field definitions are stored.
  ###
  ### For manipulating the fields, see {#fields=}, {#set_field}, {#append_field}, {#prepend_field}, {#insert_field}, and {#delete_field}
  ###
  ### @see Jamf::APIObject
  ###
  class PeripheralType  < Jamf::APIObject

    #####################################
    ### MixIns
    #####################################

    include Jamf::Creatable
    include Jamf::Updatable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "peripheraltypes"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :peripheral_types

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :peripheral_type


    ### field types can be one of these, either String or Symbol
    FIELD_TYPES = [:text, :menu]

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 11

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Instance Methods
    #####################################

    ###
    ### Initialize
    ###
    def initialize (args = {})

      super

      @fields = []
      if @init_data[:fields]
        @init_data[:fields].each{ |f|  @fields[f[:order]] = f }
      end
    end # initialize

    ### The definitions of the fields stored for this peripheral type.
    ###
    ### Each Hash defines a field of data to store. The keys are:
    ### - :name, String, the name of the field
    ### - :type, String or Symbol, the kind of data to be stored in the field, either :text or :menu
    ### - :choices, Array of Strings - if type is :menu, these are the menu choices.
    ### - :order, the one-based index of this field amongst it's peers.
    ###
    ### Since Arrays are zero-based, and the field order is one-based, keeping
    ### a nil at the front of the Array will keep the :order number in sync with the
    ### Array index of each field definition. This is done automatically by the field-editing
    ### methods: {#fields=}, {#set_field}, {#append_field}, {#prepend_field}, {#insert_field},
    ### and {#delete_field}.
    ###
    ### So the Array from the API comes like this:
    ###   [ {:type=>"text", :order=>1, :choices=>[], :name=>"make"},
    ###     {:type=>"text", :order=>2, :choices=>[], :name=>"model"},
    ###     {:type=>"text", :order=>3, :choices=>[], :name=>"family"},
    ###     {:type=>"text", :order=>4, :choices=>[], :name=>"serialnum"} ]
    ### But will be stored in a PeripheralType instance like this:
    ###   [ nil,
    ###     {:type=>"text", :order=>1, :choices=>[], :name=>"make"},
    ###     {:type=>"text", :order=>2, :choices=>[], :name=>"model"},
    ###     {:type=>"text", :order=>3, :choices=>[], :name=>"family"},
    ###     {:type=>"text", :order=>4, :choices=>[], :name=>"serialnum"} ]
    ###
    ### therefore
    ###   myPerifType.fields[2]
    ### will get you the second field, which has :order => 2.
    ###
    ### @return [Array<Hash>] The field definitions
    ###
    def fields
      @fields
    end

    ###
    ### Replace the entire Array of field definitions.
    ### The :order of each will be set based on the indexes of the
    ### Array provided.
    ###
    ### @param new_fields[Array<Hash>] the new field definitions
    ###
    ### @return [void]
    ###
    def fields= (new_fields)
      unless new_fields.kind_of? Array and  new_fields.reject{|c| c.kind_of? Hash }.empty?
        raise Jamf::InvalidDataError, "Argument must be an Array of Hashes."
      end
      raise "A peripheral type can have a maximmum of 20 fields"  if new_fields.count > 20
      new_fields.each{ |f| field_ok? f }
      @fields = new_fields
      order_fields
      @need_to_update = true
    end

    ###
    ### Replace the details of one specific field.
    ###
    ### The order must already exist. Otherwise use
    ### {#append_field}, {#prepend_field}, or {#insert_field}
    ###
    ### @param order[Integer] which field are we replacing?
    ###
    ### @param field[Hash] the new field data
    ###
    ### @return [void]
    ###
    def set_field(order, field = {})
      raise Jamf::NoSuchItemError, "No field with number '#{order}'. Use #append_field, #prepend_field, or #insert_field" unless @fields[order]
      field_ok? field
      @fields[order] = field
      @need_to_update = true
    end

    ###
    ### Add a new field to the end of the field list
    ###
    ### @param field[Hash] the new field data
    ###
    ### @return [void]
    ###
    def append_field(field = {})
      field_ok? field
      @fields << field
      order_fields
      @need_to_update = true
    end

    ###
    ### Add a new field to the beginning of the field list
    ###
    ### @param field[Hash] the new field data
    ###
    ### @return [void]
    ###
    def prepend_field(field = {})
      field_ok? field
      @fields.unshift field
      order_fields
      @need_to_update = true
    end

    ###
    ### Add a new field to the middle of the fields Array.
    ###
    ### @param order[Integer] where does the new field go?
    ###
    ### @param field[Hash] the new field data
    ###
    ### @return [void]
    ###
    def insert_field(order,field = {})
      field_ok? field
      @fields.insert((order -1), field)
      order_fields
      @need_to_update = true
    end

    ###
    ### Remove a field from the array of fields.
    ###
    ### @param order[Integer] which field to remove?
    ###
    ### @return [void]
    ###
    def delete_field(order)
      if @fields[order]
        raise Jamf::MissingDataError, "Fields can't be empty" if @fields.count == 1
        @fields.delete_at index
        order_fields
        @need_to_update = true
      end
    end



    ##############################
    ### private methods
    ##############################
    private

    ###
    ### is a Hash of field data OK for use in the JSS?
    ### Return true or raise an exception
    ###
    def field_ok?(field)
      raise Jamf::InvalidDataError, "Field elements must be hashes with :name, :type, and possibly :choices" unless field.kind_of? Hash
      raise Jamf::InvalidDataError, "Fields require names" if field[:name].to_s.empty?
      raise Jamf::InvalidDataError, "Fields :type must be one of: :#{FIELD_TYPES.join(', :')}" unless FIELD_TYPES.include? field[:type].to_sym

      if field[:type].to_sym == :menu
        unless field[:choices].kind_of? Array and  field[:choices].reject{|c| c.kind_of? String}.empty?
          raise Jamf::InvalidDataError, "Choices for menu fields must be an Array of Strings"
        end # unless
      else
        field[:choices] = []
      end # if type -- menu
      true
    end # def field ok?

    ###
    ### Close up gaps in the field order, and make each field's :order match it's array index
    ###
    def order_fields
      @fields.compact!
      @fields.each_index{|i| @fields[i][:order] = i+1}
      @fields.unshift nil
    end


    ###
    ###
    ###
    def rest_xml
      order_fields
      doc = REXML::Document.new APIConnection::XML_HEADER
      pkg = doc.add_element RSRC_OBJECT_KEY.to_s
      pkg.add_element('id').text = @id
      pkg.add_element('name').text = @name
      fields = pkg.add_element 'fields'

      flds =  @fields.compact
      flds.each_index do |i|
        field = fields.add_element 'field'
        field.add_element('order').text =flds[i][:order]
        field.add_element('name').text = flds[i][:name]
        field.add_element('type').text = flds[i][:type].to_s
        choices = field.add_element('choices')
        unless flds[i][:choices].empty?
          flds[i][:choices].each{|c| choices.add_element('choice').text = c}
        end
      end # each index do i
      return doc.to_s
    end # rest xml

  end # class Peripheral
end # module
