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


    # OAPI Object Model and Enums for: EnrollmentProcessTextObject
    #
    #
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
    #  - Jamf::OAPIObject::ProcessTextsSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/enrollment/languages/{language}:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v1/enrollment/languages/{language}:PUT', needs permissions: Update User-Initiated Enrollment
    #  - '/v2/enrollment/languages/{languageId}:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v2/enrollment/languages/{languageId}:PUT', needs permissions: Update User-Initiated Enrollment
    #
    #
    class EnrollmentProcessTextObject < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute languageCode
        #   @return [String]
        languageCode: {
          class: :string
        },

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute title
        #   @return [String]
        title: {
          class: :string
        },

        # @!attribute loginDescription
        #   @return [String]
        loginDescription: {
          class: :string
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute password
        #   @return [String]
        password: {
          class: :string
        },

        # @!attribute loginButton
        #   @return [String]
        loginButton: {
          class: :string
        },

        # @!attribute deviceClassDescription
        #   @return [String]
        deviceClassDescription: {
          class: :string
        },

        # @!attribute deviceClassPersonal
        #   @return [String]
        deviceClassPersonal: {
          class: :string
        },

        # @!attribute deviceClassPersonalDescription
        #   @return [String]
        deviceClassPersonalDescription: {
          class: :string
        },

        # @!attribute deviceClassEnterprise
        #   @return [String]
        deviceClassEnterprise: {
          class: :string
        },

        # @!attribute deviceClassEnterpriseDescription
        #   @return [String]
        deviceClassEnterpriseDescription: {
          class: :string
        },

        # @!attribute deviceClassButton
        #   @return [String]
        deviceClassButton: {
          class: :string
        },

        # @!attribute personalEula
        #   @return [String]
        personalEula: {
          class: :string
        },

        # @!attribute enterpriseEula
        #   @return [String]
        enterpriseEula: {
          class: :string
        },

        # @!attribute eulaButton
        #   @return [String]
        eulaButton: {
          class: :string
        },

        # @!attribute siteDescription
        #   @return [String]
        siteDescription: {
          class: :string
        },

        # @!attribute certificateText
        #   @return [String]
        certificateText: {
          class: :string
        },

        # @!attribute certificateButton
        #   @return [String]
        certificateButton: {
          class: :string
        },

        # @!attribute certificateProfileName
        #   @return [String]
        certificateProfileName: {
          class: :string
        },

        # @!attribute certificateProfileDescription
        #   @return [String]
        certificateProfileDescription: {
          class: :string
        },

        # @!attribute personalText
        #   @return [String]
        personalText: {
          class: :string
        },

        # @!attribute personalButton
        #   @return [String]
        personalButton: {
          class: :string
        },

        # @!attribute personalProfileName
        #   @return [String]
        personalProfileName: {
          class: :string
        },

        # @!attribute personalProfileDescription
        #   @return [String]
        personalProfileDescription: {
          class: :string
        },

        # @!attribute userEnrollmentText
        #   @return [String]
        userEnrollmentText: {
          class: :string
        },

        # @!attribute userEnrollmentButton
        #   @return [String]
        userEnrollmentButton: {
          class: :string
        },

        # @!attribute userEnrollmentProfileName
        #   @return [String]
        userEnrollmentProfileName: {
          class: :string
        },

        # @!attribute userEnrollmentProfileDescription
        #   @return [String]
        userEnrollmentProfileDescription: {
          class: :string
        },

        # @!attribute enterpriseText
        #   @return [String]
        enterpriseText: {
          class: :string
        },

        # @!attribute enterpriseButton
        #   @return [String]
        enterpriseButton: {
          class: :string
        },

        # @!attribute enterpriseProfileName
        #   @return [String]
        enterpriseProfileName: {
          class: :string
        },

        # @!attribute enterpriseProfileDescription
        #   @return [String]
        enterpriseProfileDescription: {
          class: :string
        },

        # @!attribute enterprisePending
        #   @return [String]
        enterprisePending: {
          class: :string
        },

        # @!attribute quickAddText
        #   @return [String]
        quickAddText: {
          class: :string
        },

        # @!attribute quickAddButton
        #   @return [String]
        quickAddButton: {
          class: :string
        },

        # @!attribute quickAddName
        #   @return [String]
        quickAddName: {
          class: :string
        },

        # @!attribute quickAddPending
        #   @return [String]
        quickAddPending: {
          class: :string
        },

        # @!attribute completeMessage
        #   @return [String]
        completeMessage: {
          class: :string
        },

        # @!attribute failedMessage
        #   @return [String]
        failedMessage: {
          class: :string
        },

        # @!attribute tryAgainButton
        #   @return [String]
        tryAgainButton: {
          class: :string
        },

        # @!attribute checkNowButton
        #   @return [String]
        checkNowButton: {
          class: :string
        },

        # @!attribute checkEnrollmentMessage
        #   @return [String]
        checkEnrollmentMessage: {
          class: :string
        },

        # @!attribute logoutButton
        #   @return [String]
        logoutButton: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # class EnrollmentProcessTextObject

  end # class OAPIObject

end # module Jamf
