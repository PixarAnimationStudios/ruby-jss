# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Directory Binding object in the JSS
  # These are rather complex objects, and contain settings specific to the directory object's type.
  #
  # @see Jamf::APIObject
  # @see Jamf::DirectoryBindingType
  # @note "Jamf::DirectoryBinding.fetch name: 'BindingName'" seems to be returning a 500 error in my test evironment. Use "Jamf::DirectoryBinding.fetch 'BindingName' instead."
  #
  class DirectoryBinding < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::DirectoryBindingType

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # ! You CAN update this
    DIRECTORY_BINDING_TYPE = {
      open_directory: 'Open Directory',
      active_directory: 'Active Directory',
      powerbroker_identity_services: 'PowerBroker Identity Services',
      admitmac: 'ADmitMac',
      centrify: 'Centrify'
    }.freeze

    DIRECTORY_BINDING_TYPE_CLASSES = {
      'Open Directory' => Jamf::DirectoryBindingType::OpenDirectory,
      'Active Directory' => Jamf::DirectoryBindingType::ActiveDirectory,
      'PowerBroker Identity Services' => Jamf::DirectoryBindingType::PowerBroker,
      'ADmitMac' => Jamf::DirectoryBindingType::ADmitMac,
      'Centrify' => Jamf::DirectoryBindingType::Centrify
    }

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
    attr_reader :id
    attr_reader :name, :priority, :domain, :username, :password_sha256, :computer_ou, :type, :type_settings, :password

    # Constructor
    # @see Jamf::APIObject.initialize
    # @note When creating an object with specific properties use the
    # objects name and then the settings.
    # Ex: Creating an Active Directory object:
    # Jamf::DirectoryBinding.make name: "Example Binding", username: "BindingUser", password: "SuperMonkey123", computer_ou: "computers", active_directory: { multiple_domains: false }, domain: your.domain.server
    #####################################
    def initialize(**args)
      super

      if in_jss?
        @priority = @init_data[:priority]
        @domain = @init_data[:domain]
        @username = @init_data[:username]
        @password_sha256 = @init_data[:password_sha256]
        @computer_ou = @init_data[:computer_ou]
        @type = @init_data[:type]

        class_key = DIRECTORY_BINDING_TYPE.select { |_k, v| v == @type }.map { |k, _v| k }.first
        set_type_settings(DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new(@init_data[class_key]))
      else
        # Build
        raise Jamf::MissingDataError, 'domain must be provided.' if @init_data[:domain].nil?
        raise Jamf::MissingDataError, 'username must be provided.' if @init_data[:username].nil?
        raise Jamf::MissingDataError, 'computer_ou must be provided.' if @init_data[:computer_ou].nil?
        raise Jamf::MissingDataError, 'password must be provided when creating a DirectoryBinding object.' if @init_data[:password].nil?
        raise Jamf::MissingDataError, "Type must be provided, one of \":#{DIRECTORY_BINDING_TYPE.keys.join(',:')}\"." if @init_data[:type].nil?

        unless DIRECTORY_BINDING_TYPE.keys.include? @init_data[:type]
          raise Jamf::InvalidDataError, 
                "Type must be one of \":#{DIRECTORY_BINDING_TYPE.keys.join(',:')}\"."
        end
        if !@init_data[:priority].nil? && (@init_data[:priority] <= 1 || @init_data[:priority] >= 10)
          raise Jamf::InvalidDataError, 
                'Priority must be between 1 and 10'
        end

        @domain = @init_data[:domain]
        @username = @init_data[:username]
        @computer_ou = @init_data[:computer_ou]
        @type = DIRECTORY_BINDING_TYPE[@init_data[:type]]
        @password = @init_data[:password]
        @priority = @init_data[:priority]

        @priority = 1 if @priority.nil?

        class_key = DIRECTORY_BINDING_TYPE.select { |_k, v| v == @type }.map { |k, _v| k }.first
        set_type_settings(DIRECTORY_BINDING_TYPE_CLASSES[@type.to_s].new(@init_data[class_key]))

      end
    end

    # Public Instance Methods
    #####################################

    # The domain the device will be bound to.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def domain=(newvalue)
      raise Jamf::InvalidDataError, 'Domain must be a String' unless newvalue.is_a? String

      @domain = newvalue.to_s
      @need_to_update = true
    end

    # The username used to attempt to bind the device to the domain.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def username=(newvalue)
      raise Jamf::InvalidDataError, 'Username must be a String' unless newvalue.is_a? String

      @username = newvalue
      @need_to_update = true
    end

    # The priority the domain has over another one.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [Integer]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not an Integer
    # @raise [Jamf::InvalidDataError] If newvalue is not between 1 and 10
    #
    # @return [void]
    def priority=(newvalue)
      raise Jamf::InvalidDataError, 'Priority must be a Integer' unless newvalue.is_a? Integer
      raise Jamf::InvalidDataError, 'Priority cannot exceed 10' unless newvalue <= 10
      raise Jamf::InvalidDataError, 'Priority must be greater than 0' unless newvalue > 0

      @priority = newvalue
      @need_to_update = true
    end

    # The OU path the computer object is to be placed
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def computer_ou=(newvalue)
      raise Jamf::InvalidDataError, 'Computer OU must be a String' unless newvalue.is_a? String

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
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def password=(newvalue)
      raise Jamf::InvalidDataError, 'Password must be a string' unless newvalue.is_a? String

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
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      ns = doc.add_element RSRC_OBJECT_KEY.to_s
      ns.add_element('id').text = @id.to_s
      ns.add_element('name').text = @name
      ns.add_element('priority').text = @priority.to_s
      ns.add_element('domain').text = @domain.to_s
      ns.add_element('username').text = @username.to_s
      ns.add_element('computer_ou').text = @computer_ou.to_s
      ns.add_element('type').text = @type.to_s
      ns.add_element('password').text = @password.to_s unless @password.nil?

      ns << @type_settings.type_setting_xml

      doc.to_s
    end # rest_xml

  end

end
