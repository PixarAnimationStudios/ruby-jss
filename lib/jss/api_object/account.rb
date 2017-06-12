### Copyright 2017 Pixar

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

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A User or group in the JSS.
  #
  # @see JSS::APIObject
  #
  class Account < JSS::APIObject

    # Note: This class is not fully extended and since the resource
    # is different than the rest, methods like JSS::Account.all do not work

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

    # these keys,  as well as :id and :name, can be used to look up objects of this class in the JSS
    OTHER_LOOKUP_KEYS = {
      userid: {rsrc_key: :userid, list: :all_user_ids},
      username: {rsrc_key: :username, list: :all_user_names},
      groupid: {rsrc_key: :groupid, list: :all_group_ids},
      groupname: {rsrc_key: :groupname, list: :all_group_names}
    }.freeze

    # Class Methods
    #####################################

    # @return [Array<Hash>] all JSS account users
    def self.all_users(refresh = false)
      all(refresh)[:users]
    end

    # @return [Array<Hash>] all JSS account user ids
    def self.all_user_ids(refresh = false)
      all(refresh)[:users].map { |i| i[:id] }
    end

    # @return [Array<Hash>] all JSS account user names
    def self.all_user_names(refresh = false)
      all(refresh)[:users].map { |i| i[:name] }
    end

    # @return [Array<Hash>] all JSS account groups
    def self.all_groups(refresh = false)
      all(refresh)[:groups]
    end

    # @return [Array<Hash>] all JSS account group ids
    def self.all_group_ids(refresh = false)
      all(refresh)[:groups].map { |i| i[:id] }
    end

    # @return [Array<Hash>] all JSS account group names
    def self.all_group_names(refresh = false)
      all(refresh)[:groups].map { |i| i[:name] }
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

    # See JSS::APIObject#initialize
    #
    def initialize(args = {})
      super args

      # check to see if a user has been specified, haven't built groups yet
      is_user = [:userid, :username].any? { |key| args.keys.include? key }

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
