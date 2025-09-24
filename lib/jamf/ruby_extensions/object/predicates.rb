# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module JamfRubyExtensions

  module Object

    module Predicates

      # is an object an explict true or false?
      #
      # TODO: globally replace
      #      `JSS::TRUE_FALSE.include? xxx`
      #   with
      #      `xxx.j_boolean?`
      #
      #
      # @return [Boolean]
      #
      def j_boolean?
        [true, false].include? self
      end
      alias j_bool? j_boolean?
      alias jss_boolean? j_boolean?
      alias jss_bool? j_boolean?

    end # module

  end # module

end # module
