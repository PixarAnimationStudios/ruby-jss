# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Jamf

  # This module should be mixed in to Jamf::Computer and Jamf::ComputerGroup
  #
  # It provides access to the macos-managed-software-updates JPAPI resource for
  # managed OS update commands to managed macs running Big Sur or higher.
  #
  # TODO: When POSTing to api/preview/mdm/commands is no longer in Preview,
  # implement that endpoint and then add the setting of the recovery lock
  # to this module.
  #
  # See https://learn.jamf.com/bundle/technical-articles/page/Recovery_Lock_Enablement_in_macOS_Using_the_Jamf_Pro_API.html
  #
  module ComputerRecoveryLock

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including #{self}"
      includer.extend(ClassMethods)
    end

    # The JPAPI resource for a single computer's RecoveryLock password is
    # Jamf::Computer::JPAPI_INVENTORY_RSRC then the computer's ID then this
    RECOVERY_LOCK_PW_RSRC_SUFFIX = 'view-recovery-lock-password'

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending #{self}"
      end

      # Retrieve the recovery lock password for a given computer, if one has been set.
      #
      # @param computer [Symbol, String, Integer, Array<String, Integer>] Identifier for the desired
      #   Computer
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [String, nil] The recovery lock password, or nil if none has been set.
      #######################
      def recovery_lock_password(computer, cnx: Jamf.cnx)
        id = Jamf::Computer.valid_id computer
        raise Jamf::NoSuchItemError, "No computer matches identifier '#{computer}'" unless id

        cnx.jp_get("#{Jamf::Computer::JPAPI_INVENTORY_RSRC}/#{id}/#{RECOVERY_LOCK_PW_RSRC_SUFFIX}").dig :recoveryLockPassword

      # if we get a 404 NOT FOUND error, this given computer has no passwd set, so just return nil
      rescue Jamf::Connection::JamfProAPIError => e
        raise unless e.http_status == 404

        nil
      end # def

      # TODO: When Jamf::Computer is based on the JPAPI, these methods
      # and the matching instance methods, will be moved into
      # a more appropriate file - probably another mixin for
      # the Computer class.
      #############################################
      #############################################

      # Get the JPAPI inventory data for a single computer, either by section or all sections.
      #
      # @param computer [Symbol, String, Integer, Array<String, Integer>] Identifier for the desired
      #   Computer
      #
      # @param section [String] One of the data sections listed in Jamf::OAPISchemas::ComputerSection::VALUE_OPTIONS
      #   or 'all'. Default is 'GENERAL'
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [Jamf::OAPISchemas::ComputerInventory] The inventory data, with the requested sections populated
      #########
      def inventory_data(computer, section: 'GENERAL', cnx: Jamf.cnx)
        # TODO: get this into a constant
        all = 'ALL'

        section = section.to_s.upcase
        id = Jamf::Computer.valid_id computer
        raise Jamf::NoSuchItemError, "No computer matches identifier '#{computer}'" unless id

        data =
          if section == all
            cnx.jp_get "#{Jamf::Computer::JPAPI_INVENTORY_DETAIL_RSRC}/#{id}"
          else
            raise ArgumentError, "Unknown inventory data section '#{section}'" unless Jamf::OAPISchemas::ComputerSection::VALUE_OPTIONS.include?(section)

            cnx.jp_get("#{Jamf::Computer::JPAPI_INVENTORY_RSRC}?section=#{section}&page=0&page-size=1&filter=id%3D%3D#{id}")[:results].first
          end

        Jamf::OAPISchemas::ComputerInventory.new data
      end

      # Get the MDM 'managementID' of a given computer.
      #
      # @param computer [Symbol, String, Integer, Array<String, Integer>] Identifier for the desired
      #   Computer
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [String, nil] The managementID or nil if not available
      #########
      def management_id(computer, cnx: Jamf.cnx)
        inventory_data(computer, cnx: cnx).general.managementId
      end

    end # module ClassMethods

    # Instance Methods
    ######################################

    # Get the recovery lock password for this Computer instance
    #
    # @see ComputerRecoveryLock::ClassMethods.recovery_lock_password
    #########
    def recovery_lock_password
      self.class.recovery_lock_password @id, cnx: @cnx
    end

    # Get the JPAPI inventory data for this computer, either by section or all sections.
    #
    # @see ComputerRecoveryLock::ClassMethods.inventory_data
    #########
    def inventory_data(section: 'GENERAL')
      self.class.inventory_data @id, section: section, cnx: @cnx
    end

    # Get the MDM 'managementID' of this computer.
    #
    # @see ComputerRecoveryLock::ClassMethods.management_id
    #########
    def management_id
      inventory_data.general.managementId
    end

  end # module MacOSRedeployMgmtFramework

end # module Jamf
