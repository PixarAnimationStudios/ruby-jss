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

# The module
module Jamf

  #
  class PrestagePurchasingData < Jamf::JSONObject

    include Jamf::Lockable

    OBJECT_MODEL = {

      # @!attribute id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary
      },

      # @!attribute isPurchased
      #   @param [Boolean]
      #   @return [Boolean]
      isPurchased: {
        class: :boolean
      },

      # @!attribute isLeased
      #   @param [Boolean]
      #   @return [Boolean]
      isLeased: {
        class: :boolean
      },

      # @!attribute appleCareID
      #   @param [String]
      #   @return [String]
      appleCareID: {
        class: :string
      },

      # @!attribute poNumber
      #   @param [String]
      #   @return [String]
      poNumber: {
        class: :string
      },

      # @!attribute vendor
      #   @param [String]
      #   @return [String]
      vendor: {
        class: :string
      },

      # @!attribute purchasePrice
      #   @param [String]
      #   @return [String]
      purchasePrice: {
        class: :string
      },

      # @!attribute purchasingAccount
      #   @param [String]
      #   @return [String]
      purchasingAccount: {
        class: :string
      },

      # @!attribute poDate
      #   @param [String]
      #   @return [String]
      poDate: {
        class: Jamf::Timestamp
      },

      # @!attribute warrantyExpiresDate
      #   @param [String]
      #   @return [String]
      warrantyDate: {
        class: Jamf::Timestamp
      },

      # @!attribute leaseExpiresDate
      #   @param [String]
      #   @return [String]
      leasesDate: {
        class: Jamf::Timestamp
      },

      # @!attribute lifeExpectancy
      #   @param [String]
      #   @return [String]
      lifeExpectancy: {
        class: :integer
      },

      # @!attribute purchasingContact
      #   @param [String]
      #   @return [String]
      purchasingContact: {
        class: :string
      }
    }.freeze

    parse_object_model

  end # class location

end # module
