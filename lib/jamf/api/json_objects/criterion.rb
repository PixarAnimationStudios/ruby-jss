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

# The module
module Jamf

  # A 'location' for a computer prestage in Jamf Pro
  class Criterion < Jamf::JSONObject

    # the acceptable strings for and/or
    AND = 'and'.freeze
    OR = 'or'.freeze

    AND_OR = [
      AND,
      OR
    ].freeze

    # These are the available search-types for building criteria
    IS = 'is'.freeze
    IS_NOT = 'is not'.freeze
    LIKE = 'like'.freeze
    NOT_LIKE = 'not like'.freeze
    HAS = 'has'.freeze
    HAS_NOT = 'does not have'.freeze
    MORE_THAN = 'more than'.freeze
    GREATER_THAN = 'greater than'.freeze
    LESS_THAN = 'less than'.freeze
    GREATER_OR_EQUAL = 'greater than or equal'.freeze
    LESS_OR_EQUAL = 'less than or equal'.freeze
    BEFORE_DATE = 'before (yyyy-mm-dd)'.freeze
    AFTER_DATE = 'after (yyyy-mm-dd)'.freeze
    MORE_THAN_DAYS_AGO = 'more than x days ago'.freeze
    LESS_THAN_DAYS_AGO = 'less than x days ago'.freeze
    IN_MORE_THAN_DAYS = 'in more than x days'.freeze
    IN_LESS_THAN_DAYS = 'in less than x days'.freeze
    MEMBER = 'member of'.freeze
    NOT_MEMBER = 'not member of'.freeze
    CURRENT = 'current'.freeze
    NOT_CURRENT = 'not current'.freeze
    REGEX = 'matches regex'.freeze
    NOT_REGEX = 'does not match regex'.freeze

    SEARCH_TYPES = [
      IS,
      IS_NOT,
      LIKE,
      NOT_LIKE,
      HAS,
      HAS_NOT,
      MORE_THAN,
      GREATER_THAN,
      LESS_THAN,
      GREATER_OR_EQUAL,
      LESS_OR_EQUAL,
      BEFORE_DATE,
      AFTER_DATE,
      MORE_THAN_DAYS_AGO,
      LESS_THAN_DAYS_AGO,
      IN_MORE_THAN_DAYS,
      IN_LESS_THAN_DAYS,
      MEMBER,
      NOT_MEMBER,
      CURRENT,
      NOT_CURRENT,
      REGEX,
      NOT_REGEX
    ].freeze

    OBJECT_MODEL = {

      # @!attribute name - the attribute name for this criterion
      #   @return [String]
      name: {
        class: :string,
        required: true
      },

      # @!attribute priority - Not used? Seems to always be zero.
      #   Order is determined by array index, so not really sure,
      #   possibly a holdover from classic API/XML
      #   @return [Integer]
      priority: {
        class: :integer
      },

      # @!attribute andOr - How this criterion is joined to the previous:
      #   'and' or 'or', defaults to 'and'.
      #   meaningless for the first criterion in an array
      #   @return [String]
      andOr: {
        class: :string,
        enum: Jamf::Criterion::AND_OR
      },

      # @!attribute searchType - How to compare the attribute value to
      #   the search value
      #   @return [String]
      searchType: {
        class: :string,
        enum: Jamf::Criterion::SEARCH_TYPES,
        required: true
      },

      # @!attribute value - the value to compare to the attribute
      #   @return [String]
      value: {
        class: :string,
        required: true
      },

      # @!attribute isOpeningParen - does this criterion start with an openParen?
      #   @return [Boolean]
      isOpeningParen: {
        class: :boolean
      },

      # @!attribute isClosingParen - does this criterion end with a closeParen?
      #   @return [Boolean]
      isClosingParen: {
        class: :boolean
      }

    }.freeze

    parse_object_model

  end # class location

end # module
