# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# The Module
module Jamf

  # In the Jamf Pro Web UI, API Clients are called just that "API Clients", so
  # they are defined as the Jamf::APIClient class.
  #
  # But in the Jamf Pro API, they are referred to as API Integrations, and their
  # resource paths are `v1/api-integrations`
  # So, this class is just an alias of APIClient

  APIIntegration = APIClient

end # module
