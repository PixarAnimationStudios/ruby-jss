# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  # Policy Tests
  class Policy < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::Policy

    CUSTOM_TRIGGER = 'ruby-jss-test-custom-trigger'.freeze

    # The main test method for this class
    def run_class_tests
      # policies are special so we define all the object tests here
      run_collection_tests do_object_tests: false
    end

    #################
    def add_data_to_new
      set_new_pol_category
      set_new_pol_pkg
      set_new_pol_trigger
      set_new_pol_scope
    end

    #################
    def set_new_pol_category
      # DEPRECATED - should raise an error, but eventually will not until saved.
      begin
        @unsaved_new_object.category = 'foo-this-is-not-a-real-category'
      rescue Jamf::NoSuchItemError
        nil
      end
      @unsaved_new_object.category = pol_category
      say "Set policy category to: #{pol_category}"
    end

    #################
    def set_new_pol_pkg
      # DEPRECATED - should raise an error, but eventually will not until saved
      begin
        @unsaved_new_object.add_package 'foo'
      rescue Jamf::NoSuchItemError
        nil
      end
      @unsaved_new_object.add_package pol_pkg
      say "Added policy pkg: #{pol_pkg}"
    end

    #################
    def set_new_pol_trigger
      @unsaved_new_object.set_trigger_event :custom, CUSTOM_TRIGGER
      say "Set policy trigger to: #{CUSTOM_TRIGGER}"
    end

    #################
    def set_new_pol_scope
      @unsaved_new_object.scope.add_target :computer, target_computer_name
      say "Set policy scope targets to: #{@unsaved_new_pol.scope.targets}"
      @unsaved_new_object.scope.add_exclusion :computer_group, excluded_group_name
      say "Set policy scope targets to: #{@unsaved_new_pol.scope.exclusions}"
    end

    #################
    def save_new_pol; end

    #################
    def fetch_new_pol; end

    #################
    def validate_new_pol; end

    #################
    def modify_pol; end

    #################
    def save_pol; end

    #################
    def re_fetch_pol; end

    #################
    def validate_changes; end

    #################
    def delete_pol; end

    #################
    def confirm_deleted; end

    #######
    def pol_category
      @pol_category ||= Jamf::Category.all_names.sample
    end

    #######
    def pol_pkg
      @pol_pkg ||= Jamf::Package.all_names.sample
    end

    ########
    def target_computer_name
      @target_computer_name ||= Jamf::Computer.all_names.sample
    end

    ########
    def excluded_group_name
      @excluded_group_name ||= Jamf::ComputerGroup.all_names.sample
    end

  end # class

end # module JamfTest
