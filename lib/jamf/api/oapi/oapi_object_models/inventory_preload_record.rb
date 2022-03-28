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


module Jamf

  # This module contains Object Model and Enum Constants for all JSONObjects
  # defined in the Jamf Pro API.
  #
  # Generated automatically from the OAPI schema available from the
  # 'api/schema' endpoint of any Jamf Pro server.
  #
  # This file was generated from Jamf Pro version 10.36.1
  #
  module OAPIObjectModels

    # API Object Model and Enums for: InventoryPreloadRecord
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::InventoryPreloadRecordSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::InventoryPreloadExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/inventory-preload:POST', needs permissions: Create Inventory Preload Records
    #  - '/inventory-preload/{id}:GET', needs permissions: Read Inventory Preload Records
    #  - '/inventory-preload/{id}:PUT', needs permissions: Update Inventory Preload Records
    #  - '/v1/inventory-preload:POST', needs permissions: Create Inventory Preload Records
    #  - '/v1/inventory-preload/{id}:GET', needs permissions: Read Inventory Preload Records
    #  - '/v1/inventory-preload/{id}:PUT', needs permissions: Update Inventory Preload Records
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::InventoryPreloadRecord
    #
    module InventoryPreloadRecord

      # These enums are used in the properties below

      DEVICE_TYPE_OPTIONS = [
        'Computer',
        'Mobile Device',
        'Unknown'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [Integer]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string,
          required: true
        },

        # @!attribute deviceType
        #   @return [String]
        deviceType: {
          class: :string,
          required: true,
          enum: DEVICE_TYPE_OPTIONS
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

        # @!attribute vendor
        #   @return [String]
        vendor: {
          class: :string
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::InventoryPreloadExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::InventoryPreloadExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module InventoryPreloadRecord

  end # module OAPIObjectModels

end # module Jamf
