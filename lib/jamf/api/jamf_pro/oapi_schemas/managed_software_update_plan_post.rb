# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: ManagedSoftwareUpdatePlanPost
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.14.1-t1740408745756
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
    #  - Jamf::OAPISchemas::PlanDevicePost
    #  - Jamf::OAPISchemas::PlanConfigurationPost
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/managed-software-updates/plans:POST' needs permissions:
    #    - Create Managed Software Updates
    #    - Read Computers
    #    - Read Mobile Devices
    #    - Send Computer Remote Command to Download and Install OS X Update
    #    - Send Mobile Device Remote Command to Download and Install iOS Update
    #
    #
    class ManagedSoftwareUpdatePlanPost < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute devices
        #   @return [Array<Jamf::OAPISchemas::PlanDevicePost>]
        devices: {
          class: Jamf::OAPISchemas::PlanDevicePost,
          required: true,
          multi: true,
          min_items: 1,
          unique_items: true
        },

        # @!attribute config
        #   @return [Jamf::OAPISchemas::PlanConfigurationPost]
        config: {
          class: Jamf::OAPISchemas::PlanConfigurationPost,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class ManagedSoftwareUpdatePlanPost

  end # module OAPISchemas

end # module Jamf
