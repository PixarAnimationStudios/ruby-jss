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
  ### to overcome some limitations of the API.
  ### 
  ### While a database connction isn't required for most things,
  ### warnings will be sent to stderr when functionality is limited due to 
  ### a lack of a database connection i.e. when JSS::DB_CNX.connected? == false
  ###
  ### For example, when saving a script, without database access, there's no 
  ### way to save the script contents into the database after "script migration"
  ### is complete, and saving the script file to the master distribution point
  ### doesn't do anything. So its up to some person to manually put the script
  ### contents into the database using the WebApp.
  ###
  ### To make a connection with credentials, just call the #connect method thus:
  ### JSS::DB_CNX.connect :server => 'server.company.com', :user => "user", :pw => "pw"
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
    
    ### give the connection a 120 second timeout, for really slow
    ### net connections (like... from airplanes)
    DFT_TIMEOUT = 120
    
    ### the strftime format for reading/writing dates in the db
    SQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
    
    attr_reader :server
    attr_reader :port
    attr_reader :user
    attr_reader :db_name
    attr_reader :connect_timeout
    attr_reader :read_timeout
    attr_reader :write_timeout
    
    attr_reader :db
    attr_reader :connected
    alias connected? connected
    
    def initialize ()
      @db = Mysql.init
      @connected = false
    end #init
    
    ###
    ### specify a different set of connection settings
    ###
    def connect(args = {})
      
      ### keep whatever settings we might already have
      args[:server] ||= @server
      args[:port] ||= @port
      args[:db_name] ||= @db_name
      args[:user] ||= @user
      args[:pw] ||= @pw
      args[:connect_timeout] ||= @connect_timeout
      args[:read_timeout] ||= @read_timeout
      args[:write_timeout] ||= @write_timeout
      
      ### if one timeout was given, use it for all three
      args[:connect_timeout] ||= args[:timeout]
      args[:read_timeout] ||= args[:timeout]
      args[:write_timeout] ||= args[:timeout]
      
      ### if none were given, use the defaults
      args[:connect_timeout] ||= DFT_TIMEOUT
      args[:read_timeout] ||= DFT_TIMEOUT
      args[:write_timeout] ||= DFT_TIMEOUT
      args[:port] ||= Mysql::MYSQL_TCP_PORT
      args[:db_name] ||= DEFAULT_DB_NAME
      
      @db.close if connected?

      @server = args[:server] 
      @port = args[:port] 
      @db_name = args[:db_name] 
      @user = args[:user] 
      @pw = args[:pw]
      @connect_timeout = args[:connect_timeout] 
      @read_timeout = args[:read_timeout] 
      @write_timeout = args[:write_timeout] 
      
      @db = Mysql.init
      
      @db.options Mysql::OPT_CONNECT_TIMEOUT, @connect_timeout
      @db.options Mysql::OPT_READ_TIMEOUT, @read_timeout
      @db.options Mysql::OPT_WRITE_TIMEOUT, @write_timeout
      
      @db.connect(args[:server], @user , @pw , @db_name, @port)

      @connected = true
    end # reconnect
    
    ###
    ### close the connection to the database
    ### it'll have to be re-connected before using again
    ###
    def disconnect
      @db.close if connected?
      @connected = false
      nil
    end # disconnect
    
  end # class DBConnection
  
  ### The single instance of the DBConnection 
  DB_CNX = DBConnection.instance
  
  ### The database itself, an attribute of the DBConnection,
  ### to which SQL queries are sent.
  DB = DB_CNX.db
  
end # module


