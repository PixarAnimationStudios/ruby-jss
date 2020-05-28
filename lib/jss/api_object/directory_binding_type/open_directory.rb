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

        # Class for the specific OpenDirectory DirectoryBinding type stored within the JSS
        # 
        # @author Tyler Morgan
        #
        # Attributes
        # @!attribute [rw] require_confirmation

        class OpenDirectory < DirectoryBindingType
            # Mix-Ins
            #####################################

            # Class Methods
            #####################################

            # Class Constants
            #####################################

            # Attributes
            #####################################
            attr_reader :encrypt_using_ssl
            attr_reader :perform_secure_bind
            attr_reader :use_for_authentication
            attr_reader :use_for_contacts

            # Constructor
            #####################################
            def initialize(init_data)
                @encrypt_using_ssl = init_data[:encrypt_using_ssl]
                @perform_secure_bind = init_data[:perform_secure_bind]
                @use_for_authentication = init_data[:use_for_authentication]
                @use_for_contacts = init_data[:use_for_contacts]
            end

                

            # Public Instance Methods
            #####################################

            # Encrypt the connection using SSL
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def encrypt_using_ssl=(newvalue)

                raise JSS::InvalidDataError, "encrypt_using_ssl must be true or false." unless newvalue.is_a? Bool
                
                @encrypt_using_ssl = newvalue

                self.container&.should_update
            end


            # Attempt to perform a secure bind to the domain server
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def perform_secure_bind=(newvalue)

                raise JSS::InvalidDataError, "perform_secure_bind must be true or false." unless newvalue.is_a? Bool

                @perform_secure_bind = newvalue

                self.container&.should_update
            end


            # Use this binding for authentication
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def use_for_authentication=(newvalue)

                raise JSS::InvalidDataError, "use_for_authentication must be true or false." unless newvalue.is_a? Bool

                @use_for_authentication = newvalue

                self.container&.should_update
            end


            # Use this binding for contact population
            # 
            # @author Tyler Morgan
            #
            # @param newvalue [Bool]
            #
            # @raise [JSS::InvalidDataError] If the new value doesn't match a Bool value
            #
            # @return [void]
            def use_for_contacts=(newvalue)

                raise JSS::InvalidDataError, "use_for_contacts must be true or false." unless newvalue.is_a? Bool

                @use_for_contacts = newvalue

                self.container&.should_update
            end


            # Return a REXML Element containing the current state of the DirectoryBindingType
            # object for adding into the XML of the container.
            # 
            # @author Tyler Morgan
            #
            # @return [REXML::Element]
            def type_setting_xml
                type_setting = REXML::Element.new "admitmac"
                type_setting.add_element("encrypt_using_ssl").text = @encrypt_using_ssl
                type_setting.add_element("perform_secure_bind").text = @perform_secure_bind
                type_setting.add_element("use_for_authentication").text = @use_for_authentication
                type_setting.add_element("use_for_contacts").text = @use_for_contacts

                return type_setting
            end
        end
    end
end