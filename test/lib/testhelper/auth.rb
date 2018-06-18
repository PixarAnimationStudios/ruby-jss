module JSSTestHelper

  # auth
  module Auth

    KEYCHAIN_LABEL_BASE = 'com.pixar.ruby-jss.testing'.freeze

    KEYCHAIN_JSS_LABEL = KEYCHAIN_LABEL_BASE + '.api'
    KEYCHAIN_DB_LABEL = KEYCHAIN_LABEL_BASE + '.db'
    KEYCHAIN_DIST_LABEL = KEYCHAIN_LABEL_BASE + '.distribution'

    KEYCHAIN_DIST_ACCT = 'From JSS'.freeze

    KEYCHAIN_LABELS = {
      jss: KEYCHAIN_JSS_LABEL,
      db: KEYCHAIN_DB_LABEL,
      dist: KEYCHAIN_DIST_LABEL
    }.freeze

    module_function

    # return the user's API password, prompting for it if we don't already have
    # it
    #
    def api_pw(server: nil, port: nil, user: nil)
      return @api_pw if @api_pw
      # If we're here, we need to get the pw via prompt
      @api_pw = prompt_for_password prompt: "Enter the API password for #{user}@#{server}:#{port}" do |apw|
        begin
          JSS.api.disconnect
          JSS.api.connect user: user, pw: apw, server: server, port: port
          true
        rescue JSS::AuthenticationError
          false
        end # begin
      end # do apw
      raise JSS::AuthenticationError, "Incorrect API password for #{user}@#{server}:#{port}" unless @api_pw
      @api_pw
    end

    # return the server, port, and user, which we might have gotten fromthe keychain
    def connect_to_api(server: nil, user: nil, port: nil, pw: nil)
      return if JSS.api.connected?

      JSS.api.connect server: server, port: port, user: user, pw: pw
      @api_pw = pw
      { server: JSS.api.hostname, port: JSS.api.port, user: JSS.api.jss_user }
    rescue JSS::AuthenticationError
      # If we're here, we need to prompt for the pw
      pw = api_pw server: server, port: port, user: user
    ensure
      # store the pw
      save_rw_credentials label: KEYCHAIN_JSS_LABEL, acct: JSS.api.jss_user, server: JSS.api.hostname, port: JSS.api.port, pw: pw if JSS.api.connected?
    end

    # TODO: update this as API above so there's only one per keychain.
    def db_pw
      return @db_pw if @db_pw

      # If we're here, we need to get the passwd for the user
      @db_pw = prompt_for_password prompt: "Enter the MySQL password for #{@db_user}@#{@db_server}" do |apw|
        begin
          JSS::DB_CNX.disconnect
          JSS::DB_CNX.connect server: @db_server, user: @db_user, pw: apw
          true
        rescue Mysql::ServerError::AccessDeniedError
          false
        end # begin
      end # do apw

      raise JSS::AuthenticationError, "Incorrect MySQL password for #{@db_user}@#{@db_server}" unless @db_pw
      @db_pw
    end

    # TODO: update this as API above so there's only one per keychain.
    def connect_to_db(server: nil, user: nil)
      return if JSS::DB_CNX.connected?
      @db_server = server ? server : JSS::CONFIG.api_server_name
      @db_user = user

      raise 'No db_server_name defined in /etc/ruby-jss.conf. Please specify with --db-server' unless @db_server

      # look in the keychain
      keychain_creds = rw_credentials_from_keychain(:db, @db_server, @db_user)

      # did we get a user/pw? Use it
      if keychain_creds
        @db_user ||= keychain_creds[:user]
        begin
          JSS::DB_CNX.connect server: @db_server, user: @db_user, pw: keychain_creds[:password]

          return
        rescue Mysql::ServerError::AccessDeniedError
          # re-prompt if bad pw in keychain
          say "Stored MySQL password for #{@db_user}@#{@db_server} is incorrect"
        end # begin
      else
        # Couldn't find a stored user for server, and no user given on CLI - error.
        raise "No user stored for MySQL server '#{@db_server}'. Please specify with --db-user" unless @db_user
      end

      # If we're here, we need to get the passwd for the user
      pw = db_pw

      # store the pw
      save_rw_credentials KEYCHAIN_DB_LABEL, @db_user, @db_server, pw
    end

    # TODO: pass in the API server for which we want the dist point pw
    # must be connected to api
    # and make it like API connection above, 1 per keychain.
    def dist_point_pw
      keychain_creds = rw_credentials_from_keychain(:db, @api_server, KEYCHAIN_DIST_ACCT)
      if keychain_creds
        @distpw = keychain_creds[:password]
        return @distpw if JSS::DistributionPoint.master_distribution_point.check_pw :rw, distpw
      end

      # if we're here, there was no stored pw or it was incorrect

      # If we're here, we need to get the passwd for the master dist point
      prmpt = "Enter the RW password for the Master Distribution Point on JSS #{@api_server}"
      @distpw = prompt_for_password prompt: prmpt do |apw|
        JSS::DistributionPoint.master_distribution_point.check_pw :rw, apw
      end # do apw

      raise JSS::AuthenticationError, "Incorrect RW password for the Master Distribution Point on JSS #{@api_server}" unless @distpw

      # store the pw
      save_rw_credentials KEYCHAIN_DIST_LABEL, KEYCHAIN_DIST_ACCT, @api_server, @distpw
      @distpw
    end

    # Fetch read-write credentials from the login keychain
    #
    # If the login keychain is locked, the user will be prompted
    # to unlock it in the GUI.
    #
    # @param kind[Symbol] which kind of credentials? :jss, :db, or :dist
    #
    # @return [Hash{Symbol => String}, nil] A Hash with :server, :user and :password
    #   values, nil if no matching keychain item.
    #
    def rw_credentials_from_keychain(kind)
      Keychain.user_interaction_allowed = true
      unlock_keychain
      label = KEYCHAIN_LABELS[kind]
      raise JSS::InvalidDataError, "argument must be one of :#{RW_CREDENTIAL_KINDS.join ', :'}" unless label

      pw_search = { label: label }
      pw_item = Keychain.default.internet_passwords.where(pw_search).first

      return nil unless pw_item

      { server: pw_item.server, user: pw_item.account, pw: pw_item.password, port: pw_item.port }
    end

    # Save the credentials in the login keychain
    #
    # @param user[String] the username to save
    #
    # @param pw[String] the password to save with the username
    #
    # @return [void]
    #
    def save_rw_credentials(label: nil, acct: nil, server: nil, pw: nil, port: nil)
      Keychain.default.internet_passwords.where(label: label).all.each(&:delete)
      item = Keychain.default.internet_passwords.create label: label, account: acct, server: server, password: pw, port: port
      item.save!
    end

    # Prompt the user to unlock the default keychain
    #
    # @return [void]
    #
    def unlock_keychain
      return true unless Keychain.default.locked?
      unlocked = prompt_for_password prompt: 'Enter your keychain password' do |pw|
        begin
          Keychain.default.unlock! pw
          true
        rescue Keychain::AuthFailedError
          false
        end # begin
      end # prompt for pass
      raise JSS::AuthenticationError, 'Failed to unlock default keychain' unless unlocked
    end # unlock keychain

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
    #
    def prompt_for_password(**options)
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

  end # module auth

end # module JSSTestHelper
