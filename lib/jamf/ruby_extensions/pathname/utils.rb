# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

module JamfRubyExtensions

  module Pathname

    module Utils

      # Copy a path to a destination
      # @see FileUtils.cp
      def j_cp(dest, **options)
        FileUtils.cp @path, dest.to_s, **options
      end # cp
      alias jss_cp j_cp

      # Recursively copy this path to a destination
      # @see FileUtils.cp_r
      def j_cp_r(dest, **options)
        FileUtils.cp_r @path, dest.to_s, **options
      end # cp
      alias jss_cp_r j_cp_r

      # Write some string content to a file.
      #
      # Simpler than always using an open('w') block
      # *CAUTION* this overwrites files!
      #
      def j_save(content)
        self.open('w') { |f| f.write content.to_s }
      end
      alias jss_save j_save

      # Append some string content to a file.
      #
      # Simpler than always using an open('a') block
      #
      def j_append(content)
        self.open('a') { |f| f.write content.to_s }
      end
      alias jss_append j_append

      # Touching can sometimes be good
      #
      # @see FileUtils.touch
      def j_touch
        FileUtils.touch @path
      end
      alias jss_touch j_touch

      # Pathname should use FileUtils.chown, not File.chown
      def j_chown(usr, grp)
        FileUtils.chown usr, grp, @path
      end
      alias jss_chown j_chown

    end # module

  end # module

end # module
