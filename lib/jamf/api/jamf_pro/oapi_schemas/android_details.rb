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

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: AndroidDetails
    #
    # Description of this class from the OAPI Schema:
    #   will be populated if the type is android.
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
    #  - Jamf::OAPISchemas::MobileDeviceDetails
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::IdAndName
    #  - Jamf::OAPISchemas::Security
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class AndroidDetails < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute osName
        #   @return [String]
        osName: {
          class: :string
        },

        # @!attribute manufacturer
        #   @return [String]
        manufacturer: {
          class: :string
        },

        # @!attribute model
        #   @return [String]
        model: {
          class: :string
        },

        # @!attribute internalCapacityMb
        #   @return [Integer]
        internalCapacityMb: {
          class: :integer
        },

        # @!attribute internalAvailableMb
        #   @return [Integer]
        internalAvailableMb: {
          class: :integer
        },

        # @!attribute internalPercentUsed
        #   @return [Integer]
        internalPercentUsed: {
          class: :integer
        },

        # @!attribute externalCapacityMb
        #   @return [Integer]
        externalCapacityMb: {
          class: :integer
        },

        # @!attribute externalAvailableMb
        #   @return [Integer]
        externalAvailableMb: {
          class: :integer
        },

        # @!attribute externalPercentUsed
        #   @return [Integer]
        externalPercentUsed: {
          class: :integer
        },

        # @!attribute batteryLevel
        #   @return [Integer]
        batteryLevel: {
          class: :integer
        },

        # @!attribute lastBackupTimestamp
        #   @return [Jamf::Timestamp]
        lastBackupTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute apiVersion
        #   @return [Integer]
        apiVersion: {
          class: :integer
        },

        # @!attribute computer
        #   @return [Jamf::OAPISchemas::IdAndName]
        computer: {
          class: Jamf::OAPISchemas::IdAndName
        },

        # @!attribute security
        #   @return [Jamf::OAPISchemas::Security]
        security: {
          class: Jamf::OAPISchemas::Security
        }

      } # end OAPI_PROPERTIES

    end # class AndroidDetails

  end # module OAPISchemas

end # module Jamf
