### Copyright 2017 Pixar

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

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Classes
  #####################################

  ###
  ### A peripheral in the JSS
  ###
  ### @see JSS::APIObject
  ###
  class Peripheral  < JSS::APIObject

    #####################################
    ### MixIns
    #####################################

    include JSS::Creatable
    include JSS::Updatable

    ### periphs have a purchasing subset
    include JSS::Purchasable

    ### periphs have a location subset, which will be
    ### stored in primary attributes.
    include JSS::Locatable

    ### periphs can take uploaded files.
    include JSS::Uploadable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "peripherals"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :peripherals

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :peripheral

    ### these keys, as well as :id and :name, are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:type, :bar_code_1, :computer_id ]


    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################

    ### @return [String] the type of peripheral
    attr_reader :type

    ### @return [String] the "bar code 1" value
    attr_reader :bar_code_1


    ### @return [String] the "bar code 2" value
    attr_reader :bar_code_2


    ### @return [Integer] the id number of the computer to which  this periph is connected
    attr_reader :computer_id

    #####################################
    ### Instance Methods
    #####################################

    ###
    ### @see APIObject
    ###
    def initialize (args = {})

      ### periphs don't really have names, and the JSS module list method for
      ### periphs gives the computer_id as the name, so give it a temp
      ### name of "-1", which shouldn't ever exist in the JSS
      args[:name] ||= "-1"

      super

      if args[:id] == :new
        raise JSS::InvalidDataError, "New Peripherals must have a :type, which must be one of those defined in the JSS." unless args[:type]
        @type = args[:type]
        raise JSS::InvalidDataError, "No peripheral type '#{@type}' in the JSS" unless JSS::PeripheralType.all_names(:refresh, api: @api).include? @type
        @fields = {}
        @rest_rsrc = 'peripherals/id/-1'
        @site = "None"
        return
      end

      @type =  @init_data[:general][:type]
      @site = JSS::APIObject.get_name(@init_data[:general][:site])
      @bar_code_1 = @init_data[:general][:bar_code_1]
      @bar_code_2 = @init_data[:general][:bar_code_2]
      @computer_id = @init_data[:general][:computer_id]

      ### fill in the fields
      @fields = {}
      @init_data[:general][:fields].each{|f| @fields[f[:name]] = f[:value] }

      ### get the field defs for this PeriphType, omitting the leading nil
      @field_defs ||= JSS::PeripheralType.new(:name => @type).fields.compact


    end # initialize


    ###
    ### reset the restrsrc after creation
    ###
    ### @see JSS::Creatable#create
    ###
    def create
      super
      @rest_rsrc = "peripherals/id/#{@id}"
      @id
    end

    ###
    ### periphs don't have names
    ###
    def name= (newname)
      raise JSS::UnsupportedError, "Peripherals don't have names."
    end

    ###
    ###
    ### @return [Hash] the field values of the peripheral
    ###   Each key is the fields name, as a String
    ###   and the value is the fields value, also as a String
    ###
    def fields
      @fields
    end

    ###
    ### Set the value of a field. It will be checked to ensure validity.
    ###
    ### @param field[String] the field to set
    ###
    ### @param value[String] the new value for the field
    ###
    ### @return [void]
    ###
    def set_field(field, value)
      check_field(field, value)
      @fields[field] = value
      @need_to_update = true
    end

    ###
    ### Set the value of barcode 1
    ###
    ### @param new_value[String] the new barcode value
    ###
    ### @return [void]
    ###
    def bar_code_1= (new_value)
        @bar_code_1 = new_value
        @need_to_update = true
    end


    ###
    ### Set the value of barcode 2
    ###
    ### @param new_value[String] the new barcode value
    ###
    ### @return [void]
    ###
    def bar_code_2= (new_value)
        @bar_code_2 = new_value
        @need_to_update = true
    end


    ###
    ### Associate this peripheral with a computer.
    ###
    ### @param computer[String,Integer] the name or id of a computer in the JSS
    ###
    ### @return [void]
    ###
    def associate(computer)
      if computer =~ /^d+$/
        raise JSS::NoSuchItemError, "No computer in the JSS with id #{computer}" unless JSS::Computer.all_ids(api: @api).include? computer
        @computer_id = computer
      else
        raise JSS::NoSuchItemError, "No computer in the JSS with name #{computer}" unless JSS::Computer.all_names(api: @api).include? computer
        @computer_id = JSS::Computer.map_all_ids_to(:name, api: @api).invert[computer]
      end
      @need_to_update = true
    end


    ###
    ### Disassociate this peripheral from any computer.
    ###
    ### This seems to have no effect in the JSS,
    ### the  computer/user/location data always shows the most recent.
    ###
    ### @return [void]
    ###
    def disassociate
      @computer_id = nil
      @need_to_update = true
    end


    #################################
    ### Private Methods below here
    private

    ###
    ### check a field, the field name must match those defined in
    ### the appropriate peripheral type.
    ### If a field is a menu field, the value must also be one of those defined
    ### in the periph type.
    ### Raise an exception if wrong.
    ###
    def check_field(field, value)
      ### get the field defs for this PeriphType, omitting the leading nil
      @field_defs ||= JSS::PeripheralType.new(:name => @type).fields.compact

      ### we must have the right number of fields, and they must have the same names
      ### as the definition
      required_fields = @field_defs.map{|f| f[:name]}
      raise JSS::InvalidDataError, "Peripherals of type '#{@type}' doesn't have a field '#{field}', they only have: #{required_fields.join(', ')}" unless required_fields.include? field

      ### any menu fields can only have values as defined by the type.
      menu_flds = @field_defs.select{|f| f[:type] == "menu" }
      menu_flds.each do |mf|
        next unless mf[:name] == field
        raise JSS::InvalidDataError, "The value for field '#{field}' must be one of: #{mf[:choices].join(', ')}" unless mf[:choices].include? value
      end #if menu_flds.include? field

    end # check fields

    ###
    ### Return the REST XML for this pkg, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      periph = doc.add_element RSRC_OBJECT_KEY.to_s

      general = periph.add_element('general')
      general.add_element('type').text = @type
      general.add_element('site').add_element('name').text = @site
      general.add_element('bar_code_1').text = @bar_code_1
      general.add_element('bar_code_2').text = @bar_code_2
      general.add_element('computer_id').text = @computer_id

      fields = general.add_element('fields')
      @fields.each do |n,v|
        fld =  fields.add_element('field')
        fld.add_element('name').text = n
        fld.add_element('value').text = v
      end

      if has_location?
        periph << location_xml
      end
      if has_purchasing?
        periph << purchasing_xml
      end

      return doc.to_s
    end # rest xml

    ### Aliases
    alias barcode_1 bar_code_1
    alias barcode1 bar_code_1
    alias barcode_1= bar_code_1=
    alias barcode1= bar_code_1=

    alias barcode_2 bar_code_2
    alias barcode2 bar_code_2
    alias barcode_2= bar_code_2=
    alias barcode2= bar_code_2=

    alias assign_to associate
    alias unassign disassociate

  end # class Peripheral
end # module
