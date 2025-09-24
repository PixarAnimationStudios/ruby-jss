# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

############################################
# Some handy additions to the Pathname class.
# Why aren't they there already?

require 'jamf/ruby_extensions/pathname/utils'
require 'jamf/ruby_extensions/pathname/predicates'

# include the modules loaded above
class Pathname

  include JamfRubyExtensions::Pathname::Predicates
  include JamfRubyExtensions::Pathname::Utils

end
