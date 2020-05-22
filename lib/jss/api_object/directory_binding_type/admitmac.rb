### Copyright 2019 Rixar

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

module JSS

    # Module Variables
    #####################################
    
    # Module Methods
    #####################################
    
    # Classes
    #####################################
    
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
        # Attributes
        # @!attribute [rw] require_confirmation
        # @!attribute [rw] local_home
        # @!attribute [rw] mount_style
        # @!attribute [rw] default_shell

        class ADmitMac < DirectoryBindingType
            # Mix-Ins
            #####################################

            # Class Methods
            #####################################

            # Class Constants
            #####################################

            # Attributes
            #####################################

            attr_reader :require_confirmation
            attr_reader :local_home
            attr_reader :mount_style
            attr_reader :default_shell
            attr_reader :mount_network_home
            attr_reader :place_home_folders
            attr_reader :uid
            attr_reader :user_gid
            attr_reader :gid
            attr_reader :admin_groups
            attr_reader :cached_credentials
            attr_reader :add_user_to_local
            attr_reader :users_ou
            attr_reader :groups_ou
            attr_reader :printers_ou
            attr_reader :shared_folders_ou

            # Constructor
            #####################################

            # An initializer for the ADmitMac object.
            # 
            # @author Tyler Morgan
            # @see JSS::DirectoryBinding
            # @see JSS::DirectoryBindingType
            #
            # @param [Hash] initialize data
            def initialize(init_data)
                @require_confirmation = init_data[:require_confirmation]
                @local_home = init_data[:local_home]
                @mount_style = init_data[:mount_style]
                @default_shell = init_data[:default_shell]
                @mount_network_home = init_data[:mount_network_home]
                @place_home_folders = init_data[:place_home_folders]
                @uid = init_data[:uid]
                @user_gid = init_data[:user_gid]
                @gid = init_data[:gid]
                @admin_groups = init_data[:admin_groups]
                @cached_credentials = init_data[:cached_credentials]
                @add_user_to_local = init_data[:add_user_to_local]
                @users_ou = init_data[:users_ou]
                @groups_ou = init_data[:groups_ou]
                @printers_ou = init_data[:printers_ou]
                @shared_folders_ou = init_data[:shared_folders_ou]
            end

                

            # Public Instance Methods
            #####################################

            # Require confirmation before creating a mobile account on the system.
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            def require_confirmation=(newvalue)

                raise JSS::InvalidDataError, "require_confirmation must be true or false." unless newvalue.is_a? Bool

                @require_confirmation = newvalue
                @require_confirmation
            end


            # The type of home directory type created upon logging into a system
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Symbol] The key specific to the folder type you want in HOME_FOLDER_TYPE
            # @see JSS::DirectoryBindingType::HOME_FOLDER_TYPE
            #
            # @raise [JSS::InvalidDataError] If the new value is not one of the possible keys in HOME_FOLDER_TYPE
            def local_home=(newvalue)
                
                raise JSS::InvalidDataError, "local_home must be one of :#{HOME_FOLDER_TYPE.keys.join(',:')}." unless HOME_FOLDER_TYPE.keys.include? newvalue

                @local_home = HOME_FOLDER_TYPE[newvalue)]
                @local_home
            end

            # The default shell assigned first upon logging into a system
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The string path of the shell file being set as the default
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def default_shell=(newvalue)

                raise JSS::InvalidDataError, "default_shell must be empty or a string." unless newvalue.is_a?(String)

                @default_shell = newvalue
                @default_shell
            end


            # Mount network home folder on desktop
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value is not a Bool
            def mount_network_home=(newvalue)

                raise JSS::InvalidDataError, "mount_network_home must be true or false." unless newvalue.is_a? Bool

                @mount_network_home = newvalue
                @mount_network_home
            end

            # Path at which home folders are placed
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The string path of the folder which user's directory files and folders will be created
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def place_home_folders=(newvalue)

                raise JSS::InvalidDataError, "place_home_folders must be a string." unless newvalue.is_a? String

                @place_home_folders = newvalue
                @place_home_folders
            end

            # Jamf has these linked for some reason...
            alias mount_style place_home_folders


            # Map specific UID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The UID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def uid=(newvalue)

                raise JSS::InvalidDataError, "uid must be a string, integer, or nil." unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?

                @uid = newvalue
                @uid
            end

            
            # Map specific a User's GID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The User's GID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def user_gid=(newvalue)

                raise JSS::InvalidDataError, "user_gid must be a string, integer, or nil." unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?

                @user_gid = newvalue
                @user_gid
            end


            # Map specific GID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The GID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def gid=(newvalue)

                raise JSS::InvalidDataError, "gid must be a string, integer, or nil." unless newvalue.is_a?(String) || newvalue.is_a?(Integer) || newvalue.nil?

                @gid = newvalue
                @gid
            end

            # Set specific groups to become administrators to a system.
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Array<String>] An array of all the admin group names you want to set.
            # @see add_admin_group
            # @see remove_admin_group
            #
            # @raise [JSS::InvalidDataError] If the new value is not an Array
            def admin_groups=(newvalue)
                
                raise JSS::InvalidDataError, "An Array must be provided, please use add_admin_group and remove_admin_group for individual group additions and removals." unless newvalue.is_a? Array

                @admin_groups = newvalue
                @admin_groups
            end


            # The number of times a user can log into the device while not connected to a network
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Integer] The number of times you want a user to login while not connected to a network
            #
            # @raise [JSS::InvalidDataError] If the new value is not an Integer
            def cached_credentials=(newvalue)

                raise JSS::InvalidDataError, "cached_credentials must be an integer." unless newvalue.is_a? Integer

                @cached_credentials = newvalue
                @cached_credentials
            end


            # If the user is a member of one of the groups in admin_groups, add them
            # to the local administrator group.
            # 
            # @author Tyler Morgan
            # @see admin_groups
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value is not a Bool
            def add_user_to_local=(newvalue)

                raise JSS::InvalidDataError, "add_user_to_local must be true or false." unless newvalue.is_a? Bool

                @add_user_to_local = newvalue
                @add_user_to_local
            end


            # An OU path for specific Users
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The OU path for the specific user
            # @note Not sure what this is used for
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def users_ou=(newvalue)

                raise JSS::InvalidDataError, "users_ou must be either a string or nil." unless newvalue.is_a? String || newvalue.nil?

                @users_ou = newvalue
                @users_ou
            end


            # An OU path for specific User Groups
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The OU path for the specific user group
            # @note Not sure what this is used for
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def groups_ou=(newvalue)

                raise JSS::InvalidDataError, "groups_ou must be either a string or nil." unless newvalue.is_a? String || newvalue.nil?

                @groups_ou = newvalue
                @groups_ou
            end


            # An OU path for specific Printers
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The OU path for the specific printer
            # @note Not sure what this is used for
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def printers_ou=(newvalue)

                raise JSS::InvalidDataError, "printers_ou must be either a string or nil." unless newvalue.is_a? String || newvalue.nil?

                @printers_ou = newvalue
                @printers_ou
            end


            # An OU path for specific shared folders
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The OU path for the specific shared folders
            # @note Not sure what this is used for
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            def shared_folders_ou=(newvalue)

                raise JSS::InvalidDataError, "shared_folders_ou must be either a string or nil." unless newvalue.is_a? String || newvalue.nil?

                @shared_folders_ou = newvalue
                @shared_folders_ou
            end

            
            # An a specific admin group to admin_groups
            # 
            # @author Tyler Morgan
            #
            # @param value [String] The admin group name you wish to add to the admin group list
            #
            # @raise [JSS::InvalidDataError] If the value provided is not a String
            #
            # @todo Add validation to see if the admin group already exists in the array
            def add_admin_group(value)

                raise JSS::InvalidDataError, "Admin group must be a string." unless value.is_a? String

                @admin_groups << value
                @admin_groups
            end


            # Remove a specific admin group to admin_groups
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The admin group name you wish to remove from the admin group list
            #
            # @raise [JSS::InvalidDataError] If the value provided is not a String
            # @raise [JSS::InvalidDataError] If the group provided is not in the admin_group array
            def remove_admin_group(value)

                raise JSS::InvalidDataError, "Admin group being removed must be a string" unless value.is_a? String
                raise JSS::InvalidDataError, "Admin group #{value} is not in the current admin group(s)." unless @admin_groups.include? value

                @admin_groups.delete value
                @admin_groups
            end
        end
    end
end