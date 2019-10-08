### Copyright 2019 Pixar

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

  ### Sub-Modules
  #####################################

  ### A mix-in module that allows objects to be created in the JSS
  ### via the API.
  ###
  ### When a JSS::APIObject subclass includes this module, that subclass
  ### can be instantiated with :id => :new, and :name => "some_new_name".
  ###
  ###
  ### Classes mixing this module *must* provide a #rest_xml instance method that
  ### returns the XML String to be submitted to the API for object creation.
  ###
  ### The instance can be used to set desired values for the new object, and
  ### once everything's good, use #create to create it in the JSS.
  ###
  ### If a Creatable object requires more data than just a :name for creation,
  ### the subclass may want to redefine #initialize to require those data before
  ### calling super, or may want to redefine #create or #rest_xml to check
  ### the data for consistency, and then call super
  ###
  ### It is also wise to have the individual setter methods do data validation
  ###
  ### @see APIObject#save
  ###
  module Creatable

    ###  Constants
    #####################################

    CREATABLE = true

    ###  Variables
    #####################################

    ###  Mixed-in Instance Methods
    #####################################

    # Create a new object in the JSS.
    #
    # @param api[JSS::APIConnection] the API in which to create the object
    #   Defaults to the API used to instantiate this object
    #
    # @return [Integer] the jss ID of the newly created object
    #
    def create
      raise JSS::UnsupportedError, "Creating or editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless creatable?

      raise AlreadyExistsError, "This #{self.class::RSRC_OBJECT_KEY} already exists. Use #update to make changes." if @in_jss

      @api.post_rsrc(rest_rsrc, rest_xml) =~ %r{><id>(\d+)</id><}
      @id = Regexp.last_match(1).to_i
      @in_jss = true
      @need_to_update = false
      @rest_rsrc = "#{self.class::RSRC_BASE}/id/#{@id}"

      # clear any caches for this class
      # so they'll re-cache as needed
      @api.flushcache self.class::RSRC_LIST_KEY

      @id
    end

    ### make a clone of this API object, with a new name. The class must be creatable
    ###
    ### @param name [String] the name for the new object
    ###
    ### @param api[JSS::APIConnection] the API in which to create the object
    ###  Defaults to the API used to instantiate this object
    ###
    ### @return [APIObject] An uncreated clone of this APIObject with the given name
    ###
    def clone(new_name, api: nil)
      api ||= @api
      raise JSS::UnsupportedError, 'This class is not creatable in via ruby-jss' unless creatable?
      raise JSS::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} already exists with that name" if \
        self.class.all_names(:refresh, api: api).include? new_name

      orig_in_jss = @in_jss
      @in_jss = false
      orig_id = @id
      @id = nil
      orig_rsrc = @rest_rsrc
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape new_name.to_s}"
      orig_api = @api
      @api = api

      new_obj = dup

      @in_jss = orig_in_jss
      @id = orig_id
      @rest_rsrc = orig_rsrc
      @api = orig_api
      new_obj.name = new_name

      new_obj
    end

  end # module Creatable

end # module
