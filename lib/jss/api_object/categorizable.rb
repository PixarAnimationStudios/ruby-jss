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

  # A mix-in module that centralizes the code for handling objects which can be
  # assigned a 'category' in the JSS.
  #
  # Objects in the JSS present category data in two different ways:
  #
  # 1) An 'old' style, where the top-level Hash of the API data contains a
  #    :category key which contains a String, being the category name.
  #
  # 2) A 'new' style, where the :category key is a Hash with a :name and :id key.
  #    This Hash is usually in the :general subset, but may be elsewhere.
  #
  # Classes mixing in this module MUST:
  #
  # - Define the constant CATEGORY_SUBSET as a symbol indicating where in
  #   the API data the :category key will be found. The symbol is either
  #   :top for the top-level of the API data, or the name of the subsection
  #   Hash containing :category, e.g. :general.
  #
  # - Define the constant CATEGORY_DATA_TYPE as either String or Hash
  #   (the class names) which indicate if the contents of the :category key
  #   is a String (The category name) or a Hash (containing :name and :id)
  #
  # - call {#add_category_to_xml(xmldoc)} from their #rest_xml method if they are
  #   {Updatable} or {Creatable}
  #
  module Categorizable

    # Module Constants
    #####################################

    CATEGORIZABLE = true

    # When no category has been assigned, this is the 'name'
    NO_CATEGORY_NAME = 'No category assigned'.freeze
    # When no category has been assigned, this is the id
    NO_CATEGORY_ID = -1

    # Setting the category to any of these values will unset the category
    NON_CATEGORIES = [
      nil,
      '',
      0,
      NO_CATEGORY_NAME,
      NO_CATEGORY_ID
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
      JSS::Category.fetch id: @category_id
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
      cat =
        if self.class::CATEGORY_SUBSET == :top
          @init_data[:category]
        else
          @init_data[self.class::CATEGORY_SUBSET][:category]
        end

      if cat.is_a? String
        @category_name = cat
        @category_id = JSS::Category.category_id_from_name @category_name
      else
        @category_name = cat[:name]
        @category_id = cat[:id]
      end
      clean_raw_categories
    end # parse category

    # Set the category name and id to nil, if need be.
    def clean_raw_categories
      @category_name = nil if @category_name && @category_name.to_s.casecmp(NO_CATEGORY_NAME).zero?
      @category_id = nil if @category_id == NO_CATEGORY_ID
    end

    # Add the category to the XML for POSTing or PUTting to the API.
    #
    # @param xmldoc[REXML::Document] The in-construction XML document
    #
    # @return [void]
    #
    def add_category_to_xml(xmldoc)
      return if category_name.to_s.empty?
      cat_elem = REXML::Element.new('category')

      if self.class::CATEGORY_DATA_TYPE == String
        cat_elem.text = @category_name.to_s
      elsif self.class::CATEGORY_DATA_TYPE == Hash
        cat_elem.add_element('name').text = @category_name.to_s
      else
        raise JSS::InvalidDataError, "Uknown CATEGORY_DATA_TYPE for class #{self.class}"
      end

      root = xmldoc.root

      if self.class::CATEGORY_SUBSET == :top
        root.add_element cat_elem
        return
      end

      parent = root.elements[self.class::CATEGORY_SUBSET.to_s]
      parent ||= root.add_element self.class::CATEGORY_SUBSET.to_s
      parent.add_element cat_elem
    end # add_category_to_xml

  end # module categorizable

end # module
