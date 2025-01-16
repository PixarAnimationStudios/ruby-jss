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

    # OAPI Object Model and Enums for: Package
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
    #  - Jamf::OAPISchemas::PackagesSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/packages:POST' needs permissions:
    #    - Create Packages
    #  - '/v1/packages/{id}:GET' needs permissions:
    #    - Read Packages
    #  - '/v1/packages/{id}:PUT' needs permissions:
    #    - Update Packages
    #  - '/v1/packages/{id}/manifest:POST' needs permissions:
    #    - Update Packages
    #    - Read Packages
    #
    #
    class Package < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute packageName
        #   @return [String]
        packageName: {
          class: :string,
          required: true
        },

        # @!attribute fileName
        #   @return [String]
        fileName: {
          class: :string,
          required: true
        },

        # @!attribute categoryId
        #   @return [String]
        categoryId: {
          class: :string,
          required: true
        },

        # @!attribute info
        #   @return [String]
        info: {
          class: :string,
          nil_ok: true
        },

        # @!attribute notes
        #   @return [String]
        notes: {
          class: :string,
          nil_ok: true
        },

        # @!attribute priority
        #   @return [Integer]
        priority: {
          class: :integer,
          required: true
        },

        # @!attribute osRequirements
        #   @return [String]
        osRequirements: {
          class: :string,
          nil_ok: true
        },

        # @!attribute fillUserTemplate
        #   @return [Boolean]
        fillUserTemplate: {
          class: :boolean,
          required: true
        },

        # @!attribute [r] indexed
        #   @return [Boolean]
        indexed: {
          class: :boolean,
          readonly: true
        },

        # @!attribute fillExistingUsers
        #   @return [Boolean]
        fillExistingUsers: {
          class: :boolean
        },

        # @!attribute swu
        #   @return [Boolean]
        swu: {
          class: :boolean
        },

        # @!attribute rebootRequired
        #   @return [Boolean]
        rebootRequired: {
          class: :boolean,
          required: true
        },

        # @!attribute selfHealNotify
        #   @return [Boolean]
        selfHealNotify: {
          class: :boolean
        },

        # @!attribute selfHealingAction
        #   @return [String]
        selfHealingAction: {
          class: :string,
          nil_ok: true
        },

        # @!attribute osInstall
        #   @return [Boolean]
        osInstall: {
          class: :boolean,
          required: true
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string,
          nil_ok: true
        },

        # @!attribute parentPackageId
        #   @return [String]
        parentPackageId: {
          class: :string,
          nil_ok: true
        },

        # @!attribute basePath
        #   @return [String]
        basePath: {
          class: :string,
          nil_ok: true
        },

        # @!attribute suppressUpdates
        #   @return [Boolean]
        suppressUpdates: {
          class: :boolean,
          required: true
        },

        # @!attribute [r] cloudTransferStatus
        #   @return [String]
        cloudTransferStatus: {
          class: :string,
          readonly: true
        },

        # @!attribute ignoreConflicts
        #   @return [Boolean]
        ignoreConflicts: {
          class: :boolean
        },

        # @!attribute suppressFromDock
        #   @return [Boolean]
        suppressFromDock: {
          class: :boolean,
          required: true
        },

        # @!attribute suppressEula
        #   @return [Boolean]
        suppressEula: {
          class: :boolean,
          required: true
        },

        # @!attribute suppressRegistration
        #   @return [Boolean]
        suppressRegistration: {
          class: :boolean,
          required: true
        },

        # @!attribute installLanguage
        #   @return [String]
        installLanguage: {
          class: :string,
          nil_ok: true
        },

        # @!attribute md5
        #   @return [String]
        md5: {
          class: :string,
          nil_ok: true
        },

        # @!attribute sha256
        #   @return [String]
        sha256: {
          class: :string,
          nil_ok: true
        },

        # @!attribute hashType
        #   @return [String]
        hashType: {
          class: :string,
          nil_ok: true
        },

        # @!attribute hashValue
        #   @return [String]
        hashValue: {
          class: :string,
          nil_ok: true
        },

        # @!attribute [r] size
        #   @return [String]
        size: {
          class: :string,
          nil_ok: true,
          readonly: true
        },

        # @!attribute osInstallerVersion
        #   @return [String]
        osInstallerVersion: {
          class: :string,
          nil_ok: true
        },

        # @!attribute manifest
        #   @return [String]
        manifest: {
          class: :string,
          nil_ok: true
        },

        # @!attribute manifestFileName
        #   @return [String]
        manifestFileName: {
          class: :string,
          nil_ok: true
        },

        # @!attribute format
        #   @return [String]
        format: {
          class: :string,
          nil_ok: true
        }

      } # end OAPI_PROPERTIES

    end # class Package

  end # module OAPISchemas

end # module Jamf
