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
  # - CollectionResource Items (e.g. individual Scripts)
  # - CollectionResources as a whole (e.g. Inventory Preload Records)
  # - SingletonResources (e.g. Client Checkin Settings )
  #
  # To enable change log access in a class, incldude this module _after_
  # including Jamf::CollectionResource or Jamf::SingletonResource
  #
  # ##### NON-STANDARD 'history' Paths
  #
  # For most classes, the change log path is the LIST_PATH or the #get_path
  # with '/history' appended. LIST_PATH/history is for when the history is
  # available for the class as a whole, e.g. with SingletonResources, and
  # #get_path/history is for members of a collection, and will include the
  # item's id.
  #
  # This path can be used for GETting history and POSTing new notes to the
  # history.
  #
  # If some class or instance has a non-standard path, it should override the
  # history_path class & instance methods defined here, to return the correct path.
  #
  # As an example, see Jamf::InventoryPreloadRecord, which is a Collection, but
  # only has history available for the collection as a whole, not for its items,
  # but also, the path for accessing the history is 'v2/inventory-preload/history'
  # while the LIST_PATH is 'v2/inventory-preload/records'
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

    SEARCH_RESULTS_OBJECT = Jamf::OAPISchemas::HistorySearchResultsV1
    HISTORY_ENTRY_OBJECT = Jamf::ChangeLogEntry
    POST_NOTE_OBJECT = Jamf::OAPISchemas::ObjectHistoryNote


    # when this module is included, also extend our Class Methods
    def self.included(includer)
      # puts "--> #{includer} is including Jamf::CollectionResource"
      includer.extend(ClassMethods)
    end

    # Class Methods
    #####################################
    module ClassMethods

      # Add an entry with a note to this object's change log.
      #
      # If the change history has been cached already, the cache is
      # flushed after adding the note.
      #
      # @param note[String] The note to add. It cannot be empty.
      #
      # @return [Jamf::ChangeLogEntry] the new entry
      #
      def add_change_log_note(note, id: nil, cnx: Jamf.cnx)
        note_to_send = POST_NOTE_OBJECT.new note: Jamf::Validate.non_empty_string(note)

        result = cnx.jp_post history_path(id), note_to_send.to_jamf

        # flush the cached data, forces reload when next accessed, to get new note
        @cached_change_log = nil
        HISTORY_ENTRY_OBJECT.new result
      end

      # The entire change and note history for this resource
      #
      # @param id [String, Integer] For Collection Items that have a change log
      #   This is the id of the  item. Omit this param for singletons, or
      #   collections which have a single change log.
      #
      # @param sort [String, Array<String>] Server-side sorting criteria in the format:
      #   property:direction, where direction is 'asc' or 'desc'. Multiple
      #   properties are supported, either as separate strings in an Array, or
      #   a single string, comma separated.
      #
      # @param filter [String] An RSQL filter string. Not all change_log resources
      #   currently support filters, and if they don't, this will be ignored.
      #
      # @param cnx [Jamf::Connection] The API connection to use, default: Jamf.cnx.
      #   If this is an instance of a Collection Resource, this is always
      #   the connection from which it was fetched.
      #
      # @return [Array<Jamf::ChangeLogEntry>] The change log entries requested
      #
      def change_log(id: nil, sort: nil, filter: nil,  cnx: Jamf.cnx)
        sort &&= Jamf::Sortable.parse_url_sort_param(sort)
        filter &&= Jamf::Filterable.parse_url_filter_param(filter)

        Jamf::Pager.all_pages(
          list_path: history_path(id),
          sort: sort,
          filter: filter,
          instantiate: Jamf::ChangeLogEntry,
          cnx: cnx
        )
      end

      # Return a Jamf::Pager object for retrieving all change log entries in smaller
      # groups.
      #
      # For most parameters, see .change_log
      #
      # @param page_size [Integer] The pager object returns results in groups of
      #   this many entries. Minimum is 1, maximum is 2000, default is 100
      #   Note: the final page of data may contain fewer items than the page_size
      #
      # @return [Jamf::Pager] An object from which you can retrieve sequential or
      #   arbitrary pages from the collection.
      #
      def change_log_pager(page_size: Jamf::Pager::DEFAULT_PAGE_SIZE, id: nil, sort: nil, filter: nil, cnx: Jamf.cnx)
        sort &&= Jamf::Sortable.parse_url_sort_param(sort)
        filter &&= Jamf::Filterable.parse_url_filter_param(filter)

        Jamf::Pager.new(
          page_size: page_size,
          list_path: history_path(id),
          sort: sort,
          filter: filter,
          instantiate: Jamf::ChangeLogEntry,
          cnx: cnx
        )
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
      def change_log_size(id: nil, cnx: Jamf.cnx)
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

    end # module Class Methods

    # Instance Methods
    #
    # wrappers for the class methods, which pass the id and cnx
    # should work on Singleton Resources since @id will be nil
    # but @cnx will be set.
    ########################################

    def add_change_log_note(note)
      self.class.add_change_log_note(note, id: @id, cnx: @cnx)
    end

    def change_log(sort: nil, filter: nil)
      self.class.change_log(id: @id, sort: sort, filter: filter, cnx: @cnx)
    end

    def change_log_pager(page_size: Jamf::Pager::DEFAULT_PAGE_SIZE, sort: nil, filter: nil)
      self.class.change_log_pager(
        page_size: page_size,
        id: @id,
        sort: sort,
        filter: filter,
        cnx: @cnx
      )
    end

    def change_log_count
      self.class.change_log_count(id: @id, cnx: @cnx)
    end

    def history_path
      self.class.history_path(@id)
    end

  end # module ChangeLog

end # module
