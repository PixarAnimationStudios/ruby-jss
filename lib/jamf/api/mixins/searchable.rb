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

module Jamf

  # Code for CollectionResources that have a .../searchObjects resource.
  # These resources provide for basic searching as will as sorting and paging of
  # the found set.
  #
  # NOTE: This module provides class methods, not instance methods, and
  # therefore must be mixed in with `extend` and not `include`
  #
  # Classes extended with this module *must* define:
  #
  #   SEARCH_RSRC [String] the resource to which the search is POSTed.
  #
  #
  # Classes including this module *may* define:
  #
  #   SEARCH_FIELDS [Hash{Symbol: Symbol}]
  #
  # The hash keys are the names of searchable fields, e.g. 'name', or 'udid'
  # and the values are the class expected for the field, one of:
  # :string, :integer, or :boolean
  #
  # Without defining search fields, every search returns all objects, but
  # the sorting and paging options are honored.
  #
  # If search fields are provided, then they can be specified when performing
  # a search. If more than one is specified, they are AND'ed together.
  #
  # To Search:
  #
  # 1) Set result sort order
  #
  # If you want sorted results, first set the sort order with a combination of
  # `MyClass.search_result_order = field, dir` where field is the name of the
  # sort fiend and dir is :asc or :desc
  #
  # If you want a multi-level sort, set the first sort field as above,
  # then use `MyClass.search_result_order_append field, dir` to add
  # subsequent sort fields
  #
  # To clear them out and start over, call `MyClass.clear_search_result_order`
  #
  # 2) Set page size
  #
  #  If you want paged results then call `MyClass.search_result_page_size = X`
  #  before starting your seacch
  #
  # 3) Do the search:
  #   MyClass.search
  #
  module Searchable

    SORT_DIRECTIONS = {
      asc: 'ASC',
      desc: 'DESC'
    }.freeze

    def search_result_page_size
      @search_result_page_size ||= 0
    end

    def search_result_page_size=(size)
      raise 'Size must be a non-negative integer' unless size.is_a?(Integer) && size >= 0
      @search_result_page_size = size
    end

    def search_result_order
      @search_result_order ||= []
    end

    def search_result_order=(fieldname, dir = :asc)
      raise 'direction must be either :asc, or :desc' unless SORT_DIRECTIONS.key? dir
      @search_result_order = [{ field: fieldname, direction: SORT_DIRECTIONS[dir] }]
    end

    def search_result_order_append(fieldname, dir = :asc)
      raise 'direction must be either :asc, or :desc' unless SORT_DIRECTIONS.key? dir
      search_result_order << { field: fieldname, direction: SORT_DIRECTIONS[dir] }
    end

    def clear_search_result_order
      @search_result_order = []
    end

    # TODO: occasional excludedIds array
    def search(pageNumber: 0, cnx: Jamf.cnx, load_all: true, **terms)
      raise "#{self} is not searchable in the API" unless defined? self::SEARCH_RSRC

      search_body = {
        pageNumber: pageNumber,
        pageSize: @search_result_page_size,
        isLoadToEnd: load_all,
        orderBy: @search_result_order
      }

      if defined? self::SEARCH_FIELDS
        terms.each do |fld, val|
          next unless self::SEARCH_FIELDS.key? fld

          case self::SEARCH_FIELDS[fld]
          when :integer
            val = Jamf::Validate.integer val, "Search value for #{fld} must be an Integer"
          when :string
            val = Jamf::Validate.string val, "Search value for #{fld} must be a String"
          when :boolean
            val = Jamf::Validate.boolean val, "Search value for #{fld} must be a boolean"
          end # case

          search_body[fld] = val
        end # terms.each
      end # if defined? self::SEARCH_FIELDS

      cnx.post self::SEARCH_RSRC, search_body

    end # def search

    class OrderBy < Jamf::JSONObject

      SORT_DIRECTIONS = {
        asc: 'ASC',
        desc: 'DESC'
      }.freeze

      OBJECT_MODEL = {

        # @!attribute field
        #   @return [String]
        field: {
          class: :string
        },

        # @!attribute direction
        #   @return [String]
        direction: {
          class: :string,
          enum: SORT_DIRECTIONS
        }
      }.freeze
      parse_object_model
    end # class Orderby

    class SeachParams < Jamf::JSONObject

      OBJECT_MODEL = {

        # @!attribute pageSize
        #   @return [Integer]
        pageSize: {
          class: :integer
        },

        # @!attribute pageNumber
        #   @return [Integer]
        pageNumber: {
          class: :integer
        },

        # @!attribute isLoadToEnd
        #   @return [Boolean]
        isLoadToEnd: {
          class: :boolean
        },

        # @!attribute orderBy
        #   @return [Boolean]
        orderBy: {
          class: Jamf::Searchable::OrderBy,
          multi: true
        }

      }.freeze
      parse_object_model
    end # class SearchParams

  end # module searchable

end # module
