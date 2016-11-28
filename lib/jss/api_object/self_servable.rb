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

  ### A mix-in module for handling Self Service data for objects in the JSS.
  ###
  ### The JSS objects that have Self Service data return it in a :self_service subset,
  ### which have somewhat similar data, i.e. a hash with at least these keys:
  ### - :self_service_description
  ### - :self_service_icon
  ### - :feature_on_main_page
  ### - :self_service_categories
  ###
  ### Config Profiles in self service have this key:
  ### - :security
  ###
  ### Additionally, items that apper in macOS Slf Svc have these keys:
  ### - :install_button_text
  ### - :force_users_to_view_description
  ###
  ### See the attribute definitions for details of these values and structures.
  ###
  ### Including this module in an {APIObject} subclass and calling {#parse_self_service} in the
  ### subclass's constructor will give it matching attributes with 'self_service_'
  ### appended if needed, e.g. {#self_service_feature_on_main_page}
  ###
  ###
  ### Classes including this module *must*:
  ###
  ### - Define the constant SELF_SERVICE_TARGET which contains either :macos or :ios
  ### - Define the constant SELF_SERVICE_PAYLOAD which contains one of :policy, :profile,
  ###   :app, or :ebook
  ### - Call {#parse_self_service} in the subclass's constructor, after calling super
  ### - Define the method #in_self_service? which returns a Boolean indicating that the item is
  ###   available in self service. Different API objects indicate this in different ways (and
  ###   macOS app store apps don't provide it at all via the API,
  ###   so self service can't be implemented fully)
  ### - Define the methods #add_to_self_service and #remove_from_self_service, which is handled
  ###   differently for policies, apps/ebooks, and profiles
  ### - Define the method #user_removable? which returns Boolean indicating that the item
  ###   can be removed by the user in SSvc. macOS profiles store this in the :user_removable
  ###   key of the :general subset as a boolean, whereas iOS profiles store it in
  ###   the :security hash of the :self_service data as one of 3 strings
  ### - Define the method #user_removable= which sets the appropriate values depending
  ###   on the class. (see above)
  ### - Define a #set_icon_to method which takes the id of a previously uploaded
  ###   icon, or a local path (String or Pathname) to an image file to use.
  ### - Include the result of {#self_service_xml} in their #rest_xml output
  ###
  ###
  ### Generating XML for PUT or POST:
  ###
  ### If the class including this module is creatable or updatable, calling {#self_service_xml}
  ### returns a REXML element representing the Self Service subset, to be included with the
  ### #rest_xml output of the subclass.
  ###
  ### Because some self-service-related data is located outside of the Self Service
  ### data subset (e.g. the deployment method for profiles is in the general subset),
  ### classes including this module *must* also account for that and add an appropriate
  ### XML element as needed.
  ###
  module SelfServable

    ###  Constants
    #####################################

    SELF_SERVABLE = true

    IOS_PROFILE_REMOVAL_OPTIONS = ['Always', 'With Authorization', 'Never'].freeze

    ###  Variables
    #####################################

    ###  Attribtues
    #####################################

    ### @return [String] The verbage that appears in SelfSvc for this item
    attr_reader :self_service_description

    ### @return [Boolean] Should this item feature on the main page of SSvc?
    attr_reader :self_service_feature_on_main_page

    ### @return [Array<Hash>] The categories in which this item should appear in SSvc
    ###
    ### Each Hash has these keys about the category
    ### - :id => [Integer] the JSS id of the category
    ### - :name => [String] the name of the category
    ###
    ### Most objects also include one or both of these keys:
    ### - :display_in => [Boolean] should the item be displayed in this category in SSvc? (OSX SSvc only)
    ### - :feature_in => [Boolean] should the item be featured in this category in SSVC? (OSX SSvc only)
    ###
    ### NOTE: as of Casper 9.61 there's a bug in the JSON output from the API, and only the last
    ### category is returned, if more than one are set.
    ###
    attr_reader :self_service_categories

    ### @return [Hash] The icon that appears in SelfSvc for this item
    ###
    ### The Hash contains these keys with info about the icon:
    ### - :uri => [String] the URI for retriving the icon
    ### - :id => [Integer] the JSS id number for the icon (not all SSvc items have this)
    ### - :data => [String] the icon image encoded as Base64 (not all SSvc items have this)
    ### - :filename  => [String] The name of the image file uploaded to the JSS, if applicable
    ###
    attr_reader :self_service_icon

    ### @return [Hash] The security settings for profiles in SSvc
    ###
    ### The keys are
    ### - :removal_disallowed => [String] one of the items in PROFILE_REMOVAL_OPTIONS
    ### - :password => [String] if :removal_disallowed is "With Authorization", this contains the passwd (in plaintext)
    ###   needed to remove the profile.
    ###
    ### NOTE that the key should be called :removal_allowed, since 'Never' means it can't be removed.
    ###
    attr_reader :self_service_user_removable

    ### @return [String] The text label on the install button in SSvc (OSX SSvc only)
    attr_reader :self_service_install_button_text

    ### @return [Boolean] Should an extra window appear before the user can install the item? (OSX SSvc only)
    attr_reader :self_service_force_users_to_view_description

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ### Call this during initialization of
    ### objects that have a self_service subset
    ### and the self_service attributes will be populated
    ### (as primary attributes) from @init_data
    ###
    ### @return [void]
    ###
    def parse_self_service
      @init_data[:self_service] ||= {}
      @ss_data = @init_data[:self_service]

      @self_service_description = @ss_data[:self_service_description]
      @self_service_icon = @ss_data[:self_service_icon]
      @self_service_icon ||= {}

      @self_service_feature_on_main_page = @ss_data[:feature_on_main_page]
      @self_service_feature_on_main_page ||= false

      @self_service_categories = @ss_data[:self_service_categories]
      @self_service_categories ||= []

      # make this an empty hash if needed
      @self_service_security = @ss_data[:security]
      @self_service_security ||= {}

      @self_service_install_button_text = @ss_data[:install_button_text]
      @self_service_install_button_text ||= 'Install'

      @self_service_force_users_to_view_description = @ss_data[:force_users_to_view_description]
      @self_service_force_users_to_view_description ||= false
    end # parse

    ### Setters
    ###

    ### @param new_val[String] the new discription
    ###
    ### @return [void]
    ###
    def self_service_description=(new_val)
      new_val.strip!
      return if @self_service_description == new_val
      @self_service_description = new_val
      @need_to_update = true
    end

    ### @param new_val[String] the new install button text
    ###
    ### @return [void]
    ###
    def self_service_install_button_text=(new_val)
      return nil if @self_service_install_button_text == new_val
      raise JSS::InvalidDataError, 'Only OS X Self Service Items can have custom button text' unless self.class::SELF_SERVICE_TARGET == :macos
      @self_service_install_button_text = new_val.strip
      @need_to_update = true
    end

    ### @param new_val[Boolean] should this appear on the main SelfSvc page?
    ###
    ### @return [void]
    ###
    def self_service_feature_on_main_page=(new_val)
      return nil if @self_service_feature_on_main_page == new_val
      raise JSS::InvalidDataError, 'New value must be true or false' unless JSS::TRUE_FALSE.include? new_val
      @self_service_feature_on_main_page = new_val
      @need_to_update = true
    end

    ### @param new_val[Boolean] should this appear on the main SelfSvc page?
    ###
    ### @return [void]
    ###
    def self_service_force_users_to_view_description=(new_val)
      return nil if @self_service_force_users_to_view_description == new_val
      raise JSS::InvalidDataError, 'Only OS X Self Service Items can force users to view description' unless self.class::SELF_SERVICE_TARGET == :macos
      raise JSS::InvalidDataError, 'New value must be true or false' unless JSS::TRUE_FALSE.include? new_val
      @self_service_force_users_to_view_description = new_val
      @need_to_update = true
    end

    ### Add or change one of the categories for this item in SSvc.
    ###
    ### @param new_cat[String] the name of a category for this item in SelfSvc
    ###
    ### @param display_in[Boolean] should this item appear in the SelfSvc page for the new category?
    ###
    ### @param feature_in[Boolean] should this item be featured in the SelfSvc page for the new category?
    ###
    ### @return [void]
    ###
    def add_self_service_category(new_cat, display_in: true, feature_in: false)
      new_cat.strip!
      raise JSS::NoSuchItemError, "No category '#{new_cat}' in the JSS" unless JSS::Category.all_names(:refresh).include? new_cat
      raise JSS::InvalidDataError, 'display_in must be true or false' unless JSS::TRUE_FALSE.include? display_in
      raise JSS::InvalidDataError, 'feature_in must be true or false' unless JSS::TRUE_FALSE.include? feature_in

      new_data = { name: new_cat, display_in: display_in, feature_in: feature_in }

      # see if this category is already among our categories.
      idx = @self_service_categories.index { |c| c[:name] == new_cat }

      if idx
        @self_service_categories[idx] = new_data
      else
        @self_service_categories << new_data
      end

      @need_to_update = true
    end

    ### Remove a category from those for this item in SSvc
    ###
    ### @param cat [String] the name of the category to remove
    ###
    ### @return [void]
    ###
    def remove_self_service_category(cat)
      @self_service_categories.reject! { |c| c[:name] == cat }
      @need_to_update = true
    end

    ### @api private
    ###
    ### Return a REXML <location> element to be
    ### included in the rest_xml of
    ### objects that have a Location subset
    ###
    ### @return [REXML::Element]
    ###
    def self_service_xml
      ssvc = REXML::Element.new('self_service')

      ssvc.add_element('self_service_description').text = @self_service_description
      ssvc.add_element('feature_on_main_page').text = @self_service_feature_on_main_page

      cats = ssvc.add_element('self_service_categories')
      @self_service_categories.each do |cat|
        catelem = cats.add_element('category')
        catelem.add_element('name').text = cat[:name]
        catelem.add_element('display_in').text = cat[:display_in] if cat.keys.include? :display_in
        catelem.add_element('feature_in').text = cat[:feature_in] if cat.keys.include? :feature_in
      end

      icon = ssvc.add_element('self_service_icon')
      @self_service_icon.each { |key, val|  icon.add_element(key.to_s).text = val }

      unless @self_service_security.empty?
        sec = ssvc.add_element('security')
        sec.add_element('removal_disallowed').text = @self_service_security[:removal_disallowed] if @self_service_security[:removal_disallowed]
        sec.add_element('password').text = @self_service_security[:password] if @self_service_security[:password]
      end

      ssvc.add_element('install_button_text').text = @self_service_install_button_text if @self_service_install_button_text
      ssvc.add_element('force_users_to_view_description').text = @self_service_force_users_to_view_description \
        unless @self_service_force_users_to_view_description.nil?

      ssvc
    end

    ### aliases
    alias change_self_service_category add_self_service_category

  end # module SelfServable

end # module JSS
