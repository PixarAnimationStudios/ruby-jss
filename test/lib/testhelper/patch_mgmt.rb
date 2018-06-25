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

    # Titles

    def title
      @title ||= JSS::PatchTitle.make name: PATCH_TITLE_NAME
    end

    def name_id
      @name_id ||= prompt_for_name_id
    end

    def unused_name_ids
      return @unused_name_ids if @unused_name_ids
      @unused_name_ids = internal_src.available_name_ids - JSS::PatchTitle.all_name_ids
    end

    def prompt_for_name_id
      puts '***************************'
      puts 'Enter an unused Patch Title name_id for testing.'
      puts 'Must be one of the following:'
      unused_name_ids.each { |ni| puts "  #{ni}" }
      puts
      print 'which one?: '
      chosen = $stdin.gets.chomp
      until unused_name_ids.include? chosen
        puts 'that one isnt on the list'
        print 'which one?: '
        chosen = $stdin.gets.chomp
      end
      chosen
    end

    def refetch_test_title
      @test_title = JSS::PatchTitle.fetch name: PATCH_TITLE_NAME
    end

    def test_version
      @tv ||= title.versions.values.sample
    end

  end # module PatchMgmt

end # module JSSTestHelper
