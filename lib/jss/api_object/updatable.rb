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

### A mix-in module providing object-updating via the JSS API.
module JSS

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Sub-Modules
  #####################################

  # A mix-in module that allows objects to be updated in the JSS via the API.
  #
  # When a JSS::APIObject subclass includes this module, instances of that
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
      raise JSS::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless updatable?
      raise JSS::InvalidDataError, "Names can't be empty!" if newname.to_s.empty?
      raise JSS::AlreadyExistsError, "A #{self.class::RSRC_OBJECT_KEY} named '#{newname}' already exsists in the JSS" \
        if self.class.all_names(:refresh, api: @api).include? newname
      @name = newname
      @rest_rsrc = "#{self.class::RSRC_BASE}/name/#{CGI.escape @name.to_s}" if @rest_rsrc.include? '/name/'
      @need_to_update = true
    end #  name=(newname)

    # Save changes to the JSS
    #
    # @return [Boolean] success
    #
    def update
      return nil unless @need_to_update
      raise JSS::UnsupportedError, "Editing #{self.class::RSRC_LIST_KEY} isn't yet supported. Please use other Casper workflows." unless updatable?
      raise JSS::NoSuchItemError, "Not In JSS! Use #create to create this #{self.class::RSRC_OBJECT_KEY} in the JSS before updating it." unless @in_jss
      @api.put_rsrc @rest_rsrc, rest_xml
      @need_to_update = false
      refresh_icon if self_servable?
      @id
    end # update

  end # module Creatable

end # module
