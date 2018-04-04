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
module JSS

  # An active Patch Title, or 'Patch Software Title' in the JSS.
  #
  # Even though this class corresponds to the 'patches' resource of the API
  # these objects are really 'Titles', not 'Patches'. The versions within the
  # title are really the patches, and are defined in the JSS::PatchVersion class
  #
  # This class will contain methods/attributes for accessing those patches, and
  # they can only be instantiated by fetching the title that contains them.
  #
  #
  # @see JSS::APIObject
  #
  class PatchTitle < JSS::APIObject

    include JSS::Sitable
    include JSS::Categorizable
    include JSS::Updatable

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    USE_XML_WORKAROUND = {
      patch_software_title: {
        id: -1,
        name: JSS::BLANK,
        name_id: JSS::BLANK,
        source_id: -1,
        notifications: {
          email_notification: nil,
          web_notification: nil
        },
        category: {
          id: -1,
          name: JSS::BLANK
        },
        versions: [
          {
            software_version: JSS::BLANK,
            package: {
              id: -1,
              name: JSS::BLANK
            }
          }
        ]
      }
    }.freeze

    ### The base for REST resources of this class
    RSRC_BASE = 'patchsoftwaretitles'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :patch_software_titles

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :patch_software_title

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = %i[notifications name_id source_id].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    # TODO: comfirm this in 10.4
    OBJECT_HISTORY_OBJECT_TYPE = 604

    SITE_SUBSET = :top

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :top

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = Hash

    # when fetching a specific version, this is a valid version
    LATEST_VERSION_ID = 'Latest'.freeze

    # when fetching a specific version, this is a valid version
    UNKNOWN_VERSION_ID = 'Unknown'.freeze

    # How can we be notified of new patches for this title?
    # :jss = in the JSS web UI
    # :email = via email
    # :jss_and_email = both
    # :none = no notifications
    NEW_VERSION_NOTIFICATIONS = %i[
      web
      email
      web_and_email
      none
    ].freeze

    WEB_NOTIFICATIONS = %i[web web_and_email].freeze
    EMAIL_NOTIFICATIONS = %i[email web_and_email].freeze

    REPORTS_RSRC_BASE = '/patchreports/patchsoftwaretitleid'.freeze

    # Class Methods
    #######################################

    # The same as  @see APIObject.all but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    def self.all(refresh = false, source_id: nil, api: JSS.api)
      data = super(refresh, api: api)
      return data unless source_id
      data.select { |p| p[:source_id] == source_id }
    end

    # The same as  @see APIObject.all_names but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    def self.all_names(refresh = false, source_id: nil, api: JSS.api)
      all(refresh, source_id: source_id, api: api).map { |i| i[:name] }
    end

    # The same as  @see APIObject.all_ids but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    def self.all_ids(refresh = false, source_id: nil, api: JSS.api)
      all(refresh, source_id: source_id, api: api).map { |i| i[:id] }
    end

    # @return [Array<String>] all 'name_id' values for active patches
    #
    def self.all_name_ids(refresh = false, source_id: nil, api: JSS.api)
      all(refresh, source_id: source_id, api: api).map { |i| i[:name_id] }
    end

    # Returns an Array of unique source_ids used by active Patches
    #
    # e.g. if there are patches that come from one internal source
    # and two external sources this might return [1,3,4].
    #
    # Regardless of how many patches come from each source, the
    # source id appears only once in this array.
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Array<Integer>] the ids of the patch sources used in the JSS
    #
    def self.all_source_ids(refresh = false, api: JSS.api)
      all(refresh, api: api).map { |i| i[:source_id] }.sort.uniq
    end

    # Attributes
    #####################################

    # @return [String] the 'name_id' for this patch title. name_id is a unique
    # identfier provided by the patch source
    attr_reader :name_id

    # @return [Integer] the id of the patch source from which we get patches
    # for this title
    attr_reader :source_id

    # @return [Symbol] How should new patches be announced within the JSS webUI?
    # one of: :jss, :email, :jss_and_email, :none
    attr_reader :notifications

    # @return [Integer, nil] how many total versions/patches are we aware of for this
    #   title? Nil unless fetched with versions: :all
    attr_reader :total_versions
    alias total_patches total_versions

    # @return [Integer, nil] How many computers have any version of this title
    #   installed?  Nil unless fetched with versions: :all. @see #total_computers_found
    attr_reader :total_computers

    # @return [Hash{String => JSS::PatchTitle::Version}] The JSS::PatchVersions fetched for
    # this title, keyed by version string
    attr_reader :versions
    alias patches versions

    # PatchTitles may be fetched by name: or id:
    #
    # By default, PatchTitles are fetched with data about the latest known
    # PatchVersion only, because the search takes much less time than with
    # all known PatchVersions. You may also specify `version: :latest` for the
    # same effect.
    #
    # To gather data about all known PatchVersions, use 'version: :all' when
    # fetching a PatchTitle. To get just the 'Unknown' version, use
    # 'version: :unknown'.  For any other version, specify the version as a String
    #
    # The #total_versions and #total_computers attributes will return nil unless
    # you fetched with 'version: :all', use #total_computers_found to get the
    # number found for a specific version.
    #
    def initialize(**args)
      super

      @name_id = @init_data[:name_id]
      @source_id = @init_data[:source_id]

      parse_notifications

      @total_versions = @init_data[:total_versions]
      @total_computers = @init_data[:total_computers]

      parse_versions

      @changed_pkgs = []
    end

    # @return [Integer] How many computers were found with the
    #   specified PatchVersion(s)?
    #
    def total_computers_found
      return total_computers if @version_fetched == :all
      patch_versions.values.first.size
    end

    # @return [Array<String>] PatchVersion numbers not installed
    #   on any computers
    def versions_with_no_computers
      patch_versions.keys.select { |v| patch_versions[v].size.zero? }
    end

    # @return [Array<String>] PatchVersion numbers installed
    #   on at least one computer
    def versions_with_computers
      patch_versions.keys.reject { |v| patch_versions[v].size.zero? }
    end

    # @return [Boolean] Do notifications show up in the jss?
    #
    def jss_notification?
      JSS_NOTIFICATIONS.include? notifications
    end

    # @return [Boolean] Do notifications get sent via email?
    #
    def email_notification?
      EMAIL_NOTIFICATIONS.include? notifications
    end

    # Set how to get notifications of new patches for this title
    #
    # @param now[Symbol] How should we be notified of new versions for this title?
    #   one of the values of NEW_VERSION_NOTIFICATIONS
    #
    # @return [void]
    #
    def notifications=(how)
      return if @notifications == how
      raise JSS::InvalidDataError, "Parameter must be one of :#{NEW_VERSION_NOTIFICATIONS.join ', :'}" unless NEW_VERSION_NOTIFICATIONS.include? how
      @notifications = how
      @need_to_update = true
    end

    # Remove the various cached data
    # from the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = super
      vars.delete :@versions
      vars
    end

    # this is called by JSS::PatchVersion#package= to update @changed_pkgs which
    # is used by #rest_xml to change the package assigned to a patch version
    # in this title.
    def changed_pkg_for(version)
      @changed_pkgs << version
      @need_to_update = true
    end

    # wrapper to clear @changed_pkgs after updating
    def update
      resp = super
      @changed_pkgs.clear
      resp
    end

    # TODO: use new XML parsing with data map
    # Get a patch report for this title
    # The Hash returned has 3 keys:
    #   - :total_comptuters [Integer] total computers found for the requested version(s)
    #   - :total versions [Integer] How many versions does this title have?
    #       Always 1 if you report a specific version
    #   - :versions [Hash {String => Array<Hash>}] Keys are the version(s) requested
    #     values are Arrays of Hashes, one per computer with the keyed version
    #     installed. Computer Hashes have identifiers as keys.
    #
    # See Also JSS::PatchTitle::Version.patch_report
    #
    # @param vers[String,Symbol] the version to report about. Can be a string
    #   version number like '8.13.2' or :latest, :unknown, or :all. Defaults
    #   to :all
    #
    # @return [Hash] the patch report for the version(s) specified.
    #
    def patch_report(vers = :all)
      rsrc = patch_report_rsrc(vers)

      # TODO: remove this and adjust parsing when jamf fixes the JSON
      raw_report = XMLWorkaround.json_via_xml(rsrc, @api)[:patch_report]

      report = {}
      report[:total_computers] = raw_report[:total_computers]
      report[:total_versions] = raw_report[:total_versions]

      if raw_report[:versions].is_a? Hash
        vs = raw_report[:versions][:version][:software_version].to_s
        comps = raw_report[:versions][:version][:computers]
        comps = [] if comps.empty?
        report[:versions] = { vs => comps }
        return report
      end

      report[:versions] = {}
      raw_report[:versions].each do |v|
        report[:versions][v[:software_version].to_s] = v[:computers].empty? ? [] : v[:computers]
      end
      report
    end

    def total_computers
      patch_report[:total_computers]
    end

    def total_versions
      patch_report[:total_versions]
    end

    #################################
    private

    # Used by initialize
    def parse_notifications
      notifs = @init_data[:notifications]
      @notifications =
        if notifs[:jss_notification] && notifs[:email_notification]
          :jss_and_email
        elsif notifs[:jss_notification]
          :jss
        elsif notifs[:email_notification]
          :email
        else
          :none
        end
    end

    # if not fetching all versions,
    # make a version-specific rest resource to GET
    #
    # Used by initialize
    def parse_fetch_rsrc(args)
      return nil if args[:version] == :all
      rsrc_key, lookup_value = find_rsrc_keys(args)
      "#{self.class::RSRC_BASE}/#{rsrc_key}/#{lookup_value}/version/#{args[:version]}"
    end

    # Used by initialize
    def parse_versions
      @versions = {}
      @init_data[:versions].each do |vers|
        @versions[vers[:software_version]] = JSS::PatchTitle::Version.new(self, vers)
      end # each do vers

      @version_fetched =
        case @version_requested
        when :all then :all
        when :unknown then :unknown
        else @versions.keys.first # yay for ordered hashes
        end
    end

    # given a requested version, return the rest rsrc for getting
    # a patch report for it.
    def patch_report_rsrc(vers)
      case vers
      when :all
        "#{REPORTS_RSRC_BASE}/#{id}"
      when :latest
        "#{REPORTS_RSRC_BASE}/#{id}/version/#{LATEST_VERSION_ID}"
      when :unknown
        "#{REPORTS_RSRC_BASE}/#{id}/version/#{UNKNOWN_VERSION_ID}"
      else
        "#{REPORTS_RSRC_BASE}/#{id}/version/#{vers}"
      end
    end

    # Return the REST XML for this title, with the current values,
    # for saving or updating.
    #
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      # obj = doc.add_element RSRC_OBJECT_KEY.to_s
      # LOVE us some inconsistency :-(
      obj = doc.add_element XML_PUT_OBJECT_KEY

      obj.add_element('name').text = name

      notifs = obj.add_element 'notifications'
      notifs.add_element('jss_notification').text = jss_notification?.to_s
      notifs.add_element('email_notification').text = email_notification?.to_s

      add_changed_pkg_xml obj

      add_category_to_xml doc
      add_site_to_xml doc

      doc.to_s
    end # rest_xml

    # add xml for any package changes to patch versions
    def add_changed_pkg_xml(obj)
      return if @changed_pkgs.empty?
      versions_elem = obj.add_element 'versions'
      @changed_pkgs.each do |vers|
        velem = versions_elem.add_element 'version'
        velem.add_element('software_version').text = vers.to_s
        pkg = velem.add_element 'package'
        # leave am empty package element to remove the pkg assignement
        next if patch_versions[vers].package_id == :none
        pkg.add_element('id').text = patch_versions[vers].package_id.to_s
      end # do vers
    end

  end # class Patch

end # module JSS

require 'jss/api_object/patch_title/version'
