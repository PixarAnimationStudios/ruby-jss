module JSS

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
  ### A mix-in module for handling scoping data for objects in the JSS.
  ###
  ### The JSS objects that can be scoped use similar data to represent
  ### that scoping. This module provides a consistant way to deal with scoping data
  ### via some instance methods and the {Scopable::Scope} class.
  ###
  ### When this module is mixed in to a {JSS::APIObject} subclass, instances of the subclass
  ### will have a @scope attribute containing a {JSS::Scopable::Scope} instance
  ###
  ### Classes that mix in this module must:
  ### - Set a Constant SCOPE_TARGET_KEY that is either :computers or :mobile_devices
  ### - Call {#parse_scope} during initialization to make a {JSS::Scopable::Scope} instance for their @scope attribute.
  ### - Include the result of self.scope.scope_xml in their own rest_xml output if they are {Updatable} or {Creatable}
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
    ### @api private
    ###
    ### Call this during initialization of objects that have a scope
    ### and the scope instance will be created from @init_data
    ###
    ### @return [void]
    ###
    def parse_scope
      @scope = JSS::Scopable::Scope.new self.class::SCOPE_TARGET_KEY, @init_data[:scope]
      @scope.container = self
    end


    ###
    ### Change the scope
    ###
    ### @param new_scope[JSS::Scopable::Scope] the new scope
    ###
    ### @return [void]
    ###
    def scope= (new_scope)
      raise JSS::InvalidDataError, "JSS::Scopable::Scope instance required" unless new_criteria.kind_of?(JSS::Scopable::Scope)
      raise JSS::InvalidDataError, "Scope object must have target_key of :#{self.class::SCOPE_TARGET_KEY}" unless self.class::SCOPE_TARGET_KEY == new_scope.target_key
      @scope = new_scope
      @need_to_update = true
    end

    ###
    ### When the scope changes, it calls this to tell us that an update is needed.
    ###
    ### @return [void]
    ###
    def should_update
      @need_to_update = true if @in_jss
    end

    
    ###
    ### A wrapper around the update method, to try catching RestClient::Conflict
    ### 409 errors when we couldn't verify all ldap users/groups due to lack of ldap connections
    ### 
    def update
      begin
        super
        
      rescue RestClient::Conflict => conflict
        if  self.scope.unable_to_verify_ldap_entries == true
          raise JSS::InvalidDataError, "Potentially non-existant LDAP user or group in new scope values."
        else
          raise conflict
        end
        
      end # begin
    end # update
    
  end # module Scopable
end # module JSS

require "jss/api_object/scopable/scope"
