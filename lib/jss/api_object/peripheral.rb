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
  ### See also JSS::APIObject
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
    include JSS::FileUpload
    
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
    
    ### String - the type of periph
    ### should be settable in a subclass of Peripheral
    attr_reader :type 
    
    ### Hash  - the field values of the periph
    ### Each key is the fields name, as a String
    ### and the value is the fields value, also as a String
    ###
    ### NOTE, this doesn't get an automatic getter, since
    ### we don't want the values changed without the 
    ### check_field method running, and as a Hash
    ### one can change the elements therein with 
    ### just a getter.
    ### attr_reader :fields
    
    
    ### String - the "bar code 1" value
    attr_reader :bar_code_1
    alias barcode_1 bar_code_1
    
    ### String - the "bar code 2" value
    attr_reader :bar_code_2
    alias barcode_2 bar_code_2
    
    ### Integer- the id number of the computer to which 
    ### this periph is, or was most recently, connected
    attr_reader :computer_id
    
    #####################################
    ### Instance Methods
    #####################################

    ###
    ### Initialize
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
        raise JSS::InvalidDataError, "No peripheral type '#{@type}' in the JSS" unless JSS::PeripheralType.all_names.include? @type
        @fields = {}
        @rest_rsrc = 'peripherals/id/-1'
        return
      end
      
      @type =  @init_data[:general][:type]
      @site = @init_data[:general][:site]
      @bar_code_1 = @init_data[:general][:bar_code_1]
      @bar_code_2 = @init_data[:general][:bar_code_2]
      @computer_id = @init_data[:general][:computer_id]
      ### fill in the fields
      @fields = {}
      @init_data[:general][:fields].each{|f| @fields[f[:name]] = f[:value] }     
      
      parse_location
      parse_purchasing
      
    end # initialize
    
    ### 
    ### periphs don't have names
    ###
    def name= (newname)
      raise JSS::UnsupportedError, "Peripherals don't have names."
    end 
    
    ###
    ### fields require checking so shouldn't have regular setters or getters
    ###
    def fields 
      @fields
    end
    
    ###
    ### fields require checking so shouldn't have regular setters or getters
    ###
    def set_field(field, value)
      check_field(field, value)
      @fields[field] = value
      @need_to_update = true
    end
    
    ###
    ### set the bar codes
    ###
    def bar_code_1= (new_value)
        @bar_code_1 = new_value
        @need_to_update = true
    end
    
    def bar_code_2= (new_value)
        @bar_code_2 = new_value
        @need_to_update = true
    end    
    
    ###
    ### Set the computer id
    ###
    def computer_id= (new_id)
      associate new_id
    end
    
    
    ###
    ### associate this peripheral with a computer
    ### the arg is the name or id of a computer in the JSS
    ###
    def associate(computer)
      if computer =~ /^d+$/
        raise JSS::NoSuchItemError, "No computer in the JSS with id #{computer}" unless JSS::Computer.all_ids.include? computer
        @computer_id = computer
      else
        raise JSS::NoSuchItemError, "No computer in the JSS with name #{computer}" unless JSS::Computer.all_names.include? computer
        @computer_id = JSS::Computer.map_all_ids_to(:name).invert[computer]
      end
      @need_to_update = true
    end
    alias assign_to associate
    
    ###
    ### disassociate this peripheral from any computer
    ###
    def disassociate
      @computer_id = nil
      @need_to_update = true
    end
    alias unassign disassociate
    
    #################################
    ### Private Methods below here
    ###private
    
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
      general.add_element('site').add_element('name').text = @site ? @site[:name] : JSS::NO_SITE[:name]
      general.add_element('bar_code_1').text = @bar_code_1
      general.add_element('bar_code_2').text = @bar_code_2
      general.add_element('computer_id').text = @computer_id
      
      fields = general.add_element('fields')
      @fields.each do |n,v|
        fld =  fields.add_element('field')
        fld.add_element('name').text = n
        fld.add_element('value').text = v
      end
      
      periph << location_xml
      periph << purchasing_xml
      return doc.to_s
    end # rest xml

  end # class Peripheral
end # module