### Copyright 2020 Pixar

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

  # A mix-in module to handle VPP-related data in API objects that can be
  # assigned via VPP.
  #
  # To use this module, merely `include VPPable` when defining your
  # subclass of JSS::APIObject
  #
  # classes doing so MUST call {#add_vpp_xml(xmldoc)} in their {#rest_xml} method
  #
  module VPPable

    # Mixed-in Constants
    #####################################
    VPPABLE = true

    # Mixed-in Attributes
    #####################################

    # @return [Hash]
    attr_reader :vpp_codes

    # @return [Integer]
    attr_reader :vpp_admin_account_id

    # @return [Boolean]
    attr_reader :assign_vpp_device_based_licenses
    alias vpp_device_based? assign_vpp_device_based_licenses

    # @return [Integer]
    attr_reader :total_vpp_licenses
    alias vpp_total_licenses total_vpp_licenses
    alias vpp_license_count total_vpp_licenses

    # @return [Integer]
    attr_reader :remaining_vpp_licenses
    alias vpp_licenses_remaining remaining_vpp_licenses

    # @return [Integer]
    attr_reader :used_vpp_licenses
    alias vpp_licenses_used used_vpp_licenses


    # Set whether or not the VPP licenses should be assigned
    # by device rather than by user
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def assign_vpp_device_based_licenses=(new_val)
      return nil if new_val == @assign_vpp_device_based_licenses
      raise JSS::InvalidDataError, 'New value must be true or false' unless new_val.jss_boolean?
      @assign_vpp_device_based_licenses = new_val
      @need_to_update = true
    end
    alias vpp_device_based= assign_vpp_device_based_licenses=

    # Mixed-in Private Instance Methods
    #####################################
    private

    # Parse the vpp data from the incoming API data
    #
    # @return [void]
    #
    def parse_vpp
      @vpp_codes = @init_data[:vpp_codes]
      @vpp_admin_account_id = @init_data[:vpp][:vpp_admin_account_id]
      @assign_vpp_device_based_licenses = @init_data[:vpp][:assign_vpp_device_based_licenses]
      @total_vpp_licenses = @init_data[:vpp][:total_vpp_licenses]
      @remaining_vpp_licenses = @init_data[:vpp][:remaining_vpp_licenses]
      @used_vpp_licenses = @init_data[:vpp][:used_vpp_licenses]
    end

    # Insert an appropriate vpp element into the XML for sending changes
    # to the JSS
    #
    # @param xdoc[REXML::Document] The XML document to work with
    #
    # @return [void]
    #
    def add_vpp_xml(xdoc)
      doc_root = xdoc.root
      vpp = doc_root.add_element 'vpp'
      vpp.add_element('assign_vpp_device_based_licenses').text = @assign_vpp_device_based_licenses
    end

  end # VPPable

end # JSS
