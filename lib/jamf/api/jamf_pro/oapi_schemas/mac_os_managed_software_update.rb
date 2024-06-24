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


    # OAPI Object Model and Enums for: MacOsManagedSoftwareUpdate
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
    #  - '/v1/macos-managed-software-updates/send-updates:POST' needs permissions:
    #    - Send Computer Remote Command to Download and Install OS X Update
    #
    #
    class MacOsManagedSoftwareUpdate < Jamf::OAPIObject

      # Enums used by this class or others

      UPDATE_ACTION_OPTIONS = [
        'DOWNLOAD_AND_INSTALL',
        'DOWNLOAD_ONLY'
      ]

      PRIORITY_OPTIONS = [
        'HIGH',
        'LOW'
      ]

      OAPI_PROPERTIES = {

        # @!attribute deviceIds
        #   @return [Array<String>]
        deviceIds: {
          class: :string,
          multi: true
        },

        # @!attribute groupId
        #   @return [String]
        groupId: {
          class: :string
        },

        # Allow users to defer the update the provided number of times before macOS forces the update. If a value is provided, the Software Update will use the InstallLater install action.
        # @!attribute maxDeferrals
        #   @return [Integer]
        maxDeferrals: {
          class: :integer,
          minimum: 0
        },

        # If no value is provided, the version will default to latest version based on device eligibility.
        # @!attribute version
        #   @return [String]
        version: {
          class: :string
        },

        # If no value is provided, the skipVersionVerification will default to false. If a value is provided, the specified version will be forced to complete DownloadAndInstall install action.
        # @!attribute skipVersionVerification
        #   @return [Boolean]
        skipVersionVerification: {
          class: :boolean
        },

        # ApplyMajorUpdate setting is available only when updating to the latest version based on device eligibility. If no value is provided, the calculated latest version will only include minor version updates. If a value is provided, the calculated latest version will include minor and major version updates.
        # @!attribute applyMajorUpdate
        #   @return [Boolean]
        applyMajorUpdate: {
          class: :boolean
        },

        # MaxDeferral is ignored if using the DownloadOnly install action.
        # @!attribute updateAction
        #   @return [String]
        updateAction: {
          class: :string,
          enum: UPDATE_ACTION_OPTIONS
        },

        # If not set, forceRestart will default to false. Can only be true if using the DownloadAndInstall install action and the devices the command is sent to are on macOs 11 or higher. If true, the DownloadAndInstall action is performed, a restart will be forced. MaxDeferral will be ignored if defined. 
        # @!attribute forceRestart
        #   @return [Boolean]
        forceRestart: {
          class: :boolean
        },

        # Priority can only be configured on macOS 12.3 and above, for minor updates only. Any version below 12.3 is always Low and cannot be changed until prerequisites are met. When qualified, if not explicitly set, priority will default to High
        # @!attribute priority
        #   @return [String]
        priority: {
          class: :string,
          enum: PRIORITY_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class MacOsManagedSoftwareUpdate

  end # module OAPISchemas

end # module Jamf
