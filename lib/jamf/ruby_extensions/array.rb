# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

require 'jamf/ruby_extensions/array/predicates'
require 'jamf/ruby_extensions/array/utils'

# an array
class Array

  include JamfRubyExtensions::Array::Predicates
  include JamfRubyExtensions::Array::Utils

end # class
