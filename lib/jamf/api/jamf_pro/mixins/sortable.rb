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

module Jamf

  # parse the sort params for collection GET requests
  module Sortable

    # # When this is included
    # def self.included(klass)
    #   puts "Sortable was included by #{klass}"
    # end
    #
    # # When this is exdended
    # def self.extended(klass)
    #   puts "Sortable was extended by #{klass}"
    # end

    private

    # generate the sort params for the url
    #
    def parse_collection_sort(sort)
      case sort
      when nil
        sort
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
