# Copyright 2022 Pixar

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

module Jamf

  # Classes
  ###################################

  # The parent class of OSXConfigurationProfile and MobileDeviceConfigurationProfile
  #
  # Note that the profile payloads and the profile UUID cannot be edited or updated with this via this class.
  # Use the web UI.
  #
  # @see Jamf::APIObject
  #
  class ConfigurationProfile < Jamf::APIObject

    # Mix-Ins
    ###################################

    include Jamf::Updatable
    include Jamf::Scopable
    include Jamf::SelfServable
    include Jamf::Categorizable
    include Jamf::Sitable

    # Class Constants
    ###################################

    # The possible values for the distribution_method/deployment_method
    DISTRIBUTION_METHODS = ['Install Automatically', 'Make Available in Self Service'].freeze

    # which DISTRIBUTION_METHODS means we're in self service?
    SELF_SERVICE_DIST_METHOD = 'Make Available in Self Service'.freeze

    # when a change is made, which in-scope machines should get
    # the changed profile?
    REDEPLOY_NEWLY_ASSIGNED = 'Newly Assigned'.freeze
    REDEPLOY_ALL = 'All'.freeze

    # Our SelfService deploys profiles
    SELF_SERVICE_PAYLOAD = :profile

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :general

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = Hash

    # Attributes
    ###################################

    # @return [String] the description of this profile
    attr_reader :description

    # @return [String] the uuid of this profile. NOT Updatable
    attr_reader :uuid

    # @return [String] When a change is made to the profile, which scoped machines
    #   should get the changes? This will always contain REDEPLOY_NEWLY_ASSIGNED
    #   when fetched, but can be set to REDEPLOY_ALL via the redeploy_to_all:
    #   parameter to #update & #save. After the update is complete, it reverts
    #   to REDEPLOY_NEWLY_ASSIGNED
    attr_reader :redeploy_on_update

    # @return [String] the plist containing the payloads for this profile. NOT Updatable
    attr_reader :payloads

    # Constructor
    ###################################

    # See Jamf::APIObject#initialize
    #
    def initialize(args = {})
      super
      @description = @main_subset[:description]
      @uuid = @main_subset[:uuid]
      @redeploy_on_update = @main_subset[:redeploy_on_update]
      @payloads = @main_subset[:payloads]
    end

    # Public Instance Methods
    ###################################

    # @param new_val[String] the new discription
    #
    # @return [void]
    #
    def description=(new_val)
      new_val = new_val.strip
      return nil if @self_service_description == new_val

      @description = new_val
      @need_to_update = true
    end # @param new_val[String] how should this be distributed to clients?

    # The @payloads Plist, parsed into a Ruby object
    #
    # @return [Hash] the parsed payloads plist.
    def parsed_payloads
      JSS.parse_plist @payloads
    end

    # @return [Array<Hash>] the individual payloads from the payload Plist
    #
    def payload_content
      parsed_payloads['PayloadContent']
    end

    # @param new_content [Array<Hash>] replace the payload content entirely.
    #
    #   The 'payload' of a config profile is an XML Plist. The top-level key
    #   of that plist 'PayloadContent' contains an Array of Dicts, each one being
    #   a part of the payload for the profile.
    #
    #   When replacing the PayloadContent Array, using this method, provide a
    #   *ruby* Array full of *ruby* hashes, and they will be converted to a
    #   Plist and embedded into the API XML appropriately.
    #
    #   WARNING: This is experimental! Editing the Plist Payload of a Config
    #   profile may break the profile. Make sure you test on a fake profile
    #   before using this method in production.
    #
    # @return [void]
    #
    def payload_content=(new_content)
      payload_plist_data = parsed_payloads
      payload_plist_data['PayloadContent'] = new_content
      @payloads = JSS.xml_plist_from new_content
      @need_to_update = true
      @update_payloads = true
    end

    # @return [Array<String>] the PayloadType of each payload (e.g. com.apple.caldav.account)
    #
    def payload_types
      payload_content.map { |p| p['PayloadType'] }
    end

    # clear flag after updating
    def update(redeploy_to_all: false)
      @redeploy_on_update = redeploy_to_all ? REDEPLOY_ALL : REDEPLOY_NEWLY_ASSIGNED
      super()
      # always reset to newly assigned
      @redeploy_on_update = REDEPLOY_NEWLY_ASSIGNED
      @update_payloads = nil
    end

    # wrapper with param
    def save(redeploy_to_all: false)
      if @in_jss
        raise Jamf::UnsupportedError, 'Updating this object in the JSS is currently not supported by ruby-jss' unless updatable?

        update redeploy_to_all: redeploy_to_all
      else
        raise Jamf::UnsupportedError, 'Creating this object in the JSS is currently not supported by ruby-jss' unless creatable?

        create
      end
    end

    # Private Instance Methods
    ###################################
    private

    def rest_xml
      doc = REXML::Document.new

      obj = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      gen = obj.add_element('general')
      gen.add_element('description').text = @description
      gen.add_element('redeploy_on_update').text = @redeploy_on_update
      if @update_payloads
        payloads_plist_xml = JSS.escape_xml(@payloads.gsub(/^\t*/, '').gsub(">\n", '>'))
        gen.add_element('payloads').text = payloads_plist_xml
      end
      obj << @scope.scope_xml
      add_self_service_xml doc
      add_category_to_xml doc
      add_site_to_xml doc
      doc
    end

  end # class OSXConfigurationProfile

end # module
