# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # A mix-in module that allows objects to handle standardized search Criteria.
  #
  # Some objects in the JSS, such as Advanced Searches and Smart Groups,
  # include a set of Criteria. (i.e conditions which, when met, signify inclusion
  # in a result set.)
  #
  # A {Jamf::Criteriable::Criteria} instance is a container for one or more
  # {Jamf::Criteriable::Criterion} instances and provides methods for dealing with
  # them easily.
  #
  # When a {Jamf::APIObject} subclass includes this module, that subclass
  # will have a :criteria attribute, which holds a {Jamf::Criteriable::Criteria}
  # object and can be used to manipulate the Criterion objects inside.
  #
  # The including subclass also gains some instance methods:
  # * #parse_critera - sets up the :criteria attribute during initialization
  # * #criteria= - allows the wholesale replacement of the criteria
  # * #need_to_update - allows the {Jamf::Criteriable::Criteria} instance to
  #   inform the subclass instance that it has changed and needs an #update
  #
  # Classes mixing in this module *must*
  # *  If they are Updatable or Creatable, they must insert
  #    self.criteria.rest_xml into their own xml output.
  #
  #
  # @example Working with the criteria of an advanced computer search
  #   # create three Criterion instances (split over multiple lines for clarity)
  #   #
  #   # These find all of jeauxbleaux's computers that have either
  #   # Excel or Word installed
  #
  #   crtn_0 = Jamf::Criteriable::Criterion.new(
  #     and_or: :and, # NOTE: the and_or value of the first criterion is ignored
  #     name: 'Username',
  #     search_type: 'is',
  #     value: 'jeauxbleaux'
  #   )
  #
  #   crtn_1 = Jamf::Criteriable::Criterion.new(
  #     and_or: :and,
  #     paren: :opening,
  #     name: 'Application Title',
  #     search_type: 'has',
  #     value: 'Microsoft Excel.app'
  #   )
  #
  #   crtn_2 = Jamf::Criteriable::Criterion.new(
  #     and_or: :or,
  #     name: 'Application Title',
  #     search_type: 'has',
  #     value: 'Microsoft Word.app',
  #     paren: :closing
  #   )
  #
  #   # use them to create a Criteria instance
  #   crta = Jamf::Criteriable::Criteria.new [crtn_0, crtn_1, crtn_2]
  #
  #   # create a new Advanced Search
  #   srch = Jamf::AdvancedComputerSearch.make, :name => "my computer search"
  #   srch.display_fields = ["Computer Name"]
  #
  #   # add our Criteria to it
  #   srch.criteria = crta
  #
  #   # create it in the JSS
  #   srch.create # srch.search_results now contains the matching computers
  #
  #   # append a new criterion to the criteria, limiting the search results farther
  #   # to those computers that have done a recon in the past week
  #   srch.criteria.append_criterion Jamf::Criteriable::Criterion.new(
  #     and_or: :or,
  #     name: "Last Inventory Update",
  #     search_type: "less than x days ago",
  #     value: 8
  #   )
  #
  #   # save the change to the JSS
  #   srch.save
  #
  #   # fetch the new results
  #   srch.requery_search_results
  #
  #   # oops - that last one should have been :and, not :or
  #   # so replace the last criterion with a correct one
  #   srch.criteria.set_criterion 3, Jamf::Criteriable::Criterion.new(
  #     and_or: :and,
  #     name: "Last Inventory Update",
  #     search_type: "less than x days ago",
  #     value: 8
  #   )
  #
  #   # save the change to the JSS
  #   # providing a non-false parameter to #update will automatically
  #   # perform the requery  after the update.
  #   srch.update :requery
  #
  # @see Jamf::Criteriable::Criteria
  # @see Jamf::Criteriable::Criterion
  #
  module Criteriable

    #  Constants
    #####################################

    CRITERIABLE = true

    #  Variables
    #####################################

    #  Mixed-in Attributes
    #####################################

    # @return [Jamf::Criteriable::Criteria] the criteria for the instance into which we're mixed.
    attr_reader :criteria

    #  Mixed-in Instance Methods
    #####################################

    #
    # During initialization, convert the @init_data[:criteria] Hash into
    # a Jamf::Criteriable::Criteria instance stored in @criteria
    #
    # Classes mixing in this module must call this in #initialize
    #
    # @return [void]
    #
    def parse_criteria
      @criteria = Jamf::Criteriable::Criteria.new
      @criteria.criteria = @init_data[:criteria].map { |c| Jamf::Criteriable::Criterion.new(**c) } if @init_data[:criteria]

      @criteria.container = self
    end

    #
    # Change the criteria, it must be a Jamf::Criteriable::Criteria instance
    #
    # @param new_criteria[Jamf::Criteriable::Criteria, nil] the new criteria. An
    #   empty criteria object is used if nil is passed.
    #
    # @return [void]
    #
    def criteria=(new_criteria)
      new_criteria ||= Jamf::Criteriable::Criteria.new
      raise Jamf::InvalidDataError, 'Jamf::Criteriable::Criteria instance required' unless new_criteria.is_a?(Jamf::Criteriable::Criteria)

      @criteria = new_criteria
      @criteria.container = self unless new_criteria.nil?
      @need_to_update = true
    end

    #
    #
    # @api private
    # Allow our Criteria to tell us when there's been a change that needs
    # to be updated.
    #
    # @return [void]
    #
    def should_update
      @need_to_update = true if @in_jss
    end

  end # module Criteriable

end # module Jamf
