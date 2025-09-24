# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module JamfRubyExtensions

  module Pathname

    module Predicates

      # Is this a real file rather than a symlink?
      # @see FileTest.real_file
      def j_real_file?
        FileTest.real_file? self
      end # real_file?
      alias jss_real_file? j_real_file?

      # does a path include another?
      # i.e. is 'other' a descendant of self ?
      def j_include?(other)
        eps = expand_path.to_s
        oeps = other.expand_path.to_s
        oeps != eps && oeps.start_with?(eps)
      end
      alias jss_include? j_include?

    end # module

  end # module

end # module
