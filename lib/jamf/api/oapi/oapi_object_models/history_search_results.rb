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

  # This module contains Object Model and Enum Constants for all JSONObjects
  # defined in the Jamf Pro API.
  #
  # Generated automatically from the OAPI schema available from the
  # 'api/schema' endpoint of any Jamf Pro server.
  #
  # This file was generated from Jamf Pro version 10.36.1
  #
  module OAPIObjectModels

    # API Object Model and Enums for: HistorySearchResults
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::ObjectHistory
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/inventory-preload/history:GET', needs permissions: Read Inventory Preload Records
    #  - '/v1/buildings/{id}/history:GET', needs permissions: Read Buildings
    #  - '/v1/categories/{id}/history:GET', needs permissions: Read Categories
    #  - '/v1/cloud-idp/{id}/history:GET', needs permissions: Read LDAP Servers
    #  - '/v1/cloud-ldaps/{id}/history:GET', needs permissions: Read LDAP Servers
    #  - '/v1/departments/{id}/history:GET', needs permissions: Read Departments
    #  - '/v1/device-communication-settings/history:GET', needs permissions: Read Automatically Renew MDM Profile Settings
    #  - '/v1/device-enrollments/{id}/history:GET', needs permissions: Read Device Enrollment Program Instances
    #  - '/v1/engage/history:GET', needs permissions: Read Engage Settings
    #  - '/v1/enrollment-customization/{id}/history:GET', needs permissions: Read Enrollment Customizations
    #  - '/v1/enrollment/history:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v1/inventory-preload/history:GET', needs permissions: Read Inventory Preload Records
    #  - '/v1/jamf-connect/history:GET', needs permissions: Read Jamf Connect Settings
    #  - '/v1/jamf-pro-server-url/history:GET', needs permissions: Read JSS URL
    #  - '/v1/jamf-protect/history:GET', needs permissions: Read Jamf Protect Settings
    #  - '/v1/mobile-device-prestages/{id}/history:GET', needs permissions: Read Mobile Device PreStage Enrollments
    #  - '/v1/parent-app/history:GET', needs permissions: Read Parent App Settings
    #  - '/v1/pki/venafi/{id}/history:GET', needs permissions: Read PKI
    #  - '/v1/reenrollment/history:GET', needs permissions: Read Re-enrollment
    #  - '/v1/scripts/{id}/history:GET', needs permissions: Read Scripts
    #  - '/v1/sso/history:GET', needs permissions: Read SSO Settings
    #  - '/v1/teacher-app/history:GET', needs permissions: Read Teacher App Settings
    #  - '/v1/volume-purchasing-locations/{id}/history:GET', needs permissions: Read Volume Purchasing Administrator Accounts
    #  - '/v2/enrollment-customizations/{id}/history:GET', needs permissions: Read Enrollment Customizations
    #  - '/v2/enrollment/history:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v2/inventory-preload/history:GET', needs permissions: Read Inventory Preload Records
    #  - '/v2/mobile-device-prestages/{id}/history:GET', needs permissions: Read Mobile Device PreStage Enrollments
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::HistorySearchResults
    #
    module HistorySearchResults

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute totalCount
        #   @return [Integer]
        totalCount: {
          class: :integer
        },

        # @!attribute results
        #   @return [Array<Jamf::ObjectHistory>]
        results: {
          class: Jamf::ObjectHistory,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module HistorySearchResults

  end # module OAPIObjectModels

end # module Jamf
