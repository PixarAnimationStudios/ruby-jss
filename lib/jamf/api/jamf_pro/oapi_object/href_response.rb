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


    # OAPI Object Model and Enums for: HrefResponse
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
    #  - Jamf::OAPIObject::MacOsManagedSoftwareUpdateResponse
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/preview/enrollment/access-groups:POST' needs permissions:
    #    - Update User-Initiated Enrollment
    #  - '/preview/mdm/commands:POST' needs permissions:
    #    - View MDM command information in Jamf Pro API
    #  - '/preview/remote-administration-configurations/team-viewer:POST' needs permissions:
    #    - Create Remote Administration
    #  - '/preview/remote-administration-configurations/team-viewer/{configurationId}/sessions:POST' needs permissions:
    #    - Create Remote Administration
    #  - '/v1/advanced-mobile-device-searches:POST' needs permissions:
    #    - Create Advanced Mobile Device Searches
    #  - '/v1/advanced-user-content-searches:POST' needs permissions:
    #    - Create Advanced User Content Searches
    #  - '/v1/azure-ad-migration/reports:POST' needs permissions:
    #    - Create LDAP Servers
    #  - '/v1/buildings:POST' needs permissions:
    #    - Create Buildings
    #  - '/v1/categories:POST' needs permissions:
    #    - Create Categories
    #  - '/v1/cloud-azure:POST' needs permissions:
    #    - Create LDAP Servers
    #  - '/v1/computer-inventory-collection-settings/custom-path:POST' needs permissions:
    #    - Create Custom Paths
    #  - '/v1/computers-inventory/{id}/attachments:POST' needs permissions:
    #    - Update Computers
    #  - '/v1/departments:POST' needs permissions:
    #    - Create Departments
    #  - '/v1/departments/{id}/history:POST' needs permissions:
    #    - Update Departments
    #  - '/v1/device-enrollments/upload-token:POST' needs permissions:
    #    - Create Device Enrollment Program Instances
    #  - '/v1/device-enrollments/{id}/history:POST' needs permissions:
    #    - Update Device Enrollment Program Instances
    #  - '/v1/jamf-connect/history:POST' needs permissions:
    #    - Update Jamf Connect Settings
    #  - '/v1/jamf-protect/history:POST' needs permissions:
    #    - Update Jamf Protect Settings
    #  - '/v1/pki/venafi:POST' needs permissions:
    #    - Update PKI
    #  - '/v1/pki/venafi/{id}/history:POST' needs permissions:
    #    - Update PKI
    #  - '/v1/scripts:POST' needs permissions:
    #    - Create Scripts
    #  - '/v1/self-service/branding/ios:POST' needs permissions:
    #    - Create Self Service Branding Configuration
    #  - '/v1/self-service/branding/macos:POST' needs permissions:
    #    - Create Self Service Branding Configuration
    #  - '/v1/sso/history:POST' needs permissions:
    #    - Update SSO Settings
    #  - '/v1/teacher-app/history:POST' needs permissions:
    #    - Update Teacher App Settings
    #  - '/v1/volume-purchasing-locations:POST' needs permissions:
    #    - Create Volume Purchasing Administrator Accounts
    #  - '/v1/volume-purchasing-subscriptions:POST' needs permissions:
    #    - Create Volume Purchasing Administrator Accounts
    #  - '/v2/check-in/history:POST' needs permissions:
    #    - Update Computer Check-In
    #  - '/v2/cloud-ldaps:POST' needs permissions:
    #    - Create LDAP Servers
    #  - '/v2/computer-prestages:POST' needs permissions:
    #    - Create Computer PreStage Enrollments
    #  - '/v2/enrollment-customizations:POST' needs permissions:
    #    - Create Enrollment Customizations
    #  - '/v2/enrollment/access-groups:POST' needs permissions:
    #    - Update User-Initiated Enrollment
    #  - '/v2/enrollment/history:POST' needs permissions:
    #    - Update User-Initiated Enrollment
    #  - '/v2/inventory-preload/csv:POST' needs permissions:
    #    - Create Inventory Preload Records
    #    - Update Inventory Preload Records
    #    - Create User
    #    - Update User
    #  - '/v2/inventory-preload/history:POST' needs permissions:
    #    - Update Inventory Preload Records
    #  - '/v2/inventory-preload/records:POST' needs permissions:
    #    - Create Inventory Preload Records
    #  - '/v2/mobile-device-prestages:POST' needs permissions:
    #    - Create Mobile Device PreStage Enrollments
    #  - '/v2/mobile-device-prestages/{id}/history:POST' needs permissions:
    #    - Update Mobile Device PreStage Enrollments
    #  - '/v3/check-in/history:POST' needs permissions:
    #    - Update Computer Check-In
    #
    #
    class HrefResponse < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute href
        #   @return [String]
        href: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # class HrefResponse

  end # class OAPIObject

end # module Jamf
