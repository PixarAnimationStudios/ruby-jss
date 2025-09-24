# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # This mixin overrides CollectionResource.deletable? to return false,
  # meaning that CollectionResource.delete and #delete will raise an exception
  # It should be extended into subclasses of CollectionResource
  #
  # Note that SingletonResource subclasses are never deletable
  module Undeletable

    def deletable?
      false
    end

  end # Lockable

end # Jamf
