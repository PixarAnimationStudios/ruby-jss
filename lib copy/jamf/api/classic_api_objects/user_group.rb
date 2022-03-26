### Copyright 2020 Pixar

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
module Jamf

  #####################################
  ### Module Constants
  #####################################

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
  ### A Mobile Device group in the JSS
  ###
  ### See also the parent class Jamf::Group
  ###
  ### @see Jamf::APIObject
  ###
  ### @see Jamf::Group
  ###
  class UserGroup < Jamf::Group

    #####################################
    ### Mix-Ins
    #####################################


    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "usergroups"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :user_groups

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user_group

    ### this allows the parent Group class to do things right
    MEMBER_CLASS = Jamf::User

    # the XML element for immediate member additions via PUT
    ADD_MEMBERS_ELEMENT = 'user_additions'.freeze

    # the XML element for immediate member removals via PUT
    REMOVE_MEMBERS_ELEMENT = 'user_deletions'.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 54

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### Return an array of the usernames of users in this group
    ###
    ### @return [Array<String>] the member usernames
    ###
    def member_usernames
      @members.map{|m| m[:username]}
    end

    ###
    ### Return an array of the full names of users in this group
    ###
    ### @return [Array<String>] the member full names
    ###
    def member_full_names
      @members.map{|m| m[:full_name]}
    end

    ###
    ### Return an array of the phone numbers of users in this group
    ###
    ### @return [Array<String>] the member phone numbers
    ###
    def member_phone_numbers
      @members.map{|m| m[:phone_number]}
    end

    ###
    ### Return an array of the email addresses of users in this group
    ###
    ### @return [Array<String>] the member email addresses
    ###
    def member_email_addresses
      @members.map{|m| m[:email_address]}
    end

    #####################################
    ### Private Instance Methods
    #####################################


  end # class UserGroup

end # module
