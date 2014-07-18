module JSS

### A mix-in module providing access to the "match" resources for some 
### JSS API objects, like computers and mobile devices.
###

  
  #####################################
  ### Module Variables
  #####################################
 

  #####################################
  ### Module Methods
  #####################################
  
  #####################################
  ### Sub-Modules
  #####################################
  
  module Matchable
    
    #####################################
    ###  Constants
    #####################################
    
    MATCHABLE = true
    
    MATCH_RSRC = "match"
    
    #####################################
    ###  Variables
    #####################################
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################
    
    #####################################
    ###  Extended Class Methods
    #####################################
    
    ###
    ### Perform a match, returning an Array of matching data. 
    ###
    ### Each Array element is a simple Hash with identifier and location 
    ### data for a matching object..
    ###
    ### At the moment, it appears the search is an "exact match" search
    ### regardless of the prefs of the user connected to the API.
    ###
    ### @param term[String] the term to match in the JSS.
    ###
    def match(term)
      raise JSS::InvalidDataError, "Match term may not be empty" if term.to_s.empty?
      rsrc = "#{self::RSRC_BASE}/#{JSS::Matchable::MATCH_RSRC}/#{term}"
      JSS::API.get_rsrc(rsrc)[self::RSRC_LIST_KEY]
    end
      
  end # module Matchable
  
end # module
