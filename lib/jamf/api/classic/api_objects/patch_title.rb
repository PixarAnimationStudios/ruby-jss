### Copyright 2023 Pixar

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

  # An active Patch Software Title in the JSS.
  #
  # This class provides access to titles that have been added to Jamf Pro
  # via a PatchInternalSource or a PatchExternalSource, and the versions
  # contained therein.
  #
  # Patch versions for the title are available in the #versions read-only
  # attribute, a Hash of versions keyed by the version string. The values are
  # Jamf::PatchTitle::Version objects.
  #
  # When creating/activating new Patch Titles, with .make, a unique name:, a
  # source: and a name_id: must be provided - the source must be the name or id
  # of an existing PatchSource, and the name_id must be offered by that source.
  # Once created, the source_id and name_id cannot be changed.
  #
  # When fetching titles, they can be fetched by id:, source_name_id:, or both
  # source: and name_id:
  #
  # WARNING: While they can be fetched by name, beware: the JSS does not enforce
  # unique names of titles even thought ruby-jss does. If there are duplicates
  # of the name you fetch, which one you get is undefined.
  #
  # Use the patch_report class or instance method, or
  # PatchTitle::Version.patch_report, to retrieve a report of computers with a
  # specific version of the title installed, or :all, :latest, or :unknown
  # versions. Reports called on the class or an instance default to :all
  # versions, and are slower to retrieve than a specific version,
  #
  # @see Jamf::APIObject
  #
  class PatchTitle < Jamf::APIObject

    include Jamf::Sitable
    include Jamf::Categorizable
    include Jamf::Creatable
    include Jamf::Updatable

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    # Data map for PatchTitle XML data parsing cuz Borked JSON
    # @see {Jamf::XMLWorkaround} for details
    USE_XML_WORKAROUND = {
      patch_software_title: {
        id: -1,
        name: Jamf::BLANK,
        name_id: Jamf::BLANK,
        source_id: -1,
        notifications: {
          email_notification: nil,
          web_notification: nil
        },
        category: {
          id: -1,
          name: Jamf::BLANK
        },
        site: {
          id: -1,
          name: Jamf::BLANK
        },
        versions: [
          {
            software_version: Jamf::BLANK,
            package: {
              id: -1,
              name: Jamf::BLANK
            }
          }
        ]
      }
    }.freeze

    # TODO: remove this and adjust parsing when jamf fixes the JSON
    # Data map for PatchReport XML data parsing cuz Borked JSON
    # @see {Jamf::XMLWorkaround} for details
    PATCH_REPORT_DATA_MAP = {
      patch_report: {
        name: Jamf::BLANK,
        patch_software_title_id: -1,
        total_computers: 0,
        total_versions: 0,
        versions: [
          {
            software_version: Jamf::BLANK,
            computers: [
              {
                id: -1,
                name: Jamf::BLANK,
                mac_address: Jamf::BLANK,
                alt_mac_address: Jamf::BLANK,
                serial_number: Jamf::BLANK
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

    NON_UNIQUE_NAMES = true

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

    REPORTS_RSRC_BASE = 'patchreports/patchsoftwaretitleid'.freeze

    # Class Methods
    #######################################

    # The same as  @see APIObject.all but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    # Also - since the combined source_id and name_id are unique, create an
    # identifier key ':source_name_id' by joining them with '-'
    #
    # JAMF BUG: More broken json - the id is coming as a string.
    # so here we turn it into an integer manually :-(
    # Ditto for source_id
    #
    def self.all(refresh = false, source_id: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      data = super refresh, cnx: cnx
      data.each do |info|
        info[:id] = info[:id].to_i
        info[:source_name_id] = "#{info[:source_id]}-#{info[:name_id]}"
        info[:source_id] = info[:source_id].to_i
      end
      return data unless source_id

      data.select { |p| p[:source_id] == source_id }
    end

    # The same as  @see APIObject.all_names but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    def self.all_names(refresh = false, source_id: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, source_id: source_id, cnx: cnx).map { |i| i[:name] }
    end

    # The same as  @see APIObject.all_ids but also takes an optional
    # source_id: parameter, which limites the results to
    # patch titles with the specified source_id.
    #
    def self.all_ids(refresh = false, source_id: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, source_id: source_id, cnx: cnx).map { |i| i[:id] }
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
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<Integer>] the ids of the patch sources used in the JSS
    #
    def self.all_source_ids(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).map { |i| i[:source_id] }.sort.uniq
    end

    # @return [Array<String>] all 'source_name_id' values for active patches
    #
    def self.all_source_name_ids(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).map { |i| i[:source_name_id] }
    end

    # Get a patch report for a softwaretitle, without fetching an instance.
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
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash] the patch report for the version(s) specified.
    #
    def self.patch_report(title, version: :all, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      title_id = valid_id title, cnx: cnx
      raise Jamf::NoSuchItemError, "No PatchTitle matches '#{title}'" unless title_id

      rsrc = patch_report_rsrc title_id, version

      # TODO: remove this and adjust parsing when jamf fixes the JSON
      raw_report = XMLWorkaround.data_via_xml(rsrc, PATCH_REPORT_DATA_MAP, cnx)[:patch_report]

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

    # Patch titles only have an id-based GET resource in the API.
    # so all other lookup values have to be converted to ID before
    # the call to super
    #
    def self.fetch(identifier = nil, **params)
      # default connection if unspecified
      cnx = params.delete :cnx
      cnx ||= params.delete :api # backward compatibility, deprecated
      cnx ||= Jamf.cnx

      # source: and source_id: are considered the same, source_id: wins
      params[:source_id] ||= params[:source]

      # if given a source name, this converts it to an id
      params[:source_id] = Jamf::PatchInternalSource.valid_id params[:source_id]
      params[:source_id] ||= Jamf::PatchExternalSource.valid_id params[:source_id]

      # build a possible source_name_id
      params[:source_name_id] ||= "#{params[:source_id]}-#{params[:name_id]}"

      id =
        if identifier
          valid_id identifier
        elsif params[:id]
          all_ids.include?(params[:id]) ? params[:id] : nil
        elsif params[:source_name_id]
          map_all_ids_to(:source_name_id).invert[params[:source_name_id]]
        elsif params[:name]
          map_all_ids_to(:name).invert[params[:name]]
        end

      raise Jamf::NoSuchItemError, "No matching #{name} found" unless id

      super id: id, cnx: cnx
    end

    # Override the {APIObject.valid_id}, since patch sources are so non-standard
    # Accept id, source_name_id, or name.
    # Note name may not be unique, and if not, ymmv
    #
    def self.valid_id(ident, refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      id = all_ids(refresh, cnx: cnx).include?(ident) ? ident : nil
      id ||= map_all(:id, to: :source_name_id).invert[ident]
      id ||= map_all(:id, to: :name).invert[ident]
      id
    end

    # Attributes
    #####################################

    # @return [String] the 'name_id' for this patch title. name_id is a unique
    #   identfier provided by the patch source
    attr_reader :name_id

    # @return [Integer] the id of the patch source from which we get patches
    #   for this title
    attr_reader :source_id

    # @return [String] the source_id and name_id joined by '-', a unique identifier
    attr_reader :source_name_id

    # @return [Boolean] Are new patches announced in the JSS web ui?
    attr_reader :web_notification
    alias web_notification? web_notification

    # @return [Boolean] Are new patches announced by email?
    attr_reader :email_notification
    alias email_notification? email_notification

    def initialize(**args)
      super

      if in_jss
        @name_id = @init_data[:name_id]
        @source_id = @init_data[:source_id]
      else
        # source: and source_id: are considered the same, source_id: wins
        @init_data[:source_id] ||= @init_data[:source]

        raise Jamf::MissingDataError, 'source: and name_id: must be provided' unless @init_data[:name_id] && @init_data[:source_id]

        @source_id = Jamf::PatchSource.valid_id(@init_data[:source_id])

        raise Jamf::NoSuchItemError, "No Patch Sources match '#{@init_data[:source]}'" unless source_id

        @name_id = @init_data[:name_id]

        valid_name_id = Jamf::PatchSource.available_name_ids(@source_id).include? @name_id

        raise Jamf::NoSuchItemError, "source #{@init_data[:source]} doesn't offer name_id '#{@init_data[:name_id]}'" unless valid_name_id
      end

      @source_name_id = "#{@source_id}-#{@name_id}"

      @init_data[:notifications] ||= {}
      notifs = @init_data[:notifications]
      @web_notification = notifs[:web_notification].nil? ? false : notifs[:web_notification]
      @email_notification = notifs[:email_notification].nil? ? false : notifs[:email_notification]

      @versions = {}
      @init_data[:versions] ||= []
      @init_data[:versions].each do |vers|
        @versions[vers[:software_version]] = Jamf::PatchTitle::Version.new(self, vers)
      end # each do vers

      @changed_pkgs = []
    end

    # @return [Hash{String => Jamf::PatchTitle::Version}] The Jamf::PatchVersions fetched for
    #   this title, keyed by version string
    def versions
      return @versions unless in_jss
      return @versions unless @versions.empty?

      # if we are in jss, and versions is empty, re-fetch them
      @versions = self.class.fetch(id: id).versions
    end

    # @return [Hash] Subset of @versions, containing those which have packages
    #   assigned
    #
    def versions_with_packages
      versions.select { |_ver_string, vers| vers.package_assigned? }
    end

    # Set email notifications on or off
    #
    # @param new_setting[Boolean] Should email notifications be on or off?
    #
    # @return [void]
    #
    def email_notification=(new_setting)
      return if email_notification == new_setting
      raise Jamf::InvalidDataError, 'New Setting must be boolean true or false' unless Jamf::TRUE_FALSE.include? @email_notification = new_setting

      @need_to_update = true
    end

    # Set web notifications on or off
    #
    # @param new_setting[Boolean] Should email notifications be on or off?
    #
    # @return [void]
    #
    def web_notification=(new_setting)
      return if web_notification == new_setting
      raise Jamf::InvalidDataError, 'New Setting must be boolean true or false' unless Jamf::TRUE_FALSE.include? @web_notification = new_setting

      @need_to_update = true
    end

    # this is called by Jamf::PatchTitle::Version#package= to update @changed_pkgs which
    # is used by #rest_xml to change the package assigned to a patch version
    # in this title.
    def changed_pkg_for_version(version)
      @changed_pkgs << version
      @need_to_update = true
    end

    # wrapper to fetch versions after creating
    def create
      super
    end

    # wrapper to clear @changed_pkgs after updating
    def update
      response = super
      @changed_pkgs.clear
      response
    end

    # Get a patch report for this title.
    #
    # See the class method Jamf::PatchTitle.patch_report
    #
    def patch_report(vers = :all)
      Jamf::PatchTitle.patch_report id, version: vers, cnx: @cnx
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

    # Return the REST XML for this title, with the current values,
    # for saving or updating.
    #
    def rest_xml
      doc = REXML::Document.new # Jamf::Connection::XML_HEADER
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

end # module Jamf
