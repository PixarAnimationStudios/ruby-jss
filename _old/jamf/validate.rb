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
    MAC_ADDR_RE = /^[a-f0-9]{2}(:[a-f0-9]{2}){5}$/i.freeze

    # Validate the format and content of a MAC address
    #
    # @param val[String] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] The valid value
    #
    def self.mac_address(val, msg = nil)
      msg ||= "Not a valid MAC address: '#{val}'"
      raise Jamf::InvalidDataError, msg unless val =~ MAC_ADDR_RE

      val
    end

    # Validate the format and content of an IPv4 address
    #
    # @param val[String] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] The valid value
    #
    def self.ip_address(val, msg = nil)
      msg ||= "Not a valid IPv4 address: '#{val}'"
      ok = true
      parts = val.strip.split '.'
      ok = false unless parts.size == 4
      parts.each { |p| ok = false unless p.j_integer? && p.to_i < 256 && p.to_i >= 0 }
      raise Jamf::InvalidDataError, msg unless ok

      val
    end



    # Validate that a value doesn't already exist for a given identifier of
    # a given CollectionResource class
    #
    # e.g. when klass = Jamf::Computer, identifier = :name, and val = 'foo'
    # will raise an error when a computer named 'foo' already exists
    #
    # Otherwise returns val.
    #
    # @param val[Object] The value to check for uniqueness
    #
    # @param klass[Jamf::CollectionResource] A descendent of Jamf::CollectionResource, e.g. Jamf::Computer
    #
    # @param identifier[Symbol] One of the values of klass.identifiers
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @param cnx[Jamf::Connection] The api connection to use for validation
    #
    # @return [Object] the validated unique value
    #
    def self.doesnt_exist(val, klass, identifier, msg = nil, cnx: Jamf.cnx)
      msg ||= "A #{klass} already exists with #{identifier} '#{val}'"

      raise Jamf::InvalidDataError, "No identifier '#{identifier}' for #{klass}" unless klass.identifiers.include? identifier

      return val unless klass.send("all_#{identifier}s", :refresh, cnx: cnx).include? val

      raise Jamf::AlreadyExistsError, msg
    end

    TRUE_FALSE = [true, false].freeze

    # Confirm that the given value is a boolean value, accepting
    # strings and symbols and returning real booleans as needed
    # Accepts: true, false, 'true', 'false', 'yes', 'no', 't','f', 'y', or 'n'
    # as strings or symbols, case insensitive
    #
    # @param val [Boolean,String,Symbol] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Boolean] the valid boolean
    #
    def self.boolean(val, msg = 'Value must be true or false, or equivalent string or symbol')
      return val if TRUE_FALSE.include? val
      return true if val.to_s =~ /^(t(rue)?|y(es)?)$/i
      return false if val.to_s =~ /^(f(alse)?|no?)$/i

      raise Jamf::InvalidDataError, msg
    end

    # Confirm that a value provided is an integer or a string version
    # of an integer, and return the string version
    #
    # The JPAPI specs say that all IDs are integers in strings
    # tho, the endpoints are still implementing that in different versions.
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid integer-in-a-string
    #
    def self.j_id(val, msg = 'Value must be an Integer or an Integer in a String, e.g. "42"')
      case val
      when Integer
        return val.to_s
      when String
        return val if val.j_integer?
      end
      raise Jamf::InvalidDataError, msg
    end

    # Confirm that a value is an Integer or a String representation of an
    # Integer. Return the integer, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Integer] the valid integer
    #
    def self.integer(val, msg = 'Value must be an Integer')
      val = val.to_i if val.is_a?(String) && val.j_integer?
      raise Jamf::InvalidDataError, msg unless val.is_a? Integer

      val
    end

    # Confirm that a value is a Float or a String representation of a Float.
    # Return the Float, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Float] the valid float
    #
    def self.float(val, msg = 'Value must be a Floating Point number')
      val = val.to_f if val.is_a?(String) && val.j_float?
      raise Jamf::InvalidDataError, msg unless val.is_a? Float

      val
    end

    # Confirm that a value is a string, symbol, or nil,
    # all of which will be returned as a string
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid String
    #
    def self.string(val, msg = 'Value must be a String')
      return Jamf::BLANK if val.nil?

      val = val.to_s if val.is_a? Symbol
      raise Jamf::InvalidDataError, msg unless val.is_a? String

      val
    end

    # validate that the given value is a non-empty string
    # Symbols are accepted and returned as strings
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid non-empty string
    #
    def self.non_empty_string(val, msg = 'value must be a non-empty String')
      val = val.to_s if val.is_a? Symbol
      raise Jamf::InvalidDataError, msg unless val.is_a?(String) && !val.empty?

      val
    end

    SCRIPT_SHEBANG = '#!'.freeze

    # validate that the given value is a string that starts with #!
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the validated string
    #
    def self.script_contents(val, msg = "value must be a String starting with '#!'")
      raise Jamf::InvalidDataError, msg unless val.is_a?(String) && val.start_with?(SCRIPT_SHEBANG)

      val
    end

  end # module validate

end # module JSS
