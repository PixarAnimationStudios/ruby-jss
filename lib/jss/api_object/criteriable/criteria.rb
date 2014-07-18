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

    ### The JSS::Criteriable::Criteria class stores an array of JSS::Criteriable::Criterion instances 
    ### and provides methods for working with them as a group.
    ###
    ### JSS::APIObject subclasses that include JSS::Criteriable each have a :criteria attribute
    ### which holds one Criteria object.
    ###
    ### Objects that contain Criteria objects need to 
    ### 1 - call '#container = self' on their Criteria object when its created.
    ### 2 - implement #need_to_update, which the Criteria object calls when it changes.
    ###
    ### Both of those tasks are handled by the JSS::Criteriable module and are mixed in when 
    ### it's included.
    ###
    class Criteria
      
      #####################################
      ### Class Constants
      #####################################
      
      ### Criterion instances we maintain need these attributes.s
      CRITERION_ATTRIBUTES = [:priority, :and_or, :name, :search_type, :value]
      
      #####################################
      ### Attributes
      #####################################
      
      ### Array - the group of JSS::Criteriable::Criterion instances making up these Criteria
      attr_reader :criteria
      
      ### JSS::APIObject subclass - a reference to the object containing these Criteria
      attr_reader :container
      
      ###
      ### @param new_criteria[Array<JSS:Criteriable::Criterion>]
      ### 
      def initialize(new_criteria)
        @criteria = []
        self.criteria = new_criteria
      end # init
      
      ### set the object we belong to, so we can set its @need_to_update value
      def container= (a_thing)
        @container = a_thing
      end
      
      ###
      ### Provide a whole new array of JSS::Criteriable::Criterion instances for this Criteria
      ###
      ### @param new_criteria[Array<JSS:Criteriable::Criterion>]
      ###
      def criteria= (new_criteria)
        unless new_criteria.kind_of? Array and  new_criteria.reject{|c| c.kind_of? JSS::Criteriable::Criterion }.empty?
          raise JSS::InvalidDataError, "Argument must be an Array of JSS::Criteriable::Criterion instances."
        end
        new_criteria.each{ |nc| criterion_ok? nc }
        @criteria = new_criteria
        set_priorities  
        @container.need_to_update if @container
      end
      
      
      
      ###
      ### Change the details of one specific criterion
      ###
      ### @param priority[Integer] the priority/index of the criterion being changed.
      ###   The index must already exist. Otherwise use
      ###   #append_criterion, #prepend_criterion, or #insert_criterion
      ### @param criterion[JSS::Criteriable::Criterion] the new Criterion to store at that index
      ###
      def set_criterion(priority, criterion)
        raise JSS::NoSuchItemError, "No current criterion with priority '#{priority}'" unless @criteria[priority]
        criterion_ok? criterion
        @criteria[priority] = criterion
        @container.need_to_update if @container
      end
      
      ###
      ### Add a new criterion to the end of the criteria
      ###
      ### @param criterion[JSS::Criteriable::Criterion] the new Criterion to store
      ###
      def append_criterion(criterion)
        criterion_ok? criterion
        criterion.priority = @criteria.length
        @criteria << criterion
        @container.need_to_update if @container
      end
      
      ###
      ### Add a new criterion to the beginning of the criteria
      ###
      ### @param criterion[JSS::Criteriable::Criterion] the new Criterion to store
      ###
      def prepend_criterion(criterion)
        criterion_ok? criterion
        @criteria.unshift criterion
        set_priorities
        @container.need_to_update if @container
      end
      
      ###
      ### Add a new criterion to the middle of the criteria
      ###
      ### @param priority[Integer] the priority/index before which to insert the new one.
      ### @param criterion[JSS::Criteriable::Criterion] the new Criterion to store at that index
      ###
      def insert_criterion(priority,criterion)
        criterion_ok? criterion
        @criteria.insert criterion[:priority], criterion
        set_priorities
        @container.need_to_update if @container
      end
      
      ###
      ### Remove a criterion from the criteria
      ### 
      ### @param priority[Integer] the priority/index of the criterion to delete
      ###
      def delete_criterion(priority)
        if @criteria[priority]
          raise JSS::MissingDataError, "Criteria can't be empty" if @criteria.count == 1
          @criteria.delete_at priority
          set_priorities
        end
        @container.need_to_update if @container
      end
      
      ###
      ### Set the priorities of the @criteria to match their array indices
      ###
      def set_priorities
        @criteria.each_index{ |ci| @criteria[ci].priority = ci }
      end 
      
      ###
      ### @return [REXML::Element] the xml element for the criteria
      ###
      ### @note This can't be a private method for this class.
      ###
      def rest_xml
        raise JSS::MissingDataError, "Criteria can't be empty" if @criteria.empty?
        cr = REXML::Element.new 'criteria'
        @criteria.each { |c| cr << c.rest_xml }
        return cr
     end # rest_xml
  
      #####################################
      ### Private Instance Methods
      #####################################    
      private
      
      
      ###
      ### Chech the validity of a criterion.
      ### Note that this doesn't check the :priority
      ### which is set by methods calling this one.
      ###
      ### Return true or raise an error about the problem
      ###
      def criterion_ok? (criterion)
        raise JSS::InvalidDataError, "Duplicate criterion: #{criterion.signature.join(', ')}" if @criteria.select{|c| c == criterion}.count > 1
        raise JSS::InvalidDataError, "Missing :and_or for criterion: #{criterion.signature.join(', ')}" unless criterion.and_or
        raise JSS::InvalidDataError, "Missing :name for criterion: #{criterion.signature.join(', ')}" unless criterion.name
        raise JSS::InvalidDataError, "Missing :search_type for criterion: #{criterion.signature.join(', ')}" unless criterion.search_type
        raise JSS::InvalidDataError, "Missing :value for criterion: #{criterion.signature.join(', ')}" unless criterion.value
        true
      end
      
    end # class Criteria
  end # module Criteriable  
end # module
