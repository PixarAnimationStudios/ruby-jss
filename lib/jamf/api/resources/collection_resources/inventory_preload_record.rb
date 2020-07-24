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
  class InventoryPreloadRecord < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    extend Jamf::ChangeLog

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'inventory-preload'.freeze

    DEVICE_TYPE_COMPUTER = 'Computer'.freeze
    DEVICE_TYPE_MOBILE_DEV = 'Mobile Device'.freeze
    DEVICE_TYPE_UNKNOWN = 'Unknown'.freeze

    DEVICE_TYPES = [
      DEVICE_TYPE_COMPUTER,
      DEVICE_TYPE_MOBILE_DEV,
      DEVICE_TYPE_UNKNOWN
    ].freeze

    # The 'clear' instance method won't change these attrs
    UNCLEARABLE_ATTRS = %i[id serialNumber deviceType].freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute serialNumber
      #   @return [String]
      serialNumber: {
        class: :string,
        identifier: true,
        validator: :non_empty_string,
        required: true
      },

      # @!attribute deviceType
      #   @return [String]
      deviceType: {
        class: :string,
        enum: Jamf::InventoryPreloadRecord::DEVICE_TYPES,
        required: true
      },

      # @!attribute username
      #   @return [String]
      username: {
        class: :string
      },

      # @!attribute fullName
      #   @return [String]
      fullName: {
        class: :string
      },

      # @!attribute emailAddress
      #   @return [String]
      emailAddress: {
        class: :string
      },

      # @!attribute phoneNumber
      #   @return [String]
      phoneNumber: {
        class: :string
      },

      # @!attribute position
      #   @return [String]
      position: {
        class: :string
      },

      # @!attribute department
      #   @return [String]
      department: {
        class: :string
      },

      # @!attribute building
      #   @return [String]
      building: {
        class: :string
      },

      # @!attribute room
      #   @return [String]
      room: {
        class: :string
      },

      # @!attribute poNumber
      #   @return [String]
      poNumber: {
        class: :string
      },

      # @!attribute poDate
      #   @return [String]
      poDate: {
        class: :string
      },

      # @!attribute warrantyExpiration
      #   @return [String]
      warrantyExpiration: {
        class: :string
      },

      # @!attribute appleCareId
      #   @return [String]
      appleCareId: {
        class: :string
      },

      # @!attribute lifeExpectancy
      #   @return [String]
      lifeExpectancy: {
        class: :string
      },

      # @!attribute purchasePrice
      #   @return [String]
      purchasePrice: {
        class: :string
      },

      # @!attribute purchasingContact
      #   @return [String]
      purchasingContact: {
        class: :string
      },

      # @!attribute purchasingAccount
      #   @return [String]
      purchasingAccount: {
        class: :string
      },

      # @!attribute leaseExpiration
      #   @return [String]
      leaseExpiration: {
        class: :string
      },

      # @!attribute barCode1
      #   @return [String]
      barCode1: {
        class: :string
      },

      # @!attribute barCode2
      #   @return [String]
      barCode2: {
        class: :string
      },

      # @!attribute assetTag
      #   @return [String]
      assetTag: {
        class: :string
      },

      # @!attribute extensionAttributes
      #   @return [Jamf::InventoryPreloadExtensionAttribute]
      extensionAttributes: {
        class: Jamf::InventoryPreloadExtensionAttribute,
        multi: true,
        aliases: %i[eas]
      }

    }.freeze

    parse_object_model

    # TODO: validation for ea's existance and value data type, once EAs are
    # implemented in JPAPI (see inventory_preload_extension_attribute.rb)
    #
    # @param ea_name[String] The name of the EA being set
    #
    # @param new_val[String, Integer, Jamf::Timestamp, Time] The value being set
    #
    # @return [void]
    #
    def set_ext_attr(ea_name, new_val)
      remove_ext_attr(ea_name)
      extensionAttributes_append Jamf::InventoryPreloadExtensionAttribute.new(name: ea_name, value: new_val)
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
      OBJECT_MODEL.keys.each do |attr|
        next if UNCLEARABLE_ATTRS.include? attr

        if attr == :extensionAttributes
          extensionAttributes = []
          next
        end

        # skip nils
        curr_val = send attr
        next unless curr_val

        send "#{attr}=", nil
      end
    end

  end # class

end # module
