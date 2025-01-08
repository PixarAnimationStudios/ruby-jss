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
###

###
module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  #
  # A Parent class for Advanced Computer, MobileDevice, and User searchs
  #
  # Subclasses must define:
  # * the constant RESULT_CLASS which is the JSS Module class of
  #   the item returned by the search, e.g. Jamf::Computer
  # * the constant RESULT_ID_FIELDS, which is an Array of Symbols
  #   that come from the API in the search_results along with the
  #   symbolized display fields.
  #   E.g. for AdvancedComputerSearches, :id, :name, and :udid are present along with
  #   whatever display fields have been defined.
  #
  #
  # @see Jamf::AdvancedComputerSearch
  # @see Jamf::AdvancedMobileDeviceSearch
  # @see Jamf::AdvancedUserSearch
  # @see Jamf::APIObject
  #
  class AdvancedSearch < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Criteriable
    include Jamf::Sitable

    # Class Constants
    #####################################

    EXPORT_FORMATS = %i[csv tab xml].freeze

    # Where is site data located in the API JSON?
    SITE_SUBSET = :top

    # Attributes
    #####################################

    #
    # @return [Array<Hash>] the results of the search
    #
    # Each Hash is one object that matches the criteria.
    # Within each hash there are variable keys, but always at least
    # the keys defined in each subclasses RESULT_ID_FIELDS
    #
    # The other keys correspond to the {AdvancedSearch#display_fields} defined for this
    # Advanced Search.
    #
    attr_reader :search_results

    # @return [Array<String>] the fields to be returned with the search results
    #
    # The API delivers these as an array of Hashes,
    # where each hash has only one key, :name => the name of the fields/ExtAttrib
    # to display. It should probably not have the underlying Hashes, and just
    # be an array of names. This class converts it to just an Array of field names
    # (Strings) for internal use.
    #
    # These fields are returned in the @search_results
    # data along with :id, :name, and other unique identifiers
    # for each found item. In that data, their names have colons removed, abd
    # spaces and dashes converted to underscores, and they are
    # symbolized. See attribute result_display_keys
    #
    attr_reader :display_fields

    # @return [Array<Symbol>]
    #
    # The search result Hash keys for the {#display_fields} of the search
    #
    # The field names in {#display_fields} are strings matching how the field is labeled
    # in the web UI (including the names of Extension Attributes). They have to be that way
    # when submitting them to the API, and thats mostly what {#display_fields} and related
    # methods are for.
    #
    # However, when those names come back as the Hash Keys of the {#search_results}
    # they (inconsistently) have spaces and/or dashes converted to underscores,
    # and colons are removed. The JSON module then converts the keys to Symbols,
    # so they don't match the {#display_fields}.
    #
    # For example, the display field "Last Check-in" might come back as any of these Symbols:
    # - :"Last Check-in"
    # - :Last_Check_in
    # - :"Last_Check-in"
    #
    # Also, the data returned in the {#search_results} contains more keys than just the
    # {#display_fields} - namely it comes with some standard identifiers for each found item.
    # such as JSS id number and name.
    #
    # {#result_display_keys} will hold just the Hash keys corresponding to the
    # {#display_fields} by taking the keys from the first result Hash, and removing the
    # identifier keys as listed in each subclass's RESULT_ID_FIELDS constant.
    #
    attr_reader :result_display_keys

    # @return [String] the name of the site for this search
    attr_reader :site

    # @return [String]  the SQL query generated by the JSS based on the critera
    attr_reader :sql_text

    # Constructor
    #####################################

    #
    # @see APIObject#initialize
    #
    def initialize(**args)
      super(**args)

      # @init_data now has the raw data
      # so fill in our attributes or set defaults

      @sql_text = @init_data[:sql_text]
      @site = Jamf::APIObject.get_name(@init_data[:site])

      @display_fields = @init_data[:display_fields] ? @init_data[:display_fields].map { |f| f[:name] } : []

      @search_results = @init_data[self.class::RESULT_CLASS::RSRC_LIST_KEY]
      @search_results ||= []
      @result_display_keys = if @search_results.empty?
                               []
                             else
                               @search_results[0].keys - self.class::RESULT_ID_FIELDS
                             end

      # make sure each hash of the search results
      # has a key matching a standard key.
      #
      # @search_results.each do |hash|
      #   hash.keys.each do |key|
      #     std_key = key.to_s.gsub(':', '').gsub(/ |-/, '_').to_sym
      #     next if hash[std_key]
      #     hash[std_key] = hash[key]
      #   end
      # end
    end # init

    # Public Instance Methods
    #####################################

    # Create in the JSS
    #
    # If get_results is true, they'll be available in {#search_results}. This might be slow.
    #
    # @param get_results[Boolean] should the results of the search be queried immediately?
    #
    # @return [Integer] the id of the newly created search
    #
    def create(get_results = false)
      raise Jamf::InvalidDataError, 'Jamf::Criteriable::Criteria instance required' unless @criteria.is_a? Jamf::Criteriable::Criteria
      raise Jamf::InvalidDataError, 'display_fields must be an Array.' unless @display_fields.is_a? Array

      orig_timeout = @cnx.timeout
      @cnx.timeout = 1800
      super()
      requery_search_results if get_results
      @cnx.timeout = orig_timeout

      @id # remember to return the id
    end

    # Save any changes
    #
    # If get_results is true, they'll be available in {#search_results}. This might be slow.
    #
    # @param get_results[Boolean] should the results of the search be queried immediately?
    #
    # @return [Integer] the id of the updated search
    #
    def update(get_results = false)
      orig_timeout = @cnx.timeout
      @cnx.timeout = 1800
      super()
      requery_search_results if get_results
      @cnx.timeout = orig_timeout

      @id # remember to return the id
    end

    # Wrapper/alias for both create and update
    def save(get_results = false)
      if @in_jss
        raise Jamf::UnsupportedError, 'Updating this object in the JSS is currently not supported by ruby-jss' unless updatable?

        update get_results
      else
        raise Jamf::UnsupportedError, 'Creating this object in the JSS is currently not supported by ruby-jss' unless creatable?

        create get_results
      end
    end

    # Requery the API for the search results.
    #
    # This can be very slow, so temporarily reset the API timeout to 30 minutes
    #
    # @return [Array<Hash>] the new search results
    #
    def requery_search_results
      orig_open_timeout = @cnx.open_timeout
      orig_timeout = @cnx.timeout
      @cnx.timeout = 1800
      @cnx.open_timeout = 1800
      begin
        requery = self.class.fetch(id: @id)
        @search_results = requery.search_results
        @result_display_keys = requery.result_display_keys
      ensure
        @cnx.timeout = orig_timeout
        @cnx.open_timeout = orig_open_timeout
      end
    end

    # Set the list of fields to be retrieved with the
    # search results.
    #
    # @param new_val[Array<String>] the new field names
    #
    def display_fields=(new_val)
      raise Jamf::InvalidDataError, 'display_fields must be an Array.' unless new_val.is_a? Array
      return if new_val.sort == @display_fields.sort

      @display_fields = new_val
      @need_to_update = true
    end

    # @return [Integer] the number of items found by the search
    #
    def count
      @search_results.count
    end

    # Export the display fields of the search results to a file.
    #
    # @param output_file[String,Pathname] The file in which to store the exported results
    #
    # @param format[Symbol] one of :csv, :tab, or :xml, defaults to :csv
    #
    # @param overwrite[Boolean] should the output_file be overwrite if it exists? Defaults to false
    #
    # @return [Pathname] the path to the output file
    #
    # @note This method only exports the display fields defined in this advanced search for
    # the search_result members (computers, mobile_devices, or users)
    # It doesn't currently provide the ability to export subsets of info about those objects, as the
    # Web UI does (e.g. group memberships, applications, receipts, etc)
    #
    def export(output_file, format = :csv, overwrite = false)
      raise Jamf::InvalidDataError, "Export format must be one of: :#{EXPORT_FORMATS.join ', :'}" unless EXPORT_FORMATS.include? format

      out = Pathname.new output_file

      raise Jamf::AlreadyExistsError, "The output file already exists: #{out}" if !overwrite && out.exist?

      case format
      when :csv
        require 'csv'
        CSV.open(out.to_s, 'wb') do |csv|
          csv << @result_display_keys
          @search_results.each do |row|
            csv << @result_display_keys.map { |key| row[key] }
          end # each do row
        end # CSV.open

      when :tab
        tabbed = @result_display_keys.join("\t") + "\n"
        @search_results.each do |row|
          tabbed << @result_display_keys.map { |key| row[key] }.join("\t") + "\n"
        end # each do row
        out.jss_save tabbed.chomp

      else # :xml
        doc = REXML::Document.new '<?xml version="1.0" encoding="ISO-8859-1"?>'
        members = doc.add_element self.class::RESULT_CLASS::RSRC_LIST_KEY.to_s
        @search_results.each do |row|
          member = members.add_element self.class::RESULT_CLASS::RSRC_OBJECT_KEY.to_s
          @result_display_keys.each do |field|
            member.add_element(field.to_s.tr(' ', '_')).text = row[field].empty? ? nil : row[field]
          end # ech do field
        end # each do row
        out.jss_save doc.to_s.gsub('><', ">\n<")
      end # case

      out
    end

    # Private Instance Methods
    #####################################
    private

    # Clean up the inconsistent "Display Field" keys in the search results.
    #
    # Sometimes spaces have been converted to underscores, sometimes not, sometimes both.
    # Same for dashes.
    # E.g  :"Last Check-in"/:Last_Check_in/:"Last_Check-in", :Computer_Name, and :"Display Name"/:Display_Name
    #
    # This ensures there's always the fully underscored version.
    #
    # Update an internally used array of the display field names, symbolized, with
    # spaces and dashes converted to underscores. We use these
    # to overcome inconsistencies in how the names come from the API
    #
    # @return [void]
    #
    # def standardize_display_field_keys
    #   spdash =
    #     us =
    #       @display_field_std_keys = @display_fields.map { |f| f.gsub(/ |-/, '_').to_sym }
    # end

    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      acs = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      acs.add_element('name').text = @name
      acs.add_element('sort_1').text = @sort_1 if @sort_1
      acs.add_element('sort_2').text = @sort_2 if @sort_2
      acs.add_element('sort_3').text = @sort_3 if @sort_3

      acs << @criteria.rest_xml

      df = acs.add_element('display_fields')
      @display_fields.each { |f| df.add_element('display_field').add_element('name').text = f }
      add_site_to_xml(doc)
      doc.to_s
    end # rest xml

  end # class AdvancedSearch

end # module Jamf
