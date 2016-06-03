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
  ### Module Constants
  #####################################

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  ###
  ### This class represents a Computer Invitation in the JSS.
  ###
  ### ===Adding Computer Invitations to the JSS
  ###
  ### This class is meant only to generate and hold the response of creating
  ### an invitation.
  ###
  ### @see APIObject
  ### @see Creatable
  ###

  class ComputerInvitation < JSS::APIObject

    #####################################
    ### MixIns
    #####################################

    include JSS::Creatable

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "computerinvitations"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_invitations

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_invitation

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:invitation]

    #####################################
    ### Attributes
    #####################################

    ### The values returned in the General, Location, and Purchasing subsets are stored as direct attributes
    ### Location and Purchasing are defined in the Locatable and Purchasable mixin modules.
    ### Here's General, in alphabetical order

    ### @return [String] the invitation name
    attr_reader :name

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### @see APIObject#initialize
    ###
    def initialize(args = {id: :new, name: "some_new_name"})

      super args, []

      ### We need to generate the name uniquely for each instance, so we're
      ### doing a create straight off the bat.
      @name = @init_data[:invitation]
    end

    #####################################
    ### Public Class Methods
    #####################################

    ###
    ### Needed to support creation of new Computer Invitations to set their name.
    ###
    ### @return [JSS::ComputerInvitation]
    ###
    def create
      new_invitation_id = super

      jss_me = ComputerInvitation.new(id: new_invitation_id, name: 'set_by_request')
      @name = jss_me.name
    end

    #####################################
    ### Private Instance Methods
    #####################################
    private

    ###
    ### Sets invitation expiration 4 hours after request.
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s
      obj.add_element('invitation_type').text = 'URL'
      obj.add_element('create_account_if_does_not_exist').text = 'true'
      obj.add_element('expiration_date_epoch').text = DateTime.now.advance(hours: 4).strftime('%Q')

      return doc.to_s
    end
  end
end
