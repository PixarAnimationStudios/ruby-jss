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

    # API Object Model and Enums for: StartupStatus
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
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/startup-status:GET', needs permissions: Unknown
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::StartupStatus
    #
    module StartupStatus

      # These enums are used in the properties below

      STEP_CODE_OPTIONS = [
        'SERVER_INIT_START',
        'SERVER_INIT_ANALYZING_WEBAPP',
        'SERVER_INIT_POPULATING_NAVIGATION',
        'SERVER_INIT_POPULATING_OBJECTS',
        'SERVER_INIT_INITIALIZING_OBJ',
        'SERVER_INIT_VERIFYING_CACHE',
        'SERVER_INIT_INITIALIZING_CHANGE_MANAGEMENT',
        'SERVER_INIT_INITIALIZING_COMMUNICATION_SYSTEM',
        'SERVER_INIT_INITIALIZING_MDM_QUEUE_MONITOR',
        'SERVER_INIT_CALCULATING_SMART_GROUPS',
        'SERVER_INIT_DB_SCHEMA_COMPARE',
        'SERVER_INIT_DB_TABLE_CHECK_FOR_RENAME',
        'SERVER_INIT_DB_TABLE_ALTER',
        'SERVER_INIT_DB_TABLE_ANALYZING',
        'SERVER_INIT_DB_TABLE_CREATE',
        'SERVER_INIT_DB_TABLE_DROP',
        'SERVER_INIT_DB_TABLE_RENAME',
        'SERVER_INIT_DB_COLUMN_RENAME',
        'SERVER_INIT_DB_COLUMN_ENCODING_CHANGE_STEP_1',
        'SERVER_INIT_DB_COLUMN_ENCODING_CHANGE_STEP_2',
        'SERVER_INIT_DB_COLUMN_ENCODING_CHANGE_STEP_3',
        'SERVER_INIT_DB_UPGRADE_CHECK',
        'SERVER_INIT_DB_UPGRADE_COMPLETE',
        'SERVER_INIT_SS_GENERATE_NOTIFICATIONS',
        'SERVER_INIT_SS_GENERATE_NOTIFICATIONS_STATUS',
        'SERVER_INIT_SS_GENERATE_NOTIFICATIONS_FINALIZE',
        'SERVER_INIT_PKI_MIGRATION_DONE',
        'SERVER_INIT_PKI_MIGRATION_STATUS',
        'SERVER_INIT_MEMCACHED_ENDPOINTS_CHECK',
        'SERVER_INIT_CACHE_FLUSHING',
        'SERVER_INIT_COMPLETE'
      ]

      WARNING_CODE_OPTIONS = [
        'SERVER_INIT_WARNING_DB_TABLE_ENCODING'
      ]

      ERROR_CODE_OPTIONS = [
        'CACHE_CONFIGURATION_ERROR',
        'SECONDARY_NODE_STARTUP_ERROR',
        'MORE_THAN_ONE_CLUSTER_SETTINGS_ERROR',
        'PRIMARY_NODE_NOT_SET_ERROR',
        'DATABASE_ERROR',
        'DATABASE_PASSWORD_MISSING',
        'EHCACHE_ERROR',
        'FLAG_INITIALIZATION_FAILED',
        'MEMCACHED_ERROR',
        'DATABASE_MYISAM_ERROR',
        'OLD_VERSION_ERROR'
      ]

      OAPI_PROPERTIES = {

        # @!attribute step
        #   @return [String]
        step: {
          class: :string
        },

        # @!attribute stepCode
        #   @return [String]
        stepCode: {
          class: :string,
          enum: STEP_CODE_OPTIONS
        },

        # @!attribute stepParam
        #   @return [String]
        stepParam: {
          class: :string
        },

        # @!attribute percentage
        #   @return [Integer]
        percentage: {
          class: :integer
        },

        # @!attribute warning
        #   @return [String]
        warning: {
          class: :string
        },

        # @!attribute warningCode
        #   @return [String]
        warningCode: {
          class: :string,
          enum: WARNING_CODE_OPTIONS
        },

        # @!attribute warningParam
        #   @return [String]
        warningParam: {
          class: :string
        },

        # @!attribute error
        #   @return [String]
        error: {
          class: :string
        },

        # @!attribute errorCode
        #   @return [String]
        errorCode: {
          class: :string,
          enum: ERROR_CODE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # module StartupStatus

  end # module OAPIObjectModels

end # module Jamf
