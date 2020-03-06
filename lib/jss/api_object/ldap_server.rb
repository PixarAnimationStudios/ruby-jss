# Copyright 2019 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

module JSS

  # Classes
  #####################################

  # An LDAP server in the JSS.
  #
  # This class doesn't curretly provide creation or updaing of LDAP server
  # definitions in the JSS. Please use the JSS web UI.
  #
  # However, it does provide methods for querying users and usergroups from
  # LDAP servers, and checking group membership.
  #
  # The class methods {LDAPServer.user_in_ldap?} and {LDAPServer.group_in_ldap?} can be
  # used to check all defined LDAP servers for a user or group. They are used by
  # {JSS::Scopable::Scope} when adding user and groups to scope limitations and exceptions.
  #
  # Within an LDAPServer instance, the methods {#find_user} and {#find_group} will return
  # all matches in the server for a given search term.
  #
  # @see JSS::APIObject
  #
  class LDAPServer < JSS::APIObject

    # Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'ldapservers'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :ldap_servers

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :ldap_server

    # the default LDAP port
    DEFAULT_PORT = 389

    # possible values for search scope
    SEARCH_SCOPES = ['All Subtrees', 'First Level Only'].freeze

    # possible authentication types
    AUTH_TYPES = { 'none' => :anonymous, 'simple' => :simple, 'CRAM-MD5' => :cram_md5, 'DIGEST-MD5' => :digest_md5 }.freeze

    # possible referral responses
    REFERRAL_RESPONSES = ['', nil, 'follow', 'ignore'].freeze

    # possible objectclass mapping options
    OBJECT_CLASS_MAPPING_OPTIONS = %w[any all].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 80

    # Class Methods
    #####################################

    # Does a user exist in any ldap server?
    #
    # @param user[String] a username to search for in all LDAP servers
    #
    # @param api[JSS::APIConnection] the API connection to use for the search#

    # @return [Integer, nil] the id of the first LDAP server with the user,
    #  nil if not found
    #
    def self.server_for_user(user, api: JSS.api)
      all_objects(:refresh, api: api).each do |ldap|
        next if ldap.find_user(user, :exact).empty?
        return ldap.id
      end
      nil
    end

    # For Backward Compatibility,
    #
    # @param user[String] a username to search for in all LDAP servers
    #
    # @param api[JSS::APIConnection] the API connection to use for the search
    #
    # @return [Boolean] Does the user exist in any LDAP server?
    #
    def self.user_in_ldap?(user, api: JSS.api)
      server_for_user(user, api: api) ? true : false
    end

    # Does a group exist in any ldap server?
    #
    # @param group[String] a group to search for in all LDAP servers
    #
    # @param api[JSS::APIConnection] the API connection to use for the search
    #
    # @return [Integer, nil] the id of the first LDAP server with the group,
    #  nil if not found
    #
    def self.server_for_group(group, api: JSS.api)
      all_objects(:refresh, api: api).each do |ldap|
        next if ldap.find_group(group, :exact).empty?
        return ldap.id
      end
      nil
    end

    # For Backward Compatibility,
    #
    # @param user[String] a group name to search for in all LDAP servers
    #
    # @param api[JSS::APIConnection] the API connection to use for the search
    #
    # @return [Boolean] Does the group exist in any LDAP server?
    #
    def self.group_in_ldap?(group, api: JSS.api)
      server_for_group(group, api: api) ? true : false
    end

    # On a given server, does a given group contain a given user?
    #
    # This class method allows the check to happen without instanting
    # the LDAPServer.
    #
    # @param server[String, Integer] The name or id of the LDAP server to use
    #
    # @param user[String] the username to check for memebership in the group
    #
    # @param group[String] the group name to see if the user is a member
    #
    # @param api[JSS::APIConnection] the API connection to use for the search
    #
    # @return [Boolean] is the user a member of the group?
    #
    def self.check_membership(ldap_server, user, group, api: JSS.api)
      ldap_server_id = valid_id ldap_server
      raise JSS::NoSuchItemError, "No LDAPServer matching #{ldap_server}" unless ldap_server_id
      rsrc = "#{RSRC_BASE}/id/#{ldap_server_id}/group/#{CGI.escape group.to_s}/user/#{CGI.escape user.to_s}"
      member_check = api.get_rsrc rsrc
      return false if member_check[:ldap_users].empty?
      true
    end

    # Attributes
    #####################################

    # These attributes all come from the :connection hash of the
    # API data

    # @return [String] the hostname of the server
    attr_reader :hostanme

    # @return [Integer] the port for ldap
    attr_reader :port

    # @return [Boolean] should the connection use ssl?
    attr_reader :use_ssl

    # @return [String] what authentication method should be used?
    attr_reader :authentication_type

    # @return [String] the Distinguished Name of the account used for connections/lookups?
    attr_reader :lookup_dn

    # @return [String] the password for the connection/lookup account, as a SHA256 digest.
    attr_reader :lookup_pw_sha256

    # @return [Integer]  timeout, in seconds, for opening LDAP connections
    attr_reader :open_close_timeout

    # @return [Integer] timeout, in seconds, for search queries
    attr_reader :search_timeout

    # @return [String] the referral response from the server
    attr_reader :referral_response

    # @return [Boolean] should searches use wildcards?
    attr_reader :use_wildcards

    # @return [Hash<Symbol=>String>]
    #
    # The LDAP attributes mapped to various user data
    #
    # The hash keys are:
    # - :search_base =>
    # - :search_scope =>
    # - :object_classes =>
    # - :map_object_class_to_any_or_all =>
    # - :map_username =>
    # - :map_user_id =>
    # - :map_department =>
    # - :map_building =>
    # - :map_room =>
    # - :map_realname =>
    # - :map_phone =>
    # - :map_email_address =>
    # - :map_position =>
    # - :map_user_uuid =>
    # - :append_to_email_results =>
    #
    attr_reader :user_mappings

    # @return [Hash<Symbol=>String>]
    #
    # The LDAP attributes mapped to various user group data
    #
    # The hash keys are:
    # - :search_base =>
    # - :search_scope =>
    # - :object_classes =>
    # - :map_object_class_to_any_or_all =>
    # - :map_group_id =>
    # - :map_group_name =>
    # - :map_group_uuid =>
    #
    attr_reader :user_group_mappings

    # @return [Hash<Symbol=>String>]
    #
    # The LDAP attributes used to identify a user as a member of a group
    #
    # The hash keys are:
    # - :user_group_membership_stored_in =>
    # - :map_user_membership_use_dn =>
    # - :map_group_membership_to_user_field =>
    # - :group_id =>
    # - :map_object_class_to_any_or_all =>
    # - :append_to_username =>
    # - :username =>
    # - :object_classes =>
    # - :use_dn =>
    # - :search_base =>
    # - :recursive_lookups =>
    # - :search_scope =>
    # - :map_user_membership_to_group_field =>
    #
    attr_reader :user_group_membership_mappings

    # Constructor
    #####################################

    #
    # See JSS::APIObject#initialize
    #
    def initialize(args = {})
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

      @user_mappings = @init_data[:mappings_for_users][:user_mappings]
      @user_group_mappings = @init_data[:mappings_for_users][:user_group_mappings]
      @user_group_membership_mappings = @init_data[:mappings_for_users][:user_group_membership_mappings]

      @connection = nil
      @connected = false
    end

    # Public Instance Methods
    #####################################

    # Search for a user in this ldap server
    #
    # @param user[String] the username to search for
    #
    # @param exact[Boolean] if true, force an exact match, otherwise use wildcards
    #
    # @return [Array<Hash>] The mapped LDAP data for all usernames matching the query
    #
    def find_user(user, exact = false)
      raise JSS::NoSuchItemError, 'LDAPServer not yet saved in the JSS' unless @in_jss
      raw = api.get_rsrc("#{RSRC_BASE}/id/#{@id}/user/#{CGI.escape user.to_s}")[:ldap_users]
      exact ? raw.select { |u| u[:username] == user } : raw
    end

    # @param group[String] the group name to search for
    #
    # @param exact[Boolean] if true, force an exact match, otherwuse use wildcards
    #
    # @return [Array<Hash>] The groupname and uid for all groups matching the query
    #
    def find_group(group, exact = false)
      raise JSS::NoSuchItemError, 'LDAPServer not yet saved in the JSS' unless @in_jss
      raw = api.get_rsrc("#{RSRC_BASE}/id/#{@id}/group/#{CGI.escape group.to_s}")[:ldap_groups]
      exact ? raw.select { |u| u[:groupname] == group } : raw
    end

    # @param user[String] the username to check for memebership in the group
    #
    # @param group[String] the group name to see if the user is a member
    #
    # @return [Boolean, nil] is the user a member? Nil if unable to check
    #
    def check_membership(user, group)
      raise JSS::NoSuchItemError, 'LDAPServer not yet saved in the JSS' unless @in_jss
      self.class.check_membership @id, user, group, api: @api
    end

  end # class ldap server

end # module
