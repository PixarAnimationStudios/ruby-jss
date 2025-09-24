# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class Category < JamfTest::APITest

    include JamfTest::CollectionTests

    COLLECTION_CLASS = Jamf::Category

    # run the tests
    def run_class_tests
      run_collection_tests
    end

  end # class

end # module JamfTest
