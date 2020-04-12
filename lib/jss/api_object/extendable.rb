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
#
#

#
module JSS

  # Sub-Modules
  ###################################

  # A mix-in module for handling extension attribute data for objects in the JSS.
  #
  # This module provides standardized ways to deal with Extension Attribute data
  # in objects that gather that data  ({JSS::Computer}s, {JSS::MobileDevice}s,
  # and {JSS::User}s). For working with the Extension Attributes themselves, see
  # {JSS::ExtensionAttribute} and its subclasses.
  #
  # API objects that have Extension Attribute data return it in an Array of Hashes,
  # one for each defined ExtensionAttribute for the class;
  # i.e. a {JSS::Computer}'s Array has one Hash for each {JSS::ComputerExtensionAttribute}
  # defined in the JSS.
  #
  # The Hash keys are:
  # * :id => the ExtAttr id
  # * :name => the ExtAttr name
  # * :type => the data type of the ExtAttr value
  # * :value => the value for the ExtAttr for this object as of the last report.
  #
  # Classes including this module must define the constant EXT_ATTRIB_CLASS
  # specifying which {JSS::ExtensionAttribute} subclass defines the relevant extension attributes.
  # For Example, {JSS::Computer} sets this:
  #   EXT_ATTRIB_CLASS = JSS::ComputerExtensionAttribute
  #
  #
  # Parsing also populates @ext_attrs which is a Hash of name => value for each EA.
  #
  # When updating or creating, those classes must add the REXML output of {#ext_attr_xml} to their
  # rest_xml output.
  #
  module Extendable

    #  Constants
    ###################################

    EXTENDABLE = true

    INVALID_DATE = '-- INVALIDLY FORMATTED DATE --'.freeze

    #  Attribtues
    ###################################

    # @return [Array<Hash>] The extension attribute values for the object
    attr_reader :extension_attributes

    #  Mixed-in Instance Methods
    ###################################

    # Populate @extension_attributes (the Array of Hashes that comes from the API)
    # and @ext_attr_names, which is a Hash mapping the EA names to their
    # values. This is called during initialization for all objects
    # that mix in this module
    #
    # @return [void]
    #
    def parse_ext_attrs
      @extension_attributes = @init_data[:extension_attributes]
      @extension_attributes ||= []

      # remember changes as they happen so
      # we only send changes back to the server.
      @changed_eas = []
    end

    # @return [Array<String>] the names of all known EAs
    #
    def ea_names
      ea_types.keys
    end

    # @return [Hash{String => String}] EA names => data type
    #   (one of 'String', 'Number', or 'Date')
    def ea_types
      return @ea_types if @ea_types

      @ea_types = {}
      extension_attributes.each { |ea| @ea_types[ea[:name]] = ea[:type] }
      @ea_types
    end

    # An easier-to-use hash of EA name to EA value.
    # This isn't created until its needed, to speed up instantiation.
    #
    def ext_attrs
      return @ext_attrs if @ext_attrs

      @ext_attrs = {}
      @extension_attributes.each do |ea|
        @ext_attrs[ea[:name]] =
          case ea[:type]

          when 'Date'
            begin # if there's random non-date data, the parse will fail
              JSS.parse_datetime ea[:value]
            rescue
              INVALID_DATE
            end

          when *JSS::ExtensionAttribute::NUMERIC_TYPES
            ea[:value].to_i unless ea[:value].to_s.empty?

          else # String
            ea[:value]
          end # case
      end # each do ea

      @ext_attrs
    end

    # Set the value of an extension attribute
    #
    # The new value is validated based on the data type of the
    # Ext. Attrib:
    #
    # - If the ext. attrib. is defined with a data type of Integer/Number, the
    #   value must be an Integer.
    # - If defined with a data type of Date, the value will be parsed as a
    #   timestamp, and parsing may raise an exception. Dates can't be blank.
    # - If defined wth data type of String, `to_s` will be called on the value.
    #
    # By default, the full EA definition object is fetched to see if the EA's
    # input type is 'popup menu', and if so, the new value must be one of the
    # defined popup choices, or blank.
    #
    # The EA definitions used for popup validation are cached, so we don't have
    # to reach out to the server every time. If you expect the definition to
    # have changed since it was cached, provide a truthy value to the refresh:
    # parameter
    #
    # To bypass popup validation complepletely, provide a falsey value to the
    # validate_popup_choice: parameter.
    # WARNING: beware that your value is the correct type and format, or you might
    # get errors when saving back to the API.
    #
    # Note that while the Jamf Pro Web interface does not allow editing the
    # values of Extension Attributes populated by Scripts or LDAP,  the API does
    # allow it. Bear in mind however that those values will be reset again at
    # the next recon.
    #
    # @param name[String] the name of the extension attribute to set
    #
    # @param value[String,Time,Integer] the new value for the extension
    #   attribute for this user
    #
    # @param validate_popup_choice[Boolean] validate the new value against the E.A. definition.
    #   Defaults to true.
    #
    # @param refresh[Boolean] Re-read the ext. attrib definition from the API,
    #   for popup validation.
    #
    # @return [void]
    #
    def set_ext_attr(name, value, validate_popup_choice: true, refresh: false)
      raise ArgumentError, "Unknown Extension Attribute Name: '#{name}'" unless ea_types.key? name

      value ||= JSS::BLANK
      validate_popup_value(name, value, refresh) if validate_popup_choice

      value =
        case ea_types[name]
        when JSS::ExtensionAttribute::DATA_TYPE_DATE # date
          JSS.parse_datetime(value).to_s
        when *JSS::ExtensionAttribute::NUMERIC_TYPES # integer
          if value.is_a?(Intger)
            value
          elsif value.to_s.jss_integer?
            value.to_s.to_i
          else
            raise JSS::InvalidDataError, "The value for #{name} must be an integer"
          end # if
        else # string
          value.to_s
        end # case

      # update this ea hash in the @extension_attributes array
      @extension_attributes.each { |ea| ea[:value] = value if ea[:name] == name }

      # update the shortcut hash too
      @ext_attrs[name] = value if @ext_attrs
      @changed_eas << name
      @need_to_update = true
    end

    # are there any changes in the EAs needing to be saved?
    #
    # @return [Boolean]
    #
    def unsaved_eas?
      @need_to_update && @changed_eas && !@changed_eas.empty?
    end

    # @api private
    #
    # TODO: make this (and all XML amending) method take the in-progress XML doc and
    # add (or not) the EA xml to it.
    # See how Sitable#add_site_to_xml works, as called from
    # Computer.rest_xml
    #
    # @return [REXML::Element] An <extension_attribute> element to be
    #  included in the rest_xml of objects that mix-in this module.
    #
    def ext_attr_xml
      @changed_eas ||= []
      eaxml = REXML::Element.new('extension_attributes')
      @extension_attributes.each do |ea|
        next unless @changed_eas.include? ea[:name]
        ea_el = eaxml.add_element('extension_attribute')
        ea_el.add_element('name').text = ea[:name]

        if ea[:type] == 'Date'
          begin
            ea_el.add_element('value').text = ea[:value].to_jss_date
          rescue
            ea_el.add_element('value').text = ea[:value].to_s
          end
        else
          ea_el.add_element('value').text = ea[:value].to_s
        end # if
      end # each do ea

      eaxml
    end

    # Used by set_ext_attr
    def validate_popup_value(name, value, refresh)
      # all popups can take blanks
      return if value == JSS::BLANK

      # get the ea def. instance from the api cache, or the api
      api.ext_attr_definition_cache[self.class] ||= {}
      api.ext_attr_definition_cache[self.class][name] = nil if refresh
      api.ext_attr_definition_cache[self.class][name] ||= self.class::EXT_ATTRIB_CLASS.fetch name: name, api: api

      ea_def = api.ext_attr_definition_cache[self.class][name]
      return unless ea_def.from_popup_menu?

      return if ea_def.popup_choices.include? value.to_s

      raise JSS::UnsupportedError, "The value for #{name} must be one of: '#{ea_def.popup_choices.join("' '")}'"
    end

  end # module extendable

end # module JSS
