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
#
#

# The Module
module Jamf

  # Classes
  #####################################

  # An Inventory Preload record for a Computer or Mobile Device in Jamf.
  #
  # Since the JPAPI offers access to these records via JSON as well as CSV
  # uploads, we are implementing JSON access, to stay in line with the rest
  # of how ruby-jss works, and keep things simple.
  #
  # If you want to use a CSV as your data source, you should use a ruby
  # CSV library, such as the one built in to ruby, and loop thru your CSV
  # records, creating or fetching instances of this class as needed,
  # manipulating them, and saving them.
  #
  #
  class InventoryPreloadRecord < Jamf::OAPISchemas::InventoryPreloadRecordV2
    # Mix-Ins
    #####################################
    include Jamf::CollectionResource
    extend Jamf::Filterable
    include Jamf::ChangeLog

    # extend Jamf::ChangeLog

    # Constants
    #####################################

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.
    #
    # TODO: See if these constants can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::InventoryPreloadRecordSearchResultsV2

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::InventoryPreloadRecordV2

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::InventoryPreloadRecordV2

    ############# API PATHS
    # TODO: See if these paths can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The path for GETting the list of all objects in the collection, possibly
    # filtered, sorted, and/or paged
    # REQUIRED for all collection resources
    #
    # GET_PATH, POST_PATH, PUT_PATH, PATCH_PATH, and DELETE_PATH are automatically
    # assumed from the LIST_PATH if they follow the standards:
    # - GET_PATH = "#{LIST_PATH}/id"
    #   - fetch an object from the collection
    # - POST_PATH = LIST_PATH
    #   - create a new object in the collection
    # - PUT_PATH = "#{LIST_PATH}/id"
    #   - update an object passing all its values back.
    #     Most objects use this or PATCH but not both
    # - PATCH_PATH = "#{LIST_PATH}/id"
    #   - update an object passing some of its values back
    #     Most objects use this or PUT but not both
    # - DELETE_PATH = "#{LIST_PATH}/id"
    #   - delete an object from the collection
    #
    # If those paths differ from the standards, the constants must be defined
    # here
    #
    LIST_PATH = 'v2/inventory-preload/records'.freeze

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only identifies ':id'
    ALT_IDENTIFIERS = %i[serialNumber].freeze

    # Must define this when extending Filterable
    FILTER_KEYS = OAPI_PROPERTIES.keys - [:extensionAttributes]

    # InvPreload Recs have a non-standard /history path
    def self.history_path(_id)
      'v2/inventory-preload/history'
    end

    # @param ea_name[String] The name of the EA being set
    #
    # @param new_val[String, Integer, Jamf::Timestamp, Time] The value being set
    #
    # @return [void]
    #
    def set_ext_attr(ea_name, new_val)
      remove_ext_attr(ea_name)
      extensionAttributes_append(
        Jamf::OAPISchemas::InventoryPreloadExtensionAttribute.new(name: ea_name, value: new_val)
      )
      new_val
    end

    # remove an EA value
    def remove_ext_attr(ea_name)
      idx = extensionAttributes.index { |ea| ea.name == ea_name }
      extensionAttributes_delete_at idx if idx
    end

    # a Hash of ea name => ea_value for all eas currently set.
    def ext_attrs
      eas = {}
      extensionAttributes.each { |ea| eas[ea.name] = ea.value }
      eas
    end

    # clear all values for this record except id, serialNumber, and deviceType
    def clear
      OAPI_PROPERTIES.each do |attr_name, attr_def|
        next unless attr_def[:nil_ok]

        if attr_name == :extensionAttributes
          self.extensionAttributes = []
          next
        end
        send "#{attr}=", nil
      end
    end

    # InvPreload Recs have a non-standard /history path
    def history_path(_id)
      raise Jamf::UnsupportedError, 'InventoryPreloadRecords do not have individual change logs. Use Jamf::InventoryPreloadRecord.change_log'
    end
  end # class

end # module
