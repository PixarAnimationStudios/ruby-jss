### Copyright 2014 Pixar
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

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Classes
  #####################################

  ###
  ### This class represents a Casper/JSS Client computer, on which
  ### this code is running.
  ###
  ### Since the class represents the current machine, there's no need
  ### to make an instance of it, all methods are class methods.
  ###
  ### At the moment, only Macintosh computers are supported.
  ###
  ###
  class Client

    #####################################
    ### Class Constants
    #####################################

    ### The Pathname to the jamf binary executable
    ### As of El Capitan (OS X 10.11) the location has moved.
    ORIG_JAMF_BINARY = Pathname.new "/usr/sbin/jamf"
    ELCAP_JAMF_BINARY = Pathname.new "/usr/local/jamf/bin/jamf"
    JAMF_BINARY = ELCAP_JAMF_BINARY.executable? ? ELCAP_JAMF_BINARY : ORIG_JAMF_BINARY

    ### The Pathname to the jamfHelper executable
    JAMF_HELPER = Pathname.new "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

    ### The window_type options for jamfHelper
    JAMF_HELPER_WINDOW_TYPES = {
      :hud => 'hud',
      :utility => 'utility',
      :util => 'utility',
      :full_screen => 'fs',
      :fs => 'fs'
    }

    ### The possible window positions for jamfHelper
    JAMF_HELPER_WINDOW_POSITIONS =  [nil, :ul, :ll, :ur, :lr]

    ### The available buttons in jamfHelper
    JAMF_HELPER_BUTTONS =  [1,2]

    ### The possible alignment positions in jamfHelper
    JAMF_HELPER_ALIGNMENTS =  [:right, :left, :center, :justified, :natural]

    ### The Pathname to the preferences plist used by the jamf binary
    JAMF_PLIST = Pathname.new "/Library/Preferences/com.jamfsoftware.jamf.plist"

    ### The Pathname to the JAMF support folder
    JAMF_SUPPORT_FOLDER = Pathname.new "/Library/Application Support/JAMF"

    ### The JAMF receipts folder, where package installs are tracked.
    RECEIPTS_FOLDER = JAMF_SUPPORT_FOLDER + "Receipts"

    ### The JAMF downloads folder
    DOWNLOADS_FOLDER = JAMF_SUPPORT_FOLDER + "Downloads"

    ### These jamf commands don't need root privs (most do)
    ROOTLESS_JAMF_COMMANDS = [
      :about,
      :checkJSSConnection,
      :getARDFields,
      :getComputerName,
      :help,
      :listUsers,
      :version ]

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################
    
    ###
    ### Get the current IP address as a String.
    ###
    ### This handy code doesn't acutally make a UDP connection,
    ### it just starts to set up the connection, then uses that to get
    ### the local IP.
    ###
    ### Lifted gratefully from
    ### http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
    ###
    ### @return [String] the current IP address.
    ###
    def self.my_ip_address
      ### turn off reverse DNS resolution temporarily
      ### @note the 'socket' library has already been required by 'rest-client'
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
  
      UDPSocket.open do |s|
        s.connect '192.168.0.0', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end



    ###
    ### @return [Boolean] is the jamf binary installed?
    ###
    def self.installed?
      JAMF_BINARY.executable?
    end

    ###
    ### @return [String,nil] the version of the jamf binary installed on this client, nil if not installed
    ###
    def self.jamf_version
      self.installed? ?  self.run_jamf(:version).chomp.split('=')[1] : nil
    end

    ###
    ### @return [String] the url to the JSS for this client
    ###
    def self.jss_url
      @url = self.jamf_plist['jss_url']
      return nil if @url.nil?
      @url =~ %r{(https?)://(.+):(\d+)/}
      @protocol = $1
      @server = $2
      @port = $3
      return @url
    end

    ###
    ### @return [String] the JSS server for this client
    ###
    def self.jss_server
      self.jss_url
      return @server
    end

    ###
    ### @return [String] the protocol to the JSS for this client, "http" or "https"
    ###
    def self.jss_protocol
      self.jss_url
      return @protocol
    end

    ###
    ### @return [Integer] the port to the JSS for this client
    ###
    def self.jss_port
      self.jss_url
      @port  ? @port.to_i : 80
    end

    ###
    ### @return [Hash] the parsed contents of the JAMF_PLIST if it exists, an empty hash if not
    ###
    def self.jamf_plist
      return {} unless JAMF_PLIST.file?
      Plist.parse_xml `/usr/libexec/PlistBuddy -x -c print #{Shellwords.escape JSS::Client::JAMF_PLIST.to_s}`
    end


    ###
    ### @return [Array<Pathname>] an array of Pathnames for all regular files in the jamf receipts folder
    ###
    def self.receipts
      raise JSS::NoSuchItemError, "The JAMF Receipts folder doesn't exist on this computer." unless RECEIPTS_FOLDER.exist?
      RECEIPTS_FOLDER.children.select{|c| c.file?}
    end

    ###
    ### @return [Boolean] is the JSS available now?
    ###
    def self.jss_available?
      output = run_jamf :checkJSSConnection, "-retry 1"
      $?.exitstatus == 0
    end


    ###
    ### @return [JSS::Computer] The JSS record for this computer
    ###
    def self.jss_record
      begin
        JSS::Computer.new :udid => self.udid
      rescue JSS::NoSuchItemError
        JSS::Computer.new :serial_number => self.serial_number
      end
    end

    ###
    ### @return [String] the UUID/UDID for this computer
    ###
    def self.udid
      self.hardware_data["platform_UUID"]
    end

    ###
    ### @return [String] the serial number for this computer
    ###
    def self.serial_number
      self.hardware_data["serial_number"]
    end

    ###
    ### @return [Hash] the HardwareDataType data from the system_profiler command
    ###
    def self.hardware_data
      raw = `/usr/sbin/system_profiler SPHardwareDataType -xml 2>/dev/null`
      Plist.parse_xml(raw)[0]["_items"][0]
    end


    ### Run an arbitrary jamf binary command.
    ###
    ### @note Most jamf commands require superuser/root privileges.
    ###
    ### @param command[String,Symbol] the jamf binary command to run
    ###   The command is the single jamf command that comes after the/usr/bin/jamf.
    ###
    ### @param args[String,Array] the arguments passed to the jamf command.
    ###   This is to be passed to Kernel.` (backtick), after being combined with the
    ###   jamf binary and the jamf command
    ###
    ### @param verbose[Boolean] Should the stdout & stderr of the jamf binary be sent to
    ###  the current stdout in realtime, as well as returned as a string?
    ###
    ### @return [String] the stdout & stderr of the jamf binary.
    ###
    ### @example
    ###   These two are equivalent:
    ###
    ###     JSS::Client.run_jamf "recon", "-assetTag 12345 -department 'IT Support'"
    ###
    ###     JSS::Client.run_jamf :recon, ['-assetTag', '12345', '-department', 'IT Support'"]
    ###
    ###
    ### The details of the Process::Status for the jamf binary process can be captured from $?
    ### immediately after calling. (See Process::Status)
    ###
    def self.run_jamf(command, args = nil, verbose  = false)
      raise JSS::UnmanagedError, "The jamf binary is not installed on this computer." unless self.installed?
      raise JSS::UnsupportedError, "You must have root privileges to run that jamf binary command" unless ROOTLESS_JAMF_COMMANDS.include? command.to_sym or JSS.superuser?

      cmd = case args
        when nil
          "#{JAMF_BINARY} #{command}"
        when String
          "#{JAMF_BINARY} #{command} #{args}"
        when Array
          "#{([JAMF_BINARY.to_s, command] + args).join(' ')}"
        else
          raise JSS::InvalidDataError, "args must be a String or Array of Strings"
      end # case
      
      cmd += " -verbose" if verbose
      puts "Running: #{cmd}" if verbose
      
      output = []
      IO.popen("#{cmd} 2>&1") do |proc|
        while line = proc.gets
          output << line
          puts line if verbose
        end
      end
      install_out = output.join('')
      install_out.force_encoding("UTF-8") if install_out.respond_to? :force_encoding
      return install_out
    end # run_jamf


    ### A wrapper for the jamfHelper command, which can display a window on the client machine.
    ###
    ### The first parameter must be a symbol defining what kind of window to display. The options are
    ### - :hud - creates an Apple "Heads Up Display" style window
    ### - :utility or :util -  creates an Apple "Utility" style window
    ### - :fs or :full_screen or :fullscreen - creates a full screen window that restricts all user input
    ###   WARNING: Remote access must be used to unlock machines in this mode
    ###
    ### The remaining options Hash can contain any of the options listed. See below for descriptions.
    ###
    ### The value returned is the Integer exitstatus/stdout (both are the same) of the jamfHelper command.
    ### The meanings of those integers are:
    ###
    ### - 0 - Button 1 was clicked
    ### - 1 - The Jamf Helper was unable to launch
    ### - 2 - Button 2 was clicked
    ### - 3 - Process was started as a launchd task
    ### - XX1 - Button 1 was clicked with a value of XX seconds selected in the drop-down
    ### - XX2 - Button 2 was clicked with a value of XX seconds selected in the drop-down
    ### - 239 - The exit button was clicked
    ### - 240 - The "ProductVersion" in sw_vers did not return 10.5.X, 10.6.X or 10.7.X
    ### - 243 - The window timed-out with no buttons on the screen
    ### - 250 - Bad "-windowType"
    ### - 254 - Cancel button was select with delay option present
    ### - 255 - No "-windowType"
    ###
    ### See also /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help
    ###
    ### @note the -startlaunchd and -kill options are not available in this implementation, since
    ###   they don't work at the moment (casper 9.4).
    ###   -startlaunchd seems to be required to NOT use launchd, and when it's ommited, an error is generated
    ###   about the launchd plist permissions being incorrect.
    ###
    ### @param window_type[Symbol]  The type of window to display
    ###
    ### @param opts[Hash] the options for the window
    ###
    ### @option opts :window_position [Symbol,nil] one of [ nil, :ul, :ll. :ur, :lr ]
    ###   Positions window in the upper right, upper left, lower right or lower left of the user's screen
	  ###   If no input is given, the window defaults to the center of the screen
    ###
    ### @option opts :title [String]
    ###   Sets the window's title to the specified string
    ###
    ### @option opts :heading  [String]
    ###   Sets the heading of the window to the specified string
    ###
    ### @option opts :align_heading [Symbol] one of  [:right, :left, :center, :justified, :natural]
	  ###   Aligns the heading to the specified alignment
    ###
    ### @option opts :description [String]
    ###   Sets the main contents of the window to the specified string
    ###
    ### @option opts :align_description [Symbol] one of  [:right, :left, :center, :justified, :natural]
	  ###   Aligns the description to the specified alignment
    ###
    ### @option opts :icon [String,Pathname]
    ###   Sets the windows image field to the image located at the specified path
    ###
    ### @option opts :icon_size [Integer]
    ###   Changes the image frame to the specified pixel size
    ###
    ### @option opts :full_screen_icon [any value]
    ###   Scales the "icon" to the full size of the window.
	  ###   Note: Only available in full screen mode
    ###
    ### @option opts :button1 [String]
    ###   Creates a button with the specified label
    ###
    ### @option opts :button2 [String]
    ###   Creates a second button with the specified label
    ###
    ### @option opts :default_button [Integer]  either 1 or 2
	  ###   Sets the default button of the window to the specified button. The Default Button will respond to "return"
    ###
    ### @option opts :cancel_button [Integer]  either 1 or 2
	  ###   Sets the cancel button of the window to the specified button. The Cancel Button will respond to "escape"
    ###
    ### @option opts :timeout [Integer]
    ###   Causes the window to timeout after the specified amount of seconds
	  ###   Note: The timeout will cause the default button, button 1 or button 2 to be selected (in that order)
    ###
    ### @option opts :show_delay_options [String,Array<Integer>] A String of comma-separated Integers, or an Array of Integers.
	  ###   Enables the "Delay Options Mode". The window will display a dropdown with the values passed through the string
    ###
    ### @option opts :countdown [any value]
    ###   Displays a string notifying the user when the window will time out
    ###
    ### @option opts :align_countdown [Symbol] one of  [:right, :left, :center, :justified, :natural]
    ###   Aligns the countdown to the specified alignment
    ###
    ### @option opts :lock_hud [any value]
    ###   Removes the ability to exit the HUD by selecting the close button
    ###
    ### @return [Integer] the exit status of the jamfHelper command. See above.
    ###
    def self.jamf_helper(window_type = :hud, opts = {})

      raise JSS::UnmanagedError, "The jamfHelper app is not installed properly on this computer." unless JAMF_HELPER.executable?

      unless JAMF_HELPER_WINDOW_TYPES.include? window_type
        raise JSS::InvalidDataError, "The first parameter must be a window type, one of :#{JAMF_HELPER_WINDOW_TYPES.keys.join(', :')}."
      end

      # start building the arg array

      args = ["-startlaunchd", "-windowType", JAMF_HELPER_WINDOW_TYPES[window_type]]

      opts.keys.each do |opt|
        case opt
          when :window_position
            raise JSS::InvalidDataError, ":window_position must be one of :#{JAMF_HELPER_WINDOW_POSITIONS.join(', :')}." unless JAMF_HELPER_WINDOW_POSITIONS.include? opts[opt].to_sym
            args << "-windowPosition"
            args << opts[opt].to_s

          when :title
            args << "-title"
            args << opts[opt].to_s

          when :heading
            args << "-heading"
            args << opts[opt].to_s

          when :align_heading
            raise JSS::InvalidDataError, ":align_heading must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym
            args << "-alignHeading"
            args << opts[opt].to_s

          when :description
            args << "-description"
            args << opts[opt].to_s

          when :align_description
            raise JSS::InvalidDataError, ":align_description must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym
            args << "-alignDescription"
            args << opts[opt].to_s

          when :icon
            args << "-icon"
            args << opts[opt].to_s

          when :icon_size
            args << "-iconSize"
            args << opts[opt].to_s

          when :full_screen_icon
            args << "-fullScreenIcon"

          when :button1
            args << "-button1"
            args << opts[opt].to_s

          when :button2
            args << "-button2"
            args << opts[opt].to_s

          when :default_button
            raise JSS::InvalidDataError, ":default_button must be one of #{JAMF_HELPER_BUTTONS.join(', ')}." unless JAMF_HELPER_BUTTONS.include? opts[opt]
            args << "-defaultButton"
            args << opts[opt].to_s

          when :cancel_button
            raise JSS::InvalidDataError, ":cancel_button must be one of #{JAMF_HELPER_BUTTONS.join(', ')}." unless JAMF_HELPER_BUTTONS.include? opts[opt]
            args << "-cancelButton"
            args << opts[opt].to_s

          when :timeout
            args << "-timeout"
            args << opts[opt].to_s

          when :show_delay_options
            args << "-showDelayOptions"
            args << JSS.to_s_and_a(opts[opt])[:arrayform].join(', ')

          when :countdown
            args << "-countdown"

          when :align_countdown
            raise JSS::InvalidDataError, ":align_countdown must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym
            args << "-alignCountdown"
            args << opts[opt].to_s

          when :lock_hud
            args << " -lockHUD "
        end # case opt
      end # each do opt

      system JAMF_HELPER.to_s, *args
      return $?.exitstatus

    end # def self.jamf_helper


  end # class Client

end # module
