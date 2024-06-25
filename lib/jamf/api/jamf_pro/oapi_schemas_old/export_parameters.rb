# Copyright 2024 Pixar
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


    # OAPI Object Model and Enums for: ExportParameters
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
    #  - Jamf::OAPISchemas::ExportField
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/buildings/export:POST' needs permissions:
    #    - Read Buildings
    #  - '/v1/buildings/{id}/history/export:POST' needs permissions:
    #    - Read Buildings
    #  - '/v1/cloud-idp/export:POST' needs permissions:
    #    - Read LDAP Servers
    #  - '/v1/onboarding/history/export:POST' needs permissions:
    #    - Read Onboarding Configuration
    #  - '/v1/packages/export:POST' needs permissions:
    #    - Read Packages
    #  - '/v1/packages/{id}/history/export:POST' needs permissions:
    #    - Read Packages
    #  - '/v1/reenrollment/history/export:POST' needs permissions:
    #    - Read Re-enrollment
    #  - '/v2/enrollment/history/export:POST' needs permissions:
    #    - Read User-Initiated Enrollment
    #  - '/v2/inventory-preload/export:POST' needs permissions:
    #    - Read Inventory Preload Records
    #  - '/v2/jamf-remote-assist/session/export:POST' needs permissions:
    #    - Read Remote Assist
    #
    #
    class ExportParameters < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute page
        #   @return [Integer]
        page: {
          class: :integer,
          nil_ok: true
        },

        # @!attribute pageSize
        #   @return [Integer]
        pageSize: {
          class: :integer,
          nil_ok: true
        },

        # Sorting criteria in the format: [<property>[:asc/desc]. Default direction when not stated is ascending.
        # @!attribute sort
        #   @return [Array<String>]
        sort: {
          class: :string,
          nil_ok: true,
          multi: true
        },

        # @!attribute filter
        #   @return [String]
        filter: {
          class: :string,
          nil_ok: true
        },

        # Used to change default order or ignore some of the fields. When null or empty array, all fields will be exported.
        # @!attribute fields
        #   @return [Array<Jamf::OAPISchemas::ExportField>]
        fields: {
          class: Jamf::OAPISchemas::ExportField,
          nil_ok: true,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ExportParameters

  end # module OAPISchemas

end # module Jamf
