# Copyright 2018 Pixar

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

#
module JSS

  # This file implements the 'computerapplications' API endpoint, used
  # for searching for computers with certain applications installed.
  #
  # All the methods defined here are class methods on JSS::Computer
  # since they all return lists of computers and apps.
  #
  # The apps installed on a JSS::Computer instance are available via the
  # #apps instance method (a shortcut that looks into the 'software' subset)
  #

  #
  class Computer < JSS::APIObject

    COMPUTER_APPLICATIONS_RSRC = 'computerapplications/application'.freeze

    # Query the JSS for computers with some app installed. An app name is required
    # as the first parameter.
    #
    # If no other parameters are given, returns a Hash, one key per version of the
    # app. For each version there is an array of Hashes, one Hash for each
    # computer with that version. The sub hashes contain keys for the computer's
    # identifiers, i.e. :name, :id, :udid, :serial_number, :mac_address.
    #
    # If one or more inventory fields are provided in the 'fields' parameter,
    # each computer's hash also has keys and values for those fields if they
    # exist in the JSS. These fields are those available in the display options
    # for Advanced Computer Searches (including extention attribute names) and
    # their names are case-sensitive, so 'Username', not 'username'
    #
    # If a specific version is provided in the 'version' parameter, only computers
    # containing that version of the app are returned as an Array of Hashes.
    #
    # If the ids_only parameter is truthy, an Array of JSS id numbers for
    # computers with this app is returned. In this case the 'fields' parameter
    # is ignored, however the 'version' parameters is still valid and will
    # restrict the list to those computer ids with that version installed.
    #
    # @param appname [String] The name of the app to look for, e.g. 'Transmogrifier.app'
    #
    # @param fields [String,Array<String>] Additional 'inventory fields' to return
    #    with each computer's data
    #
    # @param version [String] Limit search to a specific version of the app
    #
    # @param ids_only [Boolean] Just return an array of the id's of computers
    #  found with this query. Defaults to false
    #
    # @param api [JSS::APIConnection] The API connection to use for the query.
    #   default: JSS.api
    #
    # @return [Array<Integer>] When ids_only == true, the ids of computers with
    #   the app installed (possibly limited to version)
    #
    # @return [Array<Hash>] When version is provided, An Array of Hashes, one
    #   for each computer, with keys for identifiers plus any requested fields.
    #
    # @return [Hash{String => Array<Hash>}] When no version is provided, a Hash
    #   with keys for each version, pointing to an array of Hashes, one for
    #   each computer with that version. Each computer's Hash has keys for
    #   identifiers plus any requested fields.
    #
    #
    def self.application_installs(appname, fields: [], version: nil, ids_only: false, api: JSS.api)
      fields = [fields] unless fields.is_a? Array

      rsrc = "#{COMPUTER_APPLICATIONS_RSRC}/#{appname}"
      rsrc << "/version/#{version}" if version
      rsrc << "/inventory/#{fields.join ','}" unless ids_only || fields.empty?

      # get_rsrc will URI.encode the rsrc
      result = api.get_rsrc(rsrc)[:computer_applications]

      return result[:unique_computers].map { |c| c[:id] } if ids_only

      if version.nil?
        hash_by_version = {}
        result[:versions].each { |v| hash_by_version[v[:number]] = v[:computers] }
        return hash_by_version
      end

      result[:versions].first[:computers]
    end # self.application_search

  end # Computer

end # JSS
