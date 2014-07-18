module JSS

###  JSS API Access for Computer Reports.
### A computer report is the AdvancedComputerSearch#display_fields values for every computer matching an
### AdvancedComputerSearch, q.v.
### 
###

  
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
  ### A ComputerReport in the JSS
  ###
  ### See also the parent class JSS::Report
  ###
  ### See also JSS::APIObject
  ###
  class ComputerReport < JSS::Report
  
    #####################################
    ### Mix-Ins
    #####################################
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "computerreports"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_reports
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages 
    ### NOTE: The inconsistency of this object key being plural....will be reported to JAMF
    RSRC_OBJECT_KEY = :computer_reports
    
    ### This is the JSS module method that returns an :id => :name hash of these objects
    LIST_METHOD = :computer_reports
    
    ### The reports are about these kinds of objects:
    RESULT_CLASS = JSS::Computer
    
    ### 
    ### TEMPORARY until JAMF fixes up reports and makes their output more standardized
    ###
    def initialize(args = {})
    
      if args[:data]
        raise JSS::UnsupportedError, "Reports must be queried directly. Use :id or :name, not :data."
      
      elsif args[:id] == :new
        raise JSS::UnsupportedError, "Reports are read-only. Create or edit them using the corresponding AdvancedSearch" 
      
      else
        ### what lookup key are we using?
        lookup_key = args[:id] ? :id : nil
        lookup_key ||= args[:name] ? :name : nil
      
        raise JSS::MissingDataError, "Args must include :id or :name"  unless lookup_key
        
        rsrc = "#{self.class::RSRC_BASE}/#{lookup_key}/#{args[lookup_key]}"
        
        begin
          @init_data = JSS::API.get_rsrc(rsrc)[self.class::RSRC_OBJECT_KEY]
          ### Does this data come in subsets?
          @got_subsets = @init_data[:general].kind_of?(Hash)
        rescue RestClient::ResourceNotFound
          raise NoSuchItemError, "No #{self.class::RSRC_OBJECT_KEY} found matching: #{args[:name] ? args[:name] : args[:id]}" 
        end
      end

      ### TEMPORARY - this will change when the JSON bug is fixed
      @report_data = @init_data["Computer".to_sym]
    
    end # init
    
  end # class ComputerReport
  
end # module
