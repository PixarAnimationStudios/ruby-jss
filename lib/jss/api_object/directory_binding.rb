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
            @open_directory = @init_data[:open_directory]
            @active_directory = @init_data[:active_directory]
            @powerbroker_identity_services = @init_data[:powerbroker_identity_services]
            @admitmac = @init_data[:admitmac]
            @centrify = @init_data[:centrify]
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

            case new_type
            when :open_directory
                @open_directory = {
                    encrypt_using_ssl: args[:encrypt_using_ssl],
                    perform_secure_bind: args[:perform_secure_bind],
                    use_for_authentication: args[:use_for_authentication],
                    use_for_contacts: args[:use_for_contacts]
                }
            when :active_directory
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
                
            when :powerbroker_identity_services
                @powerbroker_identity_services = nil
                
            when :admitmac
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

            when :centrify
                @centrify = {
                    workstation_mode: args[:workstation_mode],
                    overwrite_existing: args[:overwrite_existing],
                    update_PAM: args[:update_PAM],
                    zone: args[:zone],
                    preferred_domain_server: args[:preferred_domain_server]
                }
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