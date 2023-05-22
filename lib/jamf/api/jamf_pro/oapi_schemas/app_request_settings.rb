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


    # OAPI Object Model and Enums for: AppRequestSettings
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.40.0-t1657115323
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
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/app-request/settings:GET' needs permissions:
    #    - Read App Request Settings
    #  - '/v1/app-request/settings:PUT' needs permissions:
    #    - Update App Request Settings
    #
    #
    class AppRequestSettings < Jamf::OAPIObject



      OAPI_PROPERTIES = {

        # @!attribute isEnabled
        #   @return [Boolean]
        isEnabled: {
          class: :boolean
        },

        # Can be any of the country codes from /v1/app-store-country-codes or "deviceLocale" to use each individual device's locale
        # @!attribute appStoreLocale
        #   @return [String]
        appStoreLocale: {
          class: :string
        },

        # @!attribute requesterUserGroupId
        #   @return [Integer]
        requesterUserGroupId: {
          class: :integer
        },

        # @!attribute approverEmails
        #   @return [Array<String>]
        approverEmails: {
          class: :string,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class AppRequestSettings

  end # module OAPISchemas

end # module Jamf
