### Copyright 2019 Pixar

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

  # A Category in the JSS.
  #
  #
  # @see JSS::APIObject
  #
  class Category < JSS::APIObject

    # Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable

    # Class Methods
    #####################################

    def self.category_id_from_name(name, api: JSS.api)
      return nil if name.nil?
      return nil if name.casecmp(JSS::Category::NO_CATEGORY_NAME).zero?
      JSS::Category.map_all_ids_to(:name, api: api).invert[name]
    end # self cat id from name

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'categories'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :categories

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :category

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:priority].freeze

    # When no category has been assigned, this is the 'name' and id used
    NO_CATEGORY_NAME = JSS::Categorizable::NO_CATEGORY_NAME
    NO_CATEGORY_ID = JSS::Categorizable::NO_CATEGORY_ID

    # The Default category
    DEFAULT_CATEGORY = NO_CATEGORY_NAME

    # The range of possible priorities
    POSSIBLE_PRIORITIES = 1..20

    # The Default Priority
    DEFAULT_PRIORITY = 5

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 72

    # Attributes
    #####################################

    # @return [Integer] the SelfService priority for this category
    attr_reader :priority

    # Constructor
    #####################################

    # See JSS::APIObject#initialize
    #
    def initialize(args = {})
      super
      @priority = @init_data[:priority] || DEFAULT_PRIORITY
    end

    # Public Instance Methods
    #####################################

    # Change the Priority
    #
    # @param new_val[Integer] the new priority, must be in the range POSSIBLE_PRIORITIES
    #
    # @return [void]
    #
    def priority=(new_val = @priority)
      return nil if new_val == @priority
      raise JSS::InvalidDataError, "priority must be an integer between #{POSSIBLE_PRIORITIES.first} and #{POSSIBLE_PRIORITIES.last} (inclusive)" unless POSSIBLE_PRIORITIES.include? new_val
      @priority = new_val
      @need_to_update = true
    end

    # Private Instance Methods
    #####################################
    private

    # Return a String with the XML Resource
    # for submitting creation or changes to the JSS via
    # the API via the Creatable or Updatable modules
    #
    # Most classes will redefine this method.
    #
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      tmpl = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      tmpl.add_element('name').text = @name
      tmpl.add_element('priority').text = @priority
      doc.to_s
    end

  end # class category

end # module
