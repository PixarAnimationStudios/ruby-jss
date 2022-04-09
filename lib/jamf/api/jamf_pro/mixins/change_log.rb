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
  # a mix-in module for Jamf::Resource subclasses.
  #
  # Many Jamf resources maintain an 'object history', available in the WebUI via
  # the 'History' button at the bottom of a page. Ad-hoc history entries can
  # be added containing textual notes, which is useful for objects that don't
  # have a real 'notes' or 'description' field, like policies.
  #
  # In the Jamf Pro API, this history is usually available at a resource path
  # ending with '/history' (see NON-STANDARD 'history' Paths below)
  #
  # Due to the many kinds of history available in Jamf,  like management
  # history, application usage history, and so on, ruby-jss uses the term
  # 'change log' to refer to a Jamf resource's 'object history', and access
  # to the change log is provided by this module.
  #
  # The change log can be available in different places:
  #
  # - CollectionResources (e.g. individual policies)
  #   - m
  # - CollectionResources as a whole (e.g. Inventory Preload Records)
  #   - mix-in this module by extending it, to get class methods
  # - SingletonResources (e.g. Client Checkin Settings )
  #   - mix-in this module by including AND extending, to get both
  #
  # ##### NON-STANDARD 'history' Paths
  #
  # For most classes, the change log path is the LIST_PATH or the #get_path
  # with '/history' appended. LIST_PATH/history is for when the history is
  # available for the class as a whole, e.g. with InventoryPreloadRecord, and
  # #get_path/history is for members of a collection, and has the item's id.
  # This path can be used for GETting history and POSTing new notes to the
  # history.
  #
  #
  # If some class or instance has a non-standard path, it should override the
  # history_path class method defined here, to return the correct path.
  #



  # and in that case it will be determined automatically.
  # If the object has some other path for the change log, e.g.
  # InventoryPreloadRecord, the class can define a constant HISTORY_PATH
  # with the non-standard path. If that constant is defined, it will be used.
  #
  #
  # This module will add these public methods:
  #
  #   1) #change_log, will fetch an Array of readonly
  #     Jamf::ChangeLogEntry instances. possibly sorted, filtered, paged,
  #     or cached
  #
  #   2) #next_page_of_change_log, will retrieve the next page of a paged
  #      #change_log call
  #
  #   3) #add_change_log_note(note), which takes a string and adds it to the
  #     object's change history as a note and clears the cached the logs.
  #
  module ChangeLog

    DFT_HISTORY_PATH = 'history'.freeze

    SEARCH_RESULTS_OBJECT = Jamf::OAPISchemas::HistorySearchResults
    HISTORY_ENTRY_OBJECT = Jamf::OAPISchemas::ObjectHistory
    POST_NOTE_OBJECT = Jamf::OAPISchemas::ObjectHistoryNote


    # when this module is included, also extend our Class Methods
    def self.included(includer)
      # puts "--> #{includer} is including Jamf::CollectionResource"
      includer.extend(ClassMethods)
    end

    # Class Methods
    #####################################
    module ClassMethods

      # Add a note to this resource's change log.
      #
      # If the change history has been cached already, the cache is
      # flushed after adding the note.
      #
      # @param note[String] The note to add. It cannot be empty.
      #
      # @return [void]
      #
      def add_change_log_note(note, id: nil, cnx: Jamf.cnx)
        note_to_send = POST_NOTE_OBJECT.new note: Jamf::Validate.non_empty_string(note)

        result = cnx.jp_post history_path(id), note_to_send.to_jamf

        # flush the cached data, forces reload when next accessed, to get new note
        @cached_change_log = nil
        HISTORY_ENTRY_OBJECT.new result
      end

      # The change and note history for this resource.
      # This is a collection of objects as a sub-resource of some
      # primary resource. As such, retriving the change log returns
      # an array of objects, and can be paged, sorted and filtered.
      #
      # This method is very similar to CollectionResource.all, see the
      # docs for that method for more details
      #
      # @param sort [String, Array<String>] Server-side sorting criteria in the format:
      #   property:direction, where direction is 'asc' or 'desc'. Multiple
      #   properties are supported, either as separate strings in an Array, or
      #   a single string, comma separated.
      #
      # @param filter [String] An RSQL filter string. Not all change_log resources
      #   currently support filters, and if they don't, this will be ignored.
      #
      # @param page_size [Integer] Return 'paged' results in groups of this many items.
      #   Minimum is 1, maximum is 2000
      #
      #   When this is used, this method only returns the first group items.
      #   Use {.next_page_of_change_log} to retrieve each successive page. That method
      #   will return an empty array once all items have been returned.
      #
      #   Note: the final page may contain fewer items than the page_size
      #
      # @param refresh [Boolean] re-fetch and re-cache the full list of all entries.
      #   Ignored if paged:, page_size:, sort:, or filter: are used.
      #
      # @param cnx [Jamf::Connection] The API connection to use, default: Jamf.cnx.
      #   If this is an instance of a Collection Resource, this is always
      #   the connection from which it was fetched.
      #
      # @return [Array<Jamf::ChangeLogEntry>] The change log entries requested
      #
      def change_log(id: nil, sort: nil, filter: nil, page_size: nil, refresh: false, cnx: Jamf.cnx)
        # use the cache if not paging, filtering or sorting
        return cached_change_log(refresh, id, cnx) unless page_size || sort || filter

        sort = parse_change_log_sort(sort)

        filter &&= "&filter=#{CGI.escape filter.to_s}"

        return first_change_log_page(id, page_size, sort, filter, cnx) if page_size

        fetch_all_change_log_entries(id, sort, filter, cnx)
      end

      # Fetch the next page of a paged #change_log request
      # Returns an empty array if there's been no paged request
      # or if the last one has no more pages.
      #
      # @return [Array<Jamf::ChangeHistoryEntry>] The next page of the change
      #   and note history for this resource
      #
      def next_page_of_change_log
        case @change_log_page
        when :first
          @change_log_page = 0
        when Integer
          @change_log_page += 1
        else
          # if here, we haven't initiated a paged request, or
          # all pages have already been delivered
          return []
        end

        search_path = "#{@change_log_paged_path}&page=#{@change_log_page}"
        search_result = SEARCH_RESULTS_OBJECT.new @change_log_paged_cnx.jp_get(search_path)

        @change_log_paged_fetched_count += search_result.results.size
        @change_log_paged_total_count ||= search_result.totalCount

        # did we get the last of them in the this page?
        # if so, clear all the paging data
        clear_change_log_paging_data if @change_log_paged_fetched_count >= @change_log_paged_total_count

        # return the page results
        search_result.results
      end

      # how many change log entries are there?
      # needed when using paged #change_log calls
      #
      # @param cnx [Jamf::Connection] The API connection to use, default: Jamf.cnx
      #   This is ignored for instances of Collection Resources, which always use
      #   the same connection from which they were fetched.
      #
      # @return [Integer] How many changelog entries exist?
      #
      def change_log_count(id: nil, cnx: Jamf.cnx)
        search_path = "#{history_path(id)}?page=0&page-size=1"
        search_result = SEARCH_RESULTS_OBJECT.new cnx.jp_get(search_path)
        search_result.totalCount
      end

      # @return [String] The path to get or post change logs for this object
      #
      def history_path(id = nil)
        if id
          "#{get_path}/#{id}/#{DFT_HISTORY_PATH}"
        else
          "#{get_path}/#{DFT_HISTORY_PATH}"
        end
      end

      #################
      def parse_change_log_sort(sort)
        case sort
        when nil
          sort
        when String
          "&sort=#{CGI.escape sort}"
        when Array
          "&sort=#{CGI.escape sort.join(',')}"
        else
          raise ArgumentError, 'sort criteria must be a String or Array of Strings'
        end
      end
      private :parse_change_log_sort

      # get the first page of a paged change log request, and set up for
      # getting later pages
      #
      # @param page_size [Integer] how many items per page
      #
      # @param sort [String,Array<String>] server-side sorting parameters
      #
      # @param filter [String] RSQL String limiting the result set
      #
      # @param cnx [Jamf::Connection] The API connection to use
      #
      # @return [Array<Object>] The first page of the change logs for this resource
      #
      def first_change_log_page(id, page_size, sort, filter, cnx)
        unless Jamf::Pageable::PAGE_SIZE_RANGE.include? page_size
          raise ArgumentError, "page_size must be an Integer from #{Jamf::Pageable::MIN_PAGE_SIZE} to #{Jamf::Pageable::MAX_PAGE_SIZE}"
        end

        # set all these values then call for the next page
        @change_log_paged_cnx = cnx
        @change_log_page = :first
        @change_log_page_size = page_size
        @change_log_sort = sort
        @change_log_filter = filter
        @change_log_paged_fetched_count = 0
        @change_log_paged_path = "#{history_path(id)}?page-size=#{@change_log_page_size}#{@change_log_sort}#{@change_log_filter}"

        next_page_of_change_log
      end

      # TODO:  like with Pageable - this is not threadsafe
      def clear_change_log_paging_data
        @change_log_paged_cnx = nil
        @change_log_page = nil
        @change_log_page_size = nil
        @change_log_sort = nil
        @change_log_filter = nil
        @change_log_paged_total_count = nil
        @change_log_paged_fetched_count = nil
      end

      # return the cached/cachable version of .change_log
      #
      # @param refresh [Boolean] refetch the cache from the server?
      #
      # @param cnx [Jamf::Connection] The Connection to use
      #
      # @return [Array<Jamf::ChangeLogEntry>] All the change_log entries
      #
      def cached_change_log(refresh, id, cnx)
        @cached_change_log = nil if refresh
        return @cached_change_log if @cached_change_log

        sort = nil
        filter = nil
        @cached_change_log = fetch_all_change_log_entries(id, sort, filter, cnx)
      end

      #######
      def fetch_all_change_log_entries(id, sort, filter, cnx)
        paged_path = "#{history_path(id)}?page-size=#{Jamf::Pageable::MAX_PAGE_SIZE}#{sort}#{filter}"
        page = 0

        # get the first page
        search_result = SEARCH_RESULTS_OBJECT.new cnx.jp_get("#{paged_path}&page=#{page}")
        results = search_result.results

        # keep getting pages until we have all
        until results.size >= search_result.totalCount
          page += 1
          search_result = SEARCH_RESULTS_OBJECT.new cnx.jp_get("#{paged_path}&page=#{page}")
          results += search_result.results
        end

        results
      end

    end # module Class Methods

    # Instance Methods
    # wrappers for the class methods, which pass the id and cnx
    ########################################

    def add_change_log_note(note)
      self.class.add_change_log_note(note, id: @id, cnx: @cnx)
    end

    def change_log(sort: nil, filter: nil, page_size: nil, refresh: false)
      self.class.change_log(id: @id, sort: sort, filter: filter, page_size: page_size, refresh: refresh, cnx: @cnx)
    end

    def next_page_of_change_log
      self.class.next_page_of_change_log
    end

    def change_log_count
      self.class.change_log_count(id: @id, cnx: @cnx)
    end

    def history_path
      self.class.history_path(@id)
    end

  end # module ChangeLog

end # module
