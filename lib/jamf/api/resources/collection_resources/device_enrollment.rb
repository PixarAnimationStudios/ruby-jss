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

# The Module
module Jamf

  # Classes
  #####################################

  # A decvice enrollment defined in the Jamf Pro.
  #
  # This is a connection to Apple's Device Enrollment Program.
  # A single Jamf server may have many of them, and they can belong to
  # different sites.
  #
  # These objects can be used to find the details of all the devices
  # connected to them, including the device serial numbers.
  # To see how or if those devices are assigned to prestages, see
  # Jamf::Prestage and its subclasses ComputerPrestage and MobileDevicePrestage
  #
  class DeviceEnrollment < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    include Jamf::ChangeLog

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'device-enrollment'.freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute name
      #   @return [String]
      name: {
        class: :string,
        identifier: true
      },

      # @!attribute supervisionIdentityId
      #   @return [Integer]
      supervisionIdentityId: {
        class: :integer
      },

      # @!attribute siteId
      #   @return [Integer]
      siteId: {
        class: :integer
      },

      # @!attribute serverName
      #   @return [String]
      serverName: {
        class: :string
      },

      # @!attribute serverUuid
      #   @return [String]
      serverUuid: {
        class: :string
      },

      # @!attribute adminId
      #   @return [String]
      adminId: {
        class: :string
      },

      # @!attribute orgName
      #   @return [String]
      orgName: {
        class: :string
      },

      # @!attribute orgEmail
      #   @return [String]
      orgEmail: {
        class: :string
      },

      # @!attribute orgPhone
      #   @return [String]
      orgPhone: {
        class: :string
      },

      # @!attribute orgAddress
      #   @return [String]
      orgAddress: {
        class: :string
      },

      # @!attribute tokenExpirationDate
      #   @return [Jamf::Timestamp]
      tokenExpirationDate: {
        class: Jamf::Timestamp
      }
    }.freeze

    parse_object_model

    DEVICES_RSRC = 'devices'.freeze

    SYNC_RSRC = 'sync'.freeze

    LATEST_RSRC = 'latest'.freeze

    DISOWN_RSRC = 'disown'.freeze

    TYPES = %i[computers mobiledevices].freeze

    COMPUTERS_RE = /mac/i.freeze

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
    # @param instance_ident[Integer, String] the id or name of the
    #   DeviceEnrollment instance for which to list the devices. If omitted,
    #   the devices for all instances will be returned.
    #
    # @param type[Symbol] Either :computers or :mobiledevices, returns both if
    #  not specified.
    #
    # @param refresh [Boolean] re-read the data from the API?
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Array<Jamf::DeviceEnrollmentDevice>] The devices associated with
    #   the given DeviceEnrollment instance, or all instances
    #
    def self.devices(instance_ident = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      if type
        raise ArgumentError, "Type must be one of: :#{TYPES.join ', :'}" unless TYPES.include? type
      end

      devs = fetch_devices(instance_ident, refresh, cnx)
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
    def self.device_sns(instance_ident = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      devices(instance_ident, type: type, refresh: refresh, cnx: cnx).map(&:serialNumber)
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
    def self.include?(sn, instance_ident = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      device_sns(instance_ident, type: type, refresh: refresh, cnx: cnx).j_ci_include? sn
    end

    # See .devices
    #
    # Returns just those devices with the desired profileStatus, which must be
    # an item in DeviceEnrollmentDevice::PROFILE_STATUSES
    #
    # @param status[String] A member of DeviceEnrollmentDevice::PROFILE_STATUSES
    #
    # @return [Array<Jamf::DeviceEnrollmentDevice>] The devices with the desired
    #   status, associated with the given, or all,  instances
    #
    def self.devices_with_status(status, instance_ident = nil, type: nil, refresh: false, cnx: Jamf.cnx)
      unless Jamf::DeviceEnrollmentDevice::PROFILE_STATUSES.include? status
        raise ArgumentError, "profileStatus must be one of: '#{Jamf::DeviceEnrollmentDevice::PROFILE_STATUSES.join "', '"}'"
      end

      devices(instance_ident, type: type, refresh: refresh, cnx: cnx).select { |d| d.profileStatus == status }
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
    # @return [Jamf::DeviceEnrollmentDevice] the device as known to DEP
    #
    def self.device(sn, instance_ident = nil, refresh: false, cnx: Jamf.cnx)
      sn.upcase! # SNs from apple are always uppercase
      devs = devices(instance_ident, refresh: refresh, cnx: cnx)
      dev = devs.select { |d| d.serialNumber == sn }.first
      return dev if dev

      searched = instance_ident ? "DeviceEnrollment instance #{instance_ident}" : 'any DeviceEnrollment instance'
      raise Jamf::NoSuchItemError, "No device with serialNumber '#{sn}' in #{searched}"
    end

    # The history of sync operations between Apple and a given DeviceEnrollment
    # instanace, or all instances.
    #
    # @param instance_ident[Integer, String] the id or name of the
    #   DeviceEnrollment instance for which to get the history. If omitted,
    #   the history for all instances will be returned.
    #
    # @param latest [Boolean] show only the latest sync? Only valid when an
    #   instance_ident is provided.
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Jamf::DeviceEnrollmentSyncStatus] When latest = true, the latest
    #   sync status.
    # @return [Array<Jamf::DeviceEnrollmentSyncStatus>] The known sync statuses.
    #
    def self.sync_history(instance_ident = nil, latest = false, cnx: Jamf.cnx)
      if instance_ident
        instance_id = valid_id instance_ident, cnx: cnx
        raise Jamf::NoSuchItemError "No DeviceEnrollment instance matches '#{instance_ident}'" unless instance_id

        rsrc = "#{RSRC_VERSION}/#{RSRC_PATH}/#{SYNC_RSRC}/#{instance_id}"
        rsrc += "/#{LATEST_RSRC}" if latest
      else
        rsrc = "#{RSRC_VERSION}/#{RSRC_PATH}/#{SYNC_RSRC}"
      end
      data = cnx.get rsrc

      return Jamf::DeviceEnrollmentSyncStatus.new data if data.is_a? Hash

      data.map! { |s| Jamf::DeviceEnrollmentSyncStatus.new s }
    end

    # disown one or more serial numbers from a given DeviceEnrollment instance
    #
    # @param sns[Array<String>] One or more serial numbers to disown
    #
    # @param from_instance [Integer, String] the id or name of the instance
    #  from which to disown the serial numbers
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [void]
    #
    def self.disown(*sns, from_instance:, cnx: Jamf.cnx)
      instance_id = valid_id from_instance, cnx: cnx
      raise Jamf::NoSuchItemError, "No DeviceEnrollment instance matches '#{instance}'" unless instance_id

      sns.flatten!
      sns.map!(&:to_s)
      data = { devices: sns }
      disown_rsrc = "#{self.class::RSRC_VERSION}/#{self.class::RSRC_PATH}/#{instance_id}/#{DISOWN_RSRC}"

      cnx.post(disown_rsrc, data)
    end

    # Private Class Methods
    ###############################################

    # Private, used by the .devices class method
    def self.fetch_devices(instance_ident, refresh, cnx)
      if instance_ident
        instance_id = valid_id instance_ident, cnx: cnx
        raise Jamf::NoSuchItemError, "No DeviceEnrollment instance matches '#{instance_ident}'" unless instance_id

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

      data = cnx.get("#{RSRC_VERSION}/#{RSRC_PATH}/#{instance_id}/#{DEVICES_RSRC}")[:results]

      data.map! { |dev| Jamf::DeviceEnrollmentDevice.new dev }
      @device_cache[cnx][instance_id] = data
    end
    private_class_method :devices_for_instance_id

    # Instance Methods
    #########################################

    def devices(type: nil)
      self.class.devices @id, type: type, cnx: @cnx
    end

    def device_sns(type: nil)
      devices(type: type).map(&:serialNumber)
    end

    def include?(sn, type: nil)
      device_sns(type: type).j_ci_include? sn
    end

    def devices_with_status(status, type: nil)
      self.class.devices_with_status(status, @id, type: type, cnx: @cnx)
    end

    def sync_history(latest = false)
      self.class.sync_history(@id, latest, cnx: @cnx)
    end

    def latest_sync
      sync_history :latest
    end

    def disown(*sns)
      self.class.disown sns, from_instance: @id, cnx: @cnx
    end

  end # class

end # module
