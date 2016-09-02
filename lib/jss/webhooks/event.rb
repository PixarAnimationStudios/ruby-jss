### Copyright 2016 Pixar
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

  # The superclass of all webhook events.
  #
  # Almost all processing happens here in the Superclass. The Subclasses
  # define specfic-event-related details.
  # As such, the Subclasses must define these constants:
  #
  # HANDLER_KEY = The JSSWebHooks::Configuration key pointing to the handler
  #   file for this event. See Event#handle for details.
  #
  # OBJECT_CLASS = the JSSWebHooks::EventObjects (q.v.) class representing the
  #   event object with this event
  #
  class Event

    #########################
    # Class Instance Variables

    # Holds a mapping of Event names as they come from the JSS to the
    # Event subclasses that represent them. Will be populated
    # as the event subclasses are required.
    @event_to_class_names ||= {}


    # Getter for @event_to_class_names
    #
    # @return [Hash{String => Class} a mapping of Event names as they come from
    #   the JSS to the JSSWebHooks::Event subclasses that represent them
    #
    def self.event_to_class_names
      @event_to_class_names
    end



    # Given the raw json from the JSS webhook,
    # create an object of the correct Event subclass
    #
    # @param [String] raw_event_json The JSON http POST content from the JSS
    #
    # @return [JSSWebHooks::Event subclass] the Event subclass matching the event
    #
    def self.parse_event(raw_event_json)
      event_json = JSON.parse(raw_event_json, symbolize_names: true)
      event_name = event_json[:webhook][:webhookEvent]
      JSSWebHooks::Event.event_to_class_names[event_name].new event_json, raw_event_json
    end


    # @return [String] the raw JSON recieved from the JSS
    attr_reader :raw_json

    # @return [Hash] The parsed JSON recieved from the JSS
    attr_reader :event_json

    # @return [JSSWebHooks::WebHook] The webhook in the JSS that caused this event
    attr_reader :webhook

    # @return [JSSWebHooks::EventObjects class] The event object sent with the event
    attr_reader :event_object

    # @return [Array<Proc,Pathname>] the handlers defined for this event
    attr_reader :handlers

    def initialize(event_json, raw_json)
      @event_json = event_json
      @raw_json = raw_json

      # make a WebHook instance out of the webhook data for the event
      @webhook = WebHook.new(event_json[:webhook])

      # make an Event Objects class instance for the event object that
      # came with this event.
      @event_object = self.class::OBJECT_CLASS.new(event_json[:event])

      # An array of handlers for this event type.
      @handlers = JSSWebHooks::Event::Handlers.event_handlers[self.class::EVENT_NAME]
      @handlers ||= []

    end # init

    def handle
      @handlers.each do |handler|
        case handler
        when Pathname
          pipe_to_executable handler
        when Proc
          handle_with_proc handler
        end # case
      end # @handlers.each do |handler|

    end # def handle

    # TODO: have something here that
    # cleans up old threads and forks
    def pipe_to_executable(handler)
      thread = Thread.new do
        IO.popen([handler.to_s], 'w') { |h| h.puts @raw_json }
      end
    end

    def handle_with_proc(handler)
      thread = Thread.new { handler.call self }
    end

  end # class event

end # module

# load in the subclass definitions
Pathname.new(__FILE__).parent.+('event').children.each do |file|
  require file.to_s if file.extname == '.rb'
end
