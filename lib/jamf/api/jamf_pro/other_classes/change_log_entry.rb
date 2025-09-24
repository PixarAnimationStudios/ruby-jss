# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# The module
module Jamf

  # A wrapper around Jamf::OAPISchemas::ObjectHistoryV1 to make it
  # immutable
  class ChangeLogEntry < Jamf::OAPISchemas::ObjectHistoryV1

    extend Jamf::Immutable

  end # class ChangeLogEntry

end # module
