# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # jamf client computer
  class Client

    #  Module for working with the Management Action.app, which is an interface
    # to the Notification Center
    # This should be included into Jamf::Client
    #####################################
    module ManagementAction

      # The Pathname to the Management Action executable
      MGMT_ACTION = SUPPORT_BIN_FOLDER + 'Management Action.app/Contents/MacOS/Management Action'

      # NC_ALERT_STYLE_FLAGS = 4432
      # NCPREFS_DOMAIN = 'com.apple.ncprefs'.freeze
      # MGMT_ACTION_BUNDLE_ID = 'com.jamfsoftware.Management-Action'.freeze
      # HUP_NOTIF_CTR_CMD = '/usr/bin/killall sighup usernoted NotificationCenter'.freeze

      # when this module is included, also extend our Class Methods
      def self.included(includer)
        Jamf.load_msg "--> #{includer} is including Jamf::Client::ManagementAction"
        includer.extend(ClassMethods)
      end

      # class Methods
      #####################################

      module ClassMethods

        def management_action(msg, title: nil, subtitle: nil, delay: 0)
          raise Jamf::InvalidDataError, 'delay: must be a non-negative integer.' unless delay.is_a?(Integer) && delay > -1

          cmd = Shellwords.escape MGMT_ACTION.to_s
          cmd << " -message #{Shellwords.escape msg.to_s}"
          cmd << " -title #{Shellwords.escape title.to_s}" if title
          cmd << " -subtitle #{Shellwords.escape subtitle.to_s}" if subtitle
          cmd << " -deliverydelay #{Shellwords.escape delay}" if delay > 0
          `#{cmd} 2>&1`
        end
        alias nc_notify management_action

        # Skipping all the force-alerts stuff until we figure out cleaner
        # ways to do it in 10.13+
        # The plan is to be able to make the NotificationCenter notification be an
        # 'alert' (which stays visible til the user clicks) or a
        # 'banner' (which vanishes in a few seconds), regardless of the user's
        # setting in the NC prefs.

        def force_alerts
          orig_flags = {}
          console_users.each do |user|
            orig_flags[user] = set_mgmt_action_ncprefs_flags user, NC_ALERT_STYLE_FLAGS, hup: false
          end
          system HUP_NOTIF_CTR_CMD unless orig_flags.empty?
          sleep 1
          orig_flags
        end

        def restore_alerts(orig_flags)
          orig_flags.each do |user, flags|
            set_mgmt_action_ncprefs_flags user, flags, hup: false
          end
          system HUP_NOTIF_CTR_CMD unless orig_flags.empty?
        end

        # set the NotificationCenter option flags for a user
        # flags = an integer.
        #
        # Doesn't seem to work in 10.13, so ignore this for now.
        #
        # @return [Integer] the original flags, or given flags if no originals.
        #
        def set_mgmt_action_ncprefs_flags(user, flags, hup: true)
          plist = Pathname.new "/Users/#{user}/Library/Preferences/#{NCPREFS_DOMAIN}.plist"
          prefs = JSS.parse_plist plist
          mgmt_action_setting = prefs['apps'].select { |a| a['bundle-id'] == MGMT_ACTION_BUNDLE_ID }.first
          if mgmt_action_setting
            orig_flags = mgmt_action_setting['flags']
            mgmt_action_setting['flags'] = flags
          else
            orig_flags = flags
            prefs['apps'] << { 'bundle-id' => MGMT_ACTION_BUNDLE_ID, 'flags' => flags }
          end
          plist.open('w') { |f| f.write JSS.xml_plist_from(prefs) }
          system HUP_NOTIF_CTR_CMD if hup
          orig_flags
        end

      end # ClassMethods

    end # moculde

  end # class Client

end # module
