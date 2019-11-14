# Copyright 2018 Pixar

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

# The module
module Jamf

  # A mobile device in the JSS
  class MobileDevice < Jamf::CollectionResource

    # Mix-Ins
    #####################################

    include Jamf::Referable
    include Jamf::Locatable
    include Jamf::Extendable

    # currently not creatable via API
    # TODO: remove this when it's time
    extend Jamf::UnCreatable

    # currently not creatable via API
    # TODO: remove this when it's time
    extend Jamf::UnDeletable

    # Class Constants
    #####################################

    IOS = 'ios'.freeze
    APPLETV = 'appleTv'.freeze
    ANDROID = 'android'.freeze
    UNKNOWN = 'unknown'.freeze

    IPHONE = 'iPhone'.freeze
    IPOD = 'iPod'.freeze
    IPAD = 'iPad'.freeze

    # The enum for the 'type' attribute
    TYPES = [
      IOS,
      APPLETV,
      ANDROID,
      UNKNOWN
    ].freeze

    APPLE_TYPES = [IOS, APPLETV].freeze

    RSRC_PATH = '/inventory/obj/mobileDevice'.freeze

    # This has a non-std update resource
    # we POST to /inventory/obj/mobileDevice/{id}/update
    # instad of the normal PUT to /inventory/obj/mobileDevice/{id}
    UPDATE_RESOURCE = { method: :post, path_suffix: 'update' }.freeze

    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute name
      #   @param [String]
      #   @return [String]
      name: {
        class: :string
      },

      # @!attribute [r] serialNumber
      #   @return [String]
      serialNumber: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] wifiMacAddress
      #   @return [String]
      wifiMacAddress: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] udid
      #   @return [String]
      udid: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] phoneNumber
      #   @return [String]
      phoneNumber: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] model
      #   @return [String]
      model: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] modelIdentifier
      #   @return [String]
      modelIdentifier: {
        class: :string,
        readonly: true
      },

      # @!attribute username
      #   Has custom setter, is part of Location in Details
      #   @param [String]
      #   @return [String]
      username: {
        class: :string,
        readonly: true
      },

      # TODO: Will jamf give us isManaged or isSupervised?
      # in the non-detail data?
      # @!attribute [r] isManaged
      #   @return [Boolean]
      # isManaged: {
      #   class: :boolean,
      #   readonly: true
      # },

      # @!attribute [r] type
      #   @return [Symbol]
      type: {
        class: :string,
        readonly: true,
        enum: Jamf::MobileDevice::TYPES
      }

    }.freeze
    parse_object_model

    # Class Methods
    #####################################

    # TODO: when jamf gives us isManaged in base object
    # @return [Array<Hash>] the list of all managed mobile devices
    # def self.all_unmanaged(refresh = false, api: JAMF.api)
    #   all(refresh, api: api).reject { |d| d[:managed] }
    # end

    # TODO: when jamf gives us isManaged in base object
    # @return [Array<Hash>] the list of all unmanaged mobile devices
    # def self.all_unmanaged(refresh = false, api: JAMF.api)
    #   all(refresh, api: api).reject { |d| d[:managed] }
    # end

    # TODO: when jamf gives us isSupervised in base object
    # @return [Array<Hash>] the list of all supervised mobile devices
    # def self.all_supervised(refresh = false, api: JAMF.api)
    #   all(refresh, api: api).select { |d| d[:supervised] }
    # end

    # TODO: when jamf gives us isSupervised in base object
    # @return [Array<Hash>] the list of all unsupervised mobile devices
    # def self.all_unsupervised(refresh = false, api: JAMF.api)
    #   all(refresh, api: api).reject { |d| d[:supervised] }
    # end

    # @return [Array<Hash>] the list of all iPhones
    def self.all_iphones(refresh: false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).select { |d| d[:model].start_with? IPHONE }
    end

    # @return [Array<Hash>] the list of all iPods
    def self.all_ipods(refresh: false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).select { |d| d[:model].start_with? IPOD }
    end

    # @return [Array<Hash>] the list of all iPads
    def self.all_ipads(refresh: false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).select { |d| d[:model].start_with? IPAD }
    end

    # @return [Array<Hash>] the list of all AppleTVs
    def self.all_appleTvs(refresh: false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).select { |d| d[:type] == APPLETV }
    end

    # @return [Array<Hash>] the list of all Androids
    def self.all_androids(refresh: false, cnx: Jamf.cnx)
      all(refresh, cnx: cnx).select { |d| d[:type] == ANDROID }
    end

    # Instance Methods
    # Lots of overriding of standard methods in our metaclasses
    # becuase we have a separate @details object, as well as
    # a non-standard UPDATE_RESOURCE object model
    # If this pattern becomes more common, and is uniform,
    # (i.e. for computers) we'll make  these methods into a module
    #
    #######################################

    # This custom method outputs a 'UpdateMobileDevice' object model
    # as defined in the API docs
    #
    def to_jamf
      changes = unsaved_changes
      data_to_send = {}

      data_to_send[:name] = changes[:name][:new] if changes[:name]

      data_to_send[:assetTag] = changes[:assetTag][:new] if changes[:assetTag]
      data_to_send[:siteId] = changes[:site][:new].id if changes[:site]
      data_to_send[:location] = details.location.to_jamf if changes[:location]
      data_to_send[:updatedExtensionAttributes] = ext_attrs_to_jamf if ext_attrs_unsaved_changes?

      return data_to_send unless APPLE_TYPES.include? @type

      data_to_send[@type] = { purchasing: details.type_details.purchasing.to_jamf } if changes[:type_changes][:purchasing]

      data_to_send[APPLETV][:airplayPassword] = changes[:type_changes][:airplayPassword][:new] if @type == APPLETV && changes[:type_changes][:airplayPassword]

      data_to_send
    end # to_jamf

    # TODO - needed?  Clean up?
    # merge top-level and details changes and type-specific changes
    def unsaved_changes
      @unsaved_changes ||= {}
      # name is the only thing at the top-level that isn't readonly
      if @details
        changes = details.unsaved_changes
        changes[:name] = @unsaved_changes[:name] if @unsaved_changes[:name]
        changes[:ext_attrs] = ext_attrs_unsaved_changes if ext_attrs_unsaved_changes?
        type_changes = type_details.unsaved_changes
        changes[:type_changes] = type_changes unless type_changes.empty?
      else
        changes = @unsaved_changes
      end
      changes
    end

    # clear changes for details as well as top
    def clear_unsaved_changes
      @details.clear_unsaved_changes if @details
      ext_attrs_clear_unsaved_changes
      @unsaved_changes = {}
    end

    # Fetch the details as needed
    def details
      @details ||= MobileDeviceDetails.fetch @id, @cnx
    end # details

    # Return the correct part of the details for the
    # device type
    def type_details
      case @type
      when :ios then details.ios
      when :appleTv then details.appleTv
      when :android then details.android
      end
    end

    # catches the attributes in the details
    def method_missing(meth, *args, &block)
      if details.respond_to? meth
        details.send meth, *args, &block
      elsif type_details.respond_to? meth
        type_details.send meth, *args, &block
      else
        super
      end
    end

    # provides respond_to? for the attributes in the details
    def respond_to_missing?(meth, *)
      if details.respond_to? meth
        true
      elsif type_details.respond_to? meth
        true
      else
        super
      end
    end

  end # class Mobile Device

end # module
