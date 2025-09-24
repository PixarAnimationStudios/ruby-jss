# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module Jamf

  # Module for containing the different types of DirectoryBindings stored within the JSS
  module DirectoryBindingType

    # Module Variables
    #####################################

    # Module Methods
    #####################################
    def should_update
      @need_to_update = true
    end

    def set_type_settings(settings)
      @type_settings = settings
      @type_settings.container = self
    end

  end

end
