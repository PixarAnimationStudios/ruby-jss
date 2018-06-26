### Copyright 2018 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

module JSSTestHelper

  # auth
  module PatchMgmt

    EXT_SRC_NAME = 'rubyjss-testPatchSource.company.com'.freeze
    EXT_SRC_PORT = 8843

    PATCH_TITLE_NAME = 'rubyjss-testPatchTitle'.freeze

    PATCHCPOL_NAME = 'rubyjss-testPatchPolicy'.freeze

    module_function

    # Sources

    def internal_src
      @internal_src ||= JSS::PatchInternalSource.fetch id: 1
    end

    def external_src
      @external_src ||= JSS::PatchExternalSource.make name: EXT_SRC_NAME
    end

    def refetch_external_src
      @external_src = JSS::PatchExternalSource.fetch name: EXT_SRC_NAME
    end

    def delete_external_src
      return [] unless JSS::PatchExternalSource.all_names(:refresh).include? EXT_SRC_NAME
      JSS::PatchExternalSource.delete JSS::PatchExternalSource.map_all_ids_to(:name).invert[EXT_SRC_NAME]
    end

    # Titles

    def name_id
      @name_id ||= JSS::PatchInternalSource.available_name_ids(1).sample
    end

    def title(refresh = false)
      @title = nil if refresh
      return @title if @title
      @title =
        if JSS::PatchTitle.all_names.include? PATCH_TITLE_NAME
          JSS::PatchTitle.fetch name: PATCH_TITLE_NAME
        else
          JSS::PatchTitle.make name: PATCH_TITLE_NAME
        end
    end

    def delete_title
      return [] unless JSS::PatchTitle.all_names(:refresh).include? PATCH_TITLE_NAME
      JSS::PatchTitle.delete JSS::PatchTitle.map_all_ids_to(:name).invert[PATCH_TITLE_NAME]
    end

    # Versions

    def version_key
      @version_key ||= title.versions.keys.sample
    end

    # Patch Policies

    def policy(refresh = false)
      @policy = nil if refresh
      return @policy if @policy

      unless title.in_jss
        title.source_id = 1 unless title.source_id
        title.name_id = name_id unless title.name_id
        title.save
      end

      unless title.versions[version_key].package_id.is_a? Integer
        title.versions[version_key].package = JSS::Package.all_ids.sample
        title.save
      end

      @policy =
        if JSS::PatchPolicy.all_names.include? PATCH_TITLE_NAME
          JSS::PatchPolicy.fetch name: PATCH_TITLE_NAME
        else
          JSS::PatchPolicy.make name: PATCH_TITLE_NAME, patch_title: title
        end
    end

    def delete_policy
      return [] unless JSS::PatchPolicy.all_names(:refresh).include? PATCHCPOL_NAME
      JSS::PatchPolicy.delete JSS::PatchPolicy.map_all_ids_to(:name).invert[PATCHCPOL_NAME]
    end


  end # module PatchMgmt

end # module JSSTestHelper
