# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module JamfRubyExtensions

  module FileTest

    module Predicates

      # FileTest.file? returns true if
      # the item is a symlink pointing to a regular file.
      #
      # This test, real_file?, returns true if the item is
      # a regular file but NOT a symlink.
      #
      def j_real_file?(path)
        FileTest.file?(path) && !FileTest.symlink?(path)
      end # real_file?
      alias jss_real_file? j_real_file?

    end # module

  end # module

end # module
