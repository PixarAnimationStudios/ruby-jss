# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
