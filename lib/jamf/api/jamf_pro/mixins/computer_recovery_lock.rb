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

# frozen_string_literal: true

module Jamf

  # This module should be mixed in to Jamf::Computer and Jamf::ComputerGroup
  #
  # It provides access to the macos-managed-software-updates JPAPI resource for
  # managed OS update commands to managed macs running Big Sur or higher.
  #
  module ComputerRecoveryLock

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including #{self}"
      includer.extend(ClassMethods)
    end

    # The JPAPI resource for a single computer's RecoveryLock password is
    # Jamf::Computer::JPAPI_INVENTORY_RSRC then the computer's ID then this
    RECOVERY_LOCK_PW_RSRC_SUFFIX = 'view-recovery-lock-password'

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending #{self}"
      end

      # Retrieve the recovery lock password for a given computer, if one has been set.
      #
      # @param computer [Symbol, String, Integer, Array<String, Integer>] Identifier for the desired
      #   Computer
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [String, nil] The recovery lock password, or nil if none has been set.
      #######################
      def recovery_lock_password(computer, cnx: Jamf.cnx)
        id = Jamf::Computer.valid_id computer
        raise Jamf::NoSuchItemError, "No computer matches identifier '#{computer}'" unless id

        cnx.jp_get("#{Jamf::Computer::JPAPI_INVENTORY_RSRC}/#{id}/#{RECOVERY_LOCK_PW_RSRC_SUFFIX}").dig :recoveryLockPassword

      # if we get a 404 NOT FOUND error, this given computer has no passwd set, so just return nil
      rescue Jamf::Connection::JamfProAPIError => e
        raise unless e.http_status == 404

        nil
      end # def

    end # module ClassMethods

    # Instance Methods
    ######################################

    # Get the recovery lock password  for this Computer instance
    #
    # @see ComputerRecoveryLock::ClassMethods.recovery_lock_password
    #
    def recovery_lock_password
      self.class.recovery_lock_password @id, cnx: @cnx
    end

  end # module MacOSRedeployMgmtFramework

end # module Jamf
