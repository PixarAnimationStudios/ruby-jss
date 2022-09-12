### Copyright 2022 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
module Jamf

  #
  class PatchTitle < Jamf::APIObject

    # A Patch Software Title Version in the JSS.
    #
    # This class corresponds to a "version" returned from the
    # 'patchsoftwaretitles' resource of the API
    #
    # Not only does each one have a 'version', e.g. '8.3.2b12', but
    # also knows its parent PatchTitle, the matching Jamf::Package,
    # if any, and can report the names and ids of the computers
    # that have it installed.
    #
    # To set or change the Jamf::Package associated with a PatchTitle::Version,
    # first fetch the corresponding SoftwareTitle, use the #package= method
    # of the Version object in its #versions attribute, then save the PatchTitle
    # back to the JSS.
    #
    class Version

      # Attributes
      #####################################

      # @return [String] the software version number for this PatchVersion.
      #   name_id is a unique identfier created from the patch name
      attr_reader :version

      # @return [Integer] the id of the Jamf::Package that installs this PatchVersion,
      #  if defined.
      attr_reader :package_id

      # @return [String] the name of the Jamf::Package that installs this PatchVersion,
      #  if defined
      attr_reader :package_name

      # This should only be instantiated by the Jamf::PatchTitle that contains
      # this version.
      #
      def initialize(title, data)
        @title = title
        @version = data[:software_version].to_s

        return if data[:package].to_s.empty?

        pid = data[:package][:id].to_i

        @package_id = pid < 1 ? :none : pid
        @package_name = data[:package][:name]
      end

      # @return [Boolean] Has a package been assigned to this version?
      #
      def package_assigned?
        package_id != :none
      end

      # get the patch report for this version
      # See PatchTitle.patch_report
      def patch_report
        @title.patch_report version
      end
      alias version_report patch_report
      alias report patch_report

      # @return [Integer] How many #computers have this version?
      #
      def total_computers
        patch_report[:total_computers]
      end

      # @return [Array<Hash>] A hash of identifiers for each computer
      #   with this version installed.
      def computers
        patch_report[:versions][version]
      end

      # @return [Array<Integer>] The ids of #computers
      #
      def computer_ids
        computers.map { |c| c[:id] }
      end

      # @return [Array<Integer>] The names of #computers
      #
      def computer_names
        computers.map { |c| c[:name] }
      end

      # @return [Array<Integer>] The serial_numbers of #computers
      #
      def computer_serial_numbers
        computers.map { |c| c[:serial_number] }
      end

      # @return [Array<Integer>] The udids of #computers
      #
      def computer_udids
        computers.map { |c| c[:udid] }
      end

      # Assign a new Jamf::Package to this PatchTitle::Version.
      # The Package must exist in the JSS. Be
      # sure to call #update on the PatchTitle containing
      # this Version.
      #
      # @param new_pkg[String,Integer,Symbol] A name or id of a Jamf::Package.
      #   use :none to unset a package for this version.
      #
      def package=(new_pkg)
        raise Jamf::UnsupportedError, "Packages can't be assigned to the Unkown version." if version == Jamf::PatchTitle::UNKNOWN_VERSION_ID

        pkgid =
          if new_pkg == :none
            :none
          else
            Jamf::Package.valid_id new_pkg, :refresh, cnx: @title.cnx
          end
        raise Jamf::NoSuchItemError, "No Jamf::Package matches '#{new_pkg}'" unless pkgid

        return if @package_id == pkgid

        @package_id = pkgid
        @package_name = pkgid == :none ? nil : Jamf::Package.map_all_ids_to(:name)[pkgid]
        @title.changed_pkg_for_version version
      end

      # Remove the various cached data
      # from the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      #
      def pretty_print_instance_variables
        vars = super
        vars.delete :@title
        vars
      end

    end # class Version

  end # class SoftwareTitle

end # module Jamf
