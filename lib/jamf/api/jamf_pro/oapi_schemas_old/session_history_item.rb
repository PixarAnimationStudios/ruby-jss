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


    # OAPI Object Model and Enums for: SessionHistoryItem
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
    #  - Jamf::OAPISchemas::SessionHistorySearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/jamf-remote-assist/session:GET' needs permissions:
    #    - Read Remote Assist
    #
    #
    class SessionHistoryItem < Jamf::OAPIObject

      # Enums used by this class or others

      SESSION_TYPE_OPTIONS = [
        'ATTENDED',
        'UNATTENDED'
      ]

      STATUS_TYPE_OPTIONS = [
        'STARTED',
        'FINISHED',
        'ERROR'
      ]

      OAPI_PROPERTIES = {

        # @!attribute tenantId
        #   @return [String]
        tenantId: {
          class: :string
        },

        # @!attribute sessionId
        #   @return [String]
        sessionId: {
          class: :string
        },

        # @!attribute deviceId
        #   @return [String]
        deviceId: {
          class: :string
        },

        # @!attribute sessionStartedTimestamp
        #   @return [Jamf::Timestamp]
        sessionStartedTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute sessionEndedTimestamp
        #   @return [Jamf::Timestamp]
        sessionEndedTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute sessionType
        #   @return [String]
        sessionType: {
          class: :string,
          enum: SESSION_TYPE_OPTIONS
        },

        # @!attribute statusType
        #   @return [String]
        statusType: {
          class: :string,
          enum: STATUS_TYPE_OPTIONS
        },

        # @!attribute sessionAdminId
        #   @return [String]
        sessionAdminId: {
          class: :string
        },

        # @!attribute comment
        #   @return [String]
        comment: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # class SessionHistoryItem

  end # module OAPISchemas

end # module Jamf
