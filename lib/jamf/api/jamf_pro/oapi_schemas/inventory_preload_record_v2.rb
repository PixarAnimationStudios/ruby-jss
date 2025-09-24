# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: InventoryPreloadRecordV2
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.6.1-t1718634702
    #
    # This class may be used directly, e.g instances of other classes may
    # use instances of this class as one of their own properties/attributes.
    #
    # It may also be used as a superclass when implementing Jamf Pro API
    # Resources in ruby-jss. The subclasses include appropriate mixins, and
    # should expand on the basic functionality provided here.
    #
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - Jamf::OAPISchemas::InventoryPreloadRecordSearchResultsV2
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::InventoryPreloadExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/inventory-preload/records:POST' needs permissions:
    #    - Create Inventory Preload Records
    #  - '/v2/inventory-preload/records/{id}:GET' needs permissions:
    #    - Read Inventory Preload Records
    #  - '/v2/inventory-preload/records/{id}:PUT' needs permissions:
    #    - Update Inventory Preload Records
    #
    #
    class InventoryPreloadRecordV2 < Jamf::OAPIObject

      # Enums used by this class or others

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
          class: Jamf::Timestamp,
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
        #   @return [Array<Jamf::OAPISchemas::InventoryPreloadExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::InventoryPreloadExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class InventoryPreloadRecordV2

  end # module OAPISchemas

end # module Jamf
