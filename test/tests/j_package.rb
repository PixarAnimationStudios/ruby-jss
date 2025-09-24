# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class JPackage < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::JPackage

    # run the tests
    def run_class_tests
      run_collection_tests
    end

    def create_new
      @unsaved_new_object = collection_class.create packageName: test_object_name
      @unsaved_new_object.fileName = "#{test_object_name}.pkg"
      say "Created new #{collection_class}, to be saved in Jamf."
    end

  end # class

end # module JamfTest
