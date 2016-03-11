### Copyright 2016 Pixar
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
  ### Classes
  #####################################

  ###
  ### A mysql connection to the JSS database.
  ###
  ### This is a singleton class, only one can exist at a time, and it
  ### is created, but not connected, automatically when the module loads.
  ###
  ### Use it via the JSS::DB_CNX constant (for connection metadata)
  ### and the JSS::DB_CNX.db attribute (which contains the actual mysql
  ### query interface) for making queries
  ###
  ### Direct MySQL access is minimal and discouraged, since it
  ### bypasses the API, and can be very dangerous. However, it's necessary
  ### to overcome some limitations of the API or to access custom tables.
  ###
  ### While a database connction isn't required for most things,
  ### warnings will be sent to stderr when functionality is limited due to
  ### a lack of a database connection i.e. when JSS::DB_CNX.connected? == false
  ###
  ### To make a connection with credentials, just call the #connect method thus:
  ###    JSS::DB_CNX.connect :server => 'server.company.com', :user => "user", :pw => "pw"
  ###
  ### Other options include:
  ###   :db_name => which database to connect to, defaults to 'jamfsoftware'
  ###   :port => tcp port for connection to server, defaults to the standard mysql port.
  ###   :connect_timeout => seconds to wait before giving up on connection, defaults to 120
  ###   :read_timeout => seconds to wait before giving up on recieving data, defaults to 120
  ###   :write_timeout => seconds to wait before giving up on sending data, defaults to 120
  ###   :timeout => sets all three timeouts to the same value, defaults to 120
  ###
  ### Calling JSS::DB_CNX.connect again will re-use any values not provided.
  ### but will create a new connection.
  ###
  class DBConnection

    include Singleton

    #####################################
    ### Class Constants
    #####################################

    ### The name of the JSS database on the mysql server
    DEFAULT_DB_NAME = "jamfsoftware"

    ### give the connection a 60 second timeout, for really slow
    ### net connections (like... from airplanes)
    DFT_TIMEOUT = 60

    ###
    DFT_SOCKET = '/var/mysql/mysql.sock'

    ### the default MySQL port
    DFT_PORT = 3306

    ### The default encoding in the tables - JAMF wisely uses UTF-8
    DFT_CHARSET = "utf8"

    ### the strftime format for reading/writing dates in the db
    SQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"



    attr_reader :server
    attr_reader :port
    attr_reader :socket
    attr_reader :user
    attr_reader :db_name
    attr_reader :connect_timeout
    attr_reader :read_timeout
    attr_reader :write_timeout
    attr_reader :connected


    def initialize ()
      require 'mysql'
      @mysql = Mysql.init
      @connected = false
    end #init

    ###
    ### Connect to the JSS MySQL database.
    ###
    ### @param args[Hash] the keyed arguments for connection.
    ###
    ### @option args :server[String] Required, the hostname of the JSS API server
    ###
    ### @option args :port[Integer] the port number to connect with, defaults to the default Mysql TCP port
    ###
    ### @option args :socket[String,Pathname] when the server is 'localhost', the path to the connection socket.
    ###
    ### @option args :db_name[String] the name of the database to use, defaults to 'jamfsoftware'
    ###
    ### @option args :user[String] Required, the mysql user to connect as
    ###
    ### @option args :pw[String,Symbol] Required, the password for that user, or :prompt, or :stdin
    ###   If :prompt, the user is promted on the commandline to enter the password for the :user.
    ###   If :stdin#, the password is read from a line of std in represented by the digit at #,
    ###   so :stdin3 reads the passwd from the third line of standard input. defaults to line 2,
    ###   if no digit is supplied. see {JSS.stdin}
    ###
    ### @option args :connect_timeout[Integer] the number of seconds to wait for an initial response, defaults to 120
    ###
    ### @option args :read_timeout[Integer] the number of seconds before read-request times out, defaults to 120
    ###
    ### @option args :write_timeout[Integer] the number of seconds before write-request times out, defaults to 120
    ###
    ### @option args :timeout[Integer] used for any of the timeouts that aren't explicitly set.
    ###
    ### @return [true] the connection was successfully made.
    ###
    def connect(args = {})

      # server might come frome several places
      # if not given in the args, use #hostname to figure out
      # which
      @server = args[:server] ?  args[:server] : hostname

      # settings from config if they aren't in the args
      args[:port] ||= JSS::CONFIG.db_server_port
      args[:socket] ||= JSS::CONFIG.db_server_socket
      args[:db_name] ||= JSS::CONFIG.db_name
      args[:user] ||= JSS::CONFIG.db_username
      args[:connect_timeout] ||= JSS::CONFIG.db_connect_timeout
      args[:read_timeout] ||= JSS::CONFIG.db_read_timeout
      args[:write_timeout] ||= JSS::CONFIG.db_write_timeout

      ### if one timeout was given, use it for all three
      args[:connect_timeout] ||= args[:timeout]
      args[:read_timeout] ||= args[:timeout]
      args[:write_timeout] ||= args[:timeout]

      ### if these weren't given, use the defaults
      args[:connect_timeout] ||= DFT_TIMEOUT
      args[:read_timeout] ||= DFT_TIMEOUT
      args[:write_timeout] ||= DFT_TIMEOUT
      args[:port] ||= Mysql::MYSQL_TCP_PORT
      args[:socket] ||= DFT_SOCKET
      args[:db_name] ||= DEFAULT_DB_NAME
      args[:charset] ||= DFT_CHARSET

      begin
        @mysql.close if connected?
      rescue Mysql::ClientError::ServerGoneError
        @connected = false
      end

      @port = args[:port]
      @socket = args[:socket]
      @mysql_name = args[:db_name]
      @user = args[:user]
      @connect_timeout = args[:connect_timeout]
      @read_timeout = args[:read_timeout]
      @write_timeout = args[:write_timeout]

      # make sure we have a user, pw, server
      raise JSS::MissingDataError, "No MySQL user specified, or listed in configuration." unless args[:user]
      raise JSS::MissingDataError, "Missing :pw (or :prompt/:stdin) for user '#{@user}'" unless args[:pw]
      raise JSS::MissingDataError, "No MySQL Server hostname specified, or listed in configuration." unless @server

      @pw = if args[:pw] == :prompt
        JSS.prompt_for_password "Enter the password for the MySQL user #{@user}@#{@server}:"
      elsif  args[:pw].is_a?(Symbol) and args[:pw].to_s.start_with?('stdin')
        args[:pw].to_s =~ /^stdin(\d+)$/
        line = $1
        line ||= 2
        JSS.stdin line
      else
        args[:pw]
      end

      @mysql = Mysql.init

      @mysql.options Mysql::OPT_CONNECT_TIMEOUT, @connect_timeout
      @mysql.options Mysql::OPT_READ_TIMEOUT, @read_timeout
      @mysql.options Mysql::OPT_WRITE_TIMEOUT, @write_timeout
      @mysql.charset = args[:charset]
      @mysql.connect @server, @user , @pw , @mysql_name, @port, @socket

      @connected = true
    end # reconnect

    ###
    ### @return [Mysql] The mysql database connection itself
    ###
    def db
      raise JSS::InvalidConnectionError, "No database connection. Please use JSS::DB_CNX.connect" unless JSS::DB_CNX.connected?
      @mysql
    end

    ###
    ### close the connection to the database
    ### it'll have to be re-connected before using again
    ###
    def disconnect
      @mysql.close if connected?
      @server = nil
      @port = nil
      @socket = nil
      @user = nil
      @connection_timeout = DFT_TIMEOUT
      @read_timeout = DFT_TIMEOUT
      @write_timeout = DFT_TIMEOUT
      @connected = false
      nil
    end # disconnect

    ### Test that a given hostname is a MySQL server
    ###
    ### @param server[String] The hostname to test
    ###
    ### @return [Boolean] does the server host a MySQL server?
    ###
    def valid_server? (server, port = DFT_PORT)
      mysql = Mysql.init
      mysql.options Mysql::OPT_CONNECT_TIMEOUT, 5

      begin
        # this connection should get an access denied error if there is
        # a mysql server there. I'm assuming no one will use this username
        # and pw for anything real
        mysql.connect server, "notArealUser", "definatelyNotA#{$$}password", "not_a_db", port

      rescue Mysql::ServerError::AccessDeniedError
        return true
      rescue
        return false
      end
      return false
    end

    ### The server to which we are connected, or will
    ### try connecting to if none is specified with the
    ### call to #connect
    ###
    ### @return [String] the hostname of the server
    ###
    def hostname
      # return it if already set
      return @server if @server
      # otherwise, from the config
      srvr = JSS::CONFIG.db_server_name
      # otherwise, assume its on the JSS server to which this client talks
      srvr ||= JSS::Client.jss_server
      return srvr
    end


    #### Aliases

    alias connected? connected

  end # class DBConnection

  ### The single instance of the DBConnection
  DB_CNX = DBConnection.instance

  ###
  ### @return [Mysql] The mysql database available through the DBConnection.instance
  ###
  def self.db
    DB_CNX.db
  end

end # module


