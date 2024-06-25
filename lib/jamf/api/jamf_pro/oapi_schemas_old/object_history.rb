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


    # OAPI Object Model and Enums for: ObjectHistory
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
    #  - Jamf::OAPISchemas::HistorySearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/inventory-preload/history/notes:POST' needs permissions:
    #    - Update Inventory Preload Records
    #  - '/v1/buildings/{id}/history:POST' needs permissions:
    #    - Update Buildings
    #  - '/v1/categories/{id}/history:POST' needs permissions:
    #    - Update Categories
    #  - '/v1/cloud-idp/{id}/history:POST' needs permissions:
    #    - Update LDAP Servers
    #  - '/v1/device-communication-settings/history:POST' needs permissions:
    #    - Update Automatically Renew MDM Profile Settings
    #  - '/v1/engage/history:POST' needs permissions:
    #    - Update Engage Settings
    #  - '/v1/enrollment-customization/{id}/history:POST' needs permissions:
    #    - Update Enrollment Customizations
    #  - '/v1/inventory-preload/history:POST' needs permissions:
    #    - Update Inventory Preload Records
    #  - '/v1/jamf-pro-server-url/history:POST' needs permissions:
    #    - Update JSS URL
    #  - '/v1/mobile-device-prestages/{id}/history:POST' needs permissions:
    #    - Update Mobile Device PreStage Enrollments
    #  - '/v1/packages/{id}/history:POST' needs permissions:
    #    - Update Packages
    #  - '/v1/parent-app/history:POST' needs permissions:
    #    - Update Parent App Settings
    #  - '/v1/reenrollment/history:POST' needs permissions:
    #    - Update Re-enrollment
    #  - '/v1/scripts/{id}/history:POST' needs permissions:
    #    - Update Scripts
    #  - '/v1/volume-purchasing-locations/{id}/history:POST' needs permissions:
    #    - Update Volume Purchasing Locations
    #  - '/v2/engage/history:POST' needs permissions:
    #    - Update Engage Settings
    #  - '/v2/enrollment-customizations/{id}/history:POST' needs permissions:
    #    - Update Enrollment Customizations
    #
    #
    class ObjectHistory < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [Integer]
        id: {
          class: :j_id,
          identifier: :primary,
          minimum: 1
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute date
        #   @return [String]
        date: {
          class: Jamf::Timestamp
        },

        # @!attribute note
        #   @return [String]
        note: {
          class: :string
        },

        # @!attribute details
        #   @return [String]
        details: {
          class: :string,
          nil_ok: true
        }

      } # end OAPI_PROPERTIES

    end # class ObjectHistory

  end # module OAPISchemas

end # module Jamf
