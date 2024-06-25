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


    # OAPI Object Model and Enums for: DeploymentTask
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
    #  - Jamf::OAPISchemas::DeploymentTaskSearchResults
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
    class DeploymentTask < Jamf::OAPIObject

      # Enums used by this class or others

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
          format: 'date-time',
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

    end # class DeploymentTask

  end # module OAPISchemas

end # module Jamf
