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

# Module Variables
#####################################

# Module Methods
#####################################

# Classes
#####################################

# A Dock Item in the JSS.
# These are rather simple. They have an ID, name, path, type, and contents which is read-only
#
# @see JSS::APIObject

module DirectoryBindingType

        # Module Variables
        #####################################

        # Module Methods
        #####################################
        def should_update
            @need_to_update = true
        end

        def set_type_settings(settings)
            @type_settings = settings
            @type_settings.container = self
        end

        # Classes
        #####################################

        # A Dock Item in the JSS.
        # These are rather simple. They have an ID, name, path, type, and contents which is read-only
        #
        # @see JSS::APIObject

        class DirectoryBindingType
            # Mix-Ins
            #####################################

            # Class Methods
            #####################################

            # Class Constants
            #####################################
            NETWORK_PROTOCOL = {
                afp: "AFP",
                smb: "SMB"
            }.freeze

            HOME_FOLDER_TYPE = {
                network: "Network",
                local: "Local",
                either: "Either",
                mobile: "Mobile"
            }.freeze

            # Attributes
            #####################################
            attr_accessor :container

            # Constructor
            # @see JSS::APIObject.initialize
            #####################################
        end
    end
end

require "jss/api_object/directory_binding_type/active_directory"
require "jss/api_object/directory_binding_type/open_directory"
require "jss/api_object/directory_binding_type/admitmac"
require "jss/api_object/directory_binding_type/centrify"
require "jss/api_object/directory_binding_type/powerbroker_identity_services"