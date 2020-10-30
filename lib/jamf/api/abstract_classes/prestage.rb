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

# The Module
module Jamf

  # Classes
  #####################################

  # The parent class of ComputerPrestage, and MobileDevicePrestage
  # holding common code.
  class Prestage < Jamf::CollectionResource

    extend Jamf::Abstract
    include Jamf::Lockable

    # Constants
    #####################################

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [String]
      id: {
        class: :j_id,
        identifier: :primary,
        readonly: true
      },

      # @!attribute displayName
      #   @return [String]
      displayName: {
        class: :string,
        identifier: true,
        validator: :non_empty_string,
        required: true,
        aliases: %i[name]
      },

      # @!attribute mandatory
      #   @return [Boolean]
      mandatory: {
        class: :boolean
      },

      # @!attribute mdmRemovable
      #   @return [Boolean]
      mdmRemovable: {
        class: :boolean
      },

      # @!attribute supportPhoneNumber
      #   @return [String]
      supportPhoneNumber: {
        class: :string
      },

      # @!attribute supportEmailAddress
      #   @return [String]
      supportEmailAddress: {
        class: :string
      },

      # @!attribute department
      #   @return [String]
      department: {
        class: :string
      },

      # @!attribute defaultPrestage
      #   @return [Boolean]
      defaultPrestage: {
        class: :boolean,
        aliases: [:default?]
      },

      # @!attribute enrollmentSiteId
      #   @return [Integer]
      enrollmentSiteId: {
        class: :j_id
      },

      # @!attribute keepExistingSiteMembership
      #   @return [Boolean]
      keepExistingSiteMembership: {
        class: :boolean
      },

      # @!attribute keepExistingLocationInformation
      #   @return [Boolean]
      keepExistingLocationInformation: {
        class: :boolean
      },

      # @!attribute requireAuthentication
      #   @return [Boolean]
      requireAuthentication: {
        class: :boolean
      },

      # @!attribute authenticationPrompt
      #   @return [String]
      authenticationPrompt: {
        class: :string
      },

      # @!attribute preventActivationLock
      #   @return [Boolean]
      preventActivationLock: {
        class: :boolean
      },

      # @!attribute enableDeviceBasedActivationLock
      #   @return [Boolean]
      enableDeviceBasedActivationLock: {
        class: :boolean
      },

      # @!attribute deviceEnrollmentProgramInstanceId
      #   @return [Integer]
      deviceEnrollmentProgramInstanceId: {
        class: :j_id
      },

      # @!attribute locationInformation
      #   @return [Jamf::ComputerPrestageSkipSetupItems]
      locationInformation: {
        class: Jamf::PrestageLocation,
        aliases: %i[location]
      },

      # @!attribute skipSetupItems
      #   @return [Jamf::ComputerPrestageSkipSetupItems]
      purchasingInformation: {
        class: Jamf::PrestagePurchasingData,
        aliases: %i[purchasing]
      },

      # @!attribute anchorCertificates
      #   @return [Array<String>]
      anchorCertificates: {
        class: :string,
        multi: true
      },

      # @!attribute enrollmentCustomizationId
      #   @return [Integer]
      enrollmentCustomizationId: {
        class: :j_id
      },

      # @!attribute language
      #   @return [String]
      language: {
        class: :string
      },

      # @!attribute region
      #   @return [String]
      region: {
        class: :string
      },

      # @!attribute autoAdvanceSetup
      #   @return [Boolean]
      autoAdvanceSetup: {
        class: :boolean
      },

      # @!attribute profileUUID
      #   @return [String]
      profileUuid: {
        class: :string
      },

      # @!attribute siteId
      #   @return [Integer]
      siteId: {
        class: :j_id
      }

    }.freeze

    SCOPE_RSRC = 'scope'.freeze

    SERIALS_KEY = :serialsByPrestageId

    SYNC_RSRC = 'sync'.freeze

    # Class Methods
    #####################################

    # Return the Prestage subclass that is marked as default,
    # i.e. the one that new SNs are assigned to when first added.
    # Nil if no default is defined
    # @return [Jamf::Prestage, nil]
    #
    def self.default
      # only one can be true at a time, so sort desc by that field,
      # and the true one will be at the top
      default_prestage_data = all(sort: 'defaultPrestage:desc', paged: true, page_size: 1).first

      # Just in case there was no true one, make sure defaultPrestage is true
      return unless default_prestage_data&.dig(:defaultPrestage)

      fetch id: default_prestage_data[:id]
    end

    # Return all scoped serial numbers and the id of the prestage
    # they are assigned to. Data is cached, use a truthy first param to refresh.
    #
    # @param refresh[Boolean] re-read the list from the API?
    #
    # @param cnx[Jamf::Connection] the API connection to use
    #
    # @return [Hash {String => Integer}] The Serials and prestage IDs
    #
    def self.serials_by_prestage_id(refresh = false, cnx: Jamf.cnx)
      @serials_by_prestage_rsrc ||= "#{self::RSRC_VERSION}/#{self::RSRC_PATH}/#{SCOPE_RSRC}"
      @serials_by_prestage_id = nil if refresh
      @serials_by_prestage_id ||= cnx.get(@serials_by_prestage_rsrc)[SERIALS_KEY].transform_keys!(&:to_s)
    end

    # Get the assigned serialnumbers for a given prestage
    #
    # @paream prestage_ident [Integer, String] the id or name of
    #   an existing prestage.
    #
    # @param refresh[Boolean] re-read the list from the API?
    #
    # @param cnx[Jamf::Connection] the API connection to use
    #
    # @return [Array<String>] the SN's assigned to the prestage
    #
    def self.serials_for_prestage(prestage_ident, refresh = false, cnx: Jamf.cnx)
      id = valid_id prestage_ident, cnx: cnx
      raise Jamf::NoSuchItemError, "No #{self} matching '#{prestage_ident}'" unless id

      serials_by_prestage_id(refresh, cnx: cnx).select { |_sn, psid| id == psid }.keys
    end

    # The id of the prestage to which the given serialNumber is assigned.
    # nil if not assigned or not in DEP.
    #
    # NOTE: If a serial number isn't assigned to any prestage, it may really be
    # unassigned or it may not exist in your DEP. To see if a SN exists in one
    # of your Device Enrollment instances, use Jamf::DeviceEnrollment.include?
    #
    # @param sn [String] the serial number to look for
    #
    # @param refresh[Boolean] re-read the list from the API?
    #
    # @param cnx[Jamf::Connection] the API connection to use
    #
    # @return [Integer, nil] The id of prestage to which the SN is assigned
    #
    def self.assigned_prestage_id(sn, refresh = false, cnx: Jamf.cnx)
      serials_by_prestage_id(refresh, cnx: cnx)[sn]
    end

    # Is the given serialNumber assigned to any prestage, or to the
    # given prestage if a prestage_ident is specified?
    #
    # NOTE: If a serial number isn't assigned to any prestage, it may really be
    # unassigned or it may not exist in your DEP. To see if a SN exists in one
    # of your Device Enrollment instances, use Jamf::DeviceEnrollment.include?
    #
    # @param sn [String] the serial number to look for
    #
    # @param refresh[Boolean] re-read the list from the API?
    #
    # @paream prestage_ident[Integer, String] If provided, the id or name of
    #   an existing prestage in which to look for the sn. if omitted, all
    #   prestages are searched.
    #
    # @param cnx[Jamf::Connection] the API connection to use
    #
    # @return [Boolean] Is the sn assigned, at all or to the given prestage?
    #
    def self.assigned?(sn, prestage_ident = nil, refresh: false, cnx: Jamf.cnx)
      assigned_id = assigned_prestage_id(sn, refresh, cnx: cnx)
      return false unless assigned_id

      if prestage_ident
        psid = valid_id prestage_ident, cnx: cnx
        raise Jamf::NoSuchItemError, "No #{self} matching '#{prestage_ident}'" unless psid

        return psid == assigned_id
      end

      true
    end

    # We subtract the serials_by_prestage_id.keys from all known DEP SNs
    # rather than just looking for Jamf::DeviceEnrollment.devices  with status
    # REMOVED, because of the delay in updating the status for
    # Jamf::DeviceEnrollment::Devices, which must come from apple.
    #
    # @return [Array<String>] The serial numbers of devices that are in DEP but
    #    not assigned to any prestage
    #
    def self.unassigned_sns(cnx: Jamf.cnx)
      type = self == Jamf::MobileDevicePrestage ? :mobiledevices : :computers
      Jamf::DeviceEnrollment.device_sns(type: type, cnx: cnx) - serials_by_prestage_id(:refresh, cnx: cnx).keys
    end

    # @return [Array<String>] The serial numbers of known hardware not in DEP
    #   at all
    def self.sns_not_in_device_enrollment
      # type = self == Jamf::MobileDevicePrestage ? :mobiledevices : :computers
      nil # TODO: this, once MobileDevice  & Computer classes are implemented
    end

    # Assign one or more serialNumber to a prestage
    # @return [Jamf::PrestageScope] the new scope for the prestage
    def self.assign(*sns_to_assign, to_prestage:, cnx: Jamf.cnx)
      prestage_id = valid_id to_prestage
      raise Jamf::NoSuchItemError, "No #{self} matching '#{to_prestage}'" unless prestage_id

      # all sns_to_assign must be in DEP
      not_in_dep = sns_to_assign - Jamf::DeviceEnrollment.device_sns
      raise Jamf::UnsupportedError, "These SNs are not in any Device Enrollment instance: #{not_in_dep.join ', '}" unless not_in_dep.empty?

      # all sns_to_assign must currently be unassigned.
      already_assigned = sns_to_assign - unassigned_sns
      raise Jamf::UnsupportedError, "These SNs are already assigned to a prestage: #{already_assigned.join ', '}" unless already_assigned.empty?

      # upcase all sns
      sns_to_assign.map!(&:to_s)
      sns_to_assign.map!(&:upcase)

      # get the prestage name
      prestage_name = map_all(:id, to: :displayName)[prestage_id]

      scope_rsrc = "#{self::RSRC_VERSION}/#{self::RSRC_PATH}/#{prestage_id}/#{SCOPE_RSRC}"
      scope = Jamf::PrestageScope.new cnx.get(scope_rsrc)

      # add the new sns to the existing ones
      new_scope_sns = scope.assignments.map(&:serialNumber)
      new_scope_sns += sns_to_assign
      new_scope_sns.uniq!

      update_scope(prestage_name, scope_rsrc, new_scope_sns, scope.versionLock, cnx)
    end # self.assign

    # Unassign one or more serialNumber from a prestage
    # @return [Jamf::PrestageScope] the new scope for the prestage
    def self.unassign(*sns_to_unassign, from_prestage:, cnx: Jamf.cnx)
      prestage_id = valid_id from_prestage
      raise Jamf::NoSuchItemError, "No #{self} matching '#{from_prestage}'" unless prestage_id

      # upcase all sns
      sns_to_unassign.map!(&:to_s)
      sns_to_unassign.map!(&:upcase)

      # get the prestage name
      prestage_name = map_all(:id, to: :displayName)[prestage_id]

      scope_rsrc = "#{self::RSRC_VERSION}/#{self::RSRC_PATH}/#{prestage_id}/#{SCOPE_RSRC}"
      scope = Jamf::PrestageScope.new cnx.get(scope_rsrc)

      new_scope_sns = scope.assignments.map(&:serialNumber)
      new_scope_sns -= sns_to_unassign

      update_scope(prestage_name, scope_rsrc, new_scope_sns, scope.versionLock, cnx)
    end # self.unassign

    # Provate Class Methods
    #####################################

    # used by assign and unassign
    def self.update_scope(prestage_name, scope_rsrc, new_scope_sns, vlock, cnx)
      assignment_data = {
        serialNumbers: new_scope_sns,
        versionLock: vlock
      }
      Jamf::PrestageScope.new cnx.put(scope_rsrc, assignment_data)
    rescue Jamf::Connection::APIError => e
      raise Jamf::VersionLockError, "The #{self} '#{prestage_name}' was modified by another process during this operation. Please try again" if e.status == 409

      raise e
    end
    private_class_method :update_scope

    # Instance Methods
    #####################################

    # The scope data for this prestage
    #
    # @param refresh[Boolean] reload fromthe API?
    #
    # @return [PrestageScope]
    #
    def scope(refresh = false)
      @scope = nil if refresh
      return @scope if @scope

      @scope = Jamf::PrestageScope.new @cnx.get(scope_rsrc)
      unless @scope.versionLock == @versionLock
        raise Jamf::VersionLockError, "The #{self.class} '#{name}' has been modified since it was fetched. Please refetch and try again"
      end

      @scope
    end

    # @return [Array<String>] the serialnumbers assigned to this prestage
    def assigned_sns
      scope.assignments.map(&:serialNumber)
    end

    # Is this SN assigned to this prestage?
    #
    # @param sn[String] the sn to look for
    #
    # @return [Boolean]
    #
    def assigned?(sn)
      assigned_sns.include? sn
    end
    alias include? assigned?

    # Assign
    def assign(*sns_to_assign)
      @scope = self.class.assign(sns_to_assign, to_prestage: @id, cnx: @cnx)
      @versionLock = @scope.versionLock

      # sns_to_assign.map!(&:to_s)
      # new_scope_sns = assigned_sns
      # new_scope_sns += sns_to_assign
      # new_scope_sns.uniq!
      # update_scope(new_scope_sns)
    end
    alias add assign

    def unassign(*sns_to_unassign)
      @scope = self.class.unassign(sns_to_unassign, from_prestage: @id, cnx: @cnx)
      @versionLock = @scope.versionLock
      # sns_to_unassign.map!(&:to_s)
      # new_scope_sns = assigned_sns
      # new_scope_sns -= sns_to_unassign
      # update_scope(new_scope_sns)
    end
    alias remove unassign

    def save
      super
      # the scope needs to be refreshed, since its versionLock will need to be
      # updated
      @scope = nil
    end

    # Private Instance Methods
    ############################
    private

    def scope_rsrc
      @scope_rsrc ||= "#{self.class::RSRC_VERSION}/#{self.class::RSRC_PATH}/#{@id}/#{SCOPE_RSRC}"
    end

    # def update_scope(new_scope_sns)
    #   assignment_data = {
    #     serialNumbers: new_scope_sns,
    #     versionLock: @scope.versionLock
    #   }
    #   begin
    #     @scope = Jamf::PrestageScope.new @cnx.put(scope_rsrc, assignment_data)
    #   rescue Jamf::Connection::APIError => e
    #     raise Jamf::VersionLockError, "The #{self.class} '#{name}' has been modified since it was fetched. Please refetch and try again" if e.status == 409
    #
    #     raise e
    #   end # begin
    #   @versionLock = @scope.versionLock
    # end

  end # class

end # module
