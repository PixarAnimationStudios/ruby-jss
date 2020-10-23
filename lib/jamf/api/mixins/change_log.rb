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
  # - instances of a CollectionResources (e.g. individual policies)
  #   - mix-in this module by including it, to get instance methods
  # - CollectionResources as a whole (e.g. Inventory Preload Records)
  #   - mix-in this module by extending it, to get class methods
  # - SingletonResources (e.g. Client Checkin Settings )
  #   - mix-in this module by including AND extending, to get both
  #
  # ##### NON-STANDARD 'history' Paths
  # For most classes, the change log path is the #rsrc_path with '/history'
  # appended, and in that case it will be determined automatically.
  # If the object has some other path for the change log, e.g.
  # InventoryPreloadRecord, the class can define a constant CHANGE_LOG_RSRC
  # with the non-standard path. If that constant is defined, it will be used.
  #
  #
  # This module will add two methods:
  #
  #   1) #change_log,  will fetch and cache an Array of readonly
  #     Jamf::ChangeLogEntry instances. passing any truthy parameter will
  #     cause it to re-fetch the Array from the server.
  #
  #   2) #add_change_log_note(note), which takes a string and adds it to the
  #     object's change history as a note and re-fetches & caches the history.
  #
  module ChangeLog

    # TODO:  note can have a max length of 2500 characters.

    # The change and note history for this resource.
    #
    # The history is cached internally and only re-fetched when
    # a truthy parameter is given.
    #
    # @param refresh[Boolean] re-fetch and re-cache the history
    #
    # @return [Array<Jamf::ChangeHistoryEntry>] The change and note history for
    #   this resource
    #
    def change_log(refresh: false, cnx: Jamf.cnx, page: :all, page_size: 100, sort: nil, filter: nil)

      # this should only be true for instances of CollectionResources
      cnx = @cnx if @cnx

      sort = parse_change_log_sort sort
      filter = parse_change_log_filter filter

      # If no page options, get all of them, possibly from the cache
      if page == :all
        change_log_fetch_all(refresh, sort, filter, cnx)

      # get a specific page
      else
        puts "#{change_log_rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
        raw = cnx.get "#{change_log_rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
        raw[:results].map { |l| Jamf::ChangeLogEntry.new l }
      end
    end

    # how many change log entries are there?
    # needed when using paged #change_log calls
    def change_log_count(cnx: Jamf.cnx)
      # this should only be true for instances of CollectionResources
      cnx = @cnx if @cnx

      raw = cnx.get "#{change_log_rsrc}?page=0&page-size=1"
      raw[:totalCount]
    end

    # Add a note to this resource's change log.
    #
    # If the change history has been cached already, the cache is
    # flushed after adding the note.
    #
    # @param note[String] The note to add. It cannot be empty.
    #
    # @return [void]
    #
    def add_change_log_note(note, cnx: Jamf.cnx)
      # this should only be true for instances of CollectionResources
      cnx = @cnx if @cnx

      note = Jamf::Validate.non_empty_string note
      note_to_send = { note: note }
      cnx.post change_log_rsrc, note_to_send

      # flush the cached data, force reload when next accessed, to get new note
      @change_log = nil
    end

    # Private methods
    ###########################

    private

    # the rest resource to get change logs
    def change_log_rsrc
      return @change_log_rsrc if @change_log_rsrc

      @change_log_rsrc = defined?(self::CHANGE_LOG_RSRC) ? self::CHANGE_LOG_RSRC : "#{rsrc_path}/history"
    end

    # get all change log records
    def change_log_fetch_all(refresh, sort, filter, cnx)
      # use cache if we got it and not refreshing
      @change_log = nil if refresh
      return @change_log if @change_log

      # set default page and size
      page = 0
      page_size = 2000

      raw = cnx.get "#{change_log_rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
      @change_log = raw[:results]

      until @change_log.size >= raw[:totalCount]
        page += 1
        raw = cnx.get "#{change_log_rsrc}?page=#{page}&page-size=#{page_size}#{sort}#{filter}"
        @change_log += raw[:results]
      end
      @change_log.map! { |l| Jamf::ChangeLogEntry.new l }
      return @change_log
    end


    # generate the sort params for the url
    #
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

    # generate the RSQL filter to put into the url
    # proper RSQL shouldnt need url encoding
    def parse_change_log_filter(filter)
      return if filter.nil?

      "&filter=#{filter}"
    end


  end # module ChangeHistory

end # module
