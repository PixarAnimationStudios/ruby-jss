# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

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
  ### @see Jamf::APIObject
  ###
  class Peripheral < Jamf::APIObject

    #####################################
    ### MixIns
    #####################################

    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Purchasable
    include Jamf::Locatable
    include Jamf::Uploadable
    include Jamf::Sitable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'peripherals'

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :peripherals

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :peripheral

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 8

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

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
    def initialize(**args)
      ### periphs don't really have names, and the JSS module list method for
      ### periphs gives the computer_id as the name, so give it a temp
      ### name of "-1", which shouldn't ever exist in the JSS
      args[:name] ||= '-1'

      super

      if args[:id] == :new
        raise Jamf::InvalidDataError, 'New Peripherals must have a :type, which must be one of those defined in the JSS.' unless args[:type]

        @type = args[:type]
        raise Jamf::InvalidDataError, "No peripheral type '#{@type}' in the JSS" unless Jamf::PeripheralType.all_names(:refresh, cnx: @cnx).include? @type

        @fields = {}
        @rest_rsrc = 'peripherals/id/-1'
        @site = 'None'
        return
      end

      @type = @init_data[:general][:type]
      @site = Jamf::APIObject.get_name(@init_data[:general][:site])
      @bar_code_1 = @init_data[:general][:bar_code_1]
      @bar_code_2 = @init_data[:general][:bar_code_2]
      @computer_id = @init_data[:general][:computer_id]

      ### fill in the fields
      @fields = {}
      @init_data[:general][:fields].each { |f| @fields[f[:name]] = f[:value] }

      ### get the field defs for this PeriphType, omitting the leading nil
      @field_defs ||= Jamf::PeripheralType.fetch(name: @type).fields.compact
    end # initialize

    ###
    ### reset the restrsrc after creation
    ###
    ### @see Jamf::Creatable#create
    ###
    def create
      super
      @rest_rsrc = "peripherals/id/#{@id}"
      @id
    end

    ###
    ### periphs don't have names
    ###
    def name=(_newname)
      raise Jamf::UnsupportedError, "Peripherals don't have names."
    end

    ###
    ###
    ### @return [Hash] the field values of the peripheral
    ###   Each key is the fields name, as a String
    ###   and the value is the fields value, also as a String
    ###
    attr_reader :fields

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
    def bar_code_1=(new_value)
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
    def bar_code_2=(new_value)
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
        raise Jamf::NoSuchItemError, "No computer in the JSS with id #{computer}" unless Jamf::Computer.all_ids(cnx: @cnx).include? computer

        @computer_id = computer
      else
        raise Jamf::NoSuchItemError, "No computer in the JSS with name #{computer}" unless Jamf::Computer.all_names(cnx: @cnx).include? computer

        @computer_id = Jamf::Computer.map_all_ids_to(:name, cnx: @cnx).invert[computer]
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
      @field_defs ||= Jamf::PeripheralType.fetch(name: @type, cnx: @cnx).fields.compact

      ### we must have the right number of fields, and they must have the same names
      ### as the definition
      required_fields = @field_defs.map { |f| f[:name] }
      unless required_fields.include? field
        raise Jamf::InvalidDataError,
              "Peripherals of type '#{@type}' doesn't have a field '#{field}', they only have: #{required_fields.join(', ')}"
      end

      ### any menu fields can only have values as defined by the type.
      menu_flds = @field_defs.select { |f| f[:type] == 'menu' }
      menu_flds.each do |mf|
        next unless mf[:name] == field
        raise Jamf::InvalidDataError, "The value for field '#{field}' must be one of: #{mf[:choices].join(', ')}" unless mf[:choices].include? value
      end # if menu_flds.include? field
    end # check fields

    ###
    ### Return the REST XML for this pkg, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      doc.root.name = RSRC_OBJECT_KEY.to_s
      periph = doc.root

      general = periph.add_element('general')
      general.add_element('type').text = @type
      general.add_element('site').add_element('name').text = @site
      general.add_element('bar_code_1').text = @bar_code_1
      general.add_element('bar_code_2').text = @bar_code_2
      general.add_element('computer_id').text = @computer_id

      fields = general.add_element('fields')
      @fields.each do |n, v|
        fld = fields.add_element('field')
        fld.add_element('name').text = n
        fld.add_element('value').text = v
      end

      periph << location_xml if has_location?
      periph << purchasing_xml if has_purchasing?
      add_site_to_xml doc

      doc.to_s
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
