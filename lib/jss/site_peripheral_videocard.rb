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
  class VideoCard < Peripheral
    
    ###############################
    # Class Constants
    TYPE = "VideoCard"
    
    # the fields we keep about monitors..
    # The label is that defined in the JSS Peripheral Type.
    # so it's also used as the key in the @fields hash.
    # The db_field is the mysql field that holds that data for
    # each periph in the peripheral table.
    # e.g. the "Make" is stored in field 'field_0' for periphs of type "Monitor"
    #
    NAME = {:label => "name", :db_field => 0}
    MAKE = {:label => "make", :db_field => 1}
    MODEL = {:label => "model", :db_field => 2}
    VRAM = {:label => "vram", :db_field => 3}
    BUS = {:label => "bus", :db_field => 4}
    KIND = {:label => "kind", :db_field => 5}
    
    #####################################
    # Class Variables
    #####################################
    
    ## a holder for the list of all video_cards in the JSS
    @@video_cards = nil
    
    #####################################
    # Class Methods
    #####################################
    
    ###
    ### Return an array of id's of all video_cards in the jss
    ###
    def VideoCard.video_cards(refresh = false)
      @@video_cards = nil if refresh
      return @@video_cards if @@displays
      
      @@video_cards = []
      PixJSS::Peripheral.peripherals(refresh).each {|id,p| @@video_cards << id if p == TYPE}
      
      @@video_cards
    end # def monitors
  
  
    ###
    ### Search for video_cards by model.
    ### unfortunately, the REST API doesn't really allow queries like this
    ### and getting ALL the peripherals to search them in Ruby is slow
    ### and hits the REST server too hard when all the clients do it.
    ### Direct sql is faster and better, until the API is improved.
    ###
    ### Returns the an array of peripheral IDs that match the model
    ###
    def VideoCard.by_model(model)
      query = "SELECT peripheral_id FROM #{PERIPHERAL_TABLE} WHERE type = '#{TYPE}' AND field_#{MODEL[:db_field]} = '#{model}'"
      
      qr = PixJSS::DB_CNX.db.query(query)

      results = []
      qr.each_hash {|r| results << r["peripheral_id"] }
      results
    end
    
    
    ###############################
    # Attributes
    
    # String - the name of the video card
    attr_reader :name
    
    # String - the manufacturer
    attr_reader :make
    
    # String - the model
    attr_reader :model
    
    # String - the amount of vram on the card, e.g. "256 MB"
    attr_reader :vram
    
    # String - the bus to which the card is connected, e.g. "pci"
    attr_reader :bus
    
    # String - the kind of video card ("type" in sys profiler), e.g. "gpu"
    attr_reader :kind
    
    ###
    ### Initialize
    ###
    def initialize (id=nil)
      
      super id
         
      if @exists
        raise "Peripheral #{id} is not a Video Card" unless @type == TYPE
        @name =  @fields[NAME[:label]]
        @make =  @fields[MAKE[:label]]
        @model =  @fields[MODEL[:label]]
        @vram =  @fields[VRAM[:label]]
        @bus =  @fields[BUS[:label]]
        @kind =  @fields[KIND[:label]]
        
      else 
        # doesn't exist, we're making a new one
        @type = TYPE
        @name = nil
        @make = nil
        @model =  nil
        @vram =  nil
        @bus =  nil
        @kind = nil
      end # if exists
      
    end # initialize
  
    ###
    ### set our field values
    ###
    def name=(name)
      @name = name
      @fields[NAME[:label]] = name
      @saved = false
    end
    
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
    
    def vram=(vram)
      @vram = vram
      @fields[VRAM[:label]] = vram
      @saved = false
    end
    
    def bus=(bus)
      @bus = bus
      @fields[BUS[:label]] = bus
      @saved = false
    end
    
    def kind=(kind)
      @kind = kind
      @fields[KIND[:label]] = kind
      @saved = false
    end

    
    ###
    ### Check our data before submitting
    ###
    def check_data
      super
      raise PixJSS::MissingDataError, "Missing name" unless @name
      raise PixJSS::MissingDataError, "Missing make" unless @make
      raise PixJSS::MissingDataError, "Missing model" unless @model
      raise PixJSS::MissingDataError, "Missing vram" unless @vram
      raise PixJSS::MissingDataError, "Missing bus" unless @bus
      raise PixJSS::MissingDataError, "Missing kind" unless @kind
    end
    
    ###
    ### delete all our data
    ###
    def delete
      super
      @name = nil
      @make = nil
      @model =  nil
      @vram =  nil
      @bus =  nil
      @kind = nil
    end # delete
    
  end # class 
end # module