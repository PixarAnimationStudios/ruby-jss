# Copyright 2023 Pixar
#
# frozen_string_literal: true

#
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# The Module
module Jamf

  # Classes
  #####################################

  # A building in the Jamf Pro API
  #
  # The parent class is the OAPI object representing a single member of the
  # collection, i.e. the 'GET_OBJECT' similar to the POST_OBJECT defined in the
  # class below.
  #
  class ComputerPrestage < Jamf::OAPISchemas::GetComputerPrestageV3

    include Jamf::CollectionResource
    include Jamf::Prestage

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.
    #
    # TODO: See if these constants can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::ComputerPrestageSearchResultsV3

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::PostComputerPrestageV3

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::PutComputerPrestageV3

    ############# API PATHS
    # TODO: See if these paths can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The path for GETting the list of all objects in the collection, possibly
    # filtered, sorted, and/or paged
    #
    # REQUIRED for all collection resources
    #
    # GET_, PUT_, PATCH_, POST_, and DELETE_ paths for instances don't need to be
    # defined if they are the same as LIST_PATH (followed by an id if needed)
    #
    # See the methods get_path, put_path, etc, in  Jamf::CollectionResource::ClassMethods
    #
    LIST_PATH = 'v3/computer-prestages'

    # As of Jamf Pro 10.50, the scope-related endpoints for computer prestages
    # are still in v2
    SCOPE_PATH_PREFIX = 'v2/computer-prestages'

    # alt and non-unique idents are defined in the prestage module

  end # class

end # module
