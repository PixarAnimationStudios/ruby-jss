### Copyright 2025 Pixar

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

module JamfTest

  # auth
  module Auth

    require 'open3'
    require 'pathname'

    # The security command
    SEC_COMMAND = '/usr/bin/security'

    # exit status when the keychain password provided is incorrect
    SEC_STATUS_AUTH_ERROR = 51

    # exit status when the desired item isn't found in the keychain
    SEC_STATUS_NOT_FOUND_ERROR = 44

    KEYCHAIN_LABEL_BASE = 'ruby-jss testing suite: '.freeze
    KEYCHAIN_API_LABEL = KEYCHAIN_LABEL_BASE + 'API Access'

    KEYCHAIN_SVC_BASE = 'com.pixar.ruby-jss.testing'.freeze
    KEYCHAIN_API_SVC = KEYCHAIN_SVC_BASE + '.api'

    ###########################
    def self.connect_to_api(host:, port: nil)
      creds = api_creds host: host
      creds ||= prompt_for_api_pw(host: host, port: port)

      Jamf.connect host: host, port: creds[:port], user: creds[:user], pw: creds[:pw]
    end

    # return the user's API password, prompting for it if we don't already have
    # it
    ###########################
    def self.prompt_for_api_pw(host:, port: nil)
      # If we're here, we need to get theuser and  pw via prompt
      print "Enter the API username for #{host}: "
      user = $stdin.gets.chomp

      pw = prompt_for_password prompt: "Enter the API password for #{user}@#{host}" do |apw|
        Jamf.cnx.disconnect
        Jamf.cnx.connect user: user, pw: apw, host: host, port: port
        true
      rescue JSS::AuthenticationError
        false
        # begin
      end # do apw
      raise JSS::AuthenticationError, "Incorrect API password for #{user}@#{host}" unless pw

      save_api_creds(host: host, user: user, pw: pw, port: port)

      { user: user, pw: pw, port: port }
    end

    # Prompt the user for a password in the shell
    # Returns:
    #   - a valid password, or
    #   - false if no valid password after the max number of tries
    #
    # Displays the provided promp. Passes what the user types to the block you
    # provide, which must return a Boolean indicating if the password was correct.
    #
    # @param prompt[String] The message asking for the password
    #
    # @option max_tries[Integer] The max number of times to let the
    #   user enter the passwd. Defaults to 3
    #
    # @option retry_msg[String] the text to display after a failure,
    #   but before :max_tries failures. Defaults to "Try again: " followed
    #   by the text arg.
    #
    # @option failed_msg[String] The message to display after :max_tries
    #   failures. Defaults to  "Too many failed attempts"
    #
    # @yield The block should figure out if the user typed the correct password
    #
    # @yieldparam pw [String] The password typed by the user in the input field
    #
    # @yieldreturn [Boolean] Was the password correct?
    #
    # @return [String] The validated password
    # @return [false] The user failed after max_tries: attempts.
    #
    ############################
    def self.prompt_for_password(**options)
      colon = ':'
      # set defaults
      options[:prompt] ||= 'Enter your password:'
      options[:prompt] << colon unless options[:prompt].end_with? colon
      options[:max_tries] ||= 3
      options[:retry_msg] ||= "Try Again. #{options[:prompt]}"
      options[:failed_msg] ||= 'Too many failed attempts'

      tries = 0

      prompt = options[:prompt]

      while tries < options[:max_tries]
        print "#{prompt} "
        system 'stty -echo'
        pw = $stdin.gets.chomp
        puts
        system 'stty echo'
        return pw if yield pw

        prompt = options[:retry_msg]
        tries += 1
      end
      puts options[:failed_msg]
      false
    ensure # make sure terminal is usable at the end of this
      system 'stty echo'
    end # prompt_for_password

    # Save the API testing credentials to the default keychain
    ###########################
    def self.save_api_creds(host:, user:, pw:, port: nil)
      delete_api_creds(host: host)

      cmd = +'add-internet-password'
      cmd << " -a #{escape_for_security user}"
      cmd << " -s #{escape_for_security host}"
      cmd << " -l #{escape_for_security KEYCHAIN_API_LABEL}"
      cmd << " -P #{port}" if port
      cmd << " -w #{escape_for_security pw}"

      run_security cmd
      :saved
    end

    ###########################
    def self.delete_api_creds(host:)
      # NOTE: -s must come before -l
      cmd = +'delete-internet-password'
      cmd << " -s #{escape_for_security host}"
      cmd << " -l #{escape_for_security KEYCHAIN_API_LABEL}"

      run_security cmd
      :deleted
    rescue
      nil
    end

    # retrieve the API testing credentials from the default keychain
    #
    # @return [Hash] The user, pw and possibly port for accessing the API
    #   on the host
    ###########################
    def self.api_creds(host:)
      # NOTE: -s must come before -l
      cmd = +'find-internet-password'
      cmd << " -s #{escape_for_security host}"
      cmd << " -l #{escape_for_security KEYCHAIN_API_LABEL}"
      output = run_security(cmd)

      output =~ /"acct"<blob>="(.+)"$/
      user = Regexp.last_match[1]

      output =~ /"port"<uint32>=0x([A-F0-9]+)( |$)/
      port = Regexp.last_match[1]
      port &&= port.to_i(16)

      cmd << ' -w'
      pw = run_security(cmd).chomp

      { user: user, pw: pw, port: port }
    rescue
      nil
    end

    # Run the security command in interactive mode on a given keyshcain,
    # passing in a subcommand and its arguments. so that they don't appear in the
    # `ps` output
    #
    # @param cmd [String] the subcommand being passed to 'security' with
    #   all needed options. It will not be visible outide this process, so
    #   its OK to put passwords into the options.
    #
    # @return [String] the stdout of the 'security' command.
    #
    #################################
    def self.run_security(cmd)
      output = ''
      errs = ''
      exit_status = nil

      Open3.popen3("#{SEC_COMMAND} -i") do |stdin, stdout, stderr, wait_thr|
        # pid = wait_thr.pid # pid of the started process.
        stdin.puts cmd
        stdin.close
        output = stdout.read
        errs = stderr.read
        exit_status = wait_thr.value # Process::Status object returned.
      end
      return output.chomp if exit_status.success?

      case exit_status.exitstatus
      when SEC_STATUS_AUTH_ERROR
        raise 'Incorrect keychain password'
      when SEC_STATUS_NOT_FOUND_ERROR
        raise 'No matching item was found in the keychain'
      else
        errs.chomp!
        errs =~ /: returned\s+(-?\d+)$/
        errnum = Regexp.last_match(1)
        desc = nil
        if errnum
          desc = `#{SEC_COMMAND} error #{errnum}`
          desc =
            if desc.include?('unknown error')
              nil
            else
              desc.chomp.split(errnum).last
            end
        end
        desc ||= errs
        raise "Keychain Error: #{desc.gsub("\n", '; ')}; exit status #{exit_status.exitstatus}"
      end # case
    end # run_security

    # given a string, wrap it in single quotes and escape internal single quotes
    # and backslashes so it can be used in the interactive 'security' command
    #
    # @param str[String] the string to escape
    #
    # @return [String] the escaped string
    ############################
    def self.escape_for_security(str)
      # first escape backslashes
      str = str.to_s.gsub '\\', '\\\\\\'

      # then single quotes
      str.gsub! "'", "\\\\'"

      # if other things need escaping, add them here

      "'#{str}'"
    end # escape

  end # module auth

end # module JamfTest
