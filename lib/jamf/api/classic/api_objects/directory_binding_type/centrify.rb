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
    # Attributes
    # @!attribute [rw] workstation_mode
    # @!attribute [rw] overwrite_existing
    # @!attribute [rw] update_PAM
    # @!attribute [rw] zone
    # @!attribute [rw] preferred_domain_server
    class Centrify < DirectoryBindingType

      # Mix-Ins
      #####################################

      # Class Methods
      #####################################

      # Class Constants
      #####################################

      # Attributes
      #####################################
      attr_reader :workstation_mode
      attr_reader :overwrite_existing, :update_PAM, :zone, :preferred_domain_server

      # Constructor
      #####################################

      # An initializer for the Centrify object.
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

        # Process the provided information
        @workstation_mode = init_data[:workstation_mode]
        @overwrite_existing = init_data[:overwrite_existing]
        @update_PAM = init_data[:update_PAM]
        @zone = init_data[:zone]
        @preferred_domain_server = init_data[:preferred_domain_server]
      end

      # Public Instance Methods
      #####################################

      # Sets the Centrify Mode to Workstation mode
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def workstation_mode=(newvalue)
        raise Jamf::InvalidDataError, 'workstation_mode must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @workstation_mode = newvalue

        container&.should_update
      end

      # Want to overwrite existing joined computer in the directory
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def overwrite_existing=(newvalue)
        raise Jamf::InvalidDataError, 'overwrite_existing must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @overwrite_existing = newvalue

        container&.should_update
      end

      # Update the PAM module and overwrite DirectoryService configuration
      #
      # @author Tyler Morgan
      #
      # @param newvalue [Bool]
      #
      # @raise [Jamf::InvalidDataError] If the new value doesn't match a Bool value
      #
      # @return [void]
      def update_PAM=(newvalue)
        raise Jamf::InvalidDataError, 'update_PAM must be true or false.' unless newvalue.is_a?(TrueClass) || newvalue.is_a(FalseClass)

        @update_PAM = newvalue

        container&.should_update
      end

      # The zone the computer is to be joined to
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] the new zone the computer is to be joined to
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a string.
      #
      # @return [void]
      def zone=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'zone must be a string.' unless newvalue.is_a? String

            newvalue
          end

        @zone = new

        container&.should_update
      end

      # The specific domain server that should be prioritized
      #
      # @author Tyler Morgan
      #
      # @param newvalue [String] The domain server that would be prioritized.
      #
      # @raise [Jamf::InvalidDataError] If the new value is not a string.
      #
      # @return [void]
      def preferred_domain_server=(newvalue)
        new =
          if newvalue.to_s.empty?
            Jamf::BLANK
          else
            # Data Check
            raise Jamf::InvalidDataError, 'preferred_domain_server must be a string.' unless newvalue.is_a? String

            newvalue
          end

        @preferred_domain_server = new

        container&.should_update
      end

      # Return a REXML Element containing the current state of the DirectoryBindingType
      # object for adding into the XML of the container.
      #
      # @author Tyler Morgan
      #
      # @return [REXML::Element]
      def type_setting_xml
        type_setting = REXML::Element.new 'centrify'
        type_setting.add_element('workstation_mode').text = @workstation_mode
        type_setting.add_element('overwrite_existing').text = @overwrite_existing
        type_setting.add_element('update_PAM').text = @update_PAM
        type_setting.add_element('zone').text = @zone
        type_setting.add_element('preferred_domain_server').text = @preferred_domain_server

        type_setting
      end

    end

  end

end
