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

###
module Jamf

  class Client

    # Module for working with jamfHelper.app on a managed client Mac
    # This should be included into Jamf::Client
    #####################################
    module JamfHelper

      # The Pathname to the jamfHelper executable
      JAMF_HELPER = SUPPORT_BIN_FOLDER + 'jamfHelper.app/Contents/MacOS/jamfHelper'

      # The window_type options for jamfHelper
      JAMF_HELPER_WINDOW_TYPES = {
        hud: 'hud',
        utility: 'utility',
        util: 'utility',
        full_screen: 'fs',
        fs: 'fs'
      }.freeze

      # The possible window positions for jamfHelper
      JAMF_HELPER_WINDOW_POSITIONS = [nil, :ul, :ll, :ur, :lr].freeze

      # The available buttons in jamfHelper
      JAMF_HELPER_BUTTONS =  [1, 2].freeze

      # The possible alignment positions in jamfHelper
      JAMF_HELPER_ALIGNMENTS = %i[right left center justified natural].freeze

      # when this module is included, also extend our Class Methods
      def self.included(includer)
        Jamf.load_msg "--> #{includer} is including Jamf::Client::JamfHelper"
        includer.extend(ClassMethods)
      end

      # class Methods
      #####################################

      module ClassMethods

        # A wrapper for the jamfHelper command, which can display a window on the client machine.
        #
        # The first parameter must be a symbol defining what kind of window to display. The options are
        # - :hud - creates an Apple "Heads Up Display" style window
        # - :utility or :util -  creates an Apple "Utility" style window
        # - :fs or :full_screen or :fullscreen - creates a full screen window that restricts all user input
        #   WARNING: Remote access must be used to unlock machines in this mode
        #
        # The remaining options Hash can contain any of the options listed. See below for descriptions.
        #
        # The value returned is the Integer exitstatus/stdout (both are the same) of the jamfHelper command.
        # The meanings of those integers are:
        #
        # - 0 - Button 1 was clicked
        # - 1 - The Jamf Helper was unable to launch
        # - 2 - Button 2 was clicked
        # - 3 - Process was started as a launchd task
        # - XX1 - Button 1 was clicked with a value of XX seconds selected in the drop-down
        # - XX2 - Button 2 was clicked with a value of XX seconds selected in the drop-down
        # - 239 - The exit button was clicked
        # - 240 - The "ProductVersion" in sw_vers did not return 10.5.X, 10.6.X or 10.7.X
        # - 243 - The window timed-out with no buttons on the screen
        # - 250 - Bad "-windowType"
        # - 254 - Cancel button was select with delay option present
        # - 255 - No "-windowType"
        #
        # If the :abandon_process option is given, the integer returned is the Process ID
        # of the abondoned process running jamfHelper.
        #
        # See also /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help
        #
        # @note the -startlaunchd and -kill options are not available in this implementation, since
        #   they don't work at the moment (casper 9.4).
        #   -startlaunchd seems to be required to NOT use launchd, and when it's ommited, an error is generated
        #   about the launchd plist permissions being incorrect.
        #
        # @param window_type[Symbol]  The type of window to display
        #
        # @param opts[Hash] the options for the window
        #
        # @option opts :window_position [Symbol,nil] one of [ nil, :ul, :ll. :ur, :lr ]
        #   Positions window in the upper right, upper left, lower right or lower left of the user's screen
        #   If no input is given, the window defaults to the center of the screen
        #
        # @option opts :title [String]
        #   Sets the window's title to the specified string
        #
        # @option opts :heading  [String]
        #   Sets the heading of the window to the specified string
        #
        # @option opts :align_heading [Symbol] one of  [:right, :left, :center, :justified, :natural]
        #   Aligns the heading to the specified alignment
        #
        # @option opts :description [String]
        #   Sets the main contents of the window to the specified string
        #
        # @option opts :align_description [Symbol] one of  [:right, :left, :center, :justified, :natural]
        #   Aligns the description to the specified alignment
        #
        # @option opts :icon [String,Pathname]
        #   Sets the windows image field to the image located at the specified path
        #
        # @option opts :icon_size [Integer]
        #   Changes the image frame to the specified pixel size
        #
        # @option opts :full_screen_icon [any value]
        #   Scales the "icon" to the full size of the window.
        #   Note: Only available in full screen mode
        #
        # @option opts :button1 [String]
        #   Creates a button with the specified label
        #
        # @option opts :button2 [String]
        #   Creates a second button with the specified label
        #
        # @option opts :default_button [Integer]  either 1 or 2
        #   Sets the default button of the window to the specified button. The Default Button will respond to "return"
        #
        # @option opts :cancel_button [Integer]  either 1 or 2
        #   Sets the cancel button of the window to the specified button. The Cancel Button will respond to "escape"
        #
        # @option opts :timeout [Integer]
        #   Causes the window to timeout after the specified amount of seconds
        #   Note: The timeout will cause the default button, button 1 or button 2 to be selected (in that order)
        #
        # @option opts :show_delay_options [String,Array<Integer>] A String of comma-separated Integers, or an Array of Integers.
        #   Enables the "Delay Options Mode". The window will display a dropdown with the values passed through the string
        #
        # @option opts :countdown [any value]
        #   Displays a string notifying the user when the window will time out
        #
        # @option opts :align_countdown [Symbol] one of  [:right, :left, :center, :justified, :natural]
        #   Aligns the countdown to the specified alignment
        #
        # @option opts :lock_hud [Boolean]
        #   Removes the ability to exit the HUD by selecting the close button
        #
        # @option opts :abandon_process [Boolean] Abandon the jamfHelper process so that your code can exit.
        #   This is mostly used so that a policy can finish while a dialog is waiting
        #   (possibly forever) for user response. When true, the returned value is the
        #   process id of the abandoned jamfHelper process.
        #
        # @option opts :output_file [String, Pathname] Save the output of jamfHelper
        #   (the exit code) into this file. This is useful when using abandon_process.
        #   The output file can be examined later to see what happened. If this option
        #   is not provided, no output is saved.
        #
        # @option opts :arg_string [String] The jamfHelper commandline args as a single
        #   String, the way you'd specify them in a shell. This is appended to any
        #   Ruby options provided when calling the method. So calling:
        #      Jamf::Client.jamf_helper :hud, title: 'This is a title', arg_string: '-heading "this is a heading"'
        #   will run
        #      jamfHelper -windowType hud -title 'this is a title' -heading "this is a heading"
        #   When using this, be careful not to specify the windowType, since it's generated
        #   by the first, required, parameter of this method.
        #
        # @return [Integer] the exit status of the jamfHelper command. See above.
        #
        def jamf_helper(window_type = :hud, **opts)
          raise Jamf::UnmanagedError, 'The jamfHelper app is not installed properly on this computer.' unless JAMF_HELPER.executable?

          unless JAMF_HELPER_WINDOW_TYPES.include? window_type
            raise Jamf::InvalidDataError, "The first parameter must be a window type, one of :#{JAMF_HELPER_WINDOW_TYPES.keys.join(', :')}."
          end

          # start building the arg array

          args = ['-startlaunchd', '-windowType', JAMF_HELPER_WINDOW_TYPES[window_type]]

          opts.keys.each do |opt|
            case opt
            when :window_position
              raise Jamf::InvalidDataError, ":window_position must be one of :#{JAMF_HELPER_WINDOW_POSITIONS.join(', :')}." unless \
                JAMF_HELPER_WINDOW_POSITIONS.include? opts[opt].to_sym

              args << '-windowPosition'
              args << opts[opt].to_s

            when :title
              args << '-title'
              args << opts[opt].to_s

            when :heading
              args << '-heading'
              args << opts[opt].to_s

            when :align_heading
              raise Jamf::InvalidDataError, ":align_heading must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless \
                JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym

              args << '-alignHeading'
              args << opts[opt].to_s

            when :description
              args << '-description'
              args << opts[opt].to_s

            when :align_description
              raise Jamf::InvalidDataError, ":align_description must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless \
                JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym

              args << '-alignDescription'
              args << opts[opt].to_s

            when :icon
              args << '-icon'
              args << opts[opt].to_s

            when :icon_size
              args << '-iconSize'
              args << opts[opt].to_s

            when :full_screen_icon
              args << '-fullScreenIcon'

            when :button1
              args << '-button1'
              args << opts[opt].to_s

            when :button2
              args << '-button2'
              args << opts[opt].to_s

            when :default_button
              raise Jamf::InvalidDataError, ":default_button must be one of #{JAMF_HELPER_BUTTONS.join(', ')}." unless \
                JAMF_HELPER_BUTTONS.include? opts[opt]

              args << '-defaultButton'
              args << opts[opt].to_s

            when :cancel_button
              raise Jamf::InvalidDataError, ":cancel_button must be one of #{JAMF_HELPER_BUTTONS.join(', ')}." unless \
                JAMF_HELPER_BUTTONS.include? opts[opt]

              args << '-cancelButton'
              args << opts[opt].to_s

            when :timeout
              args << '-timeout'
              args << opts[opt].to_s

            when :show_delay_options
              args << '-showDelayOptions'
              args << JSS.to_s_and_a(opts[opt])[:arrayform].join(', ')

            when :countdown
              args << '-countdown' if opts[opt]

            when :align_countdown
              raise Jamf::InvalidDataError, ":align_countdown must be one of :#{JAMF_HELPER_ALIGNMENTS.join(', :')}." unless \
                JAMF_HELPER_ALIGNMENTS.include? opts[opt].to_sym

              args << '-alignCountdown'
              args << opts[opt].to_s

            when :lock_hud
              args << '-lockHUD' if opts[opt]

            end # case opt
          end # each do opt

          cmd = Shellwords.escape JAMF_HELPER.to_s
          args.each { |arg| cmd << " #{Shellwords.escape arg}" }
          cmd << " #{opts[:arg_string]}" if opts[:arg_string]
          cmd << " > #{Shellwords.escape opts[:output_file]}" if opts[:output_file]

          if opts[:abandon_process]
            pid = Process.fork
            if pid.nil?
              # In child
              exec cmd
            else
              # In parent
              Process.detach(pid)
              pid
            end
          else
            system cmd
            $CHILD_STATUS.exitstatus
          end
        end # def self.jamf_helper

      end # ClassMethods

    end # module

  end # class Client

end # module
