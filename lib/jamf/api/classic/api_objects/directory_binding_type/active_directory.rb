# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

module Jamf

  # Module for containing the different types of DirectoryBindings stored within the JSS
  module DirectoryBindingType

    # Module Variables
    #####################################

    # Module Methods
    #####################################

    # Classes
    #####################################

    # Class for the specific Active Directory DirectoryBinding type stored within the JSS
    #
    # @author Tyler Morgan
    #
    # Attributes
    # @!attribute [rw] cache_last_user
    # @!attribute [rw] require_confirmation
    # @!attribute [rw] local_home
    # @!attribute [rw] use_unc_path
    # @!attribute [rw] mount_style
    # @!attribute [rw] default_shell
    # @!attribute [rw] uid
    # @!attribute [rw] user_gid
    # @!attribute [rw] gid
    # @!attribute [rw] multiple_domains
    # @!attribute [rw] preferred_domain
    # @!attribute [rw] admin_groups
    # @!attribute [rw] forest
    # TODO: Include default values upon creation

    class ActiveDirectory < DirectoryBindingType

      # Mix-Ins
      #####################################

      # Class Methods
      #####################################

      # Class Constants
      #####################################

      # Attributes
      #####################################
      attr_reader :cache_last_user
      attr_reader :require_confirmation, :local_home, :use_unc_path, :mount_style, :default_shell, :uid, :user_gid, :gid, :multiple_domains, 
                  :preferred_domain, :admin_groups, :forest

      # Constructor
      #####################################

      # An initializer for the Active Directory object.
      #
      # @author Tyler Morgan
      # @see Jamf::DirectoryBinding
      # @see Jamf::DirectoryBindingType
      #
      # @param [Hash] initialize data
      def initialize(init_data)
        # Return without processing anything since there is
        # nothing to process.
        return if init_data.nil?

        # Process provided information
        @cache_last_user = init_data[:cache_last_user]
        @require_confirmation = init_data[:require_confirmation]
        @local_home = init_data[:local_home]
        @use_unc_path = init_data[:use_unc_path]
        @default_shell = init_data[:default_shell]
        @uid = init_data[:uid]
        @user_gid = init_data[:user_gid]
        @gid = init_data[:gid]
        @multiple_domains = init_data[:multiple_domains]
        @preferred_domain = init_data[:preferred_domain]
        @forest = init_data[:forest]

        if init_data[:mount_style].nil? || init_data[:mount_style].is_a?(String)
          raise Jamf::InvalidDataError, "Mount style must be one of #{NETWORK_PROTOCOL.values.join(', ')}." unless NETWORK_PROTOCOL.values.map do |x|
            x.downcase
          end.include?(init_data[:mount_style].downcase) || init_data[:mount_style].nil?

          @mount_style = init_data[:mount_style]
        else
          unless NETWORK_PROTOCOL.keys.include? init_data[:mount_style]
            raise Jamf::InvalidDataError, 
                  "Mount style must be one of :#{NETWORK_PROTOCOL.keys.join(',:')},"
          end

          @mount_style = NETWORK_PROTOCOL[init_data[:mount_style]]
        end

        @admin_groups = if init_data[:admin_groups].nil?
                          # This is needed since we have the ability to add and
                          # remove admin groups from this array.
                          []
                        elsif init_data[:admin_groups].is_a? String
                          init_data[:admin_groups].split(',')
                        else
                          init_data[:admin_groups]
                        end
      end

      # Public Instance Methods
      #####################################

      # Create mobile account upon login
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def cache_last_user=(newvalue)
        # Data Check
        raise Jamf::InvalidDataError, 'cache_last_user must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

        # Update Value
        @cache_last_user = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

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
        # Data Check
        raise Jamf::InvalidDataError, 'require_confirmation must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

        # Update Value
        @require_confirmation = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Force local home directory to be placed on the startup disk
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def local_home=(newvalue)
        # Data Check
        raise Jamf::InvalidDataError, 'local_home must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

        # Update Value
        @local_home = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Attempt to derive the network home location using the UNC path stored inside Active Directory
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def use_unc_path=(newvalue)
        # Data Check
        raise Jamf::InvalidDataError, 'use_unc_path must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

        # Update Value
        @use_unc_path = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

      # The protocol to be use when mounting network home location
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Symbol] One of the keys available in NETWORK_PROTOCOL
      # @see Jamf::DIRECTORYBINDINGTYPE::NETWORK_PROTOCOL
      #
      # @raise [Jamf::InvalidDataError] If the new value provided is not a key inside the NETWORK_PROTOCOL hash.
      #
      # @return [void]
      def mount_style=(newvalue)
        # Data Check
        raise Jamf::InvalidDataError, "mount_style must be one of :#{NETWORK_PROTOCOL.keys.join(',:')}." unless NETWORK_PROTOCOL.keys.include? newvalue

        # Update Value
        @mount_style = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

      # The directory path to the shell user's default shell will be set to upon login.
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] Directory path for the specific shell that is wanting to be set.
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
            raise Jamf::InvalidDataError, 'default_shell must be a string.' unless newvalue.is_a? String

            newvalue
          end

        # Update Value
        @default_shell = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Map specific a UID to Attribute
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
            raise Jamf::InvalidDataError, 'uid must be either an integer or a string.' unless newvalue.is_a? Integer || newvalue.is_a?(String)

            newvalue
          end

        # Update Value
        @uid = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Specify a specific forest within Active Directory
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The forest you want to specify
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a String
      #
      # @return [void]
      def forest=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'forest must be a string.' unless newvalue.is_a? String

            newvalue
          end

        # Update Value
        @forest = new

        # Set the object to needing to be updated.
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
            unless newvalue.is_a? Integer || newvalue.is_a?(String)
              raise Jamf::InvalidDataError, 
                    'user_gid must be either an integer or a string.'
            end

            newvalue
          end

        # Update Value
        @user_gid = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Map specific a GID to Attribute
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
            raise Jamf::InvalidDataError, 'gid must be either an integer or a string.' unless newvalue.is_a? Integer || newvalue.is_a?(String)

            newvalue
          end

        # Update Value
        @gid = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Will this computer be possibly connecting to multiple domains
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the provided value is not a Bool.
      #
      # @return [void]
      def multiple_domains=(newvalue)
        # Data Check
        raise Jamf::InvalidDataError, 'multiple_domains must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

        # Update Value
        @multiple_domains = newvalue

        # Set the object to needing to be updated.
        container&.should_update
      end

      # What domain server should be highest priority
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String]
      #
      # @raise [Jamf::InvalidDataError] If the provided value is not a String.
      #
      # @return [void]
      def preferred_domain=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'preferred_domain must be a string.' unless newvalue.is_a? String

            newvalue
          end

        # Update Value
        @preferred_domain = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # The AD group which can be considered administrators of a device.
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Array <String>]
      #
      # @raise [Jamf::InvalidDataError] If the provided value is not an Array.
      #
      # @return [void]
      def admin_groups=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            unless newvalue.is_a? String || newvalue.is_a?(Array)
              raise Jamf::InvalidDataError, 
                    'admin_groups must be either a string or an array of strings.'
            end

            if newvalue.is_a? Array
              newvalue.join ','
            else
              newvalue
            end
          end

        # Update Value
        @admin_groups = new

        # Set the object to needing to be updated.
        container&.should_update
      end

      # Add a specific admin group to the admin_groups
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The admin group name you want to add to the admin group list
      #
      # @raise [Jamf::InvalidDataError] If the value provided is not a String
      # @raise [Jamf::InvalidDataError] If the group provided is not in the admin_group array
      #
      # @return [Array <String>] An array of all the admin groups currently set.
      def add_admin_group(value)
        raise Jamf::InvalidDataError, 'Admin group must be a string.' unless value.is_a? String
        raise Jamf::InvalidDataError, "Group \"#{value}\" already is in the admin groups." if @admin_groups.include? value

        @admin_groups << value
        # Set the object to needing to be updated.
        container&.should_update

        @admin_groups
      end

      # Remove a specific admin group from the admin_groups
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The admin group name you want to remove from the admin groups.
      #
      # @raise [Jamf::InvalidDataError] If the value provided is not a String
      # @raise [Jamf::InvalidDataError] If the group provided is not in the admin_group array
      #
      # @return [Array <String>] An array of all the admin groups currently set.
      def remove_admin_group(value)
        raise Jamf::InvalidDataError, 'Admin group being removed must be a string.' unless value.is_a? String
        raise Jamf::InvalidDataError, "Admin group #{value} is not in the current admin group(s)." unless @admin_groups.include? value

        @admin_groups.delete value
        # Set the object to needing to be updated.
        container&.should_update

        @admin_groups
      end

      # Return a REXML Element containing the current state of the DirectoryBindingType
      # object for adding into the XML of the container.
      #
      # @author Tyler Morgan
      #
      # @return [REXML::Element]
      def type_setting_xml
        type_setting = REXML::Element.new 'active_directory'
        type_setting.add_element('cache_last_user').text = @cache_last_user
        type_setting.add_element('require_confirmation').text = @require_confirmation
        type_setting.add_element('local_home').text = @local_home
        type_setting.add_element('use_unc_path').text = @use_unc_path
        type_setting.add_element('mount_style').text = @mount_style.downcase
        type_setting.add_element('default_shell').text = @default_shell
        type_setting.add_element('uid').text = @uid
        type_setting.add_element('user_gid').text = @user_gid
        type_setting.add_element('gid').text = @gid
        type_setting.add_element('multiple_domains').text = @multiple_domains
        type_setting.add_element('preferred_domain').text = @preferred_domain
        type_setting.add_element('admin_groups').text = @admin_groups.join(',').to_s unless @admin_groups.nil?
        type_setting.add_element('forest').text = @forest.to_s

        type_setting
      end

    end

  end

end
