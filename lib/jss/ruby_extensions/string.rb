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
class String

  # Convert the strings "true" and "false"
  # (after stripping whitespace and downcasing)
  # to TrueClass and FalseClass respectively
  #
  # Return nil if any other string.
  #
  # @return [Boolean,nil] the boolean value
  #
  def jss_to_bool
    case strip.downcase
    when 'true' then true
    when 'false' then false
    end # case
  end # to bool

  # Convert a string to a Time object
  #
  # returns nil if not parsable by JSS::parse_datetime
  #
  # @return [Time] the time represented by the string.
  #
  def jss_to_time
    JSS.parse_time self
  rescue
    return nil
  end

  # Convert a String to a Pathname object
  #
  # @return [Pathname]
  #
  def jss_to_pathname
    Pathname.new self
  end

  # Is this string also a positive integer?
  # (i.e. it consists only of numberic digits)
  #
  # @return [Boolean]
  #
  def jss_integer?
    self =~ /\A[0-9]+\Z/ ? true : false
  end

end # class
