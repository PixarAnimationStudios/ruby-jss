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


    # OAPI Object Model and Enums for: PatchSoftwareTitleConfigurationBase
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::PatchSoftwareTitleConfigurationExtensionAttributes
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/patch-software-title-configurations:POST' needs permissions:
    #    - Create Patch Management Software Titles
    #
    #
    class PatchSoftwareTitleConfigurationBase < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string,
          required: true
        },

        # @!attribute categoryId
        #   @return [String]
        categoryId: {
          class: :string
        },

        # @!attribute siteId
        #   @return [String]
        siteId: {
          class: :string
        },

        # @!attribute uiNotifications
        #   @return [Boolean]
        uiNotifications: {
          class: :boolean
        },

        # @!attribute emailNotifications
        #   @return [Boolean]
        emailNotifications: {
          class: :boolean
        },

        # @!attribute softwareTitleId
        #   @return [String]
        softwareTitleId: {
          class: :string,
          required: true
        },

        # @!attribute [r] jamfOfficial
        #   @return [Boolean]
        jamfOfficial: {
          class: :boolean,
          readonly: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::PatchSoftwareTitleConfigurationExtensionAttributes>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::PatchSoftwareTitleConfigurationExtensionAttributes,
          multi: true
        },

        # @!attribute [r] softwareTitleName
        #   @return [String]
        softwareTitleName: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] softwareTitleNameId
        #   @return [String]
        softwareTitleNameId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] softwareTitlePublisher
        #   @return [String]
        softwareTitlePublisher: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] patchSourceName
        #   @return [String]
        patchSourceName: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] patchSourceEnabled
        #   @return [Boolean]
        patchSourceEnabled: {
          class: :boolean,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class PatchSoftwareTitleConfigurationBase

  end # module OAPISchemas

end # module Jamf
