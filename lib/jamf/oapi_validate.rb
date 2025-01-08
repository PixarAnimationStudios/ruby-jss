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

  # A collection of methods implementing data constraints
  # as defined in the OAPI3 standard. See
  #
  # https://swagger.io/docs/specification/data-models/data-types/
  #
  # This module is extended into Jamf::Validate, where these become module
  # methods
  #
  # As with that module:
  # Some of these methods can take multiple input types, such as a String
  # or an number.  All of them will either raise an exception
  # if the value isn't valid, or will return a standardized form of the input
  # (e.g. a number, even if given a String)
  #
  # IMPORTANT - This module MUST be extended into Jamf::Validate.
  #
  module OAPIValidate

    # Validate that a value is valid based on its
    # definition in an objects OAPI_PROPERTIES constant.
    #
    # @param val [Object] The value to validate
    #
    # @param klass [Class, Symbol] The class which the val must be
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Boolean] the valid boolean
    #
    def oapi_attr(val, attr_def:, attr_name: nil)
      # check that the new val is not nil unless nil is OK
      val = not_nil(val, attr_name: attr_name) unless attr_def[:nil_ok]

      # if the new val is nil here, then nil is OK andd we shouldn't
      # check anything else
      return val if val.nil?

      val =
        case attr_def[:class]
        when :j_id
          Jamf::Validate.j_id value, attr_name: attr_name

        when Class
          class_instance val, klass: attr_def[:class], attr_name: attr_name

        when :boolean
          boolean val, attr_name: attr_name

        when :string
          fully_validate_string(val, attr_def: attr_def, attr_name: attr_name)

        when :integer
          fully_validate_integer(val, attr_def: attr_def, attr_name: attr_name)

        when :number
          fully_validate_number(val, attr_def: attr_def, attr_name: attr_name)

        when :hash
          hash val, attr_name: attr_name

        end # case

      # Now that the val is in whatever correct format after the above tests,
      # we test for enum membership if needed
      # otherwise, just return the val
      if attr_def[:enum]
        in_enum val, enum: attr_def[:enum], attr_name: attr_name
      else
        val
      end
    end

    # run all the possible validations on a string
    def fully_validate_string(val, attr_def:, attr_name: nil)
      val = string val, attr_name: attr_name

      min_length val, min: attr_def[:min_length], attr_name: attr_name if attr_def[:min_length]
      max_length val, max: attr_def[:max_length], attr_name: attr_name if attr_def[:max_length]
      matches_pattern val, attr_def[:pattern], attr_name: attr_name if attr_def[:pattern]

      val
    end

    # run all the possible validations on an integer
    def fully_validate_integer(val, attr_def:, attr_name: nil)
      val = integer val, attr_name: attr_name
      validate_numeric_constraints(val, attr_def: attr_def, attr_name: attr_name)
    end

    # run all the possible validations on a 'number'
    def fully_validate_number(val, attr_def:, attr_name: nil)
      val =
        if %w[float double].include? attr_def[:format]
          float val, attr_name: attr_name
        else
          number val, attr_name: attr_name
        end
      validate_numeric_constraints(val, attr_def: attr_def, attr_name: attr_name)
    end

    # run the numeric constraint validations for any numeric value
    # The number itself must already be validated
    def validate_numeric_constraints(val, attr_def:, attr_name: nil)
      ex_min = attr_def[:exclusive_minimum]
      ex_max = attr_def[:exclusive_maximum]
      mult_of = attr_def[:multiple_of]

      minimum val, min: attr_def[:minimum], exclusive: ex_min, attr_name: attr_name if attr_def[:minimum]
      maximum val, max: attr_def[:maximum], exclusive: ex_max, attr_name: attr_name if attr_def[:maximum]
      multiple_of val, multiplier: mult_of, attr_name: attr_name if mult_of

      val
    end

    # run the array constraint validations for an array value.
    # The individual array items  must already be validated
    def validate_array_constraints(val, attr_def:, attr_name: nil)
      min_items val, min: attr_def[:minItems], attr_name: attr_name if attr_def[:minItems]
      max_items val, max: attr_def[:maxItems], attr_name: attr_name if attr_def[:maxItems]
      unique_array val, attr_name: attr_name if attr_def[:uniqueItems]

      val
    end

    # validate that a value is of a specific class
    #
    # @param val [Object] The value to validate
    #
    # @param klass [Class, Symbol] The class which the val must be an instance of
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Object] the valid value
    #
    def class_instance(val, klass:, attr_name: nil, msg: nil)
      return val if val.instance_of? klass

      # try to instantiate the class with the value. It should raise an error
      # if not good
      klass.new val
    rescue => e
      raise_invalid_data_error(msg || "#{attr_name} value must be a #{klass}, or #{klass}.new must accept it as the only parameter, but #{klass}.new raised: #{e.class}: #{e}")
    end

    # Confirm that the given value is a boolean value, accepting
    # strings and symbols and returning real booleans as needed
    # Accepts: true, false, 'true', 'false', 'yes', 'no', 't','f', 'y', or 'n'
    # as strings or symbols, case insensitive
    #
    # TODO: use this throughout ruby-jss
    #
    # @param val [Boolean,String,Symbol] The value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Boolean] the valid boolean
    #
    def boolean(val, attr_name: nil, msg: nil)
      return val if Jamf::TRUE_FALSE.include? val
      return true if val.to_s =~ /^(t(rue)?|y(es)?)$/i
      return false if val.to_s =~ /^(f(alse)?|no?)$/i

      raise_invalid_data_error(msg || "#{attr_name} value must be boolean true or false, or an equivalent string or symbol")
    end

    # Confirm that a value is an number or a string representation of an
    # number. Return the number, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Integer]
    #
    def number(val, attr_name: nil, msg: nil)
      if val.ia_a?(Integer) || val.is_a?(Float)
        return val

      elsif val.is_a?(String)

        if val.j_integer?
          return val.to_i
        elsif val.j_float?
          return val.to_f
        end

      end

      raise_invalid_data_error(msg || "#{attr_name} value must be a number")
    end

    # Confirm that a value is an integer or a string representation of an
    # integer. Return the integer, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Integer]
    #
    def integer(val, attr_name: nil, msg: nil)
      val = val.to_i if val.is_a?(String) && val.j_integer?
      return val if val.is_a? Integer

      raise_invalid_data_error(msg || "#{attr_name} value must be an integer")
    end

    # Confirm that a value is a Float or a string representation of a Float
    # Return the Float, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Float]
    #
    def float(val, attr_name: nil, msg: nil)
      val = val.to_f if val.is_a?(Integer)
      val = val.to_f if val.is_a?(String) && (val.j_float? || val.j_integer?)
      return val if val.is_a? Float

      raise_invalid_data_error(msg || "#{attr_name} value must be an floating point number")
    end

    # Confirm that a value is a Hash
    # Return the Hash, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Hash]
    #
    def object(val, attr_name: nil, msg: nil)
      return val if val.is_a? Hash

      raise_invalid_data_error(msg || "#{attr_name} value must be a Hash")
    end

    # Confirm that a value is a String
    # Return the String, or raise an error
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @param to_s: [Boolean] If true, this method always succeds and returns
    #  the result of calling #to_s on the value
    #
    # @return [Hash]
    #
    def string(val, attr_name: nil, msg: nil, to_s: false)
      val = val.to_s if to_s
      return val if val.is_a? String

      raise_invalid_data_error(msg || "#{attr_name} value must be a String")
    end

    # validate that the given value is greater than or equal to some minimum
    #
    # If exclusive, the min value is excluded from the range and
    # the value must be greater than the min.
    #
    # While intended for Numbers, this will work for any Comparable objects
    #
    # @param val [Object] the thing to validate
    #
    # @param min [Object] A value that the val must be greater than or equal to
    #
    # @param exclusuve [Boolean] Should the min be excluded from the valid range?
    #   true: val must be > min, false: val must be >= min
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def minimum(val, min:, attr_name: nil, exclusive: false, msg: nil)
      if exclusive
        return val if val > min
      elsif val >= min
        return val
      end
      raise_invalid_data_error(msg || "#{attr_name} value must be >= #{min}")
    end

    # validate that the given value is less than or equal to some maximum
    #
    # While intended for Numbers, this will work for any Comparable objects
    #
    # If exclusive, the max value is excluded from the range and
    # the value must be less than the max.
    #
    # @param val [Object] the thing to validate
    #
    # @param max[Object] A value that the val must be less than or equal to
    #
    # @param exclusuve [Boolean] Should the max be excluded from the valid range?
    #   true: val must be < max, false: val must be <= max
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def maximum(val, max:, attr_name: nil, exclusive: false, msg: nil)
      if exclusive
        return val if val < max
      elsif val <= max
        return val
      end
      raise_invalid_data_error(msg || "#{attr_name} value must be <= #{max}")
    end

    # Validate that a given number is multiple of some other given number
    #
    # @param val [Number] the number to validate
    #
    # @param multiplier [Number] the number what the val must be a multiple of.
    #   this must be positive.
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def multiple_of(val, multiplier:, attr_name: nil, msg: nil)
      raise ArgumentError, 'multiplier must be a positive number' unless multiplier.is_a?(Numeric) && multiplier.positive?
      raise Jamf::InvalidDataError, 'Value must be a number' unless val.is_a?(Numeric)

      return val if (val % multiplier).zero?

      raise_invalid_data_error(msg || "#{attr_name} value must be a multiple of #{multiplier}")
    end

    # validate that the given value's length is greater than or equal to some minimum
    #
    # While this is intended for Strings, it will work for any object that responds
    # to #length
    #
    # @param val [Object] the value to validate
    #
    # @param min [Object] The minimum length allowed
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def min_length(val, min:, attr_name: nil, msg: nil)
      raise ArgumentError, 'min must be a number' unless min.is_a?(Numeric)
      return val if val.length >= min

      raise_invalid_data_error(msg || "length of #{attr_name} value must be >= #{min}")
    end

    # validate that the given value's length is less than or equal to some maximum
    #
    # While this is intended for Strings, it will work for any object that responds
    # to #length
    #
    # @param val [Object] the value to validate
    #
    # @param max [Object] the maximum length allowed
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def max_length(val, max:, attr_name: nil, msg: nil)
      raise ArgumentError, 'max must be a number' unless max.is_a?(Numeric)
      return val if val.length <= max

      raise_invalid_data_error(msg || "length of #{attr_name} value must be <= #{max}")
    end

    # validate that the given value contains at least some minimum number of items
    #
    # While this is intended for Arrays, it will work for any object that responds
    # to #size
    #
    # @param val [Object] the value to validate
    #
    # @param min [Object] the minimum number of items allowed
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def min_items(val, min:, attr_name: nil, msg: nil)
      raise ArgumentError, 'min must be a number' unless min.is_a?(Numeric)
      return val if val.size >= min

      raise_invalid_data_error(msg || "#{attr_name} value must contain at least #{min} items")
    end

    # validate that the given value contains no more than some maximum number of items
    #
    # While this is intended for Arrays, it will work for any object that responds
    # to #size
    #
    # @param val [Object] the value to validate
    #
    # @param max [Object] the maximum number of items allowed
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @return [String] the valid value
    #
    def max_items(val, max:, attr_name: nil, msg: nil)
      raise ArgumentError, 'max must be a number' unless max.is_a?(Numeric)
      return val if val.size <= max

      raise_invalid_data_error(msg || "#{attr_name} value must contain no more than #{max} items")
    end

    # validate that an array has only unique items, no duplicate values
    #
    # @param val [Array] The array to validate
    #
    # @param msg [String] A custom error message when the value is invalid
    #
    # @param return [Array] the valid array
    #
    def unique_array(val, attr_name: nil, msg: nil)
      raise ArgumentError, 'Value must be an Array' unless val.is_a?(Array)
      return val if val.uniq.size == val.size

      raise_invalid_data_error(msg || "#{attr_name} value must contain only unique items")
    end

    # validate that a value is not nil
    #
    # @param val[Object] the value to validate
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Object] the valid value
    #
    def not_nil(val, attr_name: nil, msg: nil)
      return val unless val.nil?

      raise_invalid_data_error(msg || "#{attr_name} value may not be nil")
    end

    # Does a value exist in a given enum array?
    #
    # @param val [Object] The thing that must be in the enum
    #
    # @param enum [Array] the enum of allowed values
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Object] The valid object
    #
    def in_enum(val, enum:, attr_name: nil, msg: nil)
      return val if  enum.include? val

      raise_invalid_data_error(msg || "#{attr_name} value must be one of: #{enum.join ', '}")
    end

    # Does a string match a given regular expression?
    #
    # @param val [String] The value to match
    #
    # @param pattern [pattern] the regular expression
    #
    # @param msg[String] A custom error message when the value is invalid
    #
    # @return [Object] The valid object
    #
    def matches_pattern(val, pattern:, attr_name: nil, msg: nil)
      return val if val =~ pattern

      raise_invalid_data_error(msg || "#{attr_name} value does not match RegExp: #{pattern}")
    end

  end # module oapi validate

end # module Jamf
