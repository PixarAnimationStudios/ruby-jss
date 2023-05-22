### Copyright 2023 Pixar

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

module JamfTest

  module PrestageTests

    include JamfTest::CollectionTests

    # run the tests
    def run_class_tests
      run_collection_tests do_object_tests: false

      if @cached_all.empty?
        say 'No ComputerPrestages defined, skipping remaining tests'
        return
      end

      # class methods
      fetch_default_prestage
      all_serials_by_prestage_id
      serials_for_prestage

      unless @sampled_sn
        say 'No serial numbers assigned to any prestage, cannot continue tests on this server.'
        return
      end

      assigned_prestage_id
      assigned_via_class

      say 'NOTE: Not testing assign/unassign. Too much potential for havoc on prod. servers. Use IRB to test manually'

      # instance methods
      scope
      assigned_via_scope
    end

    #########
    def fetch_default_prestage
      @default_computer_prestage = collection_class.default
      say "Ran #{collection_class}.default to fetch the default Computer prestage"
    end

    #########
    def all_serials_by_prestage_id
      serials = collection_class.serials_by_prestage_id
      say "Ran #{collection_class}.default to fetch the default Computer prestage"
      validate_hash serials, key_class: String, val_class: String
      @sampled_sn = serials.keys.sample
      @sample_prestage_id = serials[@sampled_sn]
    end

    ###########
    def serials_for_prestage
      collection_class.serials_for_prestage @default_computer_prestage.id
      say "Ran #{collection_class}.serials_for_prestage '#{@default_computer_prestage.id}'"

      collection_class.serials_for_prestage @default_computer_prestage.displayName
      say "Ran #{collection_class}.serials_for_prestage '#{@default_computer_prestage.displayName}'"
    end

    ##########
    def assigned_prestage_id
      looked_up_id = collection_class.assigned_prestage_id @sampled_sn, :refresh
      say "Ran #{collection_class}.assiged_prestage_id '#{@sampled_sn}', :refresh"

      if looked_up_id == @sample_prestage_id
        say "Prestage id returned was '#{looked_up_id}' as expected"
        return
      end

      raise "Prestage id returned was '#{looked_up_id}' but expected '#{@sample_prestage_id}'"
    end

    ##########
    def assigned_via_class
      assigned = collection_class.assigned? @sampled_sn, refresh: false
      say "Ran #{collection_class}.assigned? '#{@sampled_sn}', refresh: false"
      raise "Expected #{collection_class}.assigned? '#{@sampled_sn}' to return true, but got false" unless assigned

      assigned = collection_class.assigned? 'NotA-Real-SerialNumber', refresh: false
      say "Ran #{collection_class}.assigned? 'NotA-Real-SerialNumber', refresh: false"
      raise "Expected #{collection_class}.assigned? 'NotA-Real-SerialNumber' to return false, but got true" if assigned
    end

    ###########
    def scope
      @default_computer_prestage_scope = @default_computer_prestage.scope
      say "Ran #{collection_class}#scope on default prestage"
      unless @default_computer_prestage_scope.is_a?(Jamf::OAPISchemas::PrestageScopeResponseV2)
        raise 'Returned scope is not a Jamf::OAPISchemas::PrestageScopeResponseV2'
      end

      say 'Validating #assignments'
      validate_array @default_computer_prestage_scope.assignments, item_class: Jamf::OAPISchemas::PrestageScopeAssignmentV2
      say 'scope assignments are valid'
    end

    ##############
    def assigned_via_scope
      assigned = @default_computer_prestage.assigned? @sampled_sn
      say "Ran @default_computer_prestage.assigned? '#{@sampled_sn}'"
      raise "Expected @default_computer_prestage.assigned? '#{@sampled_sn}' to return true, but got false" unless assigned

      assigned = @default_computer_prestage.assigned? 'NotA-Real-SerialNumber'
      say "Ran @default_computer_prestage.assigned? 'NotA-Real-SerialNumber'"
      raise "Expected @default_computer_prestage.assigned? 'NotA-Real-SerialNumber' to return false, but got true" if assigned
    end

  end # module

end # module JamfTest
