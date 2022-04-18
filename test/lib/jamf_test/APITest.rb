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

  class APITest

    #####
    def say(msg)
      JamfTest.say msg, from: self.class.to_s
    end

    ##### The main test method
    def run_tests

      # each subclass must define this method
      run_class_tests

      say "Done! Congrats, #{self.class} looks good!"
    end

    #####
    def validate_hash(hash, has_key: nil, val_class: nil)
      raise 'Value is not a Hash' unless hash.is_a? Hash
      return unless has_key

      raise "Hash does not have required key #{has_key}" unless hash.key? has_key
      return unless val_class

      raise "Value for Hash key #{has_key} is not a #{val_class}" unless hash[has_key].is_a? val_class
    end

    #####
    def validate_array(ary, item_class: nil)
      raise 'Value is not an Array' unless ary.is_a? Array
      return unless item_class

      raise 'Array is empty, cannot validate item class' if ary.empty?
      raise "Randomly chosen item from Array is not a #{item_class}" unless ary.sample.is_a? item_class
    end

    # Ruby 3's default behavior when raising exceptions will include the output
    # of #inspect, recursively for all data in an object.
    # For many OAPIObjects, esp JPAPI Resources, this includes the embedded
    # Connection object and all the caches is might hold, which might be
    # thousands of lines.
    # we override that here to prevent that. I've heard rumor this will be
    # fixed in ruby 3.2
    def inspect
      "<#{self.class}:#{object_id}>"
    end

  end # class

end # module JamfTest
