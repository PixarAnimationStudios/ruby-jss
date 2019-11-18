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
  # When included, the instances of Jamf::Resource have change-log
  # available by GET RSRC_BASE/history and notes can be added to the history
  # by POST RSRC_BASE/history
  #
  # NOTE: ruby-jss uses the term 'change log' to refer to a Jamf object's
  # 'object history'.  This is to help differentiate it from the many
  # other kinds of history that some objects can have, like management
  # history, application usage history, and so on.
  #
  # Jamf::Resource instances can GET RSRC_BASE/{id}/history
  # and notes POSTed to RSRC_BASE/{id}/history/notes
  #
  # This module will add two instance methods:
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
    def change_log(refresh = false)
      @change_log = nil if refresh
      @change_log ||= cnx.get(change_log_rsrc)[:results].map! do |l|
        #
        # TODO: Report bug in jamf data, sometimes there's no details in the JSON
        # so add an empty string if needed. DO it for note too, just in case
        l[:details] ||= Jamf::BLANK
        l[:note] ||= Jamf::BLANK

        Jamf::ChangeLogEntry.new l
      end
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
    def add_change_log_note(note)
      note = Jamf::Validate.non_empty_string note
      note_to_send = { note: note }
      cnx.post change_log_rsrc, note_to_send
      # flush the cached data, force reload when next accessed, to get new note
      @change_log = nil
    end

    private

    def change_log_rsrc(page: nil, size: nil)
      params = ''
      params << '?' if page || size
      if page

      end

      if size

      end
      params << '?' if page || size
      params << '?' if page || size

      @change_log_rsrc ||= "#{rsrc_path}/history"
    end


  end # module ChangeHistory

end # module
