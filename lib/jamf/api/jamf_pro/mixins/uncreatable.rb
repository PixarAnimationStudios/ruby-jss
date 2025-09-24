# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # This mixin overrides CollectionResource.creatable? to return false,
  # meaning that CollectionResource.create will raise an exception
  # It should be extended into appropriate subclasses of CollectionResource
  #
  # Note that SingletonResource subclasses are never creatable
  module Uncreatable

    def creatable?
      false
    end

  end # Lockable

end # Jamf
