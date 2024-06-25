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


    # OAPI Object Model and Enums for: NotificationType
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
    #  - Jamf::OAPISchemas::NotificationV1
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class NotificationType < Jamf::OAPIObject

      # Enums used by this class or others

      VALUE_OPTIONS = [
        'APNS_CERT_REVOKED',
        'APNS_CONNECTION_FAILURE',
        'APPLE_SCHOOL_MANAGER_T_C_NOT_SIGNED',
        'BUILT_IN_CA_EXPIRED',
        'BUILT_IN_CA_EXPIRING',
        'BUILT_IN_CA_RENEWAL_FAILED',
        'BUILT_IN_CA_RENEWAL_SUCCESS',
        'CLOUD_LDAP_CERT_EXPIRED',
        'CLOUD_LDAP_CERT_WILL_EXPIRE',
        'DEP_INSTANCE_EXPIRED',
        'DEP_INSTANCE_WILL_EXPIRE',
        'DEVICE_ENROLLMENT_PROGRAM_T_C_NOT_SIGNED',
        'EXCEEDED_LICENSE_COUNT',
        'FREQUENT_INVENTORY_COLLECTION_POLICY',
        'GSX_CERT_EXPIRED',
        'GSX_CERT_WILL_EXPIRE',
        'HCL_BIND_ERROR',
        'HCL_ERROR',
        'INSECURE_LDAP',
        'INVALID_REFERENCES_EXT_ATTR',
        'INVALID_REFERENCES_POLICIES',
        'INVALID_REFERENCES_SCRIPTS',
        'JAMF_CONNECT_UPDATE',
        'JAMF_PROTECT_UPDATE',
        'JIM_ERROR',
        'LDAP_CONNECTION_CHECK_THROUGH_JIM_FAILED',
        'LDAP_CONNECTION_CHECK_THROUGH_JIM_SUCCESSFUL',
        'MDM_EXTERNAL_SIGNING_CERTIFICATE_EXPIRED',
        'MDM_EXTERNAL_SIGNING_CERTIFICATE_EXPIRING',
        'MDM_EXTERNAL_SIGNING_CERTIFICATE_EXPIRING_TODAY',
        'MII_HEARTBEAT_FAILED_NOTIFICATION',
        'MII_INVENTORY_UPLOAD_FAILED_NOTIFICATION',
        'MII_UNATHORIZED_RESPONSE_NOTIFICATION',
        'PATCH_EXTENTION_ATTRIBUTE',
        'PATCH_UPDATE',
        'POLICY_MANAGEMENT_ACCOUNT_PAYLOAD_SECURITY_MULTIPLE',
        'POLICY_MANAGEMENT_ACCOUNT_PAYLOAD_SECURITY_SINGLE',
        'PUSH_CERT_EXPIRED',
        'PUSH_CERT_WILL_EXPIRE',
        'PUSH_PROXY_CERT_EXPIRED',
        'SSO_CERT_EXPIRED',
        'SSO_IDP_CERT_EXPIRED',
        'SSO_CERT_WILL_EXPIRE',
        'SSO_IDP_CERT_WILL_EXPIRE',
        'TOMCAT_SSL_CERT_EXPIRED',
        'TOMCAT_SSL_CERT_WILL_EXPIRE',
        'USER_INITIATED_ENROLLMENT_MANAGEMENT_ACCOUNT_SECURITY_ISSUE',
        'USER_MAID_DUPLICATE_ERROR',
        'USER_MAID_MISMATCH_ERROR',
        'USER_MAID_ROSTER_DUPLICATE_ERROR',
        'VPP_ACCOUNT_EXPIRED',
        'VPP_ACCOUNT_WILL_EXPIRE',
        'VPP_TOKEN_REVOKED',
        'DEVICE_COMPLIANCE_CONNECTION_ERROR',
        'CONDITIONAL_ACCESS_CONNECTION_ERROR',
        'AZURE_AD_MIGRATION_REPORT_GENERATED',
        'BEYOND_CORP_CONNECTION_ERROR',
        'APP_INSTALLERS_NEW_APP_VERSION_AVAILABLE',
        'APP_INSTALLERS_NEW_APP_VERSION_DEPLOYMENT_STARTED',
        'APP_INSTALLERS_APP_VERSION_REMOVED',
        'APP_INSTALLERS_APP_TITLE_REMOVED',
        'APP_INSTALLERS_DEPLOYMENT_INSTALLATION_FAILED'
      ]

      OAPI_PROPERTIES = {

        # @!attribute value
        #   @return [String]
        value: {
          class: :string,
          enum: VALUE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class NotificationType

  end # module OAPISchemas

end # module Jamf
