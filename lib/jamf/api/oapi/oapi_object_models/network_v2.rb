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

    # API Object Model and Enums for: NetworkV2
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::IosDetailsV2
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::NetworkV2
    #
    module NetworkV2

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute cellularTechnology
        #   @return [String]
        cellularTechnology: {
          class: :string
        },

        # @!attribute voiceRoamingEnabled
        #   @return [Boolean]
        voiceRoamingEnabled: {
          class: :boolean
        },

        # @!attribute imei
        #   @return [String]
        imei: {
          class: :string
        },

        # @!attribute iccid
        #   @return [String]
        iccid: {
          class: :string
        },

        # @!attribute meid
        #   @return [String]
        meid: {
          class: :string
        },

        # EID or "embedded identity document" is a number associated with the eSIM on a device
        # @!attribute [r] eid
        #   @return [String]
        eid: {
          class: :string,
          readonly: true
        },

        # @!attribute carrierSettingsVersion
        #   @return [String]
        carrierSettingsVersion: {
          class: :string
        },

        # @!attribute currentCarrierNetwork
        #   @return [String]
        currentCarrierNetwork: {
          class: :string
        },

        # @!attribute currentMobileCountryCode
        #   @return [String]
        currentMobileCountryCode: {
          class: :string
        },

        # @!attribute currentMobileNetworkCode
        #   @return [String]
        currentMobileNetworkCode: {
          class: :string
        },

        # @!attribute homeCarrierNetwork
        #   @return [String]
        homeCarrierNetwork: {
          class: :string
        },

        # @!attribute homeMobileCountryCode
        #   @return [String]
        homeMobileCountryCode: {
          class: :string
        },

        # @!attribute homeMobileNetworkCode
        #   @return [String]
        homeMobileNetworkCode: {
          class: :string
        },

        # @!attribute dataRoamingEnabled
        #   @return [Boolean]
        dataRoamingEnabled: {
          class: :boolean
        },

        # @!attribute roaming
        #   @return [Boolean]
        roaming: {
          class: :boolean
        },

        # @!attribute personalHotspotEnabled
        #   @return [Boolean]
        personalHotspotEnabled: {
          class: :boolean
        },

        # @!attribute phoneNumber
        #   @return [String]
        phoneNumber: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # module NetworkV2

  end # module OAPIObjectModels

end # module Jamf
