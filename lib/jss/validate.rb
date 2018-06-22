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

    # Confirm that the given value is a boolean value, accepting
    # strings and symbols and returning real booleans as needed
    # Accepts: true, false, 'true', 'false', :true, :false, 'yes', 'no', :yes,
    # or :no (all Strings and Symbols are case insensitive)
    #
    # TODO: use this throughout ruby-jss
    #
    # @param bool [Boolean,String,Symbol] The value to validate
    #
    # @return [Boolean] the valid boolean
    #
    def self.boolean(bool)
      return bool if JSS::TRUE_FALSE.include? bool
      return true if bool.to_s =~ /^(true|yes)$/i
      return false if bool.to_s =~ /^(false|no)$/i
      raise JSS::InvalidDataError, 'Value must be boolean true or false'
    end

    # Confirm that a value is an integer or a string representation of an
    # integer. Return the integer, or raise an error
    #
    # TODO: use this throughout ruby-jss
    #
    # @param val[Object] the value to validate
    #
    # @return [void]
    #
    def self.integer(val)
      val = val.to_i if val.is_a? String && val.jss_integer?
      raise JSS::InvalidDataError, 'Value must be an integer' unless val.is_a? Integer
      val
    end

  end # module validate

end # module JSS
