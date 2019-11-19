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

module Jamf

  # a mix-in module for Jamf::Resource subclasses.
  #
  # Many Jamf resources maintain an 'object history', available in the WebUI via
  # the 'History' button at the bottom of a page. Ad-hoc history entries can
  # be added containing textual notes, which is useful for objects that don't
  # have a real 'notes' or 'description' field, like policies.
  #
  # In the Jamf Pro API, this history is usually available at a resource path
  # ending with '/history'
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
  # This module will add two methods:
  #
  #   1) #change_log,  will fetch and cache an Array of readonly
  #     Jamf::ChangeLogEntry instances. passing any truthy parameter will
  #     cause it to re-fetch the Array from the server.
  #
  #   2) #add_history_note(note), which takes a string and adds it to the
  #     object's change history as a note and re-fetches & caches the history.
  #
  module ChangeLog

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
    def change_log(refresh = false, cnx: Jamf.cnx)
      # this should only be true for instances of CollectionResources
      cnx = @cnx if @cnx

      @change_log = nil if refresh
      @change_log ||= cnx.get(change_log_rsrc)[:results].map! do |l|
        #
        # TODO: Report bug in jamf data, sometimes there's no details in the JSON
        # so add an empty string if needed. DO it for note too, just in case
        l[:details] ||= Jamf::BLANK
        l[:note] ||= Jamf::BLANK

        Jamf::ChangeLogEntry.new l
      end # map!
    end

    # Add a note to this resource's change log.
    #
    # If the change history has been cached already, it is
    # recached after adding the note.
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

    # TODO: Implement paging
    def change_log_rsrc
      @change_log_rsrc ||= "#{rsrc_path}/history"
    end

    # def change_log_rsrc(page: nil, size: nil)
    #   params = ''
    #   params << '?' if page || size
    #   if page
    #
    #   end
    #
    #   if size
    #
    #   end
    #   params << '?' if page || size
    #   params << '?' if page || size
    #
    #   @change_log_rsrc ||= "#{rsrc_path}/history"
    # end

  end # module ChangeHistory

end # module
