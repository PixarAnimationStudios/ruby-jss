# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module Jamf

  # Module for containing the different types of DirectoryBindings stored within the JSS
  module DirectoryBindingType

    # Classes
    #####################################

    # A generic binding type class that sets common variables, methods, and constructors
    # for all the different directory binding types.
    #
    # @author Tyler Morgan
    class DirectoryBindingType

      # Mix-Ins
      #####################################

      # Class Methods
      #####################################

      # Class Constants
      #####################################

      # The different network protocols supported.
      NETWORK_PROTOCOL = {
        afp: 'AFP',
        smb: 'SMB'
      }.freeze

      # The different home folder types.
      HOME_FOLDER_TYPE = {
        network: 'Network',
        local: 'Local',
        either: 'Either',
        mobile: 'Mobile'
      }.freeze

      # Attributes
      #####################################

      # This is used to properly handle updating the containing object.
      attr_accessor :container

    end

  end

end
