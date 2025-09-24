# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module JamfRubyExtensions

  module String

    module Predicates

      INTEGER_RE = /\A-?[0-9]+\Z/.freeze
      FLOAT_RE = /\A-?[0-9]+\.[0-9]+\Z/.freeze

      # Is this string also an integer?
      # (i.e. it consists only of numberic digits, maybe with a dash in front)
      #
      # @return [Boolean]
      #
      def j_integer?
        self =~ INTEGER_RE ? true : false
      end
      alias jss_integer? j_integer?

      # Is this string also a floar?
      # (i.e. it consists only of numberic digits)
      #
      # @return [Boolean]
      #
      def j_float?
        self =~ FLOAT_RE ? true : false
      end
      alias jss_float? j_float?

    end # module

  end # module

end # module
