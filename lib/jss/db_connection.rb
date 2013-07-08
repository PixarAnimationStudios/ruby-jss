# = db_connection.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A Singleton object representing the connection to the JSS MySQL database.
#

module PixJSS

  #####################################
  # Constants
  #####################################
  
  # The name of the JSS database on the mysql server
  DB = "jamfsoftware"
  
  # The default, read-only , mysql user for the JSS database
  DB_READER = "jssreader"
  
  # The password for the default mysql user
  DB_READER_PW = ''
  
  # the strftime format for reading/writing dates in the db
  SQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

  # The policies table in the JSS
  POLICIES_TABLE = "policies"
  
  # The Removable MAC addr table in the JSS
  REMOVABLE_MACADDR_TABLE = "removable_mac_addresses"
  
  
  #####################################
  # Module Variables
  #####################################
  
  # the connection to the jss database via mysql, maintained by the DBConnection singleton class
  @@db_cnx = nil
  
  #####################################
  # Classes
  #####################################
  
  ### 
  ### A mysql connection to the JSS database. 
  ### This is a singleton class, only one can exist at a time.
  ### Use it via the PixJSS::DB_CNX constant (for connection metadata)
  ### and the @@db_cnx module variable (which contains the actual database
  ### query interface @db) for making queries
  ###
  ### By default, a read only connection is created using DB_READER and DB_READER_PW.
  ### 
  ### To use different connection credentials, just call the connect method thus:
  ### DBConnection.connect :user => "newuser", :pw => "newpw"
  ###
  ### Mysql queries are way faster than REST, especially since REST requires 
  ### querying and searching each resource to find groups matching anything but
  ### :name or :id. So Mysql is preferred for allmost all reading from the JSS. 
  ### 
  ### Writing to the JSS on the other hand is better handled by REST, even if its slower, 
  ### since the API will better enforce data integrity and splitting data across tables
  ### properly (e.g. see how package categories are accessed).
  ###
  ### However, the API knows nothing of our custom tables, so we must
  ### use MySQL to write any changes there.
  ###
  class DBConnection
    include Singleton
    include PixJSS
    
    attr_reader :db_user
    attr_reader :db
    attr_reader :connected
    
    def initialize ()
      @connected = false
    end #init
    
    #
    # specify a different :db_user and :db_pw after the singleton object has been created
    #
    def connect(args = {})

      args[:server] ||= PixJSS::JSS_HOST
      args[:user] ||= DB_READER
      args[:pw] ||= DB_READER_PW
      
      @db.close if @connected
      @db_user = args[:user] 
      db_pw = args[:pw]
      @db = Mysql.connect(args[:server], @db_user , db_pw , PixJSS::DB)
      # give the connection a 20second timeout, for really slow
      # net connections (like... from airplanes)
      @db.options Mysql::OPT_CONNECT_TIMEOUT, 20
      @db.options Mysql::OPT_READ_TIMEOUT, 20
      @db.options Mysql::OPT_WRITE_TIMEOUT, 20
      
      @connected = true
      @db
    end # reconnect
    
    #
    # close the connection to the database
    # it'll have to be re-connected before using again
    #
    def disconnect
      @db.close if @connected
      @connected = false
      nil
    end # disconnect
    
  end # class DBConnection
  
  # Here's the mysql connection object. 
  # unlike the REST_CNX above, we'll mostly use
  # the @cnx instance var, stored in @@db_cnx below,
  # since that's the real mysql connection, and the 
  # instance doesn't have any wrapper methods.
  DB_CNX = DBConnection.instance
  
end # module


