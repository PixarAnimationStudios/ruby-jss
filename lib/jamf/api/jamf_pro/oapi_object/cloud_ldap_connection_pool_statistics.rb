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


    # OAPI Object Model and Enums for: CloudLdapConnectionPoolStatistics
    #
    # Description of this class from the OAPI Schema:
    #   Ldap Cloud Identity Provider conection pool statistics
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/cloud-ldaps/{id}/connection/bind:GET', needs permissions: Read LDAP Servers
    #  - '/v1/cloud-ldaps/{id}/connection/search:GET', needs permissions: Read LDAP Servers
    #  - '/v2/cloud-ldaps/{id}/connection/bind:GET', needs permissions: Read LDAP Servers
    #  - '/v2/cloud-ldaps/{id}/connection/search:GET', needs permissions: Read LDAP Servers
    #
    #
    class CloudLdapConnectionPoolStatistics < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute numConnectionsClosedDefunct
        #   @return [Integer]
        numConnectionsClosedDefunct: {
          class: :integer,
          format: int64
        },

        # @!attribute numConnectionsClosedExpired
        #   @return [Integer]
        numConnectionsClosedExpired: {
          class: :integer,
          format: int64
        },

        # @!attribute numConnectionsClosedUnneeded
        #   @return [Integer]
        numConnectionsClosedUnneeded: {
          class: :integer,
          format: int64
        },

        # @!attribute numFailedCheckouts
        #   @return [Integer]
        numFailedCheckouts: {
          class: :integer,
          format: int64
        },

        # @!attribute numFailedConnectionAttempts
        #   @return [Integer]
        numFailedConnectionAttempts: {
          class: :integer,
          format: int64
        },

        # @!attribute numReleasedValid
        #   @return [Integer]
        numReleasedValid: {
          class: :integer,
          format: int64
        },

        # @!attribute numSuccessfulCheckouts
        #   @return [Integer]
        numSuccessfulCheckouts: {
          class: :integer,
          format: int64
        },

        # @!attribute numSuccessfulCheckoutsNewConnection
        #   @return [Integer]
        numSuccessfulCheckoutsNewConnection: {
          class: :integer,
          format: int64
        },

        # @!attribute numSuccessfulConnectionAttempts
        #   @return [Integer]
        numSuccessfulConnectionAttempts: {
          class: :integer,
          format: int64
        },

        # @!attribute maximumAvailableConnections
        #   @return [Integer]
        maximumAvailableConnections: {
          class: :integer,
          format: int64
        },

        # @!attribute numSuccessfulCheckoutsWithoutWaiting
        #   @return [Integer]
        numSuccessfulCheckoutsWithoutWaiting: {
          class: :integer,
          format: int64
        },

        # @!attribute numSuccessfulCheckoutsAfterWaiting
        #   @return [Integer]
        numSuccessfulCheckoutsAfterWaiting: {
          class: :integer,
          format: int64
        },

        # @!attribute numAvailableConnections
        #   @return [Integer]
        numAvailableConnections: {
          class: :integer,
          format: int64
        }

      } # end OAPI_PROPERTIES

    end # class CloudLdapConnectionPoolStatistics

  end # class OAPIObject

end # module Jamf
