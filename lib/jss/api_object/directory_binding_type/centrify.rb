### Copyright 2019 Rixar

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

module JSS

    # Module for containing the different types of DirectoryBindings stored within the JSS
    
    module DirectoryBindingType

        # Module Variables
        #####################################

        # Module Methods
        #####################################

        # Classes
        #####################################

        # Class for the specific ADmitMac DirectoryBinding type stored within the JSS
        # 
        # @author Tyler Morgan
        #
        # Attributes
        # @!attribute [rw] workstation_mode
        # @!attribute [rw] overwrite_existing
        # @!attribute [rw] update_PAM
        # @!attribute [rw] zone
        # @!attribute [rw] preferred_domain_server
        class Centrify < DirectoryBindingType
            # Mix-Ins
            #####################################

            # Class Methods
            #####################################

            # Class Constants
            #####################################

            # Attributes
            #####################################
            attr_reader :workstation_mode
            attr_reader :overwrite_existing
            attr_reader :update_PAM
            attr_reader :zone
            attr_reader :preferred_domain_server

            # Constructor
            #####################################

            # An initializer for the Centrify object.
            # 
            # @author Tyler Morgan
            # @see JSS::DirectoryBinding
            # @see JSS::DirectoryBindingType
            #
            # @param [Hash] initialize data
            def initialize(init_data)

                # Return without processing anything since there is
                # nothing to process.
                return if init_data.nil?

                # Process the provided information
                @workstation_mode = init_data[:workstation_mode]
                @overwrite_existing = init_data[:overwrite_existing]
                @update_PAM = init_data[:update_PAM]
                @zone = init_data[:zone]
                @preferred_domain_server = init_data[:preferred_domain_server]
            end


            # Public Instance Methods
            #####################################


            # Sets the Centrify Mode to Workstation mode
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def workstation_mode=(newvalue)

                raise JSS::InvalidDataError, "workstation_mode must be true or false." unless newvalue.is_a? Bool

                @workstation_mode = newvalue

                self.container&.should_update
            end


            # Want to overwrite existing joined computer in the directory
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def overwrite_existing=(newvalue)

                raise JSS::InvalidDataError, "overwrite_existing must be true or false." unless newvalue.is_a? Bool

                @overwrite_existing = newvalue

                self.container&.should_update
            end


            # Update the PAM module and overwrite DirectoryService configuration
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def update_PAM=(newvalue)

                raise JSS::InvalidDataError, "update_PAM must be true or false." unless newvalue.is_a? Bool

                @update_PAM = newvalue

                self.container&.should_update
            end


            # The zone the computer is to be joined to
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] the new zone the computer is to be joined to
            #
            # @raise [JSS::InvalidDataError] If the new value is not a string.
            #
            # @return [void]
            def zone=(newvalue)

                raise JSS::InvalidDataError, "zone must be a string." unless newvalue.is_a? String

                @zone = newvalue

                self.container&.should_update
            end


            # The specific domain server that should be prioritized
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [String] The domain server that would be prioritized.
            #
            # @raise [JSS::InvalidDataError] If the new value is not a string.
            #
            # @return [void]
            def preferred_domain_server=(newvalue)

                raise JSS::InvalidDataError, "preferred_domain_server must be a string." unless newvalue.is_a? String

                @preferred_domain_server = newvalue

                self.container&.should_update
            end


            # Return a REXML Element containing the current state of the DirectoryBindingType
            # object for adding into the XML of the container.
            # 
            # @author Tyler Morgan
            #
            # @return [REXML::Element]
            def type_setting_xml
                type_setting = REXML::Element.new "centrify"
                type_setting.add_element("workstation_mode").text = @workstation_mode
                type_setting.add_element("overwrite_existing").text = @overwrite_existing
                type_setting.add_element("update_PAM").text = @update_PAM
                type_setting.add_element("zone").text = @zone
                type_setting.add_element("preferred_domain_server").text = @preferred_domain_server

                return type_setting
            end

        end
    end
end