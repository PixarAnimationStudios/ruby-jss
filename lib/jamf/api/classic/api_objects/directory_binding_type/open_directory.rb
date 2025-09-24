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

    # Class for the specific OpenDirectory DirectoryBinding type stored within the JSS
    #
    # @author Tyler Morgan
    #
    # Attributes
    # @!attribute [rw] require_confirmation

    class OpenDirectory < DirectoryBindingType

      # Mix-Ins
      #####################################

      # Class Methods
      #####################################

      # Class Constants
      #####################################

      # Attributes
      #####################################
      attr_reader :encrypt_using_ssl
      attr_reader :perform_secure_bind, :use_for_authentication, :use_for_contacts

      # Constructor
      #####################################
      def initialize(init_data)
        # Return without processing anything since there is
        # nothing to process.
        return if init_data.nil?

        # Process the provided information
        @encrypt_using_ssl = init_data[:encrypt_using_ssl]
        @perform_secure_bind = init_data[:perform_secure_bind]
        @use_for_authentication = init_data[:use_for_authentication]
        @use_for_contacts = init_data[:use_for_contacts]
      end

      # Public Instance Methods
      #####################################

      # Encrypt the connection using SSL
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def encrypt_using_ssl=(newvalue)
        raise Jamf::InvalidDataError, 'encrypt_using_ssl must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @encrypt_using_ssl = newvalue

        container&.should_update
      end

      # Attempt to perform a secure bind to the domain server
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def perform_secure_bind=(newvalue)
        raise Jamf::InvalidDataError, 'perform_secure_bind must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @perform_secure_bind = newvalue

        container&.should_update
      end

      # Use this binding for authentication
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def use_for_authentication=(newvalue)
        raise Jamf::InvalidDataError, 'use_for_authentication must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @use_for_authentication = newvalue

        container&.should_update
      end

      # Use this binding for contact population
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def use_for_contacts=(newvalue)
        raise Jamf::InvalidDataError, 'use_for_contacts must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @use_for_contacts = newvalue

        container&.should_update
      end

      # Return a REXML Element containing the current state of the DirectoryBindingType
      # object for adding into the XML of the container.
      #
      # @author Tyler Morgan
      #
      # @return [REXML::Element]
      def type_setting_xml
        type_setting = REXML::Element.new 'admitmac'
        type_setting.add_element('encrypt_using_ssl').text = @encrypt_using_ssl
        type_setting.add_element('perform_secure_bind').text = @perform_secure_bind
        type_setting.add_element('use_for_authentication').text = @use_for_authentication
        type_setting.add_element('use_for_contacts').text = @use_for_contacts

        type_setting
      end

    end

  end

end
