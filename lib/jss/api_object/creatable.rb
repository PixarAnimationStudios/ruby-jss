### Copyright 2016 Pixar
###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
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
  ### A mix-in module that allows objects to be created in the JSS
  ### via the API.
  ###
  ### When a JSS::APIObject subclass includes this module, that subclass
  ### can be instantiated with :id => :new, and :name => "some_new_name".
  ###
  ### The instance can be used to set desired values for the new object, and
  ### once everything's good, use #create to create it in the JSS.
  ###
  ### If a Creatable object requires more data than just a :name for creation,
  ### the subclass may want to redefine #initialize to require those data before
  ### calling super.
  ###
  ### Some subclasses may want to redefine #create to check
  ### the data for consistency, and then call super
  ### (or they may have the individual setter methods do the checks)
  ###
  ### Classes mixing this module *must* provide a #rest_xml instance method that returns the XML
  ### String to be submitted to the API for object creation.
  ###
  ### @see APIObject#save
  ###
  module Creatable

    #####################################
    ###  Constants
    #####################################

    CREATABLE = true

    #####################################
    ###  Variables
    #####################################

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### Create a new object in the JSS.
    ###
    ### @return [Integer] the jss ID of the newly created object
    ###
    def create
      raise JSS::UnsupportedError, "Creating or editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless CREATABLE
      raise AlreadyExistsError, "This #{self.class::RSRC_OBJECT_KEY} already exists. Use #update to make changes." if @in_jss
      JSS::API.post_rsrc( @rest_rsrc, rest_xml) =~ /><id>(\d+)<\/id></
      @id = $1.to_i
      @in_jss = true
      @need_to_update = false
      @rest_rsrc =  "#{self.class::RSRC_BASE}/id/#{@id}"
      return @id
    end

  end # module Creatable

end # module
