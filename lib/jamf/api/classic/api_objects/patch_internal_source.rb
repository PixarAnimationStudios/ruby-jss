# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # An 'Internal' patch source. These sources are defined by
  # Jamf themselves, as a part of the JSS, and cannot be created, modified
  #  or deleted.
  #
  # @see Jamf::APIObject
  #
  class PatchInternalSource < Jamf::PatchSource

    # Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'patchinternalsources'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :patch_internal_sources

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :patch_internal_source

  end # class PatchInternalSource

end # module Jamf
