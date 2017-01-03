### Copyright 2017 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

module JSSWebHooks

  # This method is used by the Ruby event-handler files.
  #
  # Loading them should call this method and pass in a block
  # with one parameter: a JSS::WebHooks::Event subclass object.
  #
  # The block is then converted to a Proc instance in @loaded_event_handler
  # and from there can be stored for use by the event identified by the filename.
  #
  # NOTE: the files should be read with 'load' not 'require', so that they can
  # be re-loaded as needed
  #
  # @see_also JSSWebHooks::load_handlers
  #
  # @param [Block] block the block to be used as an event handler
  #
  # @yieldparam [JSS::WebHooks::Event subclass] The event to be handled
  #
  # @return [Proc] the block converted to a Proc
  #
  def self.event_handler(&block)
    Event::Handlers.loaded_event_handler = Proc.new(&block)
  end

  class Event

    module Handlers

      ############################
      # Module constants

      DEFAULT_HANDLER_DIR = '/Library/Application Support/JSSWebHooks'.freeze

      ############################
      # Module Instance Variables, & accessors

      @loaded_event_handler = nil

      # Getter for @loaded_event_handler
      #
      # @return [Proc,nil] the most recent Proc loaded from a handler file.
      # destined for storage in @event_handlers
      #
      def self.loaded_event_handler
        @loaded_event_handler
      end

      # Setter for @loaded_event_handler
      #
      # @param [Proc] a_proc the most recent Proc loaded from a handler file.
      # destined for storage in @event_handlers
      #
      def self.loaded_event_handler=(a_proc)
        @loaded_event_handler = a_proc
      end

      @event_handlers = {}

      # Getter for @event_handlers
      #
      # @return [Hash{String => Array}] a mapping of Event Names as the come from
      # the JSS to an Array of handlers for the event. The handlers are either
      # Proc objects to call from within ruby, or Pathnames to executable files
      # which will take raw JSON on stdin.
      def self.event_handlers
        @event_handlers
      end

      ############################
      # Module Methods

      # Load all the event handlers from the handler_dir or an arbitrary dir.
      #
      # @param [String, Pathname] from_dir directory from which to
      #   load the handlers
      # @param [Boolean] reload should we reload handlers if they've already
      #   been loaded?
      #
      # @return [void]
      #
      def self.load_handlers(from_dir = CONFIG.handler_dir, reload = false)
        from_dir ||= DEFAULT_HANDLER_DIR

        if reload
          @handlers_loaded_from = nil
          @event_handlers = {}
          @loaded_event_handler = nil
        end

        handler_dir = Pathname.new(from_dir)
        return unless handler_dir.directory? && handler_dir.readable?

        handler_dir.children.each do |handler_file|
          load_handler(handler_file) if handler_file.file? && handler_file.readable?
        end

        @handlers_loaded_from = handler_dir
      end # load handlers

      # Load an even handler from a file.
      # Handler files must begin with the name of the event they handle,
      # e.g. ComputerAdded,  followed by: nothing, a dot, a dash, or
      # and underscore. Case doesn't matter.
      # So all of these are OK:
      # ComputerAdded
      # computeradded.sh
      # COMPUTERAdded_notify_team
      # Computeradded-update-ldap
      # There can be as many as desired for each event.
      #
      # Each must be either:
      #   - An executable file, which will have the raw JSON from the JSS piped
      #     to it's stdin when executed
      # or
      #   - A non-executable file of ruby code like this:
      #     JSSWebHooks.event_handler do |event|
      #       # your code goes here.
      #     end
      #
      # (see HERE for details about writing the ruby handlers)
      #
      # @param [Pathname] from_file the file from which to
      #
      # @return [Type] description of returned object
      #
      def self.load_handler(from_file)
        handler_file = Pathname.new from_file
        event_name = event_name_from_handler_filename(handler_file)
        return unless event_name

        # create an array for this event's handlers, if needed
        @event_handlers[event_name] ||= []

        if handler_file.executable?
          # store as a Pathname, we'll pipe JSON to it
          @event_handlers[event_name] << handler_file unless \
            @event_handlers[event_name].include? handler_file
        else
          # load the file. If written correctly, it will
          # put a Proc into @loaded_event_handler
          load handler_file.to_s
          # store as a Proc, to be called when the event is handled.
          @event_handlers[event_name] << @loaded_event_handler unless \
            @event_handlers[event_name].include? @loaded_event_handler

        end # if handler_file.executable?
      end # self.load_handler(handler_file)

      # Given a handler filename, return the event name it wants to handle
      #
      # @param [Pathname] filename The filename from which to glean the
      #   event name.
      #
      # @return [String,nil] The matching event name or nil if no match
      #
      def self.event_name_from_handler_filename(filename)
        @event_names ||= JSSWebHooks::Event.event_to_class_names.keys
        desired_event_name = filename.basename.to_s.split(/\.|-|_/).first
        @event_names.select { |n| desired_event_name.casecmp(n).zero? }.first
      end

    end # module Handler

  end # class event

end # module
