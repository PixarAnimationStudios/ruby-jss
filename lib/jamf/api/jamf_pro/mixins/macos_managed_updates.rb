# Copyright 2022 Pixar
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

# frozen_string_literal: true

module Jamf

  # This module should be mixed in to Jamf::Computer and Jamf::ComputerGroup
  #
  # It provides access to the macos-managed-software-updates JPAPI resource for
  # managed OS update commands to managed macs running Big Sur or higher.
  #
  module MacOSManagedUpdates

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including Jamf::MacOSManagedUpdates"
      includer.extend(ClassMethods)
    end

    # These resources in the Jamf Pro API can be used to send Managed macOS
    # updates to clients running Big Sur or higher
    MANAGED_SW_UPDATES_RSRC = 'v1/macos-managed-software-updates'

    # GETting this resource provides a list of available OS versions
    MANAGED_SW_UPDATES_AVAILABLE_VERSIONS_RSRC = "#{MANAGED_SW_UPDATES_RSRC}/available-updates"

    # POSTing JSON data to this resource will send the MDM commands to install os updates
    # For details about the data to send, see
    # https://developer.jamf.com/jamf-pro/reference/post_v1-macos-managed-software-updates-send-updates
    MANAGED_SW_UPDATES_SEND_UPDATES_RSRC = "#{MANAGED_SW_UPDATES_RSRC}/send-updates"

    # These are the options available in Jamf::OAPISchemas::MacOsManagedSoftwareUpdate::UPDATE_ACTION_OPTIONS
    DOWNLOAD_AND_INSTALL = 'DOWNLOAD_AND_INSTALL'
    DOWNLOAD_ONLY = 'DOWNLOAD_ONLY'

    # for easier use of these values as the updateAction
    UPDATE_ACTIONS = {
      install: DOWNLOAD_AND_INSTALL,
      download: DOWNLOAD_ONLY
    }

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::MacOSManagedUpdates::ClassMethods"
      end

      # get the list of available OS versions
      #
      # @return [Array<String>]
      ###################
      def available_os_updates(cnx: Jamf.cnx)
        data = cnx.jp_get(MANAGED_SW_UPDATES_AVAILABLE_VERSIONS_RSRC)
        Jamf::OAPISchemas::AvailableUpdates.new(data).availableUpdates
      end

      # Send the os update command to target Computers or a ComputerGroup
      #
      # @param updateAction [Symbol] Required. Use :install to send the
      #   DOWNLOAD_AND_INSTALL action, or :download to send  DOWNLOAD_ONLY
      #
      # @param deviceIds [String, Integer, Array<String, Integer>] Identifiers for the
      #   computer targets. Required if no groupId is given.
      #
      # @param groupId [String, Integer] Identifier for the computer group target.
      #   Requied if no deviceIds are given.
      #
      # @param maxDeferrals [Integer] Allow users to defer the update the provided number
      #   of times before macOS forces the update. If a value is provided, the Software
      #   Update will use the InstallLater install action. MaxDeferral is ignored if using the
      #   :download updateAction.
      #
      # @param version [String] The OS version to install. If no value is provided, the
      #   version will default to latest version based on device eligibility.
      #
      # @param skipVersionVerification [Boolean] Should the specified version be installed
      #   even it it isn't applicable to this machine? If no value is provided, will default to false.
      #   If true, the specified version will be forced to complete the :install updateAction.
      #
      # @param applyMajorUpdate [Boolean] Available only when updating to the latest version
      #   based on device eligibility. Defaults to false. If false the calculated latest version
      #   will only include minor version updates. If a value is provided, the calculated latest
      #   version will include minor and major version updates.
      #
      # @param forceRestart [Boolean]  Will default to false. Can only be true if updateAction
      #   is :install and the target devices are on macOs 11 or higher.
      #   If true, the DownloadAndInstall action is performed, a restart will be forced.
      #   MaxDeferral will be ignored if true.
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [Jamf::OAPISchemas::MacOsManagedSoftwareUpdateResponse]
      ########################
      def send_managed_os_update(updateAction:, deviceIds: nil, groupId: nil, maxDeferrals: nil, version: nil, skipVersionVerification: false, applyMajorUpdate: false, forceRestart: false, cnx: Jamf.cnx)
        action_to_send = UPDATE_ACTIONS.value?(updateAction) ? updateAction : UPDATE_ACTIONS[updateAction]

        raise ArgumentError, "Unknown updateAction, must be one of: #{UPDATE_ACTIONS.keys.join ', '}" unless action_to_send

        if self == Jamf::Computer
          raise ArgumentError, 'Must provide one or more deviceIds' unless deviceIds
        elsif self == Jamf::ComputerGroup
          raise ArgumentError, 'Must provide a groupId' unless groupId
        else
          raise Jamf::UnsupportedError, 'This method is only available for Jamf::Computer and Jamf::ComputerGroup'
        end

        if version
          available_versions = available_os_updates
          raise ArgumentError, "Invalid version, must be one of: #{available_versions.join ', '}" unless available_versions.include? version
        end

        if deviceIds
          deviceIds = [deviceIds] unless deviceIds.is_a?(Array)
          deviceIds.map! { |id| valid_id id, cnx: cnx }
        end
        groupId = valid_id(groupId, cnx: cnx) if groupId

        data = {}
        # ids in the JPAPI are string containing integers
        data[:deviceIds] = deviceIds.map(&:to_s) if deviceIds
        data[:groupId] = groupId.to_s if groupId

        data[:maxDeferrals] = maxDeferrals if maxDeferrals
        data[:version] = version if version
        data[:skipVersionVerification] = skipVersionVerification if skipVersionVerification
        data[:applyMajorUpdate] = applyMajorUpdate if applyMajorUpdate
        data[:updateAction] = action_to_send
        data[:forceRestart] = forceRestart if forceRestart

        payload = Jamf::OAPISchemas::MacOsManagedSoftwareUpdate.new(data).to_json

        result = cnx.jp_post MANAGED_SW_UPDATES_SEND_UPDATES_RSRC, payload
        Jamf::OAPISchemas::MacOsManagedSoftwareUpdateResponse.new result
      end

    end # module ClassMethods

    # Instance Methods
    ######################################

    # Send a managed update command to an instance of Computer or ComputerGroup.
    # This just calls the class method of the same name.
    #
    # @see MacOSManagedUpdates.send_managed_os_update
    #
    def send_managed_os_update(updateAction:, maxDeferrals: nil, version: nil, skipVersionVerification: false, applyMajorUpdate: false, forceRestart: false)
      deviceIds = is_a?(Jamf::Computer) ? @id : nil
      groupId = is_a?(Jamf::Computer) ? nil : @id

      self.class.send_managed_os_update(
        deviceIds: deviceIds,
        groupId: groupId,
        maxDeferrals: maxDeferrals,
        version: version,
        skipVersionVerification: skipVersionVerification,
        applyMajorUpdate: applyMajorUpdate,
        forceRestart: forceRestart,
        updateAction: updateAction,
        cnx: @cnx
      )
    end

  end # module MacOSManagedUpdates

end # module Jamf
