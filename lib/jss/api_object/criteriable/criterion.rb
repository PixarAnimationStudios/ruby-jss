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
    ### They are used within JSS::Criteriable::Criteria instances which store an 
    ### array of these objects and provides methods for working with them as a group.
    ###
    ### The classes that mix-in JSS::Criteriable each have a :criteria attribute which
    ### holds one JSS::Criteriable::Criteria
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
        "less than x days ago"
      ]
      
      AND_OR = [:and, :or]
      
      #####################################
      ### Attributes
      #####################################
      
      ### Integer - zero-based index of this criterion within an array of criteria
      ### used for an advanced search or smart group. 
      ### This is maintained automaticaly by the enclosing Criteria object
      attr_accessor :priority
      
      ### Symbol - the and_or value for associating this criterion with the previous one
      ### in a set of criteria. Either :and or :or
      attr_reader :and_or
      
      ### String - the name of the field being searched
      attr_accessor :name
      
      ### String - the comparator between the field and the value, must be one of SEARCH_TYPES
      ### See #criteria= for details
      attr_reader :search_type
      
      ### String - the value being searched for in the field named by :name
      attr_accessor :value
      
      ###
      ### @param args[Hash] potential keys are
      ###  * :and_or [String, Symbol] :and, or :or. How should this criterion be join with its predecessor
      ###  * :name [String] the name of a Criterion as is visible in the JSS webapp.
      ###  * :search_type [String] one of SEARCH_TYPES, the comparison between the stored value and :value
      ###  * :value [String] the value to compare with that stored for :name
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
      ### set a new and_or value
      ###
      def and_or= (new_val)
        @and_or = new_val.to_sym
        raise JSS::InvalidDataError, ":and_or must be 'and' or 'or'." unless AND_OR.include? @and_or.to_sym
      end
      
      ###
      ### set a new search type
      ###
      def search_type= (new_val)
        raise JSS::InvalidDataError, "Invalid :search_type" unless SEARCH_TYPES.include? new_val
        check_search_type(new_val)
        @search_type = new_val
      end
      
      ###
      ### check the format of the search type
      ### raise an exception if there's a problem
      ###
      def check_search_type(new_val)
        case new_val
          
          when *["more than", "less than", "more than x days ago", "less than x days ago"]
            raise JSS::InvalidDataError, "Value must be an integer for search type '#{new_val}'" unless criterion[:value] =~ /^\d+$/
          
          when *["before (yyyy-mm-dd)", "after (yyyy-mm-dd)"]
            raise JSS::InvalidDataError, "Value must be a a date in the format yyyy-mm-dd for search type '#{new_val}'"  unless new_val =~ /^\d\d\d\d-\d\d-\d\d$/
        
        end # case
      end
      
      ###
      ### Return a Array - all our values except priority, for comparing this
      ### Criterion to another for equality
      ###
      def signature
        [@and_or, @name, @search_type, @value]
      end
      
      
      ###
      ### Comparison - allows the Comparable module to do its work
      ###
      def <=>(other)
        self.signature <=> other.signature
      end
      
      ###
      ### return the xml element for the criterion, to be embeded in that of 
      ### a Criteria instance
      ### NOTE: for this class, this can't be a private method.
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
