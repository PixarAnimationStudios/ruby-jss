# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

require 'jamf/ruby_extensions/string/conversions'
require 'jamf/ruby_extensions/string/predicates'

# include the modules loaded above
class String

  include JamfRubyExtensions::String::Predicates
  include JamfRubyExtensions::String::Conversions

end
