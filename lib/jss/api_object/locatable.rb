module JSS

### A mix-in module for handling location/user data for objects in the JSS.
###
### The JSS objects that have location data all have basically the same data,
### a simple hash with these keys:
### 
###   :building => String,
###   :department => String,
###   :email_address => String,
###   :phone => String
###   :position => String
###   :real_name => String,
###   :room => String,
###   :username => String
###
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
    
    ### String
    attr_reader :building
    
    ### String
    attr_reader :department
    
    ### String
    attr_reader :email_address
    
    ### String
    attr_reader :phone
    
    ### String
    attr_reader :position
    
    ### String
    attr_reader :real_name
    
    ### String 
    attr_reader :room
    
    ### String 
    attr_reader :username
    alias user username
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### Call this during initialization of 
    ### objects that have a Location subset
    ### and the location attributes will be populated
    ### (as primary attributes) from @init_data
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
    ### Setters 
    ###
    
    ###
    def building= (new_val)
      return nil if @building == new_val
      new_val.strip!
      raise JSS::NoSuchItemError, "No building named #{new_val} exists in the JSS" unless JSS::Building.all_names.include? new_val
      @building = new_val
      @need_to_update = true
    end
    
    ###
    def department= (new_val)
      return nil if @department == new_val
      new_val.strip!
      raise JSS::NoSuchItemError, "No department named #{new_val} exists in the JSS" unless JSS::Department.all_names.include? new_val
      @department = new_val
      @need_to_update = true
    end
    
    ###
    def email_address= (new_val)
      return nil if @email_address == new_val
      new_val.strip!
      raise JSS::InvalidDataError, "Invalid Email Address" unless new_val =~ /^[^\s@]+@[^\s@]+$/
      @email_address = new_val
      @need_to_update = true
    end
    
    ###
    def position= (new_val)
      return nil if @position == new_val
      new_val.strip!
      @position = new_val
      @need_to_update = true
    end
    
    ###
    def phone= (new_val)
      return nil if @phone == new_val
      new_val.strip!
      @phone = new_val
      @need_to_update = true
    end
    
    ###
    def real_name= (new_val)
      return nil if @real_name == new_val
      new_val.strip!
      @real_name = new_val
      @need_to_update = true
    end
    
    ###
    def room= (new_val)
      return nil if @room == new_val
      new_val.strip!
      @room = new_val
      @need_to_update = true
    end
    
    ###
    def username= (new_val)
      return nil if @username == new_val
      new_val.strip!
      @username = new_val
      @need_to_update = true
    end
    
    ###
    ### Return a REXML <location> element to be
    ### included in the rest_xml of 
    ### objects that have a Location subset
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
