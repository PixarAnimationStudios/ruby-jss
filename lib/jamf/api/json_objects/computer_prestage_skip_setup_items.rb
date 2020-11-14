# Copyright 2020 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# The module
module Jamf

  # The 'skip Setup Items' for a computer prestage in Jamf Pro
  # The ones in common with Mobile Devices are in the superclass
  # To see the ones that should be here, remove anything that's in
  # mobile device's list from the computer ones, thus:
  #
  # > Jamf::ComputerPrestage.all.sample[:skipSetupItems].keys - Jamf::MobileDevicePrestage.all.sample[:skipSetupItems].keys
  #  => [:FileVault, :iCloudDiagnostics, :Accessibility, :Registration, :iCloudStorage]
  class ComputerPrestageSkipSetupItems < Jamf::PrestageSkipSetupItems

    OBJECT_MODEL = superclass::OBJECT_MODEL.merge(

      # @!attribute FileVault
      #   @return [Boolean]
      FileVault: {
        class: :boolean,
        aliases: %i[filevault]
      },

      # @!attribute iCloudDiagnostics
      #   @return [Boolean]
      iCloudDiagnostics: {
        class: :boolean,
        aliases: %i[iclouddiagnostics icloud_diagnostics]
      },

      # @!attribute iCloudStorage
      #   @return [Boolean]
      iCloudStorage: {
        class: :boolean,
        aliases: %i[icloudstorage icloud_storage]
      },

      # @!attribute Registration
      #   @return [Boolean]
      Registration: {
        class: :boolean,
        aliases: %i[registration]
      },

      # @!attribute Registration
      #   @return [Boolean]
      Accessibility: {
        class: :boolean,
        aliases: %i[accessibility]
      }
    ).freeze

    parse_object_model

  end # class location

end # module
