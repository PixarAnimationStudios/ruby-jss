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

module Jamf

  # The Shared Code for ComputerPrestage and MobileDevicePrestage
  module Prestage

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including Jamf::Prestage"
      includer.extend(ClassMethods)
    end

    # Constants
    #####################################

    # The scope of a prestage is all the SN's that have been assigned to it
    SCOPE_PATH = 'scope'.freeze

    # The class-level scopes method returns one of these objects
    ALL_SCOPES_OBJECT = Jamf::OAPISchemas::PrestageScopeV2

    # the instance level scope method or the class level
    # serials_for_prestage method returns one of these.
    INSTANCE_SCOPE_OBJECT = Jamf::OAPISchemas::PrestageScopeResponseV2

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only marks ':id'. These values are unique in the collection
    ALT_IDENTIFIERS = %i[profileUuid].freeze

    # Values which are useful as identifiers, but are not necessarily unique
    # in the collection - e.g. more than one computer can have the same name
    # WARNING
    # When more than one item in the collection has the same value for
    # one of these fields, which one is used, returned, selected, is undefined
    # You Have Been Warned!
    NON_UNIQUE_IDENTIFIERS = %i[displayName].freeze

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::Prestage::ClassMethods"
      end

      # Return the Prestage that is marked as default,
      # i.e. the one that new SNs are assigned to when first added.
      # Nil if no default is defined
      # @return [Jamf::Prestage, nil]
      ######################
      def default
        # only one can be true at a time, so sort desc by that field,
        # and the true one will be at the top
        default_prestage_data = all.select { |d| d[:defaultPrestage] }.first

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
      ######################
      def serials_by_prestage_id(_refresh = nil, cnx: Jamf.cnx)
        scope_path ||= "#{self::LIST_PATH}/#{SCOPE_PATH}"
        api_reponse = ALL_SCOPES_OBJECT.new cnx.jp_get(scope_path)
        api_reponse.serialsByPrestageId.transform_keys!(&:to_s)
      end

      # Get the assigned serialnumbers for a given prestage, without
      # having to instantiate it
      #
      # @paream prestage_ident [Integer, String] the id or name of
      #   an existing prestage.
      #
      # @param refresh[Boolean] re-read the list from the API?
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Array<String>] the SN's assigned to the prestage
      ######################
      def serials_for_prestage(prestage_ident, _refresh = nil, cnx: Jamf.cnx)
        id = valid_id prestage_ident, cnx: cnx

        raise Jamf::NoSuchItemError, "No #{self} matching '#{prestage_ident}'" unless id

        serials_by_prestage_id(cnx: cnx).select { |_sn, psid| id == psid }.keys
      end

      # The id of the prestage to which the given serialNumber is assigned.
      # nil if not assigned or not in ADE.
      #
      # NOTE: If a serial number isn't assigned to any prestage, it may really be
      # unassigned or it may not exist in your ADE. To see if a SN exists in one
      # of your Device Enrollment instances, use Jamf::DeviceEnrollment.include?
      #
      # @param sn [String] the serial number to look for
      #      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Integer, nil] The id of prestage to which the SN is assigned
      #
      def assigned_prestage_id(sn, _refresh = nil, cnx: Jamf.cnx)
        serials_by_prestage_id(cnx: cnx)[sn]
      end

      # Is the given serialNumber assigned to any prestage, or to the
      # given prestage if a prestage is specified?
      #
      # NOTE: If a serial number isn't assigned to any prestage, it may really be
      # unassigned or it may not exist in your ADE. To see if a SN exists in one
      # of your Device Enrollment instances, use Jamf::DeviceEnrollment.include?
      #
      # @param sn [String] the serial number to look for
      #
      # @param refresh[Boolean] re-read the list from the API?
      #
      # @param prestage [Integer, String] If provided, the id or name of
      #   an existing prestage in which to look for the sn. if omitted, all
      #   prestages are searched.
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Boolean] Is the sn assigned, at all or to the given prestage?
      #
      def assigned?(sn, prestage: nil, cnx: Jamf.cnx, refresh: nil)
        assigned_id = assigned_prestage_id(sn, cnx: cnx)
        # it isn't assigned at all
        return false unless assigned_id

        # we are looking to see if its assigned at all, which it is
        return true unless prestage

        # we are looking to see if its in a specific prestage
        psid = valid_id prestage, cnx: cnx
        raise Jamf::NoSuchItemError, "No #{self} matching '#{prestage}'" unless psid

        psid == assigned_id
      end

      # We subtract the serials_by_prestage_id.keys from all known ADE SNs
      # rather than just looking for Jamf::DeviceEnrollment.devices  with status
      # REMOVED, because of the delay in updating the status for
      # Jamf::DeviceEnrollment::Devices, which must come from apple.
      #
      # @return [Array<String>] The serial numbers of devices that are in ADE but
      #    not assigned to any prestage
      #
      def unassigned_sns(cnx: Jamf.cnx)
        type = self == Jamf::MobileDevicePrestage ? :mobiledevices : :computers
        Jamf::DeviceEnrollment.device_sns(type: type, cnx: cnx) - serials_by_prestage_id(:refresh, cnx: cnx).keys
      end

      # @return [Array<String>] The serial numbers of known hardware not in ADE
      #   at all
      # TODO: move this to Jamf::DeviceEnrollment
      # def sns_not_in_device_enrollment
      #   # type = self == Jamf::MobileDevicePrestage ? :mobiledevices : :computers
      #   nil # TODO: this, once MobileDevice  & Computer classes are implemented
      # end

      # Assign one or more serialNumbers to a prestage
      # @return [Jamf::OAPISchemas::PrestageScopeResponseV2] the new scope for the prestage
      def assign(*sns_to_assign, to_prestage:, cnx: Jamf.cnx)
        prestage_id = valid_id to_prestage
        raise Jamf::NoSuchItemError, "No #{self} matching '#{to_prestage}'" unless prestage_id

        # all sns_to_assign must be in ADE
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
        spath = scope_path(prestage_id)
        scope = INSTANCE_SCOPE_OBJECT.new cnx.get(spath)

        # add the new sns to the existing ones
        new_scope_sns = scope.assignments.map(&:serialNumber)
        new_scope_sns += sns_to_assign
        new_scope_sns.uniq!

        update_scope(prestage_name, spath, new_scope_sns, scope.versionLock, cnx)
      end # self.assign

      # Unassign one or more serialNumber from a prestage
      # @return [Jamf::PrestageScope] the new scope for the prestage
      def unassign(*sns_to_unassign, from_prestage:, cnx: Jamf.cnx)
        prestage_id = valid_id from_prestage
        raise Jamf::NoSuchItemError, "No #{self} matching '#{from_prestage}'" unless prestage_id

        # upcase all sns
        sns_to_unassign.map!(&:to_s)
        sns_to_unassign.map!(&:upcase)

        # get the prestage name
        prestage_name = map_all(:id, to: :displayName)[prestage_id]
        spath = scope_path(prestage_id)
        scope = INSTANCE_SCOPE_OBJECT.new cnx.get(spath)

        new_scope_sns = scope.assignments.map(&:serialNumber)
        new_scope_sns -= sns_to_unassign

        update_scope(prestage_name, spath, new_scope_sns, scope.versionLock, cnx)
      end # self.unassign

      # Private Class Methods
      #####################################

      # the class level scope path for a given prestage id
      def scope_path(prestage_id)
        "#{self::LIST_PATH}/#{prestage_id}/#{SCOPE_PATH}"
      end
      private :scope_path

      # used by assign and unassign
      def update_scope(prestage_name, spath, new_scope_sns, vlock, cnx)
        assignment_data = {
          serialNumbers: new_scope_sns,
          versionLock: vlock
        }
        INSTANCE_SCOPE_OBJECT.new cnx.jp_put(spath, assignment_data)
      end
      private :update_scope

    end # module Class Methods

    # Instance Methods
    #####################################

    # The scope data for this prestage
    #
    # @param refresh[Boolean] reload fromthe API?
    #
    # @return [PrestageScope]
    #
    def scope(refresh: false)
      @scope = nil if refresh
      return @scope if @scope

      @scope = INSTANCE_SCOPE_OBJECT.new @cnx.get(scope_path)
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

    # The scope endpoint for this instance
    def scope_path
      @scope_path ||= "#{get_path}/#{SCOPE_PATH}"
    end

    def scope
      INSTANCE_SCOPE_OBJECT.new @cnx.jp_get(scope_path)
    end

  end # class

end # module
