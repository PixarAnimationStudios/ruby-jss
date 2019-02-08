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
  # assigned a 'site' in the JSS.
  #
  # Objects in the JSS present site data in the top-level :general Hash
  # in the :site key which is a Hash with a :name and :id key.
  #
  # Classes mixing in this module MUST:
  #
  # - define the constant SITE_SUBSET as either :top, :general, or whatever
  #   sub-hash of API data conaints the site info. (most are :general, but
  #   some, like advanced searches, are at the top level)
  #
  # - call {#add_site_to_xml(xmldoc)} from their #rest_xml method if they are
  #   {Updatable} or {Creatable}
  #
  module Sitable

    # Module Constants
    #####################################

    SITABLE = true

    # When no site has been assigned, this is the 'name' and id used
    NO_SITE_NAME = 'None'.freeze
    NO_SITE_ID = -1

    # Setting the site to any of these values will unset the site
    NON_SITES = [
      nil,
      '',
      0,
      NO_SITE_NAME,
      NO_SITE_ID
    ].freeze

    # Mixed-in Public Instance Methods
    #####################################

    # The name of the site for this object.
    # For backward compatibility, this is aliased to just
    # 'site'
    #
    # @return [String] The name of the site for this object.
    #
    def site_name
      @site_name || NO_SITE_NAME
    end # cat name
    alias site site_name

    # The id of the site for this object.
    #
    # @return [Integer] The id of the site for this object.
    #
    def site_id
      @site_id || NO_SITE_ID
    end # cat id

    # The JSS::Site instance for this object's site
    #
    # @return [JSS::Site] The JSS::Site instance for this object's site
    #
    def site_object
      return nil unless site_assigned?
      JSS::Site.fetch id: @site_id
    end # cat obj

    # Does this object have a site assigned?
    #
    # @return [Boolean] Does this object have a site assigned?
    #
    def site_assigned?
      !@site_name.nil?
    end # cat assigned?

    # Change the site of this object.
    # Any of the NON_SITES values will
    # unset the site
    #
    # @param new_site[Integer, String] The new site
    #
    # @return [void]
    #
    def site=(new_site)
      return nil unless updatable? || creatable?

      # unset the site? Use nil or an empty string
      if NON_SITES.include? new_site
        unset_site
        return
      end

      new_id = JSS::Site.valid_id new_site, api: @api
      new_name = JSS::Site.map_all_ids_to(:name, api: @api)[new_id]
      # no change, go home.
      return nil if new_name == @site_name

      raise JSS::NoSuchItemError, "Site '#{new_site}' is not known to the JSS" unless new_id

      @site_name = new_name
      @site_id = new_id
      @need_to_update = true
    end # site =

    # Set the site to nothing
    #
    # @return [void]
    #
    def unset_site
      # no change, go home
      return nil if @site_name.nil?
      @site_name = nil
      @site_id = nil
      @need_to_update = true
    end # unset site

    # Mixed-in Private Instance Methods
    #####################################
    private

    # Parse the site data from any incoming API data
    #
    # @return [void]
    #
    def parse_site
      site_data =
        if self.class::SITE_SUBSET == :top
          @init_data[:site]
        elsif @init_data[self.class::SITE_SUBSET]
          @init_data[self.class::SITE_SUBSET][:site]
        end
      site_data ||= { name: NO_SITE_NAME, id: NO_SITE_ID }

      @site_name = site_data[:name]
      @site_id = site_data[:id]
    end # parse site

    # Add the site to the XML for POSTing or PUTting to the API.
    #
    # @param xmldoc[REXML::Document] The in-construction XML document
    #
    # @return [void]
    #
    def add_site_to_xml(xmldoc)
      root = xmldoc.root
      site_elem =
        if self.class::SITE_SUBSET == :top
          root.add_element 'site'
        else
          parent_elem = root.elements[self.class::SITE_SUBSET.to_s]
          parent_elem ||= root.add_element(self.class::SITE_SUBSET.to_s)
          parent_elem.add_element 'site'
        end
      site_elem.add_element('name').text = site_name.to_s
    end # add_site_to_xml

  end # module categorizable

end # module
