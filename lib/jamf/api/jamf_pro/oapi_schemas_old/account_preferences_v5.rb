# Copyright 2025 Pixar
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

    # OAPI Object Model and Enums for: AccountPreferencesV5
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
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::AccountPreferencesUserInterfaceDisplayTheme
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #  - Jamf::OAPISchemas::AccountPreferencesSearchType
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/account-preferences:GET' needs permissions:
    #    - Unknown
    #  - '/v2/account-preferences:PATCH' needs permissions:
    #    - Unknown
    #
    #
    class AccountPreferencesV5 < Jamf::OAPIObject

      # Enums used by this class or others

      LANGUAGE_OPTIONS = %w[
        en
        de
        fr
        es
        ja
        zh-hant
      ]

      OAPI_PROPERTIES = {

        # Language codes supported by Jamf Pro
        # @!attribute language
        #   @return [String]
        language: {
          class: :string,
          required: true,
          enum: LANGUAGE_OPTIONS
        },

        # @!attribute dateFormat
        #   @return [String]
        dateFormat: {
          class: :string,
          required: true
        },

        # @!attribute timezone
        #   @return [String]
        timezone: {
          class: :string,
          required: true
        },

        # @!attribute resultsPerPage
        #   @return [Integer]
        resultsPerPage: {
          class: :integer,
          required: true
        },

        # @!attribute userInterfaceDisplayTheme
        #   @return [Jamf::OAPISchemas::AccountPreferencesUserInterfaceDisplayTheme]
        userInterfaceDisplayTheme: {
          class: Jamf::OAPISchemas::AccountPreferencesUserInterfaceDisplayTheme,
          required: true
        },

        # @!attribute disableRelativeDates
        #   @return [Boolean]
        disableRelativeDates: {
          class: :boolean,
          required: true
        },

        # @!attribute disablePageLeaveCheck
        #   @return [Boolean]
        disablePageLeaveCheck: {
          class: :boolean,
          required: true
        },

        # @!attribute disableTablePagination
        #   @return [Boolean]
        disableTablePagination: {
          class: :boolean,
          required: true
        },

        # @!attribute disableShortcutsTooltips
        #   @return [Boolean]
        disableShortcutsTooltips: {
          class: :boolean,
          required: true
        },

        # @!attribute configProfilesSortingMethod
        #   @return [String]
        configProfilesSortingMethod: {
          class: :string,
          required: true
        },

        # @!attribute computerSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerApplicationSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerApplicationSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerApplicationUsageSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerApplicationUsageSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerFontSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerFontSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType
        },

        # @!attribute computerPluginSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerPluginSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType
        },

        # @!attribute computerSoftwareUpdateSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerSoftwareUpdateSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType
        },

        # @!attribute computerLocalUserAccountSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerLocalUserAccountSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerPackageReceiptSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerPackageReceiptSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerPrinterSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerPrinterSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute computerPeripheralSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerPeripheralSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType
        },

        # @!attribute computerServiceSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        computerServiceSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute mobileDeviceSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        mobileDeviceSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute mobileDeviceAppSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        mobileDeviceAppSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute userSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        userSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute userAllContentSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        userAllContentSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute userMobileDeviceAppSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        userMobileDeviceAppSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute userMacAppStoreAppSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        userMacAppStoreAppSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        },

        # @!attribute userEbookSearchMethod
        #   @return [Jamf::OAPISchemas::AccountPreferencesSearchType]
        userEbookSearchMethod: {
          class: Jamf::OAPISchemas::AccountPreferencesSearchType,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class AccountPreferencesV5

  end # module OAPISchemas

end # module Jamf
