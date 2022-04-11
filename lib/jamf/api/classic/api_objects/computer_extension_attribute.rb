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

module Jamf

  # Classes
  #####################################

  # The definition of a Computer extension attribute in the JSS
  #
  # @see Jamf::ExtensionAttribute
  #
  # @see Jamf::APIObject
  #
  class ComputerExtensionAttribute < Jamf::ExtensionAttribute

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'computerextensionattributes'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_extension_attributes

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_extension_attribute

    # these ext attribs are related to these kinds of objects
    TARGET_CLASS = Jamf::Computer

    # A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = Jamf::Criteriable::Criterion.new(and_or: 'and', name: 'Username', search_type: 'like', value: '')

    # When the intput type is script, what platforms can they run on?
    PLATFORM_MAC = 'Mac'.freeze
    PLATFORM_WINDOWS = 'Windows'.freeze
    PLATFORMS = [PLATFORM_MAC, PLATFORM_WINDOWS].freeze

    # When the platform is Windows, what languages can be user?
    LANGUAGE_VBS = 'VBScript'.freeze
    LANGUAGE_BAT = 'Batch File'.freeze
    LANGUAGE_PSH = 'PowerShell'.freeze
    WINDOWS_SCRIPTING_LANGUAGES = [LANGUAGE_VBS, LANGUAGE_BAT, LANGUAGE_PSH].freeze

    # Where can it be displayed in the Recon App?
    RECON_DISPLAY_CHOICES = [
      'Computer',
      'User and Location',
      'Purchasing',
      'Extension Attributes'
    ].freeze

    DEFAULT_RECON_DISPLAY_CHOICE = 'Extension Attributes'.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 73

    # Attributes
    ######################

    # @return [String] the script code that will be executed when the @input_type is "script",
    attr_reader :script
    alias code script

    # @return [Boolean] if the input type is 'script', is this EA enabled?
    attr_reader :enabled
    alias enabled? enabled

    # When the  @input_type is "script", The platform on which a script will run.
    #
    # NOTE: The web app seems to let you have both Mac and Windows
    # scripts defined when the type is "script",
    # however the API will only return the Mac script info if both are defined.
    # DEPRECATED: windows EAs are no longer supported
    #
    # @return [String]
    attr_reader :platform

    # The scripting language of the @script when @input_type is "script",
    # and the @platform is "Windows"
    #
    # DEPRECATED: windows EAs are no longer supported
    # @return [String]
    attr_reader :scripting_language

    # DEPRECATED: this is no longer separate from the web_display.
    # @return [String] In which part of the Recon App does the data appear?
    attr_reader :recon_display

    # Public Instance Methods
    #####################################

    # Change the recon_display of this EA
    # DEPRECATED, no longer separate from web_display in jamf pro.
    #
    def recon_display=(new_val)
      return if @recon_display == new_val
      raise Jamf::InvalidDataError, "recon_display must be a string, one of: #{RECON_DISPLAY_CHOICES.join(', ')}" unless RECON_DISPLAY_CHOICES.include? new_val

      @recon_display = new_val
      @need_to_update = true
    end

    # enable this script ea
    #
    # @return [void]
    #
    def enable
      return if enabled?

      @enabled = true
      @need_to_update = true
    end

    # disable this script ea
    #
    # @return [void]
    #
    def disable
      return unless enabled?

      @enabled = false
      @need_to_update = true
    end

    # Change the script of this EA.
    # Setting this automatically sets input_type to script
    #
    # @param new_val[String] the new value
    #
    # @return [void]
    #
    def script=(new_val)
      return if @script == new_val

      Jamf::Validate.non_empty_string new_val

      self.input_type = INPUT_TYPE_SCRIPT
      @script = new_val
      @need_to_update = true
    end
    alias code= script=

    # DEPRECATED: windows EAs are no longer supported
    #
    # Change the platform of this EA.
    # Setting this automatically sets input_type to script
    #
    # @param new_val[String] the new value, which must be a member of PLATFORMS
    #
    # @return [void]
    #
    def platform=(new_val)
      return if @platform == new_val
      raise Jamf::InvalidDataError, "platform must be a string, one of: #{PLATFORMS.join(', ')}" unless PLATFORMS.include? new_val

      self.input_type = INPUT_TYPE_SCRIPT
      @platform = new_val
      @need_to_update = true
    end

    # Change the scripting_language of this EA.
    # Setting this automatically sets input_type to 'script'
    # and the platform to "Windows"
    #
    # DEPRECATED: windows EAs are no longer supported
    #
    # @param new_val[String] the new value, which must be one of {WINDOWS_SCRIPTING_LANGUAGES}
    #
    # @return [void]
    #
    def scripting_language=(new_val)
      return if @scripting_language == new_val
      unless WINDOWS_SCRIPTING_LANGUAGES.include? new_val
        raise Jamf::InvalidDataError, "Scripting language must be a string, one of: #{WINDOWS_SCRIPTING_LANGUAGES.join(', ')}"
      end

      self.input_type = INPUT_TYPE_SCRIPT
      self.platform = 'Windows'
      @scripting_language = new_val
      @need_to_update = true
    end

    # Return an Array of Hashes showing the history of reported values for this EA on one computer.
    #
    # Each hash contains these 2 keys:
    # * :value - String, Integer, or Time, depending on @data_type
    # * :timestamp  - Time
    #
    # This method requires a MySQL database connection established via Jamf::DB_CNX.connect
    #
    # @see Jamf::DBConnection
    #
    # @param computer[Integer,String]  the id or name of the Computer.
    #
    # @return [Array<Hash{:timestamp=>Time,:value=>String,Integer,Time}>]
    #
    def history(computer)
      raise Jamf::NoSuchItemError, "EA Not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise Jamf::InvalidConnectionError, "Database connection required for 'history' query." unless Jamf::DB_CNX.connected?

      computer_id = Jamf::Computer.valid_id computer, api: @api
      raise Jamf::NoSuchItemError, "No computer found matching '#{computer}'" unless computer_id

      the_query = <<-END_Q
      SELECT eav.value_on_client AS value, r.date_entered_epoch AS timestamp_epoch
      FROM extension_attribute_values eav JOIN reports r ON eav.report_id = r.report_id
      WHERE r.computer_id = #{computer_id}
        AND eav.extension_attribute_id = #{@id}
      ORDER BY timestamp_epoch
      END_Q

      qrez = Jamf::DB_CNX.db.query the_query
      history = []

      qrez.each_hash do |entry|
        value =
          case @data_type
          when 'String' then entry['value']
          when 'Integer' then entry['value'].to_i
          when 'Date' then Jamf.parse_time(entry['value'])
          end # case
        newhash = { value: value, timestamp: JSS.epoch_to_time(entry['timestamp_epoch']) }
        history << newhash
      end # each hash

      history
    end # history

  end # class ExtAttrib

end # module
