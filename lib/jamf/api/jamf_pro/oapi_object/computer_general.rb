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


    # OAPI Object Model and Enums for: ComputerGeneral
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
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::ComputerRemoteManagement
    #  - Jamf::OAPIObject::ComputerMdmCapability
    #  - Jamf::OAPIObject::EnrollmentMethod
    #  - Jamf::OAPIObject::V1Site
    #  - Jamf::OAPIObject::ComputerExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerGeneral < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute lastIpAddress
        #   @return [String]
        lastIpAddress: {
          class: :string
        },

        # @!attribute lastReportedIp
        #   @return [String]
        lastReportedIp: {
          class: :string
        },

        # @!attribute jamfBinaryVersion
        #   @return [String]
        jamfBinaryVersion: {
          class: :string
        },

        # @!attribute platform
        #   @return [String]
        platform: {
          class: :string
        },

        # @!attribute barcode1
        #   @return [String]
        barcode1: {
          class: :string
        },

        # @!attribute barcode2
        #   @return [String]
        barcode2: {
          class: :string
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute remoteManagement
        #   @return [Hash{Symbol: Object}]
        remoteManagement: {
          class: :hash
        },

        # @!attribute supervised
        #   @return [Boolean]
        supervised: {
          class: :boolean
        },

        # @!attribute mdmCapable
        #   @return [Hash{Symbol: Object}]
        mdmCapable: {
          class: :hash
        },

        # @!attribute reportDate
        #   @return [Jamf::Timestamp]
        reportDate: {
          class: Jamf::Timestamp,
          format: date-time
        },

        # @!attribute lastContactTime
        #   @return [Jamf::Timestamp]
        lastContactTime: {
          class: Jamf::Timestamp,
          format: date-time
        },

        # @!attribute lastCloudBackupDate
        #   @return [Jamf::Timestamp]
        lastCloudBackupDate: {
          class: Jamf::Timestamp,
          format: date-time
        },

        # @!attribute lastEnrolledDate
        #   @return [Jamf::Timestamp]
        lastEnrolledDate: {
          class: Jamf::Timestamp,
          format: date-time
        },

        # @!attribute mdmProfileExpiration
        #   @return [Jamf::Timestamp]
        mdmProfileExpiration: {
          class: Jamf::Timestamp,
          format: date-time
        },

        # @!attribute initialEntryDate
        #   @return [String]
        initialEntryDate: {
          class: :string,
          format: date
        },

        # @!attribute distributionPoint
        #   @return [String]
        distributionPoint: {
          class: :string
        },

        # @!attribute enrollmentMethod
        #   @return [Hash{Symbol: Object}]
        enrollmentMethod: {
          class: :hash
        },

        # @!attribute site
        #   @return [Hash{Symbol: Object}]
        site: {
          class: :hash
        },

        # @!attribute itunesStoreAccountActive
        #   @return [Boolean]
        itunesStoreAccountActive: {
          class: :boolean
        },

        # @!attribute enrolledViaAutomatedDeviceEnrollment
        #   @return [Boolean]
        enrolledViaAutomatedDeviceEnrollment: {
          class: :boolean
        },

        # @!attribute userApprovedMdm
        #   @return [Boolean]
        userApprovedMdm: {
          class: :boolean
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPIObject::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPIObject::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerGeneral

  end # class OAPIObject

end # module Jamf
