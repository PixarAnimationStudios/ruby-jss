# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

### A mix-in module providing object-updating via the JSS API.
module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Sub-Modules
  #####################################

  # A mix-in module that allows objects to be updated in the JSS via the API.
  #
  # When a Jamf::APIObject subclass includes this module, instances of that
  # subclass can be modified in the JSS using the {#update} or {APIObject#save} methods.
  #
  # Such classes should define setter methods for any values that they wish to
  # modify, such as the {#name=} method defined here. Those setter methods must:
  # - ensure the validity of the data they accept.
  # - set @need_to_update to true, indicating that the local object no longer
  #   matches the JSS, and the changes should be pushed to the server with {#update}
  #
  # Classes mixing this module *must* provide a #rest_xml instance method that returns the XML
  # String to be submitted to the API for object updating.
  #
  # @see_also APIObject#save
  #
  module Updatable

    #  Constants
    #####################################

    UPDATABLE = true

    #  Attributes
    #####################################

    # @return [Boolean] do we have unsaved changes?
    attr_reader :need_to_update

    #  Mixed-in Instance Methods
    #####################################

    # Change the name of this item
    # Remember to #update to push changes to the server.
    #
    # @param newname[String] the new name
    #
    # @return [void]
    #
    def name=(newname)
      return nil if @name == newname
      raise Jamf::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless updatable?
      raise Jamf::InvalidDataError, "Names can't be empty!" if newname.to_s.empty?
      raise Jamf::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} named '#{newname}' already exsists in the JSS" \
        if self.class.all_names(:refresh, cnx: @cnx).include? newname

      @name = newname
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name.to_s}" if @rest_rsrc.include? '/name/'
      @need_to_update = true
    end #  name=(newname)

    # Save changes to the JSS
    #
    # @return [Integer] The object id
    #
    def update_in_jamf
      return nil unless @need_to_update
      raise Jamf::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless updatable?

      @cnx.c_put @rest_rsrc, rest_xml
      @need_to_update = false
      refresh_icon if self_servable?

      # clear any cached all-lists or id-maps for this class
      # so they'll re-cache as needed
      @cnx.flushcache self.class::RSRC_LIST_KEY

      @id
    end # update
    private :update_in_jamf

  end # module Creatable

end # module
