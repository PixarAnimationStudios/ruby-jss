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

  # A patch source. The abstract parent class of {JSS::PatchInternalSource} and
  # {JSS::PatchExternalSource}
  #
  # @see JSS::APIObject
  #
  class PatchSource < JSS::APIObject

    include JSS::Updatable

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
    #
    # These work from this metaclass, as well as from the
    # subclasses. In the metaclass, both subclasses are searched
    # and a :type value is available.
    ############################################

    # Get names, ids and types for all patch sources
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<Hash{:name=>String, :id=> Integer, :type => Symbol}>]
    #
    def self.all(refresh = false, api: JSS.api)
      if self == JSS::PatchSource
        int = JSS::PatchInternalSource.all(refresh, api: api).each { |s| s[:type] = :internal }
        ext = JSS::PatchExternalSource.all(refresh, api: api).each { |s| s[:type] = :external }
        return (int + ext).sort! { |s1, s2| s1[:id] <=> s2[:id] }
      end
      super
    end

    # Get names, ids  for all patch internal sources
    #
    # the same as JSS::PatchInternalSource.all refresh, api: api
    #
    # @see  JSS::PatchInternalSource.all
    #
    def self.all_internal(refresh = false, api: JSS.api)
      JSS::PatchInternalSource.all refresh, api: api
    end

    # Get names, ids  for all patch internal sources
    #
    # the same as JSS::PatchExternalSource.all refresh, api: api
    #
    #  @see  JSS::PatchExternalSource.all
    #
    def self.all_external(refresh = false, api: JSS.api)
      JSS::PatchExternalSource.all refresh, api: api
    end

    # @see JSS::APIObject.all_objects
    #
    def self.all_objects(refresh = false, api: JSS.api)
      if self == JSS::PatchSource
        int = JSS::PatchInternalSource.all_objects refresh, api: api
        ext = JSS::PatchExternalSource.all_objects refresh, api: api
        return (int + ext).sort! { |s1, s2| s1.id <=> s2.id }
      end
      super
    end

    # Fetch either an internal or external patch source
    #
    # BUG: there's an API bug: fetching a non-existent ids
    # which is why we rescue internal server errors.
    #
    # @see APIObject.fetch
    #
    def self.fetch(arg, api: JSS.api)
      if self == JSS::PatchSource
        begin
          fetched = JSS::PatchInternalSource.fetch arg, api: api
        rescue RestClient::ResourceNotFound, RestClient::InternalServerError, JSS::NoSuchItemError
          fetched = nil
        end
        unless fetched
          begin
            fetched = JSS::PatchExternalSource.fetch arg, api: api
          rescue RestClient::ResourceNotFound, RestClient::InternalServerError, JSS::NoSuchItemError
            raise JSS::NoSuchItemError, 'No matching PatchSource found'
          end
        end
        return fetched
      end # if self == JSS::PatchSource
      begin
        super
      rescue RestClient::ResourceNotFound, RestClient::InternalServerError, JSS::NoSuchItemError
        raise JSS::NoSuchItemError, "No matching #{self::RSRC_OBJECT_KEY} found"
      end
    end

    # Only JSS::PatchExternalSources can be created
    #
    # @see APIObject.make
    #
    def self.make(**args)
      case self.name
      when 'JSS::PatchSource'
        JSS::PatchExternalSource.make args
      when 'JSS::PatchExternalSource'
        super
      when 'JSS::PatchInternalSource'
        raise JSS::UnsupportedError, 'PatchInteralSources cannot be created.'
      end
    end

    # Only JSS::PatchExternalSources can be deleted
    #
    # @see APIObject.delete
    #
    def self.delete(victims, api: JSS.api)
      case self.name
      when 'JSS::PatchSource'
        JSS::PatchExternalSource victims, api: api
      when 'JSS::PatchExternalSource'
        super
      when 'JSS::PatchInternalSource'
        raise JSS::UnsupportedError, 'PatchInteralSources cannot be deleted.'
      end
    end

    # Get a list of patch titles available from a Patch Source (either
    # internal or external, since they have unique ids )
    #
    # @param source[String,Integer] name or id of the Patch Source for which to
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
      src_id = valid_patch_source_id source, api: api
      raise JSS::NoSuchItemError, "No Patch Source found matching: #{source}" unless src_id

      rsrc_base =
        if valid_patch_source_type(src_id, api: api) == :internal
          JSS::PatchInternalSource::AVAILABLE_TITLES_RSRC
        else
          JSS::PatchExternalSource::AVAILABLE_TITLES_RSRC
        end

      rsrc = "#{rsrc_base}#{src_id}"

      begin
        # TODO: remove this and adjust parsing when jamf fixes the JSON
        raw = JSS::XMLWorkaround.data_via_xml(rsrc, AVAILABLE_TITLES_DATA_MAP, api)
      rescue RestClient::ResourceNotFound
        return []
      end

      titles = raw[:patch_available_titles][:available_titles]
      titles.each { |t| t[:last_modified] = Time.parse t[:last_modified] }
      titles
    end

    # FOr a given patch source, an array of available 'name_id's
    # which are uniq identifiers for titles available on that source.
    #
    # @see available_titles
    #
    # @return [Array<String>] the name_ids available on the source
    #
    def self.available_name_ids(source, api: JSS.api)
      available_titles(source, api: api).map { |t| t[:name_id] }
    end

    # Given a name or id for a Patch Source (internal or external)
    # return the id if it exists, or nil if it doesn't.
    #
    # NOTE: does not indicate which kind of source it is, just that it exists
    # and can be used as a source_id for a patch title.
    # @see .valid_patch_source_type
    #
    # @param ident[String,Integer] the name or id to validate
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Integer, nil] the valid id or nil if it doesn't exist.
    #
    def self.valid_patch_source_id(ident, refresh = false, api: JSS.api)
      id = JSS::PatchInternalSource.valid_id ident, refresh, api: api
      id ||= JSS::PatchExternalSource.valid_id ident, refresh, api: api
      id
    end

    # Given a name or id for a Patch Source
    # return :internal or :external if it exists, or nil if it doesnt.
    #
    # @param ident[String,Integer] the name or id to validate
    #
    # @param refresh [Boolean] Should the data be re-read from the server
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Symbol, nil] :internal, :external, or nil if it doesn't exist.
    #
    def self.valid_patch_source_type(ident, refresh = false, api: JSS.api)
      return :internel if JSS::PatchInternalSource.valid_id ident, refresh, api: api
      return :external if JSS::PatchExternalSource.valid_id ident, refresh, api: api
      nil
    end

    # Attributes
    #####################################

    # @return [Boolean] Is this source enabled?
    attr_reader :enabled
    alias enabled? enabled

    # @return [String] The URL from which patch info is retrieved
    attr_reader :endpoint
    alias url endpoint

    # @param newname [String] The new host name (external sources only)
    #
    # @return [String] The host name of the patch source
    attr_reader :host_name
    alias hostname host_name
    alias host host_name

    # @param new_port [Integer] The new port (external sources only)
    #
    # @return [Integer] the TCP port of the patch source
    attr_reader :port

    # @return [Boolean] Is SSL enabled for the patch source?
    attr_reader :ssl_enabled
    alias ssl_enabled? ssl_enabled

    # Init
    def initialize(**args)
      raise JSS::UnsupportedError, 'PatchSource is an abstract metaclass. Please use PatchInternalSource or PatchExternalSource' if self.class == JSS::PatchSource

      super

      @enabled = @init_data[:enabled].to_s.jss_to_bool
      @enabled ||= false

      # derive the data not provided for this source type
      if @init_data[:endpoint]
        @endpoint = @init_data[:endpoint]
        url = URI.parse endpoint
        @host_name = url.host
        @port = url.port
        @ssl_enabled = url.scheme == HTTPS
      else
        @host_name = @init_data[:host_name]
        @port = @init_data[:port].to_i
        @port ||= ssl_enabled? ? DFT_SSL_PORT : DFT_NO_SSL_PORT
        @ssl_enabled = @init_data[:ssl_enabled].to_s.jss_to_bool
        @ssl_enabled ||= false
        @endpoint = "#{ssl_enabled ? HTTPS : HTTP}://#{host_name}:#{port}/"
      end
    end # init

    # Get a list of patch titles available from this Patch Source
    # @see JSS::PatchSource.available_titles
    #
    def available_titles
      self.class.available_titles id, api: api
    end

    # Get a list of available name_id's for this patch source
    # @see JSS::PatchSource.available_name_ids
    #
    def available_name_ids
      self.class.available_name_ids id, api: api
    end

    # Delete this instance
    # This method is needed to override APIObject#delete
    def delete
      case self.class.name
      when 'JSS::PatchExternalSource'
        super
      when 'JSS::PatchInternalSource'
        raise JSS::UnsupportedError, 'PatchInteralSources cannot be deleted.'
      end
    end

  end # class PatchSource

end # module JSS

require 'jss/api_object/patch_source/patch_internal_source'
require 'jss/api_object/patch_source/patch_external_source'
