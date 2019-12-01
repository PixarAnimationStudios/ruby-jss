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

  # A decvice enrollment defined in the JSS
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

    TYPES = %i[computers mobiledevices].freeze

    COMPUTERS_RE = /mac/i.freeze

    # Class Methods
    #########################################

    # All devices associated by Apple with a given DeviceEnrollment instance
    # or all defined DeviceEnrollment instances
    #
    # @param instance_ident[Integer, String] the id or name of the
    #   DeviceEnrollment instance for which to list the devices. If omitted,
    #   the devices for all instances will be returned.
    #
    # @param type[Symbol] Either :computers or :mobiledevices, returns both if
    #  not specified.
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Array<Jamf::DeviceEnrollmentDevice>] The devices associated with
    #   the given, or all,  instances
    #
    def self.devices(instance_ident = nil, type: nil, cnx: Jamf.cnx)
      if type
        raise ArgumentError, "Type must be one of: :#{TYPES.join ', :'}" unless TYPES.include? type
      end

      if instance_ident
        instance_id = valid_id instance_ident, cnx: cnx
        raise Jamf::NoSuchItemError "No DeviceEnrollment instance matches '#{instance_ident}'" unless instance_id

        devs = devices_for_instance_id instance_id, cnx

      else
        devs = []
        all_ids.each do |id|
          devs += devices_for_instance_id id, cnx
        end
      end
      return devs unless type

      if type == :computers
        devs.select { |d| d.model =~ COMPUTERS_RE }
      else
        devs.reject { |d| d.model =~ COMPUTERS_RE }
      end
    end

    # See .devices
    # Returns just the serial numbers for the devices
    def self.device_sns(instance_ident = nil, type: nil, cnx: Jamf.cnx)
      devices(instance_ident, type: type, cnx: cnx).map(&:serialNumber)
    end

    # Private, used by the .devices class method
    def self.devices_for_instance_id(instance_id, cnx)
      data = cnx.get("#{RSRC_VERSION}/#{RSRC_PATH}/#{instance_id}/#{DEVICES_RSRC}")[:results]

      data.map { |dev| Jamf::DeviceEnrollmentDevice.new dev }
    end
    private_class_method :devices_for_instance_id

    # Instance Methods
    #########################################

  end # class

end # module
