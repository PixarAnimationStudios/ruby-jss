### Copyright 2019 Pixar

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

  # Module Constants
  #####################################

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # This class represents a Computer Invitation in the JSS.
  #
  # ===Adding Computer Invitations to the JSS
  #
  # This class is meant only to generate and hold the response of creating
  # an invitation.
  #
  # @see APIObject
  # @see Creatable
  #
  class ComputerInvitation < JSS::APIObject

    # MixIns
    #####################################

    include JSS::Creatable
    include JSS::Sitable

    # Class Methods
    #####################################

    def self.all_invitations(refresh = false, api: JSS.api)
      all(refresh, api: api).map { |ci| ci[:invitation]  }
    end

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'computerinvitations'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_invitations

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_invitation

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:invitation].freeze

    # See JSS::APIObject
    OTHER_LOOKUP_KEYS = {
      invitation: {rsrc_key: :invitation, list: :all_invitations}
    }.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 84

    # Where is site data located in the API JSON?
    SITE_SUBSET = :top

    # Attributes
    #####################################

    # The values returned in the General, Location, and Purchasing subsets are stored as direct attributes
    # Location and Purchasing are defined in the Locatable and Purchasable mixin modules.
    # Here's General, in alphabetical order

    # @return [String] the invitation name
    attr_reader :name

    # @return [String] the invitation type
    #
    # Valid values are: URL and EMAIL. Will default to DEFAULT.
    attr_accessor :invitation_type

    # @return [String] whether or not to create the account if required
    #
    # "true" or "false" are valid values.
    attr_accessor :create_account_if_does_not_exist

    # @return [String]
    #
    # Time since epoch that the invitation will expire at.
    #
    # Note: defaults to "Unlimited", so only set if it should expire.
    attr_accessor :expiration_date_epoch

    # @return [String]
    #
    # The username of the ssh user to be created.
    #
    # REQUIRED for valid setup.
    attr_accessor :ssh_username

    # @return [String]
    #
    # The whether or not to hide the ssh user.
    attr_accessor :hide_account

    # @return [String]
    #
    # The invitation_status.
    attr_accessor :invitation_status

    # @return [String]
    #
    # Whether the invitation can be used multiple times (boolean).
    attr_accessor :multiple_uses_allowed

    # Public Instance Methods
    #####################################

    # @see APIObject#initialize
    #
    def initialize(args = {
      id: :new,
      name: 'some_new_name',
      ssh_username: 'casper_remote',
      hide_account: 'true'
    })

      super args

      @name = @init_data[:invitation]
      @invitation_type = @init_data[:invitation_type]
      @create_account_if_does_not_exist = @init_data[:create_account_if_does_not_exist]
      @expiration_date_epoch = @init_data[:expiration_date_epoch] || args[:expiration_date_epoch]
      @ssh_username = @init_data[:ssh_username] || args[:ssh_username]
      @hide_account = @init_data[:hide_account] || args[:hide_account]
      @invitation_status = @init_data[:invitation_status] || args[:invitation_status]
      @multiple_uses_allowed = @init_data[:multiple_uses_allowed] || args[:multiple_uses_allowed]
    end

    # Public Class Methods
    #####################################

    # Needed to support creation of new Computer Invitations to set their name.
    #
    # @return [JSS::ComputerInvitation]
    #
    def create
      new_invitation_id = super

      jss_me = ComputerInvitation.fetch(id: new_invitation_id, name: 'set_by_request')
      @name = jss_me.name
      @invitation_type = jss_me.invitation_type
      @create_account_if_does_not_exist = jss_me.create_account_if_does_not_exist
      @expiration_date_epoch = jss_me.expiration_date_epoch
      @ssh_username = jss_me.ssh_username
      @hide_account = jss_me.hide_account
      @invitation_status = jss_me.invitation_status
      @multiple_uses_allowed = jss_me.multiple_uses_allowed
    end

    # Private Instance Methods
    #####################################
    private

    # Sets invitation expiration 4 hours after request.
    #
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s
      obj.add_element('invitation_type').text = invitation_type
      obj.add_element('create_account_if_does_not_exist').text = create_account_if_does_not_exist
      if expiration_date_epoch
        obj.add_element('expiration_date_epoch').text = expiration_date_epoch
      end
      obj.add_element('ssh_username').text = ssh_username
      obj.add_element('hide_account').text = hide_account
      obj.add_element('invitation_status').text = invitation_status
      obj.add_element('multiple_uses_allowed').text = multiple_uses_allowed
      add_site_to_xml(doc)
      doc.to_s
    end

  end

end
