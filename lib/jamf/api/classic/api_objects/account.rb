# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A User or group in the JSS.
  #
  # TODO: Split this into 2 classes, with lots of custom code.
  # Thanks Jamf!
  #
  # @see Jamf::APIObject
  #
  class Account < Jamf::APIObject

    # NOTE: This class is not fully extended and since the resource
    # is different than the rest, methods like Jamf::Account.all do not work

    # Mix-Ins
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'accounts'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :accounts

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :account

    # these keys,  as well as :id and :name, can be used to look up objects of
    # this class in the JSS
    OTHER_LOOKUP_KEYS = {
      userid: { fetch_rsrc_key: :userid },
      username: { fetch_rsrc_key: :username },
      groupid: { fetch_rsrc_key: :groupid },
      groupname: { fetch_rsrc_key: :groupname }
    }.freeze

    # Class Methods
    #####################################

    # override auto-defined method
    def self.all_ids(_refresh = false, **_bunk)
      raise '.all_ids is not valid for Jamf::Account, use .all_user_ids or .all_group_ids'
    end

    # override auto-defined method
    def self.all_names(_refresh = false, **_bunk)
      raise '.all_names is not valid for Jamf::Account, use .all_user_names or .all_group_names'
    end

    # @return [Array<Hash>] all JSS account users
    def self.all_users(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:users]
    end

    # @return [Array<Hash>] all JSS account user ids
    def self.all_user_ids(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:users].map { |i| i[:id] }
    end

    # @return [Array<Hash>] all JSS account user names
    def self.all_user_names(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:users].map { |i| i[:name] }
    end

    # @return [Array<Hash>] all JSS account groups
    def self.all_groups(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:groups]
    end

    # @return [Array<Hash>] all JSS account group ids
    def self.all_group_ids(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:groups].map { |i| i[:id] }
    end

    # @return [Array<Hash>] all JSS account group names
    def self.all_group_names(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all(refresh, cnx: cnx)[:groups].map { |i| i[:name] }
    end

    # Attributes
    #####################################

    # @return [String] The user's full name
    attr_reader :full_name

    # @return [String] The user's email address
    attr_reader :email

    # @return [String] The user's access level
    attr_reader :access_level

    # @return [String] The user's privilege set
    attr_reader :privilege_set

    # @return [Hash]
    #
    # Info about the privileges assigned to the user
    #
    # Note: these arrays may be empty, they always exist
    #
    # The Hash keys are:
    # * :jss_objects => An array of jss_object privileges
    # * :jss_settings => An array of jss_settings privileges
    # * :jss_actions => An array of jss_actions privileges
    # * :recon => An array of Casper Recon privileges
    # * :casper_admin => An array of Casper Admin privileges
    # * :casper_remote => An array of Casper Remote privileges
    # * :casper_imaging => An array of Casper Imaging privileges
    attr_reader :privileges

    # Constructor
    #####################################

    # See Jamf::APIObject#initialize
    #
    def initialize(**args)
      super

      # check to see if a user has been specified, haven't built groups yet
      is_user = %i[userid username].any? { |key| args.keys.include? key }

      return unless is_user

      @user_name = @init_data[:name]
      @full_name = @init_data[:full_name]
      @email = @init_data[:email]
      @access_level = @init_data[:access_level]
      @privilege_set = @init_data[:privilege_set]
      @privileges = @init_data[:privileges]
    end # initialize

  end # class accounts

end # module
