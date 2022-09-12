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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: ComputerOverview
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
    #  - Jamf::OAPISchemas::ComputersSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ComputerLocation
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerOverview < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute location
        #   @return [Jamf::OAPISchemas::ComputerLocation]
        location: {
          class: Jamf::OAPISchemas::ComputerLocation
        },

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute udid
        #   @return [String]
        udid: {
          class: :string
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string
        },

        # @!attribute lastContactDate
        #   @return [String]
        lastContactDate: {
          class: Jamf::Timestamp
        },

        # @!attribute lastReportDate
        #   @return [String]
        lastReportDate: {
          class: Jamf::Timestamp
        },

        # @!attribute lastEnrolledDate
        #   @return [String]
        lastEnrolledDate: {
          class: Jamf::Timestamp
        },

        # @!attribute operatingSystemVersion
        #   @return [String]
        operatingSystemVersion: {
          class: :string
        },

        # @!attribute operatingSystemBuild
        #   @return [String]
        operatingSystemBuild: {
          class: :string
        },

        # @!attribute ipAddress
        #   @return [String]
        ipAddress: {
          class: :string
        },

        # @!attribute macAddress
        #   @return [String]
        macAddress: {
          class: :string
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute modelIdentifier
        #   @return [String]
        modelIdentifier: {
          class: :string
        },

        # @!attribute mdmAccessRights
        #   @return [Integer]
        mdmAccessRights: {
          class: :integer
        },

        # @!attribute isManaged
        #   @return [Boolean]
        isManaged: {
          class: :boolean
        },

        # @!attribute [r] managementId
        #   @return [String]
        managementId: {
          class: :string,
          readonly: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerOverview

  end # module OAPISchemas

end # module Jamf
