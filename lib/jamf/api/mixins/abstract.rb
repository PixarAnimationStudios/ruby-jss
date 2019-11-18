# Copyright 2019 Pixar
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

module Jamf

  # This mixin should be extended in abstract class definitions
  # it will raise an error if those classes are instantiated.
  # It also maintains an array of classes that extend themselves this way
  # and are abstract.
  module Abstract

    # when a class is extended by this module, it
    # gets added to the array of known abstract classes
    def self.extended(by_class)
      abstract_classes << by_class
    end

    # Classes will be added to this array as they are exteded by Abstract
    def self.abstract_classes
      @abstract_classes ||= []
    end

    def self.abstract?
      abstract_classes.include? self
    end

    # when any extended class or subclass of an extended class is instntiated
    # check that it isn't in the abstract list.
    def new(*args, &block)
      raise Jamf::UnsupportedError, "Unsupported: #{self} is an abstract class, cannot be instantiated." if Jamf::Abstract.abstract_classes.include? self

      super
    end

  end # module Abstract

end # Jamf
