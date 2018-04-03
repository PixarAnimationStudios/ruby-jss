### Copyright 2018 Pixar

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
module JSS

  #
  class PatchTitle < JSS::APIObject

    # A Patch Software Title Version in the JSS.
    #
    # This class corresponds to a "version" returned from the
    # 'patchsoftwaretitles' resource of the API
    #
    # Not only does each one have a 'version', e.g. '8.3.2b12', but
    # also knows its parent SoftwareTitle, the id of the matching
    # JSS::Package, if any, and can report the names and ids of the computers
    # that have it installed.
    #
    # To set or change the JSS::Package associated with a SoftwareTitle::Version,
    # first fetch
    # the corresponding SoftwareTitle, specifying the version you want to change,
    # the use the #package= method of the encapsulated PatchVersion object
    # and save your changes back to the JSS.
    #
    class Version

      # Attributes
      #####################################

      # @return [String] the software version number for this PatchVersion.
      #   name_id is a unique identfier created from the patch name
      attr_reader :version

      # @return [Integer, nil] How many computers have this version of this title
      #   installed?
      attr_reader :size
      alias total_computers size

      # @return [Array<Hash>] The :id, :name, :mac_address, :alt_mac_address &
      #  :serial_number of each computer with this PatchVersion installed.
      attr_reader :computers

      # @return [Integer] the id of the JSS::Package that installs this PatchVersion,
      #  if defined.
      attr_reader :package_id

      # @return [String] the name of the JSS::Package that installs this PatchVersion,
      #  if defined
      attr_reader :package_name

      # This should only be instantiated by the JSS::PatchTitle that contains
      # this version.
      #
      def initialize(title, data)
        @title = title
        @version = data[:software_version]
        @size = data[:size]
        @computers = data[:computers]

        return unless data[:package]

        pid = data[:package][:id].to_i

        @package_id = pid < 1 ? :none : pid
        @package_name = data[:package][:name]
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

      # @return [Array<Integer>] The serialnumbers of #computers
      #
      def computer_serial_numbers
        computers.map { |c| c[:serial_number] }
      end

      # Assign a new JSS::Package to this PatchVersion.
      # The Package must exist in the JSS. Be
      # sure to call #update on the PatchTitle containing
      # this Version.
      #
      # @param new_pkg[String,Integer,Symbol] A name or id of a JSS::Package.
      #   use :none to unset a package for this version.
      #
      def package=(new_pkg)
        raise JSS::UnsupportedError, "Packages can't be assigned to the Unkown version." if version == JSS::PatchTitle::UNKNOWN_VERSION_ID

        pkgid =
          if new_pkg == :none
            :none
          else
            JSS::Package.valid_id new_pkg, :refresh, api: @title.api
          end
        raise JSS::NoSuchItemError, "No JSS::Package matches '#{new_pkg}'" unless pkgid

        return if @package_id == pkgid

        @package_id = pkgid
        @package_name = pkgid == :none ? nil : JSS::Package.map_all_ids_to(:name)[pkgid]

        @title.changed_pkg_for version
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

end # module JSS
