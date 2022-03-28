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

    # API Object Model and Enums for: NotificationType
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::NotificationV1
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
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::NotificationType
    #
    module NotificationType

      # These enums are used in the properties below

      NOTIFICATION_TYPE_OPTIONS = [
        'APNS_CERT_REVOKED',
        'APNS_CONNECTION_FAILURE',
        'APPLE_SCHOOL_MANAGER_T_C_NOT_SIGNED',
        'BUILT_IN_CA_EXPIRED',
        'BUILT_IN_CA_EXPIRING',
        'BUILT_IN_CA_RENEWAL_FAILED',
        'BUILT_IN_CA_RENEWAL_SUCCESS',
        'CLOUD_LDAP_CERT_EXPIRED',
        'CLOUD_LDAP_CERT_WILL_EXPIRE',
        'COMPUTER_SECURITY_SSL_DISABLED',
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
        'SSO_CERT_WILL_EXPIRE',
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
        'AZURE_AD_MIGRATION_REPORT_GENERATED'
      ]

      

    end # module NotificationType

  end # module OAPIObjectModels

end # module Jamf
