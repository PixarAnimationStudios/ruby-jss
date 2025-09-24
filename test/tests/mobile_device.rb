# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class MobileDevice < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::MobileDevice

    # run the tests
    def run_class_tests
      run_collection_tests do_object_tests: false
    end

  end # class

end # module JamfTest
