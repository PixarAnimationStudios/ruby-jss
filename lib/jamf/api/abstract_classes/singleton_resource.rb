# Copyright 2019 Pixar

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

# The module
module Jamf

  # Classes
  #####################################

  # A Singleton Resource in the API.
  #
  # See {Jamf::Resource} for details and required constants
  #
  # @abstract
  #
  class SingletonResource < Jamf::Resource

    extend Jamf::Abstract

    # Public Class Methods
    #####################################

    # Return a SingletonResource from the API, from the cache if already cached
    # or retrieving from the API and caching it if neededl
    #
    # @param reload[Boolean] If already cached, re-cache from the API.
    #   WARNING: unsaved changes will be lost.
    #
    # @param version[String] the API resource version to use.
    #   Defaults to the RSRC_VERSION for the class.
    #
    # @param cnx[Jamf::Connection] The API connection to use
    #
    # @return [Jamf::SingletonResource] The ruby-instance of a Jamf resource
    #
    def self.fetch(reload = false, cnx: Jamf.cnx)
      cnx.singleton_cache[self] = nil if reload
      cached = cnx.singleton_cache[self]
      return cached if cached

      data = cnx.get "#{self::RSRC_VERSION}/#{self::RSRC_PATH}"
      cnx.singleton_cache[self] = new data, cnx: cnx
    end # fetch

    def self.flushcache(cnx: Jamf.cnx)
      validate_not_abstract
      cnx.singleton_cache[self] = nil
    end

    # Instance Methods
    #####################################

    # only have one path
    def rsrc_path
      self.class.rsrc_path
    end

    # singltons always exist
    def exist?
      true
    end

  end # class APIObject

end # module JAMF
