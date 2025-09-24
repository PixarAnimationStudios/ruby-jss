# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  ### A mix-in module providing access to the "match" resources for some
  ### JSS API objects, like computers and mobile devices.
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
  ### Simple match-based searches in the JSS.
  ###
  ### The API offers a simple match-based search for some objects, analagous to the
  ### search field at the top of the Computers, MobileDevices, and Users sections of the
  ### JSS WebApp.
  ###
  ### When a class extends itself with this module, it will acquire the .match Class Method
  ### which performs a match  and returns an Array of matching items.
  ###
  ### This module should be mixed in with #extend, not #include
  ###
  module Matchable

    #####################################
    ###  Constants
    #####################################

    MATCHABLE = true

    MATCH_RSRC = 'match'

    #####################################
    ###  Variables
    #####################################

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    #####################################
    ###  Extended Class Methods
    #####################################

    ### Perform a match, returning an Array of Hashes, one for each item matched
    ###
    ### At the moment, it appears the search is an "exact match" search
    ### regardless of the prefs of the user connected to the API.
    ###
    ### @param term[String] the term to match.
    ###
    ### @return [Array<Hash>] the item smatched.
    ###
    def match(term, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      raise Jamf::InvalidDataError, 'Match term may not be empty' if term.to_s.empty?

      rsrc = "#{self::RSRC_BASE}/#{Jamf::Matchable::MATCH_RSRC}/#{CGI.escape term.to_s}"
      cnx.c_get(rsrc)[self::RSRC_LIST_KEY]
    end

  end # module Matchable

end # module
