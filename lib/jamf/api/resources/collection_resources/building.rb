# Copyright 2020 Pixar

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

# The Module
module Jamf

  # Classes
  #####################################

  # A building defined in the JSS
  class Building < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    extend Jamf::BulkDeletable
    include Jamf::ChangeLog

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'buildings'.freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :j_id,
        identifier: :primary,
        readonly: true
      },

      # @!attribute name
      #   @return [String]
      name: {
        class: :string,
        identifier: true,
        validator: :non_empty_string,
        required: true,
        filter_key: true
      },

      # @!attribute street1
      #   @return [String]
      streetAddress1: {
        class: :string,
        filter_key: true
      },

      # @!attribute street2
      #   @return [String]
      streetAddress2: {
        class: :string,
        filter_key: true
      },

      # @!attribute city
      #   @return [String]
      city: {
        class: :string,
        filter_key: true
      },

      # @!attribute state_province
      #   @return [String]
      stateProvince: {
        class: :string,
        aliases: %i[state province],
        filter_key: true
      },

      # @!attribute zip_postal_code
      #   @return [String]
      zipPostalCode: {
        class: :string,
        aliases: %i[zip zipcode zip_code postal_code postalcode],
        filter_key: true
      },

      # @!attribute country
      #   @return [String]
      country: {
        class: :string,
        filter_key: true
      }
    }.freeze

    parse_object_model

  end # class

end # module
