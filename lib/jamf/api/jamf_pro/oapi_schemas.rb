# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
