# Copyright 2020 Pixar

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

module JSS

  # Classes
  ###################################

  # The parent class of ExtensionAttribute objects in the JSS.
  #
  # The API extension attribute objects work with the definitions of extension
  # attributes, not the resulting values stored in the JSS with the inventory
  # reports.
  #
  # This superclass, however, uses the {AdvancedSearch} subclasses to provide
  # access to the reported values in two ways:
  # * A list of  target objects with a certain value for the ExtensionAttribute instance.
  #   See the {#all_with_result} method for details
  # * A list of the most recent value for this ExtensionAttribute in all targets in the JSS
  #
  # The {ComputerExtensionAttribute} subclass offers a {ComputerExtensionAttribute#history}
  # method providing the history of values for the EA for one computer. This requires
  # MySQL access to the JSS database since that history isn't available via the API.
  #
  # Subclasses of ExtensionAttribute must define these constants:
  # * TARGET_CLASS - the {APIObject} subclass to which the extention attribute applies.
  #   e.g. {JSS::Computer}
  #
  # * ALL_TARGETS_CRITERION - a {JSS::Criteriable::Criterion} instance that will be used in
  #   an {AdvancedSearch} to find all of members of the TARGET_CLASS
  #
  # @see JSS::APIObject
  #
  class ExtensionAttribute < JSS::APIObject

    # Mix-Ins
    ###################################
    include JSS::Creatable
    include JSS::Updatable

    # Class Constants
    ###################################

    # What kinds of data can be created by EAs?
    # Note, Dates must be in the format "YYYY-MM-DD hh:mm:ss"

    DATA_TYPE_STRING = 'String'.freeze
    DATA_TYPE_NUMBER = 'Number'.freeze
    DATA_TYPE_INTEGER = 'Integer'.freeze
    DATA_TYPE_DATE = 'Date'.freeze

    DATA_TYPES = [DATA_TYPE_STRING, DATA_TYPE_DATE, DATA_TYPE_INTEGER].freeze

    DEFAULT_DATA_TYPE = DATA_TYPE_STRING

    # ExtensionAttributes refer to the numeric data type as "Integer"
    # but the ext. attr values that come with extendable objects refer to
    # that data type as "Number".  Here's an array with both, so we can
    # work with ether more easily.
    NUMERIC_TYPES = [DATA_TYPE_NUMBER, DATA_TYPE_INTEGER].freeze

    # Where does the data come from?

    INPUT_TYPE_FIELD = 'Text Field'.freeze
    INPUT_TYPE_POPUP = 'Pop-up Menu'.freeze
    INPUT_TYPE_SCRIPT = 'script'.freeze
    INPUT_TYPE_LDAP = 'LDAP Attribute Mapping'.freeze

    INPUT_TYPES = [
      INPUT_TYPE_FIELD,
      INPUT_TYPE_POPUP,
      INPUT_TYPE_SCRIPT,
      INPUT_TYPE_LDAP
    ].freeze

    DEFAULT_INPUT_TYPE = INPUT_TYPE_FIELD

    # Where can it be displayed in the WebApp?
    WEB_DISPLAY_CHOICE_GENERAL = 'General'.freeze
    WEB_DISPLAY_CHOICE_OS = 'Operating System'.freeze
    WEB_DISPLAY_CHOICE_HW = 'Hardware'.freeze
    WEB_DISPLAY_CHOICE_USER_LOC = 'User and Location'.freeze
    WEB_DISPLAY_CHOICE_PURCHASING = 'Purchasing'.freeze
    WEB_DISPLAY_CHOICE_EAS = 'Extension Attributes'.freeze

    WEB_DISPLAY_CHOICES = [
      WEB_DISPLAY_CHOICE_GENERAL,
      WEB_DISPLAY_CHOICE_OS,
      WEB_DISPLAY_CHOICE_HW,
      WEB_DISPLAY_CHOICE_USER_LOC,
      WEB_DISPLAY_CHOICE_PURCHASING,
      WEB_DISPLAY_CHOICE_EAS
    ].freeze

    DEFAULT_WEB_DISPLAY_CHOICE = WEB_DISPLAY_CHOICE_EAS

    LAST_RECON_FIELD = 'Last Inventory Update'.freeze
    LAST_RECON_FIELD_SYM = LAST_RECON_FIELD.tr(' ', '_').to_sym

    USERNAME_FIELD = 'Username'.freeze
    USERNAME_FIELD_SYM = USERNAME_FIELD.to_sym

    # Attributes
    ####################

    # :id, :name, :in_jss, :need_to_update, and :rest_rsrc come from JSS::APIObject

    # @return [String] description of the ext attrib
    attr_reader :description
    alias desc description

    # @return [String] the type of data created by the EA. Must be one of DATA_TYPES
    attr_reader :data_type

    # @return [String]  where does this data come from? Must be one of the INPUT_TYPES.
    attr_reader :input_type

    # @return [Array<String>] the choices available in the UI when the @input_type is "Pop-up Menu"
    attr_reader :popup_choices

    # @return [String] the LDAP attribute for the User's ldap entry that maps to this EA, when input type is INPUT_TYPE_LDAP
    attr_reader :attribute_mapping

    # @return [String] In which part of the web UI does the data appear?
    attr_reader :web_display

    # Constructor
    ###################################

    # @see JSS::APIObject#initialize
    #
    def initialize(args = {})
      super args

      # @init_data now has the raw data
      # so fill in our attributes or set defaults
      @description = @init_data[:description]
      @data_type = @init_data[:data_type] || DEFAULT_DATA_TYPE

      if @init_data[:input_type]
        @input_type = @init_data[:input_type][:type]

        @script = @init_data[:input_type][:script]

        @attribute_mapping = @init_data[:input_type][:attribute_mapping]
        @popup_choices = @init_data[:input_type][:popup_choices]
        # popups can always contain blank
        @popup_choices << JSS::BLANK if @popup_choices

        # These two are deprecated - windows won't be supported for long
        @platform = @init_data[:input_type][:platform]
        @scripting_language = @init_data[:input_type][:scripting_language]
      end
      @input_type ||= DEFAULT_INPUT_TYPE

      @enabled = @init_data[:enabled]

      @web_display = @init_data[:inventory_display] || DEFAULT_WEB_DISPLAY_CHOICE
      # deprecated - no longer in the UI
      @recon_display = @init_data[:recon_display] || @web_display

      # When used in Advanced Search results, the EA name
      # has colons removed, spaces & dashes turned to underscores.
      # and then ruby-jss symbolizes the name.
      @symbolized_name = @name.gsub(':', '').gsub(/-| /, '_').to_sym
    end # init

    # Public Instance Methods
    ###################################

    # @see JSS::Creatable#create
    #
    def create
      validate_for_save
      super
    end

    # @see JSS::Updatable#update
    #
    def update
      validate_for_save
      super
      # this flushes the cached EA itself, used for validating ea values.
      @api.flushcache self.class
    end

    # @see JSS::APIObject#delete
    #
    def delete
      orig_open_timeout = @api.cnx.options[:open_timeout]
      orig_timeout = @api.cnx.options[:timeout]
      @api.timeout = orig_timeout + 1800
      @api.open_timeout = orig_open_timeout + 1800
      begin
        super
        @api.flushcache self.class
      ensure
        @api.timeout = orig_timeout
        @api.open_timeout = orig_open_timeout
      end
    end

    def from_text_field?
      @input_type == INPUT_TYPE_FIELD
    end

    def from_popup_menu?
      @input_type == INPUT_TYPE_POPUP
    end

    def from_ldap?
      @input_type == INPUT_TYPE_LDAP
    end

    def from_script?
      @input_type == INPUT_TYPE_SCRIPT
    end

    # Change the description of this EA
    #
    # @param new_val[String] the new value
    #
    # @return [void]
    #
    def description=(new_val)
      new_val = new_val.to_s
      return if @description == new_val

      @description = new_val
      @need_to_update = true
    end # name=(newname)

    # Change the data type of this EA
    #
    # @param new_val[String] the new value, which must be a member of DATA_TYPES
    #
    # @return [void]
    #
    def data_type=(new_val)
      return if @data_type == new_val
      raise JSS::InvalidDataError, "data_type must be a string, one of: '#{DATA_TYPES.join("', '")}'" unless DATA_TYPES.include? new_val

      @data_type = new_val
      @need_to_update = true
    end

    # Change the inventory_display of this EA
    #
    # @param new_val[String] the new value, which must be a member of WEB_DISPLAY_CHOICES
    #
    # @return [void]
    #
    def web_display=(new_val)
      return if @web_display == new_val
      unless WEB_DISPLAY_CHOICES.include? new_val
        raise JSS::InvalidDataError, "inventory_display must be a string, one of: #{WEB_DISPLAY_CHOICES.join(', ')}"
      end

      @web_display = new_val
      @need_to_update = true
    end

    # Change the input type of this EA
    #
    # @param new_val[String] the new value, which must be a member of INPUT_TYPES
    #
    # @return [void]
    #
    def input_type=(new_val)
      return if @input_type == new_val
      raise JSS::InvalidDataError, "input_type must be a string, one of: #{INPUT_TYPES.join(', ')}" unless INPUT_TYPES.include? new_val

      @input_type = new_val
      case @input_type
      when INPUT_TYPE_FIELD
        @script = nil
        @scripting_language = nil
        @platform = nil
        @popup_choices = nil
        @attribute_mapping = nil
      when INPUT_TYPE_POPUP
        @script = nil
        @scripting_language = nil
        @platform = nil
        @attribute_mapping = nil
      when INPUT_TYPE_SCRIPT
        @popup_choices = nil
        @attribute_mapping = nil
      when INPUT_TYPE_LDAP
        @script = nil
        @scripting_language = nil
        @platform = nil
        @popup_choices = nil
      end # case

      @need_to_update = true
    end

    # Change the Popup Choices of this EA
    # New value must be an Array, the items will be converted to Strings.
    #
    # This automatically sets input_type to INPUT_TYPE_POPUP
    #
    # Values are checked to ensure they match the @data_type
    # Note, Dates must be in the format "YYYY-MM-DD hh:mm:ss"
    #
    # @param new_val[Array<#to_s>] the new values
    #
    # @return [void]
    #
    def popup_choices=(new_val)
      return if @popup_choices == new_val
      raise JSS::InvalidDataError, 'popup_choices must be an Array' unless new_val.is_a?(Array)

      # convert each one to a String,
      # and check that it matches the @data_type
      new_val.map! do |v|
        v = v.to_s.strip
        case @data_type
        when DATA_TYPE_DATE
          raise JSS::InvalidDataError, "data_type is Date, but '#{v}' is not formatted 'YYYY-MM-DD hh:mm:ss'" unless v =~ /^\d{4}(-\d\d){2} (\d\d:){2}\d\d$/
        when 'Integer'
          raise JSS::InvalidDataError, "data_type is Integer, but '#{v}' is not one" unless v =~ /^\d+$/
        end
        v
      end

      self.input_type = INPUT_TYPE_POPUP
      @popup_choices = new_val
      @need_to_update = true
    end

    # Change the LDAP Attribute Mapping of this EA
    # New value must be a String, or respond correctly to #to_s
    #
    # This automatically sets input_type to INPUT_TYPE_LDAP
    #
    # @param new_val[String, #to_s] the new value
    #
    # @return [void]
    #
    def attribute_mapping=(new_mapping)
      new_mapping = JSS::Validate.non_empty_string new_mapping.to_s
      return if new_mapping == @attribute_mapping

      self.input_type = INPUT_TYPE_LDAP
      @attribute_mapping = new_mapping
      @need_to_update = true
    end

    # Get an Array of Hashes for all inventory objects
    # with a desired result in their latest report for this EA.
    #
    # Each Hash is one inventory object (computer, mobile device, user), with these keys:
    #   :id - the computer id
    #   :name - the computer name
    #   :value - the matching ext attr value for the objects latest report.
    #
    # This is done by creating a temprary {AdvancedSearch} for objects with matching
    # values in the EA field, then getting the #search_results hash from it.
    #
    # The AdvancedSearch is then deleted.
    #
    # @param search_type[String] how are we comparing the stored value with the desired value.
    # must be a member of JSS::Criterion::SEARCH_TYPES
    #
    # @param desired_value[String] the value to compare with the stored value to determine a match.
    #
    # @return [Array<Hash{:id=>Integer,:name=>String,:value=>String,Integer,Time}>] the items that match the result.
    #
    def all_with_result(search_type, desired_value)
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{self.class::RSRC_OBJECT_KEY}." unless @in_jss
      unless JSS::Criteriable::Criterion::SEARCH_TYPES.include? search_type.to_s
        raise JSS::InvalidDataError, 'Invalid search_type, see JSS::Criteriable::Criterion::SEARCH_TYPES'
      end

      begin
        search_class = self.class::TARGET_CLASS::SEARCH_CLASS
        acs = search_class.make api: @api, name: "ruby-jss-EA-result-search-#{Time.now.to_jss_epoch}"
        acs.display_fields = [@name]
        crit_list = [JSS::Criteriable::Criterion.new(and_or: 'and', name: @name, search_type: search_type.to_s, value: desired_value)]
        acs.criteria = JSS::Criteriable::Criteria.new crit_list

        acs.create :get_results

        results = []

        acs.search_results.each do |i|
          value =
            case @data_type
            when 'Date' then JSS.parse_datetime i[@symbolized_name]
            when 'Integer' then i[@symbolized_name].to_i
            else i[@symbolized_name]
            end # case
          results << { id: i[:id], name: i[:name], value: value }
        end # each
      ensure
        acs.delete if acs.is_a? self.class::TARGET_CLASS::SEARCH_CLASS
      end
      results
    end # Return an Array of Hashes showing the most recent value

    # for this EA on all inventory objects in the JSS.
    #
    # Each Hash is one inventory object (computer, mobile device, user), with these keys:
    #   :id - the jss id
    #   :name - the object (computer, user, mobiledevice) name
    #   :value - the most recent ext attr value for the object.
    #   :as_of - the timestamp of when the value was collected (nil for User EAs, or for devices that have never collected inventory)
    #   :username - the username associated with the object
    #
    # This is done by creating a temporary {AdvancedSearch}
    # for all objects, with the EA as a display field. The #search_result
    # then contains the desired data.
    #
    # The AdvancedSearch is then deleted.
    #
    # @return [Array<Hash{:id=>Integer,:name=>String,:value=>String,Integer,Time,:as_of=>Time}>]
    #
    # @see JSS::AdvancedSearch
    #
    # @see JSS::AdvancedComputerSearch
    #
    # @see JSS::AdvancedMobileDeviceSearch
    #
    # @see JSS::AdvancedUserSearch
    #
    def latest_values
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{self.class::RSRC_OBJECT_KEY}." unless @in_jss

      tmp_advsrch = "ruby-jss-EA-latest-search-#{Time.now.to_jss_epoch}"

      begin
        search_class = self.class::TARGET_CLASS::SEARCH_CLASS
        acs = search_class.make name: tmp_advsrch, api: @api
        acs.display_fields = self.class::TARGET_CLASS == JSS::User ? [@name, USERNAME_FIELD] : [@name, USERNAME_FIELD, LAST_RECON_FIELD]

        # search for 'Username like "" ' because all searchable object classes have a "Username" value
        crit = JSS::Criteriable::Criterion.new(and_or: 'and', name: 'Username', search_type: 'like', value: '')
        # crit = self.class::ALL_TARGETS_CRITERION
        acs.criteria = JSS::Criteriable::Criteria.new [crit]
        acs.create :get_results

        results = []

        acs.search_results.each do |i|
          value =
            case @data_type
            when 'Date' then JSS.parse_datetime i[@symbolized_name]
            when 'Integer' then i[@symbolized_name].to_i
            else i[@symbolized_name]
            end # case

          as_of = Time.parse(i[LAST_RECON_FIELD_SYM]) if i[LAST_RECON_FIELD_SYM] != ''

          results << { id: i[:id], name: i[:name], username: i[USERNAME_FIELD_SYM], value: value, as_of: as_of }
        end # acs.search_results.each
      ensure
        if defined? acs
          acs.delete if acs
        elsif search_class.all_names(:refresh, api: @api).include? tmp_advsrch
          search_class.fetch(name: tmp_advsrch, api: @api).delete
        end
      end

      results
    end

    # Private Instance Methods
    ###################

    private

    # make sure things are OK for saving to Jamf
    def validate_for_save
      case @input_type
      when INPUT_TYPE_POPUP
        raise MissingDataError, "No popup_choices set for input type: #{INPUT_TYPE_POPUP}" unless @popup_choices.is_a?(Array) && !@popup_choices.empty?
      when INPUT_TYPE_LDAP
        raise MissingDataError, "No attribute_mapping set for input type: #{INPUT_TYPE_LDAP}" if @attribute_mapping.to_s.empty?
      when INPUT_TYPE_SCRIPT
        raise MissingDataError, "No script set for input_type: #{INPUT_TYPE_SCRIPT}" unless @script

        # Next two lines DEPRECATED
        @platform ||= 'Mac'
        raise MissingDataError, "No scripting_language set for Windows '#{INPUT_TYPE_SCRIPT}' input_type." if @platform == 'Windows' && !@scripting_language
      end
    end

    # Return a REXML doc string for this ext attr, with the current values.
    def rest_xml
      ea = REXML::Element.new self.class::RSRC_OBJECT_KEY.to_s
      ea.add_element('name').text = @name
      ea.add_element('description').text = @description if @description
      ea.add_element('data_type').text = @data_type

      unless self.class == JSS::UserExtensionAttribute
        ea.add_element('inventory_display').text = @web_display if @web_display
        ea.add_element('recon_display').text = @recon_display if @recon_display
      end

      it = ea.add_element('input_type')
      it.add_element('type').text = @input_type

      case @input_type
      when INPUT_TYPE_POPUP
        pcs = it.add_element('popup_choices')
        @popup_choices.each { |pc| pcs.add_element('choice').text = pc } if @popup_choices.is_a? Array
      when INPUT_TYPE_LDAP
        it.add_element('attribute_mapping').text = @attribute_mapping
      when INPUT_TYPE_SCRIPT
        ea.add_element('enabled').text = @enabled ? 'true' : 'false'
        it.add_element('script').text = @script
        it.add_element('platform').text = @platform || 'Mac'
        it.add_element('scripting_language').text = @scripting_language if @scripting_language
      end

      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << ea
      doc.to_s
    end # rest xml

  end # class ExtAttrib

end # module JSS

require 'jss/api_object/extension_attribute/computer_extension_attribute'
require 'jss/api_object/extension_attribute/mobile_device_extension_attribute'
require 'jss/api_object/extension_attribute/user_extension_attribute'
