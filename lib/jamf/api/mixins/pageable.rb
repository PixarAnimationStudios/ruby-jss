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

  # methods for dealing with paged collection GET requests
  #
  module Pageable

    # # When This is included
    # def self.included(klass)
    #   puts "Pageable was included by #{klass}"
    # end
    #
    # # When this is exdended
    # def self.extended(klass)
    #   puts "Pageable was extended by #{klass}"
    # end

    DFT_PAGE_SIZE = 100

    MIN_PAGE_SIZE = 1

    MAX_PAGE_SIZE = 2000

    PAGE_SIZE_RANGE = (MIN_PAGE_SIZE..MAX_PAGE_SIZE).freeze

    # @param rsrc [String] The collection resource GET endpoint
    #
    # @param cnx [Jamf::Connection] The API connection to use
    #
    # @return [Integer] How many items exist in this collection?
    #
    def collection_count(rsrc, cnx: Jamf.cnx)
      # this should only be true for instances of CollectionResources
      cnx = @cnx if @cnx
      cnx.get("#{rsrc}?page=0&page-size=1")[:totalCount]
    end

    # Get a specific page of a paged collection request,
    # possibly sorted & filtered.
    #
    # @param rsrc [String] The collection resource GET endpoint
    #
    # @param page [Integer] which page to get
    #
    # @param page_size [Integer] how many items per page
    #
    # @param sort [String,Array<String>] server-side sorting parameters
    #
    # @param filter [String] RSQL String limiting the result set
    #
    # @param cnx [Jamf::Connection] The API connection to use
    #
    # @return [Array<Object>] The parsed JSON for the requested page
    #
    def fetch_collection_page(rsrc, page, page_size, sort, filter, cnx: Jamf.cnx)
      page_size ||= DFT_PAGE_SIZE
      validate_page_params page_size, page
      raw = cnx.get "#{rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"

      raw[:results]
    end

    ################### Private methods
    private

    # get the first page of a paged collection, and set up for
    # getting later pages
    #
    # @param rsrc [String] The collection resource GET endpoint
    #
    # @param page_size [Integer] how many items per page
    #
    # @param sort [String,Array<String>] server-side sorting parameters
    #
    # @param filter [String] RSQL String limiting the result set
    #
    # @param cnx [Jamf::Connection] The API connection to use
    #
    # @return [Array<Object>] The first page of the collection for this resource
    #
    def first_collection_page(rsrc, page_size, sort, filter, cnx)
      page_size ||= DFT_PAGE_SIZE
      validate_page_params page_size

      @collection_rsrc_path = rsrc
      @collection_cnx = cnx
      @collection_page = :first
      @collection_page_size = page_size
      @collection_sort = sort
      @collection_filter = filter
      @collection_paged_fetched_count = 0

      next_collection_page
    end

    # Fetch the next page of a paged colleqction request.
    #
    # Returns an empty array if there's been no paged request
    # or if the last one has no more pages.
    #
    # @return [Array<Object>] The next page of the collection for this resource
    #
    def next_collection_page
      case @collection_page
      when :first
        @collection_page = 0
      when Integer
        @collection_page += 1
      else
        # if here, we haven't initiated a paged request, or
        # all pages have already been delivered
        return []
      end

      raw = @collection_cnx.get "#{@collection_rsrc_path}?page=#{@collection_page}&page-size=#{@collection_page_size}#{@collection_sort}#{@collection_filter}"

      @collection_paged_fetched_count += raw[:results].size
      @collection_paged_total_count = raw[:totalCount]

      # did we get everything in the this page?
      # if so, clear all the paging data
      clear_collection_paging_data if @collection_paged_fetched_count >= @collection_paged_total_count

      # return the page results
      raw[:results]
    end

    def clear_collection_paging_data
      @collection_rsrc_path = nil
      @collection_cnx = nil
      @collection_sort = nil
      @collection_filter = nil
      @collection_page = nil
      @collection_page_size = nil
      @collection_paged_total_count = nil
      @collection_paged_fetched_count = nil
    end

    # ensure valid page && page_size
    #
    # @param page_size [Integer] the page_size to be validated, must be in range
    #
    # @param page [Integer] the page number requested, must be >= 0
    #
    # @return [void]
    #
    def validate_page_params(page_size, page = nil)
      raise ArgumentError, "page_size must be an Integer from #{MIN_PAGE_SIZE} to #{MAX_PAGE_SIZE}" unless PAGE_SIZE_RANGE.include? page_size

      # if page is nil, ignore it, one of the auto paging methods is calling us
      return if page.nil?

      raise ArgumentError, 'page must be an Integer zero or higher' unless page.is_a?(Integer) && page > -1
    end

    # Description of #fetch_all_collection_pages
    #
    # @param rsrc [String] The collection resource GET endpoint
    #
    # @param sort [String,Array<String>] server-side sorting parameters
    #
    # @param filter [String] RSQL String limiting the result set
    #
    # @param cnx [Type] describe_cnx_here
    #
    # @return [Type] description_of_returned_object
    #
    def fetch_all_collection_pages(rsrc, sort, filter, cnx)
      page = 0
      page_size = MAX_PAGE_SIZE

      raw = cnx.get "#{rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
      results = raw[:results]

      until results.size >= raw[:totalCount]
        page += 1
        raw = cnx.get "#{rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
        results += raw[:results]
      end
      results
    end

  end # Pagable

end # Jamf
