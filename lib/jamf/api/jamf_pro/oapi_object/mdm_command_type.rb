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


    # OAPI Object Model and Enums for: MdmCommandType
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
    #  - Jamf::OAPIObject::MdmCommand
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
    class MdmCommandType < OAPIObject

      # Enums used by this class or others

      VALUE_OPTIONS = [
        'DEVICE_LOCATION',
        'ENABLE_LOST_MODE',
        'ACTIVATION_LOCK_BYPASS_CODE',
        'CLEAR_ACTIVATION_LOCK_BYPASS_CODE',
        'ACCOUNT_CONFIGURATION',
        'REFRESH_CELLULAR_PLANS',
        'SETTINGS',
        'CONTENT_CACHING_INFORMATION',
        'UNMANAGE_DEVICE',
        'ERASE_DEVICE',
        'DEVICE_LOCK',
        'CLEAR_PASSCODE',
        'DELETE_USER',
        'DEVICE_INFORMATION',
        'SHUT_DOWN_DEVICE',
        'RESTART_DEVICE',
        'INSTALL_BYO_PROFILE',
        'REMOVE_PROFILE',
        'INSTALL_PROFILE',
        'REINSTALL_PROFILE',
        'INSTALL_PROVISIONING_PROFILE',
        'PROFILE_LIST',
        'REMOVE_PROVISIONING_PROFILE',
        'CERTIFICATE_LIST',
        'INSTALLED_APPLICATION_LIST',
        'MANAGED_APPLICATION_LIST',
        'INSTALL_APPLICATION',
        'INSTALL_ENTERPRISE_APPLICATION',
        'INSTALL_PACKAGE',
        'REMOVE_APPLICATION',
        'MANAGED_MEDIA_LIST',
        'INSTALL_MEDIA',
        'REMOVE_MEDIA',
        'APPLY_REDEMPTION_CODE',
        'SETTINGS_ENABLE_PERSONAL_HOTSPOT',
        'SETTINGS_DISABLE_PERSONAL_HOTSPOT',
        'UPDATE_INVENTORY',
        'WALLPAPER',
        'DEVICE_CONFIGURED',
        'RESTRICTIONS',
        'ENABLE_REMOTE_DESKTOP',
        'DISABLE_REMOTE_DESKTOP',
        'SECURITY_INFO',
        'MARK_AS_UNMANAGED',
        'QUERY_RESPONSES',
        'AVAILABLE_OS_UPDATES',
        'PROVISIONING_PROFILE_LIST',
        'SCHEDULE_OS_UPDATE',
        'OS_UPDATE_STATUS',
        'INVITE_TO_PROGRAM',
        'PUSH_TRIGGER',
        'CLEAR_RESTRICTIONS_PASSWORD',
        'BLANK_PUSH',
        'CORPORATE_WIPE',
        'DEVICE_INFO_ACCOUNT_HASH',
        'DEVICE_INFO_ITUNES_ACTIVE',
        'DEVICE_INFO_LAST_CLOUD_BACKUP_DATE',
        'DEVICE_INFO_ACTIVE_MANAGED_USERS',
        'DEVICE_NAME',
        'ENABLE_ACTIVATION_LOCK',
        'DISABLE_ACTIVATION_LOCK',
        'LAST_CLOUD_BACKUP_DATE',
        'MARK_AS_CORPORATE_WIPE',
        'REQUEST_MIRRORING',
        'SETTINGS_DISABLE_DATA_ROAMING',
        'SETTINGS_DISABLE_VOICE_ROAMING',
        'SETTINGS_DISABLE_DIAGNOSTIC_SUBMISSION',
        'SETTINGS_DISABLE_APP_ANALYTICS',
        'SETTINGS_ENABLE_DATA_ROAMING',
        'SETTINGS_ENABLE_VOICE_ROAMING',
        'SETTINGS_ENABLE_DIAGNOSTIC_SUBMISSION',
        'SETTINGS_ENABLE_APP_ANALYTICS',
        'SETTINGS_ENABLE_BLUETOOTH',
        'SETTINGS_DISABLE_BLUETOOTH',
        'SETTINGS_MOBILE_DEVICE_PER_APP_VPN',
        'SETTINGS_MOBILE_DEVICE_APPLICATION_ATTRIBUTES',
        'STOP_MIRRORING',
        'PASSCODE_LOCK_GRACE_PERIOD',
        'SCHEDULE_OS_UPDATE_SCAN',
        'PLAY_LOST_MODE_SOUND',
        'DISABLE_LOST_MODE',
        'LOG_OUT_USER',
        'USER_LIST',
        'VALIDATE_APPLICATIONS',
        'UNLOCK_USER_ACCOUNT',
        'SET_RECOVERY_LOCK',
        'UNKNOWN'
      ]

      OAPI_PROPERTIES = {

        # @!attribute value
        #   @return [String]
        value: {
          class: :string,
          enum: VALUE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class MdmCommandType

  end # class OAPIObject

end # module Jamf
