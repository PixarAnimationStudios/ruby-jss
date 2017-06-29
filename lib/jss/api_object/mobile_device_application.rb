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

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Mobile Device Application in the JSS
  #
  class MobileDeviceApplication < JSS::APIObject

    # Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include JSS::Scopable
    include JSS::SelfServable
    include JSS::Categorizable
    include JSS::Uploadable
    include JSS::VPPable

    # Class Methods
    #####################################

    def self.all_bundle_ids(refresh = false)
      all(refresh).map { |mda| mda[:bundle_id] }
    end

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'mobiledeviceapplications'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_applications

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_application

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:internal_app].freeze

    # See JSS::Scopable
    SCOPE_TARGET_KEY = :mobile_devices

    # see JSS::Uploadable
    UPLOAD_TYPES = {
      icon: :mobiledeviceapplicationsicon,
      app: :mobiledeviceapplicationsipa,
      attachment: :mobiledeviceapplications
    }.freeze

    # see JSS::APIObject
    OTHER_LOOKUP_KEYS = {
      bundleid: {rsrc_id: :bundleid, list: :all_bundle_ids},
      bundle_id: {rsrc_id: :bundleid, list: :all_bundle_ids}
    }.freeze

    # Attributes
    #####################################

    # NOTE: the API data contains an :icon hash in the :general subsection
    # but it appears to be redundant with the one in the :self_service subsection.
    # When an icon is uploaded with Uploadable, both arae changed.
    # Also, mobiledeviceapplications are the only objects with such a 'top-level'
    # icon, any other objects with icons keep the icon data in :self_service.
    # As such, all icon handling for this class is done in the SelfServable module


    # @return [String] The user-facing name (i.e. in self service)
    attr_reader :display_name

    # @return [String]
    attr_reader :description

    # @return [String] e.g. com.company.appname
    attr_reader :bundle_id

    # @return [String]
    attr_reader :version

    # @return [Boolean]
    attr_reader :internal_app

    # @return [Hash] The .ipa file info
    attr_reader :ipa

    # @return [Hash] The provisioning profile info for this app
    attr_reader :provisioning_profile

    # @return [String] The URL for downloading this app
    attr_reader :url

    # @return [String] The URL of this item in the iTunes store, if applicable
    attr_reader :itunes_store_url

    # @return [Boolean] Will this still appear in SelfSvc after installation (I think)
    attr_reader :make_available_after_install
    alias self_service_make_available_after_install make_available_after_install

    # @return [String] The app's country/region code in the iTunes store
    attr_reader :itunes_country_region

    # @return [Integer] The last time the app and data was synced from iTunes (I think)
    attr_reader :itunes_sync_time

    # @return [Boolean] Should this app be mananged?
    attr_reader :deploy_as_managed_app

    # @return [Boolean] Should the app be removed when the device is unmanaged?
    attr_reader :remove_app_when_mdm_profile_is_removed

    # @return [Boolean] Should this app be able to backup its data when the device
    #   does its backups (to icloud or itunes)?
    attr_reader :prevent_backup_of_app_data

    # @return [Boolean] should the JSS update the icon and description from the app
    #   source?
    attr_reader :keep_description_and_icon_up_to_date

    # @return [Boolean] is this a free app?
    attr_reader :free
    alias free? free

    # @return [Boolean] If the user installs this app on their own, should Jamf
    #   take over managing it?
    attr_reader :take_over_management

    # @return [Boolean] Does the app itself come from outside the JSS?
    attr_reader :host_externally

    # @return [String] If :host_externally is true, the URL for the app
    attr_reader :external_url

    # @return [String] Pre-configuration data for installing the app.
    #   Currently there's only one key in the :configuration hash, :preferences,
    #   which contains a plist <dict> element with config data.
    attr_reader :configuration_prefs


    # Constructor
    #####################################

    #
    # See JSS::APIObject#initialize
    #
    def initialize(args)
      super
      general = @init_data[:general]
      @display_name = general[:display_name]
      @description = general[:description]
      @bundle_id = general[:bundle_id] # TODO: does this get set automatically when uploading a .ipa?
      @version = general[:version] # TODO: does this get set automatically when uploading a .ipa?
      @ipa = general[:ipa]
      @provisioning_profile = general[:provisioning_profile]
      @url = general[:url]
      @itunes_store_url = general[:itunes_store_url]
      @make_available_after_install = general[:make_available_after_install]
      @itunes_country_region = general[:itunes_country_region]
      @itunes_sync_time = general[:itunes_sync_time]
      @deploy_as_managed_app = general[:deploy_as_managed_app]
      @remove_app_when_mdm_profile_is_removed = general[:remove_app_when_mdm_profile_is_removed]
      @prevent_backup_of_app_data = general[:prevent_backup_of_app_data]
      @keep_description_and_icon_up_to_date = general[:keep_description_and_icon_up_to_date]
      @free = general[:free]
      @take_over_management = general[:take_over_management]
      @host_externally = general[:host_externally]
      @external_url = general[:external_url]
      @configuration_prefs = @init_data[:app_configuration][:preferences]
    end

    # Public Instance Methods
    #####################################

    # Setters
    ################

    # Set the display_name
    #
    # @param new_val[#to_s] The new value
    #
    # @return [void]
    #
    def display_name=(new_val)
      return nil if new_val.to_s == @display_name
      @display_name = new_val.to_s
      @need_to_update = true
    end


    # Set the description
    #
    # @param new_val[String] The new value
    #
    # @return [void]
    #
    def description=(new_val)
      return nil if new_val.to_s == @description
      @description = new_val.to_s
      @need_to_update = true
    end

    # Set the url
    #
    # @param new_val[String] The new value
    #
    # @return [void]
    #
    def url=(new_val)
      return nil if new_val == @url
      @url = new_val
      @need_to_update = true
    end

    # Set whether or not this app should be available
    # in Self Service after being installed. (e.g. for removal)
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def make_available_after_install=(new_val)
      return nil if new_val == @make_available_after_install
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @make_available_after_install = new_val
      @need_to_update = true
    end
    alias self_service_make_available_after_install= make_available_after_install=

    # Set whether or not this app should be deployed as managed
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def deploy_as_managed_app=(new_val)
      return nil if new_val == @deploy_as_managed_app
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @deploy_as_managed_app = new_val
      @need_to_update = true
    end


    # Set whether or not this app should be removed when
    # the device is unmanaged
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def remove_app_when_mdm_profile_is_removed=(new_val)
      return nil if new_val == @remove_app_when_mdm_profile_is_removed
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @remove_app_when_mdm_profile_is_removed = new_val
      @need_to_update = true
    end

    # Set whether or not the device should back up this app's data
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def prevent_backup_of_app_data=(new_val)
      return nil if new_val == @prevent_backup_of_app_data
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @prevent_backup_of_app_data = new_val
      @need_to_update = true
    end


    # Set whether or not the jss should update info about this app from the app store
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def keep_description_and_icon_up_to_date=(new_val)
      return nil if new_val == @keep_description_and_icon_up_to_date
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @keep_description_and_icon_up_to_date = new_val
      @need_to_update = true
    end

    # Set whether or not this is a free app
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def free=(new_val)
      return nil if new_val == @free
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @free = new_val
      @need_to_update = true
    end

    # Set whether or not Jamf should manage this app even if the user installed
    # it on their own.
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def take_over_management=(new_val)
      return nil if new_val == @take_over_management
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @take_over_management = new_val
      @need_to_update = true
    end

    # Set whether or not this app's .ipa is hosted outside the Jamf server
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def host_externally=(new_val)
      return nil if new_val == @host_externally
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @host_externally = new_val
      @need_to_update = true
    end

    # Set the url to use for the app if host_externally is true
    #
    # @param new_val[String] The new value
    #
    # @return [void]
    #
    def external_url=(new_val)
      return nil if new_val == @external_url
      @external_url = new_val
      @need_to_update = true
    end

    # Set the configuration prefs for this app. The value
    # must be a <dict> element from a plist
    #
    # @param new_val[String] The new value
    #
    # @return [void]
    #
    def configuration_prefs=(new_val)
      return nil if new_val == @configuration_prefs
      @configuration_prefs = new_val
      @need_to_update = true
    end


    # Save the application to a file.
    #
    # @param path[Pathname, String] The path to which the file should be saved.
    # If the path given is an existing directory, the ipa's current filename will
    # be used, if known.
    #
    # @param overwrite[Boolean] Overwrite the file if it exists? Defaults to false
    #
    # @return [void]
    #
    def save_ipa(path, overwrite = false)
      return nil unless @ipa[:data]
      path = Pathname.new path
      path = path + @ipa[:name] if path.directory? && @ipa[:name]

      raise JSS::AlreadyExistsError, "The file #{path} already exists" if path.exist? && !overwrite
      path.delete if path.exist?
      path.jss_save Base64.decode64(@ipa[:data])
    end

    # Upload a new app .ipa file
    #
    # @param path[String, Pathname] The path to the .ipa file to upload
    #
    # @return [void]
    #
    def upload_ipa(path)
      new_ipa = Pathname.new path
      upload(:app, new_icon)
      refresh_ipa
    end

    # Private Instance Methods
    ###########################################
    private

    # Re-read the ipa data from the API.
    #
    # @return [Type] description_of_returned_object
    #
    def refresh_ipa
      return nil unless @in_jss
      fresh_data = JSS.api_connection.get_rsrc(@rest_rsrc)[self.class::RSRC_OBJECT_KEY]
      @ipa = fresh_data[:general][:ipa]
    end

    def rest_xml
      doc = REXML::Document.new JSS::APIConnection::XML_HEADER
      obj = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      gen = obj.add_element 'general'
      gen.add_element('display_name').text = @display_name
      gen.add_element('description').text = @description
      gen.add_element('url').text = @url
      gen.add_element('make_available_after_install').text = @make_available_after_install
      gen.add_element('deploy_as_managed_app').text = @deploy_as_managed_app
      gen.add_element('remove_app_when_mdm_profile_is_removed').text = @remove_app_when_mdm_profile_is_removed
      gen.add_element('prevent_backup_of_app_data').text = @prevent_backup_of_app_data
      gen.add_element('keep_description_and_icon_up_to_date').text = @keep_description_and_icon_up_to_date
      gen.add_element('free').text = @free
      gen.add_element('take_over_management').text = @take_over_management
      gen.add_element('host_externally').text = @host_externally
      gen.add_element('external_url').text = @external_url
      config = gen.add_element('configuration')
      config.add_element('preferences').text = @configuration_prefs
      obj << @scope.scope_xml
      add_category_to_xml doc
      add_self_service_xml doc
      add_vpp_xml doc
      doc.to_s
    end


  end # class removable_macaddr

end # module
