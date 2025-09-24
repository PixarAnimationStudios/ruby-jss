# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
  #
  # TODO: Actually implement this module in CollectionResources?
  module Filterable

    def self.extended(extender)
      Jamf.load_msg "--> #{extender} is extending Jamf::Filterable"
    end

    FILTER_PARAM_PREFIX = '&filter='.freeze

    # generate the RSQL filter to put into the url
    # This is callable from anywhere without mixing in.
    #
    # @param filter [String, nil] the filter to apply, or nil. If the
    #   filter starts with FILTER_PARAM_PREFIX, it is returned as-is,
    #   assuming it is already properly escaped.
    # @return [String] the filter to use in the URL, with FILTER_PARAM_PREFIX
    ##############################################
    def self.parse_url_filter_param(filter)
      return filter if filter.nil? || filter.start_with?(FILTER_PARAM_PREFIX)

      "#{FILTER_PARAM_PREFIX}#{CGI.escape filter}"
    end

    def filter_keys
      defined?(self::FILTER_KEYS) ? self::FILTER_KEYS : []
    end

  end # Filterable

end # Jamf
