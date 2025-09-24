# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

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
  ### When this module is mixed in to a {Jamf::APIObject} subclass, instances of the subclass
  ### will have a @scope attribute containing a {Jamf::Scopable::Scope} instance
  ###
  ### Classes that mix in this module must:
  ### - Set a Constant SCOPE_TARGET_KEY that is either :computers or :mobile_devices
  ### - Include the result of self.scope.scope_xml in their own rest_xml output if they are {Updatable} or {Creatable}
  ###
  module Scopable

    ###  Constants
    #####################################

    SCOPABLE = true

    ###  Attribtues
    #####################################

    attr_reader :scope

    ###  Mixed-in Instance Methods
    #####################################

    ### @api private
    ###
    ### Call this during initialization of objects that have a scope
    ### and the scope instance will be created from @init_data
    ###
    ### @return [void]
    ###
    def parse_scope
      @scope = Jamf::Scopable::Scope.new self.class::SCOPE_TARGET_KEY, @init_data[:scope], container: self
      @scope.container ||= self
    end

    ### Change the scope
    ###
    ### @param new_scope[Jamf::Scopable::Scope] the new scope
    ###
    ### @return [void]
    ###
    def scope=(new_scope)
      raise Jamf::InvalidDataError, 'Jamf::Scopable::Scope instance required' unless new_criteria.is_a?(Jamf::Scopable::Scope)

      unless self.class::SCOPE_TARGET_KEY == new_scope.target_key
        raise Jamf::InvalidDataError,
              "Scope object must have target_key of :#{self.class::SCOPE_TARGET_KEY}"
      end

      @scope = new_scope
      @need_to_update = true
    end

    ### When the scope changes, it calls this to tell us that an update is needed.
    ###
    ### @return [void]
    ###
    def should_update
      @need_to_update = true if @in_jss
    end

    # A wrapper around the update method, to try catching 409 conflict errors
    # when we couldn't verify all ldap users/groups due to lack of ldap connections
    #
    def update
      resp = super
      @scope.should_update = false
      resp
    rescue Jamf::ConflictError => e
      raise Jamf::InvalidDataError, 'Potentially non-existant LDAP user or group in new scope values.' if scope.unable_to_verify_ldap_entries == true

      raise e
    end # update

  end # module Scopable

end # module Jamf
