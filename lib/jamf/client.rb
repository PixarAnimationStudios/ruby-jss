### Copyright 2022 Pixar

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

module Jamf

  # This module contains methods for working locally on a managed Jamf client
  # computer, on which this code is running.
  #
  class Client

    # The Pathname to the preferences plist used by the jamf binary
    JAMF_PLIST = Pathname.new '/Library/Preferences/com.jamfsoftware.jamf.plist'

    # The Pathname to the JAMF support folder
    JAMF_SUPPORT_FOLDER = Pathname.new '/Library/Application Support/JAMF'

    # The JAMF receipts folder, where package installs are tracked.
    RECEIPTS_FOLDER = JAMF_SUPPORT_FOLDER + 'Receipts'

    # The JAMF downloads folder
    DOWNLOADS_FOLDER = JAMF_SUPPORT_FOLDER + 'Downloads'

    # The bin folder inside the Jamf support folder
    SUPPORT_BIN_FOLDER = JAMF_SUPPORT_FOLDER + 'bin'

    # This command gives raw info about console users
    CONSOLE_USERS_SCUTIL_CMD = 'echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil'.freeze

    # ignore console user = root (loginwindow)
    ROOT_USER = 'root'.freeze

    # ignore primary console user loginwindow
    LOGINWINDOW_USER = 'loginwindow'.freeze

    # The end of the path to the Self Service Executable.
    # Used to figure out who's running Self Service.app
    SELF_SERVICE_EXECUTABLE_END = '/Self Service.app/Contents/MacOS/Self Service'.freeze

    # the ps command used to figure out who's running Self Service
    PS_USER_COMM = 'ps -A -o user,comm'.freeze

    # the path to a users byhost folder from home
    USER_PREFS_BYHOST_FOLDER = 'Library/Preferences/ByHost/'.freeze

    include Jamf::Client::JamfBinary
    include Jamf::Client::JamfHelper
    include Jamf::Client::ManagementAction

    # Class Methods
    #####################################

    # Get the current IP address as a String.
    #
    # This handy code doesn't acutally make a UDP connection,
    # it just starts to set up the connection, then uses that to get
    # the local IP.
    #
    # Lifted gratefully from
    # http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
    #
    # @return [String] the current IP address.
    #
    def self.my_ip_address
      # turn off reverse DNS resolution temporarily
      # @note the 'socket' library has already been required by 'rest-client'
      orig = Socket.do_not_reverse_lookup
      Socket.do_not_reverse_lookup = true

      UDPSocket.open do |s|
        s.connect '192.168.0.0', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end

    # Is the jamf binary installed?
    #
    # @return [Boolean] is the jamf binary installed?
    #
    def self.installed?
      JAMF_BINARY.executable?
    end

    # What version of the jamf binary is installed?
    #
    # @return [String,nil] the version of the jamf binary installed on this client, nil if not installed
    #
    def self.jamf_version
      installed? ? run_jamf(:version).chomp.split('=')[1] : nil
    end

    # the URL to the jss for this client
    #
    # @return [String] the url to the JSS for this client
    #
    def self.jss_url
      @url = jamf_plist['jss_url']
      return nil if @url.nil?
      @url =~ %r{(https?)://(.+):(\d+)/}
      @protocol = Regexp.last_match(1)
      @server = Regexp.last_match(2)
      @port = Regexp.last_match(3)
      @url
    end

    # The JSS server hostname for this client
    #
    # @return [String] the JSS server for this client
    #
    def self.jss_server
      jss_url
      @server
    end

    # The protocol for JSS connections for this client
    #
    # @return [String] the protocol to the JSS for this client, "http" or "https"
    #
    def self.jss_protocol
      jss_url
      @protocol
    end

    # The port number for JSS connections for this client
    #
    # @return [Integer] the port to the JSS for this client
    #
    def self.jss_port
      jss_url
      @port
    end

    # The contents of the JAMF plist
    #
    # @return [Hash] the parsed contents of the JAMF_PLIST if it exists,
    # an empty hash if not
    #
    def self.jamf_plist
      return {} unless JAMF_PLIST.file?
      JSS.parse_plist JAMF_PLIST
    end

    # All the JAMF receipts on this client
    #
    # @return [Array<Pathname>] an array of Pathnames for all regular files in the jamf receipts folder
    #
    def self.receipts
      raise Jamf::NoSuchItemError, "The JAMF Receipts folder doesn't exist on this computer." unless RECEIPTS_FOLDER.exist?
      RECEIPTS_FOLDER.children.select(&:file?)
    end

    # Is the JSS available right now?
    #
    # @return [Boolean] is the JSS available now?
    #
    def self.jss_available?
      run_jamf :checkJSSConnection, '-retry 1'
      $CHILD_STATUS.exitstatus.zero?
    end

    # The Jamf::Computer object for this computer
    #
    # @return [Jamf::Computer,nil] The JSS record for this computer, nil if not in the JSS
    #
    def self.jss_record
      Jamf::Computer.fetch udid: udid
    rescue Jamf::NoSuchItemError
      nil
    end

    # The UUID for this computer via system_profiler
    #
    # @return [String] the UUID/UDID for this computer
    #
    def self.udid
      hardware_data['platform_UUID']
    end

    # The serial number for this computer via system_profiler
    #
    # @return [String] the serial number for this computer
    #
    def self.serial_number
      hardware_data['serial_number']
    end

    # The parsed HardwareDataType output from system_profiler
    #
    # @return [Hash] the HardwareDataType data from the system_profiler command
    #
    def self.hardware_data
      raw = `/usr/sbin/system_profiler SPHardwareDataType -xml 2>/dev/null`
      JSS.parse_plist(raw)[0]['_items'][0]
    end

    # Who's currently got an active GUI session? - might be
    # more than one if Fast User Switching is in use.
    #
    # @return [Array<String>] The current users with GUI sessions
    #
    def self.console_users
      output = `#{CONSOLE_USERS_SCUTIL_CMD}`
      userlines = output.lines.select { |l| l =~ /SessionUserNameKey\s*:/ }
      userlines.map! { |ul| ul.split(':').last.strip }
      userlines.reject { |un| un == ROOT_USER }
    end

    # Which console user is using the primary GUI console?
    # Returns nil if the primary GUI console is at the login window.
    #
    # @return [String,nil] The login name of the user is using the primary
    #   GUI console, or nil if at the login window.
    #
    def self.primary_console_user
      `#{CONSOLE_USERS_SCUTIL_CMD}` =~ /^\s*Name : (\S+)$/
      user = Regexp.last_match(1)
      user == LOGINWINDOW_USER ? nil : user
    end

    # alias for primary_console_user
    def self.console_user
      primary_console_user
    end

    # Who's currently running Self Service.app? - might be
    # more than one if Fast User Switching is in use.
    #
    # @return [Array<String>] The current users running Self Service.app
    #
    def self.self_service_users
      ss_userlines = `#{PS_USER_COMM}`.lines.select { |l| l.include? SELF_SERVICE_EXECUTABLE_END }
      ss_userlines.map { |ssl| ssl.split(' ').first }
    end

    # @param user[String, nil] The user to query, the current user if nil.
    #
    # @return [Boolean, nil] Is 'Do Not Disturb' enabled for the user?
    #  nil if unknown/not-applicable
    #
    def self.do_not_disturb?(user = nil)
      home = user ? homedir(user) : Dir.home
      myudid = udid
      nc_prefs_file = Pathname.new "#{home}/#{USER_PREFS_BYHOST_FOLDER}/com.apple.notificationcenterui.#{myudid}.plist"
      return nil unless nc_prefs_file.readable?
      JSS.parse_plist(nc_prefs_file)['doNotDisturb']
    end

    # The home dir of the specified user, nil if
    # no homedir in local dscl.
    #
    # @param user[String] the user whose homedir to look up
    #
    # @return [Pathname, nil] The user's homedir or nil if no such user
    #
    def self.homedir(user)
      dir = `/usr/bin/dscl . -read /Users/#{user} NFSHomeDirectory 2>/dev/null`.chomp.split(': ').last
      dir ? Pathname.new(dir) : nil
    end

  end # class Client

end # module
