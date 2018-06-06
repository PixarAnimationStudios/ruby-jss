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

  # A collection of methods for validating values. Mostly for
  # ensuring the validity of data being set as attributes of APIObject
  # subclass instances.
  #
  # Some of these methods can take multiple input types, such as a String
  # or an Array.  All of them will either raise an exception
  # if the value isn't valid, or will return a standardized form of the input
  # (e.g. an Array, even if given a String)
  #
  module Validate

    # The regular expression that matches a valid MAC address.
    MAC_ADDR_RE = /^[a-f0-9]{2}(:[a-f0-9]{2}){5}$/i

    # Validate the format and content of a MAC address
    #
    # @param val[String] The value to validate
    #
    # @return [String] The valid value
    #
    def self.mac_address(val)
      raise JSS::InvalidDataError, "Not a valid MAC address: '#{val}'" unless val =~ MAC_ADDR_RE
      val
    end

    # Validate the format and content of an IPv4 address
    #
    # @param val[String] The value to validate
    #
    # @return [String] The valid value
    #
    def self.ip_address(val)
      ok = true
      parts = val.strip.split '.'
      ok = false unless parts.size == 4
      parts.each { |p| ok = false unless p.jss_integer? && p.to_i < 256 }
      raise JSS::InvalidDataError, "Not a valid IPv4 address: '#{val}'" unless ok
      val
    end

    # Validate that a value doesn't already exist for a given identifier of a given class
    #
    # @param klass[JSS::APIObject] A subclass of JSS::APIObject, e.g. JSS::Computer
    #
    # @param identifier[Symbol] One of the keys of an Item of the class's #all Array
    #
    # @param val[Object] The value to check for uniqueness
    #
    # @return [Object] the validated unique value
    #
    def self.unique_identifier(klass, identifier, val, api: JSS.api)
      raise JSS::AlreadyExistsError, "A #{klass} already exists with #{identifier} '#{val}'" if klass.all(:refresh, api: api).map { |i| i[identifier] }.include? val
      val
    end

    # Raise exception if a value is neither boolean true or boolean false
    #
    # TODO: use this throughout.
    #
    # @param val[Object] the value to validate
    #
    # @return [void]
    #
    def self.boolean(val)
      raise JSS::InvalidDataError, 'Value must be Boolean true or false' unless JSS::TRUE_FALSE.include? val
    end

    # Raise exception if a value is neither boolean true or boolean false
    #
    # TODO: use this throughout.
    #
    # @param val[Object] the value to validate
    #
    # @return [void]
    #
    def self.integer(val)
      raise JSS::InvalidDataError, 'Value must be an integer' unless val.is_a? Integer
    end

  end # module validate

end # module JSS
