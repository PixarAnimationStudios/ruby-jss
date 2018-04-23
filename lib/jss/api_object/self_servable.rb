
### Copyright 2018 Pixar

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

require 'jss/api_object/self_servable/icon'

###
module JSS

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Sub-Modules
  #####################################

  # A mix-in module for handling Self Service data for objects in the JSS.
  #
  # The JSS objects that have Self Service data return it in a :self_service subset,
  # which have somewhat similar data, i.e. a hash with at least these keys:
  # - :self_service_description
  # - :self_service_icon
  # - :feature_on_main_page
  # - :self_service_categories
  #
  # Config Profiles in self service have this key:
  # - :security
  #
  # Additionally, items that apper in macOS Slf Svc have these keys:
  # - :self_service_display_name
  # - :install_button_text
  # - :reinstall_button_text
  # - :force_users_to_view_description
  # - :notification
  # - :notification_location # PENDING API FIX
  # - :notification_subject
  # - :notification_message
  #
  # See the attribute definitions for details of these values and structures.
  #
  # Including this module in an {APIObject} subclass will give it matching
  # attributes with 'self_service_' appended if needed,
  # e.g. {#self_service_feature_on_main_page}
  #
  #
  # Classes including this module *MUST*:
  # - call {#add_self_service_xml(xmldoc)} in their #rest_xml method
  #
  # IMPORTANT: Since SelfServable also includes #{JSS::Uploadable}, for uploading icons,
  # see that module for its requirements.
  #
  #
  module SelfServable

    include Uploadable

    #  Constants
    #####################################

    SELF_SERVABLE = true

    PROFILE_REMOVAL_BY_USER = {
      always: 'Always',
      never: 'Never',
      with_auth: 'With Authorization'
    }.freeze

    MAKE_AVAILABLE = 'Make Available in Self Service'.freeze
    AUTO_INSTALL = 'Install Automatically'.freeze
    AUTO_INSTALL_OR_PROMPT = 'Install Automatically/Prompt Users to Install'.freeze
    PATCHPOL_SELF_SERVICE = 'selfservice'.freeze # 'Make Available in Self Service' in the UI
    PATCHPOL_AUTO = 'prompt'.freeze # 'Install Automatically' in the UI

    DEFAULT_INSTALL_BUTTON_TEXT = 'Install'.freeze
    DEFAULT_REINSTALL_BUTTON_TEXT = 'Reinstall'.freeze
    DEFAULT_FORCE_TO_VIEW_DESC = false

    NOTIFICATION_OPTIONS = {
      off: 'off',
      ssvc_only: 'Self Service',
      ssvc_and_nctr: 'Self Service and Notification Center'
    }.freeze
    NOTIFICATION_DEFAULT = :off

    # This hash contains the details about the inconsistencies of how
    # Self Service data is dealt with in the API data of the different
    # self-servable classes.
    #
    #  - in_self_service_data_path: Array, In the API data hash (the @init_data)
    #      where to find the value indicicating that a thing is in self service.
    #      e.g. [:self_service, :use_for_self_service] means
    #      @init_data[:self_service][:use_for_self_service]
    #
    #  - in_self_service: Object, In the path defined above, what value means
    #      the thing IS in self service
    #
    #  - not_in_self_service: Object, In the path defined above, what value means
    #      the thing IS NOT in self service
    #
    #  - self_service_subset: Symbol.  Which key of the init data hash contains
    #    the self service data. If not defined, its :self_service, but
    #    PatchPolcies use :user_interaction
    #
    #  - targets: Array<Symbol>, the array contains either :macos, :ios, or both.
    #
    #  - payload: Symbol, The thing that is deployed by self service, one of:
    #     :policy, :app, :profile, :patchpolicy (ebooks are considered apps)
    #
    #  - can_display_in_categories: Boolean, when adding 'self service categories'
    #    can the thing be 'displayed in' those categories?
    #
    #  - can_feature_in_categories: Boolean, when adding 'self service categories'
    #    can the thing be 'featured in' those categories?
    #
    # It's unfortunate that this is needed in order to keep all the
    # self service ruby code in this one module.
    #
    SELF_SERVICE_CLASSES = {
      JSS::Policy => {
        in_self_service_data_path: %i[self_service use_for_self_service],
        in_self_service: true,
        not_in_self_service: false,
        targets: [:macos],
        payload: :policy,
        can_display_in_categories: true,
        can_feature_in_categories: true
      },
      JSS::PatchPolicy => {
        in_self_service_data_path: %i[general distribution_method],
        in_self_service: PATCHPOL_SELF_SERVICE,
        not_in_self_service: PATCHPOL_AUTO,
        self_service_subset: :user_interaction,
        targets: [:macos],
        payload: :patchpolicy,
        can_display_in_categories: false,
        can_feature_in_categories: false
      },
      JSS::MacApplication => { # TODO: add the correct values when Jamf fixes this bug
        in_self_service_data_path: nil, # [:general, :distribution_method],
        in_self_service: nil, # MAKE_AVAILABLE,
        not_in_self_service: nil, # AUTO_INSTALL_OR_PROMPT,
        targets: [:macos],
        payload: :app,
        can_display_in_categories: true,
        can_feature_in_categories: true
      },
      JSS::OSXConfigurationProfile => {
        in_self_service_data_path: %i[general distribution_method],
        in_self_service: MAKE_AVAILABLE,
        not_in_self_service: AUTO_INSTALL,
        targets: [:macos],
        payload: :profile,
        can_display_in_categories: true,
        can_feature_in_categories: true
      },
      JSS::EBook => {
        in_self_service_data_path: %i[general deployment_type],
        in_self_service: MAKE_AVAILABLE,
        not_in_self_service: AUTO_INSTALL_OR_PROMPT,
        targets: %i[macos ios],
        payload: :app, # ebooks are handled the same way as apps, it seems,
        can_display_in_categories: true,
        can_feature_in_categories: true
      },
      JSS::MobileDeviceApplication => {
        in_self_service_data_path: %i[general deployment_type],
        in_self_service: MAKE_AVAILABLE,
        not_in_self_service: AUTO_INSTALL_OR_PROMPT,
        targets: [:ios],
        payload: :app,
        can_display_in_categories: true,
        can_feature_in_categories: false
      },
      JSS::MobileDeviceConfigurationProfile => {
        in_self_service_data_path: %i[general deployment_method],
        in_self_service: MAKE_AVAILABLE,
        not_in_self_service: AUTO_INSTALL,
        targets: [:ios],
        payload: :profile,
        can_display_in_categories: false,
        can_feature_in_categories: false
      }
    }.freeze

    #  Variables
    #####################################

    #  Mixed-in Attributes
    #####################################

    # @return [Boolean] Is this thing available in Self Service?
    attr_reader :in_self_service
    alias in_self_service? in_self_service

    # @return [JSS::Icon, nil] The icon used in self-service
    attr_reader :icon
    alias self_service_icon icon

    # @return [String] The name to display in macOS Self Service.
    attr_reader :self_service_display_name

    # @return [String] The verbage that appears in SelfSvc for this item
    attr_reader :self_service_description

    # @return [Boolean] Should this item feature on the main page of SSvc?
    # Only applicable to macOS targets
    attr_reader :self_service_feature_on_main_page

    # @return [Array<Hash>] The categories in which this item should appear in SSvc
    #
    # Each Hash has these keys about the category
    # - :id => [Integer] the JSS id of the category
    # - :name => [String] the name of the category
    #
    # Most objects also include one or both of these keys:
    # - :display_in => [Boolean] should the item be displayed in this category in SSvc? (not MobDevConfProfiles)
    # - :feature_in => [Boolean] should the item be featured in this category in SSVC? (macOS targets only)
    #
    attr_reader :self_service_categories

    # Profiles in Self Service have an option to allow the user to remove them
    # and for iOS profiles, if authentication is required to do so, and if so,
    # the password needed for removal.
    #
    # This data is held in the :security Hash of the selfsvc data.
    # The keys are:
    # - :removal_disallowed, which should be "removal allowed"
    # - :password => [String] if :removal_disallowed is "With Authorization",
    #   this contains the passwd (in plaintext) needed to remove the profile.
    #
    # NOTE that the key should be called :removal_allowed, since 'Never' means it can't be removed.
    #
    # These values are stored in the next two attributes.

    # @return [Symbol] one of the keys in PROFILE_REMOVAL_BY_USER
    attr_reader :self_service_user_removable

    # @return [String] The password needed for removal, in plain text.
    attr_reader :self_service_removal_password

    # @return [String] The text label on the install button in SSvc (OSX SSvc only)
    # defaults to 'Install'
    attr_reader :self_service_install_button_text

    # @return [String] The text label on the reinstall button in SSvc (OSX SSvc only)
    # defaults to 'Reinstall'
    attr_reader :self_service_reinstall_button_text

    # @return [Boolean] Should an extra window appear before the user can install the item? (OSX SSvc only)
    attr_reader :self_service_force_users_to_view_description

    # @return [Symbol] Should this policy send notifications, and if so, where?
    #   one of: :off, :ssvc_only or :ssvc_and_nctr
    attr_reader :self_service_notifications

    # @return [String] The subject text of the notification. Defaults to the
    # object name.
    attr_reader :self_service_notification_subject

    # @return [String] The message text of the notification
    attr_reader :self_service_notification_message

    #  Mixed-in Public Instance Methods
    #####################################

    # Setters
    #

    # @param new_val[String] the new discription
    #
    # @return [void]
    #
    def self_service_description=(new_val)
      new_val.strip!
      return if @self_service_description == new_val
      @self_service_description = new_val
      @need_to_update = true
    end

    # @param new_val[String] The display name of the item in SSvc
    #
    # @return [void]
    #
    def self_service_dislay_name=(new_val)
      new_val.strip!
      return nil if @self_service_dislay_name == new_val
      raise JSS::InvalidDataError, 'Only macOS Self Service items have display names' unless self_service_targets.include? :macos
      @self_service_dislay_name = new_val
      @need_to_update = true
    end

    # @param new_val[String] the new install button text
    #
    # @return [void]
    #
    def self_service_install_button_text=(new_val)
      new_val.strip!
      return nil if @self_service_install_button_text == new_val
      raise JSS::InvalidDataError, 'Only macOS Self Service Items can have custom button text' unless self_service_targets.include? :macos
      @self_service_install_button_text = new_val
      @need_to_update = true
    end

    # @param new_val[String] the new reinstall button text
    #
    # @return [void]
    #
    def self_service_reinstall_button_text=(new_val)
      new_val.strip!
      return nil if @self_service_reinstall_button_text == new_val
      raise JSS::InvalidDataError, 'Only macOS Self Service Items can have custom button text' unless self_service_targets.include? :macos
      @self_service_reinstall_button_text = new_val
      @need_to_update = true
    end

    # @param new_val[Boolean] should this appear on the main SelfSvc page?
    #
    # @return [void]
    #
    def self_service_feature_on_main_page=(new_val)
      return nil if @self_service_feature_on_main_page == new_val
      return nil unless @self_service_data_config[:can_feature_in_categories]
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @self_service_feature_on_main_page = new_val
      @need_to_update = true
    end

    # @param new_val[Boolean] Should the description be shown to users in a new
    #  window before executing the payload?
    #
    # @return [void]
    #
    def self_service_force_users_to_view_description=(new_val)
      return nil if @self_service_force_users_to_view_description == new_val
      raise JSS::InvalidDataError, 'Only macOS Self Service Items can force users to view description' unless self_service_targets.include? :macos
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @self_service_force_users_to_view_description = new_val
      @need_to_update = true
    end

    # Add or change one of the categories for this item in self service
    #
    # @param new_cat[String, Integer] the name or id of a category where this
    #   object should appear in SelfSvc
    #
    # @param display_in[Boolean] should this item appear in the SelfSvc page for
    #  the category? Only meaningful in applicable classes
    #
    # @param feature_in[Boolean] should this item be featured in the SelfSvc page
    #   for the category? Only meaningful in applicable classes.
    #   NOTE: this will always be false if display_in is false.
    #
    # @return [void]
    #
    def add_self_service_category(new_cat, display_in: true, feature_in: false)
      new_cat = JSS::Category.map_all_ids_to(:name, api: @api)[new_cat] if new_cat.is_a? Integer
      feature_in = false if display_in == false
      raise JSS::NoSuchItemError, "No category '#{new_cat}' in the JSS" unless JSS::Category.all_names(:refresh, api: @api).include? new_cat

      raise JSS::InvalidDataError, 'display_in must be true or false' unless display_in.jss_boolean?

      raise JSS::InvalidDataError, 'feature_in must be true or false' unless feature_in.jss_boolean?

      new_data = { name: new_cat }
      new_data[:display_in] = display_in if @self_service_data_config[:can_display_in_categories]
      new_data[:feature_in] = feature_in if @self_service_data_config[:can_feature_in_categories]

      # see if this category is already among our categories.
      idx = @self_service_categories.index { |c| c[:name] == new_cat }

      if idx
        @self_service_categories[idx] = new_data
      else
        @self_service_categories << new_data
      end

      @need_to_update = true
    end
    alias set_self_service_category add_self_service_category

    # Remove a category from those for this item in SSvc
    #
    # @param cat [String, Integer] the name or id of the category to remove
    #
    # @return [void]
    #
    def remove_self_service_category(cat)
      @self_service_categories.reject! { |c| c[:name] == cat || c[:id] == cat }
      @need_to_update = true
    end

    # Set the value for user-removability of profiles, optionally
    # providing a password for removal, on iOS targets.
    #
    # @param new_val[Symbol] One of the keys of PROFILE_REMOVAL_BY_USER,
    #   :always, :never, or :with_auth
    #
    # @param pw[String] A new password to use if removable :with_auth
    #
    # @return [void]
    #
    def self_service_user_removable=(new_val, pw = @self_service_removal_password)
      new_val, pw = *new_val if new_val.is_a? Array
      pw = nil unless new_val == :with_auth

      return nil if new_val == self_service_user_removable && pw == self_service_removal_password

      validate_user_removable new_val

      @self_service_user_removable = new_val
      @self_service_removal_password = pw
      @need_to_update = true
    end

    # Where should self service notifications be displayed, if at all
    # HACK: Until jamf fixes bugs, you can only set notifications
    # :off or :ssvc_only. If you want :ssvc_and_nctr, you must
    # check the checkbox in the web-UI.
    #
    # @param location[Symbol] A key from SelfServable::NOTIFICATION_OPTIONS
    #
    # @return [void]
    #
    def self_service_notifications=(location)
      raise JSS::UnsupportedError, 'Only macOS Self Service Items can have self service notifications' unless self_service_targets.include? :macos

      raise JSS::InvalidDataError, "Location must be one of: :#{NOTIFICATION_OPTIONS.keys.join ', :'}" unless NOTIFICATION_OPTIONS.keys.include? location

      # HACK: Until jamf fixes bugs, you can only set notifications
      # :off or :ssvc_only. If you want :ssvc_and_nctr, you must
      # check the checkbox in the web-UI.
      raise 'Jamf Bug: Until Jamf fixes API bugs, you can only set Self Service notifications to :off or :ssvc_only. Use the WebUI to activate Notification Center notifications' unless %i[off ssvc_only].include? location

      @self_service_notifications = location
      @need_to_update = true
    end

    # @param subj[String] The subject text for the notification
    #
    # @return [void]
    #
    def self_service_notification_subject=(subj)
      raise JSS::UnsupportedError, 'Only macOS Self Service Items can have self service notifications' unless self_service_targets.include? :macos
      subj.strip!
      return nil if subj == @self_service_notification_subject
      @self_service_notification_subject = subj
      @need_to_update = true
    end

    # @param msg[String] The message text for the notification
    #
    # @return [void]
    #
    def self_service_notification_message=(msg)
      raise JSS::UnsupportedError, 'Only macOS Self Service Items can have self service notifications' unless self_service_targets.include? :macos
      msg.strip!
      return nil if msg == @self_service_notification_message
      @self_service_notification_message = msg
      @need_to_update = true
    end

    # Set a new Self Service icon for this object.
    #
    # Since JSS::Icon objects are read-only,
    # the icon can only be changed by supplying the id number
    # of an icon already existing in the JSS, or a path to
    # a local file, which will be uploaded to the JSS and added
    # to this instance.  Uploads
    # take effect immediately, but if an integer is supplied, the change
    # must be sent to the JSS via {#update} or {#create}
    #
    # @param new_icon[Integer, String, Pathname] The id or path to the new icon.
    #
    # @return [false, Integer, Pathname] false means no change was made.
    #
    def icon=(new_icon)
      if new_icon.is_a? Integer
        return if @icon && new_icon == @icon.id
        validate_icon new_icon
        @new_icon_id = new_icon
        @need_to_update = true
      else
        unless uploadable? && defined?(self.class::UPLOAD_TYPES) && self.class::UPLOAD_TYPES.keys.include?(:icon)
          raise JSS::UnsupportedError, "Class #{self.class} does not support icon uploads."
        end
        new_icon = Pathname.new new_icon
        upload(:icon, new_icon)
        refresh_icon
      end # new_icon.is_a? Integer
      new_icon
    end # icon =
    alias self_service_icon= icon=
    alias assign_icon icon=

    # Add this object to self service if not already there.
    #
    # @return [void]
    #
    def add_to_self_service
      return nil unless @self_service_data_config[:in_self_service_data_path]
      return nil if in_self_service?
      @in_self_service = true
      @need_to_update = true
    end

    # Remove this object from self service if it's there.
    #
    # @return [void]
    #
    def remove_from_self_service
      return nil unless @self_service_data_config[:in_self_service_data_path]
      return nil unless in_self_service?
      @in_self_service = false
      @need_to_update = true
    end

    # Can this thing be removed by the user?
    #
    # @return [Boolean, nil] nil means 'not applicable'
    #
    def user_removable?
      return nil unless self_service_payload == :profile
      @self_service_user_removable != :never
    end

    # What devices types can get this thing in Self Service
    #
    # @return [Array<Symbol>] An array of :macos, :ios, or both.
    #
    def self_service_targets
      @self_service_data_config[:targets]
    end

    # What does this object deploy to the device
    # via self service?
    #
    # @return [Symbol] :profile, :app, or :policy
    #
    def self_service_payload
      @self_service_data_config[:payload]
    end

    #  Mixed-in Private Instance Methods
    #####################################
    private

    # Call this during initialization of
    # objects that have a self_service subset
    # and the self_service attributes will be populated
    # (as primary attributes) from @init_data
    #
    # @return [void]
    #
    def parse_self_service
      @self_service_data_config = SELF_SERVICE_CLASSES[self.class]

      subset_key = @self_service_data_config[:self_service_subset] ? @self_service_data_config[:self_service_subset] : :self_service

      ss_data = @init_data[subset_key]
      ss_data ||= {}

      @in_self_service = in_self_service_at_init?

      if ss_data[:security]
        removable_value = ss_data[:security][:removal_disallowed]
        @self_service_user_removable = PROFILE_REMOVAL_BY_USER.invert[removable_value]
        @self_service_removal_password = ss_data[:security][:password]
      end

      @self_service_description = ss_data[:self_service_description]

      @icon = JSS::Icon.new(ss_data[:self_service_icon]) if ss_data[:self_service_icon]

      @self_service_feature_on_main_page = ss_data[:feature_on_main_page]
      @self_service_feature_on_main_page ||= false

      @self_service_categories = ss_data[:self_service_categories]
      @self_service_categories ||= []

      return unless self_service_targets.include? :macos

      # Computers only...
      @self_service_display_name = ss_data[:self_service_display_name]
      @self_service_display_name ||= name

      @self_service_install_button_text = ss_data[:install_button_text]
      @self_service_install_button_text ||= DEFAULT_INSTALL_BUTTON_TEXT

      @self_service_reinstall_button_text = ss_data[:reinstall_button_text]
      @self_service_reinstall_button_text ||= DEFAULT_REINSTALL_BUTTON_TEXT

      @self_service_force_users_to_view_description = ss_data[:force_users_to_view_description]
      @self_service_force_users_to_view_description ||= DEFAULT_FORCE_TO_VIEW_DESC

      # HACK: Workaround until jamf fixes bugs.
      # when its fixed, here's how
      #
      # @self_service_notifications =
      #  if ss_data[:notification] == false
      #    :off
      #  else
      #    NOTIFICATION_OPTIONS.invert[ss_data[:notification_location]]
      #  end
      #
      #
      ss_xml = @api.get_rsrc("#{rest_rsrc}/subset/selfservice", :xml)
      @self_service_notifications =
        if ss_xml.include?('<notification>false</notification>')
          :off
        elsif ss_xml.include? "<notification>#{NOTIFICATION_OPTIONS[:ssvc_and_nctr]}</notification>"
          :ssvc_and_nctr
        else
          :ssvc_only
        end

      # end hacks
      @self_service_notification_subject = ss_data[:notification_subject]
      @self_service_notification_subject ||= name

      @self_service_notification_message = ss_data[:notification_message]
    end # parse

    # Figure out if this object is in Self Service, from the API
    # initialization data.
    # Alas, how to do it is far from consistent
    #
    # @return [Boolean]
    #
    def in_self_service_at_init?
      return nil unless @self_service_data_config[:in_self_service_data_path]
      subsection, key = @self_service_data_config[:in_self_service_data_path]
      return false unless @init_data[subsection]
      @init_data[subsection][key] == @self_service_data_config[:in_self_service]
    end

    def validate_user_removable(new_val)
      raise JSS::UnsupportedError, 'User removal settings not applicable to this class' unless self_service_payload == :profile

      raise JSS::UnsupportedError, 'Removal :with_auth not applicable to this class' if new_val == :with_auth && !self_service_targets.include?(:ios)

      raise JSS::InvalidDataError, "Value must be one of: :#{PROFILE_REMOVAL_BY_USER.keys.join(', :')}" unless PROFILE_REMOVAL_BY_USER.keys.include? new_val
    end

    def validate_icon(id)
      return nil unless JSS::DB_CNX.connected?
      raise JSS::NoSuchItemError, "No icon with id #{id}" unless JSS::Icon.all_ids.include? id
    end

    # Re-read the icon data for this object from the API
    # Generally done after uploading a new icon via {#icon=}
    #
    # @return [void]
    #
    def refresh_icon
      return nil unless @in_jss
      fresh_data = @api.get_rsrc(@rest_rsrc)[self.class::RSRC_OBJECT_KEY]
      icon_data = fresh_data[:self_service][:self_service_icon]
      @icon = JSS::Icon.new icon_data
    end # refresh icon

    # Add a REXML <self_service> element to the root of the provided REXML::Document
    #
    # @param xdoc[REXML::Document] The XML Document to which we're adding a Self
    #   Service subsection
    #
    # @return [void]
    #
    def add_self_service_xml(xdoc)
      doc_root = xdoc.root
      ssvc = doc_root.add_element 'self_service'

      ssvc.add_element('self_service_description').text = @self_service_description if @self_service_description
      ssvc.add_element('feature_on_main_page').text = @self_service_feature_on_main_page

      if @new_icon_id
        icon = ssvc.add_element('self_service_icon')
        icon.add_element('id').text = @new_icon_id
      end

      cats = ssvc.add_element('self_service_categories')
      if @self_service_categories
        @self_service_categories.each do |cat|
          catelem = cats.add_element('category')
          catelem.add_element('name').text = cat[:name]
          catelem.add_element('display_in').text = cat[:display_in] if @self_service_data_config[:can_display_in_categories]
          catelem.add_element('feature_in').text = cat[:feature_in] if @self_service_data_config[:can_feature_in_categories]
        end
      end

      if self_service_targets.include? :macos
        ssvc.add_element('self_service_display_name').text = @self_service_display_name if @self_service_display_name
        ssvc.add_element('install_button_text').text = @self_service_install_button_text if @self_service_install_button_text
        ssvc.add_element('reinstall_button_text').text = @self_service_reinstall_button_text if @self_service_reinstall_button_text
        ssvc.add_element('force_users_to_view_description').text = @self_service_force_users_to_view_description.to_s

        # HACK: until jamf fixes bugs
        # put the location info into 'notification'.
        # the real 'notification' value will be PUT again
        # after seprattely after this.
        #
        # w/o hack:
        #
        # ssvc.add_element('notification').text =
        #   if self_service_notifications == :off
        #     'false'
        #   else
        #     'true'
        #   end
        #
        # ssvc.add_element('notification_location').text = NOTIFICATION_OPTIONS[self_service_notifications]
        #
        ssvc.add_element('notification').text =
          if self_service_notifications == :off
            'false'
          else
            @need_ss_notification_activation_hack = true
            NOTIFICATION_OPTIONS[self_service_notifications]
          end

        ssvc.add_element('notification_subject').text = @self_service_notification_subject
        ssvc.add_element('notification_message').text = @self_service_notification_message if @self_service_notification_message
      end # if self_service_targets.include? :macos

      if self_service_payload == :profile
        if self_service_targets.include? :ios
          sec = ssvc.add_element('security')
          sec.add_element('removal_disallowed').text = PROFILE_REMOVAL_BY_USER[@self_service_user_removable]
          sec.add_element('password').text = @self_service_removal_password.to_s
        else
          gen = doc_root.elements['general']
          gen.add_element('user_removable').text = (@self_service_user_removable == :always).to_s
        end
      end

      return unless @self_service_data_config[:in_self_service_data_path]

      in_ss_section, in_ss_elem = @self_service_data_config[:in_self_service_data_path]

      in_ss_value = @in_self_service ? @self_service_data_config[:in_self_service] : @self_service_data_config[:not_in_self_service]

      in_ss_section_xml = doc_root.elements[in_ss_section.to_s]
      in_ss_section_xml ||= doc_root.add_element(in_ss_section.to_s)
      in_ss_section_xml.add_element(in_ss_elem.to_s).text = in_ss_value.to_s
    end # add_self_service_xml

    # aliases
    alias change_self_service_category add_self_service_category

    # HACK: ity hack hack...
    # remove when jamf fixes these bugs
    def update
      resp = super
      force_notifications_on if @need_ss_notification_activation_hack
      resp
    end

    # HACK: ity hack hack...
    # remove when jamf fixes these bugs
    def create
      resp = super
      force_notifications_on if @need_ss_notification_activation_hack
      resp
    end

    # HACK: ity hack hack...
    # remove when jamf fixes these bugs
    def force_notifications_on
      xml = <<-ENDXML
<#{self.class::RSRC_OBJECT_KEY}>
  <self_service>
    <notification>true</notification>
  </self_service>
</#{self.class::RSRC_OBJECT_KEY}>
      ENDXML
      @api.put_rsrc rest_rsrc, xml
      @need_ss_notification_activation_hack = nil
    end

  end # module SelfServable

end # module JSS
