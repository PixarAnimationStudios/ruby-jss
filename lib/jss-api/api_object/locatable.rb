### Copyright 2014 Pixar
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

  ### A mix-in module for handling location/user data for objects in the JSS.
  ###
  ### The JSS objects that have location data return it in a :location subset,
  ### which all have basically the same data,a simple hash with these keys:
  ### - :building => String,
  ### - :department => String,
  ### - :email_address => String,
  ### - :phone => String
  ### - :position => String
  ### - :real_name => String,
  ### - :room => String,
  ### - :username => String
  ###
  ### Including this module in an {APIObject} subclass will give it attributes
  ### matching those keys, which are populated by calling {#parse_location} in the
  ### subclass's constructor after calling super.
  ###
  ### If the subclass is creatable or updatable, calling {#location_xml} returns
  ### a REXML element representing the location subset, to be included with the
  ### #rest_xml output of the subclass.
  ###
  module Locatable

    #####################################
    ###  Constants
    #####################################

    LOCATABLE = true

    #####################################
    ###  Variables
    #####################################
    
    
    #####################################
    ###  Attribtues
    #####################################

    ### 
    ### Objects with a Location subset have those values stored as
    ### primary attributes here, not in a single Hash attribute
    ### as the other subsets

    ### @return [String]
    attr_reader :building

    ### @return [String]
    attr_reader :department

    ### @return [String]
    attr_reader :email_address

    ### @return [String]
    attr_reader :phone

    ### @return [String]
    attr_reader :position

    ### @return [String]
    attr_reader :real_name

    ### @return [String]
    attr_reader :room

    ### @return [String]
    attr_reader :username
    

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### Call this during initialization of
    ### objects that have a Location subset
    ### and the location attributes will be populated
    ### (as primary attributes) from @init_data
    ###
    ### @return [void]
    ###
    def parse_location
      @init_data[:location] ||= {}
      @building = @init_data[:location][:building]
      @department = @init_data[:location][:department]
      @email_address = @init_data[:location][:email_address]
      @phone = @init_data[:location][:phone]
      @position = @init_data[:location][:position]
      @real_name = @init_data[:location][:real_name]
      @room = @init_data[:location][:room]
      @username = @init_data[:location][:username]
    end

    
    ###
    ### All the location data in a Hash, as it comes from the API.
    ###
    ### The reason it isn't stored this way is to prevent editing of the hash directly.
    ### 
    ### @return [Hash<String>] the location data
    ###
    def location
      {
        :building => @building,
        :department => @department,
        :email_address => @email_address,
        :phone => @phone,
        :position => @position,
        :real_name => @real_name,
        :room => @room,
        :username => @username
      }
    end
    
    
    ###
    ###
    ### Setters
    ###

    ###
    def building= (new_val)
      return nil if @building == new_val
      new_val = new_val.to_s.strip
      raise JSS::NoSuchItemError, "No building named #{new_val} exists in the JSS" unless new_val.empty? or JSS::Building.all_names.include? new_val
      @building = new_val
      @need_to_update = true
    end

    ###
    def department= (new_val)
      return nil if @department == new_val
      new_val = new_val.to_s.strip
      raise JSS::NoSuchItemError, "No department named #{new_val} exists in the JSS" unless new_val.empty? or JSS::Department.all_names.include? new_val
      @department = new_val
      @need_to_update = true
    end

    ###
    def email_address= (new_val)
      return nil if @email_address == new_val
      new_val = new_val.to_s.strip
      raise JSS::InvalidDataError, "Invalid Email Address" unless new_val.empty? or  new_val =~ /^[^\s@]+@[^\s@]+$/
      @email_address = new_val
      @need_to_update = true
    end

    ###
    def position= (new_val)
      return nil if @position == new_val
      new_val = new_val.to_s.strip
      @position = new_val
      @need_to_update = true
    end

    ###
    def phone= (new_val)
      return nil if @phone == new_val
      new_val = new_val.to_s.strip
      @phone = new_val
      @need_to_update = true
    end

    ###
    def real_name= (new_val)
      return nil if @real_name == new_val
      new_val = new_val.to_s.strip
      @real_name = new_val
      @need_to_update = true
    end

    ###
    def room= (new_val)
      return nil if @room == new_val
      new_val = new_val.to_s.strip
      @room = new_val
      @need_to_update = true
    end

    ###
    def username= (new_val)
      return nil if @username == new_val
      new_val = new_val.to_s.strip
      @username = new_val
      @need_to_update = true
    end

    ###
    ### @return [Boolean] Does this item have location data?
    ###
    def has_location?
      @username or \
      @real_name or \
      @email_address or \
      @position or \
      @phone or \
      @department or \
      @building or \
      @room
    end

    ###
    ### Clear all location data
    ###
    ### @return [void]
    ###
    def clear_location
      @username = ''
      @real_name = ''
      @email_address = ''
      @position = ''
      @phone = ''
      @department  = ''
      @building = ''
      @room = ''
      @need_to_update = true
    end
    
    
    ### aliases
    alias user username
    
    
    ###
    ### @api private
    ###
    ### Return a REXML <location> element to be
    ### included in the rest_xml of
    ### objects that have a Location subset
    ###
    ### @return [REXML::Element]
    ###
    def location_xml
      location = REXML::Element.new('location')
      location.add_element('building').text = @building
      location.add_element('department').text = @department
      location.add_element('email_address').text = @email_address
      location.add_element('position').text = @position
      location.add_element('phone').text = @phone
      location.add_element('real_name').text = @real_name
      location.add_element('room').text = @room
      location.add_element('username').text = @username
      return location
    end

  end # module Locatable

end # module JSS
