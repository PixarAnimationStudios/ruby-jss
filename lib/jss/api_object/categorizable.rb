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

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A mix-in module that centralizes the code for handling objects which can be
  # assigned a 'category' in the JSS.
  #
  # Objects in the JSS present category data in two different ways:
  #
  # 1) An 'old' style, where the top-level Hash of the API data contains a
  #    :category which contains a String, being the category name.
  #
  # 2) A 'new' style, where the top-level :general Hash contains a :category key
  #    which is a Hash with a :name and :id key.
  #
  # This module can detect and handle either type.
  #
  # Classes mixing in this module MUST:
  #
  # - call {#add_category_to_xml(xmldoc)} from their #rest_xml method if they are
  #   {Updatable} or {Creatable}
  #
  module Categorizable

    # Module Constants
    #####################################

    CATEGORIZABLE = true

    # When no category has been assigned, this is the 'name' and id used
    NO_CATEGORY_NAME = 'No category assigned'.freeze
    NO_CATEGORY_ID = -1

    # Setting the category to any of these values will unset the category
    NON_CATEGORIES = [
      nil,
      '',
      0,
      NO_CATEGORY_NAME,
      NO_CATEGORY_ID
    ].freeze

    # These classes use old-style categories in their data.
    OLD_STYLE_CATEGORY_CLASSES = [
      JSS::Script,
      JSS::Package
    ].freeze

    # Mixed-in Public Instance Methods
    #####################################

    # The name of the category for this object.
    # For backward compatibility, this is aliased to just
    # 'category'
    #
    # @return [String] The name of the category for this object.
    #
    def category_name
      @category_name
    end # cat name
    alias category category_name

    # The id of the category for this object.
    #
    # @return [Integer] The id of the category for this object.
    #
    def category_id
      @category_id
    end # cat id

    # The JSS::Category instance for this object's category
    #
    # @return [JSS::Category] The JSS::Category instance for this object's category
    #
    def category_object
      return nil unless category_assigned?
      JSS::Category.new id: @category_id
    end # cat obj

    # Does this object have a category assigned?
    #
    # @return [Boolean] Does this object have a category assigned?
    #
    def category_assigned?
      !@category_name.nil?
    end # cat assigned?
    alias categorized? category_assigned?

    # Change the category of this object.
    # Any of the NON_CATEGORIES values will
    # unset the category
    #
    # @param new_cat[Integer, String] The new category
    #
    # @return [void]
    #
    def category=(new_cat)
      return nil unless updatable? || creatable?

      # unset the category? Use nil or an empty string
      if NON_CATEGORIES.include? new_cat
        unset_category
        return
      end

      new_name, new_id = evaluate_new_category(new_cat)

      # no change, go home.
      return nil if new_name == @category_name

      raise JSS::NoSuchItemError, "Category '#{new_cat}' is not known to the JSS" unless JSS::Category.all_names(:ref, api: @api).include? new_name

      @category_name = new_name
      @category_id = new_id
      @need_to_update = true
    end # category =

    # Given a category name or id, return the name and id
    # TODO: use APIObject.exist? and/or APIObject.valid_id
    # @param new_cat[String, Integer] The name or id of a possible category
    #
    # @return [Array<String, Integer>] The matching name and id, which may be nil.
    #
    def evaluate_new_category(new_cat)
      # if we were given anything but a string, assume it was an id.
      if new_cat.is_a? String
        new_name = new_cat
        new_id = JSS::Category.category_id_from_name new_cat, api: @api
      else
        new_id = new_cat
        new_name = JSS::Category.map_all_ids_to(:name, api: @api)[new_id]
      end
      [new_name, new_id]
    end

    # Set the category to nothing
    #
    # @return [void]
    #
    def unset_category
      # no change, go home
      return nil if @category_name.nil?
      @category_name = nil
      @category_id = nil
      @need_to_update = true
    end # unset category

    # Mixed-in Private Instance Methods
    #####################################
    private

    # Parse the category data from any incoming API data
    #
    # @return [void] description_of_returned_object
    #
    def parse_category
      if @init_data[:category]
        @category_name = @init_data[:category]
        @category_id = JSS::Category.category_id_from_name @category_name
      elsif @init_data[:general] && @init_data[:general][:category]
        @category_name = @init_data[:general][:category][:name]
        @category_id = @init_data[:general][:category][:id]
      end
      @category_data_style = OLD_STYLE_CATEGORY_CLASSES.include?(self.class) ? :old : :new
      @category_name = nil if @category_name.to_s.casecmp(NO_CATEGORY_NAME).zero?
      @category_id = nil if @category_id == NO_CATEGORY_ID
    end # parse category

    # Add the category to the XML for POSTing or PUTting to the API.
    #
    # @param xmldoc[REXML::Document] The in-construction XML document
    #
    # @return [void]
    #
    def add_category_to_xml(xmldoc)
      root = xmldoc.root
      if @category_data_style == :old
        root.add_element('category').text = @category_name.to_s
      else
        gen_elem = root.elements['general'] ? root.elements['general'] : root.add_element('general')
        cat_elem = gen_elem.add_element 'category'
        cat_elem.add_element('name').text = @category_name.to_s
      end
    end # add_category_to_xml

  end # module categorizable

end # module
