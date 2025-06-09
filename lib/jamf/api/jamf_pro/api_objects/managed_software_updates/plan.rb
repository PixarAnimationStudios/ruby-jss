# Copyright 2025 Pixar
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

# frozen_string_literal: true

module Jamf

  module ManagedSoftwareUpdates

    # A ManagedSoftwareUpdate Plan contains the details for
    # installing managed software updates via MDM/DDM on a device.
    # When plans are created for a group there will be one for every member of the group
    #
    class Plan < Jamf::OAPISchemas::ManagedSoftwareUpdatePlan

      # Mix-Ins
      #####################################

      include Jamf::CollectionResource
      extend Jamf::Filterable
      include Jamf::Immutable

      ########### RELATED OAPI OBJECTS

      # The OAPI object class we get back from a 'list' query to get the
      # whole collection, or a subset of it. It contains a :results key
      # which is an array of data for objects of the parent class.
      SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::ManagedSoftwareUpdatePlans

      # The OAPI object class we send with a POST request to make a new member of
      # the collection in Jamf. This is often the same as the parent class.
      POST_OBJECT = Jamf::OAPISchemas::ManagedSoftwareUpdatePlanPost

      GROUP_POST_OBJECT = Jamf::OAPISchemas::ManagedSoftwareUpdatePlanGroupPost

      ############# API PATHS

      # The path for GETting the list of all objects in the collection, possibly
      # filtered, sorted, and/or paged
      # REQUIRED for all collection resources
      #
      # GET_PATH, POST_PATH, PUT_PATH, PATCH_PATH, and DELETE_PATH are automatically
      # assumed from the LIST_PATH if they follow the standards:
      # - GET_PATH = "#{LIST_PATH}/id"
      #   - fetch an object from the collection
      # - POST_PATH = LIST_PATH
      #   - create a new object in the collection
      # - PUT_PATH = "#{LIST_PATH}/id"
      #   - update an object passing all its values back.
      #     Most objects use this or PATCH but not both
      # - PATCH_PATH = "#{LIST_PATH}/id"
      #   - update an object passing some of its values back
      #     Most objects use this or PUT but not both
      # - DELETE_PATH = "#{LIST_PATH}/id"
      #   - delete an object from the collection
      #
      # If those paths differ from the standards, the constants must be defined
      # here
      #
      LIST_PATH = "#{MANAGED_SW_UPDATES_PATH}/plans"

      # GETting this resource provides a list of existing group plans
      # POSTing to this resource will initiate a new plan targeting a group of devices
      GROUP_PLANS_PATH = "#{LIST_PATH}/group"

      # Must define this when extending Filterable
      FILTER_KEYS = %i[
        planUuid device.deviceId device.objectType updateAction versionType specificVersion maxDeferrals recipeId forceInstallLocalDateTime state
      ].freeze

      GROUP_TYPES = {
        computer: 'COMPUTER_GROUP',
        mobile_device: 'MOBILE_DEVICE_GROUP'
      }.freeze

      # Class Methods
      ######################################

      # Get an Array of all plans for a given group, either computer or mobile device.
      #
      # @param group_id [Integer] the ID of the group to get plans for
      # @param type [Symbol] the type of group, either :computer or :mobile_device
      # @param cnx [Jamf::Connection] the connection to use, defaults to Jamf.cnx
      # @return [Array<Jamf::ManagedSoftwareUpdates::Plan>] the plans for the group
      ################################
      def self.group_plans(group_id:, type:, cnx: Jamf.cnx)
        gtype = GROUP_TYPES[type.to_sym]
        raise ArgumentError, "Invalid group type: #{type}, must be one of :#{GROUP_TYPES.keys.join ', :'}" unless gtype

        plans = Jamf.cnx.jp_get("#{GROUP_PLANS_PATH}/#{group_id}?group-type=#{gtype}")[:results]
        plans.map do |plan_data|
          plan_data[:cnx] = cnx
          plan_data[:instantiate_me] = true
          new(**plan_data)
        end
      end

      # Get the declarations for a plan
      #
      # @param plan_uuid [String] the UUID of the plan to get declarations for
      #
      # @param cnx [Jamf::Connection] the connection to use, defaults to Jamf.cnx
      #
      # @return [Array<Jamf::OAPISchemas::DssDeclaration>] the declarations for the plan
      ############################
      def self.declarations(planUuid, cnx: Jamf.cnx)
        cnx.jp_get("#{LIST_PATH}/#{planUuid}/declarations")[:declarations].map do |declaration|
          Jamf::OAPISchemas::DssDeclaration.new(declaration)
        end
      end

      # get the events for a plan
      #
      # BUG ? : At lease thru Jamf Pro 11.17.1, this endpoint returns a double-wrapped JSON object
      # The first one is a Hash with one key :events, which is a String containing the JSON
      # for the actual events - an Array of Hashes, which don't have an OAPI schema.
      #
      # Those Hashes look like this, but aren't consistent
      #
      #   {:type=>".QueueAvailableOsUpdatesCommand",
      #   :eventSentEpoch=>1749158978751,
      #   :managementUUID=>"a94b11f0-c870-4006-82fe-e7afa981d61c",
      #   :processManagerUUID=>"a4b45b0a-4a46-4a52-8322-ab4f9895ab21",
      #   :availableOSUpdateDelay=>300},
      #
      #   {:id=>4238,
      #   :type=>".AvailableOsUpdateRequestCompletedEvent",
      #   :deviceObjectId=>1,
      #   :managementUUID=>"a94b11f0-c870-4006-82fe-e7afa981d61c",
      #   :eventReceivedEpoch=>1749159337161,
      #   :processManagerUUID=>"a4b45b0a-4a46-4a52-8322-ab4f9895ab21",
      #   :availableOSUpdatesDto=>
      #   {:deviceObjectId=>1,
      #     :managementUUID=>"a94b11f0-c870-4006-82fe-e7afa981d61c",
      #     :availableOsUpdates=>
      #     [{:build=>"",
      #       :preview=>false,
      #       :version=>"16.4",
      #       :critical=>false,
      #       :productKey=>"082-41241",
      #       :installSize=>0,
      #       :productName=>"",
      #       :downloadSize=>882235914,
      #       :majorOSUpdate=>false,
      #       :firmwareUpdate=>false,
      #       :restartRequired=>false,
      #       :humanReadableName=>"Command Line Tools for Xcode",
      #       :allowsInstallLater=>true,
      #       :appIdentifiersToClose=>[],
      #       :configurationDataUpdate=>false},
      #       {:build=>"",
      #       :preview=>false,
      #       :version=>"5299",
      #       :critical=>false,
      #       :productKey=>"082-54857",
      #       :installSize=>0,
      #       :productName=>"",
      #       :downloadSize=>1256157,
      #       :majorOSUpdate=>false,
      #       :firmwareUpdate=>false,
      #       :restartRequired=>false,
      #       :humanReadableName=>"XProtectPlistConfigData",
      #       :allowsInstallLater=>true,
      #       :appIdentifiersToClose=>[],
      #       :configurationDataUpdate=>true}],
      #     :eventReceivedEpoch=>1749159337161
      #     }
      #    }
      #
      # note that some have id's and some don't. Some have response data (like the available OS updates)
      # which can contain a more complex data structure.
      #
      # NOTE: This may be intentional, but is not documented in the JPAPI docs. The endpoint is "events"
      # but what's returned is an 'event store'. Its possible that the data comes from Apple as JSON
      # and Jamf is just passing it through.
      # Awaiting clarification from Jamf on this.
      #
      # In any case, this method will unwrap the JSON and return the events as an Array of Hashes
      #
      # @param plan_uuid [String] the UUID of the plan to get events for
      #
      # @param cnx [Jamf::Connection] the connection to use, defaults to Jamf.cnx
      #
      # @return [Array<Hash>] the events for the plan
      ############################
      def self.event_store(planUuid, cnx: Jamf.cnx)
        data = cnx.jp_get("#{LIST_PATH}/#{planUuid}/events")
        if data[:events].is_a?(String) && data[:events].start_with?('{"events":')
          JSON.parse data[:events], symbolize_names: true
        else
          data[:events]
        end
      end

      # Instance Methods
      ######################################

      # get the declarations for this plan
      #
      # @return [Array<Jamf::OAPISchemas::DssDeclaration>] the declarations for the plan
      ############################
      def declarations
        self.class.declarations(planUuid, cnx: cnx)
      end

      # get the events for this plan
      #
      # @return [Array<Jamf::OAPISchemas::DssDeclaration>] the events for the plan
      ############################
      def event_store
        self.class.event_store(planUuid, cnx: cnx)
      end

    end # class Plan

  end # module ManagedSoftwareUpdates

end # module Jamf
