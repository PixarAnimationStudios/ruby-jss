# Copyright 2025 Pixar
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

  # Currently no need to mix this in anywhere.
  module Sortable

    SORT_PARAM_PREFIX = '&sort='.freeze

    # generate the sort params for the url
    # This is callable from anywhere without mixing in
    def self.parse_url_sort_param(sort)
      return sort if sort.nil? || sort.start_with?(SORT_PARAM_PREFIX)

      case sort
      when String
        "&sort=#{CGI.escape sort}"
      when Array
        "&sort=#{CGI.escape sort.join(',')}"
      else
        raise ArgumentError, 'sort criteria must be a String or Array of Strings'
      end
    end

  end # Sortable

end # Jamf
