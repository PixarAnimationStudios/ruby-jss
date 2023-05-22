### Copyright 2023 Pixar

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

  # Since a non-trivial amounts of the JSON data from the API are borked, the
  # methods here can be used to parse the XML data into usable JSON, which we
  # can then treat normally.
  #
  # For classes with borked JSON, set the constant USE_XML_WORKAROUND to a Hash
  # with a single key that maps the structure of the XML and resultant Ruby data.
  #
  # As an example, here's the data map from Jamf::PatchTitle
  #
  # USE_XML_WORKAROUND = {
  #   patch_software_title: {
  #     id: -1,
  #     name: Jamf::BLANK,
  #     name_id: Jamf::BLANK,
  #     source_id: -1,
  #     notifications: {
  #       email_notification: nil,
  #       web_notification: nil
  #     },
  #     category: {
  #       id: -1,
  #       name: Jamf::BLANK
  #     },
  #     versions: [
  #       {
  #         software_version: Jamf::BLANK,
  #         package: -1,
  #           name: Jamf::BLANK
  #         }
  #       }
  #     ]
  #   }
  # }.freeze
  #
  # The constant must always be a hash that represents the data structure
  # of the object. The keys match the names of the XML elements, and the
  # values indicate how to handle the element values.
  #
  # Single-value attributes will be converted based on the provided map example
  # The class of the map example is the class of the desired data, and the value
  # of the map example is the value to use when the XML data is nil or empty.
  #
  # So a map example of '' (an empty string, a.k.a. Jamf::BLANK) indicates
  # that the value should be a String and if the XML element is nil or empty,
  # use '' in the Ruby data. If its -1, that means the value should be an
  # Integer, and if its empty or nil, use -1 in Ruby.
  #
  # Booleans are special: the map example must be nil, and nil is used when the
  # xml is empty, since you want to be able to know that the XML value was
  # neither true nor false.
  #
  # Allowed single value classes and common default examples are:
  #   String, common default: '' or Jamf::BLANK
  #   Integer, common default: -1
  #   Float, common default: -1.0
  #   Boolean, required default: nil
  #
  # Arrays and Hashes will be recognized as such, and their contents will be
  # converted recursively using the same process.
  #
  # For Arrays, provide one example in the map of an Array
  # item, and all sub elements will be processd like the example. See
  # the ':versions' array defiend in the example above
  #
  # For sub-hashes, use the same technique as for the main hash.
  # see the :category value above.
  #
  # IMPORTANT NOTE: Lots of Arrays in the XML have a matching 'size' element
  # containing an integer indicating how many items are in the array. Unfortunately
  # there is zero consistency about their existence or location. If they exist at
  # all, sometimes the are adjacent to the Array element, sometimes within it.
  #
  # Fortunately in Ruby, all container/enumerable classes have a 'size' or 'count'
  # method to easily get that number.
  # As such, when parsing XML elements, any 'size' element that exists with no
  # other 'size' elements, and contains only an integer value and no sub-
  # elements, are ignored. I haven't yet found any cases of a 'size' element
  # that is used for anything else.
  #
  module XMLWorkaround

    BOOLEAN_STRINGS = %w[true false].freeze
    TRUE_STRING = BOOLEAN_STRINGS.first
    SIZE_ELEM_NAME = 'size'.freeze

    # When APIObject classes are fetched, API JSON data is retrieved by the
    # APIObject#lookup_object_data method, which parses the JSON into Ruby data.
    #
    # If the APIObject class has the constant USE_XML_WORKAROUND defined, that
    # means the JSON data from the API is invalid, incorrect, or otherwise
    # borked. So instead, the  XML is retrieved from the API here.
    #
    # It is then parsed by using the methods in this module and returned
    # to the APIObject#lookup_object_data method, which then
    # treats it normally.
    #
    def self.data_via_xml(rsrc, map, cnx)
      raw_xml = cnx.c_get(rsrc, :xml)
      xmlroot = REXML::Document.new(raw_xml).root
      hash_from_xml = {}
      map.each do |key, model|
        hash_from_xml[key] = process_map_item model, xmlroot
      end
      hash_from_xml
    end

    # given a REXML element, return its ruby value
    #
    # This method is then called recursively as needed when traversing XML
    # elements that contain sub-elements.
    #
    # XML Elements that do not contain other elements are converted to a
    # single ruby value.
    #
    def self.process_map_item(model, element)
      case model
      when String
        element ? element.text : model
      when Integer
        element ? element.text.to_i : model
      when Float
        element ? element.text.to_f : model
      when nil
        return nil unless element

        element.text.downcase == TRUE_STRING
      when Array
        element ? elem_as_array(model.first, element) : []
      when Hash
        element ? elem_as_hash(model, element) : {}
      end # case type
    end

    # remove the 'size' sub element from a given element as long as:
    # - a sub element named 'size' exists
    # - there's only one sub element named 'size'
    # - it doesn't have sub elements itself
    # - and it contains an integer value
    # Such elements are extraneous for the most part, and are not consistently
    # located - sometimes they are in the Array-ish elements they reference,
    # sometimes they are alongside them. In any case they confuse the logic
    # when deciding if an element with sub-elements should become an
    # Array or a Hash.
    #
    def self.remove_size_sub_elem(elem)
      size_elems = elem.elements.to_a.select { |subel| subel.name == SIZE_ELEM_NAME }
      size_elem = size_elems.first
      return unless size_elem
      return unless size_elems.count == 1
      return if size_elem.has_elements?
      return unless size_elem.text.jss_integer?

      elem.delete_element size_elem
    end

    # convert an XML element into an Array
    def self.elem_as_array(model, elem)
      remove_size_sub_elem elem
      arr = []
      elem.each do |subelem|
        # Recursion for the win!
        arr << process_map_item(model, subelem)
      end # each subelem
      arr.compact
    end

    # convert an XML element into a Hash
    def self.elem_as_hash(model, elem)
      remove_size_sub_elem elem
      hsh = {}
      model.each do |key, mod|
        val = process_map_item(mod, elem.elements[key.to_s])
        val = [] if  mod.is_a?(Array) && val.to_s.empty?
        val = {} if  mod.is_a?(Hash) && val.to_s.empty?
        hsh[key] = val
      end
      hsh
    end

  end # module XMLWorkarounds

end # module
