module JSS

### A mix-in module providing object-updating via the JSS API.
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
  
  module Updatable
    
    #####################################
    ###  Constants
    #####################################
    
    UPDATABLE = true
    
    #####################################
    ###  Variables
    #####################################
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### Change the name of this item
    ### Remember to #update to push changes to the server.
    ###
    def name= (newname)
      raise JSS::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless UPDATABLE
      return nil if @name == newname
      raise JSS::InvalidDataError, "Names can't be empty!" if newname.to_s.empty?
      raise JSS::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} named '#{newname}' already exsists in the JSS" if self.class.all_names(:refresh).include? newname
      @name = newname
      @need_to_update = true
    end #  name=(newname)
    
    ###
    ### save changes to the JSS
    ###
    def update
      raise JSS::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless UPDATABLE
      return nil unless @need_to_update
      raise JSS::NoSuchItemError, "Not In JSS! Use #create to create this #{self.class::RSRC_OBJECT_KEY} in the JSS before updating it." unless @in_jss
      JSS::API.put_rsrc  @rest_rsrc, rest_xml
      @need_to_update = false
      true
    end # save
    
    ###
    ### an alias doesn't propagate to classes where this is included, 
    ### if the class redefines #update, so use a method definition to 
    ### call the local one explicitly.
    ###
    def save 
      self.update
    end
    
  end # module Creatable
  
end # module
