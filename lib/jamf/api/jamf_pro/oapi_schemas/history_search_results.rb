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


    # OAPI Object Model and Enums for: HistorySearchResults
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ObjectHistory
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/inventory-preload/history:GET' needs permissions:
    #    - Read Inventory Preload Records
    #  - '/v1/buildings/{id}/history:GET' needs permissions:
    #    - Read Buildings
    #  - '/v1/categories/{id}/history:GET' needs permissions:
    #    - Read Categories
    #  - '/v1/cloud-idp/{id}/history:GET' needs permissions:
    #    - Read LDAP Servers
    #  - '/v1/cloud-ldaps/{id}/history:GET' needs permissions:
    #    - Read LDAP Servers
    #  - '/v1/departments/{id}/history:GET' needs permissions:
    #    - Read Departments
    #  - '/v1/device-communication-settings/history:GET' needs permissions:
    #    - Read Automatically Renew MDM Profile Settings
    #  - '/v1/device-enrollments/{id}/history:GET' needs permissions:
    #    - Read Device Enrollment Program Instances
    #  - '/v1/engage/history:GET' needs permissions:
    #    - Read Engage Settings
    #  - '/v1/enrollment-customization/{id}/history:GET' needs permissions:
    #    - Read Enrollment Customizations
    #  - '/v1/enrollment/history:GET' needs permissions:
    #    - Read User-Initiated Enrollment
    #  - '/v1/inventory-preload/history:GET' needs permissions:
    #    - Read Inventory Preload Records
    #  - '/v1/jamf-connect/history:GET' needs permissions:
    #    - Read Jamf Connect Settings
    #  - '/v1/jamf-pro-server-url/history:GET' needs permissions:
    #    - Read JSS URL
    #  - '/v1/jamf-protect/history:GET' needs permissions:
    #    - Read Jamf Protect Settings
    #  - '/v1/mobile-device-prestages/{id}/history:GET' needs permissions:
    #    - Read Mobile Device PreStage Enrollments
    #  - '/v1/parent-app/history:GET' needs permissions:
    #    - Read Parent App Settings
    #  - '/v1/pki/venafi/{id}/history:GET' needs permissions:
    #    - Read PKI
    #  - '/v1/reenrollment/history:GET' needs permissions:
    #    - Read Re-enrollment
    #  - '/v1/scripts/{id}/history:GET' needs permissions:
    #    - Read Scripts
    #  - '/v1/sso/history:GET' needs permissions:
    #    - Read SSO Settings
    #  - '/v1/teacher-app/history:GET' needs permissions:
    #    - Read Teacher App Settings
    #  - '/v1/volume-purchasing-locations/{id}/history:GET' needs permissions:
    #    - Read Volume Purchasing Administrator Accounts
    #  - '/v2/enrollment-customizations/{id}/history:GET' needs permissions:
    #    - Read Enrollment Customizations
    #  - '/v2/enrollment/history:GET' needs permissions:
    #    - Read User-Initiated Enrollment
    #  - '/v2/inventory-preload/history:GET' needs permissions:
    #    - Read Inventory Preload Records
    #  - '/v2/mobile-device-prestages/{id}/history:GET' needs permissions:
    #    - Read Mobile Device PreStage Enrollments
    #
    #
    class HistorySearchResults < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute totalCount
        #   @return [Integer]
        totalCount: {
          class: :integer
        },

        # @!attribute results
        #   @return [Array<Jamf::OAPISchemas::ObjectHistory>]
        results: {
          class: Jamf::OAPISchemas::ObjectHistory,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class HistorySearchResults

  end # module OAPISchemas

end # module Jamf
