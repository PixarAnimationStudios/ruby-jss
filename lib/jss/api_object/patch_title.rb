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

  # An active Patch Software Title in the JSS.
  #
  # This class provides access to titles that have been added to Jamf Pro
  # via a PatchInternalSource or a PatchExternalSource, and the versions
  # contained therein.
  #
  # Patch versions for the title are available in the #versions read-only
  # attribute, a Hash of versions keyed by the version string. The values are
  # JSS::PatchTitle::Version objects.
  #
  # Use the patch_report method on the PatchTitle class, an instance of it, or
  # a PatchTitle::Version, to retrieve a report of computers with a
  # specific version of the title installed, or :all, :latest, or :unknown
  # versions. Reports called on the class or an instance default to :all
  # versions, and are slower to retrieve than a specific version,
  #
  # @see JSS::APIObject
  #
  class PatchTitle < JSS::APIObject

    include JSS::Sitable
    include JSS::Categorizable
    include JSS::Creatable
    include JSS::Updatable

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    # Data map for PatchTitle XML data parsing cuz Borked JSON
    # @see {JSS::XMLWorkaround} for details
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
        site: {
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

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    # Data map for PatchReport XML data parsing cuz Borked JSON
    # @see {JSS::XMLWorkaround} for details
    PATCH_REPORT_DATA_MAP = {
      patch_report: {
        name: JSS::BLANK,
        patch_software_title_id: -1,
        total_computers: 0,
        total_versions: 0,
        versions: [
          {
            software_version: JSS::BLANK,
            computers: [
              {
                id: -1,
                name: JSS::BLANK,
                mac_address: JSS::BLANK,
                alt_mac_address: JSS::BLANK,
                serial_number: JSS::BLANK
              }
            ]
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

    REPORTS_RSRC_BASE = '/patchreports/patchsoftwaretitleid'.freeze

    # Class Methods
    #######################################

    # The same as  @see APIObject.all but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    # ALSO, JAMF BUG: More broken json - the id is coming as a string.
    # so here we turn it into an integer manually :-(
    # Ditto for source_id
    #
    def self.all(refresh = false, source_id: nil, api: JSS.api)
      data = super refresh, api: api
      data.each do |info|
        info[:id] = info[:id].to_i
        info[:source_id] = info[:source_id].to_i
      end
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

    # Get a patch report for a softwaretitle, withouth fetching an instance.
    # Defaults to reporting all versions. Specifiying a version will be faster.
    #
    # The Hash returned has 3 keys:
    #   - :total_comptuters [Integer] total computers found for the requested version(s)
    #   - :total versions [Integer] How many versions does this title have?
    #       Always 1 if you report a specific version
    #   - :versions [Hash {String => Array<Hash>}] Keys are the version(s) requested
    #     values are Arrays of Hashes, one per computer with the keyed version
    #     installed. Computer Hashes have identifiers as keys.
    #
    # PatchTitle#patch_report calls this method, as does
    # PatchTitle::Version.patch_report.
    #
    # @param title[Integer, String]  The name or id of the software title to
    #   report.
    #
    # @param version[String,Symbol] Limit the report to this version.
    #   Can be a string version number like '8.13.2' or :latest, :unknown,
    #   or :all. Defaults to :all
    #
    # @param api[JSS::APIConnection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {JSS::APIConnection}
    #
    # @return [Hash] the patch report for the version(s) specified.
    #
    def self.patch_report(title, version: :all, api: JSS.api)
      title_id = valid_id title, api: api
      raise JSS::NoSuchItemError, "No PatchTitle matches '#{title}'" unless title_id

      rsrc = patch_report_rsrc title_id, version

      # TODO: remove this and adjust parsing when jamf fixes the JSON
      raw_report = XMLWorkaround.data_via_xml(rsrc, PATCH_REPORT_DATA_MAP, api)[:patch_report]
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

    # aliases of patch_report
    singleton_class.send(:alias_method, :version_report, :patch_report)
    singleton_class.send(:alias_method, :report, :patch_report)

    # given a requested version, return the rest rsrc for getting
    # a patch report for it.
    def self.patch_report_rsrc(id, vers)
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
    private_class_method :patch_report_rsrc

    # for some reason, patch titles can't be fetched by name.
    # only by id. SO, look up the id if given a name.
    #
    def self.fetch(id: nil, name: nil, api: JSS.api)
      unless id
        id =  JSS::PatchTitle.map_all_ids_to(:name).invert[name]
        raise NoSuchItemError, "No matching #{self::RSRC_OBJECT_KEY} found" unless id
      end

      super id: id, api: api
    end

    # Attributes
    #####################################

    # @return [String] the 'name_id' for this patch title. name_id is a unique
    #   identfier provided by the patch source
    attr_reader :name_id

    # @return [Integer] the id of the patch source from which we get patches
    #   for this title
    attr_reader :source_id

    # @return [Boolean] Are new patches announced in the JSS web ui?
    attr_reader :web_notification
    alias web_notification? web_notification

    # @return [Boolean] Are new patches announced by email?
    attr_reader :email_notification
    alias email_notification? email_notification

    # @return [Hash{String => JSS::PatchTitle::Version}] The JSS::PatchVersions fetched for
    #   this title, keyed by version string
    attr_reader :versions

    # PatchTitles may be fetched by name: or id:
    #
    def initialize(**args)
      super

      @name_id = @init_data[:name_id]
      @source_id = @init_data[:source_id]

      @init_data[:notifications] ||= {}
      notifs = @init_data[:notifications]
      @web_notification = notifs[:web_notification].nil? ? false : notifs[:web_notification]
      @email_notification = notifs[:email_notification].nil? ? false : notifs[:email_notification]

      @versions = {}
      @init_data[:versions] ||= []
      @init_data[:versions].each do |vers|
        @versions[vers[:software_version]] = JSS::PatchTitle::Version.new(self, vers)
      end # each do vers

      @changed_pkgs = []
    end

    # @return [Hash] Subset of @versions, containing those which have packages
    #   assigned
    #
    def versions_with_packages
      versions.select { |_ver_string, vers| vers.package_assigned? }
    end

    def email_notification=(new_setting)
      return if email_notification == new_setting
      raise JSS::InvalidDataError, 'New Setting must be boolean true or false' unless JSS::TRUE_FALSE.include? @email_notification = new_setting
      @need_to_update = true
    end

    def web_notification=(new_setting)
      return if web_notification == new_setting
      raise JSS::InvalidDataError, 'New Setting must be boolean true or false' unless JSS::TRUE_FALSE.include? @web_notification = new_setting
      @need_to_update = true
    end

    # this is called by JSS::PatchTitle::Version#package= to update @changed_pkgs which
    # is used by #rest_xml to change the package assigned to a patch version
    # in this title.
    def changed_pkg_for_version(version)
      @changed_pkgs << version
      @need_to_update = true
    end

    def source_id=(new_id)
      sid = JSS::PatchSource.valid_patch_source_id new_id
      raise JSS::NoSuchItemError, "No active Patch Sources matche '#{new_id}'" unless sid
      return if sid == source_id
      @source_id = sid
      @need_to_update = true
    end

    def name_id=(new_id)
      return if new_id == name_id
      raise JSS::NoSuchItemError, 'source_id must be set before setting name_id' if source_id.to_s.empty?
      raise JSS::NoSuchItemError, "source_id #{source_id} doesn't offer name_id '#{new_id}'" unless JSS::PatchSource.available_name_ids(source_id).include? new_id
      @name_id = new_id
      @need_to_update = true
    end

    # wrapper to fetch versions after creating
    def create
      validate_for_saving
      response = super
      @versions = self.class.fetch(id: id).versions
      response
    end

    # wrapper to clear @changed_pkgs after updating
    def update
      validate_for_saving
      response = super
      @changed_pkgs.clear
      response
    end

    # Get a patch report for this title.
    #
    # See the class method JSS::PatchTitle.patch_report
    #
    def patch_report(vers = :all)
      JSS::PatchTitle.patch_report id, version: vers, api: @api
    end
    alias version_report patch_report
    alias report patch_report

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

    #################################
    private

    def validate_for_saving
      raise JSS::InvalidDataError, 'PatchTitles must have valid source_id and name_id' if source_id.to_s.empty? || name_id.to_s.empty?
    end

    # Return the REST XML for this title, with the current values,
    # for saving or updating.
    #
    def rest_xml
      doc = REXML::Document.new # JSS::APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      obj.add_element('name').text = name
      obj.add_element('name_id').text = name_id
      obj.add_element('source_id').text = source_id

      notifs = obj.add_element 'notifications'
      notifs.add_element('web_notification').text = web_notification?.to_s
      notifs.add_element('email_notification').text = email_notification?.to_s

      add_changed_pkg_xml obj unless @changed_pkgs.empty?

      add_category_to_xml doc
      add_site_to_xml doc

      doc.to_s
    end # rest_xml

    # add xml for any package changes to patch versions
    def add_changed_pkg_xml(obj)
      versions_elem = obj.add_element 'versions'
      @changed_pkgs.each do |vers|
        velem = versions_elem.add_element 'version'
        velem.add_element('software_version').text = vers.to_s
        pkg = velem.add_element 'package'
        # leave am empty package element to remove the pkg assignement
        next if versions[vers].package_id == :none
        pkg.add_element('id').text = versions[vers].package_id.to_s
      end # do vers
    end

  end # class Patch

end # module JSS

require 'jss/api_object/patch_title/version'
