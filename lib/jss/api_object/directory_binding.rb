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

    # A Directory Binding object in the JSS
    # These are rather complex objects, and contain settings specific to the directory object's type.
    #
    # @see JSS::APIObject
    # @see JSS::DirectoryBindingType
    # @note "JSS::DirectoryBinding.fetch name: 'BindingName'" seems to be returning a 500 error in my test evironment. Use "JSS::DirectoryBinding.fetch 'BindingName' instead."
    #
    class DirectoryBinding < JSS::APIObject

        # Mix-Ins
        #####################################
        include JSS::Creatable
        include JSS::Updatable
        include JSS::DirectoryBindingType

        # Class Methods
        #####################################

        # Class Constants
        #####################################

        
        # The directory binding type
        DIRECTORY_BINDING_TYPE = {
            open_directory: "Open Directory",
            active_directory: "Active Directory",
            powerbroker_identity_services: "PowerBroker Identity Services",
            admitmac: "ADmitMac",
            centrify: "Centrify"
        }.freeze

        # The directory binding type class hash used to determine which directory binding type class should be used
        DIRECTORY_BINDING_TYPE_CLASSES = {
            "Open Directory" => JSS::DirectoryBindingType::OpenDirectory,
            "Active Directory" => JSS::DirectoryBindingType::ActiveDirectory,
            "PowerBroker Identity Services" => JSS::DirectoryBindingType::PowerBroker,
            "ADmitMac" => JSS::DirectoryBindingType::ADmitMac,
            "Centrify" => JSS::DirectoryBindingType::Centrify
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
        # OBJECT_HISTORY_OBJECT_TYPE = 41

        # Attributes
        #####################################
        
        # @return [Integer] The Id of the object in the JSS
        attr_reader :id

        # @return [String] The name of the object in the JSS
        attr_reader :name

        # @return [Integer] The priority this binding has over others when multiple bindings are applied
        attr_reader :priority

        ## @return [String] The domain server the binding will attempt to perform the bind to
        attr_reader :domain

        # @return [String] The username that will be used to perform the binding
        attr_reader :username

        # @return [String] The SHA256 hash of the user's password that would be used to perform the bind
        attr_reader :password_sha256

        # @return [String] The OU the computer object will reside in upon successful binding
        attr_reader :computer_ou

        attr_reader :type

        # @return [JSS::DirectoryBindingType] The DirectoryBindingType object that hold the settings for the specific directory binding type configured.
        attr_reader :type_settings
        
        # @note This is only available if the object is newly created and stored locally
        # @return [String] The user's password that would be used to perform the bind
        attr_reader :password

        # Constructor
        #####################################

        # When creating a new directory binding in the JSS, you must provide :username, :password, :domain, :type, :name, :computer_ou, and the specific symbol for the binding type object.
        # @see JSS::APIObject#initialize
        # @note When creating an object with specific properties use the objects name and then the settings.
        # @param [Hash] args The options to create the Directory Binding object.
        # @option args [Integer] :priority What level of priority does this binding have over others, lower is higher priority
        # @option args [String] :domain The domain server you want this binding to perform the bind to
        # @option args [String] :username The username of the account that has permission to perform the bind to the specified server
        # @option args [String] :password The password to be used by the account to perform the bind.
        # @option args [String] :password_sha256 The SHA256 hash of the password for the account being used to perform the bind to the specified server.
        # @option args [String] :computer_ou The OU path that the computer object is to reside in
        # @option args [String] :type The type of binding object, must be one of DIRECTORY_BINDING_TYPEs
        # @option args [Hash] :active_directory The settings you want to be passed to create the Active Directory binding type object.
        # @option args [Hash] :open_directory The settings you want to be passed to create the Open Directory binding type object.
        # @option args [Hash] :powerbroker_identity_services The settings you want to be passed to create the PowerBroker binding type object.
        # @option args [Hash] :admitmac The settings you want to be passed to create the ADmitMac binding type object.
        # @option args [Hash] :centrify The settings you want to be passed to create the Centrify binding type object.
        # @example Creating an Active Directory object
        #   JSS::DirectoryBinding.make name: "Example Binding", username: "BindingUser", password: "SuperMonkey123", computer_ou: "computers", active_directory: { multiple_domains: false }, domain: your.domain.server
        #####################################
        def initialize(args = {})
            super args

            if self.in_jss?
                @priority = @init_data[:priority]
                @domain = @init_data[:domain]
                @username = @init_data[:username]
                @password_sha256 = @init_data[:password_sha256]
                @computer_ou = @init_data[:computer_ou]
                @type = @init_data[:type]

                class_key = DIRECTORY_BINDING_TYPE.select { |k,v| v == @type }.map { |k,v| k }.first
                self.set_type_settings (DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new @init_data[class_key])
            else
                # Build
                raise JSS::MissingDataError, "domain must be provided." if @init_data[:domain].nil?
                raise JSS::MissingDataError, "username must be provided." if @init_data[:username].nil?
                raise JSS::MissingDataError, "computer_ou must be provided." if @init_data[:computer_ou].nil?
                raise JSS::MissingDataError, "password must be provided when creating a DirectoryBinding object." if @init_data[:password].nil?
                raise JSS::MissingDataError, "Type must be provided, one of \":#{DIRECTORY_BINDING_TYPE.keys.join(",:")}\"." if @init_data[:type].nil?
                raise JSS::InvalidDataError, "Type must be one of \":#{DIRECTORY_BINDING_TYPE.keys.join(",:")}\"." unless DIRECTORY_BINDING_TYPE.keys.include? @init_data[:type]
                raise JSS::InvalidDataError, "Priority must be between 1 and 10" if !@init_data[:priority].nil? && (@init_data[:priority] <= 1 || @init_data[:priority] >= 10)

                @domain = @init_data[:domain]
                @username = @init_data[:username]
                @computer_ou = @init_data[:computer_ou]
                @type = DIRECTORY_BINDING_TYPE[@init_data[:type]]
                @password = @init_data[:password]
                @priority = @init_data[:priority]

                @priority = 1 if @priority.nil?


                class_key = DIRECTORY_BINDING_TYPE.select { |k,v| v == @type }.map { |k,v| k }.first
                self.set_type_settings (DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new @init_data[class_key])

            end

        end # init

        # Public Instance Methods
        #####################################

        # @see Creatable#create
        #
        # @todo fill out this documentation
        #
        def create()
            super()
        end

        # Set the domain that the binding object will attempt to bind to.
        #
        # @param newvalue [String] The domain server address attempting to be bound to
        #
        # @raise [JSS::InvalidDataError] If the domain attempting to be set is not a String
        #
        # @return [Void]
        def domain=(newvalue)
            raise JSS::InvalidDataError, "Domain must be a String" unless newvalue.is_a? String

            @domain = newvalue.to_s
            @need_to_update = true
        end


        # The username used to attempt to bind the device to the domain.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String] The username to be used to perform the bind
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [Void]
        def username=(newvalue)
            raise JSS::InvalidDataError, "Username must be a String" unless newvalue.is_a? String

            @username = newvalue
            @need_to_update = true
        end


        # The priority the domain has over another one.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [Integer] The priority this binding would have over other bindings that are installed
        #
        # @note The lower the number, the higher priority the binding has.
        #
        # @raise [JSS::InvalidDataError] If newvalue is not an Integer
        # @raise [JSS::InvalidDataError] If newvalue is not between 1 and 10
        #
        # @return [void]
        def priority=(newvalue)
            raise JSS::InvalidDataError, "Priority must be a Integer" unless newvalue.is_a? Integer
            raise JSS::InvalidDataError, "Priority cannot exceed 10" unless newvalue <= 10
            raise JSS::InvalidDataError, "Priority must be greater than 0" unless newvalue > 0

            @priority = newvalue
            @need_to_update = true
        end

        
        # The OU path the computer object is to be placed
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [void]
        def computer_ou=(newvalue)
            raise JSS::InvalidDataError, "Computer OU must be a String" unless newvalue.is_a? String

            @computer_ou = newvalue
            @need_to_update = true
        end


        # Sets the password used in conjunction with the username to attempt to bind
        # the computer to the domain.
        #
        # @author Tyler Morgan
        #
        # @param newvalue [String]
        #
        # @raise [JSS::InvalidDataError] If newvalue is not a String
        #
        # @return [void]
        def password=(newvalue)
            raise JSS::InvalidDataError, "Password must be a string" unless newvalue.is_a? String

            @password = newvalue
            @need_to_update = true
        end

        # private instance methods
        ######################
        private

        # the xml formated data for adding or updating this in the JSS
        #
        # This method constructs a properly formatted XML document to be handled by the Jamf Pro API
        #
        # @author Tyler Morgan
        #
        # @return [String]
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
            if !@password.nil?
                ns.add_element('password').text = @password.to_s
            end

            ns << @type_settings.type_setting_xml

            return doc.to_s
        end # rest_xml
    end


end