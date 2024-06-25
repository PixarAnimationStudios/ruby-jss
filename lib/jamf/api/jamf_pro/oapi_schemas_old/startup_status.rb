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


    # OAPI Object Model and Enums for: StartupStatus
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
    #  - '/startup-status:GET' needs permissions:
    #    - Unknown
    #
    #
    class StartupStatus < Jamf::OAPIObject

      # Enums used by this class or others

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
          class: :string,
          nil_ok: true
        },

        # @!attribute percentage
        #   @return [Integer]
        percentage: {
          class: :integer
        },

        # @!attribute warning
        #   @return [String]
        warning: {
          class: :string,
          nil_ok: true
        },

        # @!attribute warningCode
        #   @return [String]
        warningCode: {
          class: :string,
          nil_ok: true,
          enum: WARNING_CODE_OPTIONS
        },

        # @!attribute warningParam
        #   @return [String]
        warningParam: {
          class: :string,
          nil_ok: true
        },

        # @!attribute error
        #   @return [String]
        error: {
          class: :string,
          nil_ok: true
        },

        # @!attribute errorCode
        #   @return [String]
        errorCode: {
          class: :string,
          nil_ok: true,
          enum: ERROR_CODE_OPTIONS
        },

        # @!attribute setupAssistantNecessary
        #   @return [Boolean]
        setupAssistantNecessary: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # class StartupStatus

  end # module OAPISchemas

end # module Jamf
