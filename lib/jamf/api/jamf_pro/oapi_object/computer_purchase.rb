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

  # This class is the superclass AND the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  class OAPIObject


    # OAPI Object Model and Enums for: ComputerPurchase
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.36.1-t1645562643
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
    #  - Jamf::OAPIObject::ComputerInventoryResponse
    #  - Jamf::OAPIObject::ComputerInventoryUpdateRequest
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::ComputerExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerPurchase < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute leased
        #   @return [Boolean]
        leased: {
          class: :boolean
        },

        # @!attribute purchased
        #   @return [Boolean]
        purchased: {
          class: :boolean
        },

        # @!attribute poNumber
        #   @return [String]
        poNumber: {
          class: :string
        },

        # @!attribute poDate
        #   @return [String]
        poDate: {
          class: :string,
          format: 'date'
        },

        # @!attribute vendor
        #   @return [String]
        vendor: {
          class: :string
        },

        # @!attribute warrantyDate
        #   @return [String]
        warrantyDate: {
          class: :string,
          format: 'date'
        },

        # @!attribute appleCareId
        #   @return [String]
        appleCareId: {
          class: :string
        },

        # @!attribute leaseDate
        #   @return [String]
        leaseDate: {
          class: :string,
          format: 'date'
        },

        # @!attribute purchasePrice
        #   @return [String]
        purchasePrice: {
          class: :string
        },

        # @!attribute lifeExpectancy
        #   @return [Integer]
        lifeExpectancy: {
          class: :integer
        },

        # @!attribute purchasingAccount
        #   @return [String]
        purchasingAccount: {
          class: :string
        },

        # @!attribute purchasingContact
        #   @return [String]
        purchasingContact: {
          class: :string
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPIObject::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPIObject::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerPurchase

  end # class OAPIObject

end # module Jamf
