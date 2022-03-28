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

    # API Object Model and Enums for: InventoryPreloadRecordV2
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::InventoryPreloadRecordSearchResultsV2
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::InventoryPreloadExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/inventory-preload/records:POST', needs permissions: Create Inventory Preload Records
    #  - '/v2/inventory-preload/records/{id}:GET', needs permissions: Read Inventory Preload Records
    #  - '/v2/inventory-preload/records/{id}:PUT', needs permissions: Update Inventory Preload Records
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::InventoryPreloadRecordV2
    #
    module InventoryPreloadRecordV2

      # These enums are used in the properties below

      DEVICE_TYPE_OPTIONS = [
        'Computer',
        'Mobile Device',
        'Unknown'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
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
          class: :string,
          nil_ok: true
        },

        # @!attribute fullName
        #   @return [String]
        fullName: {
          class: :string,
          nil_ok: true
        },

        # @!attribute emailAddress
        #   @return [String]
        emailAddress: {
          class: :string,
          nil_ok: true
        },

        # @!attribute phoneNumber
        #   @return [String]
        phoneNumber: {
          class: :string,
          nil_ok: true
        },

        # @!attribute position
        #   @return [String]
        position: {
          class: :string,
          nil_ok: true
        },

        # @!attribute department
        #   @return [String]
        department: {
          class: :string,
          nil_ok: true
        },

        # @!attribute building
        #   @return [String]
        building: {
          class: :string,
          nil_ok: true
        },

        # @!attribute room
        #   @return [String]
        room: {
          class: :string,
          nil_ok: true
        },

        # @!attribute poNumber
        #   @return [String]
        poNumber: {
          class: :string,
          nil_ok: true
        },

        # @!attribute poDate
        #   @return [String]
        poDate: {
          class: :string,
          nil_ok: true
        },

        # @!attribute warrantyExpiration
        #   @return [String]
        warrantyExpiration: {
          class: :string,
          nil_ok: true
        },

        # @!attribute appleCareId
        #   @return [String]
        appleCareId: {
          class: :string,
          nil_ok: true
        },

        # @!attribute lifeExpectancy
        #   @return [String]
        lifeExpectancy: {
          class: :string,
          nil_ok: true
        },

        # @!attribute purchasePrice
        #   @return [String]
        purchasePrice: {
          class: :string,
          nil_ok: true
        },

        # @!attribute purchasingContact
        #   @return [String]
        purchasingContact: {
          class: :string,
          nil_ok: true
        },

        # @!attribute purchasingAccount
        #   @return [String]
        purchasingAccount: {
          class: :string,
          nil_ok: true
        },

        # @!attribute leaseExpiration
        #   @return [String]
        leaseExpiration: {
          class: :string,
          nil_ok: true
        },

        # @!attribute barCode1
        #   @return [String]
        barCode1: {
          class: :string,
          nil_ok: true
        },

        # @!attribute barCode2
        #   @return [String]
        barCode2: {
          class: :string,
          nil_ok: true
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string,
          nil_ok: true
        },

        # @!attribute vendor
        #   @return [String]
        vendor: {
          class: :string,
          nil_ok: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::InventoryPreloadExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::InventoryPreloadExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module InventoryPreloadRecordV2

  end # module OAPIObjectModels

end # module Jamf
