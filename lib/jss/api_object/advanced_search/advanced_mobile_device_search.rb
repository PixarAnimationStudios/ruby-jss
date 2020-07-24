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

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # An AdvancedComputerSearch in the JSS
  #
  # @see JSS::AdvancedSearch
  #
  # @see JSS::APIObject
  #
  class AdvancedMobileDeviceSearch < JSS::AdvancedSearch

    # Mix-Ins
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'advancedmobiledevicesearches'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :advanced_mobile_device_searches

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_mobile_device_search

    # what kind of thing is returned by this search?
    RESULT_CLASS = JSS::MobileDevice

    # what data fields come back along with the display fields
    # for each mobiledevices?
    RESULT_ID_FIELDS = [:id, :name, :udid].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 71

    # Attributes
    #####################################

    # Constructor
    #####################################

    # Public Instance Methods
    #####################################

    # Private Instance Methods
    #####################################

  end # class

end # module
