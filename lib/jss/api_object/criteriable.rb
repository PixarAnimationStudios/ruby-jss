### Copyright 2017 Pixar

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


### A mix-in module providing consistent access to JSS::Criteriable::Criteria and
### JSS::Criteriable::Criterion objects from within objects that contain Criteria.
###
###


  #####################################
  ### Module Variables
  #####################################


  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Sub-Modules
  #####################################

  ###
  ### A mix-in module that allows objects to handle standardized search Criteria.
  ###
  ### Some objects in the JSS, such as Advanced Searches and Smart Groups,
  ### include a set of Criteria. (i.e conditions which, when met, signify inclusion
  ### in some result set.)
  ###
  ### A {JSS::Criteriable::Criteria} instance is a container for one or more
  ### {JSS::Criteriable::Criterion} instances and provides methods for dealing with
  ### them easily.
  ###
  ### When a {JSS::APIObject} subclass includes this module, that subclass
  ### will have a :criteria attribute, which holds a {JSS::Criteriable::Criteria}
  ### object and can be used to manipulate the Criterion objects inside.
  ###
  ### The including subclass also gains some instance methods:
  ### * #parse_critera - sets up the :criteria attribute during initialization
  ### * #criteria= - allows the wholesale replacement of the criteria
  ### * #need_to_update - allows the {JSS::Criteriable::Criteria} instance to
  ###   inform the subclass instance that it has changed and needs an #update
  ###
  ### Classes mixing in this module *must*
  ### *  call #parse_criteria during initialization.
  ### *  If they are Updatable or Creatable, they must insert
  ###    self.criteria.rest_xml into their own xml output.
  ###
  ###
  ### @example Working with the criteria of an advanced search
  ###   # create a couple of Criterion instances
  ###   crtn_0 = JSS::Criteriable::Criterion.new :and_or => :or, :name => "Username", :search_type => "is", :value => "jeauxbleaux"
  ###   crtn_1 = JSS::Criteriable::Criterion.new :and_or => :and, :name => "Last Check-in", :search_type => "less than x days ago", :value => 3
  ###
  ###   # use them to create a Criteria instance
  ###   crta = JSS::Criteriable::Criteria.new [crtn_0, crtn_1]
  ###
  ###   # create a new Advanced Search
  ###   srch = JSS::AdvancedComputerSearch.new :id => :new, :name => "my computer search"
  ###   srch.display_fields = ["Computer Name"]
  ###
  ###   # add our Criteria to it
  ###   srch.criteria = crta
  ###
  ###   # create it in the JSS
  ###   srch.create # srch.search_results now contains the matching computers
  ###
  ###   # append a new criterion to the criteria, limiting the search results farther
  ###   srch.criteria.append_criterion JSS::Criteriable::Criterion.new(:and_or => :or, :name => "Computer Name", :search_type => "like", :value => "o")
  ###
  ###   # save the change to the JSS
  ###   srch.save  # srch.search_results  now contains the matching computers
  ###
  ###   # oops - that last one should have been :and, not :or
  ###   srch.criteria.criteria[2].and_or = :and
  ###
  ###   # the above can also be achieved like this, by replacing the last criterion altogether:
  ###   srch.criteria.set_criterion 2, JSS::Criteriable::Criterion.new(:and_or => :and, :name => "Computer Name", :search_type => "like", :value => "o")
  ###
  ###   # save the change to the JSS
  ###   srch.save  # srch.search_results  now contains the matching computers
  ###
  ### @see JSS::Criteriable::Criteria
  ### @see JSS::Criteriable::Criterion
  ###
  module Criteriable

    #####################################
    ###  Constants
    #####################################

    CRITERIABLE = true


    #####################################
    ###  Variables
    #####################################

    #####################################
    ###  Mixed-in Attributes
    #####################################

    ### @return [JSS::Criteriable::Criteria] the criteria for the instance into which we're mixed.
    attr_reader :criteria

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    ###
    ### During initialization, convert the @init_data[:criteria] Hash into
    ### a JSS::Criteriable::Criteria instance stored in @criteria
    ###
    ### Classes mixing in this module must call this in #initialize
    ###
    ### @return [void]
    ###
    def parse_criteria
      @criteria = if @init_data[:criteria]
        JSS::Criteriable::Criteria.new @init_data[:criteria].map{|c| JSS::Criteriable::Criterion.new c}
      else
        nil
      end
      @criteria.container = self if @criteria
    end

    ###
    ### Change the criteria, it must be a JSS::Criteriable::Criteria instance
    ###
    ### @param new_criteria[JSS::Criteriable::Criteria] the new criteria
    ###
    ### @return [void]
    ###
    def criteria= (new_criteria)
      raise JSS::InvalidDataError, "JSS::Criteriable::Criteria instance required" unless new_criteria.kind_of?(JSS::Criteriable::Criteria)
      @criteria = new_criteria
      @criteria.container = self
      @need_to_update = true
    end

    ###
    ###
    ### @api private
    ### Allow our Criteria to tell us when there's been a change that needs
    ### to be updated.
    ###
    ### @return [void]
    ###
    def should_update
      @need_to_update = true if @in_jss
    end

    #####################################
    ###  Mixed-in Class Methods
    #####################################



  end # module Criteriable

end # module JSS

require "jss/api_object/criteriable/criterion"
require "jss/api_object/criteriable/criteria"
