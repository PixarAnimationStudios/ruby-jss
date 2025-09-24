# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module Jamf

  # Module for containing the different types of DirectoryBindings stored within the JSS

  module DirectoryBindingType

    # Module Variables
    #####################################

    # Module Methods
    #####################################

    # Classes
    #####################################

    # Class for the specific ADmitMac DirectoryBinding type stored within the JSS
    #
    # @author Tyler Morgan
    #
    # @note "Map Home Directory To Attribute" is currently only available in the Jamf Pro UI not through the API.
    #
    # Attributes
    # @!attribute [rw] require_confirmation
    # @!attribute [rw] local_home
    # @!attribute [rw] mount_style
    # @!attribute [rw] default_shell
    # @!attribute [rw] mount_network_home
    # @!attribute [rw] place_home_folders
    # @!attribute [rw] uid
    # @!attribute [rw] user_gid
    # @!attribute [rw] gid
    # @!attribute [rw] admin_group
    # @!attribute [rw] cached_credentials
    # @!attribute [rw] add_user_to_local
    # @!attribute [rw] users_ou
    # @!attribute [rw] groups_ou
    # @!attribute [rw] printers_ou
    # @!attribute [rw] shared_folders_ou
    # TODO: Include default values upon creation
    class ADmitMac < DirectoryBindingType

      # Mix-Ins
      #####################################

      # Class Methods
      #####################################

      # Class Constants
      #####################################

      # Attributes
      #####################################

      attr_reader :require_confirmation, :local_home, :mount_style, :default_shell, :mount_network_home, :place_home_folders, :uid, :user_gid, :gid, 
                  :admin_group, :cached_credentials, :add_user_to_local, :users_ou, :groups_ou, :printers_ou, :shared_folders_ou

      # Constructor
      #####################################

      # An initializer for the ADmitMac object.
      #
      # @author Tyler Morgan
      # @see Jamf::DirectoryBinding
      # @see Jamf::DirectoryBindingType
      #
      # @note Due to a JSS API funk, mount_style is not able to be configured through the API. It is linked to place_home_folders
      #
      # @param [Hash] initialize data
      def initialize(init_data)
        # Return without processing anything since there is
        # nothing to process.
        return if init_data.nil?

        # Process the provided information
        @require_confirmation = init_data[:require_confirmation]
        @default_shell = init_data[:default_shell]
        @mount_network_home = init_data[:mount_network_home]
        @place_home_folders = init_data[:place_home_folders]
        @uid = init_data[:uid]
        @user_gid = init_data[:user_gid]
        @gid = init_data[:gid]
        @cached_credentials = init_data[:cached_credentials]
        @add_user_to_local = init_data[:add_user_to_local]
        @users_ou = init_data[:users_ou]
        @groups_ou = init_data[:groups_ou]
        @printers_ou = init_data[:printers_ou]
        @shared_folders_ou = init_data[:shared_folders_ou]
        @mount_style = init_data[:mount_style]

        if init_data[:local_home].nil? || init_data[:local_home].is_a?(String)
          unless HOME_FOLDER_TYPE.values.include? init_data[:local_home] || init_data[:local_home].nil?
            raise Jamf::InvalidDataError, "Local Home must be one of #{HOME_FOLDER_TYPE.values.join(', ')}."
          end

          @local_home = init_data[:local_home]
        else
          unless HOME_FOLDER_TYPE.keys.include? init_data[:local_home]
            raise Jamf::InvalidDataError, "Local Home must be one of :#{HOME_FOLDER_TYPE.keys.join(',:')}."
          end
        end

        @admin_group = if init_data[:admin_group].nil?
                         # This is needed since we have the ability to add and
                         # remove admin groups from this array.
                         []
                       elsif init_data[:admin_group].is_a? String
                         init_data[:admin_group].split(',')
                       else
                         init_data[:admin_group]
                       end
      end

      # Public Instance Methods
      #####################################

      # Require confirmation before creating a mobile account on the system.
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def require_confirmation=(newvalue)
        raise Jamf::InvalidDataError, 'require_confirmation must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @require_confirmation = newvalue

        container&.should_update
      end

      # The type of home directory type created upon logging into a system
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Symbol] The key specific to the folder type you want in HOME_FOLDER_TYPE
      # @see Jamf::DirectoryBindingType::HOME_FOLDER_TYPE
      #
      # @raise [Jamf::InvalidDataError] If the new value is not one of the possible keys in HOME_FOLDER_TYPE
      #
      # @return [void]
      def local_home=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, "local_home must be one of :#{HOME_FOLDER_TYPE.keys.join(',:')}." unless HOME_FOLDER_TYPE.keys.include? newvalue

            HOME_FOLDER_TYPE[newvalue]
          end

        @local_home = new

        container&.should_update
      end

      # The default shell assigned first upon logging into a system
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The string path of the shell file being set as the default
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def default_shell=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'default_shell must be empty or a string.' unless newvalue.is_a?(String)

            newvalue
          end

        @default_shell = new

        container&.should_update
      end

      # Mount network home folder on desktop
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a Bool
      #
      # @return [void]
      def mount_network_home=(newvalue)
        raise Jamf::InvalidDataError, 'mount_network_home must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @mount_network_home = newvalue

        container&.should_update
      end

      # Path at which home folders are placed
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The string path of the folder which user's directory files and folders will be created
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def place_home_folders=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'place_home_folders must be a string.' unless newvalue.is_a? String

            newvalue
          end

        @place_home_folders = new

        container&.should_update
      end

      # Jamf has these linked for some reason...
      alias mount_style place_home_folders

      # Map specific UID to Attribute
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The UID you want to be mapped
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def uid=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'uid must be a string, integer, or nil.' unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?

            newvalue
          end

        @uid = new

        container&.should_update
      end

      # Map specific a User's GID to Attribute
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The User's GID you want to be mapped
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def user_gid=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?
              raise Jamf::InvalidDataError, 
                    'user_gid must be a string, integer, or nil.'
            end

            newvalue
          end

        @user_gid = new

        container&.should_update
      end

      # Map specific GID to Attribute
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The GID you want to be mapped
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def gid=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'gid must be a string, integer, or nil.' unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?

            newvalue
          end

        @gid = new

        container&.should_update
      end

      # Set specific groups to become administrators to a system.
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Array<String>] An array of all the admin group names you want to set.
      # @see add_admin_group
      # @see remove_admin_group
      #
      # @raise [Jamf::InvalidDataError] If the new value is not an Array
      #
      # @return [void]
      def admin_group=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            unless newvalue.is_a? Array
              raise Jamf::InvalidDataError, 
                    'An Array must be provided, please use add_admin_group and remove_admin_group for individual group additions and removals.'
            end

            newvalue
          end

        @admin_group = new

        container&.should_update
      end

      # The number of times a user can log into the device while not connected to a network
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Integer] The number of times you want a user to login while not connected to a network
      #
      # @raise [Jamf::InvalidDataError] If the new value is not an Integer
      #
      # @return [void]
      def cached_credentials=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'cached_credentials must be an integer.' unless newvalue.is_a? Integer

            newvalue
          end

        @cached_credentials = new

        container&.should_update
      end

      # If the user is a member of one of the groups in admin_group, add them
      # to the local administrator group.
      #
      # @author Tyler Morgan
      # @see admin_group
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a Bool
      #
      # @return [void]
      def add_user_to_local=(newvalue)
        raise Jamf::InvalidDataError, 'add_user_to_local must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @add_user_to_local = newvalue

        container&.should_update
      end

      # An OU path for specific Users
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The OU path for the specific user
      # @note Not sure what this is used for
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def users_ou=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'users_ou must be either a string or nil.' unless newvalue.is_a? String || newvalue.nil?

            newvalue
          end

        @users_ou = new

        container&.should_update
      end

      # An OU path for specific User Groups
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The OU path for the specific user group
      # @note Not sure what this is used for
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def groups_ou=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'groups_ou must be either a string or nil.' unless newvalue.is_a? String || newvalue.nil?

            newvalue
          end

        @groups_ou = new

        container&.should_update
      end

      # An OU path for specific Printers
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The OU path for the specific printer
      # @note Not sure what this is used for
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def printers_ou=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'printers_ou must be either a string or nil.' unless newvalue.is_a? String || newvalue.nil?

            newvalue
          end

        @printers_ou = new

        container&.should_update
      end

      # An OU path for specific shared folders
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The OU path for the specific shared folders
      # @note Not sure what this is used for
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def shared_folders_ou=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'shared_folders_ou must be either a string or nil.' unless newvalue.is_a? String || newvalue.nil?

            newvalue
          end

        @shared_folders_ou = new

        container&.should_update
      end

      # An a specific admin group to admin_group
      #
      # @author Tyler Morgan
      #
      # @param value [String] The admin group name you wish to add to the admin group list
      #
      # @raise [Jamf::InvalidDataError] If the value provided is not a String
      # @raise [Jamf::InvalidDataError] If the group provided is already a member of the admin_group array
      #
      # @return [Array <String>] An array of all the admin groups currently set.
      def add_admin_group(value)
        raise Jamf::InvalidDataError, 'Admin group must be a string.' unless value.is_a? String
        raise Jamf::InvalidDataError, "Admin group \"#{value}\" already is in the list of admin groups." if @admin_group.include? value

        @admin_group << value

        container&.should_update

        @admin_group
      end

      # Remove a specific admin group to admin_group
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The admin group name you wish to remove from the admin group list
      #
      # @raise [Jamf::InvalidDataError] If the value provided is not a String
      # @raise [Jamf::InvalidDataError] If the group provided is not in the admin_group array
      #
      # @return [Array <String>] An array of all the admin groups currently set.
      def remove_admin_group(value)
        raise Jamf::InvalidDataError, 'Admin group being removed must be a string' unless value.is_a? String
        raise Jamf::InvalidDataError, "Admin group #{value} is not in the current admin group(s)." unless @admin_group.include? value

        @admin_group.delete value

        container&.should_update

        @admin_group
      end

      # Return a REXML Element containing the current state of the DirectoryBindingType
      # object for adding into the XML of the container.
      #
      # @author Tyler Morgan
      #
      # @return [REXML::Element]
      def type_setting_xml
        type_setting = REXML::Element.new 'admitmac'
        type_setting.add_element('require_confirmation').text = @require_confirmation
        type_setting.add_element('local_home').text = @local_home
        type_setting.add_element('mount_style').text = @mount_style.downcase
        type_setting.add_element('default_shell').text = @default_shell
        type_setting.add_element('mount_network_home').text = @mount_network_home
        type_setting.add_element('place_home_folders').text = @place_home_folders
        type_setting.add_element('uid').text = @uid
        type_setting.add_element('user_gid').text = @user_gid
        type_setting.add_element('gid').text = @gid
        type_setting.add_element('add_user_to_local').text = @add_user_to_local
        type_setting.add_element('cached_credentials').text = @cached_credentials
        type_setting.add_element('users_ou').text = @users_ou
        type_setting.add_element('groups_ou').text = @groups_ou
        type_setting.add_element('printers_ou').text = @printers_ou
        type_setting.add_element('shared_folders_ou').text = @shared_folders_ou
        type_setting.add_element('admin_group').text = @admin_group.join(',').to_s unless @admin_group.nil?

        type_setting
      end

    end

  end

end
