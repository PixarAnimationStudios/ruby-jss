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
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] The valid value
    #
    def self.mac_address(val, msg = nil)
      msg ||= "Not a valid MAC address: '#{val}'"
      raise Jamf::InvalidDataError, msg unless val =~ MAC_ADDR_RE

      val
    end

    # Segments of a valid IPv4 address are integers in this range.
    IP_SEGMENT_RANGE = 0..255

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
      parts.each { |p| ok = false unless p.jss_integer? && IP_SEGMENT_RANGE.cover?(p.to_i) }
      raise Jamf::InvalidDataError, msg unless ok

      val
    end

    # Does a given JSONObject class have a given JSON attribute?
    #
    # @param klass [<JSONObject] A class descended from JSONObject
    #
    # @param attr_name [Symbol] The attribute to validate
    #
    # @return [Symbol] The valid attribute
    #
    def self.json_attribute_name(klass, attr_name)
      raise "#{klass} is not a descendent of JSONObject" unless klass < Jamf::JSONObject

      raise Jamf::NoSuchItemError, "No attribute #{attr_name} for class #{klass}" unless klass::OBJECT_MODEL.key? attrib

      attr_name
    end

    # Does a value exist in a given enum array?
    #
    # @param klass [<JSONObject] A class descended from JSONObject
    #
    # @param attr_name [Symbol] The attribute to validate
    #
    # @return [Symbol] The valid attribute
    #
    def self.in_enum(val, enum)
      raise Jamf::InvalidDataError, "Value must be one of: #{enum.join ', '}" unless enum.include? val

      val
    end

    # Validate that a value doesn't already exist for a given identifier of a
    # given class
    #
    # e.g. when klass = Jamf::Computer, identifier = :name, and val = 'foo'
    # will raise an error when a computer named 'foo' exists
    #
    # Otherwise returns val.
    #
    # @param klass[Jamf::APIObject] A subclass of Jamf::APIObject, e.g. Jamf::Computer
    #
    # @param identifier[Symbol] One of the keys of an Item of the class's #all Array
    #
    # @param val[Object] The value to check for uniqueness
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @param api[Jamf::Connection] The api connection to use for validation
    #
    # @return [Object] the validated unique value
    #
    def self.doesnt_already_exist(klass, identifier, val, msg = nil, api: JSS.api)
      msg ||= "A #{klass} already exists with #{identifier} '#{val}'"
      return val unless klass.all(:refresh, api: api).map { |i| i[identifier] }.include? val

      key = klass.real_lookup_key identifier

      # use map_all_ids_to cuz it works with any identifer, even non-existing
      existing_values = klass.map_all_ids_to( key, api: api).values
      matches = existing_values.select { |existing_val| existing_val.casecmp? val }
      return val if matches.empty?

      raise Jamf::AlreadyExistsError, msg
    end

    # Confirm that the given value is a boolean value, accepting
    # strings and symbols and returning real booleans as needed
    # Accepts: true, false, 'true', 'false', 'yes', 'no', 't','f', 'y', or 'n'
    # as strings or symbols, case insensitive
    #
    # TODO: use this throughout ruby-jss
    #
    # @param bool [Boolean,String,Symbol] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Boolean] the valid boolean
    #
    def self.boolean(bool, msg = nil)
      return bool if Jamf::TRUE_FALSE.include? bool
      return true if boolw.to_s =~ /^(t(rue)?|y(es)?)$/i
      return false if bool.to_s =~ /^(f(alse)?|no?)$/i

      msg ||= 'Value must be boolean true or false, or an equivalent string or symbol'
      raise Jamf::InvalidDataError, msg
    end

    # Confirm that a value is an integer or a string representation of an
    # integer. Return the integer, or raise an error
    #
    # TODO: use this throughout ruby-jss
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [void]
    #
    def self.integer(val, msg = nil)
      msg ||= 'Value must be an integer'
      val = val.to_i if val.is_a?(String) && val.jss_integer?
      raise Jamf::InvalidDataError, msg unless val.is_a? Integer

      val
    end

    # validate that the given value is a non-empty string
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid non-empty string
    #
    def self.non_empty_string(val, msg = nil)
      msg ||= 'value must be a non-empty String'
      raise Jamf::InvalidDataError, msg unless val.is_a?(String) && !val.empty?

      val
    end

    UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.freeze

    # validate that the given value is a valid uuid string
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid uuid string
    #
    def self.uuid(val, msg = nil)
      return val if val.is_a?(String) && val =~ UUID_RE

      msg ||= 'value must be valid uuid'
      raise Jamf::InvalidDataError, msg
    end

    # validate that the given value is an integer in the Jamf::IBeacon::MAJOR_MINOR_RANGE
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid integer
    #
    def self.ibeacon_major_minor(val, msg = nil)
      val = val.to_i if val.is_a?(String) && val.jss_integer?
      ok = val.is_a? Integer
      ok = Jamf::IBeacon::MAJOR_MINOR_RANGE.include? val if ok
      return val if ok

      msg ||= "value must be an integer in the range #{Jamf::IBeacon::MAJOR_MINOR_RANGE}"
      raise Jamf::InvalidDataError, msg unless ok
    end

    # validate a country name or code from Jamf::APP_STORE_COUNTRY_CODES
    # returning the validated code, or raising an error
    #
    # @param country[String] The country name or code
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid two-letter country code
    #
    def self.app_store_country_code(country, msg = nil)
      country = country.to_s.upcase
      return country if Jamf::APP_STORE_COUNTRY_CODES.value? country

      Jamf::APP_STORE_COUNTRY_CODES.each do |name, code|
        return code if name.upcase == country
      end

      msg ||= 'Unknown country name or code. See Jamf::APP_STORE_COUNTRY_CODES or JSS.country_code_match(str)'
      raise Jamf::InvalidDataError, msg
    end

    # validate an email address - must match the RegEx /^\S+@\S+\.\S+$/
    # i.e.:
    #  1 or more non-whitespace chars, followed by
    #  an @ character, followed by
    #  1 or more non-whitespace chars, followed by
    #  a dot, followed by
    #  1 or more non-whitespace chars
    #
    # @param email[String] The email address
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the validly formatted email address
    #
    def self.email_address(email, msg = nil)
      msg ||= "'#{email}' is not formatted as a valid email address"
      email = email.to_s
      return email if email =~ /^\S+@\S+\.\S+$/

      raise Jamf::InvalidDataError, msg
    end

  end # module validate

end # module Jamf
