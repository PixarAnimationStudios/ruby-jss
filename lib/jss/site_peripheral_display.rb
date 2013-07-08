# = site_peripheral_display.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A Display peripheral in Pixar's JSS
#


module PixJSS
  

  #####################################
  # Classes
  #####################################
  
  ### 
  ### A display in Pixar's JSS
  ### A subcass of Peripheral with modifications for how Pixar stores Display inventory data.
  ### 
  class Display < Peripheral
    
    ###############################
    # Class Constants
    DISPLAY_TYPE = "Display"
    
    # the fields we keep about monitors..
    # The label is that defined in the JSS Peripheral Type.
    # so it's also used as the key in the @fields hash.
    # The db_field is the mysql field that holds that data for
    # each periph in the peripheral table.
    # e.g. the "Make" is stored in field 'field_0' for periphs of type "Monitor"
    #
    MAKE = {:label => "make", :db_field => 0}
    MODEL = {:label => "model", :db_field => 1}
    FAMILY = {:label => "family", :db_field => 2}
    SN = {:label => "serialnum", :db_field => 3}
    
    #####################################
    # Class Variables
    #####################################
    
    ## a holder for the list of all monitors in the JSS
    @@displays = nil
    
    #####################################
    # Class Methods
    #####################################
    
    ###
    ### Return an array of id's of all monitors in the jss
    ###
    def Display.display(refresh = false)
      @@displays = nil if refresh
      return @@displays if @@displays
      
      @@displays = []
      PixJSS::Peripheral.peripherals(refresh).each {|id,p| @@displays << id if DISPLAY_TYPE == p}
      
      @@displays
    end # def monitors
  
  
    ###
    ### Search for a monitor by serialnumber.
    ### unfortunately, the REST API doesn't really allow queries like this
    ### and getting ALL the peripherals to search them in Ruby is slow
    ### and hits the REST server too hard when all the clients do it.
    ### Direct sql is faster and better, until the API is improved.
    ###
    ### Returns the peripheral ID, or nil if not found.
    ###
    def Display.by_sn(sn)
      query = "SELECT peripheral_id FROM #{PERIPHERAL_TABLE} WHERE type = '#{DISPLAY_TYPE}' AND field_#{SN[:db_field]} = '#{sn}'"
      
      result = PixJSS::DB_CNX.db.query(query)
      case result.count
        when 0 then return nil
        when 1 then return result.fetch[0].to_i
        else raise "More than one Display with serialnumber '#{sn}' in the JSS!"
      end # case
      
    end
    
    
    ###############################
    # Attributes
    
    # String - the manufacturer
    attr_reader :make
    
    # String - the model
    attr_reader :model
    
    # String - the diagonal size of the monitor
    attr_reader :family
    
    # String - the asset tag of the display
    # this gets stored as "barcode_1"
    attr_reader :assettag
    
    # String - the serial number of the monitor
    attr_reader :serial_number
    alias sn serial_number
    alias serialnum serial_number
    
    ###
    ### Initialize
    ###
    def initialize (id=nil)
      
      super id
         
      if @exists
        raise "Peripheral #{id} is not a Display" unless @type == DISPLAY_TYPE
        @make =  @fields[MAKE[:label]]
        @model =  @fields[MODEL[:label]]
        @family =  @fields[FAMILY[:label]]
        @serial_number =  @fields[SN[:label]]
        @assettag = @barcode_1
        
      else 
        # doesn't exist, we're making a new one
        @type = DISPLAY_TYPE
        @make = nil
        @model =  nil
        @family =  nil
        @serial_number =  nil
        @assettag = nil
      end # if exists
      
    end # initialize
  
    ###
    ### set our field values
    ###
    def make=(make)
      @make = make
      @fields[MAKE[:label]] = make
      @saved = false
    end
    
    def model=(model)
      @model = model
      @fields[MODEL[:label]] = model
      @saved = false
    end
    
    def family=(family)
      @family = family
      @fields[FAMILY[:label]] = family
      @saved = false
    end
    
    def serial_number=(serial_number)
      @serial_number = serial_number
      @fields[SN[:label]] = serial_number
      @saved = false
    end
    alias sn= serial_number=
    
    def assettag=(at)
      self.barcode_1 = at
    end
    
    ###
    ### Check our data before submitting
    ###
    def check_data
      super
      raise PixJSS::MissingDataError, "Missing make" unless @make
      raise PixJSS::MissingDataError, "Missing model" unless @model
      raise PixJSS::MissingDataError, "Missing serial_number" unless @serial_number
    end
    
    ###
    ### delete all our data
    ###
    def delete
      super
      @make = nil
      @model = nil
      @family = nil
      @serial_number =  nil
      @assettag = nil
    end # delete
    
    
  end # class Display
end # module