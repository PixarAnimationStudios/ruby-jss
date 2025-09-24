# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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

    # The JPAPI resource for a single computer's FV info is
    # Jamf::Computer::JPAPI_INVENTORY_RSRC then the computer's ID then this
    FILEVAULT_RSRC_SUFFIX = 'filevault'

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

        data = cnx.jp_get "#{Jamf::Computer::JPAPI_INVENTORY_RSRC}/#{id}/#{FILEVAULT_RSRC_SUFFIX}"
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
        list_path = "#{Jamf::Computer::JPAPI_INVENTORY_RSRC}/#{FILEVAULT_RSRC_SUFFIX}"
        if paged
          Jamf::Pager.new(
            page_size: page_size,
            list_path: list_path,
            instantiate: Jamf::OAPISchemas::ComputerInventoryFileVault,
            cnx: cnx
          )
        else
          Jamf::Pager.all_pages(
            list_path: list_path,
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
    # @see FileVault::ClassMethods.filevault_info
    #
    def filevault_info
      self.class.filevault_info @id, cnx: @cnx
    end

  end # module MacOSRedeployMgmtFramework

end # module Jamf
