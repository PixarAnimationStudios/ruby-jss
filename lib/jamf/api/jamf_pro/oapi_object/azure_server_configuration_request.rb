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


    # OAPI Object Model and Enums for: AzureServerConfigurationRequest
    #
    # Description of this class from the OAPI Schema:
    #   Azure Cloud Identity Provider configuration request
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
    #  - Jamf::OAPIObject::AzureConfigurationRequest
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::AzureMappings
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class AzureServerConfigurationRequest < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute tenantId
        #   @return [String]
        tenantId: {
          class: :string,
          required: true
        },

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean,
          required: true
        },

        # Azure Cloud Identity Provider mappings
        # @!attribute mappings
        #   @return [Hash{Symbol: Object}]
        mappings: {
          class: :hash,
          required: true
        },

        # @!attribute searchTimeout
        #   @return [Integer]
        searchTimeout: {
          class: :integer,
          required: true,
          minimum: 5,
          maximum: 600
        },

        # Use this field to enable transitive membership lookup with Single Sign On
        # @!attribute transitiveMembershipEnabled
        #   @return [Boolean]
        transitiveMembershipEnabled: {
          class: :boolean,
          required: true
        },

        # Use this field to set user field mapping for transitive membership lookup with Single Sign On
        # @!attribute transitiveMembershipUserField
        #   @return [String]
        transitiveMembershipUserField: {
          class: :string,
          required: true
        },

        # Use this field to enable transitive membership lookup. This setting would not apply to Single Sign On
        # @!attribute transitiveDirectoryMembershipEnabled
        #   @return [Boolean]
        transitiveDirectoryMembershipEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute code
        #   @return [String]
        code: {
          class: :string,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class AzureServerConfigurationRequest

  end # class OAPIObject

end # module Jamf
