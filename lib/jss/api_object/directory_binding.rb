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

  # A Dock Item in the JSS.
  # These are rather simple. They have an ID, name, path, type, and contents which is read-only
  #
  # @see JSS::APIObject
  #
  class DirectoryBinding < JSS::APIObject

    # JSS > directorybinding.rb
    # folder directory binding type
    ## Includes type
    ##! Requires in right way
    #class DirectoryBindingType
    #    def test1
    #        puts "Test1"
    #    end

        #? Look at scope obj (policy rest_xml)
        #def rest_xml

        #end
    #end

    #class ActiveDirectory < DirectoryBindingType
    #    RSRC_OBJECT_KEY = :active_directory
    #    # Settings for this obj
    #    def test2
    #        puts "Test2"
    #    end

    #end

        # Mix-Ins
        #####################################
        include JSS::Creatable
        include JSS::Updatable

        # Class Methods
        #####################################

        # Class Constants
        #####################################

        #! You CAN update this
        DIRECTORY_BINDING_TYPE = {
            open_directory: "Open Directory",
            active_directory: "Active Directory",
            powerbroker_identity_services: "PowerBroker Identity Services",
            admitmac: "ADmitMac",
            centrify: "Centrify"
        }.freeze

        DIRECTORY_BINDING_TYPE_CLASSES = {
            "Open Directory" => JSS::DirectoryBindingType::OpenDirectory,
            "Active Directory" => JSS::DirectoryBindingType::ActiveDirectory,
            "PowerBroker Identify Services" => JSS::DirectoryBindingType::PowerBroker,
            "ADmitMac" => JSS::DirectoryBindingType::ADmitMac,
            "Centrify" => JSS::DirectoryBindingType::Centrify
        }

        DIRECTORY_NETWORK_PROTOCOL = {
            smb: "SMB",
            afp: "AFP"
        }.freeze

        # The base for REST resources of this class
        RSRC_BASE = 'directorybindings'.freeze

        # the hash key used for the JSON list output of all objects in the JSS
        RSRC_LIST_KEY = :directory_bindings

        # The hash key used for the JSON object output.
        # It's also used in various error messages
        RSRC_OBJECT_KEY = :directory_binding

        # the object type for this object in
        # the object history table.
        # See {APIObject#add_object_history_entry}
        #OBJECT_HISTORY_OBJECT_TYPE = 41

        # Attributes
        #####################################
        attr_reader :id
        attr_reader :name
        attr_reader :priority
        attr_reader :domain
        attr_reader :username
        attr_reader :password_sha256
        attr_reader :computer_ou
        attr_reader :type
        attr_reader :type_settings

        ## The different type of directory binding settings:
        attr_reader :open_directory
        attr_reader :active_directory
        attr_reader :powerbroker_identity_services
        attr_reader :admitmac
        attr_reader :centrify

        # Constructor
        # @see JSS::APIObject.initialize
        #####################################
        def initialize(args = {})
            super args

            @priority = @init_data[:priority]
            @domain = @init_data[:domain]
            @username = @init_data[:username]
            @password_sha256 = @init_data[:password_sha256]
            @computer_ou = @init_data[:computer_ou]
            @type = @init_data[:type]

            # The different type of directory binding settings:
            #? One attribute "type-settings" instance of directory binding type DirectoryBindingType

            class_key = DIRECTORY_BINDING_TYPE.select { |k,v| v == @type }.map { |k,v| k }.first

            pp "Key found: #{class_key}"

            pp @init_data[class_key]

            @type_settings = DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new @init_data[class_key]
            # TODO: Process class and create the object
        end

        # Public Instance Methods
        #####################################

        def domain=(newvalue)
            raise JSS::InvalidDataError, "Domain must be a String" unless newvalue.is_a? String

            @domain = newvalue.to_s
        end

        def username=(newvalue)
            raise JSS::InvalidDataError, "Username must be a String" unless newvalue.is_a? String

            @username = newvalue
        end

        def priority=(newvalue)
            raise JSS::InvalidDataError, "Priority must be a Integer" unless newvalue.is_a? Integer

            @priority = newvalue
        end

        def computer_ou=(newvalue)
            raise JSS::InvalidDataError, "Computer OU must be a String" unless newvalue.is_a? String
        end

        def set_binding_type(new_type, **args)
            raise JSS::InvalidDataError, "Directory Binding type must be one of :#{DIRECTORY_BINDING_TYPE.keys.join(',:')}" unless DIRECTORY_BINDING_TYPE.keys.include? new_type

            @type = DIRECTORY_BINDING_TYPE[new_type]
            case new_type
            when :open_directory

                raise JSS::InvalidDataError, "encrypt_using_ssl must be true or false." if !args[:encrypt_using_ssl].nil? && !args[:encrypt_using_ssl].is_a?(Bool)
                raise JSS::InvalidDataError, "perform_secure_bind must be true or false." if !args[:perform_secure_bind].nil? && !args[:perform_secure_bind].is_a?(Bool)
                raise JSS::InvalidDataError, "use_for_authentication must be true or false." if !args[:use_for_authentication].nil? && !args[:use_for_authentication].is_a?(Bool)
                raise JSS::InvalidDataError, "use_for_contacts must be true or false." if !args[:use_for_contacts].nil? && !args[:use_for_contacts].is_a?(Bool)

                @open_directory = {
                    encrypt_using_ssl: args[:encrypt_using_ssl],
                    perform_secure_bind: args[:perform_secure_bind],
                    use_for_authentication: args[:use_for_authentication],
                    use_for_contacts: args[:use_for_contacts]
                }

                # Default values if object was created using Jamf Pro's Web UI
                @open_directory[:encrypt_using_ssl] = false if @open_directory[:encrypt_using_ssl].nil?
                @open_directory[:perform_secure_bind] = false if @open_directory[:perform_secure_bind].nil?
                @open_directory[:use_for_authentication] = true if @open_directory[:use_for_authentication].nil?
                @open_directory[:use_for_contacts] = true if @open_directory[:use_for_contacts].nil?

            when :active_directory
                raise JSS::InvalidDataError, "cache_last_user must be true or false." if !args[:cache_last_user].nil? && !args[:cache_last_user].is_a?(Bool)
                raise JSS::InvalidDataError, "require_confirmation must be true or false." if !args[:require_confirmation].nil? && !args[:require_confirmation].is_a?(Bool)
                raise JSS::InvalidDataError, "local_home must be true or false." if !args[:local_home].nil? && !args[:local_home].is_a?(Bool)
                raise JSS::InvalidDataError, "use_unc_path must be true or false." if !args[:use_unc_path].nil? && !args[:use_unc_path].is_a?(Bool)
                raise JSS::InvalidDataError, "multiple_domains must be true or false." if !args[:multiple_domains].nil? && !args[:multiple_domains].is_a?(Bool)

                raise JSS::InvalidDataError, "mount_style must be one of :#{DIRECTORY_NETWORK_PROTOCOL.keys.join(',:')}" if !DIRECTORY_NETWORK_PROTOCOL.keys.include? args[:mount_style] && !args[:mount_style].nil?
                
                raise JSS::InvalidDataError, "uid must be a String or Integer." if !args[:uid].nil? && (!args[:uid].is_a?(String) || !args[:uid].is_a?(Integer))
                raise JSS::InvalidDataError, "user_gid must be a String or Integer." if !args[:user_gid].nil? && (args[:user_gid].is_a?(String) || args[:user_gid].is_a?(Integer))
                raise JSS::InvalidDataError, "gid must be a String or Integer." if !args[:gid].nil? && (!args[:gid].is_a?(String) || !args[:gid].is_a?(Integer))

                raise JSS::InvalidDataError, "preferred_domain must be a String." if !args[:preferred_domain].nil? && !args[:preferred_domain].is_a?(String)
                raise JSS::InvalidDataError, "admin_groups must be a String." if !args[:admin_groups].nil? && !args[:admin_groups].is_a?(String)

                @active_directory = {
                    cache_last_user: args[:cache_last_user],
                    require_confirmation: args[:require_confirmation],
                    local_home: args[:local_home],
                    use_unc_path: args[:use_unc_path],
                    mount_style: args[:mount_style],
                    default_shell: args[:default_shell],
                    uid: args[:uid],
                    user_gid: args[:user_gid],
                    gid: args[:gid],
                    multiple_domains: args[:multiple_domains],
                    preferred_domain_server: args[:preferred_domain],
                    admin_groups: args[:admin_groups]
                }

                @active_directory[:cache_last_user] = false if @active_directory[:cache_last_user].nil?
                @active_directory[:require_confirmation] = false if @active_directory[:require_confirmation].nil?
                @active_directory[:local_home] = true if @active_directory[:local_home].nil?
                @active_directory[:use_unc_path] = false if @active_directory[:use_unc_path].nil?
                @active_directory[:mount_style] = "smb" if @active_directory[:mount_style].nil?
                @active_directory[:default_shell] = "/bin/bash" if @active_directory[:default_shell].nil?
                
            when :powerbroker_identity_services
                @powerbroker_identity_services = {}
                
            when :admitmac
                raise JSS::InvalidDataError, "require_confirmation must be true or false." if !args[:require_confirmation].nil? && !args[:require_confirmation].is_a?(Bool)
                raise JSS::InvalidDataError, "mount_network_home must be true or false." if !args[:mount_network_home].nil? && !args[:mount_network_home].is_a?(Bool)
                raise JSS::InvalidDataError, "add_user_to_local must be true or false." if !args[:add_user_to_local].nil? && !args[:add_user_to_local].is_a?(Bool)
                raise JSS::InvalidDataError, "cached_credentials must be an Integer." if !args[:cached_credentials].nil? && !args[:cached_credentials].is_a?(Integer)
                raise JSS::InvalidDataError, "default_shell must be a string." if !args[:default_shell].nil? && !args[:default_shell].is_a?(String)
                raise JSS::InvalidDataError, "place_home_folders must be a string." if !args[:place_home_folders].nil? && !args[:place_home_folders].is_a?(String)
                raise JSS::InvalidDataError, "place_home_folders must begin and end with \"/\"." if !args[:place_home_folders].nil? && !args[:place_home_folders].is_a?(String) && (args[:place_home_folders].chars.first != "/" || args[:place_home_folders].chars.last != "/")
                raise JSS::InvalidDataError, "admin_group must be a string." if !args[:admin_group].nil? && !args[:admin_group].is_a?(String)
                raise JSS::InvalidDataError, "users_ou must be a string." if !args[:users_ou].nil? && !args[:users_ou].is_a?(String)
                raise JSS::InvalidDataError, "groups_ou must be a string." if !args[:groups_ou].nil? && !args[:groups_ou].is_a?(String)
                raise JSS::InvalidDataError, "printers_ou must be a string." if !args[:printers_ou].nil? && !args[:printers_ou].is_a?(String)
                raise JSS::InvalidDataError, "shared_folders_ou must be a string." if !args[:shared_folders_ou].nil? && !args[:shared_folders_ou].is_a?(String)
                raise JSS::InvalidDataError, "Directory Binding type must be one of :#{ADMIT_HOME_FOLDER_TYPE.keys.join(',:')}" if !ADMIT_HOME_FOLDER_TYPE.keys.include? args[:local_home] && !args[:local_home].nil?

                @admitmac = {
                    require_confirmation: args[:require_confirmation],
                    local_home: args[:local_home],
                    mount_style: args[:mount_style],
                    default_shell: args[:default_shell],
                    mount_network_home: args[:mount_network_home],
                    place_home_folders: args[:place_home_folders],
                    uid: args[:uid],
                    user_gid: args[:user_gid],
                    gid: args[:gid],
                    admin_group: args[:admin_group],
                    cached_credentials: args[:cached_credentials],
                    add_user_to_local: args[:add_user_to_local],
                    users_ou: args[:users_ou],
                    groups_ou: args[:groups_ou],
                    printers_ou: args[:printers_ou],
                    shared_folders_ou: args[:shared_folders_ou]
                }

                @admitmac[:require_confirmation] = false if @admitmac[:require_confirmation].nil?
                @admitmac[:local_home] = ADMIT_HOME_FOLDER_TYPE[:network] if @admitmac[:local_home].nil?
                @admitmac[:default_shell] = "/bin/bash" if @admitmac[:default_shell].nil?
                @admitmac[:mount_network_home] = false if @admitmac[:mount_network_home].nil?
                @admitmac[:cached_credentials] = 10 if @admitmac[:cached_credentials].nil?
                @admitmac[:add_user_to_local] = true if @admitmac[:add_user_to_local].nil?

            when :centrify
                raise JSS::InvalidDataError, "workstation_mode must be true or false." if !args[:workstation_mode].nil? && !args[:workstation_mode].is_a?(Bool)
                raise JSS::InvalidDataError, "overwrite_existing must be true or false." if !args[:overwrite_existing].nil? && !args[:overwrite_existing].is_a?(Bool)
                raise JSS::InvalidDataError, "update_PAM must be true or false." if !args[:update_PAM].nil? && !args[:update_PAM].is_a?(Bool)
                raise JSS::InvalidDataError, "zone must a string." if !args[:zone].nil? && !args[:zone].is_a?(String)
                raise JSS::InvalidDataError, "preferred_domain_server must a string." if !args[:preferred_domain_server].nil? && !args[:preferred_domain_server].is_a?(String)
                
                @centrify = {
                    workstation_mode: args[:workstation_mode],
                    overwrite_existing: args[:overwrite_existing],
                    update_PAM: args[:update_PAM],
                    zone: args[:zone],
                    preferred_domain_server: args[:preferred_domain_server]
                }

                @centrify[:workstation_mode] = false if @centrify[:workstation_mode].nil?
                @centrify[:overwrite_existing] = false if @centrify[:overwrite_existing].nil?
                @centrify[:update_PAM] = true if @centrify[:update_PAM].nil?
            end
        end

        # private instance methods
        ######################
        private

        # the xml formated data for adding or updating this in the JSS
        #
        def rest_xml
            doc = REXML::Document.new APIConnection::XML_HEADER
            ns = doc.add_element RSRC_OBJECT_KEY.to_s
            ns.add_element('id').text = @id.to_s
            ns.add_element('name').text = @name
            ns.add_element('priority').text = @priority.to_s
            ns.add_element('domain').text = @domain.to_s
            ns.add_element('username').text = @username.to_s
            ns.add_element('computer_ou').text = @computer_ou.to_s
            ns.add_element('type').text = @type.to_s

            case DIRECTORY_BINDING_TYPE.select { |k,v| v == @type }.map { |k,v| k }[0]
            when :open_directory
                pp "Open Directory processing..."
                open_directory = ns.add_element('open_directory')
                @open_directory.each do |k,v|
                    open_directory.add_element(k.to_s).text = v.to_s
                end
                
            when :active_directory
                active_directory = ns.add_element('active_directory')
                @active_directory.each do |k,v|
                    active_directory.add_element(k.to_s).text = v.to_s
                end

            when :powerbroker_identity_services
                powerbroker_identity_services = ns.add_element('powerbroker_identity_services')
                @powerbroker_identity_services.each do |k,v|
                    powerbroker_identity_services.add_element(k.to_s).text = v.to_s
                end

            when :admitmac
                admitmac = ns.add_element('admitmac')
                @admitmac.each do |k,v|
                    admitmac.add_element(k.to_s).text = v.to_s
                end

            when :centrify
                centrify = ns.add_element('centrify')
                @centrify.each do |k,v|
                    centrify.add_element(k.to_s).text = v.to_s
                end
            else
                pp "Type: #{@type}"
                pp "Open_Directory"
                pp @open_directory
            end

            doc.to_s
        end # rest_xml
    end


end