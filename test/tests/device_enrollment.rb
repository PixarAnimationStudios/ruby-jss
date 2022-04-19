### Copyright 2022 Pixar

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

  class DeviceEnrollment < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::DeviceEnrollment

    # run the tests - order matters
    def run_class_tests
      run_collection_tests do_object_tests: false

      fetch_all_devices
      fetch_all_devices_for_instance
      fetch_all_sync_history
      fetch_sync_history_for_instance
      fetch_latest_sync_for_instance
    end

    ########
    def fetch_all_devices
      validate_array Jamf::DeviceEnrollment.devices, item_class: Jamf::OAPISchemas::DeviceEnrollmentDevice
      say 'Fetched devices for all DeviceEnrollment instances'
    end

    #########
    def fetch_all_devices_for_instance
      @cached_all = Jamf::DeviceEnrollment.all
      inst_name = Jamf::DeviceEnrollment.all_names(cached_list: @cached_all).sample
      inst_id = Jamf::DeviceEnrollment.valid_id inst_name
      inst_devices = Jamf::DeviceEnrollment.devices inst_name
      validate_array inst_devices, item_class: Jamf::OAPISchemas::DeviceEnrollmentDevice

      if inst_devices.sample.deviceEnrollmentProgramInstanceId == inst_id
        say "Fetched devices for DeviceEnrollment instance '#{inst_name}'"
        return
      end

      raise "Device returned by Jamf::DeviceEnrollment.devices('#{inst_name}') has different deviceEnrollmentProgramInstanceId than the id of '#{inst_name}'"
    end

    ######
    def fetch_all_sync_history
      validate_array Jamf::DeviceEnrollment.sync_history, item_class: Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus
      say 'Fetched sync history for all DeviceEnrollment instances'
    end

    #########
    def fetch_sync_history_for_instance
      @cached_all = Jamf::DeviceEnrollment.all
      inst_name = Jamf::DeviceEnrollment.all_names(cached_list: @cached_all).sample
      inst_history = Jamf::DeviceEnrollment.sync_history inst_name
      say "Fetched Sync History for DeviceEnrollment instance '#{inst_name}'"
      return if inst_history.empty?

      validate_array inst_history, item_class: Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus
    end

    #########
    def fetch_latest_sync_for_instance
      @cached_all = Jamf::DeviceEnrollment.all
      inst_name = Jamf::DeviceEnrollment.all_names(cached_list: @cached_all).sample
      inst_latest = Jamf::DeviceEnrollment.sync_history inst_name, latest: true
      raise "Latest Sync History for DeviceEnrollment instance '#{inst_name}' did not return a Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus object" unless inst_latest.is_a? Jamf::OAPISchemas::DeviceEnrollmentInstanceSyncStatus

      say "Fetched Latest Sync History for DeviceEnrollment instance '#{inst_name}'"
    end

  end # class

end #  JamfTest
