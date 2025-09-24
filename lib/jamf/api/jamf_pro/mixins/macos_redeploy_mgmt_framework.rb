# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # This module should be mixed in to Jamf::Computer and Jamf::ComputerGroup
  #
  # It provides access to the macos-managed-software-updates JPAPI resource for
  # managed OS update commands to managed macs running Big Sur or higher.
  #
  module MacOSRedeployMgmtFramework

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including #{self}"
      includer.extend(ClassMethods)
    end

    # The JP API resource for redeploying the management framework
    # to a computer. The id will be appended when used.
    REDEPLOY_RSRC = 'v1/jamf-management-framework/redeploy'

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending #{self}"
      end

      # Redeploy the Jamf Management framework to target Computers or members of ComputerGroups
      #
      # IMPORTANT: This only re-deploys the Jamf binary and related framework. The MDM system
      # must be functioning. The target computer(s) will not re-install the framework if they
      # never recieve the MDM command.
      #
      # @param target_ids [String, Integer, Array<String, Integer>] Jamf IDs for the
      #   Computer or ComputerGroup targets.
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [Hash{Integer => String}] The result for each computer, either the
      #   uuid of the sent MDM command, or an error message.
      ########################
      def redeploy_mgmt_framework(target_ids, cnx: Jamf.cnx)
        target_ids = target_ids.is_a?(Array) ? target_ids : [target_ids]
        target_comp_ids =
          if self == Jamf::Computer
            target_ids

          elsif self == Jamf::ComputerGroup
            group_ids = target_ids.is_a?(Array) ? target_ids : [target_ids]
            comp_ids = []
            group_ids.each { |gid| comp_ids += JSS::ComputerGroup.fetch(id: gid).member_ids }
            comp_ids

          else
            raise Jamf::UnsupportedError, 'This method is only available for Jamf::Computer and Jamf::ComputerGroup'
          end

        results = {}

        target_comp_ids.uniq.compact.each do |comp_id|
          result = cnx.jp_post "#{REDEPLOY_RSRC}/#{comp_id}", Jamf::BLANK

          result = Jamf::OAPISchemas::RedeployJamfManagementFrameworkResponse.new result
          results[comp_id] = result.commandUuid
        rescue Jamf::Connection::JamfProAPIError => e
          results[comp_id] = "ERROR: #{e}"
        end

        results
      end

    end # module ClassMethods

    # Instance Methods
    ######################################

    # Send a managed update command to an instance of Computer or ComputerGroup.
    # This just calls the class method of the same name.
    #
    # @see MacOSRedeployMgmtFramework.redeploy_mgmt_framework
    #
    def redeploy_mgmt_framework
      self.class.redeploy_mgmt_framework @id, cnx: @cnx
    end

  end # module MacOSRedeployMgmtFramework

end # module Jamf
