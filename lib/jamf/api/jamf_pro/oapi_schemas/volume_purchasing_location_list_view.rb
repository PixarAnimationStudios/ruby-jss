# Copyright 2023 Pixar
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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: VolumePurchasingLocationListView
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.50.0-t1693149930
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
    #  - Jamf::OAPISchemas::VolumePurchasingLocations
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
    #
    class VolumePurchasingLocationListView < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute [r] totalPurchasedLicenses
        #   @return [Integer]
        totalPurchasedLicenses: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] totalUsedLicenses
        #   @return [Integer]
        totalUsedLicenses: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute [r] appleId
        #   @return [String]
        appleId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] organizationName
        #   @return [String]
        organizationName: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] tokenExpiration
        #   @return [String]
        tokenExpiration: {
          class: Jamf::Timestamp,
          readonly: true
        },

        # The two-letter ISO 3166-1 code that designates the country where the Volume Purchasing account is located.
        # @!attribute [r] countryCode
        #   @return [String]
        countryCode: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] locationName
        #   @return [String]
        locationName: {
          class: :string,
          readonly: true
        },

        # If this is "true", the clientContext used by this server does not match the clientContext returned by the Volume Purchasing API.
        # @!attribute [r] clientContextMismatch
        #   @return [Boolean]
        clientContextMismatch: {
          class: :boolean,
          readonly: true
        },

        # @!attribute automaticallyPopulatePurchasedContent
        #   @return [Boolean]
        automaticallyPopulatePurchasedContent: {
          class: :boolean
        },

        # @!attribute sendNotificationWhenNoLongerAssigned
        #   @return [Boolean]
        sendNotificationWhenNoLongerAssigned: {
          class: :boolean
        },

        # @!attribute autoRegisterManagedUsers
        #   @return [Boolean]
        autoRegisterManagedUsers: {
          class: :boolean
        },

        # @!attribute siteId
        #   @return [String]
        siteId: {
          class: :string
        },

        # @!attribute [r] lastSyncTime
        #   @return [String]
        lastSyncTime: {
          class: Jamf::Timestamp,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class VolumePurchasingLocationListView

  end # module OAPISchemas

end # module Jamf
