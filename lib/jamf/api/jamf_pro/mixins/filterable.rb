# Copyright 2022 Pixar
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

module Jamf

  # process filter strings for resources with filter request parameters
  #
  # This should be extended into CollectionResources whose LIST_PATH is
  # filterable
  #
  # Classes doing so must define the FILTER_KEYS constant, an Array of
  # Symbols of keys from OAPI_PROPERTIES which can be used in filters.
  module Filterable

    FILTER_PARAM_PREFIX = '&filter='.freeze

    # generate the RSQL filter to put into the url
    # This is callable from anywhere without mixing in.
    def self.parse_url_filter_param(filter)
      return filter if filter.nil? || filter.start_with?(FILTER_PARAM_PREFIX)

      "#{FILTER_PARAM_PREFIX}#{CGI.escape filter}"
    end

    def filter_keys
      defined?(self::FILTER_KEYS) ? self::FILTER_KEYS : []
    end



  end # Filterable

end # Jamf
