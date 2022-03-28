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

    # API Object Model and Enums for: DeploymentTask
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::DeploymentTaskSearchResults
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
    #   include Jamf::OAPIObjectModels::DeploymentTask
    #
    module DeploymentTask

      # These enums are used in the properties below

      STATUS_OPTIONS = [
        'COMMAND_QUEUED',
        'NO_COMMAND',
        'PENDING_MANIFEST',
        'COMPLETE',
        'GAVE_UP',
        'UNKNOWN'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute [r] computerId
        #   @return [String]
        computerId: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] computerName
        #   @return [String]
        computerName: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] version
        #   @return [String]
        version: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] updated
        #   @return [Jamf::Timestamp]
        updated: {
          class: Jamf::Timestamp,
          readonly: true
        },

        # Status of this Jamf Connect deployment task. "Command" below refers to an `InstallEnterpriseApplication` command. Tasks that are not finished (i.e., `COMPLETE` or `GAVE_UP`) are evaluated once every thirty minutes, so the status value for a device may lag behind a successful Jamf Connect package install up to thirty minutes. * `COMMAND_QUEUED` - command has been queued * `NO_COMMAND` - command has not yet been queued * `PENDING_MANIFEST` - task is waiting to obtain a valid package manifest before a command can be queued * `COMPLETE` - command has been completed successfully * `GAVE_UP` - the command failed with an error or the device did not process it in a reasonable amount of time * `UNKNOWN` - unknown; tasks in this state will be evaluated
        # @!attribute status
        #   @return [String]
        status: {
          class: :string,
          enum: STATUS_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # module DeploymentTask

  end # module OAPIObjectModels

end # module Jamf
