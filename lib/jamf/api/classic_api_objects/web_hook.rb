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

#
module Jamf

  # Classes
  ###################################

  #
  # A webhook as defined in JamfPro.
  #
  class WebHook < Jamf::APIObject

    # Mix-Ins
    ###################################
    include Jamf::Creatable
    include Jamf::Updatable

    # Class Methods
    ###################################

    # Class Constants
    ###################################

    # The base for REST resources of this class
    RSRC_BASE = 'webhooks'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :webhooks

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :webhook

    # the content types available for webhooks, internally we use Symbols,
    # but the API wants the proper MIME strings
    CONTENT_TYPES = {
      xml: 'text/xml',
      json: 'application/json'
    }.freeze

    # The available webhook events.
    EVENTS = %w(
      ComputerAdded
      ComputerCheckIn
      ComputerInventoryCompleted
      ComputerPolicyFinished
      ComputerPushCapabilityChanged
      JSSShutdown
      JSSStartup
      MobileDeviceCheckIn
      MobileDeviceCommandCompleted
      MobileDeviceEnrolled
      MobileDevicePushSent
      MobileDeviceUnEnrolled
      PatchSoftwareTitleUpdated
      PushSent
      RestAPIOperation
      SCEPChallenge
      SmartGroupComputerMembershipChange
      SmartGroupMobileDeviceMembershipChange
    ).freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 500

    # Attributes
    ###################################

    # @return [Boolean] is this webhook enabled?
    attr_reader :enabled

    # @return [String] the URL accessed by this webhook
    attr_reader :url

    # @return [Symbols] the content_type, one of the keys of CONTENT_TYPES
    attr_reader :content_type

    # @return [String] the event name to which this webhook responds
    attr_reader :event

    # Constructor
    ###################################

    # See Jamf::APIObject#initialize
    def initialize(**args)
      super

      # now we have pkg_data with something in it, so fill out the instance vars
      @enabled = @init_data[:enabled]
      @url = @init_data[:url]
      @content_type = CONTENT_TYPES.invert[@init_data[:content_type]]
      @event = @init_data[:event]

      # defaults
      @content_type ||= :json
      @enabled = false if @enabled.nil?
    end # init

    # Public Instance Methods
    ###################################

    # Setters
    #########

    # Set the enabled state of this webhook
    #
    # @param new_val[Boolean] the new state
    #
    # @return [void]
    #
    def enabled=(new_val)
      return nil if new_val == @enabled
      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "enabled must be boolean 'true' or 'false'" unless \
        Jamf::TRUE_FALSE.include? new_val
      @enabled = new_val
      @need_to_update = true
    end

    # Set the URL accessed by this webhook
    #
    # @param new_val[String] The new URL
    #
    # @return [void]
    #
    def url=(new_val)
      return nil if new_val == @url
      # handy - from http://stackoverflow.com/questions/1805761/check-if-url-is-valid-ruby#1805788
      url_ok = new_val =~ /\A#{URI.regexp(%w(http https))}\z/
      raise Jamf::InvalidDataError, 'New value is not a valid http(s) url' unless url_ok && url_ok.zero?
      @url = new_val
      @need_to_update = true
    end

    # Set the content_type sent to the url
    # Must be one of the keys of CONTENT_TYPES, i.e. :xml or :json
    #
    # @param new_val[Symbol] The new content_type
    #
    # @return [void]
    #
    def content_type=(new_val)
      return nil if new_val == @content_type
      raise Jamf::InvalidDataError, "content_type must be one of :#{CONTENT_TYPES.keys.join ', :'}" unless \
        CONTENT_TYPES.keys.include? new_val
      @content_type = new_val
      @need_to_update = true
    end

    # Set the event handled by this webhook
    # Must be a member of the EVENTS Array
    #
    # @param new_val[String] The event name
    #
    # @return [void]
    #
    def event=(new_val)
      return nil if new_val == @event
      raise Jamf::InvalidDataError, 'Unknown webhook event' unless EVENTS.include? new_val
      @event = new_val
      @need_to_update = true
    end

    # Convenience Methods
    #########

    # Enable this webhook, saving the new state immediately
    #
    # @return [void]
    #
    def enable
      raise Jamf::NoSuchItemError, 'Save the webhook before enabling it' unless @in_jss
      self.enabled = true
      save
    end

    # Disable this webhook, saving the new state immediately
    #
    # @return [void]
    #
    def disable
      raise Jamf::NoSuchItemError, 'Save the webhook before disabling it' unless @in_jss
      self.enabled = false
      save
    end

    # Aliases
    ###################################

    alias enabled? enabled

    # Private Instance Methods
    ##############################

    private

    # Return the REST XML for this webhook, with the current values,
    # for saving or updating
    #
    def rest_xml
      validate_before_save
      doc = REXML::Document.new APIConnection::XML_HEADER
      webhook = doc.add_element 'webhook'
      webhook.add_element('name').text = @name
      webhook.add_element('enabled').text = @enabled
      webhook.add_element('url').text = @url
      webhook.add_element('content_type').text = CONTENT_TYPES[@content_type]
      webhook.add_element('event').text = @event
      doc.to_s
    end # rest xml

    def validate_before_save
      raise 'url must be a valid http(s) URL String' unless @url.is_a? String
      raise 'event must be a valid event name from Jamf::WebHook::EVENTS' unless EVENTS.include? @event
    end

  end # class department

end # module
