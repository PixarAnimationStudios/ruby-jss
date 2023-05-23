# Copyright 2023 Pixar
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

  # an object that performs a paged query for a pageable resource,
  # possibly sorted and filtered. One of these is returned by class method
  # .pager class method of CollectionResources the .change_log_pager method
  # of ChangeLog resources
  #
  class Pager

    # Constants
    ########################################

    MIN_PAGE_SIZE = 1

    MAX_PAGE_SIZE = 2000

    DEFAULT_PAGE_SIZE = 100

    PAGE_SIZE_RANGE = (MIN_PAGE_SIZE..MAX_PAGE_SIZE).freeze

    # Class Methods
    ########################################

    # Return all results from a pageable list path.
    #
    # Pageable resources are always returned in pages, usually defaulting to
    # 100 items per page, but the max allowed page size is 2000. If there are more
    # than 2000 items, we must loop through the pages to get them all.
    #
    # This method is used to get all pages of data from a giving path, automatically
    # looping through the pages and collecting the data to be returned in a
    # single Array. It uses a Pager object to do that, but the Pager itself
    # is transient, only the resulting Array is returned.
    #
    # @param list_path [String] The Resource URL path that provides the paged
    #   query results
    #
    # @param sort [String ] The optional sort parameter for the query
    #
    # @param filter [String] The optional RSQL filter parameter for the query
    #
    # @param instantiate [Class] Instantiate the results as the given class by
    #   passing the raw JSON data to the class' .new method. WARNING: Be sure the
    #   data returned from the API is appropriate for instantiating this class.
    #
    # @param cnx [Jamf::Connection] The API connection to use, default: Jamf.cnx
    #
    # @return [Array<Hash,Jamf::OAPIObject>] All of the pages of data, returned as one array,
    #   optionally instantiated into a subclass of Jamf::OAPIObject.
    #
    def self.all_pages(list_path:, sort: nil, filter: nil, instantiate: nil, cnx: Jamf.cnx)
      sort &&= Jamf::Sortable.parse_url_sort_param(sort)
      filter &&= Jamf::Filterable.parse_url_filter_param(filter)

      pager = new(
        page_size: MAX_PAGE_SIZE,
        list_path: list_path,
        sort: sort,
        filter: filter,
        instantiate: instantiate,
        cnx: cnx
      )

      fetched_page = pager.fetch_next_page
      data = fetched_page
      until fetched_page.empty?
        fetched_page = pager.fetch_next_page
        data += fetched_page
      end
      data
    end

    # Attributes
    ########################################

    # @return [Jamf::Connection] The Connection object used for the query
    attr_reader :cnx

    # @return [String] The Resource URL path that provides the paged query results
    attr_reader :list_path

    # @return [String, nil] The optional sort parameter for the query,
    attr_reader :sort

    # @return [String, nil] The optional filter parameter for the query
    attr_reader :filter

    # @return [Integer] How many items to return per page
    attr_reader :page_size

    # @return [nil, Integer] The most recent page number fetched by fetch_next_page,
    #   or nil if it hasn't been called yet.
    attr_reader :last_fetched_page

    # @return [Integer] The page which will be returned when fetch_next_page is called
    attr_reader :next_page

    # @return [] The full r#source URL, with page_size, sort, and filter, but
    #   without the 'page' parameter
    attr_reader :query_path

    # @return [Integer, nil] How many items are there in total? NOTE: this does
    #   not apply any given filter, which might reduce the number of items
    #   returned by a pager.
    attr_reader :total_count

    # @return [Integer, nil] How many pages needed to retrieve the total_count?
    #  nil if using a filter, since that may return fewer than the total count.
    attr_reader :total_pages

    # Constructor
    ########################################

    # @param list_path [String] The Resource URL path that provides the paged
    #   query results
    #
    # @param page_size [Integer] How many items to return per page
    #
    # @param sort [String ] The optional sort parameter for the query
    #
    # @param filter [String] The optional RSQL filter parameter for the query
    #
    # @param instantiate [Class] Instantiate the results as the given class by
    #   passing the raw JSON data to the class' .new method
    #
    # @param cnx [Jamf::Connection]  The Connection object used for the query.
    #   Defaults to the Default connection
    #
    ########################################
    def initialize(list_path:, page_size: DEFAULT_PAGE_SIZE, sort: nil, filter: nil, instantiate: nil, cnx: Jamf.cnx)
      validate_page_size(page_size)

      @cnx = cnx
      @list_path = list_path
      @sort = Jamf::Sortable.parse_url_sort_param(sort)
      @filter = Jamf::Filterable.parse_url_filter_param(filter)
      @page_size ||= DEFAULT_PAGE_SIZE
      @instantiate = instantiate

      # start with page 0, the first page
      # This will be incremented and appended to the query path each time we call
      # next_page
      @next_page = 0

      @query_path = "#{@list_path}?page-size=#{@page_size}#{@sort}#{@filter}"

      # get one item which will contain the total count
      @total_count = cnx.jp_get("#{@list_path}?page-size=1&page=0#{@filter}")[:totalCount]
      # can't know total pages of filtered query
      @total_pages = @filter ? nil : (@total_count / @page_size.to_f).ceil
    end

    # @return [Array] The next page of the collection, i.e. whichever page is
    #   indicated in the next_page attribute.
    ########################################
    def fetch_next_page
      page @next_page, increment_next: true
    end

    # Reset the pager to start at a specific page (by default, the beginning)
    # so that #fetch_next_page will start from there the next time it's called.
    def reset(to_page = 0)
      to_page = 0 if to_page == :first
      raise ArgumentError, 'Page number must be an Integer 0 or higher' if !to_page.is_a?(Integer) || to_page.negative?

      @next_page = to_page
    end

    # Retrieve an arbitrary page of the result.
    #
    # IMPORTANT: In the Jamf Pro API, page numbers are zero-based! The first page
    # is 0, the second is 1, and so on. Asking for page 27 will give you the
    # 28th page of results
    #
    # If increment_next is true, then subsequent calls to #fetch_next_page will
    # continue from whatever page number was requested.
    #
    # When increment_next is false (the default), the sequence of pages returned
    # by #next_page is unchanged, regardless of which page you return here.
    #
    # @param number [Integer, Symbol] Which page to retrieve.
    #   The Symbols :first and :last will work as expected. Otherwise, the
    #   zero-based page number is needed. Will return an empty array if greater
    #   than the total number of pages in the query result
    #
    # @param increment_next [Boolean] should the next_page value be reset to the
    #   page number plus 1? This makes #fetch_next_page continue from this one.
    #
    # @return [Array] The desired page of the result, containing up to #page_size
    #   items. Will be empty if the page is greater than the total available.
    #
    ########################################
    def page(page_number, increment_next: false)
      page_number = 0 if page_number == :first
      if page_number == :last
        raise Jamf::UnsupportedError, 'Cannot use :last with filtered queries' if @filter

        page_number = (@total_pages - 1)
      end

      validate_page_number page_number

      data = @cnx.jp_get "#{@query_path}&page=#{page_number}"
      data = data[:results]
      data.map! { |r| @instantiate.new r } if @instantiate

      if increment_next
        @last_fetched_page = page_number
        @next_page = (page_number + 1)
      end

      data
    end

    # ensure valid page_size
    #
    # @param page_size [Integer] the page_size to be validated, must be in range
    #
    # @return [void]
    #
    def validate_page_size(page_size)
      return if page_size.is_a?(Integer) && PAGE_SIZE_RANGE.cover?(page_size)

      raise ArgumentError, "page_size must be an Integer from #{MIN_PAGE_SIZE} to #{MAX_PAGE_SIZE}"
    end
    private :validate_page_size

    # ensure valid page_number
    #
    # @param page [Integer] the page number requested, must be >= 0
    #
    # @return [void]
    #
    def validate_page_number(page_number)
      return if page_number.is_a?(Integer) && page_number >= 0

      raise ArgumentError, 'Page number must be an Integer 0 or higher'
    end
    private :validate_page_number

  end # class Pager

end # Jamf
