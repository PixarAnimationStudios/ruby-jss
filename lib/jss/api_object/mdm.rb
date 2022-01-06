### Copyright 2020 Pixar

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

###
module JSS

  # Mixin Modules
  #####################################

  # This module provides the ability to work with MDM commands for objects that
  # can receive them.
  #
  # Objects mixing in this module MUST:
  #
  # - Define the constant MDM_COMMAND_TARGET - One of:
  #    :computers, :computergroups, :mobiledevices, :mobiledevicegroups
  #
  #
  #
  #
  module MDM

    # Constants
    #####################################

    #### target types

    # These targets are computers
    COMPUTER_TARGETS = %i[computers computergroups].freeze

    # The API resource for sending computer commands
    COMPUTER_RSRC = 'computercommands'.freeze

    # These targets are mobile devices
    DEVICE_TARGETS = %i[mobiledevices mobiledevicegroups].freeze

    # the API resource for sending device commands
    DEVICE_RSRC = 'mobiledevicecommands'.freeze

    # These targets are groups, and need their member ids expanded for sending commands
    GROUP_TARGETS = %i[computergroups mobiledevicegroups].freeze

    #### The commands

    # Both computers & devices

    BLANK_PUSH = 'BlankPush'.freeze
    DEVICE_LOCK = 'DeviceLock'.freeze
    ERASE_DEVICE = 'EraseDevice'.freeze
    UNMANGE_DEVICE = 'UnmanageDevice'.freeze
    # UPDATE_OS = 'UpdateOS'.freeze

    # computers only

    DELETE_USER = 'DeleteUser'.freeze
    UNLOCK_USER_ACCOUNT = 'UnlockUserAccount'.freeze
    ENABLE_REMOTE_DESKTOP = 'EnableRemoteDesktop'.freeze
    DISABLE_REMOTE_DESKTOP = 'DisableRemoteDesktop'.freeze

    # devices

    SETTINGS = 'Settings'.freeze
    CLEAR_PASSCODE = 'ClearPasscode'.freeze
    UPDATE_INVENTORY = 'UpdateInventory'.freeze
    CLEAR_RESTRICTIONS_PASSWORD = 'ClearRestrictionsPassword'.freeze
    ENABLE_DATA_ROAMING = 'SettingsEnableDataRoaming'.freeze
    DISABLE_DATA_ROAMING = 'SettingsDisableDataRoaming'.freeze
    ENABLE_VOICE_ROAMING = 'SettingsEnableVoiceRoaming'.freeze
    DISABLE_VOICE_ROAMING = 'SettingsDisableVoiceRoaming'.freeze

    # shared ipads only

    PASSCODE_LOCK_GRACE_PERIOD = 'PasscodeLockGracePeriod'.freeze

    # supervised devices

    WALLPAPER = 'Wallpaper'.freeze
    DEVICE_NAME = 'DeviceName'.freeze
    SHUTDOWN_DEVICE = 'ShutDownDevice'.freeze
    RESTART_DEVICE = 'RestartDevice'.freeze
    ENABLE_LOST_MODE = 'EnableLostMode'.freeze
    DISABLE_LOST_MODE = 'DisableLostMode'.freeze
    DEVICE_LOCATION = 'DeviceLocation'.freeze
    PLAY_LOST_MODE_SOUND = 'PlayLostModeSound'.freeze
    ENABLE_APP_ANALYTICS = 'SettingsEnableAppAnalytics'.freeze
    DISABLE_APP_ANALYTICS = 'SettingsDisableAppAnalytics'.freeze
    ENABLE_DIAGNOSTIC_SUBMISSION = 'SettingsEnableDiagnosticSubmission'.freeze
    DISABLE_DIAGNOSTIC_SUBMISSION = 'SettingsDisableDiagnosticSubmission'.freeze

    #### Groupings of commands

    # The MDM commands applicable to computers
    COMPUTER_COMMANDS = [
      BLANK_PUSH,
      DEVICE_LOCK,
      ERASE_DEVICE,
      UNMANGE_DEVICE,
      DELETE_USER,
      UNLOCK_USER_ACCOUNT,
      ENABLE_REMOTE_DESKTOP,
      DISABLE_REMOTE_DESKTOP
    ].freeze

    # The MDM commands applicable to all mobile devices
    ALL_DEVICE_COMMANDS = [
      BLANK_PUSH,
      DEVICE_LOCK,
      ERASE_DEVICE,
      UNMANGE_DEVICE,
      SETTINGS,
      CLEAR_PASSCODE,
      UPDATE_INVENTORY,
      ENABLE_DATA_ROAMING,
      DISABLE_DATA_ROAMING,
      ENABLE_VOICE_ROAMING,
      DISABLE_VOICE_ROAMING,
      PASSCODE_LOCK_GRACE_PERIOD
    ].freeze

    # The MDM commands applicable to supervised mobile devices
    SUPERVISED_DEVICE_COMMANDS = [
      WALLPAPER,
      DEVICE_NAME,
      SHUTDOWN_DEVICE,
      RESTART_DEVICE,
      CLEAR_RESTRICTIONS_PASSWORD,
      ENABLE_LOST_MODE,
      DISABLE_LOST_MODE,
      DEVICE_LOCATION,
      PLAY_LOST_MODE_SOUND,
      ENABLE_APP_ANALYTICS,
      DISABLE_APP_ANALYTICS,
      ENABLE_DIAGNOSTIC_SUBMISSION,
      DISABLE_DIAGNOSTIC_SUBMISSION
    ].freeze

    # The MDM commands applicable to mobile devices
    DEVICE_COMMANDS = ALL_DEVICE_COMMANDS + SUPERVISED_DEVICE_COMMANDS

    # Symbols that can be used to represent the commands to the
    # {.send_mdm_command} Class method.
    # Alternates are provided to match both the actual API command,
    # and the command label in the JSS web UI, as well as common
    # variants.
    # e.g. the DeviceLock command in the API, is recognized as:
    # :device_lock and :lock_device, and just :lock
    #
    COMMANDS = {

      # all objects
      blank_push: BLANK_PUSH,
      send_blank_push: BLANK_PUSH,
      noop: BLANK_PUSH,

      device_lock: DEVICE_LOCK,
      lock_device: DEVICE_LOCK,
      lock: DEVICE_LOCK,

      erase_device: ERASE_DEVICE,
      wipe_device: ERASE_DEVICE,
      wipe_computer: ERASE_DEVICE,
      wipe: ERASE_DEVICE,
      erase: ERASE_DEVICE,

      unmanage_device: UNMANGE_DEVICE,
      remove_mdm_profile: UNMANGE_DEVICE,

      # computers only
      unlock_user_account: UNLOCK_USER_ACCOUNT,

      delete_user: DELETE_USER,

      enable_remote_desktop: ENABLE_REMOTE_DESKTOP,
      disable_remote_desktop: DISABLE_REMOTE_DESKTOP,

      # mobile devices only
      settings: SETTINGS, # not yet implemented as its own method

      update_inventory: UPDATE_INVENTORY,
      recon: UPDATE_INVENTORY,

      clear_passcode: CLEAR_PASSCODE,

      clear_restrictions_password: CLEAR_RESTRICTIONS_PASSWORD,

      enable_data_roaming: ENABLE_DATA_ROAMING,
      disable_data_roaming: DISABLE_DATA_ROAMING,

      enable_voice_roaming: ENABLE_VOICE_ROAMING,
      disable_voice_roaming: DISABLE_VOICE_ROAMING,

      # supervized mobile devices only
      device_name: DEVICE_NAME, # implemented as part of MobileDevice.name=

      wallpaper: WALLPAPER,
      set_wallpaper: WALLPAPER,

      passcode_lock_grace_period: PASSCODE_LOCK_GRACE_PERIOD,

      shut_down_device: SHUTDOWN_DEVICE,
      shutdown_device: SHUTDOWN_DEVICE,
      shut_down: SHUTDOWN_DEVICE,
      shutdown: SHUTDOWN_DEVICE,

      restart_device: RESTART_DEVICE,
      restart: RESTART_DEVICE,

      enable_app_analytics: ENABLE_APP_ANALYTICS,
      disable_app_analytics: DISABLE_APP_ANALYTICS,

      enable_diagnostic_submission: ENABLE_DIAGNOSTIC_SUBMISSION,
      disable_diagnostic_submission: DISABLE_DIAGNOSTIC_SUBMISSION,

      enable_lost_mode: ENABLE_LOST_MODE,
      disable_lost_mode: DISABLE_LOST_MODE,

      device_location: DEVICE_LOCATION, # not yet implemented as its own method

      play_lost_mode_sound: PLAY_LOST_MODE_SOUND
    }.freeze

    ### Command Data

    COMMAND_DATA = {
      DEVICE_LOCK => :passcode, # 6 char passcode
      ERASE_DEVICE => String, # 6 char passcode
      DELETE_USER => String, # username
      UNLOCK_USER_ACCOUNT => String # username
    }.freeze

    WALLPAPER_LOCATIONS = {
      lock_screen: 1,
      home_screen: 2,
      lock_and_home_screen: 3
    }.freeze

    ### Status

    # the status to flush for 'pending'
    PENDING_STATUS = 'Pending'.freeze

    # the status to flush for 'failed'
    FAILED_STATUS = 'Failed'.freeze

    # the status to flush for both pending and failed
    PENDINGFAILED_STATUS = 'Pending+Failed'.freeze

    FLUSHABLE_STATUSES = {
      pending: PENDING_STATUS,
      failed: FAILED_STATUS,
      pending_failed: PENDINGFAILED_STATUS
    }.freeze

    BLANK_PUSH_RESULT = 'Command sent'.freeze

    # xml elements

    GENERAL_ELEMENT = 'general'.freeze
    COMMAND_ELEMENT = 'command'.freeze
    TARGET_ID_ELEMENT = 'id'.freeze

    COMPUTER_COMMAND_ELEMENT = 'computer_command'.freeze
    COMPUTER_ID_ELEMENT = 'computer_id'.freeze
    COMPUTER_COMMAND_UDID_ELEMENT = 'command_uuid'.freeze

    DEVICE_COMMAND_ELEMENT = 'mobile_device_command'.freeze
    DEVICE_LIST_ELEMENT = 'mobile_devices'.freeze
    DEVICE_ID_ELEMENT = 'id'.freeze
    DEVICE_COMMAND_STATUS_ELEMENT = 'status'.freeze

    # Mixin Class Methods
    ###########################

    # See
    # https://codereview.stackexchange.com/questions/23637/mixin-both-instance-and-class-methods-in-ruby
    # for discussion of this technique for mixing in both
    # Class and Instance methods when including a module.
    #
    module ClassMethods

      # Send an MDM command to one or more targets without instantiating them.
      #
      # This general class method, and all the specific ones that all it, have
      # matching instance methods. Use the class method when you don't have, or
      # don't want to retrieve, instances of all the targets.
      #
      # If you do have an instance or a target, call the matching instance method
      # to send commands to that specific target.
      #
      # @example send a blank push to mobiledevice id 12 without instantiating:
      #
      #   JSS::MobileDevice.send_blank_push 12
      #
      # @example send a blank push to mobiledevice id 12 with instantiating:
      #
      #   device = JSS::MobileDevice.fetch id: 12
      #   device.send_blank_push
      #
      # @example send a blank push to computers in computer groups
      #   'SpecialMacs' and 'FooBarGroup'
      #
      #   JSS::ComputerGroup.send_blank_push ['SpecialMacs', 'FooBarGroup']
      #
      # @param targets[String,Integer,Array<String,Integer>]
      #   the name or id of the device(s), or devicegroup(s) to receive the
      #   command, or an array of such names or ids. NOTE: when calling this on a
      #   Group class, the targets are the groups themselves, not the individual
      #   members - the membership will be expanded.
      #
      # @param command[Symbol] the command to send, one of the keys
      #   of COMMANDS
      #
      # @param opts[Hash] Some commands require extra data, e.g. a device name.
      #   Put it here
      #
      # @param api[JSS::APIConnection] the API connection to use. Defaults to the
      #   currently active API, see {JSS::APIConnection}
      #
      # @return [Hash{Integer=>String}] Keys are the target device ids.
      #   Values depend on the kind of target:
      #   - Computers will have the udid of the command sent to that computer.
      #     The udid can be used to later retrieve info about the command.
      #   - Mobile Devices seem to only have one command udid returned - for the
      #     last device to have the command sent to it. (even in the Database,
      #     not just in the API). So instead, the Hash value is the status of
      #     the command for that device, most often 'Command sent'
      #   Blank pushes do not generate return values, so Hash values are
      #   always 'Command sent' (an error will be raised if there are problems
      #   sending)
      #
      def send_mdm_command(targets, command, opts: {}, api: JSS.api)
        command = validate_command(command)

        rsrc = "#{send_command_rsrc}/command/#{command}"

        targets = raw_targets_to_ids targets, api: api

        cmd_xml = mdm_command_xml(command, opts, targets)

        if JSS.devmode?
          puts "Sending XML:\n"
          REXML::Document.new(cmd_xml).write STDOUT, 2
          puts "\n\nTo rsrc: #{rsrc}"
        end

        result = api.post_rsrc rsrc, cmd_xml

        if command == BLANK_PUSH
          hash = {}
          targets.each { |t| hash[t] = BLANK_PUSH_RESULT }
        elsif COMPUTER_TARGETS.include? self::MDM_COMMAND_TARGET
          hash = process_computer_xml_result(result)
        elsif DEVICE_TARGETS.include? self::MDM_COMMAND_TARGET
          hash = process_mobiledevice_xml_result(result)
        end

        hash
      end

      # Convert the result of senting a computer MDM command into
      # the appropriate hash
      #
      # @param result [String] The raw XML from POSTing a computer command
      #
      # @return (see #send_mdm_command)
      #
      def process_computer_xml_result(result)
        hash = {}
        REXML::Document.new(result).elements[COMPUTER_COMMAND_ELEMENT].each_element do |cmd|
          compid = cmd.elements[COMPUTER_ID_ELEMENT].text.to_i
          udid = cmd.elements[COMPUTER_COMMAND_UDID_ELEMENT].text
          hash[compid] = udid
        end
        hash
      end

      # Convert the result of senting a device MDM command into
      # the appropriate hash
      #
      # @param result [String] The raw XML from POSTing a device command
      #
      # @return (see #send_mdm_command)
      #
      def process_mobiledevice_xml_result(result)
        hash = {}
        mds = REXML::Document.new(result).elements[DEVICE_COMMAND_ELEMENT].elements[DEVICE_LIST_ELEMENT]
        mds.each_element do |md|
          id = md.elements[DEVICE_ID_ELEMENT].text.to_i
          status = md.elements[DEVICE_COMMAND_STATUS_ELEMENT].text
          hash[id] = status
        end
        hash
      end

      # The API rsrc for sending MDM commands to this kind of target
      #
      # @return [String] The API rsrc.
      #
      def send_command_rsrc
        case self::MDM_COMMAND_TARGET
        when *COMPUTER_TARGETS
          COMPUTER_RSRC
        when *DEVICE_TARGETS
          DEVICE_RSRC
        else
          raise JSS::InvalidDataError, "Unknown MDM command target: #{self::MDM_COMMAND_TARGET}"
        end
      end

      # Convert the targets provided for sending a command into
      # the final list of computers or mobile devices.
      #
      # @param targets[String,Integer,Array] See {#send_mdm_command}
      #
      # @param expand_groups[Boolean] Should groups be expanded into member ids?
      #
      # @param api[JSS::APIConnection] an API connection to use.
      #
      # @return [Array<Integer>] The ids of the target devices for a command
      #
      def raw_targets_to_ids(targets, api: JSS.api, expand_groups: true)
        targets = targets.is_a?(Array) ? targets : [targets]

        # flush caches before checking ids and managment
        api.flushcache self::RSRC_LIST_KEY

        # make sure its an array of ids
        targets.map! do |md|
          id = valid_id md, api: api
          raise JSS::NoSuchItemError, "No #{self} matches identifier: #{md}" unless id
          id
        end # map!

        # expand group members if needed
        if expand_groups && GROUP_TARGETS.include?(self::MDM_COMMAND_TARGET)
          target_ids = []
          targets.each { |group_id| target_ids += fetch(id: group_id).member_ids }
          targets = target_ids
        end

        # make sure all of them are managed, or else the API will raise a 400
        # 'Bad Request' when sending the command to an unmanaged target
        all_mgd = map_all_ids_to(:managed, api: api).select { |_id, mgd| mgd }.keys

        targets.each do |target_id|
          raise JSS::UnmanagedError, "#{self} with id #{target_id} is not managed. Cannot send command." unless all_mgd.include? target_id
        end

        targets
      end

      # Generate the XML to send to the API, sending the MDM command to the targets
      #
      # @param command [Symbol] the command to be sent, a key from COMMANDS
      #
      # @param options [Hash] different commands require different options,
      #   see each command method
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @return [String] The XML content to send to the API
      #
      def mdm_command_xml(command, options, targets)
        raise JSS::MissingDataError, 'Targets cannot be empty' if targets.empty?

        case self::MDM_COMMAND_TARGET
        when *COMPUTER_TARGETS
          command_elem = COMPUTER_COMMAND_ELEMENT
          target_list_elem = JSS::Computer::RSRC_LIST_KEY.to_s
          target_elem = JSS::Computer::RSRC_OBJECT_KEY.to_s
        when *DEVICE_TARGETS
          command_elem = DEVICE_COMMAND_ELEMENT
          target_list_elem = JSS::MobileDevice::RSRC_LIST_KEY.to_s
          target_elem = JSS::MobileDevice::RSRC_OBJECT_KEY.to_s
        else
          raise JSS::NoSuchItemError, "Unknonwn MDM command target: #{self::MDM_COMMAND_TARGET}"
        end # case

        xml = REXML::Document.new JSS::APIConnection::XML_HEADER
        cmd_xml = xml.add_element command_elem

        general = cmd_xml.add_element GENERAL_ELEMENT
        general.add_element(COMMAND_ELEMENT).text = command
        options.each do |opt, val|
          general.add_element(opt.to_s).text = val.to_s
        end # do opt val

        tgt_list = cmd_xml.add_element target_list_elem
        targets.each do |tgt_id|
          tgt = tgt_list.add_element(target_elem)
          tgt.add_element(TARGET_ID_ELEMENT).text = tgt_id.to_s
        end

        xml.to_s
      end # self.mdm_command_xml(command, options)

      # Validate that this command is known and can be sent to this kind of
      # object, raising an error if not.
      #
      # @param command[Symbol] One of the symbolic commands as keys in COMMANDS
      #
      # @return [String] the matching value for the command symbol given
      #
      def validate_command(command)
        raise JSS::NoSuchItemError, "Unknown command '#{command}'" unless COMMANDS.keys.include? command

        command = COMMANDS[command]

        case self::MDM_COMMAND_TARGET
        when *COMPUTER_TARGETS
          return command if COMPUTER_COMMANDS.include? command
          raise JSS::UnsupportedError, "'#{command}' cannot be sent to computers or computer groups"
        when *DEVICE_TARGETS
          return command if DEVICE_COMMANDS.include? command
          raise JSS::UnsupportedError, "'#{command}' cannot be sent to mobile devices or mobile device groups"
        end

        raise JSS::NoSuchItemError, "'#{command}' is known, but not available for computers or mobile devices. This is a bug. Please report it."
      end

      ###### The individual commands

      # NOTE: not implementing Settings and Location until I know more what they do

      # Commands for both computers and devices
      ################################

      # Send a blank push to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)]
      #
      def blank_push(targets, api: JSS.api)
        send_mdm_command targets, :blank_push, api: api
      end
      alias send_blank_push blank_push
      alias noop blank_push

      # Send a Device Lock to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param passcode[String] a six-char passcode, required for computers & computergroups
      #
      # @param message[String] An optional message to display on mobiledevices & mobiledevicegroups
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def device_lock(targets, passcode: '', message: nil, api: JSS.api)
        case self::MDM_COMMAND_TARGET
        when *COMPUTER_TARGETS
          raise JSS::InvalidDataError, 'Locking computers requires a 6-character String passcode' unless passcode.size == 6
          opts = { passcode: passcode }
        when *DEVICE_TARGETS
          opts = {}
          opts[:lock_message] = message if message
        end # case
        send_mdm_command targets, :device_lock, opts: opts, api: api
      end
      alias lock_device device_lock
      alias lock device_lock

      # Send an Erase Device command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param passcode[String] a six-char passcode, required for computers & computergroups
      #
      # @param preserve_data_plan[Boolean] Should the data plan of the mobile device be preserved?
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def erase_device(targets, passcode: '', preserve_data_plan: false, api: JSS.api)
        case self::MDM_COMMAND_TARGET
        when *COMPUTER_TARGETS
          raise JSS::InvalidDataError, 'Erasing computers requires a 6-character String passcode' unless passcode.size == 6
          opts = { passcode: passcode }
        when *DEVICE_TARGETS
          opts = {}
          opts[:preserve_data_plan] = 'true' if preserve_data_plan
        end # case
        send_mdm_command targets, :erase_device, opts: opts, api: api
      end
      alias wipe erase_device
      alias wipe_device erase_device
      alias erase erase_device
      alias wipe_computer erase_device

      # Send an Unmanage Device command to one or more targets
      #
      # NOTE: when used with computers, the mdm profile will probably
      # be re-installed immediately unless the computer is also no longer
      # managed by Jamf Pro itself. To fully unmanage a computer, use
      # the {JSS::Computer#make_unmanaged} instance method.
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def unmanage_device(targets, api: JSS.api)
        send_mdm_command targets, :unmanage_device, api: api
      end
      alias remove_mdm_profile unmanage_device

      # Commands for computers only
      ################################

      # Send an unlock_user_account command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param user[String] the username of the acct to unlock
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def unlock_user_account(targets, user, api: JSS.api)
        send_mdm_command targets, :unlock_user_account, opts: { user_name: user }, api: api
      end

      # Send a delete_user command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param user[String] the username of the acct to delete
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def delete_user(targets, user, api: JSS.api)
        send_mdm_command targets, :delete_user, opts: { user_name: user }, api: api
      end

      # Send an enable_remote_desktop command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_remote_desktop(targets, api: JSS.api)
        send_mdm_command targets, :enable_remote_desktop, api: api
      end

      # Send a disable_remote_desktop command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_remote_desktop(targets, api: JSS.api)
        send_mdm_command targets, :disable_remote_desktop, api: api
      end

      # Commands for mobile devices only
      ################################

      # Send an update_inventory command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def update_inventory(targets, api: JSS.api)
        send_mdm_command targets, :update_inventory, api: api
      end
      alias recon update_inventory

      # Send an clear_passcode command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def clear_passcode(targets, api: JSS.api)
        send_mdm_command targets, :clear_passcode, api: api
      end

      # Send an clear_restrictions_password command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def clear_restrictions_password(targets, api: JSS.api)
        send_mdm_command targets, :clear_restrictions_password, api: api
      end

      # Send an enable_data_roaming command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_data_roaming(targets, api: JSS.api)
        send_mdm_command targets, :enable_data_roaming, api: api
      end

      # Send andisable_data_roaming command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_data_roaming(targets, api: JSS.api)
        send_mdm_command targets, :disable_data_roaming, api: api
      end

      # Send an enable_voice_roaming command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_voice_roaming(targets, api: JSS.api)
        send_mdm_command targets, :enable_voice_roaming, api: api
      end

      # Send a disable_voice_roaming command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_voice_roaming(targets, api: JSS.api)
        send_mdm_command targets, :disable_voice_roaming, api: api
      end

      # Commands for supervized mobile devices only
      ################################

      # Send a device_name command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param name[String] The new name
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def device_name(targets, name, api: JSS.api)
        send_mdm_command targets, :device_name, opts: { device_name: name }, api: api
      end
      alias set_name device_name
      alias set_device_name device_name

      # Send a wallpaper command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param wallpaper_setting[Symbol] :lock_screen, :home_screen, or :lock_and_home_screen
      #
      # @param wallpaper_content[String,Pathname] The local path to a .png or .jpg to use
      #   as the walpaper image, required if no wallpaper_id
      #
      # @param wallpaper_id[Symbol] The id of an Icon in Jamf Pro to use as the wallpaper image,
      #   required if no wallpaper_content
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def wallpaper(targets, wallpaper_setting: nil, wallpaper_content: nil, wallpaper_id: nil, api: JSS.api)
        raise ArgumentError, "wallpaper_setting must be one of: :#{WALLPAPER_LOCATIONS.keys.join ', :'}" unless WALLPAPER_LOCATIONS.keys.include? wallpaper_setting

        opts = { wallpaper_setting: WALLPAPER_LOCATIONS[wallpaper_setting] }

        if wallpaper_content
          file = Pathname.new wallpaper_content
          raise JSS::NoSuchItemError, "Not a file: #{file}" unless file.file?
          opts[:wallpaper_content] = Base64.encode64 file.read
        elsif wallpaper_id
          opts[:wallpaper_id] = wallpaper_id
        else
          raise ArgumentError, 'Either wallpaper_id: or wallpaper_content must be provided'
        end

        send_mdm_command targets, :wallpaper, opts: opts, api: api
      end
      alias set_wallpaper wallpaper

      # Send a passcode_lock_grace_period command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param secs[Integer] The numer of seconds for the grace period
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def passcode_lock_grace_period(targets, secs, api: JSS.api)
        send_mdm_command targets, :passcode_lock_grace_period, opts: { passcode_lock_grace_period: secs }, api: api
      end

      # Send a shut_down_device command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def shut_down_device(targets, api: JSS.api)
        send_mdm_command targets, :shut_down_device, api: api
      end
      alias shutdown_device shut_down_device
      alias shut_down shut_down_device
      alias shutdown shut_down_device

      # Send a restart_device command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def restart_device(targets, api: JSS.api)
        send_mdm_command targets, :restart_device, api: api
      end
      alias restart restart_device

      # Send an enable_app_analytics command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_app_analytics(targets, api: JSS.api)
        send_mdm_command targets, :enable_app_analytics, api: api
      end

      # Send a disable_app_analytics command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_app_analytics(targets, api: JSS.api)
        send_mdm_command targets, :disable_app_analytics, api: api
      end

      # Send an enable_diagnostic_submission command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_diagnostic_submission(targets, api: JSS.api)
        send_mdm_command targets, :enable_diagnostic_submission, api: api
      end

      # Send a disable_diagnostic_submission command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_diagnostic_submission(targets, api: JSS.api)
        send_mdm_command targets, :disable_diagnostic_submission, api: api
      end

      # Send a enable_lost_mode command to one or more targets
      #
      # Either or both of message and phone number must be provided
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param message[String] The message to display on the lock screen
      #
      # @param phone[String] The phone number to display on the lock screen
      #
      # @param footnote[String] Optional footnote to display on the lock screen
      #
      # @param play_sound[Boolean] Play a sound when entering lost mode
      #
      # @param enforce_lost_mode[Boolean] Re-enabled lost mode when re-enrolled after wipe.
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def enable_lost_mode(
            targets,
            message: nil,
            phone: nil,
            footnote: nil,
            play_sound: false,
            enforce_lost_mode: true,
            api: JSS.api
      )
        raise ArgumentError, 'Either message: or phone_number: must be provided' unless message || phone
        opts = { always_enforce_lost_mode: enforce_lost_mode }
        opts[:lost_mode_message] = message if message
        opts[:lost_mode_phone] = phone if phone
        opts[:lost_mode_footnote] = footnote if footnote
        opts[:lost_mode_with_sound] = 'true' if play_sound

        send_mdm_command targets, :enable_lost_mode, opts: opts, api: api
      end

      # Send a play_lost_mode_sound command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def play_lost_mode_sound(targets, api: JSS.api)
        send_mdm_command targets, :play_lost_mode_sound, api: api
      end

      # Send a disable_lost_mode command to one or more targets
      #
      # @param targets[String,Integer,Array<String,Integer>] @see .send_mdm_command
      #
      # @param api[JSS::APIConnection] the API thru which to send the command
      #
      # @return (see .send_mdm_command)
      #
      def disable_lost_mode(targets, api: JSS.api)
        send_mdm_command targets, :disable_lost_mode, api: api
      end

      # Flushing Commands
      ###############################

      # Flush pending or failed commands on devices or groups
      #
      # @param targets[String,Integer,Array<String,Integer>]
      #   the name or id of the device or group to flush commands, or
      #   an array of such names or ids, or a comma-separated string
      #   of them. NOTE: when calling this on a Group class, the targets
      #   are the groups themselves, not the individual members.
      #
      # @param status[String] a key from {JSS::Commandable::FLUSHABLE_STATUSES}
      #
      # @param api[JSS::APIConnection] an API connection to use.
      #   Defaults to the corrently active API. See {JSS::APIConnection}
      #
      # @return [void]
      #
      def flush_mdm_commands(targets, status: nil, api: JSS.api)
        raise JSS::InvalidDataError, "Status must be one of :#{FLUSHABLE_STATUSES.keys.join ', :'}" unless FLUSHABLE_STATUSES.keys.include? status

        status = FLUSHABLE_STATUSES[status]

        target_ids = raw_targets_to_ids targets, api: api, expand_groups: false

        command_flush_rsrc = "commandflush/#{self::MDM_COMMAND_TARGET}/id"

        flush_rsrc = "#{command_flush_rsrc}/#{target_ids.join ','}/status/#{status}"

        puts "Sending API DELETE: #{flush_rsrc}" if JSS.devmode?

        api.delete_rsrc flush_rsrc
      end

    end # module ClassMethods

    # Extend ourself when included
    # @see {JSS::MDM::ClassMethods}
    def self.included(klass)
      klass.extend JSS::MDM::ClassMethods
    end

    # Mixin Instance Methods
    ###########################
    # See https://codereview.stackexchange.com/questions/23637/mixin-both-instance-and-class-methods-in-ruby
    # for discussion of this technique for mixing in both
    # Class and Instance methods when including a module.

    # Commands for both computers and devices
    ################################

    # Send a blank push to this object
    #
    # @return [void]
    #
    def blank_push
      self.class.send_blank_push @id, api: @api
    end
    alias send_blank_push blank_push
    alias noop blank_push

    # Send a dev lock to this object
    #
    # @param passcode_or_message[String] a six-char passcode, required for computers & computergroups
    #   Or an optional message to display on mobiledevices & mobiledevicegroups
    #
    # @return (see .send_mdm_command)
    #
    def device_lock(passcode_or_message = '')
      self.class.device_lock @id, passcode: passcode_or_message, message: passcode_or_message, api: @api
    end
    alias lock device_lock
    alias lock_device device_lock

    # Send an erase device command to this object
    #
    # @param passcode[String] a six-char passcode, required for computers & computergroups
    #
    # @return (see .send_mdm_command)
    #
    def erase_device(passcode = '', preserve_data_plan: false)
      self.class.erase_device @id, passcode: passcode, preserve_data_plan: preserve_data_plan, api: @api
    end
    alias wipe_device erase_device
    alias wipe_computer erase_device
    alias wipe erase_device
    alias erase erase_device

    # Send an unmanage device command to this object
    #
    # NOTE: when used with computers, the mdm profile will probably
    # be re-installed immediately unless the computer is also no longer
    # managed by Jamf Pro itself. To fully unmanage a computer, use
    # the {JSS::Computer#make_unmanaged} instance method.
    #
    # @return (see .send_mdm_command)
    #
    def unmanage_device
      self.class.unmanage_device @id, api: @api
    end
    alias remove_mdm_profile unmanage_device

    # Commands for computers only
    ################################

    # Send an unlock_user_account command to this computer or group
    #
    # @param user[String] the username of the acct to unlock
    #
    # @return (see .send_mdm_command)
    #
    def unlock_user_account(user)
      self.class.unlock_user_account @id, user, api: @api
    end

    # Send a delete_user command to this computer or group
    #
    # @param user[String] the username of the acct to delete
    #
    # @return (see .send_mdm_command)
    #
    def delete_user(user)
      self.class.delete_user @id, user, api: @api
    end

    # Send an enable_remote_desktop command to this computer or group
    #
    # @return (see .send_mdm_command)
    #
    def enable_remote_desktop
      self.class.enable_remote_desktop @id, api: @api
    end

    # Send a disable_remote_desktop command to this computer or group
    #
    # @return (see .send_mdm_command)
    #
    def disable_remote_desktop
      self.class.disable_remote_desktop @id, api: @api
    end

    # Commands for mobile devices only
    ################################
    # mobile devices only
    # settings: SETTINGS,

    # Send an update_inventory command to this object
    #
    # @return (see .send_mdm_command)
    #
    def update_inventory
      self.class.update_inventory @id, api: @api
    end
    alias recon update_inventory

    # Send an clear_passcode command to this object
    #
    # @return (see .send_mdm_command)
    #
    def clear_passcode
      self.class.clear_passcode @id, api: @api
    end

    # Send an clear_restrictions_password command to this object
    #
    # @return (see .send_mdm_command)
    #
    def clear_restrictions_password
      self.class.clear_restrictions_password @id, api: @api
    end

    # Send an enable_data_roaming command to this object
    #
    # @return (see .send_mdm_command)
    #
    def enable_data_roaming
      self.class.enable_data_roaming @id, api: @api
    end

    # Send a disable_data_roaming command to this object
    #
    # @return (see .send_mdm_command)
    #
    def disable_data_roaming
      self.class.disable_data_roaming @id, api: @api
    end

    # Send an enable_voice_roaming command to this object
    #
    # @return (see .send_mdm_command)
    #
    def enable_voice_roaming
      self.class.enable_voice_roaming @id, api: @api
    end

    # Send a disable_voice_roaming command to this object
    #
    # @return (see .send_mdm_command)
    #
    def disable_voice_roaming
      self.class.disable_voice_roaming @id, api: @api
    end

    # Commands for supervized mobile devices only
    #
    # NOTE: DeviceName is sent to supervised devices when
    # their name is changed with #name= and they are then
    # updated in the JSS with #update/#save
    ################################

    # Send a device_name command to this object
    #
    # @param name[String] The new name
    #
    # @return (see .send_mdm_command)
    #
    def device_name(name)
      self.class.device_name @id, name, api: @api
    end
    alias set_name device_name
    alias set_device_name device_name

    # Send a wallpaper command to this object
    #
    # @param wallpaper_setting[Symbol] :lock_screen, :home_screen, or :lock_and_home_screen
    #
    # @param wallpaper_content[String,Pathname] The local path to a .png or .jpg to use
    #   as the walpaper image, required if no wallpaper_id
    #
    # @param wallpaper_id[Symbol] The id of an Icon in Jamf Pro to use as the wallpaper image,
    #   required if no wallpaper_content
    #
    # @return (see .send_mdm_command)
    #
    def wallpaper(wallpaper_setting: nil, wallpaper_content: nil, wallpaper_id: nil)
      self.class.wallpaper(
        @id,
        wallpaper_setting: wallpaper_setting,
        wallpaper_content: wallpaper_content,
        wallpaper_id: wallpaper_id,
        api: @api
      )
    end
    alias set_wallpaper wallpaper

    # Send a passcode_lock_grace_period command to this object
    #
    # @param secs[Integer] The numer of seconds for the grace period
    #
    # @return (see .send_mdm_command)
    #
    def passcode_lock_grace_period(secs)
      self.class.passcode_lock_grace_period @id, secs, api: @api
    end

    # Send a shut_down_device command to this object
    #
    # @return (see .send_mdm_command)
    #
    def shut_down_device
      self.class.shut_down_device @id, api: @api
    end
    alias shutdown_device shut_down_device
    alias shut_down shut_down_device
    alias shutdown shut_down_device

    # Send a restart_device command to this object
    #
    # @return (see .send_mdm_command)
    #
    def restart_device
      self.class.restart_device @id, api: @api
    end
    alias restart restart_device

    # Send an enable_app_analytics command to this object
    #
    # @return (see .send_mdm_command)
    #
    def enable_app_analytics
      self.class.enable_app_analytics @id, api: @api
    end

    # Send a disable_app_analytics command to this object
    #
    # @return (see .send_mdm_command)
    #
    def disable_app_analytics
      self.class.disable_app_analytics @id, api: @api
    end

    # Send an enable_diagnostic_submission command to this object
    #
    # @return (see .send_mdm_command)
    #
    def enable_diagnostic_submission
      self.class.enable_diagnostic_submission @id, api: @api
    end

    # Send a disable_diagnostic_submission command to this object
    #
    # @return (see .send_mdm_command)
    #
    def disable_diagnostic_submission
      self.class.disable_diagnostic_submission @id, api: @api
    end

    # Send a enable_lost_mode command to one or more targets
    #
    # Either or both of message and phone number must be provided
    #
    # @param message[String] The message to display on the lock screen
    #
    # @param phone_number[String] The phone number to display on the lock screen
    #
    # @param footnote[String] Optional footnote to display on the lock screen
    #
    # @param play_sound[Boolean] Play a sound when entering lost mode
    #
    # @param enforce_lost_mode[Boolean] Re-enabled lost mode when re-enrolled after wipe.
    #
    # @return (see .send_mdm_command)
    #
    def enable_lost_mode(
          message: nil,
          phone_number: nil,
          footnote: nil,
          enforce_lost_mode: true,
          play_sound: false
    )
      self.class.enable_lost_mode(
        @id,
        message: message,
        phone_number: phone_number,
        footnote: footnote,
        play_sound: play_sound,
        enforce_lost_mode: enforce_lost_mode,
        api: @api
      )
    end

    # Send a play_lost_mode_sound command to this object
    #
    # @return (see .send_mdm_command)
    #
    def play_lost_mode_sound
      self.class.play_lost_mode_sound @id, api: @api
    end

    # Send a disable_lost_mode command to this object
    #
    # @return (see .send_mdm_command)
    #
    def disable_lost_mode
      self.class.disable_lost_mode @id, api: @api
    end

    # Flushing Commands
    ###############################

    # flush pending and/or failed MDM commands for this object
    #
    # @param status[String] a key from {JSS::Commandable::FLUSHABLE_STATUSES}
    #
    # @return [void]
    #
    def flush_mdm_commands(status)
      self.class.flush_mdm_commands @id, status: status, api: @api
    end

  end # module MDM

end # module
