module JSS

### A mix-in module for handling scoping data for objects in the JSS.
###
### The JSS objects that can be scoped use similar data to represent
### that scoping. This class provides a consistant way to deal with scoping data.
### 
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
  
  ###
  ### Classes that mix in this module must:
  ###  - Set a Constant SCOPE_TARGET_KEY that is either :computers or :mobile_devices
  ###  - 
  ###
  module Scopable
    
    #####################################
    ###  Constants
    #####################################
    
    SCOPABLE = true
        
    #####################################
    ###  Variables
    #####################################
    
    #####################################
    ###  Attribtues
    #####################################
    
    attr_reader :scope
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### Call this during initialization of 
    ### objects that have a scope
    ### and the scope attribute will be populated
    ### from @init_data
    ###
    def parse_scope
      @scope = JSS::Scopable::Scope.new self.class::SCOPE_TARGET_KEY, @init_data[:scope]
    end
    
    
    ###
    ### change the scope, it must be a JSS::Scopable::Scope instance
    ###
    def scope= (new_scope)
      raise JSS::InvalidDataError, "JSS::Scopable::Scope instance required" unless new_criteria.kind_of?(JSS::Scopable::Scope)
      raise JSS::InvalidDataError, "Scope object must have target_key of :#{self.class::SCOPE_TARGET_KEY}" unless self.class::SCOPE_TARGET_KEY == new_criteria.target_key
      @scope = new_scope
      @need_to_update = true
    end
    
    ###
    ### the Scope has to tell us when it changes
    ###
    def need_to_update
      @need_to_update = true if @in_jss
    end

    
  end # module Scopable
end # module JSS

require "jss/api_object/scopable/scope"