### Copyright 2018 Pixar

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

#
module JSS

  # A patch source. The abstract parent class of {JSS::PatchInternalSource} and
  # {JSS::PatchExternalSource}
  #
  # @see JSS::APIObject
  #
  class PatchSource < JSS::APIObject

    HTTP = 'http'.freeze
    HTTPS = 'https'.freeze

    DFT_ENABLED = false
    DFT_SSL = true
    DFT_SSL_PORT = 443
    DFT_NO_SSL_PORT = 80

    AVAILABLE_TITLES_RSRC = 'patchavailabletitles/sourceid/'.freeze

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    # Data map for PatchReport XML data parsing cuz Borked JSON
    # @see {JSS::XMLWorkaround} for details
    AVAILABLE_TITLES_DATA_MAP = {
      patch_available_titles: {
        available_titles: [
          {
            name_id: JSS::BLANK,
            current_version: JSS::BLANK,
            publisher: JSS::BLANK,
            last_modified: JSS::BLANK,
            app_name: JSS::BLANK
          }
        ]
      }
    }.freeze

    # Class Methods
    ############################################

    # Get a list of patch titles available from a Patch Source (either
    # internal or external, since they have unique ids )
    #
    # @param vers[String,Integer] name or id of the Patch Source for which to
    # get the available titles
    #
    # @param api[JSS::APIConnection] The api connection to use for the query
    #   Defaults to the currently active connection
    #
    # @return [Array<Hash{Symbol:String}>] One hash for each available title, with
    #   these keys:
    #     :name_id String
    #     :current_version String
    #     :publisher String
    #     :last_modified Time
    #     :app_name  String
    #
    def self.available_titles(source, api: JSS.api)
      validate_subclass
      src_id = valid_id source
      raise JSS::NoSuchItemError, "No Patch Source found matching: #{source}" unless src_id
      rsrc = "#{AVAILABLE_TITLES_RSRC}#{src_id}"

      # TODO: remove this and adjust parsing when jamf fixes the JSON
      raw = JSS::XMLWorkaround.data_via_xml(rsrc, AVAILABLE_TITLES_DATA_MAP, api)
      titles = raw[:patch_available_titles][:available_titles]
      titles.each { |t| t[:last_modified] = Time.parse t[:last_modified] }
      titles
    end

    def self.validate_subclass
      return unless self == JSS::PatchSource
      raise JSS::UnsupportedError, 'PatchSource is an abstract parent class. Please use PatchInternalSource or PatchExternalSource'
    end

    # Attributes
    #####################################

    # @return [Boolean] Is this source enabled?
    attr_reader :enabled
    alias enabled? enabled

    # @return [String] The URL from which patch info is retrieved
    attr_reader :endpoint
    alias url endpoint

    # @return [String] The host name of the patch source
    attr_reader :host_name
    alias hostname host_name
    alias host host_name

    # @return [Integer] the TCP port of the patch source
    attr_reader :port

    # @return [Boolean] Is SSL enabled for the patch source?
    attr_reader :ssl_enabled
    alias ssl_enabled? ssl_enabled

    #
    def initialize(**args)
      self.class.validate_subclass
      super
      @enabled = @init_data[:enabled]

      # from API in Internal sources
      @endpoint = @init_data[:endpoint]

      # from API in External sources
      @host_name = @init_data[:host_name]
      @port = @init_data[:port]
      @ssl_enabled = @init_data[:ssl_enabled]

      # set defaults
      @enabled ||= DFT_ENABLED
      @ssl_enabled = DFT_SSL if ssl_enabled.nil?
      if port.nil?
        @port = ssl_enabled? ? DFT_SSL_PORT : DFT_NO_SSL_PORT
      end

      # derive the data not provided for this source type
      if @endpoint
        url = URI.parse endpoint
        @host_name = url.host
        @port = url.port
        @ssl_enabled = url.scheme == HTTPS
      else
        protocol =  ssl_enabled ? HTTPS : HTTP
        @endpoint = "#{protocol}://#{host_name}:#{port}/"
      end
    end # init

    # Enable this source for retrieving patch info
    #
    # if we ever get the ability to en/disable the internal sources,
    # this is here in the superclass
    #
    # @return [void]
    #
    def enable
      return if enabled?
      validate_host_port('enable a patch source')
      @enabled = true
      @need_to_update = true
    end

    # Disable this source for retrieving patch info
    #
    # if we ever get the ability to en/disable the internal sources,
    # this is here in the superclass
    #
    # @return [void]
    #
    def disable
      raise JSS::UnsupportedError, 'Internal Patch Sources cannot be disabled' unless self.class == JSS::PatchExternalSource
      return unless enabled?
      @enabled = false
      @need_to_update = true
    end

    # Get a list of patch titles available from this Patch Source
    #
    # @return [Array<Hash{Symbol:String}>] One hash for each available title, with
    #   these keys:
    #     :name_id String
    #     :current_version String
    #     :publisher String
    #     :last_modified Time
    #     :app_name  String
    #
    def available_titles
      self.class.available_titles id, api: api
    end

    # if we ever get the ability to en/disable the internal sources
    # this is here in the superclass
    def update
      validate_host_port('update a patch source')
      super
    end

    private

    # raise an exeption if needed when trying to do something that needs
    # a host and port set
    #
    # @param action[String] The action that needs a host and port
    #
    # @return [void]
    #
    def validate_host_port(action)
      return nil unless self.class == JSS::PatchExternalSource
      raise JSS::UnsupportedError, "Cannot #{action} without first setting a host_name and port" if hostname.to_s.empty? && port.to_s.empty?
    end

    # if we ever get the ability to en/disable the internal sources
    # this is here in the superclass
    def rest_xml
      doc = REXML::Document.new
      src = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      src.add_element('enabled').text = @enabled.to_s
      doc
    end

  end # class PatchSource

end # module JSS

require 'jss/api_object/patch_source/patch_internal_source'
require 'jss/api_object/patch_source/patch_external_source'
