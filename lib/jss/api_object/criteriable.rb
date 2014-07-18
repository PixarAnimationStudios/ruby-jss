module JSS
  
  
### A mix-in module providing consistent access to JSS::Criteriable::Criteria and
### JSS::Criteriable::Criterion objects from within objects that contain Criteria.
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
  ### A mix-in module that allows objects to handle standardized Criteria.
  ###
  ### Some objects in the JSS, such as Advanced Searches and Smart Groups,
  ### include a set of Criteria, conditions which, when met, signify inclusion
  ### in some result set. 
  ###
  ### When a JSS::APIObject subclass includes this module, that subclass
  ### will have a :criteria attribute, which holds a JSS::Criteriable::Criteria
  ### instance, which itself is a container for JSS::Criteriable::Criterion 
  ### instances.
  ### 
  ### The including subclass also gains some instance methods:
  ### * #parse_critera - sets the :criteria attribute during initialization
  ### * #criteria= - allows the wholesale replacement of the criteria
  ### * #need_to_update - allows the JSS::Criteriable::Criteria instance to 
  ###   inform the subclass instance that it has changed and needs an #update
  ###
  ### JSS::Criteriable::Criteria provides methods for dealing with the 
  ### individual JSS::Criteriable::Criterion instances it contains, and can be
  ### accessed via the :criteria attribute.
  ###
  module Criteriable
    
    #####################################
    ###  Constants
    #####################################
    
    CRITERIABLE = true
    
    
    #####################################
    ###  Variables
    #####################################
    
    #####################################
    ###  Mixed-in Attributes
    #####################################
    
    ### JSS::Criteriable::Criteria - the criteria for the instance into which we're mixed.
    attr_reader :criteria
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################
    
    ###
    ### During initialization, convert the @init_data[:criteria] Hash into
    ### a JSS::Criteriable::Criteria instance stored in @criteria
    ###
    ### Classes mixing in this module must call this in #initialize
    ###
    def parse_criteria
      @criteria = if @init_data[:criteria]
        JSS::Criteriable::Criteria.new @init_data[:criteria].map{|c| JSS::Criteriable::Criterion.new c}
      else
        nil
      end
      @criteria.container = self if @criteria
    end
    
    ###
    ### change the criteria, it must be a JSS::Criteriable::Criteria instance
    ###
    def criteria= (new_criteria)
      raise JSS::InvalidDataError, "JSS::Criteriable::Criteria instance required" unless new_criteria.kind_of?(JSS::Criteriable::Criteria)
      @criteria = new_criteria
      @need_to_update = true
    end
    
    ###
    ### Allow our Criteria to tell us when there's been a change that needs
    ### to be updated.
    ###
    def need_to_update
      @need_to_update = true if @in_jss
    end
    
    #####################################
    ###  Mixed-in Class Methods
    #####################################
    
    
  
  end # module Criteriable
  
end # module JSS

require "jss/api_object/criteriable/criterion"
require "jss/api_object/criteriable/criteria"