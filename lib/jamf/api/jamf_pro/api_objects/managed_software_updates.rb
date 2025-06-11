# Copyright 2025 Pixar
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

  # This module provides access to the Managed Software Updates endpoints of the Jamf Pro API.
  #
  # Sending managed software updates is done by creating a "plan" for one or more devices, or
  # a group of devices, either computers or mobile devices. Plans are created with the
  # send_managed_sw_update method, which takes the target devices or group, the update action,
  # the version type, and other optional parameters such as specific version, build version.
  #
  # Once created/sent, Plans, identified by their planUuid, can be retrieved with the
  # Jamf::ManagedSoftwareUpdate::Plan class which encapsulates the details of the plan, including
  # the latest status of the update from the Jamf Pro server.
  #
  # You can also retrieve the status of any computer or group from the MDM server/Client Machines via the
  # Jamf::ManagedSoftwareUpdates.status method, which returns an array of Status objects
  # for the devices or group members you specify.
  #
  # TODO: We will integrate the ManagedSoftwareUpdate::Plan class into Jamf::Computer,
  # Jamf::MobileDevice, Jamf::ComputerGroup, and Jamf::MobileDeviceGroup (and/or their JP API versions)
  # as both a class method and an instance method, so that you can send updates directly
  # from those classes and instances.
  #
  # We will probably not add support for the "feature-toggle" endpoints, since eventually
  # this 'feature' will be the only way to do these updates, and that such toggling is better
  # done in the web app.
  #
  module ManagedSoftwareUpdates

    ############# API PATHS

    MANAGED_SW_UPDATES_PATH = 'v1/managed-software-updates'

    AVAILABLE_VERSIONS_PATH = "#{MANAGED_SW_UPDATES_PATH}/available-updates"

    DEVICE_POST_PATH = "#{MANAGED_SW_UPDATES_PATH}/plans"

    GROUP_POST_PATH = "#{MANAGED_SW_UPDATES_PATH}/plans/group"

    STATUS_PATH = "#{MANAGED_SW_UPDATES_PATH}/update-statuses"

    COMPUTER_STATUS_PATH = "#{STATUS_PATH}/computers"

    COMPUTER_GROUP_STATUS_PATH = "#{STATUS_PATH}/computer-groups"

    MOBILE_DEVICE_STATUS_PATH = "#{STATUS_PATH}/mobile-devices"

    MOBILE_DEVICE_GROUP_STATUS_PATH = "#{STATUS_PATH}/mobile-device-groups"

    STATUS_FILTER_KEYS = %i[
      osUpdatesStatusId device.deviceId device.objectType downloaded downloadPercentComplete productKey status deferralsRemaining maxDeferrals nextScheduledInstall created updated
    ].freeze

    DEVICE_TYPES = Jamf::OAPISchemas::PlanDevicePost::OBJECT_TYPE_OPTIONS

    GROUP_TYPES = Jamf::OAPISchemas::PlanGroupPost::OBJECT_TYPE_OPTIONS

    UPDATE_ACTIONS = Jamf::OAPISchemas::PlanConfigurationPost::UPDATE_ACTION_OPTIONS

    VERSION_TYPES = Jamf::OAPISchemas::PlanConfigurationPost::VERSION_TYPE_OPTIONS

    # Class Methods
    ######################################

    # get the list of available OS versions for macOS and/or iOS/iPadOS
    #
    # @param cnx [Jamf::Connection] the connection to use, defaults to Jamf.cnx
    # @return [Hash {Symbol => Array<String>}]
    ###################
    def self.available_os_updates(cnx: Jamf.cnx)
      cnx.jp_get(AVAILABLE_VERSIONS_PATH)[:availableUpdates]
    end

    # Send an MDM/DDM OS update command to one or more target devices or a group
    #
    # TODO: Integrate this into Jamf::Computer, Jamf::MobileDevice, Jamf::ComputerGroup,
    # and Jamf::MobileDeviceGroup as both a class method and an instance method.
    #
    # @param deviceIds [String, Integer, Array<String, Integer>] Required if no groupId is given.
    #   The Jamf ID for the device targets, may be integers or integer-strings.
    #
    # @param groupId [String, Integer] Requied if no deviceIds are given. The Jamf ID for
    #   the group target, may be integer or integer-string.
    #
    # @param targetType [Symbol, String] Required. The type of device or group.
    #   For devices, one of :computer, :mobile_device, :apple_tv.
    #   For groups, one of :computer_group, :mobile_device_group.
    #
    # @param updateAction [Symbol, String] Required. One of :download_only, :download_install,
    #   :download_install_allow_deferral, :download_install_restart, :download_install_schedule.
    #
    # @param versionType [Symbol, String] Required. One of :latest_major, :latest_minor,
    #   :latest_any, :specific_version, :custom_version
    #
    # @param specificVersion [String] Optional. Indicates the specific version to update to.
    #   Only available when the versionType is set to specific_version or custom_version
    #
    # @param buildVersion [String] Optional. Indicates the build version to update to.
    #   Only available when the version type is set to custom version.
    #
    # @param maxDeferrals [Integer] Required when the provided updateAction is :download_install_allow_deferral.
    #   Not applicable to all updateActions.
    #
    # @param forceInstallLocalDateTime [Time, Jamf::Timestamp, String] Optional. The local date and time
    # of the device to force update by
    #
    # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
    #
    # @return [Jamf::OAPISchemas::ManagedSoftwareUpdatePlanPostResponse] The Response object from the API
    ########################
    def self.send_managed_sw_update(targetType:, updateAction:, versionType:, deviceIds: nil, groupId: nil, cnx: Jamf.cnx, **opts)
      deviceIds, groupId, targetType = validate_targets(targetType: targetType, deviceIds: deviceIds, groupId: groupId)

      # Ensure we have a valid update action
      updateAction = validate_update_action(updateAction)

      # Ensure we have a valid version type
      versionType = validate_version_type(versionType)

      # Build the request body, starting with the common config
      request_body = {
        config: {
          updateAction: updateAction,
          versionType: versionType
        }
      }

      request_body[:config][:specificVersion] = opts[:specificVersion] if opts[:specificVersion]
      request_body[:config][:buildVersion] = opts[:buildVersion] if opts[:buildVersion]
      request_body[:config][:maxDeferrals] = opts[:maxDeferrals] if opts[:maxDeferrals]
      if opts[:forceInstallLocalDateTime]
        time = Time.parse opts[:forceInstallLocalDateTime] unless opts[:forceInstallLocalDateTime].is_a? Time
        request_body[:config][:forceInstallLocalDateTime] = time.strftime('%FT%T')
      end

      # Add the target information
      if deviceIds
        request_body[:devices] = deviceIds.map { |id| { deviceId: id, objectType: targetType } }
        post_path = DEVICE_POST_PATH
      else
        request_body[:group] = {
          groupId: groupId,
          objectType: targetType
        }
        post_path = GROUP_POST_PATH
      end
      Jamf::OAPISchemas::ManagedSoftwareUpdatePlanPostResponse.new cnx.jp_post(post_path, request_body)
    end

    # Retrieve one or more ManagedSoftwareUpdateStatuses objects for a device, group members,
    # or the result of an arbitrary filter on all Status objects.
    #
    # TODO: Integrate this into Jamf::Computer, Jamf::MobileDevice, Jamf::ComputerGroup,
    # and Jamf::MobileDeviceGroup as both a class method and an instance method.
    #
    # @param type [Symbol] Required unless using a filter. One of :computer, :mobile_device,
    #   :mobile_device_group, :computer_group.
    #
    # @param id [Integer, String] Required unless using a filter. The Jamf ID of the device or group
    #
    # @param filter [String] Required unless providing type: and id:.  An RSQL filter string to apply
    #   to the collection of Status objects. Available filter keys are: osUpdatesStatusId device.deviceId
    #   device.objectType downloaded downloadPercentComplete productKey status deferralsRemaining
    #   maxDeferrals nextScheduledInstall created updated
    #
    # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
    #
    # @return [Array<Jamf::OAPISchemas::ManagedSoftwareUpdateStatus>] The Status objects for the device
    #    or members of the group, or the filter results.
    #
    ###############################
    def self.status(type: nil, id: nil, filter: nil, cnx: Jamf.cnx)
      raise ArgumentError, 'Must provide either type and id, or a filter' if (type || id) && filter
      raise ArgumentError, 'Must provide both type and id if using either' if (type || id) && !(type && id)

      get_path =
        case type
        when :computer
          "#{COMPUTER_STATUS_PATH}/#{id}"
        when :mobile_device
          "#{MOBILE_DEVICE_STATUS_PATH}/#{id}"
        when :computer_group
          "#{COMPUTER_GROUP_STATUS_PATH}/#{id}"
        when :mobile_device_group
          "#{MOBILE_DEVICE_GROUP_STATUS_PATH}/#{id}"
        else
          unless type.nil?
            raise ArgumentError,
                  "Invalid type: #{type}, must be one of: #{%i[computer mobile_device computer_group mobile_device_group].join ', '}"
          end
          raise ArgumentError, 'filter required if not using type and id' unless filter

          "#{STATUS_PATH}/?filter=#{CGI.escape filter}"
        end

      Jamf::OAPISchemas::ManagedSoftwareUpdateStatuses.new(cnx.jp_get(get_path)).results
    end

    # Validate the device or group ids and type
    #
    # @param deviceIds [String, Integer, Array<String, Integer>] Required if no groupId is given.
    #   Identifiers for the device targets.
    #
    # @param groupId [String, Integer] Requied if no deviceIds are given. Identifier for
    #   the group target.
    #
    # @param type [Symbol, String] Required. The type of device or group.
    #   For devices, one of :computer, :mobile_device, :apple_tv.
    #   For groups, one of :computer_group, :mobile_device_group.
    #
    # @return [Hash] a hash with the keys :type, :deviceIds, and :groupId
    ##########################
    def self.validate_targets(targetType:, deviceIds: nil, groupId: nil)
      raise ArgumentError, 'Must provide either deviceIds or groupId' if deviceIds.nil? && groupId.nil?
      raise ArgumentError, 'Must specify either deviceIds or groupId, but not both' if deviceIds && groupId

      targetType = targetType.to_s.upcase
      if deviceIds
        # Ensure we have a valid device type
        raise ArgumentError, "Invalid device type: #{targetType}, mst be one of: #{DEVICE_TYPES.join ', '}" unless DEVICE_TYPES.include?(targetType)

        deviceIds = [deviceIds] unless deviceIds.is_a?(Array)
      else
        # Ensure we have a valid group type
        raise ArgumentError, "Invalid group type: #{targetType}, mst be one of: #{GROUP_TYPES.join ', '}" unless GROUP_TYPES.include?(targetType)
      end

      [deviceIds, groupId, targetType]
    end
    private_class_method :validate_targets

    # Validate the update action, convert it to the format expected by the API
    # @param updateAction [Symbol, String] the update action to validate
    # @return [String] the update action in the format expected by the API
    ###########################
    def self.validate_update_action(updateAction)
      updateAction = updateAction.to_s.upcase
      raise ArgumentError, "Invalid updateAction: #{updateAction}, must be one of: #{UPDATE_ACTIONS.join ', '}" unless UPDATE_ACTIONS.include?(updateAction)

      updateAction
    end
    private_class_method :validate_update_action

    # Validate the version type, convert it to the format expected by the API
    # @param versionType [Symbol, String] the version type to validate
    # @return [String] the version type in the format expected by the API
    #########################
    def self.validate_version_type(versionType)
      versionType = versionType.to_s.upcase
      raise ArgumentError, "Invalid versionType: #{versionType}, must be one of: #{VERSION_TYPES.join ', '}" unless VERSION_TYPES.include?(versionType)

      versionType
    end
    private_class_method :validate_version_type

  end # module MacOSManagedUpdates

end # module Jamf
