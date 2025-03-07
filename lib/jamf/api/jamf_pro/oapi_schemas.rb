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

# The module
module Jamf

  # This module is the namespace for all JP API objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  # The classes in this module are the Ruby representations of the
  # JSON schema objects (Hashes) in the Jamf Pro OAPI schema
  #
  # Each class is created from the JSON Object definition and other
  # schema data, such as required attributes, the class or type of each
  # attribute (which could be another OAPI object), and any enumurated
  # values for attributes.
  # The classes are all subclasses of Jamf::OAPIObject, which defines
  # common methods for all OAPI objects, such as converting to and from
  # JSON, and validating attribute values.
  #
  # These clases are used in various ways in ruby-jss:
  # - As the value of an attribute in another OAPI object
  # - As the parent class for a Jamf Pro API Resource class
  # - As a representation of a JSON objects sent to or received from the API
  #   (e.g. in a POST or PUT request)
  #
  # They are mostly generated automatically using the 'generate_object_models'
  # executable in the 'bin' directory of ruby-jss. After generation the files needed
  # are manually edited to add any needed functionality or clarifications of names
  # etc, and then they are moved into the 'jamf/api/jamf_pro/oapi_schemas' directory.
  #
  #####################################
  module OAPISchemas

  end # module OAPISchemas

end # module Jamf
