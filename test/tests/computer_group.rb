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

  class ComputerGroup < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::ComputerGroup

    # run the tests
    def run_class_tests
      run_collection_tests
    end

    #### Collection Test Overrides

    ################
    def create_new
      @unsaved_new_object = collection_class.create name: test_object_name, type: :static
      say "Created new Static #{collection_class}, to be saved in Jamf."
    end

    ################
    def add_data_to_new
      @all_comps_shuffled = Jamf::Computer.all.dup.shuffle
      if @all_comps_shuffled.empty?
        say 'No computers found in Jamf to add to the new Static Group!'
        return
      end

      @comps_added_to_static_group = []

      comp_1 = @all_comps_shuffled.shift
      if comp_1
        @unsaved_new_object.add_member comp_1[:id]
        @comps_added_to_static_group << comp_1[:id]
        say "Added computer id #{comp_1[:id]} to unsaved Static Group"
      end

      comp_2 = @all_comps_shuffled.shift
      if comp_2
        @unsaved_new_object.add_member comp_2[:name]
        @comps_added_to_static_group << comp_2[:name]
        say "Added computer name #{comp_2[:name]} to unsaved Static Group"
      end

      comp_3 = @all_comps_shuffled.shift
      if comp_3
        @unsaved_new_object.add_member comp_3[:serial_number]
        @comps_added_to_static_group << comp_3[:serial_number]
        say "Added computer serial_number #{comp_3[:serial_number]} to unsaved Static Group"
      end

      comp_4 = @all_comps_shuffled.shift
      if comp_4
        @unsaved_new_object.add_member comp_4[:udid]
        @comps_added_to_static_group << comp_4[:udid]
        say "Added computer udid #{comp_4[:udid]} to unsaved Static Group"
      end

      comp_5 = @all_comps_shuffled.shift
      return unless comp_5

      @unsaved_new_object.add_member comp_5[:mac_address]
      @comps_added_to_static_group << comp_5[:mac_address]
      say "Added computer mac_address #{comp_5[:mac_address]} to unsaved Static Group"
    end

    ################
    def validate_fetched
      super

      unless @fetched_new_object.member_ids.sort == @unsaved_new_object.member_ids.sort
        raise 'Original ruby object created with .create does not have the same member ids as the one re-fetched after saving!'
      end

      say "Fetched instance of #{collection_class} has the same members as the one we made with .create"
    end

    ################
    def modify_fetched
      super

      @comps_added_to_static_group.shuffle!
      3.times do
        comp_to_remove = @comps_added_to_static_group.shift
        @fetched_new_object.remove_member comp_to_remove
        say "Removed member with identifier '#{comp_to_remove}'"
      end

      @modified_member_ids = @fetched_new_object.member_ids
    end

    ################
    def validate_changes
      unless @fetched_new_object.member_ids.sort == @fetched_edited_object.member_ids.sort
        raise 'Modified ruby object saved after editing does not have the same member ids as the one originally saved!'
      end

      say "Modified/saved/refetched instance of #{collection_class} has correct membership."

      # Test the class method for changing membership without instantiating/saving
      return unless @all_comps_shuffled.size > 4

      adds = []
      adds << @all_comps_shuffled.shift[:id]
      adds << @all_comps_shuffled.shift[:serial_number]
      adds << @all_comps_shuffled.shift[:udid]
      removes = @fetched_edited_object.member_ids.sample

      collection_class.change_membership @fetched_edited_object.id, add_members: adds, remove_members: removes
      say "Successfully used #{collection_class}.change_membership to immediately add and remove members."
    end

    ################
    def confirm_deleted
      say 'Pausing 15 secs for group deletion to complete...'
      sleep 15
      super
    end

  end # class ComputerGroup

end # module JamfTest
