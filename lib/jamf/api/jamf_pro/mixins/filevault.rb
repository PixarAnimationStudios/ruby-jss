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

  # This module should be mixed in to Jamf::Computer
  #
  # It provides access to the /v1/computers-inventory/filevault and
  # /v1/computers-inventory/{id}/filevault JPAPI resources
  #
  module FileVault

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including #{self}"
      includer.extend(ClassMethods)
    end

    # The base resource for computers in the JPAPI
    #
    # TODO: When we migrate Jamf::Computer from the classic to the JPAPI,
    # this constant will be defined there, and this module should use
    # that one.
    COMPUTERS_INVENTORY_RSRC = 'v1/computers-inventory'

    # The JPAPI resource for a single computer's FV info is
    # COMPUTERS_INVENTORY_RSRC then the computers ID then this
    FILEVAULT_RSRC_SUFFIX = 'filevault'

    # The JPAPI resource for paginated FV info for all computers
    ALL_COMPUTERS_FILEVAULT_RSRC = "#{COMPUTERS_INVENTORY_RSRC}/#{FILEVAULT_RSRC_SUFFIX}"

    # Class Methods
    #####################################
    module ClassMethods

      # when this module is included, also extend our Class Methods
      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending #{self}"
      end

      # Get the filevault info for one or all computers, or Jamf::Pager for getting all of them
      # paged in groups.
      #
      # WARNING: This data will include the plaintext FileVault personal recovery keys. The
      #   'View Disk Encryption Recovery Key' privilege is required.
      #
      # @param computer [Symbol, String, Integer, Array<String, Integer>] Identifier for the desired
      #   Computer, or :all to get data for all computers, as an Array or via a Jamf::Pager
      #
      # @param paged [Boolean] when computer is :all, should we return a Jamf::Pager to get paged results?
      #
      # @param page_size [Integer] when computer is :all and paged: is true, how many results to return in each page.
      #
      # @param cnx [Jamf::Connection] The API connection to use. Defaults to Jamf.cnx
      #
      # @return [Jamf::OAPISchemas::ComputerInventoryFileVault, Array<Jamf::OAPISchemas::ComputerInventoryFileVault>, Jamf::Pager]
      #   The filevault info for a computer, all computers, or a Jamf::Pager to get all computers in pages.
      ########################
      def filevault_info(computer, paged: false, page_size: Jamf::Pager::DEFAULT_PAGE_SIZE, cnx: Jamf.cnx)
        return all_computers(paged: paged, page_size: page_size, cnx: cnx) if computer == :all

        id = Jamf::Computer.valid_id computer
        raise Jamf::NoSuchItemError, "No computer matches identifier '#{computer}'" unless id

        data = cnx.jp_get "#{COMPUTERS_INVENTORY_RSRC}/#{id}/#{FILEVAULT_RSRC_SUFFIX}"
        Jamf::OAPISchemas::ComputerInventoryFileVault.new data

      # if we get a 404 NOT FOUND error, this given computer has no FV data, so just return nil
      rescue Jamf::Connection::JamfProAPIError => e
        raise unless e.http_status == 404

        nil
      end # def

      # return info for all computers, possibly as a Pager
      # @see .filevault_info
      ########################
      def all_computers(paged: false, page_size: nil, cnx: Jamf.cnx)
        if paged
          Jamf::Pager.new(
            page_size: page_size,
            list_path: ALL_COMPUTERS_FILEVAULT_RSRC,
            instantiate: Jamf::OAPISchemas::ComputerInventoryFileVault,
            cnx: cnx
          )
        else
          Jamf::Pager.all_pages(
            list_path: ALL_COMPUTERS_FILEVAULT_RSRC,
            instantiate: Jamf::OAPISchemas::ComputerInventoryFileVault,
            cnx: cnx
          )
        end
      end
      private :all_computers

    end # module ClassMethods

    # Instance Methods
    ######################################

    # Get the filevault info for this Computer instance
    #
    # @see FileVault.filevault_info
    #
    def filevault_info
      self.class.filevault_info @id, cnx: @cnx
    end

  end # module MacOSRedeployMgmtFramework

end # module Jamf
