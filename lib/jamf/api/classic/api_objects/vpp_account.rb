### Copyright 2022 Pixar

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

  # A VPP account defined in the JSS
  #
  class VPPAccount < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Updatable
    include Jamf::Sitable

    # Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'vppaccounts'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :vpp_accounts

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :vpp_account

    SITE_SUBSET = :top

    # Attributes
    #####################################

    # @return [String] The full name of the local contact person for the acct
    attr_reader :contact

    # @return [String] The service token for connecting to the account at Apple.
    #   Currently not visible, appears as '***************'
    attr_reader :service_token

    # @return [String] The name of the company associated with the Acct/Token
    attr_reader :account_name

    # @return [Time] The expiration date of the Acct/Token
    attr_reader :expiration_date

    # @return [String] The location associated with the Acct/Token
    attr_reader :location_name
    alias location location_name

    # @return [String] The Country Code associated with the acct
    attr_reader :country

    # @return [String] The AppleID associated with the acct
    attr_reader :apple_id

    # @return [Boolean] Automatically populate purchased content from Apple
    #   School Manager or Apple Business Manager in Jamf Pro
    attr_reader :populate_catalog_from_vpp_content

    # @return [Boolean] Display a notification to users on their mobile devices
    #   when a volume purchased app in a user-based volume assignment is no
    #   longer assigned to them
    attr_reader :notify_disassociation

    # @return [Boolean] Automatically register users that have Managed Apple IDs
    #   so they do not receive an invitation and are not prompted to register
    #   with volume purchasing
    attr_reader :auto_register_managed_users

    # Constructor
    #####################################

    # See Jamf::APIObject#initialize
    #
    def initialize(args = {})
      super
      @contact = @init_data[:contact]
      @service_token = @init_data[:service_token]
      @account_name = @init_data[:account_name]
      @expiration_date = @init_data[:expiration_date].to_s.empty? ? nil : Jamf.parse_time(@init_data[:expiration_date])
      @location_name = @init_data[:location_name]
      @country = @init_data[:country]
      @apple_id = @init_data[:apple_id]
      @populate_catalog_from_vpp_content = @init_data[:populate_catalog_from_vpp_content]
      @notify_disassociation = @init_data[:notify_disassociation]
      @auto_register_managed_users = @init_data[:auto_register_managed_users]
    end

    # Public Instance Methods
    #####################################

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def contact=(new_val = @contact)
      return if new_val == @contact

      @contact = Jamf::Validate.non_empty_string new_val, 'Contact must be a non-empty String'
      @need_to_update = true
    end

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def country=(new_val = @country)
      return if new_val == @country

      @country = Jamf::Validate.app_store_country_code new_val
      @need_to_update = true
    end

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def apple_id=(new_val = @apple_id)
      return if new_val == @apple_id

      @apple_id = Jamf::Validate.email_address new_val
      @need_to_update = true
    end

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def populate_catalog_from_vpp_content=(new_val = @populate_catalog_from_vpp_content)
      return if new_val == @populate_catalog_from_vpp_content

      @populate_catalog_from_vpp_content = Jamf::Validate.boolean new_val
      @need_to_update = true
    end

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def notify_disassociation=(new_val = @notify_disassociation)
      return if new_val == @notify_disassociation

      @notify_disassociation = Jamf::Validate.boolean new_val
      @need_to_update = true
    end

    # @param new_val[String] the value
    #
    # @return [void]
    #
    def auto_register_managed_users=(new_val = @auto_register_managed_users)
      return if new_val == @auto_register_managed_users

      @auto_register_managed_users = Jamf::Validate.boolean new_val
      @need_to_update = true
    end

    # Private Instance Methods
    #####################################
    private

    # Return a String with the XML Resource
    # for submitting creation or changes to the JSS via
    # the API via the Creatable or Updatable modules
    #
    # Most classes will redefine this method.
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      tmpl = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      tmpl.add_element('name').text = @name
      tmpl.add_element('contact').text = @contact
      tmpl.add_element('country').text = @country
      tmpl.add_element('apple_id').text = @apple_id
      tmpl.add_element('populate_catalog_from_vpp_content').text = @populate_catalog_from_vpp_content.to_s
      tmpl.add_element('notify_disassociation').text = @notify_disassociation.to_s
      tmpl.add_element('auto_register_managed_users').text = @auto_register_managed_users.to_s

      add_site_to_xml doc

      doc.to_s
    end

  end # VPPAccount

end # JSS
