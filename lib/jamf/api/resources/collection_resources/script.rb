# Copyright 2019 Pixar

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
  class Script < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    include Jamf::ChangeLog
    include Jamf::Referable

    # Constants
    #####################################

    RSRC_PATH = 'scripts'.freeze

    RSRC_VERSION = 'v1'.freeze

    PRIORITY_BEFORE = 'BEFORE'.freeze
    PRIORITY_AFTER = 'AFTER'.freeze
    PRIORITY_AT_REBOOT = 'AT_REBOOT'.freeze

    PRIORTIES = [
      PRIORITY_BEFORE,
      PRIORITY_AFTER,
      PRIORITY_AT_REBOOT
    ].freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute name
      #   @return [String]
      name: {
        class: :string,
        identifier: true
      },

      # @!attribute info
      #   @return [String]
      info: {
        class: :string
      },

      # @!attribute notes
      #   @return [String]
      notes: {
        class: :string
      },

      # @!attribute priority
      #   @return [String]
      priority: {
        class: :string,
        enum: Jamf::Script::PRIORTIES
      },

      # TODO: Jamf should standardize object references
      # this should be a Category::Reference object

      # @!attribute categoryId
      #   @return [Integer]
      categoryId: {
        class: :integer
      },

      # @!attribute categoryName
      #   @return [String]
      categoryName: {
        class: :string
      },

      # @!attribute osRequirements
      #   @return [String]
      osRequirements: {
        class: :string
      },

      # @!attribute scriptContents
      #   @return [String]
      scriptContents: {
        class: :string,
        validate: :script_contents,
        aliases: %i[code]
      },

      # @!attribute parameter4
      #   @return [String]
      parameter4: {
        class: :string
      },

      # @!attribute parameter5
      #   @return [String]
      parameter5: {
        class: :string
      },

      # @!attribute parameter6
      #   @return [String]
      parameter6: {
        class: :string
      },

      # @!attribute parameter7
      #   @return [String]
      parameter7: {
        class: :string
      },

      # @!attribute parameter8
      #   @return [String]
      parameter8: {
        class: :string
      },

      # @!attribute parameter9
      #   @return [String]
      parameter9: {
        class: :string
      },

      # @!attribute parameter10
      #   @return [String]
      parameter10: {
        class: :string
      },

      # @!attribute parameter11
      #   @return [String]
      parameter11: {
        class: :string
      }
    }.freeze

    parse_object_model


    # Class Methods
    ##################################

    def self.scriptContents(scr_ident, cnx: Jamf.cnx)
      id = valid_id scr_ident
      raise Jamf::NoSuchItemError, "No script matches '#{scr_ident}'" unless id
      cnx.download "#{RSRC_VERSION}/#{RSRC_PATH}/#{id}/download"
    end

  end # class

end # module
