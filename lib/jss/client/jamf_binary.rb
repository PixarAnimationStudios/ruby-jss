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
  module Client

    # Constants
    #####################################

    # The Pathname to the jamf binary executable
    # Before SIP (macOS 10.10 and below)
    ORIG_JAMF_BINARY = Pathname.new '/usr/sbin/jamf'

    # The Pathname to the jamf binary executable
    # After SIP (OS X 10.11 and above)
    SIP_JAMF_BINARY = USR_LOCAL_BIN_FOLDER + 'jamf'

    # The path to the jamf binary
    JAMF_BINARY = SIP_JAMF_BINARY.executable? ? SIP_JAMF_BINARY : ORIG_JAMF_BINARY

    # These jamf commands don't need root privs (most do)
    ROOTLESS_JAMF_COMMANDS = %i[
      about
      checkJSSConnection
      getARDFields
      getComputerName
      help
      listUsers
      version
    ].freeze

    # the option that makes the jamf binary verbose
    JAMF_VERBOSE_OPT = ' -verbose'.freeze

    # Module Methods
    #####################################

    # the preferred way to make all the following methods into
    # module methods:

    module_function

    # Run an arbitrary jamf binary command.
    #
    # @note Most jamf commands require superuser/root privileges.
    #
    # @param command[String,Symbol] the jamf binary command to run
    #   The command is the single jamf command that comes after the/usr/bin/jamf.
    #
    # @param args[String,Array] the arguments passed to the jamf command.
    #   This is to be passed to Kernel.` (backtick), after being combined with the
    #   jamf binary and the jamf command
    #
    # @param verbose[Boolean] Should the stdout & stderr of the jamf binary be sent to
    #  the current stdout in realtime, as well as returned as a string?
    #
    # @return [String] the stdout & stderr of the jamf binary.
    #
    # @example
    #   These two are equivalent:
    #
    #     JSS::Client.run_jamf "recon", "-assetTag 12345 -department 'IT Support'"
    #
    #     JSS::Client.run_jamf :recon, ['-assetTag', '12345', '-department', 'IT Support'"]
    #
    #
    # The details of the Process::Status for the jamf binary process can be
    # captured from $CHILD_STATUS immediately after calling. (See Process::Status)
    #
    def run_jamf(command, args = nil, verbose = false)
      raise JSS::UnmanagedError, 'The jamf binary is not installed on this computer.' unless installed?
      unless ROOTLESS_JAMF_COMMANDS.include?(command.to_sym) || JSS.superuser?
        raise JSS::UnsupportedError, 'You must have root privileges to run that jamf binary command'
      end
      cmd = build_jamf_command command, args
      cmd += " #{JAMF_VERBOSE_OPT}" if verbose && !cmd.include?(JAMF_VERBOSE_OPT)
      execute_jamf cmd, verbose
    end # run_jamf

    private_class_method

    def build_jamf_command(command, args)
      case args
      when nil
        "#{JAMF_BINARY} #{command}"
      when String
        "#{JAMF_BINARY} #{command} #{args}"
      when Array
        ([JAMF_BINARY.to_s, command] + args).join(' ')
      else
        raise JSS::InvalidDataError, 'args must be a String or Array of Strings'
      end # case
    end

    def execute_jamf(cmd, verbose)
      puts "Running: #{cmd}" if verbose
      output = ''
      IO.popen("#{cmd} 2>&1") do |proc|
        loop do
          line = proc.gets
          break unless line
          output << line
          puts line if verbose
        end
      end
      output.force_encoding('UTF-8')
      output
    end

  end # class Client

end # module
