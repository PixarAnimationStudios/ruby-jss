# = rest_connection.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A Singleton object representing the connection to the JSS REST API.
#

module PixJSS
  
  #####################################
  # Constants
  #####################################
  
  # The REST API path in the http URL
  REST_RSRC = "JSSResource"
  
  # put it together into the URL we use for RESTful work
  REST_URL = URI::encode "http://#{JSS_HOST}:#{JSS_PORT}/#{REST_RSRC}"
  
  # The top line of an XML doc for submitting data via REST
  REST_XML_HEADER = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
  
  
  #####################################
  # Module Variables
  #####################################
  
  # the connection to the jss database via REST, maintained by the RESTConnection singleton class
  @@rest_cnx = nil
  
  #####################################
  # Module Methods
  #####################################
  
  #####################################
  # Classes
  #####################################
  
  ### 
  ### A REST API connection to the JSS database
  ### This is a singleton class, only one can exist at a time.
  ### Use it via the PixJSS::REST_CNX constant if you want to use the 
  ### methods provided below, or the @@rest_cnx module variable if
  ### you want direct access to the RestClient::Resource object.
  ###
  ### for general reading and writing, its handy to use the methods below:
  ### get_rsrc, put_rsrc, put_xml, post_rsrc, & delete_rsrc.
  ###
  ### By default, a read only connection is created using REST_READER and REST_READER_PW.
  ###
  ### To use different connection credentials, just call the 
  ### RESTConnection.connect method with  :user => "newuser", :pw => "newpw"
  ###
  ### NOTE: the user must have API permissions in the JSS
  ###
  ### This object is mostly used for writing changes to the JSS, 
  ### either adding or modifying
  ### resources (DB records, mostly) or attributes (fields) within existing resources, 
  ### or deleting resources. 
  ### 
  ### While its simple to read data from the JSS via the REST API, it's very slow, and 
  ### can't yet return groups of records or do any complex searches. 
  ### Also, it has no access to the custom pixar tables
  ### For speedier reading, use the mysql connection via the DBConnection class.
  ###
  ###
  ### See https://casper.pixar.com:8443/apiFrontPage.rest for 
  ### documentation about the JSS REST API
  ###
  class RESTConnection
    include Singleton
    include PixJSS
    
    attr_reader :jss_user
    attr_reader :cnx
    attr_reader :authenticated
    
    def initialize ()
      @authenticated = false
      @connected = false
      self
    end # init
    
    ###
    ### specify a :user and :pw to use for REST connections
    ### and return the rest client object.
    ### Default :timeout and :open_timeout are are 60 secs
    ### If you need to override them,
    ### provide them as integers.
    ###
    def connect (args = {})
      args[:server] ||= PixJSS::JSS_HOST
      args[:port] ||= PixJSS::JSS_PORT
      @rest_url = URI::encode "http://#{args[:server]}:#{args[:port]}/#{REST_RSRC}"
      
      args[:user] ||= REST_READER
      args[:pw] ||= REST_READER_PW
      args[:password] = args[:pw]
      args[:timeout] ||= 60
      args[:open_timeout] ||= 60
      
      @cnx = RestClient::Resource.new("#{@rest_url}", args) 
      @authenticated = true if REST_READER != args[:user]
      @jss_user = args[:user]
      @connected = true
      @cnx  
    end # reconnect
    
    ###
    ### there isn't any real "connection" to disconnect from, just
    ### the saved authentication credentials. So to disconnect, just 
    ### reconnect with the default read-only credentials
    ###
    def disconnect
      connect :user => REST_READER, :pw => REST_READER_PW
      @connected = false
    end # disconnect
    
    #
    # Get an arbitrary JSS record or field via a REST resource, 
    # all nice and parsed into a ruby data structure (arrays, hashes, strings, etc)
    # attribute and item names (hash keys) come back as ruby symbols
    #
    # rsrc = the JSS resource to fetch
    #
    def get_rsrc (rsrc = nil)
     raise MissingDataError, "No REST resource specified" unless rsrc 
     rsrc = URI::encode rsrc
     JSON.parse(@cnx[rsrc].get(:accept => :json), :symbolize_names => true)
    end
    
    #
    # Change an existing field in a JSS record via a REST resource
    #
    # :rsrc => the REST resource being writting (the record in the DB, basically)
    # :attrib => the name of the attribute to write
    # :value => the value to write to the attribute
    #
    def put_rsrc (args = {})
      raise InvalidConnectionError, "Not authenticated to the JSS." if @jss_user == REST_READER 
      raise MissingDataError, "Missing :rsrc" if args[:rsrc].nil?
      raise MissingDataError, "Missing :attrib" if args[:attrib].nil?
      raise MissingDataError, "Missing :value" if args[:value].nil?
      @cnx[args[:rsrc]].put(args[:attrib] => args[:value])
    end
    
    #
    # Change many fields of an existing JSS record via a REST resource
    #
    # :rsrc => the REST resource being writting
    # :xml => the xml txt specifying the changes.
    #
    # for example, to make a computer resource be "in inventory"
    # the resource might look like this:
    #
    # computers/macaddress/00.25.bc.dc.f7.ec
    #
    # the xml looks like this:
    #
    # <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    # <computer>
    #   <location>
    #     <username>inventory</username>
    #     <real_name>inventory</real_name>
    #     <email_address>inventory</email_address>
    #     <position>inventory</position>
    #     <phone>inventory</phone>
    #     <room>u350</room>
    #   </location>
    # </computer>'
    # 
    def put_xml(args = {})
      raise InvalidConnectionError, "Not authenticated to the JSS." if @jss_user == REST_READER 
      raise MissingDataError, "No REST resource specified" unless args[:rsrc]
      raise MissingDataError, "No XML payload specified" unless args[:xml]
      @cnx[args[:rsrc]].put(args[:xml], :content_type => 'text/xml')
    end
  
    #
    # Add a new top-level resource to the JSS via REST post
    # top level resources are, e.g. computers, pkgs, scripts...
    #
    # :rsrc = the resource to create
    # :xml = the xml data defining the resource
    #
    def post_rsrc(args={})
      raise InvalidConnectionError, "Not authenticated to the JSS." if @jss_user == REST_READER 
      raise MissingDataError, "Missing :rsrc" if args[:rsrc].nil?
      raise MissingDataError, "Missing :xml" if args[:xml].nil?
      
      # convert CRs & to &#13;
      args[:xml].gsub!(/\r/, '&#13;')
      
      # send the data
      @cnx[args[:rsrc]].post args[:xml], :content_type => 'text/xml', :accept => :json
      
    end #post_rsrc
    
    #
    # delete a top-level resource fromthe JSS via REST
    # top level resources are, e.g. computers, pkgs, scripts...
    #
    # :rsrc = the resource to create
    #
    def delete_rsrc(rsrc)
      raise InvalidConnectionError, "Not authenticated to the JSS." if @jss_user == REST_READER 
      raise MissingDataError, "Missing :rsrc" if rsrc.nil?
      
      # delete the resource
      @cnx[rsrc].delete
      
    end #delete_rsrc
  end # class JSSRESTconnection
  
  # Since its a singleton object, just store it here
  # Most of the work done will be through this, rather than its
  # internal @cnx var (formerly stored in @@rest_cnx below)
  # because the instance has wrapper methods which we'll 
  # use.  See DB_CNX for differences with the mysql connection
  REST_CNX = RESTConnection.instance

    
end # module