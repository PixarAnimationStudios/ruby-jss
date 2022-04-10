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

  # A collection of methods for validating values.
  #
  # Some of these methods can take multiple input types, such as a String
  # or an Array.  All of them will either raise an exception
  # if the value isn't valid, or will return a standardized form of the input
  # (e.g. an Array, even if given a String)
  #
  module Validate

    # Raise an invalid data error
    def self.raise_invalid_data_error(msg)
      raise Jamf::InvalidDataError, msg.strip
    end

    extend Jamf::OAPIValidate

    # The regular expression that matches a valid MAC address.
    MAC_ADDR_RE = /^[a-f0-9]{2}(:[a-f0-9]{2}){5}$/i.freeze

    # The Regexp that matches a valid IPv4 address
    IPV4_ADDR_RE = /^((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(\.|$)){4}/.freeze

    # the regular expression that matches a valid UDID/UUID
    UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.freeze

    # Validate the format and content of a MAC address
    #
    # @param val[String] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] The valid value
    #
    def self.mac_address(val, msg: nil)
      return val if val =~ MAC_ADDR_RE

      raise_invalid_data_error(msg || "Not a valid MAC address: '#{val}'")
    end

    # Validate the format and content of an IPv4 address
    #
    # @param val[String] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] The valid value
    #
    def self.ip_address(val, msg: nil)
      val = val.strip
      return val if val =~ IPV4_ADDR_RE

      raise_invalid_data_error(msg || "Not a valid IPv4 address: '#{val}'")
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
    def self.doesnt_already_exist(klass, identifier, val, msg: nil, api: Jamf.cnx)
      return val unless klass.all(:refresh, api: api).map { |i| i[identifier] }.include? val

      key = klass.real_lookup_key identifier

      # use map_all_ids_to cuz it works with any identifer, even non-existing
      existing_values = klass.map_all_ids_to(key, api: api).values
      matches = existing_values.select { |existing_val| existing_val.casecmp? val }
      return val if matches.empty?

      raise_invalid_data_error(msg || "A #{klass} already exists with #{identifier} '#{val}'")
    end

    # validate that the given value is a non-empty string
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid non-empty string
    #
    def self.non_empty_string(val, attr_name: nil, msg: nil)
      return val if val.is_a?(String) && !val.empty?

      raise_invalid_data_error(msg || "#{attr_name} value must be a non-empty String")
    end

    # Confirm that a value provided is an integer or a string version
    # of an integer, and return the string version
    #
    # The JPAPI specs say that all IDs are integers in strings
    # tho, some endpoints are still using actual integers.
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid integer-in-a-string
    #
    def self.j_id(val, attr_name: nil, msg: nil)
      case val
      when Integer
        return val.to_s
      when String
        return val if val.j_integer?
      end
      raise_invalid_data_error(msg || "#{attr_name} value must be an Integer or an Integer in a String, e.g. \"42\"")
    end

    # validate that the given value is a valid uuid string
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid uuid string
    #
    def self.uuid(val, msg: nil)
      return val if val.is_a?(String) && val =~ UUID_RE

      raise_invalid_data_error(msg || 'value must be valid uuid')
    end

    # validate that the given value is an integer in the Jamf::IBeacon::MAJOR_MINOR_RANGE
    #
    # @param val [Object] the thing to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid integer
    #
    def self.ibeacon_major_minor(val, msg: nil)
      val = val.to_i if val.is_a?(String) && val.jss_integer?
      ok = val.is_a? Integer
      ok = Jamf::IBeacon::MAJOR_MINOR_RANGE.include? val if ok
      return val if ok

      raise_invalid_data_error(msg || "value must be an integer in the range #{Jamf::IBeacon::MAJOR_MINOR_RANGE}")
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
    def self.app_store_country_code(country, msg: nil)
      country = country.to_s.upcase
      return country if Jamf::APP_STORE_COUNTRY_CODES.value? country

      Jamf::APP_STORE_COUNTRY_CODES.each do |name, code|
        return code if name.upcase == country
      end

      raise_invalid_data_error(msg || "Unknown country name or code '#{country}'. See Jamf::APP_STORE_COUNTRY_CODES or JSS.country_code_match(str)")
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
    def self.email_address(email, msg: nil)
      email = email.to_s
      return email if email =~ /^\S+@\S+\.\S+$/

      raise_invalid_data_error(msg || "'#{email}' is not formatted as a valid email address")
    end

  end # module validate

end # module Jamf
