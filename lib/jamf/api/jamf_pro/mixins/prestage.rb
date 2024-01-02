# Copyright 2023 Pixar

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
      # they are assigned to.
      #
      # @param refresh[Boolean] re-read the list from the API? DEPRECATED:
      #   the data is always read from the API. If making many calls at once,
      #   consisider capturing serials_by_prestage_id in your own variable and using
      #   it as this method does
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Hash {String => Integer}] The Serials and prestage IDs
      ######################
      def serials_by_prestage_id(refresh = false, cnx: Jamf.cnx) # rubocop:disable Lint/UnusedMethodArgument
        api_reponse = ALL_SCOPES_OBJECT.new cnx.jp_get(scope_path)
        api_reponse.serialsByPrestageId.transform_keys(&:to_s)
      end
      alias all_scopes serials_by_prestage_id

      # Get the assigned serialnumbers for a given prestage, without
      # having to instantiate it
      #
      # @paream prestage_ident [Integer, String] the id or name of
      #   an existing prestage.
      #
      # @param refresh[Boolean] re-read the list from the API? DEPRECATED:
      #   the data is always read from the API. If making many calls at once,
      #   consisider capturing serials_by_prestage_id in your own variable and using
      #   it as this method does
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Array<String>] the SN's assigned to the prestage
      ######################
      def serials_for_prestage(prestage_ident, refresh = false, cnx: Jamf.cnx) # rubocop:disable Lint/UnusedMethodArgument
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
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [String, nil] The id of prestage to which the SN is assigned
      #
      def assigned_prestage_id(sn, cnx: Jamf.cnx)
        serials_by_prestage_id(cnx: cnx)[sn]
      end

      # Is the given serialNumber assigned to any prestage, or to the
      # given prestage if a prestage is specified?
      #
      # This uses .serials_by_prestage_id, the class-level scope path which
      # gets a hash of all assigned SNS => the id of the prestage they are
      # assigned to. The instance#assigned? method uses a different path
      # which returnds more data in an OAPI object.
      #
      # NOTE: If a serial number isn't assigned to any prestage, it may really be
      # unassigned or it may not exist in your ADE. To see if a SN exists in one
      # of your Device Enrollment instances, use Jamf::DeviceEnrollment.include?
      #
      # @param sn [String] the serial number to look for
      #
      # @param prestage [Integer, String] If provided, the id or name of
      #   an existing prestage in which to look for the sn. if omitted, all
      #   prestages are searched.
      #
      # @param cnx[Jamf::Connection] the API connection to use
      #
      # @return [Boolean] Is the sn assigned, at all or to the given prestage?
      #
      def assigned?(sn, prestage: nil, cnx: Jamf.cnx)
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

      # Assign one or more serialNumbers to a prestage
      # @return [Jamf::OAPISchemas::PrestageScopeResponseV2] the new scope for the prestage
      def assign(*sns_to_assign, to_prestage:, cnx: Jamf.cnx)
        prestage_id = valid_id to_prestage
        raise Jamf::NoSuchItemError, "No #{self} matching '#{to_prestage}'" unless prestage_id

        # upcase all sns
        sns_to_assign.map!(&:to_s)
        sns_to_assign.map!(&:upcase)

        # get the current scope of the prestage
        spath = scope_path(prestage_id)
        scope = INSTANCE_SCOPE_OBJECT.new cnx.get(spath)

        # add the new sns to the existing ones
        new_scope_sns = scope.assignments.map(&:serialNumber)
        new_scope_sns += sns_to_assign
        new_scope_sns.uniq!

        update_scope(spath, new_scope_sns, scope.versionLock, cnx)
      end # self.assign

      # Unassign one or more serialNumber from a prestage
      # @return [Jamf::PrestageScope] the new scope for the prestage
      def unassign(*sns_to_unassign, from_prestage:, cnx: Jamf.cnx)
        prestage_id = valid_id from_prestage
        raise Jamf::NoSuchItemError, "No #{self} matching '#{from_prestage}'" unless prestage_id

        # upcase all sns
        sns_to_unassign.map!(&:to_s)
        sns_to_unassign.map!(&:upcase)

        # get the current scope of the prestage
        spath = scope_path(prestage_id)
        scope = INSTANCE_SCOPE_OBJECT.new cnx.get(spath)

        new_scope_sns = scope.assignments.map(&:serialNumber)
        new_scope_sns -= sns_to_unassign

        update_scope(spath, new_scope_sns, scope.versionLock, cnx)
      end # self.unassign

      # the endpoint path for the scope of a given prestage id
      #
      def scope_path(prestage_id = nil)
        pfx = defined?(self::SCOPE_PATH_PREFIX) ? self::SCOPE_PATH_PREFIX : get_path

        prestage_id ? "#{pfx}/#{prestage_id}/#{SCOPE_PATH}" : "#{pfx}/#{SCOPE_PATH}"
      end

      # Private Class Methods
      #####################################

      # used by assign and unassign
      def update_scope(spath, new_scope_sns, vlock, cnx)
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

    # getter alias for the 'standard' name attribute - Thanks for the consistency, Jamf
    def name
      displayName
    end

    # setter alias for the 'standard' name attribute - Thanks for the consistency, Jamf
    def name=(newname)
      displayName = newname
    end

    # The scope data for this prestage -
    #
    # @param refresh[Boolean] reload from the API? DEPRECATED:
    #   the data is always read from the API. If making many calls at once,
    #   consisider capturing the data in your own variable
    #
    # @return [PrestageScope]
    #
    def scope(refresh = false) # rubocop:disable Lint/UnusedMethodArgument
      scope = INSTANCE_SCOPE_OBJECT.new @cnx.get(scope_path)

      # TODO: is this the best way to deal with fetching a scope that
      # is more updated than the rest of the object?
      unless scope.versionLock == @versionLock
        raise Jamf::VersionLockError, "The #{self.class} '#{displayName}' has been modified since it was fetched. Please refetch and try again"
      end

      scope
    end

    # @return [Array<String>] the serialnumbers assigned to this prestage
    def assigned_sns
      scope.assignments.map(&:serialNumber)
    end

    # Is this SN assigned to this prestage?
    #
    # This method uses the instance's scope object, from a different API
    # path than the class-level .assigned? method.
    #
    # @param sn[String] the sn to look for
    #
    # @return [Boolean]
    #
    def assigned?(sn)
      assigned_sns.include? sn
    end
    alias include? assigned?
    alias scoped? assigned?

    # Assign
    def assign(*sns_to_assign)
      scope = self.class.assign(*sns_to_assign, to_prestage: @id, cnx: @cnx)
      @versionLock = scope.versionLock
    end
    alias add assign

    def unassign(*sns_to_unassign)
      scope = self.class.unassign(*sns_to_unassign, from_prestage: @id, cnx: @cnx)
      @versionLock = scope.versionLock
    end
    alias remove unassign

    # The scope endpoint for this instance
    def scope_path
      @scope_path ||= self.class.scope_path(id)
    end

  end # class

end # module
