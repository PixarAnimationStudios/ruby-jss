### Copyright 2014 Pixar
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

    MATCH_RSRC = "match"

    #####################################
    ###  Variables
    #####################################

    #####################################
    ###  Mixed-in Instance Methods
    #####################################

    #####################################
    ###  Extended Class Methods
    #####################################

    ###
    ### Perform a match, returning an Array of Hashes, one for each item matched
    ###
    ### At the moment, it appears the search is an "exact match" search
    ### regardless of the prefs of the user connected to the API.
    ###
    ### @param term[String] the term to match.
    ###
    ### @return [Array<Hash>] the item smatched.
    ###
    def match(term)
      raise JSS::InvalidDataError, "Match term may not be empty" if term.to_s.empty?
      rsrc = "#{self::RSRC_BASE}/#{JSS::Matchable::MATCH_RSRC}/#{term}"
      JSS::API.get_rsrc(rsrc)[self::RSRC_LIST_KEY]
    end

  end # module Matchable

end # module
