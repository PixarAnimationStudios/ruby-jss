# Copyright 2020 Pixar

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
  #####################################


  # An extension attribute as defined in the JSS
  #
  # @see JSS::ExtensionAttribute
  #
  # @see JSS::APIObject
  #
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'mobiledeviceextensionattributes'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_extension_attributes

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_extension_attribute

    # these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::MobileDevice

    # A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = JSS::Criteriable::Criterion.new(and_or: 'and', name: 'Last Inventory Update', search_type: 'after (yyyy-mm-dd)', value: '2003-01-01')

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 86

    # Public Instance Methods
    #####################################

    # @see JSS::ExtensionAttribute#web_display=
    #
    def web_display=(new_val)
      raise JSS::InvalidDataError, "Mobile Device Extension Attributes web_display cannot be '#{WEB_DISPLAY_CHOICE_OS}'" if new_val == WEB_DISPLAY_CHOICE_OS

      super
    end # end web_display

    # @see JSS::ExtensionAttribute#input_type=
    #
    def input_type=(new_val)
      raise JSS::InvalidDataError, "Mobile Device Extension Attribute input_type cannot be '#{INPUT_TYPE_SCRIPT}'" if new_val == INPUT_TYPE_SCRIPT

      super
    end # end input_type

    # Return an Array of Hashes showing the history of reported values for this EA on one MobileDevice.
    #
    # Each hash contains these 2 keys:
    # * :value - String, Integer, or Time, depending on @data_type
    # * :timestamp - Time
    #
    # This method requires a MySQL database connection established via JSS::DB_CNX.connect
    #
    # @see JSS::DBConnection
    #
    # @param mobiledevice[Integer,String] the id or name of the MobileDevice.
    #
    # @return [Array<Hash{:timestamp=>Time,:value=>String,Integer,Time}>]
    #
    def history(mobiledevice)
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidConnectionError, "Database connection required for 'history' query." unless JSS::DB_CNX.connected?

      mobile_device_id = JSS::MobileDevice.valid_id mobiledevice, api: @api
      raise JSS::NoSuchItemError, "No MobileDevice found matching '#{mobiledevice}'" unless mobile_device_id

      the_query = <<-END_Q
      SELECT eav.value_on_client AS value, r.date_entered_epoch AS timestamp_epoch
      FROM mobile_device_extension_attribute_values eav JOIN reports r ON eav.report_id = r.report_id
      WHERE r.mobile_device_id = #{mobile_device_id}
        AND eav.mobile_device_extension_attribute_id = #{@id}
      ORDER BY timestamp_epoch
      END_Q

      qrez = JSS::DB_CNX.db.query the_query
      history = []
      qrez.each_hash do |entry|
        value =
          case @data_type
          when 'String' then entry['value']
          when 'Integer' then entry['value'].to_i
          when 'Date' then JSS.parse_datetime(entry['value'])
          end # case
        newhash = { value: value, timestamp: JSS.epoch_to_time(entry['timestamp_epoch']) }
        history << newhash
      end # each hash

      history
    end # history

  end # class ExtAttrib

end # module
