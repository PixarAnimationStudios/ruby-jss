# Copyright 2018 Pixar

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

    RSRC_PATH = 'settings/scripts'.freeze

    PRIORTIES = {
      before: 'BEFORE',
      after: 'AFTER',
      at_reboot: 'AT_REBOOT'
    }.freeze

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
    }.freeze
    parse_object_model


   #    {
   # id (integer, optional),
   # name (string, optional),
   # info (string, optional),
   # notes (string, optional),
   # priority (string, optional) = ['BEFORE', 'AFTER', 'AT_REBOOT'],
   # categoryId (integer, optional),
   # categoryName (string, optional),
   # parameter1 (string, optional),
   # parameter2 (string, optional),
   # parameter3 (string, optional),
   # parameter4 (string, optional),
   # parameter5 (string, optional),
   # parameter6 (string, optional),
   # parameter7 (string, optional),
   # parameter8 (string, optional),
   # osRequirements (string, optional),
   # scriptContents (string, optional)
   # }


  end # class

end # module
