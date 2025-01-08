### Copyright 2025 Pixar

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

module Jamf

  # This is just a stub for now.
  class MacApplication < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Updatable
    include Jamf::Scopable
    include Jamf::SelfServable
    include Jamf::Categorizable
    include Jamf::VPPable
    include Jamf::Sitable

    ### The base for REST resources of this class
    RSRC_BASE = 'macapplications'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mac_applications

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mac_application

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 350

    # See Jamf::Scopable
    SCOPE_TARGET_KEY = :computers

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :general

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = Hash

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # Attributes
    #############################################

    # @return [String]
    attr_reader :version

    # @return [Boolean]
    attr_reader :is_free
    alias free? is_free

    # @return [String]
    attr_reader :bundle_id

    # @return [String]
    attr_reader :url

    ## Constructor
    #####################################

    def initialize(**args)
      super
      general = @init_data[:general]
      @version = general[:version]
      @is_free = general[:is_free]
      @bundle_id = general[:bundle_id]
      @url = general[:url]
    end

    # Overrides, because consistency isn't alway a thing in the
    # classic API
    #############################################

    # Override self_service_display_name getter
    def self_service_display_name
      raise Jamf::UnsupportedError, 'MacApplications do not have separate display names. Please use the object name.'
    end

    # Override self_service_display_name setter
    def self_service_display_name=(_newname)
      raise Jamf::UnsupportedError, 'MacApplications do not have separate display names. Please use the object name.'
    end

    # Override reinstall_button_text getter
    def reinstall_button_text
      raise Jamf::UnsupportedError, 'MacApplications do not have separate text for reinstall buttons. Please use install_button_text.'
    end

    # Override reinstall_button_text setter
    def reinstall_button_text=(_new)
      raise Jamf::UnsupportedError, 'MacApplications do not have separate text for reinstall buttons. Please use install_button_text.'
    end

    # Alas, SSvc icons are not uploadable via the API for
    # mac apps
    def upload(_type, _local_file)
      raise Jamf::UnsupportedError, 'The Classic API does not support uploading icons for MacApplications. Please use the Web UI'
    end

    ## Private Instance Methods
    #####################################
    private

    ### Return the xml for creating or updating this script in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element('general')

      general.add_element('version').text = @version
      general.add_element('is_free').text = @is_free.to_s
      general.add_element('bundle_id').text = @bundle_id
      general.add_element('url').text = @url

      obj << @scope.scope_xml

      add_self_service_xml doc
      add_category_to_xml doc
      add_site_to_xml doc
      add_vpp_xml doc

      doc.to_s
    end

  end # class MacApplication

end # module Jamf
