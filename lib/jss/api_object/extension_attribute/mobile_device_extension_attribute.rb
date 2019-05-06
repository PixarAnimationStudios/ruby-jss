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

  #####################################
  ### Constants
  #####################################

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  ####################################
  ### Classes
  #####################################

  ###
  ### An extension attribute as defined in the JSS
  ###
  ### @see JSS::ExtensionAttribute
  ###
  ### @see JSS::APIObject
  ###
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'mobiledeviceextensionattributes'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_extension_attributes

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_extension_attribute

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = %i[description inventory_display recon_display].freeze

    ### these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::MobileDevice

    ### A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = JSS::Criteriable::Criterion.new(and_or: 'and', name: 'Last Inventory Update', search_type: 'after (yyyy-mm-dd)', value: '2003-01-01')

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 86

    ######################
    ### Attributes
    ######################

    ### @return [String] the name of the LDAP attribute to use when the @input Type is "LDAP Attribute Mapping"
    attr_reader :attribute_mapping

    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject.initialize
    ###
    def initialize(args = {})
      super args
      @attribute_mapping = @init_data[:input_type][:attribute_mapping] if @init_data[:input_type]
    end # init

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### @see JSS::Creatable#create
    ###
    def create
      if @input_type == 'LDAP Attribute Mapping'
        raise MissingDataError, "No attribute_mapping defined for 'LDAP Attribute Mapping' input_type." unless @attribute_mapping
      end
      super
    end

    ###
    ### @see JSS::ExtensionAttribute#web_display=
    ###
    def web_display= (new_val)
      raise JSS::InvalidDataError, "web_display cannot be 'Operating System' for Mobile Device Extension Attributes." if new_val == 'Operating System'
      super
    end # end web_display


    ###
    ### @see JSS::ExtensionAttribute#input_type=
    ###
    def input_type= (new_val)
      raise JSS::InvalidDataError, "Mobile Device Extension Attribute input_type cannot be 'script'" if new_val == 'script'

      super

      if @input_type == 'LDAP Attribute Mapping'
        @popup_choices = nil
      else
        @attribute_mapping = nil
      end
    end # end input_type

    ###
    ### Set the ldap attribute to use for input_type 'LDAP Attribute Mapping'
    ###
    ### @param ldap_attrib[String] the attribute to use
    ###
    ### @return [void]
    ###
    def attribute_mapping= (ldap_attrib)
      return nil if ldap_attrib == @attribute_mapping
      @attribute_mapping = ldap_attrib
      @need_to_update = true
    end

    ### Return an Array of Hashes showing the history of reported values for this EA on one MobileDevice.
    ###
    ### Each hash contains these 2 keys:
    ### * :value - String, Integer, or Time, depending on @data_type
    ### * :timestamp - Time
    ###
    ### This method requires a MySQL database connection established via JSS::DB_CNX.connect
    ###
    ### @see JSS::DBConnection
    ###
    ### @param mobiledevice[Integer,String] the id or name of the MobileDevice.
    ###
    ### @return [Array<Hash{:timestamp=>Time,:value=>String,Integer,Time}>]
    ###
    def history(mobiledevice)
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidConnectionError, "Database connection required for 'history' query." unless JSS::DB_CNX.connected?

      mobile_device_id = case mobiledevice
                         when *JSS::MobileDevice.all_ids(api: @api)
                           mobiledevice
                         when *JSS::MobileDevice.all_names(api: @api)
                           JSS::MobileDevice.map_all_ids_to(:name, api: @api).invert[mobiledevice]
                         end # case

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
        value = case @data_type
                when 'String' then entry['value']
                when 'Integer' then entry['value'].to_i
                when 'Date' then JSS.parse_datetime(entry['value'])
                end # case
        newhash = { value: value, timestamp: JSS.epoch_to_time(entry['timestamp_epoch']) }
        history << newhash
      end # each hash

      history
    end # history

    ######################
    ### Private Instance Methods
    #####################

    private

    ###
    ### Return the REST XML for this item, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      mdea = rest_rexml
      if @input_type == 'LDAP Attribute Mapping'
        it = mdea.elements["input_type"]
        it.add_element('attribute_mapping').text = @attribute_mapping
      end

      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << mdea

      doc.to_s
    end # rest xml

  end # class ExtAttrib

end # module
