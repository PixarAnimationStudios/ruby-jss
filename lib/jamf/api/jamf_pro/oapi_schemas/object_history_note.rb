# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: ObjectHistoryNote
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
    #  - '/v1/departments/{id}/history:POST' needs permissions:
    #    - Update Departments
    #  - '/v1/device-communication-settings/history:POST' needs permissions:
    #    - Update Automatically Renew MDM Profile Settings
    #  - '/v1/device-enrollments/{id}/history:POST' needs permissions:
    #    - Update Device Enrollment Program Instances
    #  - '/v1/engage/history:POST' needs permissions:
    #    - Update Engage Settings
    #  - '/v1/enrollment-customization/{id}/history:POST' needs permissions:
    #    - Update Enrollment Customizations
    #  - '/v1/gsx-connection/history:POST' needs permissions:
    #    - Update GSX Connection
    #  - '/v1/inventory-preload/history:POST' needs permissions:
    #    - Update Inventory Preload Records
    #  - '/v1/jamf-connect/history:POST' needs permissions:
    #    - Update Jamf Connect Settings
    #  - '/v1/jamf-pro-server-url/history:POST' needs permissions:
    #    - Update JSS URL
    #  - '/v1/jamf-protect/history:POST' needs permissions:
    #    - Update Jamf Protect Settings
    #  - '/v1/mobile-device-prestages/{id}/history:POST' needs permissions:
    #    - Update Mobile Device PreStage Enrollments
    #  - '/v1/onboarding/history:POST' needs permissions:
    #    - Update Onboarding Configuration
    #  - '/v1/packages/{id}/history:POST' needs permissions:
    #    - Update Packages
    #  - '/v1/parent-app/history:POST' needs permissions:
    #    - Update Parent App Settings
    #  - '/v1/pki/venafi/{id}/history:POST' needs permissions:
    #    - Update PKI
    #  - '/v1/reenrollment/history:POST' needs permissions:
    #    - Update Re-enrollment
    #  - '/v1/scripts/{id}/history:POST' needs permissions:
    #    - Update Scripts
    #  - '/v1/smtp-server/history:POST' needs permissions:
    #    - Update SMTP Server
    #  - '/v1/sso/history:POST' needs permissions:
    #    - Update SSO Settings
    #  - '/v1/teacher-app/history:POST' needs permissions:
    #    - Update Teacher App Settings
    #  - '/v1/volume-purchasing-locations/{id}/history:POST' needs permissions:
    #    - Update Volume Purchasing Locations
    #  - '/v1/volume-purchasing-subscriptions/{id}/history:POST' needs permissions:
    #    - Update Volume Purchasing Locations
    #  - '/v2/engage/history:POST' needs permissions:
    #    - Update Engage Settings
    #  - '/v2/enrollment-customizations/{id}/history:POST' needs permissions:
    #    - Update Enrollment Customizations
    #  - '/v2/enrollment/history:POST' needs permissions:
    #    - Update User-Initiated Enrollment
    #  - '/v2/inventory-preload/history:POST' needs permissions:
    #    - Update Inventory Preload Records
    #  - '/v2/mobile-device-prestages/{id}/history:POST' needs permissions:
    #    - Update Mobile Device PreStage Enrollments
    #  - '/v2/patch-software-title-configurations/{id}/history:POST' needs permissions:
    #    - Update Patch Management Software Titles
    #  - '/v2/sso/history:POST' needs permissions:
    #    - Update SSO Settings
    #  - '/v3/check-in/history:POST' needs permissions:
    #    - Update Computer Check-In
    #
    #
    class ObjectHistoryNote < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute note
        #   @return [String]
        note: {
          class: :string,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class ObjectHistoryNote

  end # module OAPISchemas

end # module Jamf
