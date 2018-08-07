### Copyright 2018 Pixar

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

  #
  class Client

    #  Constants
    #####################################

    # The Pathname to the Management Action executable
    MGMT_ACTION = SUPPORT_BIN_FOLDER + 'Management Action.app/Contents/MacOS/Management Action'

    # NC_ALERT_STYLE_FLAGS = 4432
    # NCPREFS_DOMAIN = 'com.apple.ncprefs'.freeze
    # MGMT_ACTION_BUNDLE_ID = 'com.jamfsoftware.Management-Action'.freeze
    # HUP_NOTIF_CTR_CMD = '/usr/bin/killall sighup usernoted NotificationCenter'.freeze

    # class Methods
    #####################################

    def self.management_action(msg, title: nil, subtitle: nil, delay: 0)
      raise JSS::InvalidDataError, 'delay: must be a non-negative integer.' unless delay.is_a?(Integer) && delay > -1

      cmd = Shellwords.escape MGMT_ACTION.to_s
      cmd << " -message #{Shellwords.escape msg.to_s}"
      cmd << " -title #{Shellwords.escape title.to_s}" if title
      cmd << " -subtitle #{Shellwords.escape subtitle.to_s}" if subtitle
      cmd << " -deliverydelay #{Shellwords.escape delay}" if delay > 0
      `#{cmd} 2>&1`
    end

    # an alias of management_action
    def self.nc_notify(msg, title: nil, subtitle: nil, delay: 0)
      management_action(msg, title: title, subtitle: subtitle, delay: delay)
    end

    private_class_method

    # Skipping all the force-alerts stuff until we figure out cleaner
    # ways to do it in 10.13+
    # The plan is to be able to make the NotificationCenter notification be an
    # 'alert' (which stays visible til the user clicks) or a
    # 'banner' (which vanishes in a few seconds), regardless of the user's
    # setting in the NC prefs.

    def self.force_alerts
      orig_flags = {}
      console_users.each do |user|
        orig_flags[user] = set_mgmt_action_ncprefs_flags user, NC_ALERT_STYLE_FLAGS, hup: false
      end
      system HUP_NOTIF_CTR_CMD unless orig_flags.empty?
      sleep 1
      orig_flags
    end

    def self.restore_alerts(orig_flags)
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
    def self.set_mgmt_action_ncprefs_flags(user, flags, hup: true)
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
      # system "/usr/bin/defaults write #{NCPREFS_DOMAIN} '#{prefs.to_plist}'"
      plist.open('w') { |f| f.write prefs.to_plist }
      system HUP_NOTIF_CTR_CMD if hup
      orig_flags
    end

  end # class Client

end # module
