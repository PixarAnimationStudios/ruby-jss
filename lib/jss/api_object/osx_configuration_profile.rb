### Copyright 2017 Pixar

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
  ### Classes
  #####################################

  ###
  ### An OS X Configuration Profile in the JSS.
  ###
  ### Note that the profile payloads and the profile UUID cannot be edited or updated with this via this class.
  ### Use the web UI.
  ###
  ### @see JSS::APIObject
  ###
  class OSXConfigurationProfile < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################
    include JSS::Updatable
    include JSS::Scopable
    include JSS::SelfServable

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "osxconfigurationprofiles"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :os_x_configuration_profiles

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :os_x_configuration_profile

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:distribution_method, :scope, :redeploy_on_update]

    ### Our scopes deal with computers
    SCOPE_TARGET_KEY = :computers

    ### Our SelfService happens on OSX
    SELF_SERVICE_TARGET = :osx

    ### Our SelfService deploys profiles
    SELF_SERVICE_PAYLOAD = :profile

    ### The possible values for the :distribution_method
    DISTRIBUTION_METHODS = ["Install Automatically", "Make Available in Self Service"]

    SELF_SERVICE_DIST_METHOD = "Make Available in Self Service"

    ### The possible values for :level
    LEVELS = ["user", "computer"]

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 4

    #####################################
    ### Attributes
    #####################################

    ### @return [String] the description of this profile
    attr_reader :description

    ### @return [String] the distribution_method of this profile
    attr_reader :distribution_method

    ### @return [Boolean] can the user remove this profile
    attr_reader :user_removable

    ### @return [String] the level (user/computer) of this profile
    attr_reader :level

    ### @return [String] the uuid of this profile. NOT Updatable
    attr_reader :uuid

    ### @return [Boolean] Should this profile be redeployed when an inventory update happens?
    attr_reader :redeploy_on_update

    ### @return [String] the plist containing the payloads for this profile. NOT Updatable
    attr_reader :payloads

    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject#initialize
    ###
    def initialize (args = {})

      super

      @description = @main_subset[:description]
      @distribution_method = @main_subset[:distribution_method]
      @user_removable = @main_subset[:user_removable]
      @level = @main_subset[:level]
      @uuid = @main_subset[:uuid]
      @redeploy_on_update = @main_subset[:redeploy_on_update]
      @payloads = @main_subset[:payloads]
    end

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### @param new_val[String] the new discription
    ###
    ### @return [void]
    ###
    def description= (new_val)
      return nil if @self_service_description == new_val
      @description = new_val.strip!
      @need_to_update = true
    end


    ###
    ### @param new_val[String] how should this be distributed to clients?
    ###
    ### @return [void]
    ###
    def distribution_method= (new_val)
      return nil if @distribution_method == new_val
      raise JSS::InvalidDataError, "New value must be one of '#{DISTRIBUTION_METHODS.join("' '")}'" unless DISTRIBUTION_METHODS.include? new_val
      @distribution_method = new_val
      @need_to_update = true
    end

    ###
    ### @param new_val[Boolean] should the user be able to remove this?
    ###
    ### @return [void]
    ###
    def user_removable= (new_val)
      return nil if @self_service_feature_on_main_page == new_val
      raise JSS::InvalidDataError, "Distribution method must be '#{SELF_SERVICE_DIST_METHOD}' to let the user remove it." unless in_self_service?
      raise JSS::InvalidDataError, "New value must be true or false" unless JSS::TRUE_FALSE.include? new_val
      @user_removable = new_val
      @need_to_update = true
    end

    ###
    ### @param new_val[String] the new level for this profile (user/computer)
    ###
    ### @return [void]
    ###
    def level= (new_val)
      return nil if @level == new_val
      raise JSS::InvalidDataError, "New value must be one of '#{LEVELS.join("' '")}'" unless LEVELS.include? new_val
      @level = new_val
      @need_to_update = true
    end


    ###
    ### @return [Boolean] is this profile available in Self Service?
    ###
    def in_self_service?
      @distribution_method == SELF_SERVICE_DIST_METHOD
    end


    ###
    ### @return [Boolean] is this profile removable by the user?
    ###
    def user_removable?
      @user_removable
    end


    ###
    ### @return [Hash] The payload plist parsed into a Ruby hash
    ###
    def parsed_payloads
      Plist.parse_xml @payloads
    end

    ###
    ### @return [Array<Hash>] the individual payloads from the payload Plist
    ###
    def payload_content
      parsed_payloads['PayloadContent']
    end

    ###
    ### @return [Array<String>] the PayloadType of each payload (e.g. com.apple.caldav.account)
    ###
    def payload_types
      payload_content.map{|p| p['PayloadType'] }
    end

    #####################################
    ### Private Instance Methods
    #####################################
    private

    def rest_xml
      doc = REXML::Document.new

      obj = doc.add_element RSRC_OBJECT_KEY.to_s
      gen = obj.add_element('general')
      gen.add_element('description').text = @description
      gen.add_element('distribution_method').text = @distribution_method
      gen.add_element('user_removable').text = @user_removable
      gen.add_element('level').text = @level
      gen.add_element('redeploy_on_update').text = @redeploy_on_update

      obj << @scope.scope_xml
      obj << self_service_xml

      return doc.to_s
    end

  end # class OSXConfigurationProfile

end # module
