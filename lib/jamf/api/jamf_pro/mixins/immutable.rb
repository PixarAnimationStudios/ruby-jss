# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # When extended with this mixin, OAPIObject.mutable? returns false,
  # meaning that no setters are ever defined, #save will raise an error
  #
  module Immutable

    def self.extended(extender)
      Jamf.load_msg "--> #{extender} is extending Jamf::Immutable"
    end

  end # Immutable

end # Jamf
