# Copyright 2020 Pixar

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
  class Building < Jamf::OAPIObject::Building

    include Jamf::CollectionResource
    extend Jamf::Filterable

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.
    #
    # TODO: See if these constants can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPIObject::BuildingSearchResults

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPIObject::Building

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPIObject::Building

    # The OAPI object we send with a PATCH request to change an object in
    # Jamf by replacing only some of its values. This is never the same as the
    # parent class, and is usually used when many or most of the data about an
    # object cannot be changed via the API.
    PATCH_OBJECT = Jamf::OAPIObject::Building

    ############# API PATHS
    # TODO: See if these paths can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The path for GETting the list of all objects in the collection, possibly
    # filtered, sorted, and/or paged
    # REQUIRED for all collection resources
    LIST_PATH = 'v1/buildings'.freeze

    # See Jamf::CollectionResource::ClassMethods#get_path
    GET_PATH = LIST_PATH

    # The path for PUTting (replacing) a single object. The desired object id will
    # be appended to the end, e.g. if this value is 'v1/buildings' and you want
    # to PUT the record for building id 23, then we will PUT 'v1/buildings/23'
    #
    # You only really need to define this if it is not the same as the LIST_PATH
    # this is here for documentation
    PUT_PATH = LIST_PATH

    # The path for PATCHing (updating in-place) a single object. The desired
    # object id will be appended to the end, e.g. if this value is 'v1/buildings'
    # and you want to PATCH the record for building id 23, then we will PATCH
    # 'v1/buildings/23'
    #
    # You only really need to define this if it is not the same as the LIST_PATH
    # This is here for documentation
    PATCH_PATH = LIST_PATH

    # You only really need to define this if it is not the same as the LIST_PATH
    # This is here for documentation
    POST_PATH = LIST_PATH

    # You only really need to define this if it is not the same as the LIST_PATH
    # This is here for documentation
    DELETE_PATH = LIST_PATH

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only identifies ':id'
    ALT_IDENTIFIERS = %i[name].freeze

    # Must define this when extending Filterable
    FILTER_KEYS = %i[
      name streetAddress1 streetAddress2 city stateProvince zipPostalCode country
    ].freeze

  end # class

end # module
