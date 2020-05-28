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
        # @!attribute [rw] preferred_domain_server
        # @!attribute [rw] admin_groups
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
            attr_reader :require_confirmation
            attr_reader :local_home
            attr_reader :use_unc_path
            attr_reader :mount_style
            attr_reader :default_shell
            attr_reader :uid
            attr_reader :user_gid
            attr_reader :gid
            attr_reader :multiple_domains
            attr_reader :preferred_domain_server
            attr_reader :admin_groups

            # Constructor
            #####################################

            # An initializer for the Active Directory object.
            # 
            # @author Tyler Morgan
            # @see JSS::DirectoryBinding
            # @see JSS::DirectoryBindingType
            #
            # @param [Hash] initialize data
            def initialize(init_data)
                @cache_last_user = init_data[:cache_last_user]
                @require_confirmation = init_data[:require_confirmation]
                @local_home = init_data[:local_home]
                @use_unc_path = init_data[:use_unc_path]
                @mount_style = init_data[:mount_style]
                @default_shell = init_data[:default_shell]
                @uid = init_data[:uid]
                @user_gid = init_data[:user_gid]
                @gid = init_data[:gid]
                @multiple_domains = init_data[:multiple_domains]
                @preferred_domain_server = init_data[:preferred_domain_server]
                @admin_groups = init_data[:admin_groups]
            end

                

            # Public Instance Methods
            #####################################

            # Create mobile account upon login
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def cache_last_user=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "cache_last_user must be true or false." unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

                # Update Value
                @cache_last_user = newvalue

                # Return the new value
                @cache_last_user
            end


            # Require confirmation before creating a mobile account on the system.
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def require_confirmation=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "require_confirmation must be true or false." unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

                # Update Value
                @require_confirmation = newvalue

                # Return the new value
                @require_confirmation
            end


            # Force local home directory to be placed on the startup disk
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def local_home=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "local_home must be true or false." unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

                # Update Value
                @local_home = newvalue

                # Return the new value
                @local_home
            end


            # Attempt to derive the network home location using the UNC path stored inside Active Directory
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def use_unc_path=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "use_unc_path must be true or false." unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

                # Update Value
                @use_unc_path = newvalue

                # Return the new value
                @use_unc_path
            end

            
            # The protocol to be use when mounting network home location
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Symbol] One of the keys available in NETWORK_PROTOCOL
            # @see JSS::DIRECTORYBINDINGTYPE::NETWORK_PROTOCOL
            #
            # @raise [JSS::InvalidDataError] If the new value provided is not a key inside the NETWORK_PROTOCOL hash.
            #
            # @return [void]
            def mount_style=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "mount_style must be one of :#{NETWORK_PROTOCOL.keys.join(',:')}." unless NETWORK_PROTOCOL.keys.include? newvalue

                # Update Value
                @mount_style = newvalue

                # Return the new value
                @mount_style
            end

            
            # The directory path to the shell user's default shell will be set to upon login.
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] Directory path for the specific shell that is wanting to be set.
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            #
            # @return [void]
            def default_shell=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "default_shell must be a string." unless newvalue.is_a? String

                # Update Value
                @default_shell = newvalue

                # Return the new value
                @default_shell
            end


            # Map specific a UID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The UID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            #
            # @return [void]
            def uid=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "uid must be either an integer or a string." unless (newvalue.is_a? Integer || newvalue.is_a?(String))

                # Update Value
                @uid = newvalue

                # Return the new value
                @uid
            end


            # Map specific a User's GID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The User's GID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            #
            # @return [void]
            def user_gid=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "user_gid must be either an integer or a string." unless (newvalue.is_a? Integer || newvalue.is_a?(String))

                # Update Value
                @user_gid = newvalue

                # Return the new value
                @user_gid
            end


            # Map specific a GID to Attribute
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The GID you want to be mapped
            #
            # @raise [JSS::InvalidDataError] If the new value is not a String
            #
            # @return [void]
            def gid=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "gid must be either an integer or a string." unless (newvalue.is_a? Integer || newvalue.is_a?(String))

                # Update Value
                @gid = newvalue

                # Return the new value
                @gid
            end


            # Will this computer be possibly connecting to multiple domains
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the provided value is not a Bool.
            #
            # @return [void]
            def multiple_domains=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "multiple_domains must be true or false." unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

                # Update Value
                @multiple_domains = newvalue

                # Return the new value
                @multiple_domains
            end


            # What domain server should be highest priority
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String]
            #
            # @raise [JSS::InvalidDataError] If the provided value is not a String.
            #
            # @return [void]
            def preferred_domain_server=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "preferred_domain_server must be a string." unless newvalue.is_a? String

                # Update Value
                @preferred_domain_server = newvalue

                # Return the new value
                @preferred_domain_server
            end

            
            # The AD group which can be considered administrators of a device.
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Array <String>]
            #
            # @raise [JSS::InvalidDataError] If the provided value is not an Array.
            #
            # @return [void]
            def admin_groups=(newvalue)

                # Data Check
                raise JSS::InvalidDataError, "admin_groups must be either a string or an array of strings." unless (newvalue.is_a? String || newvalue.is_a?(Array))

                # Update Value
                if newvalue.is_a? Array
                    @admin_groups = newvalue.join ","
                else
                    @admin_groups = newvalue
                end

                # Return the new value
                @admin_groups
            end


            # Add a specific admin group to the admin_groups
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The admin group name you want to add to the admin group list
            #
            # @raise [JSS::InvalidDataError] If the value provided is not a String
            # @raise [JSS::InvalidDataError] If the group provided is not in the admin_group array
            #
            # @return [Array <String>] An array of all the admin groups currently set.
            def add_admin_group(value)

                raise JSS::InvalidDataError, "Admin group must be a string." unless value.is_a? String
                raise JSS::InvalidDataError, "Group \"#{value}\" already is in the admin groups." unless !@admin_groups.include? value

                @admin_groups << value
                @admin_groups
            end


            # Remove a specific admin group from the admin_groups
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The admin group name you want to remove from the admin groups.
            #
            # @raise [JSS::InvalidDataError] If the value provided is not a String
            # @raise [JSS::InvalidDataError] If the group provided is not in the admin_group array
            #
            # @return [Array <String>] An array of all the admin groups currently set.
            def remove_admin_group(value)

                raise JSS::InvalidDataError, "Admin group being removed must be a string." unless value.is_a? String
                raise JSS::InvalidDataError, "Admin group #{value} is not in the current admin group(s)." unless @admin_groups.include value

                @admin_groups.delete value
                @admin_groups
            end


            # Return a REXML Element containing the current state of the DirectoryBindingType
            # object for adding into the XML of the container.
            # 
            # @author Tyler Morgan
            #
            # @return [REXML::Element]
            def type_setting_xml
                type_setting = REXML::Element.new "active_directory"
                type_setting.add_element("cache_last_user").text = @cache_last_user
                type_setting.add_element("require_confirmation").text = @require_confirmation
                type_setting.add_element("local_home").text = @local_home
                type_setting.add_element("use_unc_path").text = @use_unc_path
                type_setting.add_element("mount_style").text = @mount_style
                type_setting.add_element("default_shell").text = @default_shell
                type_setting.add_element("uid").text = @uid
                type_setting.add_element("user_gid").text = @user_gid
                type_setting.add_element("gid").text = @gid
                type_setting.add_element("multiple_domains").text = @multiple_domains
                type_setting.add_element("preferred_domain_server").text = @preferred_domain_server
                type_setting.add_element("admin_groups").text = @admin_groups.join(',').to_s unless @admin_groups.nil?

                return type_setting
            end
        end
    end
end