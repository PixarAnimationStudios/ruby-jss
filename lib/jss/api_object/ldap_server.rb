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
  ### An LDAP server in the JSS.
  ###
  ### This class doesn't curretly provide creation or updaing of LDAP server
  ### definitions in the JSS. Please use the JSS web UI.
  ###
  ### However, it does provide methods for querying users and usergroups from
  ### LDAP servers, and checking group membership.
  ###
  ### When an LDAPServer instance is created, if it
  ### uses anonymous binding for lookups (the Authentication Type is set to 'none') then 
  ### the LDAP connection is established immediately. Otherwise, you must use the {#connect}
  ### method, and provide the appropriate password for the lookup account defined.
  ###
  ### Since LDAP server connections are used to verify the validity of LDAP users & groups used in 
  ### scopes, if you don't connect to all LDAP servers before modifying any scope's user & group
  ### limitations or exceptions, those new values may not be verifiable. Unverified limitations and
  ### exceptions, when sent to the API, will result in a REST 409 Conflict error if the user or 
  ### group doesn't exist. Unfortunately, 409 Conflict errors are very generic and don't indicate the
  ### source of the problem (in this case, a non-existent user or group limitation or exception to the 
  ### scope). The {JSS::Scopable} module tries to catch these errors and raise a more useful
  ### exception when they happen.
  ###
  ### The class method {LDAPServer.all_ldaps} returns a Hash of JSS::LDAPServer instances.
  ### one for each server defined in the JSS. 
  ###
  ### The class methods {LDAPServer.user_in_ldap?} and {LDAPServer.group_in_ldap?} can be
  ### used to check all defined LDAP servers for a user or group. They are used by
  ### {JSS::Scopable::Scope} when adding user and groups to scope limitations and exceptions.
  ###
  ### Within an LDAPServer instance, the methods {#find_user} and {#find_group} will return
  ### all matches in the server for a given search term.
  ###
  ### @see JSS::APIObject
  ###
  class LDAPServer < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Variables
    #####################################
    
    @@all_ldaps = nil
    
    #####################################
    ### Class Methods
    #####################################
    
    ###
    ### @param refresh[Boolean] should the LDAP server data be re-read from the API?
    ###
    ### @return [Hash{String => JSS::LDAPServer}] JSS::LDAPServer instances for all defined servers
    ###
    def self.all_ldaps(refresh = false)
      @@all_ldaps = nil if refresh
      return @@all_ldaps if @@all_ldaps
      
      @@all_ldaps = {}
      JSS::LDAPServer.all.each { |svr| @@all_ldaps[svr[:name]] = JSS::LDAPServer.new(:id =>svr[:id])}

      @@all_ldaps
    end
    
    ###
    ### @param user[String] a username to search for in all LDAP servers
    ###
    ### @return [Boolean] does the user exist in any LDAP server?
    ###
    def self.user_in_ldap? (user)
      gotuser = false
      self.all_ldaps.values.each{|ldap| gotuser =  true unless ldap.find_user(user, :exact).empty? }
      return gotuser
    end

    ###
    ### @param group[String] a group to search for in all LDAP servers
    ###
    ### @return [Boolean] does the group exist in any LDAP server?
    ###
    def self.group_in_ldap? (group)
      gotgroup = false
      self.all_ldaps.values.each{|ldap| gotgroup =  true unless ldap.find_group(group, :exact).empty? }
      return gotgroup
    end



    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "ldapservers"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :ldap_servers

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :ldap_server

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = []

    ### the default LDAP port
    DEFAULT_PORT = 389

    ### possible values for search scope
    SEARCH_SCOPES = ["All Subtrees", "First Level Only"]

    ### possible authentication types
    AUTH_TYPES = {'none' => :anonymous, 'simple' => :simple, 'CRAM-MD5' => :cram_md5, 'DIGEST-MD5' => :digest_md5 }

    ### possible referral responses
    REFERRAL_RESPONSES = ['', nil, 'follow', 'ignore']

    ### possible objectclass mapping options
    OBJECT_CLASS_MAPPING_OPTIONS = ["any", "all"]

    #####################################
    ### Attributes
    #####################################

    ### These attributes all come from the :connection hash of the
    ### API data

    ### @return [String] the hostname of the server
    attr_reader :hostanme

    ### @return [Integer] the port for ldap
    attr_reader :port

    ### @return [Boolean] should the connection use ssl?
    attr_reader :use_ssl

    ### @return [String] what authentication method should be used?
    attr_reader :authentication_type

    ### @return [String] the Distinguished Name of the account used for connections/lookups?
    attr_reader :lookup_dn

    ### @return [String] the password for the connection/lookup account, as a SHA256 digest.
    attr_reader :lookup_pw_sha256

    ### @return [Integer]  timeout, in seconds, for opening LDAP connections
    attr_reader :open_close_timeout

    ### @return [Integer] timeout, in seconds, for search queries
    attr_reader :search_timeout

    ### @return [String] the referral response from the server
    attr_reader :referral_response

    ### @return [Boolean] should searches use wildcards?
    attr_reader :use_wildcards


    ### @return [Hash<Symbol=>String>]
    ###
    ### The LDAP attributes mapped to various user data
    ###
    ### The hash keys are:
    ### - :search_base =>
    ### - :search_scope =>
    ### - :object_classes =>
    ### - :map_object_class_to_any_or_all =>
    ### - :map_username =>
    ### - :map_user_id =>
    ### - :map_department =>
    ### - :map_building =>
    ### - :map_room =>
    ### - :map_realname =>
    ### - :map_phone =>
    ### - :map_email_address =>
    ### - :map_position =>
    ### - :map_user_uuid =>
    ### - :append_to_email_results =>
    ###
    attr_reader :user_mappings


    ### @return [Hash<Symbol=>String>]
    ###
    ### The LDAP attributes mapped to various user group data
    ###
    ### The hash keys are:
    ### - :search_base =>
    ### - :search_scope =>
    ### - :object_classes =>
    ### - :map_object_class_to_any_or_all =>
    ### - :map_group_id =>
    ### - :map_group_name =>
    ### - :map_group_uuid =>
    ###
    attr_reader :user_group_mappings

    ### @return [Hash<Symbol=>String>]
    ###
    ### The LDAP attributes used to identify a user as a member of a group
    ###
    ### The hash keys are:
    ### - :user_group_membership_stored_in =>
    ### - :map_user_membership_use_dn =>
    ### - :map_group_membership_to_user_field =>
    ### - :group_id =>
    ### - :map_object_class_to_any_or_all =>
    ### - :append_to_username =>
    ### - :username =>
    ### - :object_classes =>
    ### - :use_dn =>
    ### - :search_base =>
    ### - :recursive_lookups =>
    ### - :search_scope =>
    ### - :map_user_membership_to_group_field =>
    ###
    attr_reader :user_group_membership_mappings
    
    ### @return [Boolean] we we connected to this server at the moment?
    attr_reader :connected
    
    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject#initialize
    ###
    def initialize (args = {})
      require 'net/ldap'
      super

      @hostname = @init_data[:connection][:hostname]
      @port = @init_data[:connection][:port]
      @use_ssl = @init_data[:connection][:use_ssl]
      @authentication_type = AUTH_TYPES[@init_data[:connection][:authentication_type]]
      @open_close_timeout = @init_data[:connection][:open_close_timeout]
      @search_timeout = @init_data[:connection][:search_timeout]
      @referral_response = @init_data[:connection][:referral_response]
      @use_wildcards = @init_data[:connection][:use_wildcards]

      @lookup_dn = @init_data[:connection][:account][:distinguished_username]
      @lookup_pw_sha256 = @init_data[:connection][:account][:password_sha256]

      @user_mappings = @init_data[:mappings_for_users ][:user_mappings]
      @user_group_mappings = @init_data[:mappings_for_users ][:user_group_mappings]
      @user_group_membership_mappings = @init_data[:mappings_for_users ][:user_group_membership_mappings]

      # the ldap attributes to retrieve with user lookups
      # (all those defined in the user mappings)
      @user_attrs_to_get = {
        :username => @user_mappings[:map_username],
        :user_id => @user_mappings[:map_user_id],
        :department => @user_mappings[:map_department],
        :building => @user_mappings[:map_building],
        :room => @user_mappings[:map_room],
        :realname => @user_mappings[:map_realname],
        :phone => @user_mappings[:map_phone],
        :email_address => @user_mappings[:map_email_address],
        :position => @user_mappings[:map_position],
        :user_uuid => @user_mappings[:map_user_uuid]
      }.delete_if{|k,v| v.nil? }

      # and for groups....
      @user_group_attrs_to_get = {
        :group_id => @user_group_mappings[:map_group_id],
        :group_name => @user_group_mappings[:map_group_name],
        :group_uuid => @user_group_mappings[:map_group_uuid]
      }.delete_if{|k,v| v.nil? }

      @connection = nil
      @connected = false
      
      # If we are using anonymous binding, connect now
      connect if @authentication_type == :anonymous
    end

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ###
    ### @param user[String] the username to search for
    ###
    ### @param exact[Boolean] if true, force an exact match, otherwise use wildcards if @use_wildcards is true
    ###
    ### @param additional_filter[Net::LDAP::Fliter] an additional filter to be AND'd to the existing filter.
    ###
    ### @return [Array<Hash>] The @user_attrs_to_get for all usernames matching the query
    ###
    def find_user(user, exact = false, additional_filter = nil)
      
      raise JSS::InvalidConnectionError, "Not connected to LDAP server '#{@name}'. Please use #connect first." unless @connected
      
      if @use_wildcards and not exact
        user_filter = Net::LDAP::Filter.contains(@user_mappings[:map_username], user)
      else
        user_filter = Net::LDAP::Filter.eq(@user_mappings[:map_username], user)
      end

      # limit the object classes
      ocs = @user_mappings[:object_classes].to_s.chomp.split(/,\s*/)
      anyall = @user_mappings[:map_object_class_to_any_or_all]
      oc_filter =  Net::LDAP::Filter.eq("objectclass", ocs.shift)
      ocs.each do |oc|
        if anyall == "any"
          oc_filter = oc_filter | Net::LDAP::Filter.eq("objectclass", oc)
        else
          oc_filter = oc_filter & Net::LDAP::Filter.eq("objectclass", oc)
        end
      end

      full_filter = oc_filter & user_filter
      full_filter = full_filter & additional_filter if additional_filter
      treebase = @user_mappings[:search_base]
      ldap_attribs = @user_attrs_to_get.values

      # should we grab membership from the user?
      if @user_group_membership_mappings[:user_group_membership_stored_in] == "user object" and \
        @user_group_membership_mappings[:map_group_membership_to_user_field]
        get_groups = true
        ldap_attribs << @user_group_membership_mappings[:map_group_membership_to_user_field]
      end

      results = []

      @connection.search(:base => treebase, :filter => full_filter, :attributes => ldap_attribs ) do |entry|
        userhash = {:dn => entry.dn}
        @user_attrs_to_get.each do |k,attr|
          userhash[k] = entry[attr][0]
        end
        userhash[:groups] = entry[@user_group_membership_mappings[:map_group_membership_to_user_field]] if get_groups
        # to do - if the groups are dns, convert to groupnames
        results << userhash
      end
      results
    end

    ###
    ###
    ### @param group[String] the group name to search for
    ###
    ### @param exact[Boolean] if true, force an exact match, otherwuse use wildcards if @use_wildcards is true
    ###
    ### @param additional_filter[Net::LDAP::Fliter] an additional filter to be AND'd to the existing filter.
    ###
    ### @return [Array<Hash>] The @user_group_attrs_to_get for all groups matching the query
    ###
    def find_group(group, exact = false, additional_filter = nil)
      
      raise JSS::InvalidConnectionError, "Not connected to LDAP server '#{@name}'. Please use #connect first." unless @connected
      
      if @use_wildcards and not exact
        group_filter = Net::LDAP::Filter.contains(@user_group_mappings[:map_group_name], group)
      else
        group_filter = Net::LDAP::Filter.eq(@user_group_mappings[:map_group_name], group)
      end

      # limit the object classes
      ocs = @user_group_mappings[:object_classes].to_s.chomp.split(/,\s*/)
      anyall = @user_group_mappings[:map_object_class_to_any_or_all]
      oc_filter =  Net::LDAP::Filter.eq("objectclass", ocs.shift)
      ocs.each do |oc|
        if anyall == "any"
          oc_filter = oc_filter | Net::LDAP::Filter.eq("objectclass", oc)
        else
          oc_filter = oc_filter & Net::LDAP::Filter.eq("objectclass", oc)
        end
      end

      full_filter = oc_filter & group_filter
      full_filter = full_filter & additional_filter if additional_filter
      treebase = @user_group_mappings[:search_base]
      ldap_attribs = @user_group_attrs_to_get.values

      # should we grab membership from the group?
      if @user_group_membership_mappings[:user_group_membership_stored_in] == "group object" and \
        @user_group_membership_mappings[:map_user_membership_to_group_field]
        get_members = true
        ldap_attribs << @user_group_membership_mappings[:map_user_membership_to_group_field]
      end

      results = []
      @connection.search(:base => treebase, :filter => full_filter, :attributes => ldap_attribs ) do |entry|
        hash = {:dn => entry.dn}
        @user_group_attrs_to_get.each do |k,attr|
          hash[k] = entry[attr][0]
        end
        hash[:members] = entry[@user_group_membership_mappings[:map_user_membership_to_group_field]] if get_members
        # to do, if the members are dns, convert to usernames
        results << hash
      end
      results
    end


    ###
    ### @param user[String] the username to check for memebership in the group
    ###
    ### @param group[String] the group name to see if the user is a member
    ###
    ### @return [Boolean, nil] is the user a member? Nil if unable to check
    ###
    ### @todo Implement checking groups membership in 'other' ldap area
    ###
    def check_membership(user, group)
      
      raise JSS::InvalidConnectionError, "Not connected to LDAP server '#{@name}'. Please use #connect first." unless @connected
      
      found_user = find_user(user, :exact)[0]
      found_group = find_group(group, :exact)[0]

      raise JSS::NoSuchItemError, "No user '#{user}' in LDAP." unless found_user
      raise JSS::NoSuchItemError, "No group '#{group}' in LDAP." unless found_group

      if @user_group_membership_mappings[:user_group_membership_stored_in] == "group object"
        if @user_group_membership_mappings[:map_user_membership_use_dn]
          return found_group[:members].include? found_user[:dn]
        else
          return found_group[:members].include? user
        end


      elsif @user_group_membership_mappings[:user_group_membership_stored_in] == "user object"
        if @user_group_membership_mappings[:use_dn]
          return found_user[:groups].include? found_group[:dn]
        else
          return found_user[:groups].include? group
        end


      else
        ### To do!!
        return nil
        # implement a search based on the "other" settings
        # This will be 3 searchs
        # - one for the username mapping in users
        # - one for the gid in groups
        # - one for a record linking them in the "other" search base
      end
    end


    ###
    ### The connect to this LDAP server for subsequent use of the {#find_user}, {#find_group}
    ### and {#check_membership} methods
    ###
    ### @param password[String,Symbol] the LDAP connection password for this server. Can be nil if
    ###   authentication type is 'none'.
    ###   If :prompt, the user is promted on the commandline to enter the password for the :user.
    ###   If :stdin, the password is read from a line of std in, defaults to line 0, see {JSS.stdin}
    ###
    ### @param stdin_line[Integer] which line of stdin contains the :stdin password, defaults to 1, 
    ###  but if stdin is used for the API connection, will probably be higher
    ###
    ### @return [Boolean] did we connect to the LDAP server with the defined credentials
    ###
    def connect(password = nil, stdin_line = 1)
      
      unless @authentication_type == :anonymous
        # how do we get the password?
        pw = case password
          when :prompt
            JSS.prompt_for_password "Enter the password for the LDAP connection account '#{@lookup_dn}':"
          when :stdin
            JSS.stdin stdin_line 
          else
            password
        end # case
      
        raise JSS::InvalidDataError, "Incorrect password for LDAP connection account '#{@lookup_dn}'" unless @lookup_pw_sha256 == Digest::SHA2.new(256).update(pw.to_s).to_s
      end # unless 

      @connection = Net::LDAP.new :host => @hostname, :port => @port, :auth => {:method => @authentication_type, :username => @lookup_dn, :password => pw }
      
      @connected = true
    end # connect
    
    
    
    ###
    ### Aliases
    ###
    
    alias connected? connected
    
  end # class ldap server

end # module
