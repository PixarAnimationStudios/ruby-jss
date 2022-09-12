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

# The Module
module Jamf

  # Classes
  #####################################

  # A decvice enrollment defined in the Jamf Pro.
  #
  # This is a connection to Apple's Automated Device Enrollment Program.
  # A single Jamf server may have many of them, and they can belong to
  # different sites.
  #
  # These objects can be used to find the details of all the devices
  # connected to them, including the device serial numbers.
  # To see how or if those devices are assigned to prestages, see
  # Jamf::Prestage and its subclasses ComputerPrestage and MobileDevicePrestage
  #
  class DeviceEnrollment < Jamf::OAPISchemas::DeviceEnrollmentInstance

    include Jamf::CollectionResource

    # Mix-Ins
    #####################################

    # include Jamf::ChangeLog

    # Constants
    #####################################

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.
    #
    # TODO: See if these constants can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::DeviceEnrollmentInstanceSearchResults

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::DeviceEnrollmentToken

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::DeviceEnrollmentInstance

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
    LIST_PATH = 'v1/device-enrollments'.freeze

    POST_PATH = "#{LIST_PATH}/upload-token".freeze

    PUB_KEY_PATH_SUFFIX = 'public-key'.freeze

    DEVICES_PATH_SUFFIX = 'devices'.freeze

    SYNCS_PATH_SUFFIX = 'syncs'.freeze

    LATEST_PATH_SUFFIX = 'latest'.freeze

    DISOWN_PATH_SUFFIX = 'disown'.freeze

    TYPES = %i[computers mobiledevices].freeze

    COMPUTERS_RE = /mac/i.freeze

    # TODO: Find out if 'name' is enforced to be unique
    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only marks ':id'. These values are unique in the collection
    # ALT_IDENTIFIERS = %i[name].freeze

    # Values which are useful as identifiers, but are not necessarily unique
    # in the collection - e.g. more than one computer can have the same name
    # WARNING
    # When more than one item in the collection has the same value for
    # one of these fields, which one is used, returned, selected, is undefined
    # You Have Been Warned!
    NON_UNIQUE_IDENTIFIERS = %i[name].freeze

    # Class Methods
    #########################################

    # All devices associated by Apple with a given DeviceEnrollment instance
    # or all defined DeviceEnrollment instances.
    #
    # This data is cached the first time it is read from the API, similarly to
    # how CollectionResources are cached. To refresh the cache, pass
    # a truthy value to the refresh: parameter, or use the Connection's
    # .flushcache method
    #
    # @param instance[Integer, String] the id or name of the
    #   DeviceEnrollment instance for which to list the devices. If omitted,
    #   the devices for all instances will be returned.
    #
    # @param type [Symbol] Either :computers or :mobiledevices, returns both if
    #  not specified.
    #
    # @param refresh [Boolean] re-read the data from the API?
    #
    # @param cnx [Jamf::Connection] The API connection to use
    #
    # @return [Array<Jamf::OAPISchemas::DeviceEnrollmentDevice>] The devices associated with
    #   the given DeviceEnrollment instance, or all instances
    #
    def self.devices(instance = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      raise ArgumentError, "Type must be one of: :#{TYPES.join ', :'}" if type && !TYPES.include?(type)

      devs = fetch_devices(instance, refresh, cnx)
      return devs unless type

      if type == :computers
        devs.select { |d| d.model =~ COMPUTERS_RE }
      else
        devs.reject { |d| d.model =~ COMPUTERS_RE }
      end
    end

    # The serial numbers assigned bu Apple to one, or all of your
    # Device Enrollment instances
    #
    # See .devices
    #
    # @return [Array<String>] just the serial numbers for the devices
    #
    def self.device_sns(instance = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      devices(instance, type: type, refresh: refresh, cnx: cnx).map(&:serialNumber)
    end

    # Is the given serial number in one, or any, or your Device Enrollment
    # instances?
    #
    # See .devices
    #
    # @param sn [String] the serialNumber to look for
    #
    # @return [Boolean] is the given SN in a given DeviceEnrollment instance
    # or in DEP at all?
    #
    def self.include?(sn, instance = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      device_sns(instance, type: type, refresh: refresh, cnx: cnx).j_ci_include? sn
    end

    # See .devices
    #
    # Returns just those devices with the desired profileStatus, which must be
    # an item in Jamf::OAPISchemas::DeviceEnrollmentDevice::PROFILE_STATUS_OPTIONS
    #
    # @param status[String] A member of Jamf::OAPISchemas::DeviceEnrollmentDevice::PROFILE_STATUS_OPTIONS
    #
    # @return [Array<Jamf::DeviceEnrollmentDevice>] The devices with the desired
    #   status, associated with the given, or all,  instances
    #
    def self.devices_with_status(status, instance = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      statuses = Jamf::OAPISchemas::DeviceEnrollmentDevice::PROFILE_STATUS_OPTIONS
      raise ArgumentError, "profileStatus must be one of: '#{statuses.join "', '"}'" unless statuses.include? status

      devices(instance, type: type, refresh: refresh, cnx: cnx).select { |d| d.profileStatus == status }
    end

    # Fetch a single device from any defined DeviceEnrollment instance.
    # The instance id containing the device is available in its
    # .deviceEnrollmentProgramInstanceId attribute.
    #
    # @pararm sn [String] the serial number of the device
    #
    # @param instance_ident [String, Integer] the name or id of the instance
    # in which to look for the sn. All instances are searched if omitted.
    #
    # @param refresh [Boolean] re-read the data from the API?
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Jamf::DeviceEnrollmentDevice, nil] the device as known to DEP
    #
    def self.device(sn, instance = nil, refresh: false, cnx: Jamf.cnx)
      sn.upcase! # SNs from apple are always uppercase
      devs = devices(instance, refresh: refresh, cnx: cnx)
      devs.select { |d| d.serialNumber == sn }.first
    end

    # The history of sync operations between Apple and a given DeviceEnrollment
    # instanace, or all instances.
    #
    # @param instance [Integer, String] the id or name of the
    #   DeviceEnrollment instance for which to get the history. If omitted,
    #   the history for all instances will be returned.
    #
    # @param latest [Boolean] show only the latest sync? Only valid when an
    #   instance is provided.
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus] When latest = true, the latest
    #   sync status.
    # @return [Array<JJamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus>] The known sync statuses.
    #
    def self.sync_history(instance = nil, latest: false, cnx: Jamf.cnx)
      if instance
        instance_id = valid_id instance, cnx: cnx
        raise Jamf::NoSuchItemError "No DeviceEnrollment instance matches '#{instance_ident}'" unless instance

        path = "#{get_path}/#{instance_id}/#{SYNCS_PATH_SUFFIX}"
        path += "/#{LATEST_PATH_SUFFIX}" if latest
      else
        path = "#{get_path}/#{SYNCS_PATH_SUFFIX}"
        latest = false
      end

      data = cnx.jp_get path

      return Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus.new data if latest

      data.map! { |s| Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus.new s }
    end

    # disown one or more serial numbers from a given DeviceEnrollment instance
    #
    # @param sns[String, Array<String>] One or more serial numbers to disown
    #
    # @param from_instance [Integer, String] the id or name of the instance
    #  from which to disown the serial numbers
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Hash] The SNs as keys and 'SUCESS' or 'FAILED' as values
    #
    def self.disown(*sns, from_instance:, cnx: Jamf.cnx)
      instance_id = valid_id from_instance, cnx: cnx
      raise Jamf::NoSuchItemError, "No DeviceEnrollment instance matches '#{instance}'" unless instance_id

      sns.flatten!
      sns.map!(&:to_s)
      data = { devices: sns }

      disown_path = "#{get_path}/#{instance_id}/#{DISOWN_PATH_SUFFIX}"
      resp = Jamf::OAPISchemas::DeviceEnrollmentDisownResponse.new cnx.jp_post(disown_path, data)

      resp.devices
    end

    # Private Class Methods
    ###############################################

    # Private, used by the .devices instance method
    def self.fetch_devices(instance = nil, refresh, cnx)
      if instance
        instance_id = valid_id instance, cnx: cnx
        raise Jamf::NoSuchItemError, "No DeviceEnrollment instance matches '#{instance}'" unless instance_id

        devs = devices_for_instance_id instance_id, refresh, cnx
      else
        devs = []
        all_ids.each do |id|
          devs += devices_for_instance_id id, refresh, cnx
        end
      end
      devs
    end
    private_class_method :fetch_devices

    # Private, used by the .fetch_devices class method
    def self.devices_for_instance_id(instance_id, refresh, cnx)
      @device_cache ||= {}
      @device_cache[cnx] ||= {}
      @device_cache[cnx][instance_id] = nil if refresh
      return @device_cache[cnx][instance_id] if @device_cache[cnx][instance_id]

      data =
        Jamf::OAPISchemas::DeviceEnrollmentDeviceSearchResults.new(
          cnx.jp_get("#{LIST_PATH}/#{instance_id}/#{DEVICES_PATH_SUFFIX}")
        ).results
      @device_cache[cnx][instance_id] = data
    end
    private_class_method :devices_for_instance_id

    # Instance Methods
    #########################################

    def devices(type: nil, refresh: false)
      self.class.devices @id, type: type, cnx: @cnx, refresh: refresh
    end

    def device_sns(type: nil, refresh: false)
      devices(type: type, refresh: refresh).map(&:serialNumber)
    end

    def include?(sn, type: nil, refresh: false)
      device_sns(type: type, refresh: refresh).j_ci_include? sn
    end

    def devices_with_status(status, type: nil, refresh: false)
      self.class.devices_with_status(status, @id, type: type, refresh: refresh, cnx: @cnx)
    end

    def sync_history(latest: false)
      self.class.sync_history(@id, latest: latest, cnx: @cnx)
    end

    def latest_sync
      sync_history latest: true
    end

    def disown(*sns)
      self.class.disown sns, from_instance: @id, cnx: @cnx
    end

  end # class

end # module
