### Copyright 2025 Pixar

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

  class InventoryPreloadRecord < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::InventoryPreloadRecord

    TEST_SN = 'ABC123XYZ987-no-really'
    TEST_DEV_TYPE = 'Computer'
    TEST_USERNAME = 'testy-tester'
    TEST_EA_NAME = 'test-ext-attr'
    TEST_EA_VALUE = 'A valuable value'
    TEST_BARCODE_1_VALUE = 'barcode-1-here'

    # run the tests
    def run_class_tests
      run_collection_tests do_object_tests: false

      # custom object tests... some from the mixin, others overridden here
      create_new # in mixin
      add_data_to_new_with_failures
      save_new_with_failures
      add_data_to_new
      save_new # in mixin
      fetch_new(
        by_name: false,
        by_searchterm: true,
        by_ident: :serialNumber,
        val_to_fetch: TEST_SN
      ) # in mixin
      validate_fetched # in mixin
      modify_fetched
      re_save_fetched # in mixin
      re_fetch
      validate_changes
      delete # in mixin
      confirm_deleted # in mixin
    ensure
      ensure_deleted
    end

    ################
    def add_data_to_new_with_failures
      begin
        @unsaved_new_object.deviceType = 'NotARealDeviceType'
      rescue Jamf::InvalidDataError
        say 'Got expected Jamf::InvalidDataError when setting deviceType to an invalid value (not in the enum)'
        return
      end
      raise 'Setting deviceType to an invalid value (not in the enum) did not raise Jamf::InvalidDataError'
    end

    ################
    def save_new_with_failures
      begin
        @new_object_id = @unsaved_new_object.save
      rescue Jamf::MissingDataError
        say 'Got expected Jamf::MissingDataError when saved with no SN'
      end
      @unsaved_new_object.serialNumber = TEST_SN

      begin
        @new_object_id = @unsaved_new_object.save
      rescue Jamf::MissingDataError
        say 'Got expected Jamf::MissingDataError when saved with no deviceType'
        return
      end

      raise 'Saving without required values did not raise Jamf::MissingDataError'
    end

    ################
    def add_data_to_new
      @unsaved_new_object.deviceType = TEST_DEV_TYPE
      @unsaved_new_object.username = TEST_USERNAME
      @unsaved_new_object.set_ext_attr TEST_EA_NAME, TEST_EA_VALUE
      say "Set deviceType, username, and EA #{TEST_EA_NAME}"
    end

    ################
    def modify_fetched
      @fetched_new_object.barCode1 = TEST_BARCODE_1_VALUE

      say "Changed local instance barCode1 from '' to '#{TEST_BARCODE_1_VALUE}'"
    end

    ################
    def re_fetch
      @fetched_edited_object = collection_class.fetch serialNumber: TEST_SN
      say "Fetched fresh instance of #{collection_class} SN '#{TEST_SN}'"
    end

    ################
    def validate_changes
      if @fetched_edited_object.barCode1 == TEST_BARCODE_1_VALUE
        say "Re-fetched instance of #{collection_class} SN '#{TEST_SN}' has changed barCode1"
        return
      end

      raise "Re-fetched instance of #{collection_class} SN '#{TEST_SN}' did not have changed barCode1"
    end

  end # class

end # module JamfTest
