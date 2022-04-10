# Copyright 2022 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# backporting of some newer ruby methods into older rubies
#

# Hash.key
#
# #key exists in ruby 1.9+, in 1.8 its called #index
# it returns the hash key for a given value, if the value exists
# in the hash
#
###########################################
unless {}.respond_to? :key
  class Hash

    alias key index

  end
end

# Array.sample
#
# #sample exists in ruby 1.9+, in 1.8 its called #choice
# it returns a randomly chosen element of the given array
# eg: [1, 2, 3].sample returns either 1, 2, or 3
#
###########################################
unless [].respond_to? :sample
  class Array

    alias sample choice

  end
end

# String.force_encoding
#
#
###########################################
unless ''.respond_to? :force_encoding
  class String

    def force_encoding(_args = nil)
      self
    end

  end
end


# String.casecmp?
#
#
###########################################
unless ''.respond_to? :casecmp?
  class String

    def casecmp?(other)
      return nil unless other.is_a? String

      casecmp(other).zero?
    end

  end
end
