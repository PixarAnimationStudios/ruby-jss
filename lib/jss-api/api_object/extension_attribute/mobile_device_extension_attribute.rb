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
  ### Constants
  #####################################

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  ####################################
  ### Classes
  #####################################


  ###
  ### An extension attribute as defined in the JSS
  ###
  ### @see JSS::ExtensionAttribute
  ###
  ### @see JSS::APIObject
  ###
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "mobiledeviceextensionattributes"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_extension_attributes

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_extension_attribute

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:description, :inventory_display, :recon_display]

    ### these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::MobileDevice
    
    ### A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = JSS::Criteriable::Criterion.new(:and_or => "and", :name => "Last Inventory Update", :search_type => "after (yyyy-mm-dd)", :value => "2003-01-01")

    ######################
    ### Attributes
    ######################

    ### @return [String] the name of the LDAP attribute to use when the @input Type is "LDAP Attribute Mapping"
    attr_reader :attribute_mapping


    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject.initialize
    ###
    def initialize(args = {})

      super args

      if @init_data[:input_type]
        @attribute_mapping = @init_data[:input_type][:attribute_mapping]
      end
    end # init


    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### @see JSS::Creatable#create
    ###
    def create
      if @input_type == 'LDAP Attribute Mapping'
        raise MissingDataError, "No attribute_mapping defined for 'LDAP Attribute Mapping' input_type." unless @attribute_mapping
      end
      super
    end


    ###
    ### @see JSS::ExtensionAttribute#web_display=
    ###
    def web_display= (new_val)
      raise JSS::InvalidDataError, "web_display cannot be 'Operating System' for Mobile Device Extension Attributes." if new_val == 'Operating System'
      super
    end #


    ###
    ### @see JSS::ExtensionAttribute#input_type=
    ###
    def input_type= (new_val)
      raise JSS::InvalidDataError, "Mobile Device Extension Attribute input_type cannot be 'script'" if new_val == 'script'

      super

      if @input_type == 'LDAP Attribute Mapping'
        @popup_choices = nil
      else
        @attribute_mapping = nil
      end
    end #
    
    ###
    ### Set the ldap attribute to use for input_type 'LDAP Attribute Mapping'
    ###
    ### @param ldap_attrib[String] the attribute to use
    ###
    ### @return [void]
    ###
    def attribute_mapping= (ldap_attrib)
      return nil if ldap_attrib == @attribute_mapping
      @attribute_mapping = ldap_attrib
      @need_to_update = true
    end
    
    ######################
    ### Private Instance Methods
    #####################

    private

    ###
    ### Return the REST XML for this item, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      mdea = rest_rexml
      if @input_type == 'LDAP Attribute Mapping'
        it = mdea.elements["input_type"]
        it.add_element('attribute_mapping').text = @attribute_mapping
      end

      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << mdea

      return doc.to_s
    end # rest xml

  end # class ExtAttrib

end # module
