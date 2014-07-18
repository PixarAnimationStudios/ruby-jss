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
  ### The parent class of a Report in the JSS
  ###
  ### Subclasses must define the constant RESULT_CLASS, which is the
  ### JSS Module class of the items contained in the report, 
  ### e.g. JSS::Computer.
  ###
  ### Reports are read-only, they return the display_fields defined
  ### in the matching Advanced_xx_Search, for each of the items found.
  ### Make changes to them using the matching Advanced_xx_Search class.
  ###
  ### This data is more appropriately accessed via the Advanced_xx_Search#report method,
  ### which instantiates one of these objects and returns its report_data
  ###
  ###
  ### Other than :name and :id, they have only one value, :report_data, an Array.
  ###
  ### The items in the array are hashes, with keys matching the display_fields
  ### Array of the corresponding Advanced_xx_Search
  ### 
  ### NOTE: At the moment there are many problems and inconsistencies withthe API output 
  ### for reports. This code will change when it's cleaned up.
  ###
  ### See also JSS::APIObject
  ###
  class Report < JSS::APIObject
  
    #####################################
    ### Mix-Ins
    #####################################
    
    #####################################
    ### Class Constants
    #####################################
    
    
    #####################################
    ### Attributes
    #####################################
    
    ### the report results - an Array of Hashes, one for each RESULT_CLASS item in the report.
    ### The hash keys are symbolized versions of the display field names defined in the 
    ### matching Advanced Search.
    ###
    ### NOTE: as of casper 9.32, the JSON output of the API is broken, it only returns one
    ### result, and the JSON data structure is wierd. This will be changing soon!
    attr_reader :report_data
    
    #####################################
    ### Constructor
    #####################################
    
    def initialize(args = {})
    
      if args[:data]
        raise JSS::UnsupportedError, "Reports must be queried directly. Use :id or :name, not :data."
      
      elsif args[:id] == :new
        raise JSS::UnsupportedError, "Reports are read-only. Create or edit them using the corresponding AdvancedSearch" 
        
      end
      
      super args

      ### TEMPORARY - this will change when the JSON bug is fixed
      @report_data = @init_data[self.class::RESULT_CLASS::RSRC_LIST_KEY]
    
    end # init
    
    #####################################
    ### Public Instance Methods
    #####################################
    
  end # class
  
end # module

require "jss/api_object/report/computer_report"
