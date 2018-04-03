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

  # Since much of the JSON data is borked, the methods here can be used to
  # parse the XML data into usable JSON, which we can then treat normally.
  #
  # For classes with borked JSON, set the constant USE_XML_WORKAROUND to true
  # (or anything) and then class.fetch will use the XML data parsed
  # with the methods here to get functional JSON, which can be treated mostly
  # like normal.
  #
  # One important difference, at least to start. Since we don't know
  # if an empty XML element should really be a Hash or Array, they
  # always come back as an empty string. In either case #empty? should work.
  #
  module XMLWorkarounds

    TF_STRINGS = %w[true false].freeze
    TRUESTRING = TF_STRINGS.first
    SIZE_ELEM_NAME = 'size'.freeze

    # given a REXML element, return its ruby value
    #
    # When APIObject classes with USE_XML_WORKAROUND defined are fetched,
    # The XML is parsed by calling this method with the root XML element.
    # This happens in APIObject#lookup_object_data
    #
    # This method is called recursively as needed when traversing XML elements
    # that contain elements.
    #
    def self.process_element(elem)
      # remove any 'size' element if appropriate
      remove_size_sub_elem elem

      # Elems without sub elems have a single value
      return elem_to_single_value(elem) unless elem.has_elements?

      # If an element has sub-elements, and all the sub-elems
      # have the same name, (ignoring a single 'size' element removed above)
      # then the elem should be comverted to
      # an Array of its sub-elems, ignoring their names.
      #
      # Those sub-elems may themselves be Arrays or Hashes.
      #
      return elem_as_array elem if elem_should_be_array? elem

      # If we're here, the elem has sub-elems with different names,
      # so convert the elem to a hash, with the sub-elem names as
      # keys pointing to their values, which may be other arrays or hashes.
      #
      # NOTE: if there are more than one element with the same name,
      # there will be lost data, but also its badly designed XML.
      # Jamf has done this in the past, e.g. with the SlfSvc Notification
      # options PI-005310
      #
      elem_as_hash elem
    end

    # remove the 'size' sub element as long as:
    # - a sub element named 'size' exists
    # - there's only one sub element named 'size'
    # - it doesn't have sub elements itself
    # - and it contains an integer value
    # These are extraneous for the most part, and
    # will confuse the logic when deciding if an element
    # should become an Array or a Hash.
    #
    def self.remove_size_sub_elem(elem)
      return unless elem.elements[SIZE_ELEM_NAME]
      return unless elem.elements.to_a.select { |subel| subel.name == SIZE_ELEM_NAME }.count == 1
      return if elem.elements[SIZE_ELEM_NAME].has_elements?
      return unless elem.elements[SIZE_ELEM_NAME].text.jss_integer?
      elem.delete_element SIZE_ELEM_NAME
    end

    # Convert a single text value from an XML element into
    # an approprate ruby class:
    #   - textual integers to integers         '123' => 123
    #   - textual floats to floats             '-12.34' => -12.34
    #   - textual Booleans to real booleans    'true' => true
    #   - everything else is a String          '37.0.2' => '37.0.2'
    #                                        nil => ''
    #
    def self.elem_to_single_value(elem)
      case elem.text
      when /^-?\d+$/
        elem.text.to_i
      when /^-?\d+\.\d+$/
        elem.text.to_f
      when *TF_STRINGS
        elem.text.downcase == TRUESTRING ? true : false
      else
        elem.text.to_s
      end # case
    end

    # If there's more than one sub-element, and those
    # all have the same name, it should be an Array
    def self.elem_should_be_array?(elem)
      elem.elements.size > 1 && elem.to_a.map(&:name).uniq.size == 1
    end

    # convert an XML element into an Array
    def self.elem_as_array(elem)
      arr = []
      elem.each do |subelem|
        # Recursion for the win!
        arr << process_element(subelem)
      end # each subelem
      arr
    end

    # convert an XML element into a Hash
    def self.elem_as_hash(elem)
      hsh = {}
      elem.each do |subelem|
        # Recursion for the win!
        hsh[subelem.name] = process_element(subelem)
      end # each subelem
      hsh
    end

  end # module XMLWorkarounds

end # module
