# Copyright 2025 Pixar
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

    # OAPI Object Model and Enums for: SiteObject
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
    #  - '/v1/sites/{id}/objects:GET' needs permissions:
    #    - Read Sites
    #
    #
    class SiteObject < Jamf::OAPIObject

      # Enums used by this class or others

      OBJECT_TYPE_OPTIONS = [
        'Computer',
        'Peripheral',
        'Licensed Software',
        'Licensed Software Template',
        'Policy',
        'macOS Configuration Profile',
        'Restricted Software',
        'Managed Preference Profile',
        'Computer Group',
        'Mobile Device',
        'Apple TV',
        'Android Device',
        'User Group',
        'iOS Configuration Profile',
        'Mobile Device App',
        'E-book',
        'Mobile Device Group',
        'Classroom',
        'Advanced Computer Search',
        'Advanced Mobile Search',
        'Advanced User Search',
        'Advanced User Content Search',
        'Computer Invitation',
        'Mobile Device Invitation',
        'Mobile Device Enrollment Profile',
        'Device Enrollment Program Instance',
        'Mobile Device Prestage',
        'Computer DEP Prestage',
        'Enrollment Customization',
        'VPP Location',
        'VPP Subscription',
        'VPP Invitation',
        'VPP Assignment',
        'User',
        'Network Integration',
        'Mac App',
        'App Installer',
        'BYO Profile',
        'Self Service Plugin',
        'Software Title',
        'Patch Software Title Summary',
        'Patch Policy',
        'Patch Software Title Configuration',
        'Change Password',
        'Mobile Device Inventory',
        'Computer Inventory',
        'Change Management',
        'Licensed Software License',
        'Unknown'
      ]

      OAPI_PROPERTIES = {

        # @!attribute siteId
        #   @return [String]
        siteId: {
          class: :string,
          required: true
        },

        # @!attribute objectType
        #   @return [String]
        objectType: {
          class: :string,
          required: true,
          enum: OBJECT_TYPE_OPTIONS
        },

        # @!attribute objectId
        #   @return [String]
        objectId: {
          class: :string,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class SiteObject

  end # module OAPISchemas

end # module Jamf
