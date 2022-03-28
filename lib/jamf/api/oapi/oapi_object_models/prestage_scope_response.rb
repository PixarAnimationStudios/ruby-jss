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

    # API Object Model and Enums for: PrestageScopeResponse
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
    #  - OAPIObjectModels::PrestageScopeAssignment
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/computer-prestages/{id}/scope:GET', needs permissions: Read Computer PreStage Enrollments
    #  - '/v1/computer-prestages/{id}/scope:PUT', needs permissions: Update Computer PreStage Enrollments
    #  - '/v1/computer-prestages/{id}/scope:POST', needs permissions: Update Computer PreStage Enrollments
    #  - '/v1/computer-prestages/{id}/scope:DELETE', needs permissions: Update Computer PreStage Enrollments
    #  - '/v1/mobile-device-prestages/{id}/scope:GET', needs permissions: Read Mobile Device PreStage Enrollments
    #  - '/v1/mobile-device-prestages/{id}/scope:PUT', needs permissions: Update Mobile Device PreStage Enrollments
    #  - '/v1/mobile-device-prestages/{id}/scope:POST', needs permissions: Update Mobile Device PreStage Enrollments
    #  - '/v1/mobile-device-prestages/{id}/scope:DELETE', needs permissions: Update Mobile Device PreStage Enrollments
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::PrestageScopeResponse
    #
    module PrestageScopeResponse

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute prestageId
        #   @return [Integer]
        prestageId: {
          class: :integer
        },

        # @!attribute assignments
        #   @return [Array<Jamf::PrestageScopeAssignment>]
        assignments: {
          class: Jamf::PrestageScopeAssignment,
          multi: true
        },

        # @!attribute versionLock
        #   @return [Integer]
        versionLock: {
          class: :integer
        }

      } # end OAPI_PROPERTIES

    end # module PrestageScopeResponse

  end # module OAPIObjectModels

end # module Jamf
