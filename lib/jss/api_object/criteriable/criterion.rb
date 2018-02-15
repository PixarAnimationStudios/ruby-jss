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

  module Criteriable

    #####################################
    ### Module Variables
    #####################################

    #####################################
    ### Module Methods
    #####################################

    #####################################
    ### Classes
    #####################################

    ### This class defines a single criterion used in advanced searches and
    ### smart groups throughout the JSS module.
    ###
    ### They are used within {JSS::Criteriable::Criteria} instances which store an
    ### array of these objects and provides methods for working with them as a group.
    ###
    ### The classes that mix-in {JSS::Criteriable} each have a :criteria attribute which
    ### holds one {JSS::Criteriable::Criteria}
    ###
    ### See {JSS::Criteriable} for examples
    ###
    class Criterion

      #####################################
      ### Mix Ins
      #####################################

      include Comparable  # this allows us compare instances using <=>

      #####################################
      ### Class Constants
      #####################################

      ### These are the available search-types for building criteria
      SEARCH_TYPES = [
        "is",
        "is not",
        "like",
        "not like",
        "has",
        "does not have",
        "more than",
        "less than",
        "before (yyyy-mm-dd)",
        "after (yyyy-mm-dd)",
        "more than x days ago",
        "less than x days ago",
        "in more than x days",
        "in less than x days",
        "member of",
        "not member of",
        "current",
        "not current"
      ]

      ### the acceptable symboles for and/or
      AND_OR = [:and, :or]

      #####################################
      ### Attributes
      #####################################

      ### @return [Integer] zero-based index of this criterion within an array of criteria
      ###  used for an advanced search or smart group.
      ###  This is maintained automaticaly by the enclosing Criteria object
      attr_accessor :priority

      ### @return [Symbol] :and or :or - the and_or value for associating this criterion with the previous one
      attr_reader :and_or

      ### @return [String] the name of the field being searched
      attr_accessor :name

      ### @return [String] the comparator between the field and the value, must be one of SEARCH_TYPES
      ### @see #criteria=
      attr_reader :search_type

      ### @return [String] the value being searched for in the field named by :name
      attr_reader :value

      ###
      ### @param args[Hash] a hash of settings for the new criterion
      ### @option args :and_or [String, Symbol] :and, or :or. How should this criterion be join with its predecessor?
      ### @option args :name [String] the name of a Criterion as is visible in the JSS webapp.
      ### @option args :search_type [String] one of SEARCH_TYPES, the comparison between the stored value and :value
      ### @option args :value [String] the value to compare with that stored for :name
      ###
      ### @note :priority is maintained by the JSS::Criteriable::Criteria object holding this instance
      ###
      def initialize(args = {})

        @priority = args[:priority]

        if args[:and_or]
          @and_or = args[:and_or].to_sym
          raise JSS::InvalidDataError, ":and_or must be 'and' or 'or'." unless AND_OR.include? @and_or
        end

        @name = args[:name]

        if args[:search_type]
          raise JSS::InvalidDataError, "Invalid :search_type" unless SEARCH_TYPES.include? args[:search_type]
          @search_type = args[:search_type]
        end

        @value = args[:value]
      end # init

      ###
      ### Set a new and_or for the criteron
      ###
      ### @param new_val[Symbol] the new and_or
      ###
      ### @return [void]
      ###
      def and_or= (new_val)
        @and_or = new_val.to_sym
        raise JSS::InvalidDataError, ":and_or must be 'and' or 'or'." unless AND_OR.include? @and_or.to_sym
      end

      ###
      ### Set a new search type for the criteron
      ###
      ### @param new_val[String] the new search type
      ###
      ### @return [void]
      ###
      def search_type= (new_val)
        raise JSS::InvalidDataError, "Invalid :search_type" unless SEARCH_TYPES.include? new_val
        @search_type = new_val
      end

      ###
      ### Set a new value for the criteron
      ###
      ### @param new_val[Integer,String] the new value
      ###
      ### @return [void]
      ###
      def value=(new_val)
        case @search_type

          when *["more than", "less than", "more than x days ago", "less than x days ago"]
            raise JSS::InvalidDataError, "Value must be an integer for search type '#{new_val}'" unless new_val =~ /^\d+$/

          when *["before (yyyy-mm-dd)", "after (yyyy-mm-dd)"]
            raise JSS::InvalidDataError, "Value must be a a date in the format yyyy-mm-dd for search type '#{new_val}'"  unless new_val =~ /^\d\d\d\d-\d\d-\d\d$/

        end # case

        @value = new_val

      end

      ###
      ### @return [String] All our values except priority joined together
      ###   for comparing this Criterion to another for equality and order
      ###
      ### @see #<=>
      ###
      def signature
        [@and_or, @name, @search_type, @value].join ","
      end


      ###
      ### Comparison - allows the Comparable module to do its work
      ###
      ### @return [Integer]  -1, 0, or 1
      ###
      ### @see Comparable
      ###
      def <=>(other)
        self.signature <=> other.signature
      end

      ###
      ### @api private
      ###
      ### @return [REXML::Element] The xml element for the criterion, to be embeded in that of
      ###   a Criteria instance
      ###
      ### @note For this class, rest_xml can't be a private method.
      ###
      def rest_xml
        crn = REXML::Element.new 'criterion'
        crn.add_element('priority').text = @priority
        crn.add_element('and_or').text = @and_or
        crn.add_element('name').text = @name
        crn.add_element('search_type').text = @search_type
        crn.add_element('value').text = @value
        return crn
     end

    end # class criterion
  end # module Criteriable
end # module
